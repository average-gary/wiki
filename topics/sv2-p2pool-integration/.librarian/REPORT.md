# Librarian Report — 2026-05-23

> Scanned 11 articles in `sv2-p2pool-integration`. First scan. Passes: staleness, quality.

## Headline finding

**All 11 articles flagged stale — but the cause is structural, not content drift.** Every article is missing both `verified:` and `volatility:` frontmatter fields. The verification-recency dimension contributes 0 of 25 to the composite, capping every article at ~50/100 even though all were compiled 1 day ago.

This is the same fix-pattern that landed in `gtx-1060-headless-ai-server` and `rust-multi-platform` on 2026-05-21. Recommended remediation is identical: add `verified: 2026-05-22` and a `volatility:` tier to every article's frontmatter. Quality scoring is unaffected and is uniformly excellent (avg 90/100).

## Summary

| Metric | Value |
|--------|-------|
| Articles scanned | 11 |
| Below staleness threshold (70) | 11 (structural — see above) |
| Low quality (< 50) | 0 |
| Average staleness | 49/100 (capped) |
| Average quality | 90/100 |

## Stale Articles

All 11 stale by the protocol. Top factor for 9 of them is missing `verified:`; the other 2 (reference + decision-log) additionally lack `sources:`.

| Article | Score | Top Factor | Recommendation |
|---|---|---|---|
| [sv2-integration-surface](../wiki/concepts/sv2-integration-surface.md) | 50/100 | unverified | structural-fix |
| [stratum-v2-overview](../wiki/concepts/stratum-v2-overview.md) | 50/100 | unverified | structural-fix |
| [braidpool](../wiki/concepts/braidpool.md) | 50/100 | unverified | structural-fix |
| [p2poolv2](../wiki/concepts/p2poolv2.md) | 50/100 | unverified | structural-fix |
| [p2pool-history](../wiki/concepts/p2pool-history.md) | 50/100 | unverified | structural-fix |
| [ocean-datum](../wiki/concepts/ocean-datum.md) | 50/100 | unverified | structural-fix |
| [integration-paths](../wiki/topics/integration-paths.md) | 50/100 | unverified | structural-fix |
| [why-decentralized-pools-struggle](../wiki/topics/why-decentralized-pools-struggle.md) | 50/100 | unverified | structural-fix |
| [share-accounting-mapping](../wiki/topics/share-accounting-mapping.md) | 50/100 | unverified, status: draft | structural-fix + draft → confirmed |
| [decisions/open-questions](../wiki/decisions/open-questions.md) | 25/100 | no `sources:`, unverified | structural-fix (or accept type=decision-log exemption) |
| [reference/repos](../wiki/reference/repos.md) | 25/100 | no `sources:`, unverified | structural-fix (or accept type=reference exemption) |

## Low Quality Articles (quality < 50)

None.

## Notable quality flags

| Article | Quality | Flags |
|---|---|---|
| reference/repos | 70/100 | unverified, no-sources, thin-coverage |
| decisions/open-questions | 80/100 | unverified, no-sources (expected for decision-log) |
| share-accounting-mapping | 95/100 | unverified, **status: draft** — flag for promotion review |

## All Articles (sorted by quality desc)

| Article | Staleness | Quality | Flags |
|---|---|---|---|
| stratum-v2-overview | 50 | 95 | unverified |
| braidpool | 50 | 95 | unverified |
| p2poolv2 | 50 | 95 | unverified |
| p2pool-history | 50 | 95 | unverified |
| ocean-datum | 50 | 95 | unverified |
| integration-paths | 50 | 95 | unverified |
| why-decentralized-pools-struggle | 50 | 95 | unverified |
| share-accounting-mapping | 50 | 95 | unverified, draft-status |
| sv2-integration-surface | 50 | 90 | unverified |
| decisions/open-questions | 25 | 80 | unverified, no-sources |
| reference/repos | 25 | 70 | unverified, no-sources, thin-coverage |

## Recommended follow-ups

1. **Wiki-wide structural fix** — add `verified:` and `volatility:` to all 11 articles. Most are conceptual and warm-volatility appropriate; `share-accounting-mapping` and `integration-paths` are project-living docs and should likely be `hot`. After the fix, re-scan should show staleness ~95-99 across the board.
2. **`share-accounting-mapping` is `status: draft`** — the body is detailed and well-grounded but the open-questions section flags 7 unresolved design points. Either promote to confirmed and split the open-questions into `wiki/decisions/`, or keep `status: draft` and pair with [Quality flag: draft-status](#).
3. **`decisions/open-questions` and `reference/repos`** — neither is a sourced article in the librarian's sense. Consider amending the librarian protocol to exempt `type: decision-log` and `type: reference` from the source-chain integrity dimension, OR add minimal `sources:` (the decision-log can cite the share-accounting-mapping; reference/repos can cite itself).
4. **Inventory candidate**: a recurring "verify once a quarter" task on this wiki — the integration target is a fast-moving codebase (sv2-apps, p2poolv2, braidpool all have weekly commits), so even after the structural fix the verified-recency dimension will degrade quickly.
