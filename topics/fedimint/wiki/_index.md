---
title: Wiki — Fedimint
type: index
updated: 2026-05-28
---

# Wiki — Fedimint

## Topics (synthesizing reads)

- [[topics/fedimint-multi-currency-status.md|Multi-currency status]] ⭐ — three-path framing (native mintv2 / Stability Pool / off-mint bridge), what shipped, what's missing

## Concepts (atomic reference reads)

### Multi-currency machinery
- [[concepts/amount-units-and-amounts.md|AmountUnits and Amounts]] — core-layer multi-unit types (PR #7734)
- [[concepts/mintv2-amount-unit-config.md|mintv2 amount_unit config]] — per-module unit declaration (PR #8460)
- [[concepts/fedimint-modules-and-instances.md|Fedimint modules and instances]] — `ModuleKind` / `ModuleInstanceId` decoupling, in-tree vs FMCM

### Existing non-BTC patterns
- [[concepts/stability-pool.md|Stability Pool]] — Fedi's synthetic-USD external custom module
- [[concepts/off-mint-payments-bridge-pattern.md|Off-mint payments-bridge pattern]] — BitSacco / ChapSmart shape

### Cross-cutting
- [[concepts/federation-trust-model.md|Federation trust model]] — KYF, debasement, exit, regulation, and how multi-currency multiplies these

## Reference

- [[reference/cashu-comparison.md|Cashu comparison]] — Cashu's NUT-02 multi-unit support as the closest precedent

## Theses (candidates for follow-up research)

(None yet — see open questions in [[topics/fedimint-multi-currency-status.md|multi-currency status]] for follow-up candidates.)

## Stats

- 9 raw sources ingested (0 papers, 7 articles, 2 repos)
- 8 wiki articles compiled (1 topic + 6 concepts + 1 reference)
- 0 candidate theses
- Last research session: 2026-05-28 (initial round, "fedimint multi-currency support", 5 parallel agents)
