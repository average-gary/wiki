---
title: "Spec: a pool that accepts a wildcard descriptor as miner identity and derives each coinbase payout address from the block height"
type: plan
format: spec
generated: 2026-07-29
revised: 2026-07-29
confidence: medium
host_scheme: PPLNS-JD / SV2 (share-accounting-ext type 32)
rotation_trigger: block height as derivation index (stateless)
descriptor_intake: SV2 user_identity (V1 miners via the SV2 Translator)
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
  - "wiki/decisions/attribution-retention-tradeoffs.md"
  - "wiki/topics/self-blinding-pool-design-space.md"
  - "output/playbook-self-blinding-pool-attribution-2026-07-29.md"
  - "raw/repos/2026-07-29-pool-identity-vs-payout-script-conflation-code-read.md"
  - "raw/repos/2026-07-29-sv2-apps-xpub-coinbase-rotation-code-read.md"
  - "raw/repos/2026-07-29-bip352-silent-payments-coinbase-incompatibility.md"
  - "raw/papers/2026-07-29-romiti-2019-mining-pool-payout-deanonymization.md"
summary: "Technical spec for a pool taking a BIP-380 wildcard descriptor as SV2 user_identity and deriving each miner's coinbase scriptPubKey at index = the block height being mined. Height indexing makes derivation a pure function of (descriptor, height): no pool-side index state, no persistence ordering, no rotation trigger, and recovery survives the pool's death. Hosted on PPLNS-JD because its Slice/Share ledger is already identity-free. V1 miners reach it through the SV2 Translator. Eleven sections: descriptor grammar and the load-bearing has_wildcard() rejection, the payout_id/script split, the user_identity grammar collision on '/', and an honest privacy scope — this defeats Romiti et al. on chain and is a pool-side no-op."
---

# Spec: wildcard-descriptor miner identity with height-indexed coinbase derivation

> Generated from the [bitcoin-mining-payout-schemas](../_index.md) wiki — 12 articles, 4 raw sources, and 1 prior output consulted, plus 3 direct reads of the `sv2-apps-coinbase-rotation` clone during revision (§12). **Revised 2026-07-29** to height-as-index (§4), which deleted the derivation-store section entirely; finder bonus moved out of scope; V1 reinstated via the Translator. See §13 for what the revision removed.

## 0. Summary and scope

A miner authenticates to the pool with a **BIP-380 wildcard output descriptor** (e.g. `wpkh(xpub…/0/*)`) instead of a literal address. When the pool builds a coinbase for block height `H`, each paid miner's output pays `descriptor.at_derivation_index(H)`. No miner is paid the same address twice, because no height repeats.

**The load-bearing property is that derivation is a pure function of `(descriptor, height)`.** The pool stores no index, advances no counter, and persists nothing on the payout path. This one choice deletes an entire class of failure — see §4.1 for what it buys and §4.2 for the cost you are accepting.

**Host scheme: PPLNS-JD / SV2** with `share-accounting-ext` (extension type 32). This is chosen because it is the only surveyed scheme whose ledger is *already* decoupled: its `Slice{number_of_shares, difficulty, fees, root, job_id}` and `Share{nonce, ntime, version, extranonce, job_id, share_index, merkle_path}` structures contain **not one identity field**, and the ledger primary key is positional — `(slice, share_index)`, verified by `merkle_path(share) + share_hash == slice.root`. Every other scheme must retrofit a decoupling that PPLNS-JD gets for free. ckpool by contrast converts `username[128]` *directly into* the payout script via `address_to_txn()` into `txnbin[48]`; public-pool makes `address varchar(62)` part of a composite `PRIMARY KEY`.

**Explicitly in scope**: descriptor intake and validation, the ledger-key/payout-script split, height-indexed coinbase assembly, miner recovery, and the operator runbook.

**Explicitly out of scope**: **finder bonus** — no flat bounty to the block finder, so every miner appears exactly once per payout list, which is what makes height indexing safe (§4.3.1); blinding the pool to attribution (see §9.2 — this design is a pool-side privacy *no-op* by construction, and saying otherwise would be false); balance accrual to a payout threshold (see §4.4 — accrual is custody, and custody is the regulatory trigger); output-count compression via covenants (see [[../wiki/concepts/ctv-coinbase-payout-tree|CTV Coinbase Payout Tree]]).

> **Scope interaction worth stating once.** Height indexing and "no finder bonus" are not independent choices. Because index is a pure function of height, a miner can have **exactly one address per block** — so any scheme paying a miner twice in one block (bonus + proportional share) must merge those rows into one output or it cannot be expressed at all. With the finder bonus out of scope this is free. If it ever comes back, read §4.3.1 first.

**Prior-art status, and it is unusual**: **no pool anywhere accepts an xpub, output descriptor, or payment code as a miner's payout identity.** That is a confirmed negative result, verified against source for ckpool, public-pool, DATUM, the SV2 reference apps, and Ocean's docs — not an unsearched gap. Upstream SV2 shipped `coinbase_output_descriptors` in PR #1720 (merged 2025-07-09) but **wildcards remain rejected in merged code**, and its scope is the pool's own single output, not per-miner. This spec is therefore a greenfield design, not an integration against a known-good reference.

Note what the merged code's rejection comment actually says: *"no wildcards allowed (at least for now; gmax thinks it would be cool if we would instantiate it with the blockheight or something, but need to work out UX)."* **This spec implements that parenthetical.** The height-indexing choice in §4 is not novel invention — it is the deferred upstream idea, with §6 as the "work out UX" part that deferred it.

## 1. System architecture

```
  V1 miner ──┐
   (Avalon,  │  stratum V1
  Whatsminer)│  username = descriptor
             ▼
      ┌──────────────┐              ┌──────────────────────────────────────┐
      │ SV2          │   SV2        │  POOL                                │
      │ Translator   │──────────────┼─▶┌──────────────┐                    │
      │ (§3.2 — one  │ user_identity│  │  Identity    │ validate (§3.1)    │
      │  descriptor  │              │  │  Intake      │ hard-fail gate     │
      │  per         │              │  └──────┬───────┘                    │
      │  upstream)   │              │         │ payout_id = H(descriptor)  │
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
| **SV2 Translator** | Terminates V1 miners, opens an SV2 channel carrying the descriptor as `user_identity` (§3.2) | Existing, unmodified |
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

Normalize before hashing: strip the `#checksum` suffix, lowercase hex, canonicalize key origin `[fingerprint/path]` spacing. Two textually different spellings of the same descriptor **must** yield the same `payout_id`, or a miner silently splits into two ledger identities and loses accrued credit.

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

The descriptor arrives in SV2's `user_identity` field on `OpenExtendedMiningChannel` / `OpenStandardMiningChannel`. `user_identity` is `Str0_255`, which accommodates a ~150-character wildcard descriptor with headroom.

**V1 miners are not excluded.** They connect to an **SV2 Translator**, which terminates the V1 session and opens an SV2 channel upstream. The descriptor is configured on the Translator's upstream, not typed into each miner's firmware:

```toml
[[upstreams]]
address = "pool.example.com"
port = 34254
authority_pubkey = "…"
user_identity = "wpkh([d34db33f/84h/0h/0h]xpub6ERApfZwUNrhL…/0/*)#hkuz7pyx"
```

This inverts the firmware problem rather than solving it, and the distinction matters for who bears the risk. The ceilings are real but they now apply to a **config file on a machine the operator controls**, not to an ASIC's username buffer:

| Constraint | Value | Still relevant? |
|---|---|---|
| Typical wildcard descriptor | ~150 chars | — |
| SV2 `user_identity` (`Str0_255`) | 255 | **Fits with headroom** — the only limit on the path |
| **Avalon firmware** | truncates at **63** | **No** — the descriptor never enters miner firmware |
| **Whatsminer firmware** | overflow past 127 ("may damage your miner") | **No** — same reason |
| Firmware percent-encoding | mangles `()[]/*#` | **No** — same reason |
| ckpool `username[128]`, splits on `._` | 127 usable | **No** — not on this path |

One consequence to design around: the Translator sets **one `user_identity` per upstream**, and the doc comment notes it "will be appended with a counter for each mining channel (e.g. `username.miner1`, `username.miner2`)." So all V1 miners behind one Translator share a single descriptor and therefore a single `payout_id` — they are one ledger identity with one payout. A V1 farm wanting per-rig separation runs a Translator per rig group, or accepts aggregate payout. This is a real limitation but not a blocking one, and it is the operator's choice rather than the pool's problem.

> **The worker-suffix collision, and it is not hypothetical.** The Translator appends `.minerN`, and `sv2-apps` already parses `user_identity` by splitting on `.` — `address_part_from_user_identity()` does `split_once('.').map(|(address, _)| address)`. A descriptor's checksum is delimited by `#`, not `.`, so the suffix strips cleanly *provided* the split is applied before descriptor parsing and the descriptor itself contains no `.`. Wildcard descriptors normally don't. **Validate this explicitly** (§8.1) rather than assuming it, because the failure is a silently truncated descriptor that may still parse.

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

What saves it is ordering, and the existing code already has the right shape: `PayoutMode::try_from` tries `script_from_address(addr)` **first** and only falls through to `split('/')` if that fails. So the rule for this spec is explicit:

1. **Try descriptor parse first.** If `validate_descriptor()` succeeds, this is a descriptor identity. Stop. Never reach the `/`-splitting branch.
2. **Only then** fall through to the `sri/...` payout-mode grammar.
3. **Never** feed a `user_identity` to both parsers and merge results.

Two reasons this ordering and not the reverse: a descriptor is self-identifying (it has a checksum, and `wpkh(`/`tr(`/`pkh(` prefixes that `sri` cannot produce), whereas `sri/solo/<addr>` is a bare-token grammar that could in principle be shadowed. And a descriptor beginning with `sri` is impossible, while a `sri/...` string that accidentally parses as a valid checksummed descriptor is also impossible — so the two languages are disjoint *as long as* you commit to one direction of precedence. Write a test asserting `sri/solo/bc1q…` is **not** treated as a descriptor identity and that a descriptor is **not** treated as a payout mode (§8.1).

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

### 4.4 Dust and the accrual trap

Sub-dust amounts are **dropped, not accrued.** This is a deliberate and costly choice, and it is the regulatory hinge of the whole design.

FinCEN FIN-2019-G001 §5.4 exempts pool distributions as "integral to the provision of services" — *unless* the operator combines them with "hosting CVC wallets," which is "account-based money transmission." **Accrual to a minimum threshold is a hosted balance**, which is exactly the trigger. Compounding it, §4.5.1(a) makes an "anonymizing services provider" a money transmitter **expressly ineligible** for the integral exemption. Custody and address-rotation are individually survivable and **jointly fatal**.

So a pool doing per-payout rotation has a much stronger reason than usual to stay coinbase-direct. The cost is real and lands on the smallest miners — Ocean's own TIDES docs concede that satoshi-precision rewards produce uneconomic dust and that sub-1-satoshi earnings at block-found "are lost." Document the effective minimum plainly rather than hiding it behind an accrual buffer.

One interaction specific to height indexing: a dropped dust payout leaves **no trace in the miner's address history**, since no address is consumed for a miner who isn't paid. Under a counter, a skipped miner and a paid miner are distinguishable by index movement. Here the miner's only signal is the receipt endpoint (§6), which is another reason to publish it even though it is not recovery-critical.

### 4.5 Output-count ceiling is firmware, not consensus

Any per-miner-output scheme is bounded by what ASIC firmware accepts as a coinbase: roughly **380–530 outputs** (DATUM's table caps at "huge — max 16 kB"; per-vendor, nicehash ≈500 B, antminer ≈730 B, antminer2 2250 B, whatsminer 6500 B). This is not changed by rotation — rotation alters *which* script each output pays, not how many there are — but it caps the miner count per block regardless, and Braidpool's retrospective is the empirical warning: p2pool's large coinbase of small outputs "competed for block space with fee-paying transactions." Braidpool's own coinbase has **two** outputs.

If the paid-miner count approaches the ceiling, the levers are a higher dust floor, paying the top N by weight, or covenant-based fanout ([[../wiki/concepts/ctv-coinbase-payout-tree|CTV Coinbase Payout Tree]], blocked on BIP-119).

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

The last row is new and specific to this design: height is now correctness-critical *input* rather than internal state, so it must be validated where it enters.

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
  - A descriptor with a `.minerN` worker suffix appended by the Translator strips to the exact original descriptor, checksum intact.
  - A **truncated** descriptor is rejected rather than parsed — the dangerous case is a truncation that still parses.
- **`payout_id` normalization**: textual variants of one descriptor collide; genuinely different descriptors do not.
- **`merge_by_payout_id()`** collapses two rows for one miner into one summed output (§4.3.1), even though no in-scope scheme produces them.

### 8.2 Integration / regtest — the tests that matter

1. **Address equals height, end to end.** Mine a block at known height `H`; assert every payout output equals `deriveaddresses(desc, [H,H])` computed independently by `bitcoin-cli`, not by the pool's own code. Catches off-by-one between template height and coinbase height.
2. **Wrong-height guard.** Fault-inject a template/coinbase height mismatch; assert the pool **halts** rather than paying at the wrong index (§5.2, last row).
3. **Orphan reconvergence.** Mine a competing chain so height `H` is re-mined; assert the replacement block pays the **same** address, and that no index is consumed or skipped. This is the test that demonstrates the orphan-cleanliness claim in §4.1.
4. **No-wildcard descriptor is rejected at channel open** — plus the negative: assert it never reaches the payout path.
5. **Full-cycle recovery via `importdescriptors`.** Mine N blocks paying one descriptor across scattered heights, then from a fresh Core wallet run the exact §6 commands and assert every payment is found. Then assert a **bare seed restore with default gap limit finds nothing** — pinning the §4.2 tradeoff as an executable test rather than a caveat, so nobody later "fixes" it by accident.
6. **V1 through the Translator.** A V1 miner (cgminer or a simulator) authenticates against a Translator whose upstream `user_identity` is a descriptor; assert the pool derives correctly and that the `.minerN` suffix does not corrupt the descriptor (§3.2).
7. **500-output coinbase** accepted by the node and within the firmware byte budget of §4.5.
8. **Two Translator channels, one descriptor** → one `payout_id`, one merged output (§3.2's aggregate-identity consequence).

### 8.3 Property tests

- **Determinism across process lifetimes**: for arbitrary `(descriptor, height)`, the derived script is identical across restarts, threads, and fresh processes with no shared state. The counter design needed a crash-interleaving property test here; this needs a purity assertion.
- **No address collision across miners**: for distinct descriptors and any height, derived scripts differ. (Guards against a `payout_id` normalization bug collapsing two miners into one identity.)
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

### 9.5 Share-credit theft must be reconstructed, not waived

Bedrock's mining cookie `C_M = H²(R_M, M.uname)` defeats BiteCoin connection-hijacking **precisely because the username is an input to the PoW** — an attacker substituting their own username produces a hash that no longer meets target. If `user_identity` becomes a descriptor rather than a stable plaintext username, that construction needs re-deriving. **Whether it survives is unanalyzed by anyone** and is tracked as an active inventory record (`candidates/blinded-mining-cookie-security.md`). This spec keeps a stable plaintext descriptor in `user_identity`, so the property most likely survives unchanged — but that is an assumption, not a result.

## 10. Deployment

### 10.1 Migration path

The pool almost certainly already has miners authenticating with literal addresses. Descriptor identity must be **additive, never a cutover** — an existing miner's payout path must not change because the pool shipped a feature they didn't ask for.

**Phase 0 — schema, no behavior change.** Add `miner_identity` and `payout_receipt`. Backfill one row per existing miner with a synthetic `payout_id` and their literal address stored as `addr(<address>)`, which §2.3 rejects at the descriptor-intake endpoint and which therefore reads unambiguously as "static, do not derive." Nothing observable changes; independently revertible.

**Phase 1 — intake behind a flag.** Ship §3 validation with descriptor acceptance disabled by default. Enable on signet or testnet4 first. The gating tests are §8.2 #1 (address equals height, verified by `bitcoin-cli` rather than the pool's own code) and #5 (full-cycle recovery via `importdescriptors`). Those two together prove the design end-to-end: the pool derives what the chain says it should, and a miner can actually retrieve it.

**Phase 2 — opt-in on mainnet.** Miners presenting a valid descriptor get height-derived payouts; everyone else is untouched. **Miner-facing docs with the §6 commands must ship before this phase, not after.** Under height indexing a miner cannot fall back on "raise my gap limit" — without the docs they will see an empty wallet and conclude they were not paid.

**Phase 3 — coexistence is the steady state, not a transition.** Static-address and descriptor miners share every coinbase permanently. V1 miners can now participate via the Translator (§3.2), so this is no longer a protocol-imposed split — but it is still a *tooling*-imposed one, since descriptor miners need Core-grade recovery. Don't plan for eventual uniformity.

### 10.2 Rollback — now genuinely reversible

**This section is short because height indexing deleted its hard part.** The counter design's most dangerous operation — restoring a stale `next_index` and thereby re-deriving already-paid indices — **cannot happen here.** There is no index state to restore wrongly.

| Component | Reversible? | Procedure |
|---|---|---|
| Intake (§3) | **Yes, cleanly** | Disable the flag. New channels fall back to static addresses. |
| Coinbase assembly (§4) | **Yes** | Resolver pays the miner's static address if one is recorded. |
| Derivation (§5) | **Yes — nothing to roll back** | Stateless. Re-deriving at height `H` after any restore yields the identical script. |
| `payout_receipt` | **Yes** | Audit-only. A stale or missing restore loses receipts, not correctness — rebuild from the chain. |

The one remaining caution is unrelated to rotation: a **stale `miner_identity` restore** could resurrect a descriptor a miner had replaced, paying an address they no longer watch. Funds remain theirs and spendable, but they may not see them. Reconcile descriptor changes forward on restore.

A prior-draft warning that no longer applies, recorded so it isn't reintroduced: *"back up the index table on a separate restore-forward-only schedule."* Unnecessary now — normal backup discipline suffices.

### 10.3 Operator monitoring

The failure modes are silent, so each of these is the only external signal for a specific quiet failure:

| Metric / alert | Catches |
|---|---|
| **Payout `scriptPubKey` ≠ independently derived script at height `H`** | The single most valuable check. Recompute from `(descriptor, H)` outside the payout path and compare. Catches off-by-one on height, a stale cache, and a wrong-descriptor bug in one query. |
| Distinct `script_pubkey` count per `payout_id` **vs.** number of payouts | A silently-static miner — a §3.1 `has_wildcard()` miss. If these diverge, that miner isn't rotating. |
| Template height vs. coinbase-derived height mismatch | The §5.2 halt condition |
| Descriptor-parse failures at channel open, by error kind | A grammar collision (§3.2.1) or a Translator suffix bug (§3.2) |
| `PRIMARY KEY (block_height, payout_id)` violations | A duplicate payout row — §4.3.1's structural requirement being violated |
| Coinbase output count and serialized byte size per block | Approaching the §4.5 firmware ceiling |

Rows that the counter design needed and this one does not: index-advance rate, derivation-store commit latency, and store error rate. Removing monitoring surface is a real benefit — each of those was a metric an operator had to understand to run the system safely.

The first row deserves emphasis: it is a cheap independent recomputation, no existing implementation does it, and it is the only thing that distinguishes "derivation is correct" from "derivation has been paying the wrong index since the last deploy."

## 11. Open questions

1. **A principled recovery-range default.** What index window should miner docs recommend for `importdescriptors`? Derivable from the pool's age and block rate, and now a *documentation* question rather than the correctness question it was under a counter. The old "principled gap-limit default" question — which `para` names as open and sv2-apps ignores — dissolves here rather than getting answered.
2. **Does the mining cookie survive?** §9.5. Highest-value open technical question in this space, and untouched by this revision.
3. **Descriptor rotation by the miner.** Changing descriptors is a ledger-identity migration (`payout_id` changes, so credit must carry across). Unspecified here, and now the main residual state hazard (§10.2).
4. **Per-rig identity for V1 farms.** The Translator carries one `user_identity` per upstream, so a V1 farm behind one Translator is one payout identity (§3.2). Whether per-rig separation is worth a Translator per rig group is an operator question nobody has costed.
5. **Wallet tooling for sparse-index descriptors.** The gap is real and general: no consumer wallet handles "scan these 40 specific indices out of 900,000." Height indexing would be strictly better with it, and it is a plausible contribution to Sparrow or BDK.
6. **Subset-sum against real coinbase payout sets.** The CoinJoin literature transfers by argument; nobody has run the attack on actual coinbase distributions.
7. **Does an `sri/...` payout mode compose with a descriptor identity?** §3.2.1 mandates precedence, not composition. Whether a miner should be able to say "descriptor identity *and* 10% donation" is unspecified, and the current grammar cannot express it.

## 12. Sources consulted

**Wiki articles (12)**
- [[../wiki/concepts/xpub-payout-identity|xpub Payout Identity]] — per-scheme coupling table, the five mechanical changes, firmware ceilings, upstream status
- [[../wiki/concepts/coinbase-address-rotation|Coinbase Address Rotation]] — the `has_wildcard()` guard, the persist-before-return requirement, the anti-pattern in §5.1
- [[../wiki/concepts/pplns-jd|PPLNS-JD / SLICE]] — the positional ledger that makes this an identity-layer-only change
- [[../wiki/concepts/payout-attribution-privacy|Payout Attribution Privacy]] — §9.2, attribution comes from validation not payment
- [[../wiki/concepts/coinbase-amount-linkability|Coinbase Amount Linkability]] — §9.3, the subset-sum argument and the three structural reasons a coinbase is the worst case
- [[../wiki/concepts/lottery-pplns|Lottery-PPLNS]] — hazard #1 (duplicate payout rows), hazard #5 (per-template derivation storm)
- [[../wiki/concepts/tides|TIDES]] — work-issue-time coinbase precomputation, the §7.1 cadence contrast
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

**Direct code read (2026-07-29, this revision)**

Read from the local `sv2-apps-coinbase-rotation` clone while revising, and both findings changed the spec rather than confirming it:

- `stratum-apps/src/payout.rs` — `PayoutMode::try_from` **splits `user_identity` on `/`** for its `sri/solo/<addr>` and `sri/donate/<pct>/<addr>` grammar, and `address_part_from_user_identity()` splits on `.`. A wildcard descriptor contains six `/`. This is §3.2.1, which did not exist before the code read; the saving grace is that the existing code already tries address/descriptor parsing *before* the `/`-split, so the required precedence matches its current shape.
- `miner-apps/translator/src/lib/config.rs` — `Upstream.user_identity` is one string per upstream, documented as "appended with a counter for each mining channel (e.g. `username.miner1`)". This is what makes the V1-via-Translator path work (§3.2) and also what makes a V1 farm behind one Translator a single payout identity.
- `stratum-apps/src/config_helpers/xpub_derivation.rs:140` — `if !descriptor.has_wildcard()`, the guard §3.1 is built on, confirmed present in the branch.

**Gap research (2026-07-29)**
- Sparrow Wallet FAQ — default gap limit 20 (40 postmix), configurable under Settings → Advanced
- BDK `crates/chain/src/indexer/keychain_txout.rs` — `pub const DEFAULT_LOOKAHEAD: u32 = 25`

*Both figures ground §4.2 and §6. In the first draft they were the reason to **reject** height indexing; here they are the reason height indexing **requires** Core-grade recovery tooling and explicit miner documentation. The numbers did not change — the operator's judgment on whether that cost is acceptable did.*

## 13. Revision history

**2026-07-29 (initial)** — per-payout counter, SV2-only intake, finder bonus treated as a live possibility.

**2026-07-29 (this revision)** — three operator decisions, each of which simplified the design:

1. **Height as derivation index** (§4). Deleted the derivation-store section, its four correctness requirements, the halt-don't-degrade failure matrix, three regtest tests, three monitoring metrics, and the never-roll-back-state hazard. Accepted cost: no bare-seed recovery (§4.2), mitigated by documenting exact `bitcoin-cli` commands (§6). Net effect — the riskiest part of the spec became its shortest.
2. **Finder bonus out of scope** (§0, §4.3.1). Makes "exactly one output per miner per block" free rather than a merge requirement to enforce.
3. **V1 miners via the SV2 Translator** (§3.2). Removes the "SV2-only, no V1 path" limitation and the entire firmware field-width problem class, at the cost of one shared payout identity per Translator upstream.

The one thing this revision made *more* complex is §3.2.1, and it came from reading the code rather than from any of the three decisions: `user_identity` already has a `/`-delimited grammar that collides with descriptor syntax.
