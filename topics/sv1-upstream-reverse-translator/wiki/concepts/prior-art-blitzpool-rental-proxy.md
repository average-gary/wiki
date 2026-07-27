---
title: "Prior art: blitzpool-rental-proxy — the reverse translator, already built"
category: concept
status: active
created: 2026-07-27
updated: 2026-07-27
verified: 2026-07-27
volatility: hot
confidence: high
sources:
  - raw/repos/2026-07-27-blitzpool-rental-proxy-sv2-to-sv1-translator.md
  - raw/repos/2026-05-28-path1-sri-stratum-translation-crate.md
  - raw/repos/2026-05-28-path4-channels-sv2-reuse.md
  - raw/articles/2026-05-28-path1-bitcoin-wiki-difficulty.md
  - raw/articles/2026-05-28-path1-bip-320-nversion-bits.md
tags: [prior-art, existence-proof, blitzpool, rental-proxy, sv2-to-sv1, bidirectional-translator, bdiff, upstream-switching, hashrate-broker, agpl]
summary: "This wiki's 2026-05-28 research concluded the reverse translator was greenfield from a code perspective. That conclusion is false as of 2026-07-27. A working SV2-miner → SV1-pool translator exists, deployed, in Rust, on top of the same SRI crates this wiki planned to use."
---

# Prior art: blitzpool-rental-proxy — the reverse translator, already built

This wiki's 2026-05-28 research concluded the reverse translator was **greenfield from a code perspective**. That conclusion is false as of 2026-07-27. A working SV2-miner → SV1-pool translator exists, deployed, in Rust, on top of the same SRI crates this wiki planned to use.

The implementation is `warioishere/blitzpool-rental-proxy` (crate `stratum-rental-proxy` v0.3.1, AGPL-3.0-or-later, created 2026-06-27 — a month *after* the research that missed it). 0 stars, 0 forks, single author, self-described "Beta. Deployed and running, but still maturing." **Unnoticed, not unbuilt.**

## What it proves and what it does not

| Claim | Status |
|---|---|
| An SV2-miner → SV1-pool translation path can be built on SRI crates | **Proven** — deployed and running |
| `stratum_translation` ships only the SV1→SV2 leg; the inverse must be hand-authored | **Independently confirmed** (see below) |
| `channels_sv2` primitives are reusable unchanged in the reverse direction | **Confirmed** for `merkle_root::merkle_root_from_path` |
| The hashrate-broker segment is real, not aspirational | **Existence proof** — that is this proxy's entire business |
| Upstream switching is a solvable problem | **Solved**, with a cause-dependent two-strategy answer |
| The translation is *correct* | **Unverified** — no test run, no interop check, author says "expect rough edges" |
| The spec gap is closed | **No** — SV2 spec §10.4.5 is still blank, sv2-spec issue #102 still open |

The last two rows matter. This is a code-side existence proof only, and a weakly-validated one: single author, one month old, no community review. It changes "nobody has done this" to "one person has done this and it runs," not to "this is a solved, trusted problem."

## The directional split, verbatim from the source

`src/proto/translate.rs`'s module doc-comment states which direction came from upstream and which the author had to write:

> - **SV1 miner ↔ SV2 pool**: SV2 `NewExtendedMiningJob`+`SetNewPrevHash` become a `mining.notify`, `SetTarget` becomes `mining.set_difficulty`, and a `mining.submit` becomes `SubmitSharesExtended`. **These conversions are provided by `stratum_translation`.**
> - **SV2 miner ↔ SV1 pool**: the inverse, **built here** — `mining.notify` becomes `NewExtendedMiningJob`(+`SetNewPrevHash`), `mining.set_difficulty` becomes `SetTarget`, and `SubmitSharesExtended` becomes a `mining.submit`.

This is an independent confirmation of this wiki's Path-1 finding ([[../../raw/repos/2026-05-28-path1-sri-stratum-translation-crate|stratum-translation crate]]): the helper crate's bidirectionality is *transformation*-direction, not *role*-direction, and the reverse role's helpers do not exist upstream.

All four combinations are claimed working: SV1→SV1 and SV2→SV2 passthrough, plus both translation directions.

## The ~150 LOC estimate was wrong by an order of magnitude

This wiki estimated the missing `stratum_translation` helpers at **~150 LOC** ([[architecture-and-state-machine]] § What needs to be written from scratch; [[../topics/reverse-translator-playbook|playbook]] § Implementation surface). Blitzpool's `translate.rs` is **33 855 bytes** — call it 900–1100 lines.

That is not a like-for-like comparison: `translate.rs` also carries difficulty/target math, the version-rolling mask handling, and probe logic that this wiki assigned to the role binary rather than the helper crate. But the gap is large enough that the estimate should be read as **the floor for three signatures, not the cost of the translation layer**. A realistic figure for "everything a reverse translator must author on the pure-translation side" is closer to 500–1000 LOC.

## Correctness details worth stealing

- **Byte order** — targets are 32-byte **little-endian** per the SV2 spec; the SV1 `mining.notify` prev-hash **per-word swap** is absorbed by the SV1 `PrevHash` newtype, so the SV2 `prev_hash` stays in its natural internal order. This resolves the "must verify per-pool" caveat in [[../reference/sv2-sv1-message-mapping-table|the mapping table]]'s prev_hash row with a concrete convention.
- **Version rolling** — `VERSION_ROLLING_MASK: u32 = 0x1fff_e000`, the default BIP-320 mask, advertised to miners and used to extract rolling bits from a submitted SV2 version field. Matches [[../../raw/articles/2026-05-28-path1-bip-320-nversion-bits|BIP-320]].
- **`channels_sv2` reuse** — imports `stratum_core::channels_sv2::merkle_root::merkle_root_from_path` rather than reimplementing merkle reconstruction, exactly as [[../../raw/repos/2026-05-28-path4-channels-sv2-reuse|Path 4]] recommended.
- **Downstream protocol detection** — `src/proto/detect.rs` classifies each connection on a shared port by **peeking (not consuming) the first byte**: `{`, space, `\n`, `\r` → SV1 JSON-RPC (leniency for miners that lead with whitespace); everything else → SV2 Noise handshake, on the reasoning that "the SV2 adapter's handshake rejects genuine garbage and closes." A TLS `0x16` ClientHello lands in the SV2 bucket by design.
- **Upstream protocol detection** — `UPSTREAM_PROBE_TIMEOUT = 3s`, folded into the connect: the native protocol is attempted first and its socket **reused on success**; only on failure/timeout is the other protocol tried and translation engaged. No standalone prober.

## The difficulty-convention conflict — bdiff, not pdiff

Blitzpool uses Bitcoin **bdiff** (difficulty 1 = the `0x00000000FFFF0000…0000` target), matching `rust-bitcoin`'s `Target::difficulty_float`. Its stated rationale:

> "a miner reads back exactly the difficulty the pool set (no off-by-one), and the threshold the miner sees agrees with the work the proxy credits."

**This contradicts what this wiki currently prescribes.** [[sv2-sv1-primitive-mapping]] and [[../reference/sv2-sv1-message-mapping-table|the mapping table]] both specify `max_target = pdiff_max / difficulty` with `pdiff_max = 0x00000000FFFFFFFF…`, citing pool convention ([[../../raw/articles/2026-05-28-path1-bitcoin-wiki-difficulty|pdiff vs bdiff]]).

The wiki is also **internally inconsistent** on this point: the playbook's prescribed helper is `Target::from_difficulty(f64)` from the `bitcoin` crate — which is bdiff-based — while the mapping tables specify pdiff math. The two cannot both be right.

The numeric spread is ~0.0015% (pdiff_max / bdiff_max ≈ 1.0000152587), so it is invisible in share accounting and cannot cause a valid share to be rejected. It matters for exactly one thing: **round-trip fidelity**. Under bdiff, a miner that converts the received `SetTarget` back to a difficulty reads the same number the pool sent. Under pdiff, it reads a value off by that ratio. Blitzpool's choice is the defensible one, and this wiki's tables should be treated as unresolved until someone checks a real pool's convention against a real miner's readback.

## The upstream-switching problem — a solved treatment

The README calls this "the one hard problem": a new upstream hands out a different extranonce and difficulty. Blitzpool picks the strategy by **cause**, not by mechanism:

| Cause | Strategy | Mechanism | Rationale given |
|---|---|---|---|
| **Operator-initiated** (idle-pool edit, rent start, rent end) | **Force miner reconnect** | Miner re-handshakes cleanly against the new upstream; correct extranonce/difficulty from the first job | "A live re-point a miner might silently ignore would waste every share, so the reconnect is the safe default here." |
| **Automatic failover** (upstream dies mid-session) | **Re-point in place** | SV1: `mining.set_extranonce` + `mining.set_difficulty` + `mining.notify(clean)`, or `client.reconnect` if the miner can't take a live extranonce. SV2: `SetExtranoncePrefix` + `SetTarget`. | "In-place keeps a flapping pool from storming the miner with reconnects." |

Safety-first for intentional changes, continuity-first for unintentional ones. This wiki had catalogued mid-session `mining.set_extranonce` as an unsolved hard problem with "in-flight shares may fail upstream"; the cause-split is the missing design answer, now absorbed into [[architecture-and-state-machine]].

## SV1 upstream means there is no authority key at all

`UpstreamTarget { url, user, password, authority_pubkey: Option<String> }` — the `authority_pubkey` is the pool's Noise authority public key in base58, verified during the upstream handshake. It is **SV2-only** and ignored entirely by the SV1 adapter. The source documents the degraded case explicitly: "when `None`, the link is encrypted but unauthenticated."

An implementation detail that sharpens a wiki claim: [[sv2-features-lost-with-sv1-upstream]] rated authority-bound server identity at egress "lost-but-replaceable (TLS+pinning DIY)." Blitzpool shows the field simply has no SV1 counterpart to populate — the loss is structural in the type, not merely operational.

## Dependency posture — and an SRI packaging defect

SV2 support is feature-gated (`--features sv2`) "so the default SV1 build stays lean," and pulls SRI from **git, not crates.io**:

- `stratum-core` — `git = stratum-mining/stratum`, `branch = "main"`, `features = ["translation"]`
- `stratum-apps` — `git = stratum-mining/sv2-apps`, `rev = 27985c63f7c47310281289d4da17b90780bb11fd`, `features = ["network", "std"]`
- `secp256k1 0.28` matched to `noise_sv2`'s version; `primitive-types 0.13` for the 256-bit division in the bdiff↔target conversion

The stated reason for avoiding crates.io is a concrete defect worth recording for anyone planning this build:

> "the crates.io releases at current majors don't compile together (`mining_sv2`'s derives reference `super::binary_sv2`), whereas the git workspaces are internally consistent."

Practical consequence: **a reverse translator cannot be built against published SRI crates today.** Pin git revs and unify `stratum-core` with `stratum-apps`' transitive copy on the same branch. The `translation` feature is what pulls in `stratum_translation` + `sv1_api`. Network transport comes from `stratum-apps::network_helpers` (`connect_with_noise` / `accept_noise_connection` → `NoiseTcpStream`).

## The surrounding role is a rental broker, not a pool front

The translation is embedded in a hashrate-rental proxy, not shipped standalone. The README's framing of the inversion: "a pool *generates* its own block templates; this proxy *forwards* a miner's work to an upstream of someone else's choosing and measures the delivered hashrate for billing/payout."

A seller registers a miner; while **idle** it mines the seller's own default pool; when a buyer **rents** it, hashrate is rerouted server-side for the duration, then reverts — "the seller never reconfigures the miner." Rented shares and blocks credit the *buyer's* upstream account; the seller earns a rental fee, not the mining reward. Billing quantity is **TH·day** (`HASHES_PER_TH_DAY = 1e12 × 86_400.0`).

Session state is a two-variant enum — `Routing::Idle` (seller's default pool) or `Routing::Rented { order_id }` (buyer target). Hashrate is measured at the wire: `hashrate = Σ(share_diff) × 2^32 / elapsed_seconds` over a rolling window of accepted-share difficulty, with elapsed capped at the window so the estimate is right within about a minute of reconnect, and a `MIN_RATE_SECS = 60.0` divisor floor so one early share can't spike the number. Sampled into 10-minute slots with 7-day retention.

**What transfers to this wiki's use cases**: the translation primitives, the protocol-agnostic-core-with-pluggable-codec-adapters layering (the same shape this wiki's playbook proposed), the detection logic, the switching strategy. **What does not**: rental orders, billing, the seller/buyer economics. This wiki's motivating cases are pool inertia and gradual migration, where the "SV2 stack" is a pool front or miner fleet rather than a broker.

## Consequences for the plan

1. **The upstream-contribution pitch is stronger, not weaker.** A draft PR adding inverse helpers to `stratum_translation` can now cite a working AGPL implementation as evidence of demand — "someone shipped this out-of-tree because the helpers don't exist" is a better argument than "someone might want this." AGPL means the code cannot be copied into MIT/Apache-2.0 SRI, but it can be cited, and its API shape can be studied.
2. **Read the code before writing any.** `translate.rs` is the single highest-value artifact for anyone starting this build — it is the answer key for byte order, difficulty convention, and version-rolling mask handling.
3. **The spec contribution is untouched and now more valuable.** §10.4.5 is still `...`, #102 is still open. There is now a running implementation to describe, which makes filling in the section a documentation exercise rather than a design exercise.
4. **Budget for git-pinned SRI dependencies**, not crates.io versions.

## See also

- [[sv2-spec-issue-102-the-canonical-reference]] — the spec-side gap, which this does *not* close
- [[architecture-and-state-machine]] — absorbed the switching split and the revised LOC figures
- [[sv2-sv1-primitive-mapping]] — the difficulty convention this source disputes
- [[sv2-features-lost-with-sv1-upstream]] — the authority-key row this sharpens
- [[customer-segments-and-tam]] — the hashrate-broker segment this realizes
- [[../topics/reverse-translator-playbook]] — the build path this revises
- [[../reference/sv2-sv1-message-mapping-table]] — prev_hash byte order and difficulty rows affected
- [[../../raw/repos/2026-07-27-blitzpool-rental-proxy-sv2-to-sv1-translator|source: blitzpool-rental-proxy]]
