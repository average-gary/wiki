# Wiki Log

## [2026-05-20] init | created project-local wiki at `.wiki/` for `feat/iroh-transport` branch

## [2026-05-20] research | "Iroh integration for Stratum v2 applications" --deep → 19 sources ingested, 11 articles compiled (3 topics + 8 concepts + 1 reference), 2 candidate theses

## [2026-05-20] gap-close | Fedimint Iroh integration → 1 source ingested, 1 concept added (`fedimint-as-reference.md`); playbook revised: per-role ALPN, two-layer identity model, mandatory operational primitives (keepalive, per-request timeout, bind-error propagation, observability)

## [2026-05-23] librarian | first scan: 14 articles, 14 stale (structural — missing `verified:` + `volatility:`), 0 low-quality (avg staleness 47, avg quality 91). Content quality is excellent; the playbook scores 100/100. Recommended fix is the same metadata backfill that landed in two other wikis on 2026-05-21.

## [2026-05-23] librarian | structural fix applied: `verified: 2026-05-20` + `volatility:` added to all 14 articles. Tiers: hot for living-doc articles, cold for paper/baseline-grounded articles, warm elsewhere. reference/specs-and-crates tagged `compiled-from: conversation`.

## [2026-05-26] plan | "draft a branch with the network transport abstraction that would be an upstream PR to sv2-apps" → output/plan-sv2-transport-abstraction-pr-2026-05-26.md (7 articles consulted, 5 decisions, 9 phases)

## [2026-05-27] plan | "update to latest rc for iroh" → output/plan-iroh-rc-1-bump-2026-05-27.md (5 articles + 2 gap-fills consulted, 5 decisions, 6 phases). Gap research found rc.1 published today 2026-05-27; rc.0→rc.1 breakage surface (FourTuple Path API, AccessControl trait, IncomingLocalAddr rename, noq@1.0.0-rc.1) does not intersect SV2 transport code per grep audit.

## [2026-05-27] gap-close | iroh 1.0.0-rc.1 release notes ingested (raw/articles/2026-05-27-iroh-1-0-0-rc-1.md); rc.0→rc.1 has zero impact on SV2 transport surface (verified via cargo build + full integration test suite — pool/jd/translator iroh tests + fallback_iroh_to_tcp all pass on rc.1 with no source code changes). iroh-endpoint-and-alpn.md + iroh-relays.md re-verified against docs.rs/iroh/1.0.0-rc.1; `verified: 2026-05-27`. Sources count 20 → 21.
