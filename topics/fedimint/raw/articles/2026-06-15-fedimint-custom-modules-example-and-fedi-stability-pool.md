---
title: "fedimint-custom-modules-example state + Fedi stability pool out-of-tree reality (2026-06-15)"
type: raw
source_type: articles
source_url: https://github.com/fedimint/fedimint-custom-modules-example
source: "fedimint-custom-modules-example + fedixyz/fedi"
ingested: 2026-06-15
fetched: 2026-06-15
verified: 2026-06-15
volatility: warm
quality: 4
confidence: high
tags: [fedimint, FMCM, custom-modules, fedi-stability-pool, upgrade-tax, scaffold-rot]
summary: Survey of the official `fedimint-custom-modules-example` (last push 2024-07-13, pinned to fedimint v0.3.0 — pre-`AmountUnit`) and Fedi's stability-pool module in `fedixyz/fedi` (depending on the `fedibtc/fedimint` fork at `v0.11.0-fedi1`, ~2,500-line server crate). Captures the FMCM upgrade tax and the de facto fork-the-upstream pattern.
---

# Out-of-tree (FMCM) Fedimint module reality — 2026-06-15

What writing a custom Fedimint module looks like in mid-2026, in light of [[2026-06-15-fedimint-server-module-trait-surface|the multi-currency-aware ServerModule/ClientModule trait surface]] and [[2026-06-15-fedimint-amount-units-and-amounts-source|AmountUnit/Amounts]] in master. The headline finding: **there is no upstream-curated 2026 path for FMCM authors**, and the only public real-world example forks fedimint rather than tracking it.

## 1. `fedimint-custom-modules-example` (the official scaffold)

- **Repo:** `https://github.com/fedimint/fedimint-custom-modules-example`
- **Latest push:** **2024-07-13**. Last meaningful commit `b6dc50df` (2024-06-11, "Merge PR #21"). Prior commits update for fedimint 0.3 (April 2024). Repo is **~2 years stale** as of 2026-06-15.
- `is_template: true`, MIT, 15 stars, 17 forks, 9 open issues.
- Workspace members: `fedimintd`, `fedimint-cli`, `fedimint-dummy-{common,client,server,tests}`, `tests`.
- All `fedimint-*` deps pinned to **git tag `v0.3.0`** of `fedimint/fedimint`.
- README ~8.7 KB; covers Nix install, `git clone`, `nix develop`, `just mprocs`, three-crate breakdown for the Dummy module, architecture diagram.
- **Zero mentions of `AmountUnit`, `Amounts`, multi-currency, or non-BTC.** The README predates PR #7734.

**Implication:** A 2026 author cloning the template lands on a code shape that pre-dates `Amounts`, the `distributed_gen` rework (post-#8067), the `fedimint-server-core` / `fedimint-client-module` crate split, and v2 modules. **The starting point is wrong.**

## 2. The in-tree dummy/empty modules are the real reference

Per [[2026-06-15-fedimint-server-module-trait-surface|the trait-surface walk]]:

- **`modules/fedimint-empty-*`** is the explicitly-recommended "good template for a new module" (per crate description). Total ~480 LOC across the three crates for a no-op module.
- **`modules/fedimint-dummy-*`** is the worked example. Already multi-currency-aware:
  - `DummyInput { amount: Amount, unit: AmountUnit, pub_key: PublicKey }`
  - `DummyOutput { amount: Amount, unit: AmountUnit }`
  - Server returns `TransactionItemAmounts { amounts: Amounts::new_bitcoin(input.amount), fees: Amounts::ZERO }`
  - Client implements `get_balance(_, unit) -> Amount` and `get_balances(_) -> Amounts`

A 2026 FMCM author should **copy from in-tree dummy/empty, not from the external example repo**.

## 3. Fedi's stability pool — the only public real-world FMCM

- **Repo:** `https://github.com/fedixyz/fedi` (public, last push 2026-06-15, not archived).
- Workspace path: `crates/modules/stability-pool/{client,common,server,tests}` plus `crates/modules/stability-pool-old/*` and `crates/modules/fedi-social/*`.
- Server crate: `version = "0.3.0"`, `edition = "2024"`, `lib.rs` ≈ **86,768 bytes (~2,500 lines)** — about 9× the size of in-tree empty-server, 9× dummy-server. Imports include `Audit`, `Amounts`, `ApiEndpoint`, `ApiRequestErased`, `CoreConsensusVersion`, `InputMeta`, `ModuleConsensusVersion`, `ModuleInit`, `SupportedModuleApiVersions`, `TransactionItemAmounts`, `ConfigGenModuleArgs`, `ServerModule`, `ServerModuleInit`, `ServerModuleInitArgs`, plus `MockOracle` / `AggregateOracle` for fiat price feeds.
- **Fedi pins to a fedimint fork**: root `Cargo.toml` declares `git = "https://github.com/fedibtc/fedimint", tag = "v0.11.0-fedi1"` for every fedimint-* dep. Even `fedimintd-fedi` (per workspace metadata `repository = "https://github.com/fedibtc/fedimintd-fedi"`) is fork-distributed.
- Commented-out path-deps to `../fedimint/*` for local development. Dangling TODO comment about "needed when we update fedimint again to include https://github.com/fedimint/fedimint/pull/6578" — explicit evidence of a renames-catchup backlog.

**Implication:** **Forking is the de-facto FMCM pattern.** No version of `fedimint-core` is published on crates.io that matches the in-tree multi-currency surface; Fedi maintains a downstream `v0.X.Y-fedi1` tag stream.

## 4. The breakage tax

Documented breakages an FMCM author has paid (or will pay) in the last ~12 months:

1. **PR #6578 batch — pre-0.10 renames.** Fedi's Cargo TODO comment confirms they still owe a renames-catchup. Authors must rename imports across all module crates.
2. **PR #8067 (0.10) — `ModuleInit::parse_params` and per-module `GenParams` removed.** [[../articles/2026-05-28-fedimint-issue-8217-external-modules-broken|Issue #8217]] documents this **broke Fedi's stability pool port to 0.10**. Quotes:
   - shaurya947 (Fedi): *"While trying to port https://github.com/fedixyz/fedi to fedimint 0.10, I realized that support for each module's `GenParams` was completely nuked in https://github.com/fedimint/fedimint/pull/8067. Unless there is a way I'm not seeing, this makes it impossible to effectively port Fedi's stability pool module, that relies on different `GenParams` for different runtime environments."*
   - elsirion (maintainer): *"I think this was mostly resolved on calls, some learnings on being more careful not to break external modules. **I'll probably have to reintroduce config gen params again for proper multi-asset ecash support, so this whole thing feels like a mistake. But live and learn …**"*
   - shaurya947 framing: *"custom external modules a bit of second-class now (at least from the developer UX perspective)"*.
3. **PR #7734 (multi-currency).** Trait surface now uses `Amounts` everywhere amount-flowed:
   - Add `unit: AmountUnit` fields to `Input`/`Output` types if multi-asset.
   - `process_input` / `process_output` return `TransactionItemAmounts`.
   - `input_fee` / `output_fee` take `&Amounts` and return `Option<Amounts>`.
   - `get_balance(_, unit) -> Amount` plus new `get_balances(_) -> Amounts`.
   - Manual `primary_module: ModuleInstanceId` setting is gone; use `supports_being_primary() -> PrimaryModuleSupport` per-unit instead.
4. **V2 modules in-tree** (Discussion #8680, joschisan, 2026-06-09): mintv2/walletv2/lnv2/recurringdv2 land alongside v1. joschisan: *"All v2 modules are half the size and simpler to integrate and modify. Future work can be reasonably done for both, maybe 50% more work instead of double."* — explicit 1.5× duplication overhead an FMCM author who integrates with mint/wallet/ln also pays.
5. **Scaffold rot** — see #1 above.
6. **No upstream stability promise**, no crates.io publication that matches master, no curated migration guide.

**Per-minor-release upgrade tax (sketch):**
- Re-pin every `fedimint-*` git dep to the new tag.
- Resolve workspace-rename churn (PR #6578-class).
- Re-add any `GenParams`-equivalent runtime config (env vars, custom `ServerModuleInit::init` plumbing) when the previous mechanism is deleted.
- Update `ServerModule`/`ClientModule` trait signatures touched by the release.
- Update database migrations if `ServerModuleDbMigrationFn` / `ClientModuleMigrationFn` signatures shifted.
- Decide whether to track v1 modules, port to v2, or build for both.

Per shaurya947 / elsirion exchange and Fedi's fork tag: a few-day-to-multi-week port per minor fedimint release is realistic.

## 5. Search for 2026 blog posts / talks / guides

Direct fetches:
- `fedimint.org/blog` (2026): no posts on custom modules, multi-currency, FMCM, or extension modules. Coverage is releases (v0.6/v0.7), Vipr Wallet, BitSacco Kenya, gateway updates. **Empty for this question.**
- `fedimint.org/docs/category/developers`: 404.
- DuckDuckGo / Google: anti-scrape walls; no usable hits via WebFetch.

**Net:** there is effectively no public 2026 blog/tutorial corpus on writing FMCMs outside the GitHub example repo (stale) and Fedi's source. The official "developers" docs path is broken.

## 6. Caveats / open work

- I did not deep-read Fedi's stability-pool `lib.rs` (~2,500 lines). A wiki author wanting to dissect a real multi-currency module's architecture should fetch `https://raw.githubusercontent.com/fedixyz/fedi/main/crates/modules/stability-pool/server/src/lib.rs` directly.
- Issue #8217's resolution path (env-var workaround vs config-gen-params reintroduction) is "mostly resolved on calls" per elsirion — there is no public design doc for the eventual fix.
- WebSearch was not available in the agent that gathered this; relied on the official blog and direct GitHub fetches. A Twitter / conference-talk corpus may exist that I did not see.

## See also

- [[2026-05-28-fedimint-issue-8217-external-modules-broken|Issue #8217 — `GenParams` removal]]
- [[../repos/2026-06-15-fedimint-server-module-trait-surface|ServerModule/ClientModule trait surface]]
- [[../repos/2026-06-15-fedimint-amount-units-and-amounts-source|AmountUnit/Amounts source]]
- [[2026-05-28-fedimint-discussion-8218-gold-stablecoins|Discussion #8218 — dpc on multi-currency status]]
- [[../repos/2026-06-15-fedimint-recent-prs-and-discussions|Recent PRs & discussions]]
- [[../../wiki/concepts/fedimint-modules-and-instances|Fedimint modules and instances (concept)]]
