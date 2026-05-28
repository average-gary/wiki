---
title: "Issue #8217 — External Custom Modules incompatibility with 0.10 (closed)"
type: raw
source_type: articles
source_url: https://github.com/fedimint/fedimint/issues/8217
fetched: 2026-05-28
verified: 2026-05-28
volatility: warm
quality: 4
confidence: high
tags: [fedimint, custom-modules, fmcm, fedi-stability-pool, breakage]
summary: A maintainer-reported issue showing Fedi's external Stability Pool module broke when porting to fedimint 0.10 because PR #8067 removed module `GenParams` support. Demonstrates how fragile the External Custom Module (FMCM) ecosystem is — relevant context for any non-BTC asset module.
---

# Issue #8217 — External custom modules incompatibility with 0.10

- **State**: CLOSED
- **URL**: https://github.com/fedimint/fedimint/issues/8217

## Body (verbatim)

> While trying to port https://github.com/fedixyz/fedi to fedimint 0.10, I realized that support for each module's `GenParams` was completely nuked in https://github.com/fedimint/fedimint/pull/8067
>
> Unless there is a way I'm not seeing, this makes it impossible to effectively port Fedi's stability pool module, that relies on different `GenParams` for different runtime environments: https://github.com/fedixyz/fedi/blob/243c0269b02a2b6b05b19e7d1a8d988e241583a1/crates/fedimint/fedimintd/src/main.rs#L43
>
> Please advise on how to proceed.

## Why this matters for multi-currency

- Fedi maintains its **Stability Pool** as an *external* (out-of-tree) custom module, not as a PR into `fedimint/fedimint`. Fedi's source lives at `github.com/fedixyz/fedi`.
- This is the canonical existing example of a non-mint module providing stable-value functionality — and porting it across upstream Fedimint versions is painful enough to file a blocking issue.
- Implication: any future **third-party stablecoin / non-BTC asset module** built on Fedimint's new multi-currency rails will face the same FMCM brittleness. Module authors track upstream `ModuleInit` / `GenParams` API churn manually.
- This is a **practical obstacle** to a thriving non-BTC module ecosystem, distinct from the *protocol* obstacle that has been cleared by PRs #7734 / #8460.

## See also

- [[2026-05-28-bitcoin-manual-fedimint-stability-pool|Stability Pool article]] — what the module actually does
- [[2026-05-28-fedimint-discussion-8218-gold-stablecoins|Discussion #8218]] — dpc confirms Stability Pool is the "custom extension module" for synthetic stable balances
- [[2026-05-28-fedimint-pr-8460-mintv2-amount-unit-config|PR #8460]] — in-tree multi-asset support is via mintv2 + module instances, not external modules
