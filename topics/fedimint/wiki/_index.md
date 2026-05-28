---
title: Wiki — Fedimint
type: index
updated: 2026-05-28
---

# Wiki — Fedimint

## Topics (synthesizing reads)

- [[Multi-currency status|topics/fedimint-multi-currency-status.md]] ⭐ — three-path framing (native mintv2 / Stability Pool / off-mint bridge), what shipped, what's missing

## Concepts (atomic reference reads)

### Multi-currency machinery
- [[AmountUnits and Amounts|concepts/amount-units-and-amounts.md]] — core-layer multi-unit types (PR #7734)
- [[mintv2 amount_unit config|concepts/mintv2-amount-unit-config.md]] — per-module unit declaration (PR #8460)
- [[Fedimint modules and instances|concepts/fedimint-modules-and-instances.md]] — `ModuleKind` / `ModuleInstanceId` decoupling, in-tree vs FMCM

### Existing non-BTC patterns
- [[Stability Pool|concepts/stability-pool.md]] — Fedi's synthetic-USD external custom module
- [[Off-mint payments-bridge pattern|concepts/off-mint-payments-bridge-pattern.md]] — BitSacco / ChapSmart shape

### Cross-cutting
- [[Federation trust model|concepts/federation-trust-model.md]] — KYF, debasement, exit, regulation, and how multi-currency multiplies these

## Reference

- [[Cashu comparison|reference/cashu-comparison.md]] — Cashu's NUT-02 multi-unit support as the closest precedent

## Theses (candidates for follow-up research)

(None yet — see open questions in [[topics/fedimint-multi-currency-status.md|multi-currency status]] for follow-up candidates.)

## Stats

- 9 raw sources ingested (0 papers, 7 articles, 2 repos)
- 8 wiki articles compiled (1 topic + 6 concepts + 1 reference)
- 0 candidate theses
- Last research session: 2026-05-28 (initial round, "fedimint multi-currency support", 5 parallel agents)
