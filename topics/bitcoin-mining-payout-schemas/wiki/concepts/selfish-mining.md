---
title: Selfish Mining
category: concept
created: 2026-05-23
confidence: high
tags: [selfish-mining, attack, Eyal, Sirer, Sapirshtein, threshold]
volatility: warm
updated: 2026-07-15
verified: 2026-07-15
sources:
  - "raw/papers/2026-05-23-eyal-sirer-2014-selfish-mining.md"
---

# Selfish Mining

Pool-vs-network attack distinct from BWH/FAW. A miner with sufficient hashrate mines on a private chain and selectively releases blocks to make their chain longer than the public chain — orphaning honest miners' work and capturing more than their proportional share of block rewards.

## Origin

Eyal & Sirer 2014, *"Majority is Not Enough: Bitcoin Mining is Vulnerable"* — Financial Cryptography 2014, also CACM 2018.

## Threshold (Eyal & Sirer)

Attacker is profitable when:

`(1−γ)/(3−2γ) < α < 1/2`

Where:
- `α` = attacker's fraction of network hashrate.
- `γ` = fraction of honest network mining on the attacker's branch when there's a tie (network propagation advantage).

| γ | Threshold α |
|---|---|
| 0 (no tie advantage) | **1/3 (33.3%)** |
| 0.5 | **1/4 (25%)** |
| ~1 (full tie advantage) | **~0%** |

## Optimal selfish mining (Sapirshtein, Sompolinsky, Zohar 2016)

Reframes as MDP, finds ε-optimal policies that **lower the threshold below SM1**:

- γ = 0 → ~**0.2321** (vs Eyal's 1/3)
- γ = 1 → 0

So even a **23% attacker can profit under optimal selfish mining**. Adds combined selfish-mining + double-spend analysis.

## Payout-scheme interaction

**Eyal/Sirer assume proportional distribution; they do NOT distinguish PPS / PPLNS / FPPS.** The model is pool-vs-network, not within-pool.

The paper's Section 8 ("Practical Considerations") discusses propagation/γ, NOT payout scheme variants. **No formal selfish-mining-vs-payout-scheme analysis exists in the canonical literature** — this is a genuine gap in the field.

Same incidence-vs-profit asymmetry as [[block-withholding|BWH/FAW]]:

- Attacker profit is scheme-invariant (selfish mining captures block rewards directly).
- **Incidence at the victim pool is scheme-dependent**: FPPS pool eats the orphan-loss (operator pays miners regardless); PPLNS-class miners eat the orphan-loss directly.

## Has it happened?

**Empirically: rare.** Suspected episodes (Bitmain ~2014, certain Asian-pool clusters in 2016) but no widely-attested production-scale incident in Bitcoin. Hashrate concentration plus γ-asymmetric network advantage would be needed; the major pools' reputational cost likely outweighs the marginal revenue.

**Persistent threat at high concentration.** [[../topics/decentralization-and-pool-concentration|b10c 2025]] shows Foundry alone at ~31% — already at the Eyal threshold. Combined with proxy-pool template-relaying (~40% AntPool & friends), the **theoretical threshold for profitable selfish mining is being crossed today** — but mitigated by reputational/coordination costs.

## Mitigation

- **Random tie-breaking** (Eyal & Sirer's own proposal): forces γ → 0.5 → threshold up to 25%.
- **Uniform-tie-breaking** (Bitcoin Core implements): each node picks a random tie-winner. Doesn't fully fix but raises threshold.
- **Hashrate decentralization**: most effective long-term mitigation.
- **No deployed cryptographic mitigation** for the underlying attack as of 2026.

## Sources

- [[../../raw/papers/2026-05-23-eyal-sirer-2014-selfish-mining|Eyal & Sirer 2014 — Majority is Not Enough]]
- Sapirshtein, Sompolinsky, Zohar 2016 — *Optimal Selfish Mining Strategies in Bitcoin* (FC 2016, arXiv:1507.06183)

## See also

- [[block-withholding|Block Withholding & FAW]]
- [[../topics/decentralization-and-pool-concentration|Decentralization & Pool Concentration]]
