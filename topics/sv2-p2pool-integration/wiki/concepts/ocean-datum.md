---
title: OCEAN DATUM
type: concept
created: 2026-05-22
updated: 2026-05-22
verified: 2026-05-22
volatility: warm
confidence: high
sources:
  - "[[raw/articles/2026-05-22-ocean-datum-overview|OCEAN DATUM overview]]"
  - "[[raw/articles/2026-05-22-ocean-tides-payout|OCEAN TIDES payout]]"
  - "[[raw/data/2026-05-22-pool-concentration-snapshot|Pool concentration data]]"
---

# OCEAN DATUM

DATUM (Decentralized Alternative Templates for Universal Mining) is OCEAN's production-deployed protocol for decentralized template construction. It is the **existence proof** that miners will adopt a non-custodial decentralized-template pool — and the **counterexample** that you can do it without SV2.

## Pitch

> Built from scratch with decentralized template construction in mind.

OCEAN's framing positioned DATUM as an alternative to SV2 because *"Sv2 wouldn't be a viable solution in the near term"* (2024 framing). They built on V1 to ship.

## Architecture

- Miners run a **DATUM gateway** + **local bitcoind**
- Gateway distributes work generated only from local node templates
- Coinbase payouts go directly to miners "instantaneously and without custodial oversight"
- Pool wallet does not hold funds (non-custodial)
- Future direction: pool becomes "almost completely blinded" to template contents

## Wire protocol

**Stratum V1 + version-rolling (ASICBoost)**, NOT SV2.

- Acknowledges V1's inability to retract previously-accepted work as a known limitation
- Explicit pragmatic tradeoff: V1's deployable-today reality > SV2's protocol elegance

## Reference implementation

`github.com/OCEAN-xyz/datum_gateway`:
- bitcoind via standard `getblocktemplate` RPC + `blocknotify`
- Zero Bitcoin Core patches required
- Pool currently validates blocks during beta

## Payout: TIDES

> TIDES is what PPLNS was originally supposed to be.

- Active window = **8× current block difficulty in shares**
- Window slides per block; each share averages ~8 payouts over its lifetime
- `Reward = (miner_shares_in_window / total_window_shares) × block_reward`
- Share log append-only, never truncated

## Adoption snapshot (2026-05-22)

- OCEAN pool hashrate: 17.5–28.27 EH/s (sources disagree on averaging window)
- ~1.7%–2.9% of network — small but non-zero
- Top miner controls **22.97% of OCEAN's pool hashrate** — significant intra-pool concentration even at the decentralization-focused pool
- DATUM adoption % among OCEAN miners: **not published**

## Differences vs p2poolv2

| Dimension | OCEAN DATUM | p2poolv2 |
|---|---|---|
| Wire | SV1 + version rolling | SV1 today, SV2 future |
| Templates | Decentralized (per-miner local bitcoind) | Decentralized (each p2poolv2 node has own bitcoind) |
| Share accounting | Centralized (OCEAN tracks via TIDES) | Decentralized (peer-to-peer share chain) |
| Payout | Direct coinbase via TIDES | Direct coinbase to top-N + atomic swaps |
| Live? | Yes, in production | Pre-production |

The key architectural difference: **DATUM keeps share accounting centralized at the pool**; p2poolv2 makes share accounting itself a P2P consensus problem. (See [[p2poolv2#differentiation-from-sv2--datum|p2poolv2 framing]].)

## Implication for p2poolv2 + SV2

DATUM proves decentralized templating is achievable on V1 today. p2poolv2's bet is that SV2 is the right long-term protocol layer — but DATUM is the existence proof that miners will deploy a production pool that stays on V1 if SV2 ships too late.

## See also

- [[p2poolv2]]
- [[braidpool]]
- [[../topics/why-decentralized-pools-struggle|Why decentralized pools struggle]]
