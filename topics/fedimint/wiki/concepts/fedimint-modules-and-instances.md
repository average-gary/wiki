---
title: "Fedimint modules and instances (ModuleKind vs ModuleInstanceId)"
type: concept
created: 2026-05-28
updated: 2026-05-28
verified: 2026-05-28
volatility: warm
confidence: high
tags: [fedimint, modules, fmcm, custom-modules, architecture]
---

# Fedimint modules and instances

Fedimint's protocol is a thin consensus + transaction layer on top of which **modules** provide functionality. Three modules are core: **wallet** (on-chain BTC), **mint** (Chaumian eCash), **lightning** (LN gateway interface). Custom modules can extend the federation.

## ModuleKind vs ModuleInstanceId

In `fedimint-core/src/core.rs`:

- **`ModuleKind`** — a string type-id identifying *what kind* of module this is (`"mint"`, `"wallet"`, `"lightning"`, `"stabilitypool"`, etc.).
- **`ModuleInstanceId`** — a `u16` identifying *which specific instance* of that kind in this federation.

The two are decoupled. A source comment notes: a single `ModuleKind` *can* be instantiated twice with different instance IDs ("rare, but possible"). This decoupling is what makes the multi-currency architecture clean — see [[mintv2-amount-unit-config|mintv2 amount_unit config]].

## In-tree vs external (FMCM) modules

- **In-tree**: ship inside `fedimint/fedimint`. Examples: wallet, mint (v1 + v2), lightning, dummy/empty.
- **External / Fedimint Custom Modules (FMCM)**: live in separate repos, link `fedimint-core` as a library. Example: Fedi's Stability Pool at `github.com/fedixyz/fedi`.

External modules are fragile — they track upstream API changes manually. [[../../raw/articles/2026-05-28-fedimint-issue-8217-external-modules-broken|Issue #8217]] documents how PR #8067 broke the FMCM `GenParams` surface and stranded Fedi's Stability Pool port to fedimint 0.10.

## Why the distinction matters for multi-currency

There are now **two architectural paths** to non-BTC value inside a Fedimint federation:

1. **In-tree multi-currency**: spin up multiple `mintv2` module instances with different `amount_unit` values. Clean, supported by core, but no real-asset backing logic ships in-tree.
2. **External custom module**: write your own module (e.g. Stability Pool) that holds non-BTC value and exposes its own balances via the federation. Path used in production today (Fedi's synthetic USD), but FMCM brittleness is a recurring tax.

## See also

- [[mintv2-amount-unit-config|mintv2 amount_unit config]] — in-tree path
- [[stability-pool|Stability Pool]] — external-module path
- [[amount-units-and-amounts|AmountUnits and Amounts]] — core-layer enabler for the in-tree path
- [[../../raw/articles/2026-05-28-fedimint-issue-8217-external-modules-broken|Issue #8217]] — external-module brittleness
