---
title: "Fedimint recent PRs and discussions touching modules & multi-currency (master @ c39f9c8)"
type: raw
source_type: repos
source_url: https://github.com/fedimint/fedimint
source: "fedimint/fedimint @ c39f9c8 + open discussions"
local_path: /Users/garykrause/repos/fedimint
ingested: 2026-06-15
fetched: 2026-06-15
verified: 2026-06-15
volatility: hot
quality: 5
confidence: high
tags: [fedimint, prs, discussions, v2-modules, gateway-extensibility, multi-currency, primary-module]
summary: Recent (2026-04-01 → 2026-06-15) merged PRs, open discussions, and load-bearing commits affecting Fedimint module authors writing multi-currency code. Includes Discussion #8395 (gateway extensibility for non-BTC LN — proposed but unimplemented), #8680 (elsirion's v2-module status note), the recent overflow-fix #8686, walletv2/mintv2/lnv2 hardening commits, and the open `AmountUnit` design questions.
---

# Recent PRs & discussions (2026-04-01 → 2026-06-15)

Snapshot of activity since the prior research session (2026-05-28). Repo @ master `c39f9c8`, 352 commits ahead of `v0.11.2-alpha.1` (released 2026-06-02).

## 1. Recently merged PRs (newest first)

No new multi-currency PRs landed in this window. All activity is v2-module hardening and core hygiene.

| PR | Merged | Title | Module-author relevance | SHA |
|---|---|---|---|---|
| #8686 | 2026-06-12 | `fix(core): reject amount addition overflow` | `Amount`/`Amounts` arithmetic now returns `Option`/error on overflow. Modules summing per-unit `Amount`s must propagate `None` instead of panicking. | `25ef880c3af` |
| #8665 | 2026-06-13 | `[Backport v0.11] fix(walletv2-fedi-integration): persist send + receive terminal state to operation log` | Pattern: terminal SM states must be persisted to OperationLog. Authors should mirror this. | — |
| #8682 | 2026-06-11 | `test(walletv2): scan initial regtest blocks` | Test-harness convention for walletv2-style modules. | — |
| #8676 | 2026-06-10 | `feat: add custom meta to wallet v2 send` | `walletv2` send/receive now accepts caller-supplied `OperationMeta`. Pattern multi-currency modules should mirror. | `ce06da2908b` |
| #8673 | 2026-06-04 | `test(mint): cover duplicate blind nonce rejection` | Idempotency-of-nonces test pattern for mint-style modules. | — |
| #8667 | 2026-06-03 | `fix: include invite code in mintv2 ecash` | mintv2 ecash format extended. Existing decoders need backcompat. | `3737cf7a288` |
| #8649 | 2026-06-01 | `feat(lnv2-client): expose payment preimage in FinalSendOperationState` | API additions on the v2-module client side. | — |
| #8647 | 2026-05-28 | `fix(mintv2-fedi-integration): persist receive terminal state to operation log` | Same persistence pattern as #8665. | `87bb55c7520` |
| #8646 | 2026-05-28 | `feat(walletv2-fedi-integration): expose receive address and bitcoin outpoint on meta and event` | Demonstrates dual surfacing (meta + event log). Pattern for multi-currency. | — |
| #8460 | 2026-04-08 | `feat(mintv2): add amount_unit config field for multi-asset support` | The single PR wiring `AmountUnit` into `MintConfigConsensus` / `MintClientConfig`. Defaults to `BITCOIN` via serde. | `e368d4f6c9b` |
| #7734 | 2025-10-19 | `chore: multi-currency support` | Foundation: `AmountUnit`, `Amounts`, multi-primary modules. +1620/-884. | — |

Ancillary infra (relevant context, not direct multi-currency):
- #8601 — ban std HashMap in server crates (deterministic iteration required).
- #8463 — log consensus versions on startup.
- #8557 — federation prefix in client logs.
- #8554 — `SafeUrl::join_path` migration.
- #8520 / #8523 / #8524 — iroh networking polish.

## 2. Open discussions (most relevant)

### Discussion #8680 — *Summary of practical improvements of the V2 Modules* (2026-06-09, elsirion)

Strong signal that v2 is the production direction. Selected quotes:

> "Mintv2 cannot loose money... This is not a fix or safeguard but a natural property that falls out of the stateless nonce derivation paired with the new recovery."

> "All v2 modules are half the size and simpler to integrate and modify. Future work can be reasonably done for both, maybe 50% more work instead of double."

> "The gateway easily works with any combination of modules, the mintv2 and wallet v2 modules integration took maybe an hour."

Recoveryv2, recurringdv2 stateless. walletv2 has built-in address management and no esplora dependency. **No PR or roadmap issue commits to mintv1 deprecation, but the technical case is being made publicly.**

### Discussion #8395 — *Gateway Extensibility: Allow External Modules to Handle Non BTC Lightning Payments* (2026-03-19)

**Direct multi-currency relevance.** Quote:

> "As multi currency support lands via #7734. The gateway needs a way for custom modules to register payment handlers for new asset types."

Proposes a `GatewayPaymentHandler` trait with `asset_type()`, `handle_incoming/create_invoice/handle_outgoing`. **Not implemented as of 2026-06-15.** No PR linked. An external module minting non-BTC ecash today **cannot receive Lightning payments through `gatewayd`** — it would have to implement deposits/withdrawals out-of-band.

### Discussion #8218 — *Are gold stable coins compatible with the stablecoin integration in the Fedi Wallet?* (2026-01-28)

dpc reply (verbatim):

> "Fedi app has a custom extension module that implements synthetic stable balances. In Fedimint we are working in the longer term goal on multi-currency support, which in principle would allow people to implement extension modules for any assets. But it is nowhere need [near] to be implemented."

(Already ingested at [[../articles/2026-05-28-fedimint-discussion-8218-gold-stablecoins|Discussion #8218]].)

### Discussion #8129 — *Primitives Module* (2026-01-09)

Proposes a primitives module (hash/time/point locks decoupled from LN) that would enable atomic on-chain↔ecash and "swaps with other assets". Adjacent enabler for multi-asset; conceptual, inactive since January 2026.

## 3. Open issues (module-API / multi-currency adjacent)

Of 30 open issues sampled, **none directly mention `AmountUnit`, `Amounts`, multi-currency, multi-asset, stablecoin, oracle, or peg.** Closest module-author-relevant:

- **#6650** — *Automatically determine max supported module API version* (updated 2026-04-06). Module authors today still hand-bump `SupportedModuleApiVersions`.
- **#8421** — *Event log events for operations should be a superset of legacy update stream* (2026-03-25). Modules should design state-machine transitions so all `subscribe_*` states get corresponding event-log events.
- **#8425** — *Fix atomicity bugs in event system* (2026-03-26). Affects how modules emit events.
- **#8313** — *Periodic rebalancing of e-cash notes* (2026-03-31). mintv1 motivation; multi-unit mints will face the same fragmentation per-unit.
- **#8688** — *Allow separate send/receive nodes for LN gateway* (2026-06-13). Gateway extensibility, adjacent to non-BTC LN payments work.
- **#8627** — *Setup codes should commit to Fedimint version* (2026-06-10). Affects how config codes evolve when modules change `Consensus*Config` shape — non-trivial for adding new currency units in production.

**No open issue tracks "extend `AmountUnits` to fiat" or "add backing-asset module".** Multi-currency exists in code without a public roadmap issue.

## 4. Local-repo recent commits (most relevant)

`git log --since="2026-04-01" -- modules/ fedimint-core/ fedimint-server-core/ fedimint-client-module/`. Highlights:

**Core / Amounts:**
- `25ef880c3af` `f35d4eb4c7c` — `fix(core): reject amount addition overflow`
- `0844b55a11c` — `chore: remove VERSION_0_8_2 and VERSION_0_9_0`

**mintv2:**
- `e368d4f6c9b` `47a0340e1bf` — `feat(mintv2): add amount_unit config field`
- `3737cf7a288` — `fix: include invite code in mintv2 ecash`
- `87bb55c7520` `be1b96c50a2` — `fix(mintv2-client): persist receive terminal state to operation log`

**walletv2:**
- `7f3d2ff5366` — `feat(walletv2): expose receive address and bitcoin outpoint on meta and event`
- `d6f70ebd38b` `ce06da2908b` — `feat: add custom meta to wallet v2 send`
- `10906756858` — `fix(walletv2-client): persist send + receive terminal state to operation log`
- `8aab7eb9e9e` — `refactor(wallet-client): move tokio::select to top of peg-in monitor loop`
- `9bb87e25c6c` — `feat(wallet-client): bounded reuse of unused deposit addresses via allocate_deposit_address_pooled`
- `480a68743b8` — `chore: add WalletDescriptor to WalletClientConfig and WalletConsensusConfig`

**lnv2:**
- `7a2e639f13a` `253edcb22b1` — `feat(lnv2-client): expose payment preimage in FinalSendOperationState`
- `acdcda7c143` — `fix(lnv2): use post-recovery balance as threshold base`

**Server hygiene (affects all modules):**
- `28b6a0ff188` `9c44623e0d2` `66e1b8cf8dc` — `chore(server): ban standard hash maps in server crates` (#8601). Use deterministic-iteration maps.
- `6c3915b9f46` — `feat(client): add finalize_and_submit_transaction_dbtx`
- `f309a51d638` — `feat(client): plumb fed_id span to module client tasks`. Tracing context now includes `fed_id` automatically.

## 5. CHANGELOG state

`/Users/garykrause/repos/fedimint/CHANGELOG.md` newest entry is **v0.7.0** (late 2025). **Multi-currency (#7734, #8460) is NOT called out in any release-notes file in the repo.** `docs/RELEASE_NOTES-v0.4.md` is the only secondary release-notes doc and is irrelevant today.

For multi-currency module authors: **the only authoritative sources for changes between v0.7 and v0.12-alpha are the PR #7734 description, the PR #8460 description, the source code, and Discussion #8680.**

## 6. Open questions (carry-forward to playbook)

1. **Is `AmountUnit` an open string or restricted enum?** — *Answered:* opaque `u64` newtype, unit `0` reserved for BITCOIN, no registry. Two federations choosing `AmountUnit::new_custom(1)` could mean different things. **Conventions for fiat / stablecoin tagging are an open design question.**
2. **What's the migration path for an FMCM that returns `Amount` to start returning `Amounts`?** — *Partially answered.* PR #8460 demonstrates the pattern (`Amounts::new_custom(unit, amount)`). `Amounts::expect_only_bitcoin()` is the back-compat helper, no deprecation timeline.
3. **Will mintv2 deprecate mintv1?** — *Strong signal but no committed roadmap.* Discussion #8680 is a public technical case, no PR.
4. **Are backing-asset modules being built in-tree?** — *No.* Zero PRs / open issues / discussions surface in-tree peg/oracle/collateral work. Gateway-side extension API (Discussion #8395) is unimplemented.
5. **How does a multi-currency module register as primary for its unit?** — *Answered.* `PrimaryModuleSupport` enum: `Any { priority }` / `Selected { priority, units: BTreeSet<AmountUnit> }` / `None`. mintv2 uses `Selected(HIGH, [cfg.amount_unit])`. Whether multiple instances of the same module type with different `amount_unit`s coexist correctly is **not exercised by tests**.
6. **Does the gateway plug into non-BTC units?** — *No.* Discussion #8395 unimplemented.

## 7. Cashu comparison (NUT-01/02 multi-unit) — current state

Cashu has shipped a stable, string-based, ISO-aware multi-unit API since pre-2026:

- NUT-01: *"A mint may support any currency unit(s) they can mint and melt, either directly or indirectly."* `btc`, `sat`, `msat`, ISO 4217 (`usd`, `eur`), stablecoin tickers.
- NUT-02: *"the `unit` string is incorporated into keyset-ID derivation."* Cross-unit transactions in one tx are first-class.
- NUT-04 (mint): per-`(method, unit)` min/max amount caps.
- NUT-00 V4 token format: mandatory `"u": str` field.

**Reference value for Fedimint:** Fedimint's design (`AmountUnit(u64)` opaque, configured per module instance) is **lower-level** than Cashu's. A Fedimint module author building a fiat mint should look at NUT-01/02 to understand the human-readable / minor-unit-decimals semantics they will need to layer on top of `AmountUnit` themselves. No recent (2026) Cashu changes to the multi-unit model.

## See also

- [[2026-06-15-fedimint-server-module-trait-surface|ServerModule/ClientModule trait surface]]
- [[2026-06-15-fedimint-amount-units-and-amounts-source|AmountUnit/Amounts source]]
- [[2026-06-15-fedimint-mintv2-amount-unit-wiring|mintv2 amount_unit wiring]]
- [[../articles/2026-06-15-fedimint-custom-modules-example-and-fedi-stability-pool|Custom-modules-example + Fedi stability pool]]
- [[../articles/2026-05-28-fedimint-issue-8217-external-modules-broken|Issue #8217]]
- [[../articles/2026-05-28-fedimint-discussion-8218-gold-stablecoins|Discussion #8218]]
