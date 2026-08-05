---
title: "Spec: a pool that accepts a wildcard descriptor as miner identity and derives each coinbase payout address from the block height"
type: plan
format: spec
generated: 2026-07-29
revised: 2026-07-30
confidence: medium
host_scheme: PPLNS-JD / SV2 (share-accounting-ext type 32)
rotation_trigger: block height as derivation index (stateless)
descriptor_intake: SV2 user_identity (V1 via Translator passthrough — 7 Translator changes §3.2.2 + 6 pool-side changes §3.2.3; requires aggregate_channels = false)
blocking_defect: a valid descriptor in user_identity is paid 100% to the pool today (NoPayoutMode → FullDonation) — must be fixed in Phase 1 before any descriptor can be delivered (§3.2.3)
payout_window: N = 8 × D in accumulated share difficulty (NOT 8 blocks) — per TIDES and SLICE
share_retention: by accumulated difficulty, past the window edge to survive a 4× upward retarget (§2.5)
miner_identity_policy: distinct descriptor = distinct user; no linking or migration, miner-managed (§2.5)
sources:
  - "wiki/concepts/xpub-payout-identity.md"
  - "wiki/concepts/coinbase-address-rotation.md"
  - "wiki/concepts/pplns-jd.md"
  - "wiki/concepts/payout-attribution-privacy.md"
  - "wiki/concepts/coinbase-amount-linkability.md"
  - "wiki/concepts/lottery-pplns.md"
  - "wiki/concepts/tides.md"
  - "wiki/concepts/ctv-coinbase-payout-tree.md"
  - "wiki/concepts/block-withholding.md"
  - "wiki/concepts/payout-schema-taxonomy.md"
  - "wiki/concepts/sv2-share-accounting-ext.md"
  - "wiki/concepts/pplns.md"
  - "wiki/decisions/attribution-retention-tradeoffs.md"
  - "wiki/topics/self-blinding-pool-design-space.md"
  - "output/playbook-self-blinding-pool-attribution-2026-07-29.md"
  - "output/report-blinded-share-credit-thesis-2026-07-29.md"
  - "wiki/theses/blinded-share-credit-commitment.md"
  - "raw/repos/2026-07-29-pool-identity-vs-payout-script-conflation-code-read.md"
  - "raw/repos/2026-07-29-sv2-apps-xpub-coinbase-rotation-code-read.md"
  - "raw/repos/2026-07-29-bip352-silent-payments-coinbase-incompatibility.md"
  - "raw/papers/2026-07-29-romiti-2019-mining-pool-payout-deanonymization.md"
summary: "Technical spec for a pool taking a BIP-380 wildcard descriptor as SV2 user_identity and deriving each miner's coinbase scriptPubKey at index = the block height being mined. Height indexing makes derivation a pure function of (descriptor, height): no pool-side index state, no persistence ordering, no rotation trigger, and recovery survives the pool's death. Hosted on PPLNS-JD because its Slice/Share ledger is already identity-free. V1 miners reach it through SV2 Translator passthrough — the miner sets its own username to the descriptor and the Translator forwards it unmodified — which needs 7 Translator changes and, larger, 6 pool-side changes: payout identity is scoped to the TCP connection rather than the channel, so N devices behind one Translator collapse to the last-opened identity from the next NewTemplate onward. Per-device payout additionally requires aggregate_channels = false, which is a structural requirement and not a tuning knob. One blocking defect found by code read: a valid untruncated descriptor in user_identity resolves to NoPayoutMode, which the pool maps to FullDonation — 100% of the block to the pool, silently, for the connection's lifetime. Identity is miner-managed: a distinct descriptor is a distinct user with no pool-side linking or migration. The pool's obligation is share retention, and the window is N = 8 × D in *accumulated share difficulty* — not 8 blocks, so a 1% pool's window is ~5.5 days of wall-clock — with retention extending past the window edge because an upward difficulty retarget grows the window backwards. Thirteen sections: descriptor grammar and the load-bearing has_wildcard() rejection, the payout_id/script split, the user_identity grammar collision on '/', and an honest privacy scope — this defeats Romiti et al. on chain and is a pool-side no-op."
---

# Spec: wildcard-descriptor miner identity with height-indexed coinbase derivation

> Generated from the [bitcoin-mining-payout-schemas](../_index.md) wiki — 15 articles, 4 raw sources, and 2 prior outputs consulted, plus an exhaustive multi-agent code read of the `sv2-apps-coinbase-rotation` clone at HEAD `e2930150` (§12). **Revised four times**: to height-as-index (§4), which deleted the derivation-store section entirely, with finder bonus moved out of scope; then to **V1 Translator passthrough** (§3.2); then (2026-07-30) to put identity management on the miner and replace it with a **share-retention** requirement (§2.5), the window being `N = 8 × D` in *accumulated share difficulty*; then (2026-07-30, fifth) to correct §3.2 against the code — the Translator work is **7 changes not 3**, the pool-side work is **6 more and larger**, `aggregate_channels = false` is a hard requirement, the 32-byte cap must be **left alone**, and a valid descriptor is **paid 100% to the pool today**. Open questions #2 and #3 are **closed**. See §13.

## 0. Summary and scope

A miner authenticates to the pool with a **BIP-380 wildcard output descriptor** (e.g. `wpkh(xpub…/0/*)`) instead of a literal address. When the pool builds a coinbase for block height `H`, each paid miner's output pays `descriptor.at_derivation_index(H)`. No miner is paid the same address twice, because no height repeats.

**The load-bearing property is that derivation is a pure function of `(descriptor, height)`.** The pool stores no index, advances no counter, and persists nothing on the payout path. This one choice deletes an entire class of failure — see §4.1 for what it buys and §4.2 for the cost you are accepting.

**Host scheme: PPLNS-JD / SV2** with `share-accounting-ext` (extension type 32). This is chosen because it is the only surveyed scheme whose ledger is *already* decoupled: its `Slice{number_of_shares, difficulty, fees, root, job_id}` and `Share{nonce, ntime, version, extranonce, job_id, share_index, merkle_path}` structures contain **not one identity field**, and the ledger primary key is positional — `(slice, share_index)`, verified by `merkle_path(share) + share_hash == slice.root`. Every other scheme must retrofit a decoupling that PPLNS-JD gets for free. ckpool by contrast converts `username[128]` *directly into* the payout script via `address_to_txn()` into `txnbin[48]`; public-pool makes `address varchar(62)` part of a composite `PRIMARY KEY`.

**Explicitly in scope**: descriptor intake and validation, the ledger-key/payout-script split, height-indexed coinbase assembly, miner recovery, and the operator runbook.

**Explicitly out of scope**: **finder bonus** — no flat bounty to the block finder, so every miner appears exactly once per payout list, which is what makes height indexing safe (§4.3.1); **any linking, migration, or reconciliation between miner identities** — a distinct descriptor is a distinct user and identity management is the miner's responsibility (§2.5); blinding the pool to attribution (see §9.2 — this design is a pool-side privacy *no-op* by construction, and saying otherwise would be false); balance accrual to a payout threshold (see §4.4 — accrual is custody, and custody is the regulatory trigger); output-count compression via covenants (see [[../wiki/concepts/ctv-coinbase-payout-tree|CTV Coinbase Payout Tree]]).

> **Scope interaction worth stating once.** Height indexing and "no finder bonus" are not independent choices. Because index is a pure function of height, a miner can have **exactly one address per block** — so any scheme paying a miner twice in one block (bonus + proportional share) must merge those rows into one output or it cannot be expressed at all. With the finder bonus out of scope this is free. If it ever comes back, read §4.3.1 first.

**Prior-art status, and it is unusual**: **no pool anywhere accepts an xpub, output descriptor, or payment code as a miner's payout identity.** That is a confirmed negative result, verified against source for ckpool, public-pool, DATUM, the SV2 reference apps, and Ocean's docs — not an unsearched gap. Upstream SV2 shipped `coinbase_output_descriptors` in PR #1720 (merged 2025-07-09) but **wildcards remain rejected in merged code**, and its scope is the pool's own single output, not per-miner. This spec is therefore a greenfield design, not an integration against a known-good reference.

Note what the merged code's rejection comment actually says: *"no wildcards allowed (at least for now; gmax thinks it would be cool if we would instantiate it with the blockheight or something, but need to work out UX)."* **This spec implements that parenthetical.** The height-indexing choice in §4 is not novel invention — it is the deferred upstream idea, with §6 as the "work out UX" part that deferred it.

## 1. System architecture

```
  V1 miner ──┐
   mining.   │  stratum V1
   authorize │  username = descriptor
  (descriptor)
             ▼
      ┌──────────────┐              ┌──────────────────────────────────────┐
      │ SV2          │   SV2        │  POOL                                │
      │ Translator   │──────────────┼─▶┌──────────────┐                    │
      │ (§3.2 —      │ user_identity│  │  Identity    │ validate (§3.1)    │
      │  PASSTHROUGH │ (unmodified) │  │  Intake      │ hard-fail gate     │
      │  of miner's  │              │  └──────┬───────┘                    │
      │  own ident.) │              │         │ payout_id = H(descriptor)  │
      └──────────────┘              │         ▼                            │
                                    │  ┌──────────────────┐                │
  SV2 miner ────────────────────────┼─▶│ Share Accounting │ ledger key =   │
   OpenExtendedMiningChannel        │  │   (unchanged)    │ (slice,        │
   user_identity = descriptor       │  └──────┬───────────┘  share_index)  │
                                    │         │              NO address    │
                                    │         │ block found @ height H     │
                                    │         ▼                            │
                                    │  ┌──────────────────┐                │
                                    │  │ Payout Resolver  │                │
                                    │  │ (§4)             │                │
                                    │  └──────┬───────────┘                │
                                    │         │  script =                  │
                                    │         │  descriptor.at_index(H)    │
                                    │         │  ── pure function,         │
                                    │         │     NO STORED STATE ──     │
                                    │         ▼                            │
                                    │  ┌──────────────────┐                │
                                    │  │ Coinbase         │ N outputs, all │
                                    │  │ Assembly         │ derived at H   │
                                    │  └──────────────────┘                │
                                    └──────────────────────────────────────┘
```

Two structural properties carry the design:

- **The share-accounting path never sees an address or a descriptor.** Identity reaches the ledger only as an opaque `payout_id`.
- **The payout path holds no state.** There is no derivation store, no counter, and nothing to persist, corrupt, or restore incorrectly. Compare the [[../wiki/concepts/coinbase-address-rotation|counter-based implementations]], where persistence *is* the correctness core — an entire section of this spec's first draft, now deleted.

### 1.1 Components

| Component | Responsibility | New? |
|---|---|---|
| **SV2 Translator** | Terminates V1 miners; **passes the miner's own authorized username through** as the upstream channel's `user_identity` (§3.2) | **Existing, requires modification** — 7 changes, see §3.2.2. Requires `aggregate_channels = false` (§3.2.1a) |
| **Pool channel/job pipeline** | Bind payout identity **per channel**, not per TCP connection; build coinbase outputs per extended channel | **Modified — 6 changes, see §3.2.3.** Prerequisite for *any* multi-channel connection to pay correctly, descriptor or not |
| **Identity Intake** | Parse and validate descriptor from `user_identity`; compute `payout_id`; reject at channel-open on failure | New |
| **Share Accounting** | Unmodified `share-accounting-ext` slice/share ledger | Unchanged |
| **Payout Resolver** | On block found at height `H`: compute payout list, derive each paid miner's script at index `H` | Modified |
| **Coinbase Assembly** | Build coinbase from resolved scripts | Modified |
| ~~Derivation Store~~ | **Eliminated by height indexing.** No component owns index state. | — |

## 2. Data model

### 2.1 Identity record

```sql
CREATE TABLE miner_identity (
    payout_id        BLOB PRIMARY KEY,   -- 32-byte tagged hash of normalized descriptor (§2.2)
    descriptor       TEXT NOT NULL,      -- normalized, checksummed, ~150 chars typical
    created_at       INTEGER NOT NULL,
    last_paid_at     INTEGER
);
-- No next_index. No highest_paid. Index is the block height; there is no
-- derivation state to store, advance, back up, or restore incorrectly.

CREATE TABLE payout_receipt (          -- audit + miner receipt; append-only, NOT recovery-critical
    block_height     INTEGER NOT NULL, -- this IS the derivation index
    payout_id        BLOB    NOT NULL,
    script_pubkey    BLOB    NOT NULL, -- denormalized for audit convenience
    amount_sats      INTEGER NOT NULL,
    PRIMARY KEY (block_height, payout_id)
);
```

Four deliberate choices:

- **`payout_id` is the primary key, not the address.** This is the whole point. A schema doing `ON CONFLICT (address) DO UPDATE` keys balances on address *globally*, so a miner whose address changes every block writes a new row every block and pending-credit carry-forward silently stops working. That failure is silent accounting drift, not a crash.
- **`derivation_index` is gone as a column** — it would be an exact duplicate of `block_height`. The old `UNIQUE (payout_id, derivation_index)` constraint is likewise gone: with index ≡ height, the primary key already enforces it. The invariant "no index is paid twice" stops being something to *check* and becomes something the design cannot express. That is the single largest correctness win of this revision.
- **`payout_receipt` is an audit table, not a recovery dependency.** In the counter design, losing this table meant losing the ability to reconstruct which indices had been paid. Here it is pure convenience: a miner who knows the pool's found-block heights can re-derive every script themselves, and those heights are on the public chain forever (§6).
- **`PRIMARY KEY (block_height, payout_id)`** guarantees one row per miner per block. With the finder bonus out of scope this is naturally satisfied. It is also the constraint that would *fire* rather than silently misbehave if a finder bonus were added without merging first (§4.3.1).

### 2.2 `payout_id` derivation

```
payout_id = SHA256(SHA256("pool/payout-id/v1") || normalized_descriptor_without_checksum)
```

Normalize before hashing: strip the `#checksum` suffix, lowercase hex, and **strip key-origin information entirely** — not merely canonicalize its spacing. Two textually different spellings of the same descriptor **must** yield the same `payout_id`, or a miner silently splits into two ledger identities and loses accrued credit.

> **Why origin *presence*, not just origin spacing.** `wpkh([d34db33f/84h/0h/0h]xpub6ER…/0/*)` and `wpkh(xpub6ER…/0/*)` wrap the same xpub. Spacing canonicalization leaves them textually distinct, so they hash to **different `payout_id`s** — while `at_derivation_index(H).script_pubkey()` returns **byte-identical** scripts. That produces two coinbase outputs paying the same address in one transaction: precisely the failure §4.3.1 exists to prevent, and §4.3.1's `PRIMARY KEY (block_height, payout_id)` backstop **passes** it, because the `payout_id`s differ. Reachable two ways with no bug anywhere — a miner adding or removing origin info between sessions, or one operator configuring two rigs inconsistently. Origin-only variants of one xpub must be **one** `payout_id`, and §4.3's assembly additionally asserts script distinctness *after* derivation (§4.3.1) because no `payout_id`-level check can catch this class.

### 2.3 Descriptor acceptance grammar

Accepted: **unhardened, single-path, wildcard-terminated**, exactly one wildcard, no private keys.

| Form | Verdict | Why |
|---|---|---|
| `wpkh(xpub…/0/*)`, `tr(xpub…/0/*)`, `pkh(…/*)` | **accept** | The target shape |
| `wpkh(xpub…)` — no wildcard | **reject** | §3.1 — the load-bearing rejection |
| `.../0h/*` or `.../0'/*` — hardened step | **reject** | Pool holds only public key material; cannot derive through a hardened step |
| `<0;1>` multipath (BIP-389) | **reject** | The receive/change pair is meaningless for a coinbase, which is always "receive" |
| any `xprv`/`tprv` | **reject, do not log the string** | Pool must never hold spending authority. Treat as a credential leak: reject, emit a redacted diagnostic, never write the value to logs or the DB |
| `addr(bc1q…)` | **reject at this endpoint** | Static addresses are a valid pool feature but not *this* feature; a static miner must not silently get a "rotating" identity |
| BIP-352 silent payment address | **reject — structurally impossible** | See §2.4 |
| `sh(wpkh(…/*))`, `multi(…/*)` | **accept if the implementation can derive it**; reject otherwise | Fail closed rather than derive a script you cannot construct |

### 2.4 BIP-352 silent payments cannot work here

Worth stating in the spec so nobody proposes it as a follow-up. BIP-352 requires `a = a_1 + … + a_n`, the sum of **input private keys**, and fails when `a = 0` (the receiver skips a transaction whose `A` is the point at infinity). A coinbase is defined by consensus as `vin.size() == 1 && vin[0].prevout.IsNull()` — there is no input private key, so there is no ECDH shared secret to derive from. This is structural, not a missing implementation: "coinbase" appears zero times in BIP-352's 524 lines, and no proposal exists for a coinbase-specific tweak substitute.

### 2.5 Identity is the miner's to manage; the pool's job is share retention

**`payout_id` is the account.** A different descriptor is a different account — including a new descriptor arriving on the same connection from the same physical miner. The pool treats it as a new user, credits it as a new user, and does not attempt to relate it to any previous identity. Managing identity is the miner's responsibility, not the pool's, and no mechanism here links, migrates, or reconciles one identity to another.

The invariant this rests on:

> A share is credited to the `payout_id` that was live when it was submitted, permanently. Nothing later reassigns it.

What the pool owes is narrower and purely mechanical: **retain enough share history to pay everyone the window can still reach.**

#### The window is `8 × D` *shares*, not 8 blocks

The unit matters, and getting it wrong understates retention badly. `N = 8 × D` is a **share count** — eight times the network difficulty expressed in shares — not a count of blocks. Both production non-custodial schemes define it this way: TIDES's `share_log_window = 8 × current_block_difficulty` with **N scaling with D and no fixed share count** ([[../wiki/concepts/tides|TIDES]]), and SLICE/PPLNS-JD's *"multiplies it by 8 to create the look back window"* ([[../wiki/concepts/pplns-jd|PPLNS-JD]]). The [[../wiki/concepts/sv2-share-accounting-ext|share-accounting extension]] gives the boundary operationally: walk back from the block accumulating slice difficulty until the cumulative total reaches the window threshold; the block-finding slice is excluded.

So the window is a quantity of **accumulated share difficulty**, and how long it takes *this pool* to accumulate it depends entirely on the pool's hashrate:

| Pool share of network hashrate | Time to accumulate `8 × D` of shares |
|---|---|
| 100 % (hypothetical) | ~80 minutes |
| 10 % | ~13 hours |
| 1 % | ~5.5 days |
| 0.1 % | ~55 days |

A small pool's window is **weeks of wall-clock time**, not minutes. Any retention policy written against "8 blocks" or "~80 minutes" would discard shares that are still owed payment. Retention must be driven by accumulated difficulty, never by a clock or a block count.

#### Difficulty adjustment is why retention must exceed the current window

`D` changes every 2016 blocks, so the window's size in shares changes with it. **When difficulty adjusts upward, the window grows** — and it grows *backwards*, reaching further into share history than it did before the adjustment. Shares that sat just outside the window at the old `D` can fall back inside it at the new `D`.

Therefore: **the pool must retain shares beyond the current window's edge**, sized so that a plausible upward adjustment cannot reach past the oldest retained share. Pruning to exactly the current window is a correctness bug that only manifests after an upward retarget, which makes it the kind that ships and sits quiet. Bitcoin's retarget is clamped to a factor of 4 per period, so retaining `4 × 8 × D = 32 × D` of accumulated share difficulty is the worst-case-safe floor at the current `D`; a pool wanting margin across consecutive adjustments retains more. Whatever the chosen figure, it is expressed in accumulated share difficulty, computed from the current `D`, and re-evaluated at each retarget.

Retention beyond that is not required for payout correctness. `miner_identity` rows must outlive any share that can still be paid — an unpaid share must always be able to resolve its descriptor — but nothing here requires keeping identity or share data indefinitely. A pool may prune past the retarget-safe horizon, and the attribution-minimizing posture in §9.2 argues for doing so. See [[../wiki/decisions/attribution-retention-tradeoffs|Attribution Retention Tradeoffs]].

## 3. Intake API

### 3.1 The load-bearing validation: reject descriptors without a wildcard

**This is the single most important requirement in the spec.**

A descriptor without a wildcard — `wpkh(<xpub>)`, `tr(<xpub>)` — **parses successfully and then returns the same address forever.** Nothing errors. The rotation code runs on every block, derives, writes bytes identical to what was already there, and the operator's only signal is noticing repeated addresses on chain weeks later.

Both known rotation implementations independently guard this with the same API — miniscript's `has_wildcard()`, checked at construction and hard-failing. Two codebases converging on the identical call is strong evidence it is the right place to fail. **A rotation implementation without this check is broken by default**, because the broken configuration is also the most natural thing an operator or miner would write.

At per-miner granularity the exposure multiplies: there are as many opportunities to miss it as there are miners, and each silently-static miner looks exactly like a working one.

```rust
fn validate_descriptor(s: &str) -> Result<Descriptor<DescriptorPublicKey>, IntakeError> {
    let d: Descriptor<DescriptorPublicKey> = s.parse()
        .map_err(|e| IntakeError::Unparseable(e))?;
    if d.to_string().contains("prv") { return Err(IntakeError::PrivateKeyOffered) } // redacted diagnostic
    if !d.has_wildcard()             { return Err(IntakeError::NoWildcard) }        // §3.1 — hard fail
    if d.is_multipath()              { return Err(IntakeError::MultipathRejected) }
    if has_hardened_steps(&d)        { return Err(IntakeError::HardenedStepRejected) }
    d.sanity_check().map_err(IntakeError::Insane)?;
    // Probe at the CURRENT TIP HEIGHT and far beyond it — not at 0. Under height
    // indexing, index 0 is never used, and a descriptor that derives at 0 but not
    // at ~900_000 would pass a naive check and then fail at block-found.
    let tip = current_tip_height();
    for probe in [tip, tip + 210_000, (1u32 << 31) - 1] {
        d.at_derivation_index(probe)?.script_pubkey();
    }
    Ok(d)
}
```

The probe range matters more here than in the counter design, and differently. Under a counter, indices start at 0 and creep upward, so probing 0 is representative. Under height indexing **index 0 is never used** — the first address a miner is ever paid at is ~900,000. Probing the tip, the tip plus roughly four years of blocks, and the unhardened ceiling `2^31-1` proves the descriptor works in the range it will actually be used in. Accepting a descriptor and *then* discovering at block-found that it cannot be derived means the pool has already accepted work it cannot pay for.

The unhardened ceiling is worth one sentence of arithmetic: BIP-32 unhardened indices run to `2^31-1` = 2,147,483,647, and the chain is at ~900,000. At 144 blocks/day that ceiling is ~40,800 years away. Height indexing does not meaningfully consume the keyspace.

### 3.2 Transport: SV2 `user_identity`, with V1 reaching it through the Translator

The descriptor arrives in SV2's `user_identity` field on `OpenExtendedMiningChannel` / `OpenStandardMiningChannel`. That field is `Str0255` (`mining_sv2-11.0.0/src/open_channel.rs:131`, max 255 bytes per `binary_sv2-6.0.0/src/datatypes/non_copy_data_types/mod.rs:52`), which accommodates a ~150-byte wildcard descriptor with headroom. **255 is the real binding limit on the payout path.** The 32-byte figure the previous revision treated as binding is on a different path entirely — see §3.2.1c.

**V1 miners are not excluded.** They connect to an **SV2 Translator**, which terminates the V1 session and opens an SV2 channel upstream. The intended shape is passthrough: the V1 miner sets its own `mining.authorize` username to its descriptor, and the Translator forwards that identity to the upstream channel unmodified. The Translator is a proxy, not the owner of payout identity. That keeps the property that matters — **each device controls its own payout descriptor** — and gives a V1 farm per-rig identity rather than one identity per Translator.

The pool cannot tell whether a channel came from a native SV2 miner or a translated V1 rig, and does not need to: its `SetupConnection` handler reads only `flags` and discards `vendor` / `hardware_version` / `firmware` / `device_id` (`pool-apps/pool/src/lib/downstream/common_message_handler.rs:33-106`), and `Downstream` has no field to hold them. **Channel *provenance* is invisible to the pool. Channel *count* is not**, and that distinction is where the previous revision's sequencing argument fails — see §3.2.3.

### 3.2.1 The `user_identity` grammar collision — check this before writing any code

`sv2-apps` already assigns meaning to `user_identity`, and it **splits on `/`**:

```rust
let mut parts = user_identity.split('/');
match (parts.next(), parts.next(), parts.next(), parts.next()) {
    (Some("sri"), Some("solo"), Some(payout_address), _) => { … }
    (Some("sri"), Some("donate"), Some(percentage), Some(payout_address)) => { … }
    (Some("sri"), Some(_), _, _) => Err(PayoutModeError::InvalidUserIdentity(…)),
    _ => Err(PayoutModeError::NoPayoutMode(…)),
}
```

**A wildcard descriptor is full of `/`** — `wpkh([d34db33f/84h/0h/0h]xpub…/0/*)` contains six. The two grammars share a delimiter, which is the kind of thing that works in testing and breaks on a real descriptor.

What saves it is ordering, and the existing code has the right *shape* but not the right *content*: `PayoutMode::try_from` tries `script_from_address(addr)` **first** and only falls through to `split('/')` if that fails — but `script_from_address` wraps its input as `addr(<input>)` (`stratum-apps/src/payout.rs:429-436`), which cannot parse a `wpkh(...)`, so today a descriptor falls through the `/`-split to `NoPayoutMode` and then to `FullDonation` (§3.2.3). The precedence slot exists; the descriptor arm that belongs in it does not. So the rule for this spec is explicit:

1. **Try descriptor parse first.** If `validate_descriptor()` succeeds, this is a descriptor identity. Stop. Never reach the `/`-splitting branch.
2. **Only then** fall through to the `sri/...` payout-mode grammar.
3. **Never** feed a `user_identity` to both parsers and merge results.

Two reasons this ordering and not the reverse: a descriptor is self-identifying (it has a checksum, and `wpkh(`/`tr(`/`pkh(` prefixes that `sri` cannot produce), whereas `sri/solo/<addr>` is a bare-token grammar that could in principle be shadowed. And a descriptor beginning with `sri` is impossible, while a `sri/...` string that accidentally parses as a valid checksummed descriptor is also impossible — so the two languages are disjoint *as long as* you commit to one direction of precedence. Write a test asserting `sri/solo/bc1q…` is **not** treated as a descriptor identity and that a descriptor is **not** treated as a payout mode (§8.1).

### 3.2.1a `aggregate_channels = false` is a hard requirement

**Per-device payout is structurally impossible in Aggregated mode.** In `aggregate_channels = true` the Translator emits exactly **one** upstream `OpenExtendedMiningChannel` per upstream-connection lifetime, however many V1 devices attach. Only the `AggregatedState::NoChannel` arm reaches `upstream_sender` (`miner-apps/translator/src/lib/sv2/channel_manager/mod.rs:498-565`); devices arriving while the state is `Pending` are buffered (`:491-497`) and drained locally (`sv2/channel_manager/mining_message_handler.rs:374-398`); devices arriving in `Connected` are answered entirely in-process by `handle_downstream_channel_request_in_aggregated_mode` (`mod.rs:864-1002`), which synthesizes `OpenExtendedMiningChannelSuccess` and sends it to `sv1_server_sender`, never upstream.

Since the channel-open `user_identity` is the **only** field the pool parses for payout (`pool-apps/pool/src/lib/channel_manager/mining_message_handler.rs:143` standard, `:389` extended), aggregated mode can carry at most **one descriptor per Translator**. Devices are distinguished only by a translator-minted 2-byte `local_index` inside the extranonce (`sv2/channel_manager/mod.rs:44`, `:53-54`), which the pool treats as opaque nonce search space and for which it holds no descriptor map — that map exists only inside the Translator process.

The consequence is worse than a lost feature: pushing per-device descriptors through an aggregated Translator pays **the entire farm at one arbitrary device's identity**. So:

> **Requirement.** Descriptor identities require `aggregate_channels = false`. The Translator MUST refuse to start when a descriptor identity is in play and `aggregate_channels = true`, rather than leaving it to operator configuration.

Startup validation is cheap because the field is **required with no default** — `pub aggregate_channels: bool` at `miner-apps/translator/src/lib/config.rs:46` carries no `#[serde(default)]`, unlike its neighbours at `:40`, `:48`, `:53`, `:59`, `:61`, and there is no `impl Default` in the file. Deserialization fails if it is absent, so there is no silent-default hazard. The shipped convention is `true` for the five pool/hosted-pool examples and `false` for the three JDC examples (e.g. `config-examples/mainnet/tproxy-config-local-pool-example.toml:23` vs `tproxy-config-local-jdc-example.toml:23`).

Two corrections to claims that look load-bearing and are not. Devices 2..N are **not** silent upstream in aggregated mode — their `SubmitSharesExtended` frames are rewritten onto the aggregated channel and forwarded (`sv2/channel_manager/mod.rs:567-616`, `:724-740`), as is the aggregated `UpdateChannel` (`:742-785`). And the `.translator-proxy` rewrite at `:504-516` does **not** corrupt a descriptor: `address_part_from_user_identity` splits on the **first** `.` (`stratum-apps/src/payout.rs:438-443`) and a BIP-380 descriptor contains none, so the appended suffix strips cleanly with the checksum intact. Aggregated mode is rejected on the structural ground, not a string-mangling one.

**What NonAggregated costs, stated plainly.**

| Aggregated buys | NonAggregated cost | Verdict |
|---|---|---|
| 1 upstream channel for N devices | N upstream channels | Real, bounded by devices-per-Translator |
| 1 summed-hashrate `UpdateChannel` | N `UpdateChannel`s (`sv2/difficulty_manager.rs:205-212`) | Real; **but per-device vardiff is strictly better** than one min-target for the whole farm |
| 14 bytes of extranonce absorbed as padding | 12 bytes (`sv2/channel_manager/mod.rs:519-536`) | Non-issue: pool grants `CLIENT_SEARCH_SPACE_BYTES = 16` (`pool-apps/pool/src/lib/channel_manager/mod.rs:62`) against a typical `downstream_extranonce2_size = 4` |
| One share sequence-number stream | Per-channel counters (`mod.rs:618-625`) | Non-issue |
| Upstream `CloseChannel` escalates to full fallback (`mining_message_handler.rs:429-440`) | Only the affected channel/group is removed (`:442-455`) | **Better** failure isolation |
| 65,536 concurrent-device cap (`mod.rs:44`) | Pool's `POOL_MAX_CHANNELS = 16_777_216` (`pool-apps/pool/src/lib/channel_manager/mod.rs:57`) | Better |

Nobody has measured upstream bandwidth or CPU at realistic device counts (100+ ASICs per Translator), so the tradeoff is characterized structurally, not quantitatively. Note also that `verify_payout = true` is **incompatible** with per-device descriptors: the Translator's expected payout distribution is a single `Arc<OnceLock<Option<PayoutMode>>>` (`sv2/channel_manager/mod.rs:169`) set once from TOML (`lib/mod.rs:487`) and enforced on every job (`sv2/channel_manager/mining_message_handler.rs:550-557`), so it would reject jobs built for a per-device descriptor. It defaults false (`config.rs:40`) and is false in all eight shipped examples.

### 3.2.1b The current Translator cannot pass identity through

Read against the clone at HEAD `e2930150`, three reasons, each verified:

1. **The channel-open `user_identity` comes from config, not from the miner.** `sv1/sv1_server/mod.rs:975-984`: `let miner_id = self.miner_counter.fetch_add(1, Ordering::SeqCst) + 1; let user_identity = self.user_identity();` — an `Arc<OnceLock<String>>` filled once from `Upstream.user_identity` in TOML (`lib/mod.rs:484-488`) — then `format!("{user_identity}.miner{miner_id}")` unless the value starts with `sri/`. The device's own username is never consulted. That is the string the pool parses `PayoutMode::try_from` against, so **today every V1 rig behind a Translator is paid to the operator's configured identity, in both modes.**
2. **Channel open happens before `mining.authorize`.** `sv1/sv1_server/mod.rs:529-546` opens the upstream channel on the **first** downstream message (`if is_first_message { self.handle_open_channel_request(downstream_id).await?; }`) and pushes that message into `queued_sv1_handshake_messages`, returning before `handle_message` at `:552`. The queue drains only in the `OpenExtendedMiningChannelSuccess` handler (`:781-805`). So at the instant the identity is chosen, both `authorized_worker_name` and `user_identity` are still `String::new()` (`sv1/downstream.rs:114-115`). **This is an ordering change, not a field swap** — see §3.2.2.
3. **A second injection site exists that the previous revision omitted.** `sv2/channel_manager/mod.rs:504-516` rewrites the upstream identity to `<prefix-before-first-dot>.translator-proxy` in aggregated mode, with the same `sri/` exemption and the same issue-#369 comment. A patch touching only `sv1_server/mod.rs:980` still has its identity mangled here whenever aggregated mode is active. It also ends in `user_identity.as_str().try_into().unwrap()` — a bare unwrap into `Str0255`.

### 3.2.1c The length budget, corrected

| Constraint | Value | Binding on the payout path? |
|---|---|---|
| Typical wildcard descriptor | ~150 bytes | — |
| Shortest wildcard form with checksum (`tr(xpub…/*)`) | 126 | No shorter form exists; a raw-compressed-pubkey wildcard is rejected by miniscript outright |
| SV2 `user_identity` (`Str0255`) | **255** | **Yes — this is the binding limit.** `mining_sv2-11.0.0/src/open_channel.rs:131` |
| Translator `tlv_compatible_username` | 32 | **No.** Normative SV2 limit for the 0x0002 TLV only, on a path the pool discards. Do **not** raise it — see below |
| **Avalon firmware** | truncates at **63** | **Yes** under passthrough — too short for any wildcard descriptor |
| **Whatsminer firmware** | overflow past 127 ("may damage your miner") | **Yes** under passthrough — too short, and dangerous |
| Firmware percent-encoding | mangles `()[]/*#` | **Yes** — descriptors are full of these |
| ckpool `username[128]`, splits on `._` | 127 usable | Not on this path |

**The 32-byte cap must be left alone, and the spec's previous prescription to raise it is withdrawn.** Three reasons:

- **32 is not a Translator constant.** It is enforced independently in two external published crates — `extensions_sv2-0.2.0/src/worker_specific_hashrate_tracking.rs:13,:44-47` (sender side) and `parsers_sv2-0.5.0/src/tlv_extensions/mod.rs:20,:57,:69` (both directions) — both citing the sv2-spec's worker-specific-hashrate-tracking extension. `miner-apps/translator/src/lib/utils.rs:273` is a hand-copied mirror.
- **Raising the mirror alone disconnects miners.** In NonAggregated mode — the only mode per-device payout works in — `sv1/sv1_server/mod.rs:648-676` constructs the TLV gated **only** on `self.mode.is_non_aggregated()`, with no negotiation check at the construction site, and maps `UserIdentity::new`'s error to `TproxyError::disconnect` at `:665-671`, which reaches `handle_downstream_disconnect` at `:175-182`. A ~150-byte value in `data.user_identity` becomes an authorize/disconnect loop on the first share. Today's warn-and-truncate is the only thing keeping that connection alive.
- **The cap is not on the payout path.** `tlv_compatible_username` has exactly one call site, `sv1/sv1_server/downstream_message_handler.rs:209`. The channel-open identity is built independently at `sv1_server/mod.rs:975-989` and serialized uncapped. The two values are simultaneously different — the existing integration test asserts channel-open identity `"user_identity.miner1"` (`integration-tests/tests/extensions.rs:121`) while asserting a 9-byte TLV payload `"SRI-miner"`.

The route around already exists in the struct: `authorize()` stores the username **twice** — `data.authorized_worker_name = name.to_string()` untruncated (`downstream_message_handler.rs:207`) and `data.user_identity = tlv_compatible_username(name).to_string()` truncated (`:209`). Source the channel-open identity from `authorized_worker_name`; leave `user_identity` as the 32-byte TLV/monitoring field.

The truncation's fail-closed property is worth keeping, restated with its real basis and its real consequence. **Truncation cannot produce a wrong address** — exhaustive enumeration of all 149 proper prefixes of a 150-byte `wpkh` descriptor through `miniscript` 13.0.0 shows exactly two parse (the whole string and the checksum-stripped whole string) and both derive the identical `scriptPubKey`. The guarantee has two independent legs: an unclosed paren fails `expression::Tree::from_str`, and a cut inside the 8-char checksum fails the length check at `miniscript-13.0.0/src/descriptor/checksum.rs:105-111`. Verified across `wpkh` / `tr` / `pkh` / `sh(wpkh)` / `wsh(multi)` / `wsh(sortedmulti)` / `wsh(and_v)` and deep paths. **But the consequence in current code is not rejection.** A parse failure yields `NoPayoutMode`, which the pool maps to `PayoutMode::FullDonation` (`pool-apps/pool/src/lib/channel_manager/mining_message_handler.rs:145`, `:391`) — 100% of the block to the pool. Fail-closed on the *parse* is guaranteed; fail-closed on the *pool's response* does not exist yet and is a §3.1 requirement, not an existing property. See §3.2.3.

### 3.2.2 The Translator refactor — the ordering fix

**This is a proposed refactor, not existing behaviour.** The code facts it rests on are verified against HEAD `e2930150`; the design is engineering judgment.

The obstacle is precise. The upstream channel opens on the **first** downstream message and every V1 handshake message is queued behind channel establishment:

```rust
// miner-apps/translator/src/lib/sv1/sv1_server/mod.rs:529-546
let is_first_message = downstream.downstream_data
    .super_safe_lock(|d| d.queued_sv1_handshake_messages.is_empty());
if is_first_message {
    self.handle_open_channel_request(downstream_id).await?;
}
debug!("Down: Queuing Sv1 message until channel is established");
downstream.downstream_data.super_safe_lock(|data| {
    data.queued_sv1_handshake_messages.push(downstream_message.clone())
});
return Ok(());
```

The `return` at `:546` precedes `handle_message` at `:552`, so **no V1 message is parsed before the channel opens**. The queue drains only in the `OpenExtendedMiningChannelSuccess` handler (`:781-805`). At the instant the channel-open identity is chosen, both identity fields are still `String::new()` (`sv1/downstream.rs:114-115`). This is why "read the miner's username instead" and "store the raw username in a new field" are both insufficient: **there is no username to read yet.**

**The fix is to make `mining.authorize` — not first-message — the trigger.** Replace the `is_first_message` gate with "open when a queued `mining.authorize` has been parsed", or peek the queued `json_rpc::Message` for its username before opening. `mining.subscribe` normally precedes `authorize`, so the reorder is small and confined. Then source the identity from `data.authorized_worker_name`, which `authorize()` already stores **untruncated** at `downstream_message_handler.rs:207` — no new field is required.

The invariant must be stated as **two** things, not one, or the naive fix breaks every device:

1. The channel-open `user_identity` is the **raw** `authorized_worker_name`, byte-identical to what the device sent.
2. `data.user_identity` **stays ≤ 32 bytes**, because it is the TLV-bound field and `UserIdentity::new` failure is a hard disconnect (`sv1_server/mod.rs:665-671` → `:175-182`).

| # | Anchor | Change | Why |
|---|---|---|---|
| 1 | `sv1/sv1_server/mod.rs:529-534` | Trigger `handle_open_channel_request` on a queued `mining.authorize` rather than on `is_first_message` | The descriptor does not exist before authorize. **Ordering change; the highest-regression-risk item in the spec** |
| 2 | `sv1/sv1_server/mod.rs:975-984` | Source identity from `data.authorized_worker_name` (`downstream_message_handler.rs:207`, untruncated) when it parses as a descriptor; fall back to `self.user_identity()` otherwise | Passthrough without breaking existing single-identity deployments |
| 3 | `sv1/sv1_server/mod.rs:980-984` | Do **not** append `.miner{N}` to a descriptor identity | Same reason the code already exempts `sri/` (issue #369) |
| 4 | `sv1/sv1_server/mod.rs:986-988` | **Delete or keep-truncated** the write-back `d.user_identity = user_identity.clone()` | This is the line that would put a ~150-byte descriptor into the TLV-bound field. Leaving it turns every descriptor device in NonAggregated mode into a disconnect on first share |
| 5 | `sv2/channel_manager/mod.rs:504-516` | Exempt descriptor identities from the `.translator-proxy` rewrite; replace `try_into().unwrap()` with a checked conversion | Second injection site, omitted by the previous revision. The bare unwrap into `Str0255` panics the channel-manager task for a pre-dot prefix over 238 bytes |
| 6 | `config.rs:46` + `lib/mod.rs` startup | Refuse to boot with `aggregate_channels = true` when a descriptor identity is in use | §3.2.1a. Cheap because the field is required with no default |
| 7 | `downstream_message_handler.rs:203-213` | Reject at authorize, with an SV1 error to the miner, any username exceeding `Str0255` | Over-255 handling is broken today: `sv1_server/mod.rs:991-1005` logs `error!` and returns `Ok(())`, so the message is silently dropped and the miner's handshake sits in `queued_sv1_handshake_messages` forever — no disconnect, no SV1 error, and the keepalive loop skips the connection because `sv1_handshake_complete` is never set (`:1308`). Not reachable at ~150 bytes, but reachable from untrusted input once devices supply identity |
| — | `sv1/sv1_server/mod.rs:648-676` | **No change.** Leave the TLV producer and its 32-byte cap exactly as they are | 32 is a normative external constant (`extensions_sv2-0.2.0/src/worker_specific_hashrate_tracking.rs:13`); raising it disconnects miners |

Everything downstream of item 2 already carries the value through unmodified in NonAggregated mode: the pending map is keyed by `request_id` and there is no identity rewrite (`sv2/channel_manager/mod.rs:542-548`), then `upstream_sender.send` at `:554-565`.

**One existing test must be updated, not added to.** `integration-tests/tests/extensions.rs:121` asserts `user_identity == "user_identity.miner1"` on the channel-open while asserting the TLV payload is the device's own `"SRI-miner"` at 9 bytes (`:181-191`). That test is direct evidence the two paths carry different values simultaneously, and it will fail loudly under item 2 — which is correct. Rewrite it to assert the new invariant rather than deleting it.

### 3.2.3 Pool-side prerequisites — larger than the Translator work

Fixing the Translator alone yields N correctly-labelled channels on one connection that all get paid to the last one's descriptor. **The pool aggregates devices too — not by intent but by state layout.**

`Downstream.payout_mode` is a single `SharedLock<Option<PayoutMode>>` per TCP connection (`pool-apps/pool/src/lib/downstream/mod.rs:72`, init `:176`), destructively overwritten on every channel open (`mining_message_handler.rs:171-174` standard, `:412-415` extended; `SharedLock::set` is `*v = value`, `stratum-apps/src/sync.rs:49-52`), never cleared on `CloseChannel` (`:67-90`), and read **once per connection** on every template (`template_distribution_message_handler.rs:56-65`) to build the group-channel job (`:70-78`). Every extended channel then inherits that job verbatim via `on_group_channel_job` (`:158-165`), which only re-stamps the extranonce prefix and never rebuilds the coinbase (`channels_sv2-7.0.0/src/server/extended.rs:516-521`). Standard channels are merged by a second, independent path (`:126-129`).

The failure mode is the dangerous kind: each channel's **first** job at open IS built from that channel's own parsed mode (`mining_message_handler.rs:531-537` extended, `:166` standard), so per-device payout is transiently correct and degrades to last-writer-wins only from the next `NewTemplate`. **A test that mines on the first job after channel open passes while production silently mispays.** Acceptance criteria must verify coinbase outputs after at least one subsequent `NewTemplate`, per device.

Two more pool-side defects on the descriptor path:

- **A valid, untruncated descriptor is paid 100% to the pool today.** `PayoutMode::try_from` (`stratum-apps/src/payout.rs:229-284`) has no descriptor arm: `script_from_address` wraps its input as `addr(<descriptor>)` (`:429-436`), which cannot parse a `wpkh(...)`, and the `/`-split then yields first segment `wpkh([<fingerprint>` rather than `sri`, hitting `_ => Err(NoPayoutMode)` at `:283`. The pool maps that to `FullDonation` (`mining_message_handler.rs:145`, `:391`), which emits one output for the entire value to the pool script (`payout.rs:99-104`), persists per-connection, and re-applies on every template. No error is returned and the arm logs nothing. **This is a wrong-payment bug, not a missing feature**, and it is mode-independent. The descriptor machinery already works — `CoinbaseRewardScript::from_descriptor` accepts wildcards directly at `stratum-apps/src/config_helpers/coinbase_output/mod.rs:45-61` with `has_wildcard()` at `:143` — it is simply never called on `user_identity`.
- **`coinbase_outputs()` maxes at two outputs.** `payout.rs:59-105` is exhaustive over `PayoutMode`: Solo/LegacySolo → one output for the full value, Donate → two, FullDonation → one. There is no variant and no loop over miners. `grep -i pplns` across the repo returns zero hits. So §4's N-output design has **no substrate in this clone** and rests on the [[../wiki/concepts/sv2-share-accounting-ext|share-accounting extension]] articles alone.

The required pool changes, in dependency order. **Items 1–4 are prerequisites for any multi-channel connection to pay correctly — descriptor or not.** This is a proposed refactor, not existing behaviour; the anchors are verified.

| # | Anchor | Change |
|---|---|---|
| 1 | `stratum-apps/src/payout.rs:229-284` | Add a descriptor arm **before** the `/`-split (§3.2.1 precedence). Call `CoinbaseRewardScript::from_descriptor(user_identity)` unwrapped, not via `script_from_address`'s `addr(...)` wrapper |
| 2 | `mining_message_handler.rs:145`, `:391` | Stop mapping `NoPayoutMode → FullDonation` for descriptor-shaped identities. Return `ERROR_CODE_OPEN_MINING_CHANNEL_INVALID_USER_IDENTITY` (already in scope at `:153`, `:399`). `is_client_authorized` (`:45-51`) currently ignores its `_user_identity` and returns `Ok(true)` — the natural validation hook |
| 3 | `downstream/mod.rs:72` | Move payout identity off the connection. No new map is strictly needed: `ExtendedChannel` already stores `user_identity` (`channels_sv2-7.0.0/src/server/extended.rs:93`, `get_user_identity()` at `:259`, already read at `pool-apps/pool/src/lib/monitoring.rs:23`) |
| 4 | `template_distribution_message_handler.rs:56-65`, `:158-165` | Build coinbase outputs **per extended channel** via `on_new_template`, and emit per-channel `NewExtendedMiningJob` (`:98-106`) and per-channel `SetNewPrevHash` (`:240-257`) instead of the group-scoped ones. **This is the real cost: a protocol-surface change, not a field move.** The Translator fans the group job out at `miner-apps/translator/src/lib/sv2/channel_manager/mining_message_handler.rs:619-647`, so both sides give up that bandwidth optimization for descriptor connections |
| 5 | `mining_message_handler.rs:67-90` | Clear payout state on `CloseChannel`. Today a closed channel's identity persists and keeps getting paid |
| 6 | `channel_manager/mod.rs:485`, `:755-771` | Re-send `coinbase_output_constraints` when the output **set size** changes. It is sent once at startup for a single output plus `OFFSET_ADDITIONAL_SIZE = 43` / `OFFSET_MAX_SIGOPS = 4` (`stratum-apps/src/coinbase_output_constraints.rs:18`, `:27`) — sized for a 1→1 script substitution, not for N outputs. This is the concrete mechanism behind §4.5's ceiling at the sv2-apps layer |

Scope note: `requires_custom_work` downstreams are exempt from all of this — `template_distribution_message_handler.rs:52-54` returns early and `mining_message_handler.rs:523` skips coinbase construction. That exemption does **not** cover a Translator, which sends `SetupConnection` flags `0b100` (`miner-apps/translator/src/lib/sv2/upstream/mod.rs:329`, `:560-564`), yielding `has_work_selection == false`.

There is no regression test for any of this. Every case in `integration-tests/tests/pool_solo_mining.rs` uses one identity per connection (`:640`, `:764`), and the two-channel case at `:309`/`:431` uses the same `"cool_miner/worker.1"` for both, so it cannot detect the overwrite.

### 3.2.4 The firmware tradeoff

**Firmware ceilings apply on the passthrough path**, and this is the honest cost of miner-set versus operator-set identity. Under passthrough the descriptor is typed into the rig, so field widths come back: Avalon truncates at 63, Whatsminer overflows past 127, and percent-encoding mangles `()[]/*#`. The shortest wildcard form with a checksum is `tr(xpub…/*)` at **126 bytes** — measured against `miniscript` 13.0.0, the version pinned in `stratum-apps/Cargo.lock` — so **no descriptor form gets under 63**, and the previous revision's hope that dropping the origin prefix "helps" is arithmetically dead.

State the tradeoff to operators rather than letting them discover it: **operator-set (config) identity works on any V1 rig today and pays one descriptor for the whole farm; miner-set (passthrough) identity gives per-device payout separation but requires firmware that can hold a ~150-byte username without truncating or percent-encoding it.** Support both — passthrough when the authorized username parses as a descriptor, configured value otherwise — and the operator picks per deployment. One caveat on the config path: a descriptor in the Translator's TOML `Upstream.user_identity` is hard-failed at startup only when `verify_payout = true` (`config.rs:143-167` → `lib/mod.rs:78-92`), which defaults false and is false in all eight shipped examples. Without change #2 above, the config path with a descriptor donates the whole farm's blocks to the pool.

> **The worker-suffix collision.** The Translator appends `.miner{N}` to the configured identity (`sv1_server/mod.rs:980-984`), and `sv2-apps` parses `user_identity` by splitting on `.` — `address_part_from_user_identity()` does `split_once('.').map(|(address, _)| address)` (`stratum-apps/src/payout.rs:438-443`). The code **already skips** the suffix for `sri/`-prefixed identities (issue #369). **Descriptor identities need the same exemption at both injection sites** — `sv1_server/mod.rs:980` and `sv2/channel_manager/mod.rs:507`. A descriptor's checksum is delimited by `#` not `.`, so a suffix does in fact strip cleanly and the descriptor is recovered byte-for-byte — verified — but relying on that means relying on the `.` split running before descriptor parsing. Take the exemption. **Test it explicitly** (§8.1).

### 3.3 Failure responses

| Condition | SV2 response | Operator signal |
|---|---|---|
| No wildcard | `OpenMiningChannel.Error{ code: "invalid-descriptor-no-wildcard" }` | **WARN** — most likely miner mistake |
| Unparseable | `…Error{ code: "invalid-descriptor" }` | INFO |
| Private key offered | `…Error{ code: "invalid-descriptor" }` — do not echo the string | **ERROR**, redacted |
| Hardened / multipath | `…Error{ code: "invalid-descriptor-unsupported-form" }` | INFO |
| Descriptor un-derivable at height | `…Error{ code: "invalid-descriptor" }` | **ERROR** — should be impossible after §3.1 probes |

Rejection is at **channel open**, before any share is accepted. Never accept work from a miner whose payout cannot be constructed.

## 4. Payout path — height as the derivation index

### 4.1 The decision, and what it deletes

**`index = the height of the block being mined`.** Every paid miner's output in the block at height `H` pays `descriptor.at_derivation_index(H)`.

This is Greg Maxwell's suggestion from SV2 #1652, which upstream deferred for UX reasons — the merged code's own comment reads *"gmax thinks it would be cool if we would instantiate it with the blockheight or something, but need to work out UX."* This spec adopts it.

The reason is not elegance. It is that **the entire rotation-state problem stops existing**:

| Property | Per-payout counter | Height as index |
|---|---|---|
| Pool-side index state | One counter per miner, durable | **None** |
| Persist-before-return ordering | **Load-bearing correctness requirement** | Not applicable |
| Corrupt store → replay from index 0 | A real, silent failure mode | **Cannot occur** |
| Stale backup restore → address reuse | The most dangerous operation in the system | **Cannot occur** |
| Rotation trigger (SV2 #697) | The hard unresolved question | **Not a question** — no rotation event exists |
| Derivation per template refresh | Burns an index unless cached | **Idempotent** — same height, same address |
| Recovery if the pool disappears | Depends on pool-published state | **Independent of the pool** |

Two of those deserve emphasis because they are the ones that actually change the risk profile:

**SV2 #697 dissolves rather than gets answered.** The issue states: *"The tricky part here is to decide when to rotate. Doing it for every `SetNewPrevHash` would generate too many addresses, which is difficult for wallet software to keep track of."* Under height indexing there is no rotation event to schedule — the address is a pure function of `(descriptor, height)`. Rotating on `SetNewPrevHash` is exactly correct and costs nothing, because a new `prevhash` means a new height, and every template at the *same* height derives the *same* address.

**Idempotence is what makes this portable.** A pool rebuilds its coinbase on every template refresh, potentially every few seconds. A counter burns an index each time unless you add a cache; height indexing returns the identical script every time by construction. That means scripts can be resolved at **work-issue** time for free — so this design ports to TIDES and ckpool, which precompute the coinbase before miners start hashing, without the per-template derivation storm that [[../wiki/concepts/lottery-pplns|lottery-PPLNS]] hazard #5 warns about. PPLNS-JD remains the best host for the *ledger* reason (zero identity fields, §0), but no longer for a cadence reason.

Orphans are also clean: an orphaned block at height `H` and its replacement at `H` derive the same address. Since the orphan never existed on chain, there is no reuse — and unlike the counter design, no index is burned.

### 4.2 The cost you are accepting: no bare-seed recovery

This is the one real downside and it should not be soft-pedalled.

| Wallet / spec | Gap limit |
|---|---|
| BIP-44 stated standard | **20** |
| Sparrow default | **20** (40 postmix), configurable under Settings → Advanced |
| BDK `DEFAULT_LOOKAHEAD` | **25** |

A wallet restored from seed alone scans indices 0–19, finds nothing, and reports an **empty wallet**. Not "some payments missing" — nothing at all, because the first payment is at ~900,000. Under a counter, indices are 0, 1, 2, … and every consumer wallet works with zero configuration.

**The accepted tradeoff** (operator decision, 2026-07-29): the pool's found blocks are public and easily sourceable, so a miner can scan those specific heights rather than a contiguous range. Height indexing does not eliminate recovery state — it **relocates** it from the pool to a small public list. What makes that a good trade is that the list is *derivable from the chain by anyone, forever*, whereas a per-miner counter lives only in the pool's database. **Recovery survives the pool's death**, which no counter design achieves.

The obligation this creates is documentation, not machinery: §6 must give miners exact commands, because "raise your gap limit" is not a workable instruction when the required lookahead is ~900,000.

### 4.2.1 Rejected alternatives

| Alternative | Why not |
|---|---|
| **Per-payout counter** | Requires the whole durable-index apparatus: persist-before-return, atomic writes, fatal-on-corrupt startup, restore-forward-only backups. All of it is correctness-critical and all of it is a way to silently reintroduce address reuse. Consumer-wallet compatibility is its only advantage, and §4.2 trades that away deliberately. |
| **Per template refresh** | ~2,880 indices/day/miner at a 30 s cadence, nearly all never paid. Buys no privacy — the Romiti attack turns on addresses *actually paid*. |
| **Pool's block ordinal** (1st, 2nd, 3rd block found) | Genuinely tempting: small consecutive indices *and* idempotence. Rejected because it reintroduces pool-side state — the ordinal counter must be persisted and stays correct only if never restored stale, which is the failure class this revision exists to delete. Height is already public; an ordinal is pool-attested. |
| **Timestamp or `ntime`** | Not idempotent within a height, and miner-influenced within consensus bounds. |

### 4.3 Resolution algorithm

```
on build_coinbase(height H, share_ledger):
    payouts = pplns_distribution(share_ledger)      # unchanged; keyed by payout_id
    payouts = merge_by_payout_id(payouts)           # §4.3.1 — MUST be exactly one row per miner
    assert distinct(p.payout_id for p in payouts)

    outputs = []
    for (payout_id, amount) in payouts:
        if amount < DUST_THRESHOLD(script_type):    # §4.4 — drop, do not accrue
            continue
        script = payout_script(descriptor_for(payout_id), H)   # pure; no state (§5)
        outputs.push((script, amount))

    coinbase = assemble(outputs)
    # Audit only — NOT correctness-critical, unlike the counter design (§2.1)
    try: record_payout_receipts(H, payouts)
    except: warn()                                  # pay anyway (§5.2)
```

Two ordering notes, both different from the counter design:

- **Dust filtering no longer needs to precede derivation** for correctness — skipping a miner costs nothing now, since no index is consumed. It still precedes it for clarity and to avoid deriving scripts that are discarded.
- **Receipt-writing is no longer inside the payout's critical path.** In the counter design the audit row had to commit atomically with the index advance. Here a failed receipt write is a warning, not an abort.

### 4.3.1 Exactly one output per miner per block — a structural requirement

Because index is a pure function of height, **a miner has exactly one derivable address in block `H`.** Any payout list containing two rows for the same `payout_id` cannot be expressed: either you merge them into one output, or you emit two outputs paying the *same* address — which is on-chain address reuse inside a single transaction, the loudest possible version of the failure this design exists to prevent.

With the finder bonus out of scope this is satisfied for free: PPLNS distribution produces one weight per miner. The requirement is written down anyway because it is the constraint a future finder bonus would silently violate. [[../wiki/concepts/lottery-pplns|Lottery-PPLNS]] hazard #1 already documents the duplicate-address merge bug in Blitzpool's PPLNS ledger apply; under height indexing that same bug stops being an accounting slip and becomes a privacy regression.

So: `merge_by_payout_id()` is **mandatory**, the `PRIMARY KEY (block_height, payout_id)` is its backstop, and if a finder bonus is ever added, the finder's bonus and proportional share **must be summed into a single output** before assembly. A counter design would have left the option of paying two distinct addresses; this one does not.

**And one assert that the `payout_id` check cannot substitute for.** After derivation, assert `distinct(o.script_pubkey for o in outputs)`. Two *different* `payout_id`s can derive the *same* script when they are origin-only variants of one xpub (§2.2) — `wpkh([fp/84h/0h/0h]xpub…/0/*)` and `wpkh(xpub…/0/*)` produce byte-identical `scriptPubKey`s at every height. The merge-by-`payout_id` step passes, the primary key passes, and the block still pays one address twice. §2.2's origin-stripping normalization is the fix; this assert is the backstop for a normalization bug, and it must run on **scripts after derivation**, not on identities before it.

**The requirement is per `payout_id`, and deliberately not per operator.** The pool has no basis for asserting that two descriptors belong to the same person and no business inferring it — a distinct `payout_id` is a distinct user (§2.5), full stop. Merging by anything coarser than `payout_id` would require exactly the identity-linking this design refuses to perform.

### 4.4 Dust and the accrual trap

Sub-dust amounts are **dropped, not accrued.** This is a deliberate and costly choice, and it is the regulatory hinge of the whole design.

FinCEN FIN-2019-G001 §5.4 exempts pool distributions as "integral to the provision of services" — *unless* the operator combines them with "hosting CVC wallets," which is "account-based money transmission." **Accrual to a minimum threshold is a hosted balance**, which is exactly the trigger. Compounding it, §4.5.1(a) makes an "anonymizing services provider" a money transmitter **expressly ineligible** for the integral exemption. Custody and address-rotation are individually survivable and **jointly fatal**.

So a pool doing per-payout rotation has a much stronger reason than usual to stay coinbase-direct. The cost is real and lands on the smallest miners — Ocean's own TIDES docs concede that satoshi-precision rewards produce uneconomic dust and that sub-1-satoshi earnings at block-found "are lost." Document the effective minimum plainly rather than hiding it behind an accrual buffer.

One interaction specific to height indexing: a dropped dust payout leaves **no trace in the miner's address history**, since no address is consumed for a miner who isn't paid. Under a counter, a skipped miner and a paid miner are distinguishable by index movement. Here the miner's only signal is the receipt endpoint (§6), which is another reason to publish it even though it is not recovery-critical.

### 4.5 Output-count ceiling is firmware, not consensus

Any per-miner-output scheme is bounded by what ASIC firmware accepts as a coinbase: roughly **380–530 outputs** (DATUM's table caps at "huge — max 16 kB"; per-vendor, nicehash ≈500 B, antminer ≈730 B, antminer2 2250 B, whatsminer 6500 B). This is not changed by rotation — rotation alters *which* script each output pays, not how many there are — but it caps the miner count per block regardless, and Braidpool's retrospective is the empirical warning: p2pool's large coinbase of small outputs "competed for block space with fee-paying transactions." Braidpool's own coinbase has **two** outputs.

If the paid-miner count approaches the ceiling, the levers are a higher dust floor, paying the top N by weight, or covenant-based fanout ([[../wiki/concepts/ctv-coinbase-payout-tree|CTV Coinbase Payout Tree]], blocked on BIP-119).

**The concrete mechanism at the sv2-apps layer is `coinbase_output_constraints`, and it is sized wrong for N outputs.** It is sent to the Template Provider **once at startup**, budgeted as one configured output plus `OFFSET_ADDITIONAL_SIZE = 43` and `OFFSET_MAX_SIGOPS = 4` (`stratum-apps/src/coinbase_output_constraints.rs:18`, `:27`) — i.e. sized for a 1→1 script *substitution*, not for a growing output set. It must be recomputed and re-sent whenever the output **set size** changes (§3.2.3 item 6). The arithmetic suggests this binds much earlier than 380–530: a p2wpkh-configured pool gets 31 + 43 = 74 bytes of budget, while even two p2tr outputs need 2 × 43 = 86. The Template Provider's enforcement path was not traced, so treat that as arithmetic rather than a measurement — but if it does reject, item 6 is a blocker and not an optimization.

## 5. Derivation — stateless by construction

This section replaces what was, in the counter design, the largest and most dangerous part of the spec. It is now short, and that is the point.

```rust
/// Derive a miner's payout script for the block being mined.
/// Pure function of (descriptor, height). No state, no I/O, no failure
/// mode other than a descriptor that should never have been accepted.
fn payout_script(desc: &Descriptor<DescriptorPublicKey>, height: u32)
    -> Result<ScriptBuf, DeriveError>
{
    Ok(desc.at_derivation_index(height)?.script_pubkey())
}
```

**What is deliberately absent**, each item having been a correctness requirement in the counter design:

- No `next_index`, no `fetch_add`, no atomic counter.
- No persist-before-return ordering constraint.
- No transactional store, no `Durability::Immediate`, no write-temp-then-rename.
- No fatal-on-corrupt-startup path, because there is no index file to corrupt.
- No "abort the payout if the write fails," because there is no write.

### 5.1 What the counter design got wrong, kept as a warning

Recorded because the primitive this spec builds on ([sv2-apps' `XpubDerivator`](../raw/repos/2026-07-29-sv2-apps-xpub-coinbase-rotation-code-read.md)) is counter-based, so anyone implementing this will read that code first and may carry its shape over:

```rust
// ANTI-PATTERN — not applicable under height indexing; do not reintroduce
let new_index = self.current_index.fetch_add(1, Ordering::SeqCst) + 1;
let script = self.derive_at_index(new_index)?;
if let Err(e) = self.persist_index() {
    tracing::warn!("Failed to persist coinbase rotation index to {:?}: {}", self.index_file, e);
}
```

Its three reachable failures were: a bare `fs::write` with no fsync, so a crash mid-write truncates the file; `load_index` doing `contents.trim().parse().unwrap_or(default)`, so a corrupt file **silently replays derivation from index 0** — reaching address reuse, the exact thing the feature exists to prevent, by the quietest available path; and a restart reusing the current address because the in-memory index can be one ahead of disk. `parasitepool/para` avoids all three by persisting before returning, and its design doc names the rejected alternative — *"B. Push then persist — risk: ckpool advertises an address whose derivation index isn't yet on disk; restart loses it"* — which is precisely what sv2-apps implements.

**Height indexing makes all of it unreachable.** The lesson to retain is the general one: a rotation feature that silently stops rotating has failed while continuing to report success. Under height indexing the equivalent silent failure is a non-wildcard descriptor (§3.1), which is why that check is the load-bearing one.

### 5.2 Failure posture

| Failure | Response |
|---|---|
| Descriptor un-derivable at height `H` | Should be impossible after §3.1's probes. Skip that miner, **retain their ledger credit**, alert CRITICAL. Do not substitute another address. |
| `payout_receipt` write fails | **Pay anyway.** This table is an audit convenience, not a correctness dependency — the receipt is reconstructible from the chain. Alert WARN. This inverts the counter design, where a failed write meant aborting the payout. |
| Two payout rows for one `(height, payout_id)` | Primary-key violation. Merge before insert; if it fires, the payout list has a duplicate (§4.3.1) — halt and fix rather than emitting two outputs to one address. |
| Node reports a different height than the template | **Halt.** Deriving at the wrong height pays an address the miner will not scan. Assert template height == the height the coinbase is built for. |
| Two channels on one connection carry **different** payout identities and the pool is still binding identity per connection | **Halt, and alert CRITICAL.** This is §3.2.3's collapse: the second open silently re-points the first channel's payouts from the next `NewTemplate` onward. It affects `sri/solo/<addr>` identities too, so alert regardless of whether descriptors are in use. Until §3.2.3 items 3–5 land, this condition is *reachable in normal operation* behind any Translator. |
| Two derived scripts in one payout list are identical | **Halt** (§4.3.1). Distinct `payout_id`s deriving one script means a §2.2 normalization bug, most likely origin-info variants of one xpub. |

The height row is specific to this design: height is now correctness-critical *input* rather than internal state, so it must be validated where it enters. The two-channel row is not specific to it — it is a pre-existing pool defect this design surfaces (§3.2.3).

## 6. Recovery — the miner's procedure

Recovery does not depend on the pool. It depends on the pool's **found-block heights**, which are on the public chain permanently and can be recovered by anyone from the coinbase tag, block explorer, or the pool's published list — even if the pool no longer exists. That property is the main thing height indexing buys over a counter.

**What the pool must publish** (unauthenticated, since it is public information anyway):

1. **The list of block heights it has found**, as a plain endpoint and in its docs. One shared list for all miners, verifiable against the chain. This replaces the counter design's per-miner `highest_paid` state.
2. **Per-miner payout receipts** — `(block_height, script_pubkey, amount_sats)` per `payout_id` — as convenience, explicitly *not* as the recovery path of record.

**The miner's procedure, with the actual commands.** "Raise your gap limit" is not workable at ~900,000, so the docs must be concrete:

```bash
# Derive the script for one specific block the pool found:
bitcoin-cli deriveaddresses "wpkh([d34db33f/84h/0h/0h]xpub…/0/*)#hkuz7pyx" '[901234,901234]'

# Import a bounded range covering the pool's active period, then rescan:
bitcoin-cli importdescriptors '[{
  "desc": "wpkh([d34db33f/84h/0h/0h]xpub…/0/*)#hkuz7pyx",
  "range": [900000, 902000],
  "timestamp": 1719800000,
  "internal": false,
  "label": "pool-payouts"
}]'
```

Bitcoin Core handles explicit index ranges natively — `range` is an absolute index window, not a gap-limit offset, so this works without reconfiguring anything. A ~2,000-index window covering the pool's operating period is cheap; it does not require knowing which specific heights were found.

**Tooling that does *not* work, and should be named in the docs so miners don't try:** Sparrow's gap limit is a *depth* past the last used index, not an offset, so it cannot reach ~900,000 by configuration. Most seed-only mobile wallets likewise. **A bare seed restore finds nothing.** This is the accepted §4.2 tradeoff and it must be stated in miner-facing docs at signup, not discovered after a payout.

Since the design is SV2-native and miners are already running a Translator or SV2 firmware, requiring Core-grade tooling for recovery is consistent with the audience — but it is a requirement, and it should be written as one.

**Two notes on gaps.** Gaps are the normal case here, not an anomaly: a miner is paid only at heights the pool found, so their used indices are inherently sparse. And the open question the counter design could not answer — a principled gap-limit default — **dissolves** rather than gets answered, because there is no contiguous scan to size.

## 7. Performance

### 7.1 Idempotence removes the cadence problem entirely

Derivation is a pure function of `(descriptor, height)`, so every template refresh at the same height derives the same script. Cadence therefore stops being a design constraint:

| Scheme | Counter design | This design |
|---|---|---|
| **PPLNS-JD** | ~500 derivations per block found | Same, and safely cacheable per height |
| TIDES (work-issue-time coinbase) | ~500 × every 30 s, and each burns an index | ~500 × every 30 s, **burning nothing** — or cache one script per `(payout_id, height)` and pay ~500 total |
| ckpool (`generate_userwbs()` per workbase) | Same continuous cadence, same burn | Same, no burn |

That is why §4.1 claims portability: the per-template derivation storm that [[../wiki/concepts/lottery-pplns|lottery-PPLNS]] hazard #5 warns about becomes a pure-CPU concern with a trivial cache, rather than a correctness problem that consumes indices.

**The one real CPU trap, still live.** sv2-apps' `XpubDerivator` stores the descriptor as a `String` and **re-parses it on every derivation**, because miniscript's `Descriptor<DescriptorPublicKey>` holds an internal `RefCell` taproot cache and so is not `Send + Sync`. At once-per-block that is free. At per-template × per-miner it is a parse storm. If porting to a work-issue-time scheme, hold pre-parsed `Descriptor` objects behind per-identity locks, and key a script cache on `(payout_id, height)` — which is sound *only* because derivation is idempotent.

### 7.2 Budget

| Operation | Frequency | Target |
|---|---|---|
| Descriptor validation + 3 probes (§3.1) | Per channel open | < 5 ms |
| `payout_script()` — pure derivation, no I/O | Per paid miner per block | < 1 ms |
| Full payout resolution, 500 miners | Per block found | < 500 ms |

No durability commit appears in this table. That absence is the performance story.

**Caveat on the 500-miner row: nothing in the read clone exercises anything near it.** `PayoutMode::coinbase_outputs` (`stratum-apps/src/payout.rs:59-105`) is exhaustive over the enum and maxes at **two** outputs (Donate); Solo/LegacySolo pay the whole block value to one output; there is no loop over miners, and `grep -i pplns` across the repo returns zero hits. This budget is a design target for the PPLNS host described in §0, not a measurement against existing code. See §12.

## 8. Testing strategy

Rotation's failure modes are silent, which makes the negative tests more valuable than the positive ones. sv2-apps ships 12 unit tests including pinned derivation vectors and a restart test, but **no integration or regtest coverage** — the gap this section closes.

Height indexing **deletes three of the counter design's most important tests** (restart mid-rotation, corrupt-store-refuses-to-start, write-failure-aborts-payout) because the failures they guard against are now unreachable. That is the clearest measure of what this revision bought. What replaces them is smaller and mostly about the two grammars sharing a delimiter.

### 8.1 Unit

- **Pinned derivation vectors.** Fixed tpub → expected `scriptPubKey` hex at heights in the range actually used: 900,000, 900,001, 1,000,000, and `2^31−1`. **Not index 0** — it is never used and testing it proves nothing about the operating range.
- **Idempotence.** `payout_script(d, H)` called 1,000 times returns the identical script. This is the property the whole design rests on and it is one assertion.
- **Every rejection in §2.3**, asserting on error *kind*, not message text.
- **The `user_identity` grammar collision (§3.2.1)** — the highest-value new test:
  - `sri/solo/bc1q…` is parsed as a payout mode, **never** as a descriptor identity.
  - `wpkh([d34db33f/84h/0h/0h]xpub…/0/*)#hkuz7pyx` is parsed as a descriptor identity, **never** split on `/` into `sri`-grammar tokens.
  - A descriptor identity is **exempted** from the Translator's `.miner{N}` suffix, exactly as `sri/`-prefixed identities already are (issue #369). Belt-and-braces: if a suffix *is* appended, it strips to the exact original descriptor with checksum intact.
  - A **truncated** descriptor is rejected rather than parsed — the dangerous case is a truncation that still parses. Include the 32-byte cut specifically (`tlv_compatible_username`'s current limit), asserting it loses the closing paren and `#checksum` and therefore fails the grammar.
- **A valid, untruncated descriptor is never silently donated** — the single highest-value new unit test in the spec. Assert `PayoutMode::try_from` on a full ~150-byte `wpkh([…]xpub…/0/*)#cksum` does **not** resolve to `FullDonation`, and that before the descriptor arm lands (§3.2.3 items 1–2) the pool returns `ERROR_CODE_OPEN_MINING_CHANNEL_INVALID_USER_IDENTITY` rather than opening the channel. Cover `tr` / `pkh` / `sh(wpkh)`, with and without `#checksum`, with and without key origin. This is a wrong-payment bug today, not a missing feature.
- **The two identity fields carry different values, deliberately.** Assert the channel-open `user_identity` is byte-for-byte `authorized_worker_name` (`downstream_message_handler.rs:207`, untruncated) **and** that `data.user_identity` stays ≤ 32 bytes (`:209`), and that no value over 32 bytes ever reaches `UserIdentity::new`. This is the rewrite of `integration-tests/tests/extensions.rs:121`, which currently asserts `"user_identity.miner1"` and will fail under §3.2.2 item 2 — correctly.
- **`payout_id` normalization**: textual variants of one descriptor collide; genuinely different descriptors do not. **Include origin-info variants specifically** — `wpkh([fp/84h/0h/0h]xpub…/0/*)` and `wpkh(xpub…/0/*)` over one xpub must yield **one** `payout_id` (§2.2), because they derive identical scripts and no downstream check catches them.
- **`merge_by_payout_id()`** collapses two rows for one miner into one summed output (§4.3.1), even though no in-scope scheme produces them.

### 8.2 Integration / regtest — the tests that matter

1. **Address equals height, end to end.** Mine a block at known height `H`; assert every payout output equals `deriveaddresses(desc, [H,H])` computed independently by `bitcoin-cli`, not by the pool's own code. Catches off-by-one between template height and coinbase height.
2. **Wrong-height guard.** Fault-inject a template/coinbase height mismatch; assert the pool **halts** rather than paying at the wrong index (§5.2, last row).
3. **Orphan reconvergence.** Mine a competing chain so height `H` is re-mined; assert the replacement block pays the **same** address, and that no index is consumed or skipped. This is the test that demonstrates the orphan-cleanliness claim in §4.1.
4. **No-wildcard descriptor is rejected at channel open** — plus the negative: assert it never reaches the payout path.
5. **Full-cycle recovery via `importdescriptors`.** Mine N blocks paying one descriptor across scattered heights, then from a fresh Core wallet run the exact §6 commands and assert every payment is found. Then assert a **bare seed restore with default gap limit finds nothing** — pinning the §4.2 tradeoff as an executable test rather than a caveat, so nobody later "fixes" it by accident.
6. **V1 passthrough through the Translator.** A V1 miner (cgminer or a simulator) sends `mining.authorize` with a **~150-byte descriptor as its username**; assert the descriptor reaches the pool's `OpenExtendedMiningChannel` **byte-for-byte**, that the pool derives correctly, and that no `.miner{N}` suffix was appended (§3.2.2). Three sub-assertions: the channel open is deferred until after authorize; the miner's username wins over the configured one; and the **two-field invariant** holds — channel-open identity is the raw `authorized_worker_name` *while* `data.user_identity` stays ≤ 32 bytes. (The previous revision asserted "nothing truncates at 32 bytes," which tests the wrong invariant and would drive the implementation into the `UserIdentity::new` disconnect at `sv1_server/mod.rs:665-671`.)
7. **Per-device payout survives a subsequent `NewTemplate` — the test that catches the real bug.** Two V1 devices, two descriptors, one Translator in **NonAggregated** mode → two `payout_id`s and two coinbase outputs, asserted **after at least one `NewTemplate` following both channel opens**, not on the opening job. Each channel's *first* job is already built from its own parsed mode (`mining_message_handler.rs:531-537`), so a test that mines on the first job **passes today while production silently mispays** (§3.2.3). Requires both the Translator changes (§3.2.2) and the pool-side per-channel binding (§3.2.3 items 3–4).
8. **A descriptor-username device submits shares without being disconnected (NonAggregated).** With the worker-hashrate extension negotiated and a ~150-byte descriptor as the device username, assert the device submits shares normally and is **not dropped**. Guards the `UserIdentity::new` → `TproxyError::disconnect` tripwire (`sv1_server/mod.rs:665-671` → `:175-182`) that the naive "just delete the truncation" fix arms. This replaces the previous revision's test #8, whose premise (raise the cap, expect rejection) was wrong twice over — see §13.
8a. **Aggregated mode is refused, not degraded.** Start the Translator with `aggregate_channels = true` and a descriptor identity in play; assert it **fails to start** with a specific error rather than opening one upstream channel (§3.2.1a). Then the negative, pinning the structural fact: with the guard removed, assert exactly **one** `OpenExtendedMiningChannel` reaches the pool for N attached devices, so nobody later "optimizes" descriptor deployments back into aggregated mode.
8b. **A closed channel stops being paid.** Open channels A and B with different descriptors on one connection, `CloseChannel` B, drive a `NewTemplate`, assert A is paid at A's descriptor. `handle_close_channel` (`mining_message_handler.rs:67-90`) never clears `payout_mode` today, so B's identity persists after disconnect (§3.2.3 item 5).
8c. **In-band re-key does not hijack siblings.** With A and B open on one connection, open a third channel C with a different descriptor and drive a `NewTemplate`; assert A and B are still paid at their **own** descriptors. This needs no reconnect to trigger and is the §5.2 halt condition.
8d. **Over-`Str0255` identity is rejected at authorize with an SV1 error.** Feed a 300-byte username; assert the device receives an SV1 error and is **not** left with a permanently queued handshake — today `build_sv2_open_extended_mining_channel` failure logs `error!` and returns `Ok(())` (`sv1_server/mod.rs:991-1005`), hanging the miner forever with `sv1_handshake_complete` never set. Also assert no panic in the channel manager for a pre-dot prefix of 239–248 bytes in aggregated mode (`sv2/channel_manager/mod.rs:515-516`, bare `unwrap`).
8e. **`verify_payout = true` is refused with per-device descriptors.** Assert the Translator rejects the combination at startup: its expected payout distribution is a single `Arc<OnceLock<Option<PayoutMode>>>` (`sv2/channel_manager/mod.rs:169`) enforced on every job (`sv2/channel_manager/mining_message_handler.rs:550-557`), so it would reject jobs built for any descriptor other than the configured one (§3.2.1a).
8f. **`coinbase_output_constraints` is re-sent when the output set grows.** Move from 1 to N payout outputs and assert the Template Provider is re-informed (§4.5, §3.2.3 item 6). Untested today, and the arithmetic suggests even a 2-output Donate coinbase can exceed the startup budget.
9. **Config fallback still works.** A V1 miner whose username is *not* a descriptor (e.g. `worker1`) falls back to the Translator's configured `user_identity` with the existing `.miner{N}` behaviour. Guards the "additive, never a cutover" requirement in §10.1 at the Translator layer.
10. **500-output coinbase** accepted by the node and within the firmware byte budget of §4.5.
11. **Window is share-difficulty, not wall-clock or block count (§2.5).** Drive a regtest pool at a hashrate low enough that accumulating `8 × D` of share difficulty spans **many** blocks; assert the window boundary lands where accumulated difficulty crosses the threshold, and that a share older than 8 blocks but still inside the window **is paid**. This is the executable form of the unit correction: a "prune after 8 blocks" or "prune after 80 minutes" implementation fails here.
12. **Upward difficulty retarget grows the window backwards.** Fill the ledger at difficulty `D`, retarget upward, then find a block. Assert the window now reaches shares that were outside it at the old `D`, that those shares are paid, and that they resolve their `miner_identity` descriptor. Then assert the retention floor holds: nothing prunable at the new `D` was pruned at the old one. This pins the §2.5 requirement that retention must exceed the current window — the bug it guards against only appears after a retarget.

### 8.3 Property tests

- **Determinism across process lifetimes**: for arbitrary `(descriptor, height)`, the derived script is identical across restarts, threads, and fresh processes with no shared state. The counter design needed a crash-interleaving property test here; this needs a purity assertion.
- **No address collision across miners**: for distinct descriptors and any height, derived scripts differ. (Guards against a `payout_id` normalization bug collapsing two miners into one identity.) **Extend to origin-info variants**: generate `wpkh([fp/84h/0h/0h]xpub…/0/*)` and `wpkh(xpub…/0/*)` over one xpub, assert `at_derivation_index(H).script_pubkey()` is **identical** while §2.2's normalization yields **one** `payout_id` — and that if normalization is broken so the ids differ, §4.3's post-derivation script-distinctness assert fires. The `PRIMARY KEY (block_height, payout_id)` backstop **passes** this case, so it cannot catch it.
- **Truncation prefix enumeration**: for generated descriptors across `wpkh` / `tr` / `pkh` / `sh(wpkh)` / `wsh(multi)` / `wsh(sortedmulti)`, assert no proper prefix parses as a wildcard descriptor deriving a *different* `scriptPubKey`, and no proper prefix parses as a non-wildcard descriptor. Exhaustive enumeration over one xpub pair confirmed only the whole string and its checksum-stripped form parse; a property test closes the residual "a prefix that happens to be checksum-valid" gap that measurement alone cannot rule out.
- **Exactly one output per `payout_id`** in every generated payout distribution (§4.3.1).
- **Sum of coinbase outputs equals subsidy + fees**, for every generated payout distribution.

## 9. What this design does and does not buy

Stating this precisely, because the honest scope is narrower than "private payouts" and an unqualified claim here would be false.

### 9.1 It defeats the attack that demonstrably works

Romiti et al. (WEIS 2019) identified **92 % of BTC.com miners, 75 % of ViaBTC, and 30 % of AntPool** from public chain data with **no pool cooperation**. The driver was payout-address reuse — median 20 reuses at BTC.com, 5 at ViaBTC, 2 at AntPool — and the inverse correlation between reuse and identification rate is the entire empirical case for rotation. Height indexing removes that lever completely: reuse is not merely avoided by policy, it is **unrepresentable**, since no height recurs and a miner has exactly one address per block (§4.3.1).

### 9.2 It is a pool-side privacy no-op

**The pool learns nothing less than before.** A pool's attribution knowledge comes from **share validation, not from payment**: by the time any satoshi moves, the pool has already recomputed every share header, assigned every target, timestamped every arrival, and can infer hashrate to within a few percent. Worse, the pool now holds a descriptor that links **all** of a miner's rotated addresses together — a linkage that did not previously exist in one place.

> An xpub username is an **on-chain privacy upgrade and a pool-side privacy no-op.**

Do not market this as blinding. Blinding the pool is a separate and much harder problem — see [[../wiki/topics/self-blinding-pool-design-space|Self-Blinding Pool Design Space]]. *(Corrected 2026-07-29: this section previously said the problem was "bounded by an impossibility result (Canard–Gouget…)". That attribution was wrong — see [[../raw/papers/2026-07-29-stateful-vs-oneshot-credentials-no-separation|the correcting read]]. The difficulty is real but quantitative: range-proof width, per-share round-trips, and the hashrate side channel. Nothing in this plan depends on the distinction.)*

### 9.3 The amount channel stays open

Rotation hides *who*, not the *distribution shape*. For payout outputs `{a₁…a_N}`, the ratio `aᵢ / Σaⱼ` is miner *i*'s **exact** relative share weight, requiring no knowledge of pool difficulty or window length — the sum normalizes them away. And `N` bounds the anonymity set; AntPool's fixed 101-output structure was the very *filter* Romiti et al. used to find payout transactions.

A coinbase is a **strictly easier** subset-sum instance than a CoinJoin: one input of publicly known value (no input-side ambiguity), no input shuffling available (`vin.size() == 1` by consensus), and **no padding possible** (the total is consensus-bounded by subsidy + fees, so every decoy satoshi must come out of a real miner). One mitigating property of this design: paying `share_fraction × reward` produces high-entropy non-round amounts, and round numbers are what accelerated CoinJoin Sudoku's break of SharedCoin.

### 9.4 It removes the only withholding detection that has ever worked

**Eligius 2014** caught its block-withholding attacker only because they "used **two payout addresses**," letting the operator cluster individually insignificant signals into one significant one. Per-payout rotation removes exactly that lever. This is a **genuine cost of rotation** — distinct from attribution generally.

It is a small cost under PPLNS-JD specifically, because attribution-based withholding detection already fails under full identity: Eyal 2015 notes a pool "might not be able to detect which of its **registered** miners are the perpetrators," since a catching threshold "would reject the majority of its honest miners," and Sybil churn defeats registration anyway. Under PPLNS, withholding costs the attacker their own revenue — **incentive alignment does the work attribution can't**. The cost would be materially higher on PPS/FPPS.

### 9.5 Share-credit theft — resolved in this design's favour, and there is no better option

Bedrock's mining cookie `C_M = H²(R_M, M.uname)` defeats BiteCoin connection-hijacking **precisely because the username is an input to the PoW** — an attacker substituting their own username produces a hash that no longer meets target.

**This spec is unaffected, and that is now a result rather than an assumption.** The 2026-07-29 thesis round ([[report-blinded-share-credit-thesis-2026-07-29|report]], verdict **MIXED**) closed the question that the first draft carried as open, and the inventory record `candidates/blinded-mining-cookie-security.md` is `resolved: 2026-07-29`. Three findings from it bear on this design:

- **The property depends on the value being unforgeable and miner-bound, not on it being a human-readable name.** A descriptor in `user_identity` is a stable plaintext string, exactly as `M.uname` was. Substituting one for the other changes nothing in the cookie construction.
- **Bedrock is a weaker baseline than this wiki previously credited it with.** It names no hardness assumption; §7.1 is a work-equivalence argument. Its cookie rotates only on block-find — **~7.44 years for an S7**, which the paper computes itself — so it never delivered a per-session unlinkable value. And placing the cookie in the prevout hash is consensus-invalid for the share that *is* a block. There is less here to preserve than the first draft assumed.
- **The obstacle the thesis found is one this design never incurs.** Bedrock keys the vardiff target on identity — `store(M.uname, K_M, R_M, target)`, fetched via `getMParams(M.uname)` — so a pool cannot even evaluate `H²(nonce||F) < target` for an anonymous submitter. Blinding breaks share *validation*, one layer before crediting. **This spec keeps a stable plaintext identity**, so identity-keyed vardiff, dedup, and crediting all work untouched.

**The thesis is why this plan is the right shape.** What survives its MIXED verdict is not a cryptographic barrier but an architectural one: blinded credit is strictly harder than blinded payout **because crediting is an online interactive protocol while payout is an offline non-interactive derivation** — and BBW's construction cannot be made non-interactive, since its p.166 argument relies on rewinding. Plus a hashrate side channel that batching converts (`interval = b / share_rate`) rather than removes, and which no paper has quantified.

So the tractable half of the problem is exactly the half this spec does. **Payout blinding is an offline BIP-32 derivation and needs no protocol at all** — which is what §5 is. Share-credit blinding needs an online two-party protocol per credit, an unquantified timing leak, and a repair to Bedrock's identity-keyed vardiff that nobody has written. This design takes the offline half and leaves the pool's own knowledge untouched, which §9.2 states plainly rather than dressing up. That is not a gap in the plan; it is the plan.

## 10. Deployment

### 10.1 Migration path

The pool almost certainly already has miners authenticating with literal addresses. Descriptor identity must be **additive, never a cutover** — an existing miner's payout path must not change because the pool shipped a feature they didn't ask for.

The previous revision put all Translator work in a single Phase 2.5 sequenced **after** the pool side, on the reasoning that "the pool cannot distinguish a translated channel from a native one, so nothing about the pool's correctness depends on this landing." **That reasoning is withdrawn.** It is sound with respect to channel *provenance* and false with respect to channel *count*: a Translator in NonAggregated mode puts N channels on ONE upstream TCP connection, and the pool's connection-scoped `payout_mode` (`pool-apps/pool/src/lib/downstream/mod.rs:72`) collapses them regardless of provenance. The pool-side per-channel work is a **Phase 2 prerequisite**, not a Phase 2.5 follow-on.

**Phase 0 — schema, no behavior change.** Add `miner_identity` and `payout_receipt`; backfill one row per existing miner with a synthetic `payout_id` and their literal address stored as `addr(<address>)`, which §2.3 rejects at the descriptor-intake endpoint and therefore reads unambiguously as "static, do not derive." Nothing observable changes; independently revertible.

**Phase 1 — intake behind a flag, plus the fail-open fix.** Ship §3 validation with descriptor acceptance disabled by default; enable on signet or testnet4 first. **New and non-optional in this phase:** add the descriptor arm to `PayoutMode::try_from` (`stratum-apps/src/payout.rs:229-284`) and remove the `NoPayoutMode → FullDonation` default for descriptor-shaped identities (`mining_message_handler.rs:145`, `:391`). Today a valid descriptor in `user_identity` is paid **100% to the pool, silently, for the connection's lifetime** — so this must land before any code path can deliver a descriptor to the pool, or the feature's first success is a donated block. Gating tests: §8.2 #1, #5, and the new "valid descriptor is never silently donated" unit test.

**Phase 2 — opt-in on mainnet, with per-channel payout binding.** Miners presenting a valid descriptor get height-derived payouts; everyone else is untouched. Miner-facing docs with the §6 commands must ship **before** this phase — under height indexing a miner cannot fall back on "raise my gap limit," and without the docs they will see an empty wallet and conclude they were not paid. Phase 2 also carries §3.2.3 items 3–5 — move payout identity off `Downstream`, build coinbase outputs per extended channel, emit per-channel `NewExtendedMiningJob` and `SetNewPrevHash` instead of the group-scoped ones, and clear payout state on `CloseChannel`. This is a protocol-surface change, not a field move, and it is the largest single work item in the spec. It is **independently justified**: two native SV2 miners with different `sri/solo/<addr>` identities on one connection are already merged today from the next `NewTemplate` onward, so this is a pre-existing pool defect the design surfaces rather than creates. Gating tests: the "per-device payout survives a subsequent `NewTemplate`" test and the "closed channel stops being paid" test — both of which must verify coinbase outputs **after** at least one `NewTemplate`, since each channel's first job is already correct (`mining_message_handler.rs:531-537`) and a first-job-only test passes while production mispays.

**Phase 2.5 — V1 passthrough, Translator-only, as a separate deliverable.** Now strictly the Translator changes in §3.2.2 (seven items: reorder the channel-open trigger, source from `authorized_worker_name`, no `.miner{N}` suffix, drop the write-back at `sv1_server/mod.rs:986-988`, exempt the second injection site at `sv2/channel_manager/mod.rs:504-516`, refuse `aggregate_channels = true`, reject over-`Str0255` at authorize). It ships **after** Phase 2 for one reason only, and it is a different reason than before: not "the pool doesn't care" but "the pool must be able to pay N channels correctly before N channels arrive." The regression risk is unchanged and real — item 1 touches handshake ordering, the part most likely to break existing V1 deployments. Gating tests: §8.2 #6 (rewritten per the new two-field invariant), #9, the aggregated-mode-refusal test, the no-disconnect-on-first-share test, and the over-`Str0255` test. **New deployment constraint:** descriptor passthrough requires `aggregate_channels = false` and `verify_payout = false`; the Translator must refuse to boot otherwise. Until this ships, V1 farms can use the configured-identity path — but **only after Phase 1**, since before it a descriptor in the TOML donates the farm's blocks to the pool with `verify_payout` at its default of false.

**Phase 3 — coexistence is the steady state, not a transition.** Static-address and descriptor miners share every coinbase permanently; V1 miners participate via the Translator as one aggregate identity before Phase 2.5 and per-device after. The split that remains is *tooling*-imposed on three counts: descriptor miners need Core-grade recovery (§6), per-device V1 identity needs firmware that can hold a ~150-byte username (§3.2.4), and per-device V1 identity is **also** bounded by `aggregate_channels = false`, which forfeits the single-upstream-channel optimization and gains per-device vardiff and per-device failure isolation (§3.2.1a). Don't plan for eventual uniformity.

### 10.2 Rollback — now genuinely reversible

**This section is short because height indexing deleted its hard part.** The counter design's most dangerous operation — restoring a stale `next_index` and thereby re-deriving already-paid indices — **cannot happen here.** There is no index state to restore wrongly.

| Component | Reversible? | Procedure |
|---|---|---|
| Intake (§3) | **Yes, cleanly** | Disable the flag. New channels fall back to static addresses. |
| Coinbase assembly (§4) | **Yes** | Resolver pays the miner's static address if one is recorded. |
| Derivation (§5) | **Yes — nothing to roll back** | Stateless. Re-deriving at height `H` after any restore yields the identical script. |
| `payout_receipt` | **Yes** | Audit-only. A stale or missing restore loses receipts, not correctness — rebuild from the chain. |

Two cautions remain, both bounded.

**A stale `miner_identity` restore** can only re-point an account at an older descriptor **of its own** — the funds land at a script that account's holder can derive and spend. Not lost, not misdirected to a third party, not unrecoverable. Whether they notice is their responsibility: the receipt endpoint (§6) is published and the block heights are public, so every payment is discoverable by anyone who looks. The pool informs; it does not hand-hold. Attempting more would mean retaining balances (§4.4's custody trigger) or refusing to pay.

It is weaker still than that, for a code-grounded reason worth stating: **the stored descriptor is a cache, not authoritative state.** It is re-asserted on the wire at *every* channel open — the pool re-reads `msg.user_identity` (`mining_message_handler.rs:337`), re-derives (`:389`), and re-stores (`:412-415`), and the template path consumes the in-memory value, never a DB read (`template_distribution_message_handler.rs:56-65`). So exposure is bounded by `[restore → that miner's next channel open]`, a currently-connected device is unaffected, and reconnects are frequent by construction. The only bad case is a miner who changed descriptors, then went offline with credit still in the window, when a pre-change backup is restored — and even then the funds are theirs and spendable. Keep "reconcile descriptor changes forward on restore" as a runbook step; drop any framing of this as the design's main residual hazard.

**A stale share-ledger restore is the one that actually costs something**, and it is a §2.5 retention question rather than a rotation one: restoring a ledger pruned under a *lower* `D` can leave the oldest retained share inside the current window, so shares that are owed are simply absent. Verify the retention margin (§10.3) after any restore, not just at retarget.

A prior-draft warning that no longer applies, recorded so it isn't reintroduced: *"back up the index table on a separate restore-forward-only schedule."* Unnecessary now — normal backup discipline suffices.

### 10.3 Operator monitoring

The failure modes are silent, so each of these is the only external signal for a specific quiet failure:

| Metric / alert | Catches |
|---|---|
| **Payout `scriptPubKey` ≠ independently derived script at height `H`** | The single most valuable check. Recompute from `(descriptor, H)` outside the payout path and compare. Catches off-by-one on height, a stale cache, and a wrong-descriptor bug in one query. |
| Distinct `script_pubkey` count per `payout_id` **vs.** number of payouts | A silently-static miner — a §3.1 `has_wildcard()` miss. If these diverge, that miner isn't rotating. |
| Template height vs. coinbase-derived height mismatch | The §5.2 halt condition |
| Descriptor-parse failures at channel open, by error kind | A grammar collision (§3.2.1) or a Translator suffix bug. **Requires §3.2.3 item 2 first** — today a failed parse silently becomes `FullDonation` and emits nothing to count |
| **Channels resolving to `FullDonation` whose identity begins with a descriptor prefix** (`wpkh(`, `tr(`, `pkh(`, `sh(`) | The silent-donation bug (§3.2.3). Should be identically **zero** after Phase 1; any nonzero value is a misdirected block, and it is the highest-severity alert in this table |
| **Two or more channels on one connection carrying different payout identities** | The §3.2.3 collapse. Alert regardless of whether descriptors are involved — it affects `sri/solo/<addr>` identities too. Reachable in normal operation behind any Translator until §3.2.3 items 3–5 land |
| **Distinct `payout_id`s that derive an identical `script_pubkey`** in one block | A §2.2 normalization bug, most likely origin-info variants of one xpub. The primary key cannot catch this (§4.3.1) |
| Channels whose `user_identity` equals the Translator's *configured* value when passthrough is enabled | Passthrough silently not happening — the §3.2 #1 failure, which pays the operator's descriptor instead of the miner's |
| `PRIMARY KEY (block_height, payout_id)` violations | A duplicate payout row — §4.3.1's structural requirement being violated |
| Coinbase output count and serialized byte size per block | Approaching the §4.5 firmware ceiling |
| Oldest retained share's distance (in accumulated difficulty) from the current window edge | The §2.5 retention floor. If this margin shrinks below what a 4× upward retarget could consume, the next adjustment silently drops shares that are still owed. Re-evaluate at every retarget. |

Rows that the counter design needed and this one does not: index-advance rate, derivation-store commit latency, and store error rate. Removing monitoring surface is a real benefit — each of those was a metric an operator had to understand to run the system safely.

The first row deserves emphasis: it is a cheap independent recomputation, no existing implementation does it, and it is the only thing that distinguishes "derivation is correct" from "derivation has been paying the wrong index since the last deploy."

## 11. Open questions

1. **A principled recovery-range default.** What index window should miner docs recommend for `importdescriptors`? Derivable from the pool's age and block rate, and now a *documentation* question rather than the correctness question it was under a counter. The old "principled gap-limit default" question — which `para` names as open and sv2-apps ignores — dissolves here rather than getting answered.
2. ~~**Does the mining cookie survive?**~~ **Closed** — resolved by the 2026-07-29 thesis round in this design's favour, and no longer an open question. See the rewritten §9.5. The two follow-ups that *did* spin out of it are `batched-credit-timing-leak` (p1 — the hashrate side channel under batching, unquantified in any paper) and `canard-gouget-primary-text` (p3), and **neither bears on this spec**, because both are about *blinded* credit and this design keeps identity in the clear.
3. ~~**Descriptor rotation by the miner.**~~ **Closed — not a pool concern, and now confirmed *forced* rather than merely trivial.** Identity management is the miner's responsibility. A distinct descriptor is a distinct user, including on the same connection from the same hardware, and the pool neither links nor migrates across identities (§2.5). The code read closes the transport half outright: SV2 has **no re-key message.** `user_identity` is read at exactly two sites, both channel-open (`pool-apps/pool/src/lib/channel_manager/mining_message_handler.rs:100`, `:337`); `UpdateChannel` carries only `channel_id`, `nominal_hash_rate`, `maximum_target` (`mining_sv2-11.0.0/src/update_channel.rs:12-35`); and the per-share identity TLV is discarded (`:919-921`). A new descriptor is a new channel, which behind a Translator is a reconnect. Nothing about signalling needs designing and there is no migration to build. **One thing did come out of this question and is not closed with it:** in current pool code a device can present a second identity *in-band with no reconnect* by opening another channel, which re-points every sibling device on that connection. That is a funds-misdirection defect, not a rotation question — specified as §3.2.3 items 3–5 with a §5.2 halt condition and tests #8b/#8c.
4. **Firmware headroom for descriptor usernames.** Passthrough (§3.2) puts a ~150-byte descriptor in the rig's username field, and Avalon truncates at 63 while Whatsminer overflows past 127. Nobody has surveyed which V1 firmware in the field can actually hold it. **The shortening sub-question is now closed and the answer is no**: measured against `miniscript` 13.0.0, the shortest wildcard forms with a checksum are `tr(xpub…/*)` = **126** bytes, `pkh(xpub…/*)` = 127, `wpkh(xpub…/*)` = 128, and a raw-compressed-pubkey wildcard is rejected outright ("public keys must be 64, 66 or 130 characters in size"), so no shorter wildcard form exists. **No descriptor gets under Avalon's 63, and only a bare `tr()` gets under Whatsminer's 127.** Shortening is not a lever. The field survey remains open, and until someone runs it the honest statement to operators is that per-device V1 identity is firmware-dependent.
5. **Wallet tooling for sparse-index descriptors.** The gap is real and general: no consumer wallet handles "scan these 40 specific indices out of 900,000." Height indexing would be strictly better with it, and it is a plausible contribution to Sparrow or BDK.
6. **Subset-sum against real coinbase payout sets.** The CoinJoin literature transfers by argument; nobody has run the attack on actual coinbase distributions.
7. **Does an `sri/...` payout mode compose with a descriptor identity?** §3.2.1 mandates precedence, not composition. Whether a miner should be able to say "descriptor identity *and* 10% donation" is unspecified, and the current grammar cannot express it.

## 12. Sources consulted

**Wiki articles (14)**
- [[../wiki/concepts/xpub-payout-identity|xpub Payout Identity]] — per-scheme coupling table, the five mechanical changes, firmware ceilings, upstream status
- [[../wiki/concepts/coinbase-address-rotation|Coinbase Address Rotation]] — the `has_wildcard()` guard, the persist-before-return requirement, the anti-pattern in §5.1
- [[../wiki/concepts/pplns-jd|PPLNS-JD / SLICE]] — the positional ledger that makes this an identity-layer-only change
- [[../wiki/concepts/payout-attribution-privacy|Payout Attribution Privacy]] — §9.2, attribution comes from validation not payment
- [[../wiki/concepts/coinbase-amount-linkability|Coinbase Amount Linkability]] — §9.3, the subset-sum argument and the three structural reasons a coinbase is the worst case
- [[../wiki/concepts/lottery-pplns|Lottery-PPLNS]] — hazard #1 (duplicate payout rows), hazard #5 (per-template derivation storm)
- [[../wiki/concepts/tides|TIDES]] — work-issue-time coinbase precomputation, the §7.1 cadence contrast, and `share_log_window = 8 × D` (§2.5's window)
- [[../wiki/concepts/sv2-share-accounting-ext|SV2 Share Accounting Extension]] — the exact window boundary in §2.5 (first slice reaching the difficulty threshold back from the block, block-finding slice excluded)
- [[../wiki/concepts/pplns|PPLNS]] — the rolling-window property behind §2.5's overlap interval: shares still in the window are paid for blocks found after they were submitted
- [[../wiki/concepts/ctv-coinbase-payout-tree|CTV Coinbase Payout Tree]] — output-count compression if §4.5's ceiling binds
- [[../wiki/concepts/block-withholding|Block Withholding]] — §9.4, Eligius 2014 and Eyal 2015
- [[../wiki/decisions/attribution-retention-tradeoffs|Attribution Retention Tradeoffs]] — §4.4's FinCEN coupling, the per-axis cost table
- [[../wiki/topics/self-blinding-pool-design-space|Self-Blinding Pool Design Space]] — the boundary this spec deliberately does not cross
- [[../wiki/concepts/payout-schema-taxonomy|Payout Schema Taxonomy]] §3d — where payout-address handling sits as an axis

**Raw sources (4)**
- [[../raw/repos/2026-07-29-pool-identity-vs-payout-script-conflation-code-read|Identity-vs-payout-script code read]] — ckpool/public-pool/DATUM/TIDES/share-accounting-ext internals, SV2 #697/#1652/#1720
- [[../raw/repos/2026-07-29-sv2-apps-xpub-coinbase-rotation-code-read|sv2-apps xpub coinbase rotation]] — the `XpubDerivator` primitive and the persistence anti-pattern kept as §5.1's warning
- [[../raw/repos/2026-07-29-bip352-silent-payments-coinbase-incompatibility|BIP 352 coinbase incompatibility]] — §2.4, plus BIP-380 wildcards and the BIP-44 gap limit
- [[../raw/papers/2026-07-29-romiti-2019-mining-pool-payout-deanonymization|Romiti et al. WEIS 2019]] — §9.1's identification rates and reuse medians

**Prior output**
- [[playbook-self-blinding-pool-attribution-2026-07-29|Playbook: self-blinding pool attribution]] — the 5-step build path this spec implements as Part A

**Direct code read (2026-07-29, second revision)**

Read from the local `sv2-apps-coinbase-rotation` clone while revising, and both findings changed the spec rather than confirming it. All three anchors below survived the fifth revision's re-read:

- `stratum-apps/src/payout.rs` — `PayoutMode::try_from` **splits `user_identity` on `/`** for its `sri/solo/<addr>` and `sri/donate/<pct>/<addr>` grammar, and `address_part_from_user_identity()` splits on `.`. A wildcard descriptor contains six `/`. This is §3.2.1, which did not exist before the code read; the saving grace is that the existing code already tries address/descriptor parsing *before* the `/`-split, so the required precedence matches its current shape.
- `miner-apps/translator/src/lib/config.rs` — `Upstream.user_identity` is one string per upstream, documented as "appended with a counter for each mining channel (e.g. `username.miner1`)".
- `stratum-apps/src/config_helpers/xpub_derivation.rs:140` — `if !descriptor.has_wildcard()`, the guard §3.1 is built on, confirmed present in the branch.

**Translator + pool code read (2026-07-30, fifth revision — branch HEAD `e2930150`)**

A multi-agent read of both sides, adversarially verified. It **retracted fifteen claims** from the previous revision and found one defect that blocks the feature. What follows is the anchor list; the reasoning is in §3.2.1a–§3.2.3 and §13.

*Translator, identity path:*

- `sv1/sv1_server/mod.rs:975-984` — the channel-open identity is `self.user_identity()`, an `Arc<OnceLock<String>>` filled once from TOML (`lib/mod.rs:484-488`), plus `.miner{N}` from an `AtomicUsize`. The device's username is never consulted, so **every V1 rig behind a Translator is paid to the operator's configured identity today, in both modes.** The existing `sri/` suffix exemption (issue #369) is the shape descriptors need.
- `sv1/sv1_server/mod.rs:529-546` — the channel opens on the **first** downstream message and the `return` at `:546` precedes `handle_message` at `:552`, so **no V1 message is parsed before the channel opens**; the queue drains only at `:781-805`. At the instant identity is chosen, both identity fields are still `String::new()` (`sv1/downstream.rs:114-115`). This is why "read the miner's username" and "add a field for it" are both insufficient — there is no username yet.
- `downstream_message_handler.rs:207` — `data.authorized_worker_name = name.to_string()`, **untruncated**. This is the route around the cap; no new field is required.
- `downstream_message_handler.rs:209` + `utils.rs:272-291` — `data.user_identity = tlv_compatible_username(name)`, `MAX_USER_IDENTITY_BYTES = 32`, warn-and-truncate. **One call site only**, on the authorize path.
- `sv1_server/mod.rs:986-988` — `d.user_identity = user_identity.clone()`, the write-back that would put a ~150-byte descriptor into the TLV-bound field. Must be dropped.
- `sv1_server/mod.rs:648-676` — the TLV is built gated **only** on NonAggregated mode with no negotiation check at the construction site, and `UserIdentity::new`'s error maps to `TproxyError::disconnect` (`:665-671` → `:175-182`). This is why raising the cap disconnects miners.
- `sv2/channel_manager/mod.rs:504-516` — a **second** identity-injection site, aggregated mode only, rewriting to `<prefix>.translator-proxy` with its own `sri/` exemption and a bare `try_into().unwrap()` into `Str0255`. A patch touching only `sv1_server/mod.rs:980` is still mangled here.
- `sv2/channel_manager/mod.rs:498-565`, `:864-1002`, `:44`, `:53-54` — the aggregated-mode structure behind §3.2.1a: one upstream channel per connection lifetime, devices distinguished only by a 2-byte translator-minted `local_index`.
- `config.rs:46` — `aggregate_channels` is **required with no default**, so a startup guard is cheap and there is no silent-default hazard.

*Pool, payout path — the larger half:*

- `pool-apps/pool/src/lib/downstream/mod.rs:72` — `payout_mode: SharedLock<Option<PayoutMode>>`, **one slot per TCP connection**, overwritten on every open (`mining_message_handler.rs:171-174`, `:412-415`), never cleared on close (`:67-90`), read once per connection per template (`template_distribution_message_handler.rs:56-65`). This is the collapse.
- `template_distribution_message_handler.rs:158-165` → `channels_sv2-7.0.0/src/server/extended.rs:516-521` — extended channels inherit the group job and only re-stamp the extranonce prefix, **never rebuilding the coinbase**. Meanwhile each channel's *first* job at open **is** built from its own parsed mode (`mining_message_handler.rs:531-537`), which is why a first-job test passes while production mispays.
- `stratum-apps/src/payout.rs:229-284`, `:429-436`, `:99-104` and `mining_message_handler.rs:145`, `:391` — **the blocking defect.** `PayoutMode::try_from` has no descriptor arm; `script_from_address` wraps its input as `addr(<descriptor>)`, which cannot parse; the `/`-split then yields `NoPayoutMode`, which the pool maps to `PayoutMode::FullDonation` — one output, the entire block value, to the pool script, persisted for the connection's lifetime, no error returned and nothing logged. **A valid untruncated descriptor takes this path today.** The machinery to do it right already exists and is simply never called on `user_identity`: `CoinbaseRewardScript::from_descriptor` accepts wildcards at `stratum-apps/src/config_helpers/coinbase_output/mod.rs:45-61` with `has_wildcard()` at `:143`.
- `channels_sv2-7.0.0/src/server/extended.rs:93`, `:259` — `ExtendedChannel` already stores `user_identity` and exposes `get_user_identity()`, already read at `pool-apps/pool/src/lib/monitoring.rs:23`. The missing piece is the job pipeline, not a data structure.
- `downstream/common_message_handler.rs:33-106` — `SetupConnection` reads only `flags`, discarding `vendor` / `hardware_version` / `firmware` / `device_id`: channel *provenance* really is invisible to the pool. Channel *count* is not.

*The substrate caveat, which bears on §4 and §7.2:* **this clone is a solo/donate coinbase-templating pool, not a reward-sharing one.** `PayoutMode::coinbase_outputs` (`payout.rs:59-105`) is exhaustive and maxes at **two** outputs; `ShareAccounting` is per-channel monotonic counters with no window (`channels_sv2-7.0.0/src/server/share_accounting.rs:74-92`); a found block forwards the finding channel's own coinbase verbatim (`mining_message_handler.rs:964-972`) — winner-take-all; and `grep -i pplns` across the repo returns **zero hits**. So §4.3's `pplns_distribution`, §4.3.1's merge, §4.5's output ceiling and §7.2's 500-miner budget are **un-verifiable against this clone** and rest on the [[../wiki/concepts/sv2-share-accounting-ext|share-accounting extension]] and [[../wiki/concepts/pplns-jd|PPLNS-JD]] articles alone.

*What was not done:* no code was executed and the integration suite was not run. Everything above is static reading plus standalone `miniscript` 13.0.0 parser probes. `integration-tests/lib/mod.rs:369-523` does parameterize `aggregate_channels`, and `integration-tests/tests/extensions.rs:41-44` comments that `aggregate_channels = false` is what makes TLV fields appear — consistent with the reading, unexecuted. There is also **no regression test anywhere for the collapse**: every case in `pool_solo_mining.rs` uses one identity per connection, and the two-channel case at `:309`/`:431` uses the same `"cool_miner/worker.1"` for both.

**Prior thesis round (2026-07-29)**
- [[report-blinded-share-credit-thesis-2026-07-29|Report: is blinded share credit strictly harder than blinded payout?]] and [[../wiki/theses/blinded-share-credit-commitment|the thesis]] — verdict **MIXED**. Rewrote §9.5 from "unanalyzed by anyone" to a resolved question, and supplies the argument for why this plan's scope is the tractable one: payout blinding is offline non-interactive derivation, share-credit blinding is an online two-party protocol with an unquantified timing leak and a broken identity-keyed vardiff. Also the source of §9.5's Bedrock corrections (no hardness assumption; ~7.44-year S7 cookie rotation; prevout placement consensus-invalid for the share that is a block).

**Gap research (2026-07-29)**
- Sparrow Wallet FAQ — default gap limit 20 (40 postmix), configurable under Settings → Advanced
- BDK `crates/chain/src/indexer/keychain_txout.rs` — `pub const DEFAULT_LOOKAHEAD: u32 = 25`

*Both figures ground §4.2 and §6. In the first draft they were the reason to **reject** height indexing; here they are the reason height indexing **requires** Core-grade recovery tooling and explicit miner documentation. The numbers did not change — the operator's judgment on whether that cost is acceptable did.*

## 13. Revision history

**2026-07-29 (initial)** — per-payout counter, SV2-only intake, finder bonus treated as a live possibility.

**2026-07-29 (this revision)** — three operator decisions, each of which simplified the design:

1. **Height as derivation index** (§4). Deleted the derivation-store section, its four correctness requirements, the halt-don't-degrade failure matrix, three regtest tests, three monitoring metrics, and the never-roll-back-state hazard. Accepted cost: no bare-seed recovery (§4.2), mitigated by documenting exact `bitcoin-cli` commands (§6). Net effect — the riskiest part of the spec became its shortest.
2. **Finder bonus out of scope** (§0, §4.3.1). Makes "exactly one output per miner per block" free rather than a merge requirement to enforce.
3. **V1 miners via the SV2 Translator** (§3.2). Removes the "SV2-only, no V1 path" limitation, at the cost of one shared payout identity per Translator upstream.

The one thing this revision made *more* complex is §3.2.1, and it came from reading the code rather than from any of the three decisions: `user_identity` already has a `/`-delimited grammar that collides with descriptor syntax.

**2026-07-29 (third revision)** — two corrections, one from the operator and one from the wiki:

1. **Translator passthrough, not Translator configuration** (§3.2, §1, §8.2, §10.1). The intended design is that the **V1 miner sets its own username to the descriptor** and the Translator forwards it upstream unmodified — a proxy, not the owner of payout identity. This is better than what the previous revision described, because it gives per-rig payout identity instead of one identity per Translator. But reading the code showed the current Translator **cannot** do it: channel identity comes from TOML, the channel opens before `mining.authorize` arrives, and the only path carrying the miner's own username truncates at 32 bytes and is discarded by the pool. §3.2 became a three-change modification spec with regtest tests (§8.2 #6/#7/#9) and its own migration phase (§10.1 Phase 2.5). *(Superseded by the fifth revision: 7 Translator changes plus 6 larger pool-side ones, and one of the three reasons — the 32-byte cap — was the wrong diagnosis.)* The previous revision's claim that this "deletes the entire firmware field-width problem class" is **withdrawn** — that was true only for operator-set identity. Under passthrough the descriptor is typed into the rig, so Avalon's 63-char truncation and Whatsminer's overflow apply again, and §3.2 now presents both paths as an explicit operator tradeoff.
2. **§9.5 rewritten — the mining-cookie question is resolved, not open.** The section claimed the property was "unanalyzed by anyone" and cited an active inventory record. Both were stale: the 2026-07-29 thesis round closed it (verdict MIXED) and `candidates/blinded-mining-cookie-security.md` is `resolved: 2026-07-29`. The resolution favours this design — it keeps identity in the clear, so identity-keyed vardiff, dedup, and crediting all work untouched, and the thesis's surviving obstacle (crediting is online and interactive, payout is offline and not) is the argument for why this plan takes the tractable half. Open question #2 is closed; #4 is replaced with the firmware-headroom question that passthrough creates.

**2026-07-30 (fourth revision)** — identity management moved off the pool entirely; a share-retention requirement takes its place, and the window's unit is corrected.

1. **`N = 8 × D` is a share count, not a block count** (§2.5, frontmatter). An intermediate draft of this revision wrote "~8 blocks of work, ~80 minutes" — true only for a pool holding 100% of network hashrate. The window is **eight times the network difficulty in accumulated share difficulty**: TIDES states N as scaling with D with *no fixed share count*, and the share-accounting extension's boundary is a difficulty accumulation walked back from the block. Time-to-fill scales inversely with pool hashrate — ~13 hours at 10%, **~5.5 days at 1%**, ~55 days at 0.1%. A retention policy written against blocks or wall-clock would discard shares still owed payment. This was the most consequential error in the draft.
2. **Retention must exceed the current window, because an upward retarget grows it backwards** (§2.5, §8.2 #12, §10.3). `D` changes every 2016 blocks; when it rises, the window reaches further back in share history than before, so shares previously outside it fall back inside. Pruning to exactly the current window is a correctness bug that manifests only after an upward retarget — it ships and sits quiet. Bitcoin clamps retargets to 4×, making `32 × D` of accumulated share difficulty the worst-case-safe floor at the current `D`, re-evaluated each period. No prior revision contained this requirement.
3. **Identity is the miner's to manage** (§2.5, §0 scope, §4.3.1, open question #3). A distinct descriptor is a distinct user — including a new descriptor arriving on the same connection from the same hardware. The pool does not link, migrate, or reconcile identities, and this revision removes the draft's treatment of "descriptor rotation" as a pool-side design problem, along with its mid-window overlap discussion. §4.3.1 merges on `payout_id` because anything coarser would require the identity-linking the design refuses to perform. Open question #3 stays closed, on firmer grounds.
4. **Retention is bounded, not indefinite** (§2.5). The draft recorded never-expiring `miner_identity` as an unresolved tension with §9.2. It resolves: rows must outlive any share that can still be paid, and past the retarget-safe horizon a pool may prune — which §9.2's posture argues for. Correctness sets a floor, not a mandate to keep everything forever.
5. **§10.2's stale-restore caution bounded.** A stale restore can only re-point a miner at an older descriptor **of their own** — funds land at a script they can derive and spend. Whether they watch that wallet is not the pool's problem to engineer around; the receipt endpoint and block heights are published, so every payment is discoverable. Attempting more would mean retaining balances or refusing to pay.

**2026-07-30 (fifth revision)** — an exhaustive multi-agent code read of the clone at HEAD `e2930150`, adversarially verified, **retracted fifteen claims** from the third and fourth revisions. Five of them change the plan rather than its prose.

1. **A valid descriptor is paid 100% to the pool today** (§3.2.1, §3.2.3, §5.2, §8.1, §8.2 #8, §10.1 Phase 1, §10.3, §12). This is the finding that reorders the phases. `PayoutMode::try_from` has no descriptor arm; `script_from_address` wraps its input as `addr(<descriptor>)`, which cannot parse; the `/`-split then returns `NoPayoutMode`, which the pool maps to `PayoutMode::FullDonation` — one output, the whole block value, to the pool's own script, persisted for the connection's lifetime, **no error returned and nothing logged.** Prior revisions assumed the failure mode of an unrecognized identity was rejection. It is silent expropriation. The fail-closed fix is now non-optional Phase 1 work and must land before any descriptor can be delivered to a pool, including in testing.
2. **The pool is the bigger half of the work, not the Translator** (§1.1, §3.2.3, §10.1). The third revision located the whole problem in the Translator. It is not there: `Downstream.payout_mode` is **one slot per TCP connection**, blind-overwritten on every channel open, and extended channels inherit the group job which never rebuilds the coinbase — so N devices on one connection collapse to the last-opened identity from the next `NewTemplate` onward. Each channel's *first* job **is** built from its own mode, so a first-job test passes while production mispays; there is no regression test for this anywhere in the repo. Six pool-side changes (§3.2.3) are a **prerequisite** for any multi-channel connection, which is why the fourth revision's Phase 2 / Phase 2.5 ordering is reversed here.
3. **`aggregate_channels = false` is a structural requirement, not a tuning knob** (§1.1, §3.2.1a, §5.2, §8.2 #8a, §10.1). In aggregated mode `AggregatedState::NoChannel` is the only arm that reaches the upstream sender, every channel id collapses to `AGGREGATED_CHANNEL_ID = u32::MAX`, and devices are distinguished only by a translator-minted 2-byte `local_index`. Per-device payout identity is **unrepresentable** in that mode no matter how either side is refactored, so a Translator running aggregated must refuse descriptor identities at startup rather than silently pay them to one script.
4. **The 32-byte cap must be left alone** (§3.2.1c, §3.2.2, §8.2 #8). The third revision prescribed widening `MAX_USER_IDENTITY_BYTES`. That is actively harmful: the normative constant lives in external crates, and raising the local mirror converts a warn-and-truncate into `UserIdentity::new` returning an error that maps to a hard disconnect — every descriptor-carrying V1 rig drops on its first share. The route is around, not through: `data.authorized_worker_name` already holds the **untruncated** username, and the real binding limit upstream is `Str0255` at 255 bytes. No new field is needed and the TLV path is left untouched.
5. **Origin information must be stripped during normalization** (§2.2, §8.1, §8.3, §10.3). `wpkh([fp/84h/0h/0h]xpub…/0/*)` and `wpkh(xpub…/0/*)` produce **different `payout_id`s and byte-identical `scriptPubKey`s**. `PRIMARY KEY (block_height, payout_id)` does not catch this, so the post-derivation distinctness assert must run on **derived scripts**, not on identities.

Also measured rather than estimated: the shortest wildcard descriptor forms are `tr(xpub…/*)` at **126** bytes, `pkh` at 127, `wpkh` at 128, with raw-compressed-pubkey wildcards rejected by the parser — so the open question about shortening a descriptor under Avalon's 63-char truncation is **closed negative** (§11 OQ4). Open question #3 moves from "trivially closed" to "closed and *forced*": an in-band re-key on a shared connection would hijack sibling channels' payouts under today's code, which is a pool-side correctness defect (§3.2.3, §5.2) rather than a rotation-semantics question.

Ten residual risks are recorded rather than resolved; the load-bearing one is whether per-channel coinbase templating is confined to this repo's pool code or requires an upstream `channels_sv2` change, which is the difference between a week and a quarter on §3.2.3 item 4. Nothing was executed — see §12's *what was not done*.
