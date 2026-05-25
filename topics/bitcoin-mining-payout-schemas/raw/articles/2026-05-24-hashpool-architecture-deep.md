---
title: "hashpool architecture deep-dive — settlement design, mint binary, plugin proposal"
publication: github.com/vnprc/hashpool
url: https://github.com/vnprc/hashpool/blob/master/docs/SETTLEMENT_DESIGN.md
url2: https://github.com/vnprc/hashpool/blob/master/docs/PLUGIN_ARCHITECTURE_PROPOSAL.md
url3: https://github.com/vnprc/hashpool/blob/master/roles/mint/Cargo.toml
type: article
ingested: 2026-05-24
quality: 5
credibility: high
confidence: high
tags: [hashpool, architecture, CDK, mint, settlement, epoch, BlockFound]
---

# hashpool Architecture Deep-Dive

Code-level architecture from the canonical project sources. Companion to the higher-level [[../repos/2026-05-23-hashpool-vnprc|hashpool repo notes]].

## One-liner

**hashpool = SRI 1.7 fork** where the SV2 pool role, instead of crediting an internal share-accounting DB, calls a co-located **CDK 0.16 mint** (extended via the `cdk-ehash` `MintPayment` plugin) over an SV2 Noise channel using the `mint_quote_sv2` subprotocol; the mint blind-signs one ehash token per share, miners optionally bind tokens to **accumulating melt quotes** tied to a BTC address, and on each `BlockFound` event the mint rotates its per-epoch keyset and reconciles the pool-built coinbase against quote balances — preserving a `Σ ehash redemptions = mint reserve increase` solvency invariant **without per-miner accounts**.

## Workspace structure

10 crates in `roles/`:

- `pool` — SV2 pool coordinator
- `translator` — SV2 proxy (V1 down ↔ V2 up), holds the Cashu wallet
- `jd-client` / `jd-server` — Job Declaration
- **`mint`** — co-located CDK Cashu mint
- `web-pool` / `web-proxy` — monitoring dashboards
- `roles-utils`, `test-utils`, `tests-integration`

Production deployment: 11 systemd units managed via `hashpool-ctl`. Each requires Prometheus/VictoriaMetrics scraping `/metrics`.

## `roles/mint/Cargo.toml` dependencies

CDK 0.16.0 stack:
- `cdk`, `cdk-axum`, `cdk-mintd`, `cdk-sqlite` — all pinned 0.16.0
- **`cdk-ehash`** from `forge.anarch.diy/vnprc/cdk-ehash.git` rev `c1a11ba` — ehash-specific logic, NOT in upstream CDK

Local workspace deps:
- `shared_config`, `mint_pool_messaging`, `network_helpers_sv2`, `roles_logic_sv2`
- **`mint_quote_sv2`** (`../../protocols/v2/subprotocols/mint-quote`) — new SV2 subprotocol
- `ehash` (`../../protocols/ehash`)
- `key-utils`

SV2 protocol crates pinned: `codec_sv2 = "5.0.0"`, `noise_sv2 = "1.4.2"`, `mining_sv2 = "9.0.0"`. **Mint speaks SV2 directly to the pool over Noise-encrypted channels** — not HTTP.

Bitcoin signing: `bitcoin = "0.32.2"`, `bip39 = "2.0"`. HTTP wallet API: `axum 0.8`, `hyper 1`, `tower 0.4`. **No `cln`/`lnd` deps** — issue #56 closed Not Planned (Sep 2025); LN integration deferred.

## Settlement design (the canonical payout-schema doc)

From `docs/SETTLEMENT_DESIGN.md`:

### Epoch model

> An epoch = the interval between two consecutive blocks the pool finds. Each epoch has its own ehash currency unit (e.g. `HASH_epoch_42`) backed by a unique CDK keyset.

> When the pool finds a block, the current epoch closes: the keyset rotates, quotes settle, and a new epoch begins.

### Two redemption paths (per-miner choice)

1. **Ecash path (default)**: miners hold ehash as bearer tokens, redeem at the mint for BTC-backed ecash after epoch close.
2. **On-chain path**: miner opens an **accumulating melt quote** with a payout BTC address; tokens are burned into the quote during the epoch.

### Quote state machine

```
CREATED → ACCUMULATING → PAID (address landed in coinbase)
                       → FALLBACK → SETTLED (mint issues ecash)
```

> Burning tokens at contribution time eliminates double-spend by construction.

### `BlockFound` flow (new SV2 message, mint↔pool)

```
Pool sends BlockFound{block_hash, keyset_id, coinbase_tx} to mint
  → mint rotates keyset
  → mint scans coinbase outputs vs accumulating quotes
  → matched quotes go PAID
  → unmatched go FALLBACK
```

Coinbase 100-block maturity is **not required for redemption** since "miners own those outputs as soon as the block is found"; mint uses an intermediate `PENDING_CONFIRMATION` state.

### Solvency invariant (the crux)

Coinbase template = `[Output 0: Miner A → a sats] [Output 1: Miner B → b sats] … [Output N: Mint → X − Σ direct_payouts]`.

> Mint's BTC reserve increase exactly equals ecash-redemption obligations + fallback obligations. **No surplus, no deficit.**

Verification of pool-built coinbase uses NUT-XX / BDK payment processor from CDK as a third-party-payment verifier.

## `cdk-ehash` plugin (forge.anarch.diy/vnprc/cdk-ehash, rev c1a11ba)

NOT a CDK fork — a CDK **plugin**. Implements CDK's `MintPayment` trait, mounted via `MintBuilder::add_payment_processor`.

Core type: **`EhashPaymentProcessor`** — accepts proof-of-work shares as the "payment" that satisfies a mint quote.

4-step mint flow:
1. Quote creation with **header-hash validation** (the share's block-header hash is the receipt)
2. Hashpool share verification
3. Wallet polling for payment status
4. Blinded-signature issuance / token mint

Registers a custom currency unit (`ehash`) and custom payment methods through CDK's builder; `cdk-axum` auto-generates the HTTP endpoints.

Single dep: `cdk-common = 0.16.0`.

**Notable gap**: README has no accumulating-melt-quote or BlockFound code yet — confirming SETTLEMENT_DESIGN.md describes a target state, with parts still to land in this crate.

## Plugin architecture proposal (target state)

From `docs/PLUGIN_ARCHITECTURE_PROPOSAL.md`:

4-layer split:
- `protocols` — framework-agnostic messages
- `shared-utils` — interface traits, no impls
- `plugins` — concrete feature crates
- `roles` — thin orchestrators that load plugins via config and fire hooks

**Pool-side traits**: `AcceptanceHook`, `RewardCalculator`, `StatsProvider`, `WalletBridge`.

**Translator-side**: `SharePreprocessor`, `WalletManager`, `QuoteReceiver`.

Quote dispatch is being moved into a dedicated `ehash-hooks` plugin so the SV2 pool role doesn't hard-depend on Cashu logic. Pluggable reward calculators (linear weighting, proportional, variance-reduction) explicitly enumerated.

## Operational details (Poisson proof consolidation)

From `docs/poisson-proof-consolidation-plan.md`:

- Translator's faucet wallet accumulates Cashu proofs unboundedly. CDK's swap operation has a **1000-proof input ceiling** → without consolidation the wallet wedges.
- Proofs are **P2PK-locked** (`SpendingConditions::new_p2pk`) at mint time — confirms hashpool uses scripted Cashu, not bare proofs.
- Consolidation interval is exponential: `interval_secs = -u.ln() × mean_secs` (memoryless Poisson) plus random subset selection to thwart timing/clustering analysis.

## Public endpoints (production-ish)

- `pool.hashpool.dev`
- `proxy.hashpool.dev`
- `wallet.hashpool.dev` — Cashu wallet SPA served via nginx from `/opt/cashu.me/dist/spa`

(No public testnet4 endpoint documented separately; testnet runs on these endpoints.)

## See also

- [[../repos/2026-05-23-hashpool-vnprc|hashpool repo notes]]
- [[2026-05-24-vnprc-profile|vnprc profile]]
- [[../../wiki/concepts/ehash|eHash concept]]
- [[2026-05-24-cashu-mining-application|Cashu mining application origin]]
