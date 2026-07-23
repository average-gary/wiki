---
title: Theses — index
type: wiki-index
---

# Theses (3)

- [[../../theses/splice-lightning-channel-in-coinbase|Thesis: I can splice a lightning channel in a coinbase transaction]] — verdict: **Mixed / High** (A Contradicted · B Not viable · C Supported)
- [[../../theses/splice-in-vs-bolt12-miner-liquidity|Thesis (follow-up #3a): splice-in matured coinbase vs OCEAN BOLT12 payouts]] — verdict: **Contradicted (as stated) / Mixed (reframed) · High** — "inbound liquidity" is a category error (splice-in → outbound; receiving → consumes inbound); reframed to outbound it's condition-dependent; the two are complementary.
- [[../../theses/pool-provisions-miner-inbound-via-splice|Thesis (follow-up #3b): pool provisions miner inbound via toward-miner splices]] — verdict: **Partially Supported · High** — mechanism real & deployed (as wallet-LSP: bLIP-36/52, Phoenix/eclair #2861); literal "funds on pool's side = payout" is a category error (`push_msat` omitted from `open_channel2`); JIT/on-the-fly is the one genuine fusion; a mining pool doing it is unbuilt.
