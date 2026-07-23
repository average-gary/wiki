---
title: splice-lightning-channel-in-coinbase — raw papers index
type: raw-index
---

# Raw: papers (8)

- [[2026-07-23-bolt2-splicing-and-coinbase-funding]] — BOLT #2 splicing spec + the `channel_ready` coinbase-funding rule. **[spec, high]** Reading A✗ / B~ / C✓.
- [[2026-07-23-bip34-block-height-in-coinbase]] — BIP-34 height in coinbase scriptSig. **[spec, high]** Reinforces Reading A✗.
- [[2026-07-23-bip141-coinbase-witness-commitment]] — BIP-141 coinbase witness commitment + structure. **[spec, high]** Structural.
- [[2026-07-23-bip118-sighash-anyprevout]] — BIP-118 APO/APOAS (the presigning wall & its non-activated relaxation). **[spec, high]** A/B.
- [[2026-07-23-bolt2-splice-balance-direction]] — BOLT #2 splice balance direction: `funding_contribution_satoshis` credits the SENDER'S OWN side (verified verbatim). **[spec, high]** Follow-up #3 — the inbound/outbound category error.
- [[2026-07-23-bolt12-offers]] — BOLT #12 reusable offers: the OCEAN payout rail; receiving consumes inbound. **[spec, high]** Follow-up #3.
- [[2026-07-23-blip52-jit-and-pushmsat-omitted]] — `push_msat` OMITTED from `open_channel2` (verbatim) + bLIP-52/LSPS2 JIT fee-from-payment fusion (verbatim). **[spec, high]** Follow-up #3 (thesis 3) — the two load-bearing facts: no single tx carries inbound+value; JIT is the one genuine fusion.
- [[2026-07-23-blip36-on-the-fly-funding]] — bLIP-36 on-the-fly funding: funder creates on-chain tx (dual-fund OR splice) toward a recipient lacking inbound, fee from the relayed payment. **[spec-draft, high]** Follow-up #3 — strongest FOR the mechanism.
