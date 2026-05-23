---
title: Open questions and follow-up research
type: decision-log
created: 2026-05-22
updated: 2026-05-22
verified: 2026-05-22
volatility: hot
compiled-from: conversation
status: open
---

# Open questions and follow-up research

Captured from gap-closing round 2 (2026-05-22). Several gap-closing agents hit WebFetch denials; their outputs are seed lists rather than verified findings. The Gap 5 mapping spec (the highest-leverage one) succeeded.

## Verified deliverables (this round)

- **[[../topics/share-accounting-mapping|Share-accounting mapping spec]]** — full SV2 → p2poolv2 message-by-message mapping plus `JobValidationEngine` skeleton, grounded in direct reads of `bitcoin_core_ipc.rs:1-867` and `snapshot_cache.rs:45-74`.

## Open: SV2 vs SV1 quantitative benchmarks (Gap 1)

**Status**: blocked. WebFetch denials prevented fetches of braiins.com, stratumprotocol.org, sv2-spec.

Common circulating claims that need verification:
- "Up to ~3% hashrate uplift" via header-only mining + faster job switching — **unsupported, source: vendor marketing**
- "Bandwidth reduction by an order of magnitude" via binary framing — **unsupported, unitless marketing claim**
- Empty-block elimination via faster `SetNewPrevHash` propagation — **direction plausible, magnitude unverified**

To close: re-run with WebFetch enabled. Sources to hit:
- `braiins.com/stratum-v2`
- `stratumprotocol.org/blog`
- `github.com/stratum-mining/stratum/tree/main/roles` (Criterion benchmarks measure codec/serde, not end-to-end)
- Bitcoin++ talk transcripts (Pavel Moravec, Jan Čapek)

## Open: p2poolv2 architecture docs deep-fetch (Gap 2)

**Status**: blocked. Module-level cross-check is solid (already done at first round); body-text verification is not.

To close: WebFetch each:
- `https://raw.githubusercontent.com/p2poolv2/p2poolv2/main/docs/architecture/{README,async-flow,share-processing-pipeline,store-architecture,store-schema}.md`
- `https://raw.githubusercontent.com/p2poolv2/p2poolv2/main/docs/atomic-swap/README.md`
- `https://raw.githubusercontent.com/p2poolv2/p2poolv2/main/docs/difficulty_adjustment/README.md`

Spot-check rule: docs are LLM-generated per the project's own README caveat. Any claim of column-family layout, key-prefix bytes, or specific function signatures must be checked against `p2poolv2_lib/src/store/` and `shares/`.

## Open: PPLNS variance / uncle-block academic literature (Gap 3)

**Status**: candidate seed list filed at [[../../raw/papers/2026-05-22-pplns-variance-academic-candidates|candidates list]]. Each citation needs verification.

Highest-priority verifications:
1. Rosenfeld 2011 (`arxiv.org/abs/1112.4980`) — closed-form PPLNS variance
2. Lewenberg-Sompolinsky-Zohar 2015 — inclusive block chain protocols (uncle reward economics)
3. Sompolinsky-Zohar GHOST — orphan-rate model

These three combined are the closest analytical foundation for comparing chain-with-uncles vs flat PPLNS vs DAG variance.

## Open: Conference talks / podcasts (Gap 4)

**Status**: blocked. URL candidates filed but not verified.

Candidates worth searching for:
- Bob McElrath — Braidpool talk(s), likely Bitcoin++ Mining edition Austin Oct 2024
- Filippo Merli (SRI) — SV2 architecture talks
- Jason Hughes (OCEAN) — DATUM design rationale, likely SLP and Block Digest
- Chaincode Labs / Bitcoin Dev Podcast — SV2 episode

## Open: design questions surfaced by the mapping spec

These are project decisions, not research questions:

1. **Uncle weighting in SV2 metrics** — `SubmitSharesSuccess.new_shares_sum` is a flat scalar; p2poolv2's chain-with-uncles needs uncle-weighted aggregation. May require a richer trait return type.
2. **`JdToken` → payout-script binding** — `JobValidationEngine` doesn't handle `AllocateMiningJobToken`; persistence design needed in the JDS layer.
3. **Token revocation on share-chain reorg** — trait has no callback; likely needs `notify_share_chain_reorg(new_tip)` extension.
4. **Coinbase-only declarations** — likely have to be rejected (p2poolv2's GBT-style validation needs full wtxid list).
5. **`PushSolution` ↔ `SubmitSharesExtended` ordering** — race not addressed in reference impl; p2poolv2 must handle it without losing block-finder credit.

## Recommended follow-up sequence

1. Re-fetch with WebFetch enabled to close Gaps 1, 2, 4.
2. Verify the three foundational variance papers (Gap 3) before citing.
3. Discuss design questions 1-5 with the p2poolv2 maintainers via GitHub issue or Matrix.
4. Prototype `P2poolV2Engine` against sv2-apps integration tests using the [[../topics/share-accounting-mapping#recommended-jobvalidationengine-skeleton|skeleton from the mapping spec]].
