---
title: Concepts
type: index
updated: 2026-06-15
---

# Concepts

## Module-authoring trait surface (added 2026-06-15)

- [[server-module-trait|ServerModule trait]] — what a module implements consensus-side (`ServerModule` + `ServerModuleInit`)
- [[client-module-trait|ClientModule trait]] — client-side surface (`ClientModule` + `ClientModuleInit`, state machines, primary-module API)
- [[transaction-item-amounts|TransactionItemAmounts and the per-unit balance check]] — the multi-unit return type + `FundingVerifier`
- [[primary-module-support|Primary module support]] — per-unit funding routing (replaces the manual `primary_module` setting)
- [[three-crate-pattern|Three-crate module pattern]] — `-common` / `-client` / `-server` split, recommended scaffolds
- [[fmcm-upgrade-tax|FMCM upgrade tax]] — what writing out-of-tree costs you per minor fedimint release

## Multi-currency machinery

- [[amount-units-and-amounts|AmountUnit and Amounts]] — multi-unit core types (PR #7734)
- [[mintv2-amount-unit-config|mintv2 amount_unit config]] — per-module unit declaration (PR #8460)
- [[fedimint-modules-and-instances|Fedimint modules and instances]] — module-kind vs instance-id, in-tree vs FMCM

## Existing non-BTC patterns

- [[stability-pool|Stability Pool]] — synthetic-USD via BTC collateral (Fedi external module)
- [[off-mint-payments-bridge-pattern|Off-mint payments-bridge pattern]] — BitSacco / ChapSmart shape

## Cross-cutting

- [[federation-trust-model|Federation trust model]] — KYF, debasement, exit, regulation, multi-currency risk multiplier
