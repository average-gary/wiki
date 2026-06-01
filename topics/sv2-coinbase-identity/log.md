# sv2-coinbase-identity log

## [2026-05-28] init
Topic wiki created. Thesis filed. Phase 0 decomposition complete; charitable reframe approved (signature = unique per-miner string).

## [2026-05-28] research --mode thesis | "SV2 user_identity → Pool → coinbase per-miner tag (no JD)"
5 agents launched (Supporting / Opposing / Mechanistic / Meta / Adjacent). 7 sources ingested (5 articles + 1 repo + 1 spec PR). 6 concept articles + 1 topic article + 1 thesis-with-verdict compiled. Verdict: **Partially Supported (high confidence)**. Mechanically feasible — SRI's `JobFactory::new(version_rolling_allowed, pool_tag, miner_tag)` already takes a `miner_tag` parameter; the Pool constructor `new_for_pool` simply passes `None`. Off-spec but not anti-spec; weaker trust than JD.
