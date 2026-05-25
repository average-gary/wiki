---
title: "btc++ conference talks on hashpool / mining-payout decentralization"
publication: bitcoin++ conference (btcplusplus.dev)
url: https://hashpool.dev/media/
type: video
ingested: 2026-05-23
quality: 5
credibility: high
confidence: high
tags: [btc++, hashpool, vnprc, ecash, conference, video]
---

# btc++ Conference Talks — Mining Payout / Ecash

vnprc (creator of hashpool) is the dominant figure for payout/accounting talks in the 2024-2025 btc++ circuit. Other named figures (Filippo Merli, Calle, Luke Dashjr) have **not** surfaced btc++-specific recorded talks on payout schemes — likely because btc++ Riga 2025 was privacy-edition and Austin 2024 was script-edition, not mining-edition.

## 1. "Hashpools — A New Kind of Mining Pool Powered by Ecash"

- **Speaker**: vnprc (creator of hashpool)
- **Event**: bitcoin++ Berlin, October 2024 (e-cash edition)
- **URL**: https://www.youtube.com/watch?v=SeydWRNjH_Y
- **Quality**: 5/5

Foundational talk launching hashpool publicly.

- Replaces traditional pool share-accounting database with Cashu-style ecash mints.
- Miners receive blinded "eHash" tokens for shares submitted.
- Pool operator does not need a custodial liability ledger of miner balances — issued tokens are bearer claims.
- Decentralizes payout trust: ecash mint signs share-value tokens, redeemable when blocks are found, removing operator's ability to selectively withhold.

## 2. "Proxy Pools — Harness the Free Market to Decentralize Bitcoin Mining"

- **Speaker**: vnprc
- **Event**: bitcoin++ Austin, May 2025 (mempool edition) — POOLIN' STAGE Day 2
- **URL**: https://www.youtube.com/watch?v=F2p_V0svDTo&t=3h15m30s
- **Quality**: 5/5

Follow-up to Berlin 2024.

- Proxy pools sit between miners and traditional pools, splitting hashrate across pools and rewriting payout/accounting flows.
- Argues market competition between proxy operators (rather than a single pool monopoly) drives decentralization of payout trust.
- Treats payout accounting as a service layer that can be unbundled from block-template construction.
- Positions hashpool as one implementation of the proxy-pool pattern.

## 3. "Hashpools — One Year Development Update"

- **Speaker**: vnprc
- **Event**: bitcoin++ Durham, NC, November 15, 2025 (local edition)
- **URL**: Listed at https://hashpool.dev/media/ (Durham playlist on @btcplusplus YouTube channel; direct link not surfaced via fetch)
- **Quality**: 4/5

One-year retrospective on hashpool's Cashu-mint-based share accounting.

- Status of eHash token mechanism, mint federation, PPLNS-compatible payout math.
- Likely covers Stratum V2 / Job Declaration integration progress.

## Companion source (not btc++ but referenced)

**Stephan Livera Podcast 681** — "eCash & eHash: The Hashpool Solution" — August 5, 2025, https://stephanlivera.com/episode/681/. Long-form interview with vnprc that explicitly references the two btc++ talks. Useful for "what was claimed" expansion.

## What's NOT here

- No standalone btc++ talks for **Calle (Cashu)** on mining-specific ecash use.
- No standalone btc++ talks for **Filippo Merli / DMND / SLICE**.
- No standalone btc++ talks for **Luke Dashjr / OCEAN / TIDES**.
- No standalone btc++ talks for **Pavel Moravec / Braiins**.

btc++ Riga 2025 was privacy-edition (no mining track); Austin 2024 was script-edition. The "mining edition" of btc++ has not yet happened (as of 2026-05) — most mining content surfaces at btc++ via cross-track talks. **Recommend monitoring for a future mining edition** as the natural venue for SLICE / TIDES / DATUM technical deep-dives.

## See also

- [[../repos/2026-05-23-hashpool-vnprc|hashpool repo]]
- [[../../wiki/concepts/ehash|eHash concept]]
