---
title: "OCEAN Miner Sentiment — community reception 2024-2026"
publication: bitcointalk + Stacker News
type: article
ingested: 2026-05-23
quality: 4
credibility: medium
confidence: medium
tags: [OCEAN, TIDES, sentiment, miner-feedback, Dashjr, BOLT12]
---

# OCEAN Miner Sentiment (2024-2026)

Aggregated miner-community reception of OCEAN's TIDES + DATUM since launch (March 2024). Wiki already has the heatpunks empirical thread; this captures broader sentiment.

## Sources (6 distinct)

| # | Source | Date | Sentiment | Quality |
|---|---|---|---|---|
| 1 | bitcointalk 5503061 ("Ocean.xyz shares going backwards!") | 2024-07-15 | Negative (UX/variance confusion) | 3/5 |
| 2 | Stacker News 403182 ("Ocean Scoring System - Explanation?") | 2024-01-27 | Mixed leaning negative (transparency) | 4/5 |
| 3 | Stacker News 335672 (Ordinal filtering) | 2023-12-02 | Negative (Dashjr filter politics) | 3/5 |
| 4 | Stacker News 1216990 ("Why Ocean says its miners make more money") | 2025-09-11 | Mixed (variance vs. low fee) | 4/5 |
| 5 | Stacker News 908411 ("LN Payouts On Ocean Pool?") | 2025-03-09 | Mixed leaning negative (BOLT12 friction) | 4/5 |
| 6 | Stacker News 851025 (BOLT12 setup with Coinos) | 2025-01-15 | Positive with friction | 4/5 |

## Sentiment buckets

### Variance / payout unpredictability
- **bitcointalk #1**: Small miner (4 TH/s) panicked when share count fell from 17G → 16.85G with no block found. mikeywith explained TIDES replaces shares as others submit more. Concrete UX failure: TIDES counter unintuitive enough that even moderate-hashrate miners think they're losing money.
- **SN #2** (early adopter, 2 months post-launch): "feels like a lotta trust me bro with them so far" vs. Braiins' clear documentation. Documented "TIDES tail extends past stopping" effect.
- **SN #4** (joyfam, 2025): "rolling the dice with expensive equipment" — professional-miner skepticism about variance on amortized hardware.

### UX / documentation / Lightning friction
- **SN #5** (siggy47): OCEAN's BOLT12 / CLN-only Lightning payout requirement is "unexplained" and undocumented. Channel liquidity must come from miner side. Excludes LND-using miners. **15 comments** = highest-engagement payout-mechanics thread.
- **SN #6** (BOLT12 Coinos tutorial): memo-format errors, Sparrow signing failures.

### Dashjr filter politics (separate from TIDES)
- **SN #3**: harrr — "Miners who decide based on ideology and not economics will not survive." Direct rejection of OCEAN's Knots-based filtering on profitability grounds, not TIDES grounds.

### Praise — non-custodial, low fees, decentralization
- **SN #6 comments**: "fairest payout system in bitcoin's history."
- **SN #4 explainer** (Super Testnet): articulates the 1% admin fee + no luck fund advantage.
- Bitaxe / S9 miner-context — confirms hobbyist segment is OCEAN's enthusiastic core.

## Synthesis

OCEAN reception breaks cleanly into **four orthogonal axes**:

1. **TIDES-as-mechanism**: confusing for new miners; variance is real and felt; long-horizon math is correct but short-horizon UX is rough.
2. **Operations**: BOLT12-only Lightning is a UX wall; CLN-only excludes LND users; tutorials exist but config errors common.
3. **Politics**: Dashjr's Knots/Ordinals stance polarizes — separate from payout mechanics.
4. **Principle**: small miners praise non-custodial design; "fairest payout" sentiment exists in the cypherpunk segment.

**Professional miners (Foundry, MARA, Riot engineers) are largely absent from public OCEAN discussion.** That itself is a data point: OCEAN's natural audience as of 2026 is hobbyist + sovereign-miner, not industrial.

## Significance for wiki

Updates the [[../../wiki/topics/why-fpps-dominates-but-is-fragile|"Why FPPS Dominates"]] article: the cypherpunk/sovereign segment OCEAN serves is small and self-selected. Industrial miners' silence on OCEAN suggests the FPPS dominance won't break from grass-roots sentiment alone — would require either a specific event (custody failure at major FPPS pool, regulatory action) or post-subsidy fee economics making FPPS structurally untenable.

## Open gaps

- Reddit r/BitcoinMining / r/Bitcoin / r/btc — unreachable from this fetch (some sub-Reddits return 403). Recommend follow-up via authenticated Reddit access.
- Twitter/X sentiment from named miner accounts (Econoalchemist, Diverter, Bitcoin Mechanic) — nitter mirrors captcha-walled.

## See also

- [[../../wiki/concepts/tides|TIDES]]
- [[../../wiki/topics/why-fpps-dominates-but-is-fragile|Why FPPS Dominates]]
- [[2026-05-23-heatpunks-tides-vs-fpps-experiment|heatpunks empirical (already ingested)]]
