---
title: "Customer segments and honest TAM read"
type: concept
status: active
created: 2026-05-28
updated: 2026-05-28
confidence: high
tags: [tam, customer-fit, business-motivation, market-sizing]
---

# Customer segments and honest TAM read

Why would anyone deploy a reverse translator in 2026? Path 5's market analysis with verdict per hypothesis.

## The structural reason this tool exists

Top-5 pools = 77.7% of Bitcoin's network hashrate as of 2026-05-28; none have public SV2-native stratum endpoints ([[../../raw/data/2026-05-28-path5-mempool-space-pools-snapshot|hashrate snapshot]]). DEMAND is the only major pool marketed as SV2-native ([[../../raw/articles/2026-05-28-path5-demand-pool-and-easy-sv2|DEMAND]]). An SV2 stack that can only mine to DEMAND (or a regtest fixture) is a stack with one production destination.

## Per-hypothesis verdict

| # | Hypothesis | Verdict | Strongest evidence |
|---|---|---|---|
| 1 | Pool inertia (large pools still SV1 in 2026) | **Supported** | Top-5 pools = 77.7%, none SV2-native; DEMAND still uniquely markets as "first SV2 pool" |
| 2 | Gradual migration tooling demand | **Supported** | Sjors's bio recruiting + dmnd-easy-sv2 lib |
| 3 | Hashrate brokers fanning SV2-front to SV1 backends | **Unclear, leaning aspirational** | Luxor has business case but zero public SV2 work |
| 4 | SV2 firmware fleet → SV1 payout pool | **Supported by inference** | BraiinsOS+ ships SV2 firmware; top destinations are SV1 |
| 5 | Ecash / hashpool settlement bridges with SV1 upstream | **Refuted in present, possible future** | hashpool runs its own SV2 pool, not on top of an SV1 upstream |
| 6 | Censorship-resistance / MEV preserved with reverse translator | **Mostly refuted as marketing** | Pool still constructs the actual block template |
| 7 | Testing / dev tooling demand | **Supported** | SRI is alpha, no reverse translator exists, every dev testing against a real pool today writes one-offs |

## Customer ranking (most realistic first)

1. **SRI / SV2 ecosystem developers**. Strategic value: very high. Paying customer count: zero. Without this tool, SV2 stack development can only be tested against SRI's own pool role on regtest, or DEMAND. Sjors Provoost's GitHub bio ([[../../raw/articles/2026-05-28-path5-sjors-bio-recruiting]]) explicitly recruits for "reverse-translator development." *The path-of-least-resistance first user.*
2. **Hashpool / Cashu mining-mint experimenters**. Small, motivated, non-paying. A hashpool variant issuing eHash backed by another pool's PPLNS payout would need this. ~1-3 hobbyist projects in 2026.
3. **Mid-size mining operators running BraiinsOS+ / SV2 firmware paid out by Foundry / Antpool / F2Pool**. Largest theoretical TAM by hashrate, smallest active demand. Operators today downgrade firmware to SV1 client mode rather than running an extra proxy service.
4. **Hashrate brokers (Luxor, NiceHash, OKMiner)**. Architectural fit, no commercial pull. 2027-2028 customer if SV2 reaches escape velocity.
5. **Solo miners / OCEAN customers / p2pool**. *Not* customers. They want to avoid centralized pools, not bridge to them.

## Bottom line

The reverse translator is a **developer tool first, production component second**. The strongest reason to build it now is not market size — it is that without it, the SV2 ecosystem cannot be exercised against the actual production hashrate landscape, which keeps SV2 itself in dev-loop purgatory. **Public-good plumbing more than a commercial product.**

## What would change this read

- Foundry or Antpool announcing a concrete >18-month-out SV2 deployment timeline → operators rush to deploy SV2 stacks early to get ahead of it.
- A hashrate broker (Luxor / NiceHash) launching SV2-front routing as a customer-visible feature → instantly creates a paying-customer surface.
- Hashpool variant emerging that issues eHash on top of a Foundry / Antpool PPLNS settlement → ecash mints become customer #2.

## Cross-wiki context

- [[../../sv2-p2pool-integration/_index|sv2-p2pool-integration]] — p2pool is *not* a reverse-translator customer (no upstream pool to translate to).
- [[../../bitcoin-mining-payout-schemas/_index|bitcoin-mining-payout-schemas]] — the upstream SV1 pool dictates payout (PPLNS, FPPS, etc.).
- [[../../iroh-transport-stratum-v2/_index|iroh-transport-stratum-v2]] — alternative transport is orthogonal; reverse translator's egress is whatever the upstream pool requires (TCP, sometimes TLS).

## See also

- [[sv2-features-lost-with-sv1-upstream]] — what the customer is *actually* buying internally
- [[sv2-spec-issue-102-the-canonical-reference]] — the spec acknowledges the need
