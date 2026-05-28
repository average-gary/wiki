---
title: "PR #8460 — feat(mintv2): add amount_unit config field for multi-asset support (joschisan, merged 2026-04-08)"
type: raw
source_type: repos
source_url: https://github.com/fedimint/fedimint/pull/8460
fetched: 2026-05-28
verified: 2026-05-28
volatility: warm
quality: 5
confidence: high
tags: [fedimint, multi-currency, multi-asset, mintv2, mint-module, joschisan]
summary: Builds on PR #7734 by adding an `amount_unit` config field to the v2 mint module, letting a federation declare which unit a given mint instance issues. Backported to releases/v0.11 in PR #8466.
---

# PR #8460 — feat(mintv2): add amount_unit config field for multi-asset support

- **Author**: joschisan (Fedimint core dev)
- **Merged**: 2026-04-08
- **Backport (v0.11)**: [PR #8466](https://github.com/fedimint/fedimint/pull/8466), merged 2026-04-09 (by fedimint-bot)
- **State**: MERGED
- **URL**: https://github.com/fedimint/fedimint/pull/8460

## What it does

Adds an `amount_unit` configuration field to the v2 mint module (`mintv2`). With PR #7734 having made `fedimint-core` unit-aware, this PR exposes the unit declaration at the per-module config level — a federation operator can now specify which unit a given mint instance issues.

This is the **per-module piece** that pairs with the **core-layer piece** in [[2026-05-28-fedimint-pr-7734-multi-currency-support|PR #7734]]:

- PR #7734 (Oct 2025) → fedimint-core supports `Amounts: unit -> amount`
- PR #8460 (Apr 2026) → mintv2 module config has an `amount_unit` field

## Significance

- A single Fedimint federation could now (in principle) run **multiple mintv2 module instances** with different `amount_unit` values — one BTC mint, one synthetic-USD mint, etc., each issuing notes denominated in its declared unit.
- The architecture leverages Fedimint's pre-existing capability that `ModuleKind` and `ModuleInstanceId` are decoupled — the same module *kind* can be instantiated multiple times. (See `fedimint-core/src/core.rs`: "rare, but possible".)
- **What this still does NOT provide**: a peg mechanism, a collateral pool, or any oracle. It only labels notes with a unit. Whether those notes are *redeemable* for the labeled asset is entirely the responsibility of whatever module / off-chain process backs them.
- Backporting to `releases/v0.11` indicates this is intended for production federations, not just master-branch experimentation.

## See also

- [[2026-05-28-fedimint-pr-7734-multi-currency-support|PR #7734]] — the prerequisite core change
- [[2026-05-28-fedimint-discussion-8218-gold-stablecoins|Discussion #8218]] — dpc on what's still missing (peg, oracle, real assets)
- [[2026-05-28-fedimint-issue-8217-external-modules-broken|Issue #8217]] — Fedi's stability pool external-module port pain
