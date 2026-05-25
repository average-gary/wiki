---
title: "PioneerHash/e-sharp — the canonical eHash workspace (deep-dive)"
publication: github.com/PioneerHash/e-sharp
url: https://github.com/PioneerHash/e-sharp
type: article
ingested: 2026-05-25
quality: 5
credibility: high
confidence: high
tags: [e-sharp, PioneerHash, EthnTuttle, eHash, JDC, Cashu, sub-pool, canonical]
---

# e-sharp — The Canonical eHash Workspace

PioneerHash/e-sharp is **not "another eHash repo"** — it is the canonical, materially-more-advanced implementation of the eHash design. It supersedes vnprc/hashpool's testnet4-only state on multiple dimensions: shipped code, formal specs, dual-mode (solo + pool) operation, and active development cadence.

## Identity

- **Repo**: https://github.com/PioneerHash/e-sharp
- **Created**: 2026-01-07
- **Last commit**: 2026-05-18 (active, daily commits in May 2026)
- **License**: MIT OR Apache-2.0
- **Default branch**: `master` (only branch)
- **Size**: 763 KB
- **Total issues**: 29 (open + closed; 0 PRs ever — same "issue-driven, zero PRs" signature as EthnTuttle's other work)
- **Render**: e# (the README literally writes the directory tree as `e#/`)

## CLAUDE.md self-description

> *"ehash is a system for issuing ecash tokens (Cashu) for mining shares using Stratum V2. Miners receive ehash tokens proportional to their contributed work, which can later be redeemed when payouts occur."*

## Workspace structure (7 crates + 4 fork submodules)

```
e#/
├── crates/
│   ├── ehash-core/       # Core types: EhashPubkey, bech32 "hpub" encoding
│   ├── ehash-sv2/        # Sv2 message protocol for JDC↔mint communication
│   ├── ehash-mint/       # Ecash mint daemon for share issuance
│   ├── ehash-dev/        # Development environment orchestrator
│   ├── ehash-cli/        # CLI wallet: quotes, minting, melt, send/receive
│   ├── ehash-tests/      # E2E and integration tests
│   └── portalloc/        # Dynamic port allocation for tests
├── forks/
│   ├── stratum/          # PioneerHash/stratum fork (submodule)
│   ├── sv2-apps/         # PioneerHash/sv2-apps fork (submodule)
│   ├── cdk/              # PioneerHash/cdk fork (submodule)
│   └── mujina/           # PioneerHash/mujina fork (submodule)
├── specs/
│   ├── sv2-messages.md
│   └── keyset-lifecycle.md
├── justfile
└── flake.nix
```

Workspace `Cargo.toml` (4787 bytes) uses **`[patch]` overrides** to redirect every Stratum V2 + CDK dependency to the submoduled forks. Rust toolchain pinned to 1.85+. CDK from `PioneerHash/cdk` branch `main`.

## Architectural inversion: JDC as Sub-Pool

This is the design's headline. e-sharp positions the **Job Declarator Client (JDC) as a "sub-pool"** that issues eHash tokens, with the upstream Pool remaining a vanilla SV2 pool.

### Pool mining mode (normal)

```
[Miners] → [Translator] → [ehash JDC] → [Vanilla Pool] → [Bitcoin Network]
                              ↓
                        ShareReport
                              ↓
                        [ehash-mint]
                              ↑
                    LN/on-chain payments
                   (trigger keyset lifecycle)
```

**Key principle**: the upstream pool needs **zero modifications**. JDC handles all eHash logic. Works with **any Stratum V2 pool**.

Keyset lifecycle is triggered by LN payments (or manual on-chain funding), NOT by block-finding (because in pool mode, the pool gets the coinbase, not the JDC).

### Solo mining mode (fallback)

```
[Miners] → [Translator] → [ehash JDC] → [Template Provider] → [Bitcoin Network]
                              ↓
                  ShareReport + BlockFoundReport
                     + ChainTipUpdate
                              ↓
                        [ehash-mint]
                   (coinbase-based lifecycle)
```

In solo mode: JDC connects to Template Provider directly, sends `BlockFoundReport` when a block lands, sends `ChainTipUpdate` for confirmation tracking (100 blocks). Keyset lifecycle uses coinbase rewards.

**Automatic fallback/reconnect** when Pool availability changes — `JdMode::SoloMining` ↔ `JdMode::PoolMining`.

## Sv2 Extension Protocol (extension type 0x0100)

Five new SV2 messages (transport: Noise NX handshake, encoding: little-endian binary, fire-and-forget no-ACK):

| Code | Name | Direction | Size | Modes |
|---|---|---|---|---|
| 0x00 | `ShareReport` | JDC → Mint | 73 B | Both |
| 0x01 | `BlockFoundReport` | JDC → Mint | 73 B | **Solo only** |
| 0x02 | `RegisterChannelPubkey` | Translator → JDC | 37 B | Both |
| 0x03 | `ChainTipUpdate` | JDC → Mint | 40 B | **Solo only** |
| 0x04 | `MintConnectionSetup` | Mint → JDC | variable | Solo only |

### `ShareReport` (73 B)

```
pubkey            33 B  (compressed secp256k1, miner's hpub)
share_hash        32 B  (SHA256d of share, deduplication)
difficulty_ratio   8 B  (f64: share_difficulty / network_difficulty)
```

### `BlockFoundReport` (73 B)

Identical wire format to `ShareReport`. The **message-type byte** (0x01 vs 0x00) encodes the block-found status. On receipt, the mint:

1. Creates a quote with the **block bonus multiplier** applied
2. Triggers keyset rotation (ACTIVE → CALCULATING)
3. Records the block for confirmation tracking

### `MintConnectionSetup` (Mint → JDC)

The mint sends its **LDK on-chain wallet `scriptPubKey`** to the JDC after the Noise handshake. JDC uses this as the coinbase output for solo-mining block templates. Generated fresh per connection via `onchain_payment().new_address()`.

> *"The static `coinbase_reward_script` config field is removed from the JDC configuration when `ehash_mint` is enabled. The mint is the sole authority for the coinbase address."*

This is genuinely novel: **the mint becomes the coinbase-address authority**, not the miner or the pool.

## Keyset Lifecycle State Machine

```
                         [Block Found]
ACTIVE ─────────────────────────────────────────> CALCULATING
   │                                                   │
   │                                                   │ [Orphaned]
   │                                                   v
   │                                               ORPHANED ──┐
   │                                                   ^      │
   │                                                   │      │ [chain]
   │                                                   └──────┘
   │ [LN Payment ≥ threshold]                          │
   │                                                   │ [100 blocks OR instant for LN]
   └────────────────> CALCULATING ─────────────────────┴──> MELTING ──> EXPIRED
                      (instant for LN)                         │
                                                               │ [timeout]
                                                               v
                                                           EXPIRED
```

### State definitions

- **ACTIVE**: only one keyset is ACTIVE at a time. Mint issues new tokens against this keyset. Tracks `total_issued_ehash`.
- **CALCULATING**: computing payout ratio. For block trigger: waiting for 100 confirmations + coinbase value query. For LN trigger: instant. Calculates `ehash_to_sat_ratio = (available_sats - fee) / total_ehash`.
- **ORPHANED**: block was orphaned (detected via reorg). **Tokens bucket with next confirmed block.** Chained orphans accumulate until a block confirms; all orphaned keysets in bucket share the next block's payout.
- **MELTING**: users redeem tokens for sats at fixed ratio. Time-limited window (default **2 weeks** = 1,209,600 secs). Tracks remaining `available_sats` and `redeemed_ehash`.
- **EXPIRED**: redemption window closed. **Unredeemed tokens forfeited**. Unredeemed sats returned to pool/operator.

### Configuration constants (defaults)

| Param | Default | Purpose |
|---|---|---|
| `coinbase_maturity_blocks` | **100** | Bitcoin consensus |
| `melting_duration_secs` | **2 weeks** | Window for redemption |
| `ln_liquidity_threshold_sats` | **1,000,000** (1M sats) | Min LN payment to trigger keyset rotation |
| `mint_fee_percent` | **2.0%** | Deducted before ratio calc |
| `default_min_melt_sats` | **1,000** | Min melt amount per keyset |
| `state_check_interval_secs` | **60** | State-transition check cadence |

### Two payout triggers (the design's central novelty)

1. **Block found** → 100-block coinbase maturity → coinbase value queried → MELTING
2. **LN payment ≥ threshold** → instant CALCULATING → instant MELTING

So eHash tokens **mature on either pool-side block-finds OR LN inflows**, decoupling the redemption clock from network-block cadence. This is structurally different from vnprc/hashpool's epoch model (which is strictly per-block).

## Orphan handling

**Bucket chaining.** When a block orphans:

1. The keyset enters ORPHANED state with the original block hash
2. Tokens stay valid; their redemption value is *bucketed* with the next confirmed block
3. Chained orphans accumulate (rare — usually 1-2 deep at most)
4. All orphaned keysets in the bucket **share the next confirmed block's payout pro-rata**

This is the **first published mining-payout scheme to formalize orphan handling at the accounting layer** — vnprc/hashpool's design does not. (Per spec `specs/orphan-detection-ldk-melt.md` referenced from CLAUDE.md.)

## Test maturity (massive lead vs vnprc/hashpool)

Recent commit titles establish the test surface:

- `test(p0): add three P0 E2E tests for critical production invariants` (2026-05-13)
- `test(ehash-tests): JDC disconnect/reconnect E2E test` (2026-05-07)
- `test(ehash-tests, ehash-mint, ehash-dev): solo mining + orphan detection E2E tests` (2026-04-17)
- `test(ehash-tests, ehash-dev): Solo Mining E2E test` (2026-04-03)
- `feat(e2e-tests): keyset expiry E2E test + configurable melting duration` (2026-04-02)
- `feat(e2e-tests, ehash-dev): complete E2E melt flow test` (2026-04-02)
- `test(ehash-mint): duplicate share rejection unit test` (2026-04-17)

**Real E2E tests against an LDK Lightning node + LND + CLN**, plus orphan detection and keyset-expiry tests. vnprc/hashpool's `cdk-ehash` plugin has 4 integration tests that exercise only the in-memory CDK mint.

## Lightning integration: actually shipped

Recent commits show **real LDK ↔ LND ↔ CLN integration** for the LN-payment payout trigger:

- `fix(ehash-dev): LND opens channel to LDK instead of LDK→LND` (2026-04-02)
- `fix(ehash-dev): wait for LND funding manager before opening channel`
- `fix(ehash-dev): filter LDK channel active check by LND peer pubkey`
- `feat(ehash-tests, ehash-dev): use LND invoice for melt to avoid LDK→CLN routing failures`

This contrasts with vnprc/hashpool: **no LN deps in `roles/mint/Cargo.toml`** (issue #56 closed Not Planned, Sep 2025). e-sharp ships LN.

## CLI wallet (real, working)

```
ehash wallet show              # Display wallet pubkey
ehash quotes list              # List quotes from the mint
ehash mint --all               # Mint tokens from paid quotes
ehash balance                  # Check token balance
ehash send 100                 # Send 100 ehash (outputs token)
ehash receive <token>          # Receive a Cashu token
ehash melt list                # List meltable keysets
ehash melt preview 1000        # Preview melt conversion
ehash melt pay <bolt11>        # Pay Lightning invoice with ehash
```

vnprc/hashpool: no first-class user-facing CLI wallet of comparable surface.

## Comparison: e-sharp vs vnprc/hashpool

| Property | vnprc/hashpool | **PioneerHash/e-sharp** |
|---|---|---|
| Status | testnet4 PoC, v0.1.1 | **Active dev, daily commits** |
| Tag cadence | ~12 months between v0.1 and v0.1.1 | Continuous (no formal tags yet) |
| Architecture | SRI fork with co-located mint | **JDC-as-sub-pool, vanilla pool compatible** |
| Solo mining | Not first-class | **First-class, automatic fallback** |
| LN integration | None (#56 Not Planned) | **LDK + LND + CLN, shipped + tested** |
| Orphan handling | Not designed | **Bucket-chaining, formal spec + E2E tests** |
| Payout triggers | Block-find only (epoch model) | **Block OR LN payment ≥ threshold** |
| Spec docs | SETTLEMENT_DESIGN.md (target-state) | **specs/keyset-lifecycle.md + sv2-messages.md (shipped)** |
| Test surface | 4 in-memory mint integration tests | **Multiple P0 E2E tests against real LDK/LND/CLN** |
| Mint coinbase authority | Pool controls | **Mint controls (via MintConnectionSetup)** |
| CLI | Cashu wallet SPA via nginx | **First-class `ehash` CLI** |
| `BlockFoundReport` SV2 message | Absent | **Implemented (0x01, 73 B)** |

## Implication: a parallel canonical implementation

vnprc/hashpool is the original implementation; **e-sharp is the more advanced one**. The wiki must update:

1. **eHash concept article** — update from "vnprc is the implementer" to "vnprc is the original implementer; PioneerHash/e-sharp is the now-canonical workspace led by EthnTuttle."
2. **PioneerHash org article** — `e-sharp` is no longer "possibly a successor / related lib" — it IS the successor.
3. **The hashpool architecture deep-dive** — relabel as "vnprc/hashpool architecture" to disambiguate from e-sharp.
4. **Critiques article** — many of the 12 critiques (LN liveness, no orphan handling, no real CLI, no E2E tests) **are addressed in e-sharp** but **not in vnprc/hashpool**. The wiki was rating the project on its older code.

## Open questions

1. **Why two parallel codebases?** vnprc and EthnTuttle co-architected hashpool (vnprc commits, EthnTuttle issues #2-#33). e-sharp emerged 6+ months later in a separate org with EthnTuttle's signature design choices (JDC-as-sub-pool, dual-trigger lifecycle). Was this a fork, a planned reimplementation, or a soft schism?
2. **Will vnprc/hashpool keep developing?** Tag cadence (12mo gap) suggests it's quasi-maintained.
3. **Is e-sharp running anywhere publicly?** No `pool.e-sharp.dev` or equivalent endpoint identified yet. Status board: [PioneerHash Roadmap project board](https://github.com/orgs/PioneerHash/projects/2).
4. **Does Calle (Cashu creator) endorse e-sharp's design?** His t/870 endorsement was for vnprc-flavored eHash; the JDC-sub-pool reframing post-dates that thread.

## Sources

- https://github.com/PioneerHash/e-sharp (canonical)
- `Cargo.toml`, `CLAUDE.md`, `specs/keyset-lifecycle.md`, `specs/sv2-messages.md`
- Commit log April-May 2026 (28+ commits)
- https://github.com/orgs/PioneerHash/projects/2 (roadmap board, referenced from CLAUDE.md)

## See also

- [[2026-05-24-pioneerhash-org|PioneerHash org overview]] — needs update
- [[2026-05-24-ethntuttle-profile|EthnTuttle profile]] — needs update
- [[2026-05-24-cdk-ehash-code-state|cdk-ehash plugin]] — for contrast (vnprc-side, dormant)
- [[2026-05-24-hashpool-architecture-deep|vnprc/hashpool architecture]] — for contrast
- [[../../wiki/concepts/ehash|eHash concept]] — needs major update
