---
title: "Reverse-translator customer segments — honest TAM read"
source: synthesis across Path 5 sources
type: articles
tags: [tam, customer-fit, business-motivation, market-sizing]
summary: "The credible 2026 customer for a reverse translator is the SRI dev community itself, not commercial mining ops. Production deployment numbers in 2026 are likely single digits. TAM grows only if (a) Foundry/Antpool announce a >18-month-out SV2 timeline or (b) a hashrate broker launches SV2-front routing as a differentiator."
confidence: high
ingested: 2026-05-28
ingested_by: path5
quality_score: 4
---

# Customer segments — honest TAM read

## Per-hypothesis verdict (from Path 5)

| # | Hypothesis | Verdict | Strongest evidence |
|---|---|---|---|
| 1 | Pool inertia (large pools still SV1 in 2026) | **Supported** | Top-5 pools = 77.7%, none SV2-native; DEMAND still uniquely markets as "first SV2 pool" |
| 2 | Gradual migration tooling demand | **Supported** | Sjors's bio recruiting + dmnd-easy-sv2 lib + forward translator normalizes the bridge pattern |
| 3 | Hashrate brokers fanning SV2-front to SV1 backends | **Unclear, leaning aspirational** | Luxor has business case but zero public SV2 work |
| 4 | SV2 firmware fleet → SV1 payout pool | **Supported by inference** | BraiinsOS has shipped SV2 firmware for years; top destinations are SV1 |
| 5 | Ecash/hashpool settlement bridges with SV1 upstream | **Refuted in present, possible future** | hashpool runs its own SV2 pool, not on top of an SV1 upstream |
| 6 | Censorship-resistance / MEV preserved with reverse translator | **Mostly refuted as marketing** | Pool still constructs the actual block template when upstream is SV1 |
| 7 | Testing / dev tooling demand | **Supported** | SRI is alpha, no reverse translator exists, every dev testing against a real pool today writes one-offs |

## Customer ranking (most realistic first)

1. **SRI/SV2 ecosystem developers** — strategic value very high, paying customer count zero. Without this tool, SV2 stack development can only be tested against SRI's own pool role on regtest, or DEMAND. *Path of least resistance first user.*
2. **Hashpool / Cashu mining-mint experimenters** — small, motivated, non-paying. A "mint-as-a-service" variant issuing eHash backed by another pool's PPLNS payout would need this. ~1–3 hobbyist projects in 2026.
3. **Mid-size mining operators running BraiinsOS / SV2 firmware paid out by Foundry/Antpool/F2Pool** — largest *theoretical* TAM by hashrate, smallest *active* demand. Operators today downgrade firmware to SV1 client mode rather than running an extra proxy service.
4. **Hashrate brokers (Luxor, NiceHash, OKMiner)** — architectural fit, no commercial pull. 2027–2028 customer.
5. **Solo miners / OCEAN customers / p2pool** — *not* customers; they want to avoid centralized pools, not bridge to them.

## Bottom line

The reverse translator is **developer tool first, production component second**. The strongest reason to build it now is not market size — it is that without it, the SV2 ecosystem cannot be exercised against the actual production hashrate landscape, which keeps SV2 itself in dev-loop purgatory. **Public-good plumbing more than a commercial product.**

## What would change this read

- Foundry or Antpool announcing a concrete >18-month-out SV2 deployment timeline → operators rush to deploy SV2 stacks early.
- A hashrate broker (Luxor / NiceHash) launching SV2-front routing as a customer-visible feature → instantly creates a paying-customer surface.
- Hashpool variant emerging that issues eHash on top of a Foundry/Antpool PPLNS settlement → ecash mints become customer #2.

## See also

- [[2026-05-28-path5-pool-software-landscape]]
- [[2026-05-28-path5-sjors-bio-recruiting]]
- [[2026-05-28-path5-luxor-hashrate-routing]]
- [[2026-05-28-path5-demand-pool-and-easy-sv2]]
