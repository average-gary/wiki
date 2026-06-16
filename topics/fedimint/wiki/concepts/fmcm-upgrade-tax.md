---
title: "FMCM upgrade tax — the cost of writing a Fedimint module out-of-tree"
type: concept
created: 2026-06-15
updated: 2026-06-15
verified: 2026-06-15
volatility: warm
confidence: high
tags: [fedimint, FMCM, custom-modules, upgrade-tax, scaffold-rot, multi-currency]
---

# FMCM upgrade tax

The "Fedimint Custom Module" (FMCM) story is technically real — `fedimint-core`, `fedimint-server-core`, and `fedimint-client-module` are public crates and external modules can implement [[server-module-trait|`ServerModule`]] / [[client-module-trait|`ClientModule`]] without forking. In practice, every minor fedimint release has broken external modules in some load-bearing way, and the only public real-world FMCM (Fedi's stability pool) has chosen to **fork upstream** rather than track it via crates.io.

This article catalogs the recurring breakages so a 2026 module-author reader can budget for them.

## The breakages

1. **PR #6578 batch (pre-0.10) — workspace renames.** Fedi's `Cargo.toml` still has a TODO comment about catching up to renamed crates. Authors must rename imports across all module crates each cycle.

2. **PR #8067 (0.10) — per-module `GenParams` removed.** [[../../raw/articles/2026-05-28-fedimint-issue-8217-external-modules-broken|Issue #8217]] documents this **broke Fedi's stability pool port** to fedimint 0.10. shaurya947 (Fedi):
   > *"While trying to port https://github.com/fedixyz/fedi to fedimint 0.10, I realized that support for each module's `GenParams` was completely nuked in https://github.com/fedimint/fedimint/pull/8067… this makes it impossible to effectively port Fedi's stability pool module, that relies on different `GenParams` for different runtime environments."*
   elsirion has acknowledged the removal will need to be reversed: *"I'll probably have to reintroduce config gen params again for proper multi-asset ecash support, so this whole thing feels like a mistake. But live and learn."*

3. **PR #7734 (multi-currency) — trait surface broadly changed.** Modules now must:
   - Add `unit: AmountUnit` to `Input`/`Output` types if multi-asset (a BTC-only module can stay scalar internally and wrap with `Amounts::new_bitcoin`).
   - Return `TransactionItemAmounts` from `process_input`/`process_output`.
   - Take `&Amounts` and return `Option<Amounts>` from `input_fee`/`output_fee`.
   - Switch `get_balance() -> Amount` to `get_balance(_, unit) -> Amount` plus add `get_balances(_) -> Amounts`.
   - Replace manual primary-module setting with [[primary-module-support|`PrimaryModuleSupport`]] declaration.

4. **V2 modules in-tree** (Discussion #8680, 2026-06-09). mintv2 / walletv2 / lnv2 / recurringdv2 land alongside v1. joschisan: *"All v2 modules are half the size and simpler to integrate and modify. Future work can be reasonably done for both, maybe 50% more work instead of double."* — explicit ~1.5× duplication overhead an FMCM author who integrates with mint/wallet/ln also pays.

5. **Scaffold rot.** `fedimint-custom-modules-example` is pinned to `v0.3.0` of fedimint, last commit 2024-07-13. By 2026 it predates `Amounts`, the `fedimint-server-core` / `fedimint-client-module` crate split, the `distributed_gen` rework, and v2 modules. **The starting point is wrong.** Use in-tree `fedimint-empty-*` / `fedimint-dummy-*` instead.

6. **No upstream stability promise / no published crates.io match.** No version of `fedimint-core` published on crates.io currently matches the in-tree multi-currency surface. Fedi maintains a downstream `v0.X.Y-fedi1` tag stream on its own fork.

7. **No CHANGELOG / migration guide for v0.8+.** `CHANGELOG.md`'s newest entry is v0.7.0. Multi-currency (#7734, #8460) is **not called out** in any release-notes file. The only authoritative sources for changes between v0.7 and v0.12-alpha are the PR descriptions themselves, the source code, and Discussion #8680.

## Per-minor-release upgrade checklist (sketch)

- Re-pin every `fedimint-*` git dep to the new tag.
- Resolve workspace-rename churn (PR #6578-class).
- Re-add any `GenParams`-equivalent runtime config (env vars, custom `ServerModuleInit::init` plumbing) when the previous mechanism is deleted.
- Update `ServerModule` / `ClientModule` trait signatures touched by the release. Watch for `&mut Amounts` overflow propagation (PR #8686, 2026-06-12) — make sure your sum sites handle `None`.
- Update database migrations if `ServerModuleDbMigrationFn` / `ClientModuleMigrationFn` signatures shifted.
- Decide whether to track v1 modules, port to v2, or build for both.
- Re-run `just final-check` against the new fedimint commit pinned in your `Cargo.toml`.

Realistic budget per minor fedimint release for an FMCM that integrates with mint/wallet/ln: **a few days to multi-week port** depending on how invasive that release's changes were.

## The de facto pattern: fork upstream

Per the [[../../raw/articles/2026-06-15-fedimint-custom-modules-example-and-fedi-stability-pool#3-fedis-stability-pool--the-only-public-real-world-fmcm|stability-pool survey]], Fedi pins every `fedimint-*` dep to `git = "https://github.com/fedibtc/fedimint", tag = "v0.11.0-fedi1"` — i.e., they consume their **own fork** of fedimint, not upstream. The dangling Cargo comment about "needed when we update fedimint again to include https://github.com/fedimint/fedimint/pull/6578" makes the manual catchup explicit.

If you're building an FMCM in 2026, plan for a `[patch]` section or a fedimint fork from day one. Avoid hand-wiring against an upstream master tag — the surface will move under you.

## Mitigations the maintainers acknowledge are needed

- Reintroduce per-module `GenParams` for multi-asset config (elsirion in #8217).
- Ship a `GatewayPaymentHandler` extension API for non-BTC LN (Discussion #8395, 2026-03-19, unimplemented).
- Update `fedimint-custom-modules-example` to a 2026 fedimint version (no PR seen).

None of these have landed as of 2026-06-15.

## See also

- [[../../raw/articles/2026-06-15-fedimint-custom-modules-example-and-fedi-stability-pool|FMCM survey]] — example repo + Fedi stability pool
- [[../../raw/articles/2026-05-28-fedimint-issue-8217-external-modules-broken|Issue #8217]] — `GenParams` removal in detail
- [[../../raw/repos/2026-06-15-fedimint-recent-prs-and-discussions|Recent PRs & discussions]] — including #8395 gateway extensibility, #8680 v2-module status
- [[fedimint-modules-and-instances|Modules and instances]]
- [[three-crate-pattern|Three-crate pattern]]
