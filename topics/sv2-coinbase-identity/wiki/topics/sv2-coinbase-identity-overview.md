---
title: "SV2 coinbase identity — overview"
type: topic
created: 2026-05-28
updated: 2026-05-28
confidence: high
tags: [stratum-v2, user_identity, coinbase, miner-tag, pool-tag, SRI, JD]
---

# SV2 coinbase identity — overview

Synthesizes the question: **can the Stratum V2 `user_identity` field on `OpenMiningChannel` be used by the Pool to embed a per-miner unique tag into the coinbase the Pool constructs, *without* invoking Job Declaration?**

The verdict (see [[theses/sv2-coinbase-identity]]) is **Partially Supported (mechanically feasible) — but not the spec's intended use, not currently wired in the SRI reference, and weaker on trust properties than the JD path.**

## The architectural picture

```
                    ┌─────────────────────┐
                    │  Template Provider  │  (bitcoind)
                    └──────────┬──────────┘
                               │ NewTemplate
                               │ (BIP-34 height + outputs)
                               ▼
┌──────────┐ OpenChannel  ┌─────────────────┐  NewMiningJob
│ Miner /  │─────────────▶│   SV2 Pool      │─(merkle_root only)──▶ Standard ch.
│ Proxy /  │ user_identity│                 │  NewExtendedMiningJob
│ JDC      │              │  JobFactory     │─(coinbase_prefix +    Extended ch.
└──────────┘              │  ╭─────────╮    │   coinbase_suffix)
                          │  │/pool//  │ ←─ │  miner_tag = None today
                          │  ╰─────────╯    │
                          └─────────────────┘
                          ▲ thesis seam: feed user_identity → miner_tag
```

## Three answers in one

| Question | Answer |
|---|---|
| Does the spec **prescribe** that `user_identity` flows into coinbase bytes? | **No.** Spec scopes it to identification/auth. |
| Does the spec **forbid** a Pool from doing so unilaterally? | **No.** Pool controls its own coinbase prefix/suffix. |
| Does the SRI reference impl **already do it**? | **No** — but the slot, byte budget, scriptSig serializer, and parameter all exist. The non-JD `new_for_pool` constructor passes `miner_tag = None`. Wiring `user_identity` into that slot is a one-line change. |

## Trust comparison
- Thesis form (Pool-side, non-JD): trusting attribution. Miner has no cryptographic guarantee the Pool inserted the right tag.
- JD form: non-custodial / verifiable. Miner builds its own coinbase. This is what [[OCEAN's DATUM Gateway|raw/articles/2026-05-28-ocean-datum-gateway-coinbase-tagging]] ships in production.

## Constituent concepts
- [[wiki/concepts/user_identity-field]]
- [[wiki/concepts/sv2-coinbase-scriptsig-layout]]
- [[wiki/concepts/job-factory-and-coinbase-construction]]
- [[wiki/concepts/coinbase-ownership-pool-vs-jdc]]
- [[wiki/concepts/extension-0x0002-worker-tracking-tlv]]

## See also
- [[theses/sv2-coinbase-identity]] — full thesis with verdict
- Cross-topic: [[../../sv2-p2pool-integration|sv2-p2pool-integration]] (`share-accounting-mapping` references `user_identity`)
- Cross-topic: [[../../bitcoin-mining-payout-schemas|bitcoin-mining-payout-schemas]] (DATUM is in the OCEAN payout-schema discussion)
