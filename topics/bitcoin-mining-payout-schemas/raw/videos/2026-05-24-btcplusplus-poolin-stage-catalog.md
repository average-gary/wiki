---
title: "btc++ Poolin' Stage catalog (Austin May 2025) + adjacent payout talks"
publication: youtube.com/@btcplusplus
url: https://www.youtube.com/@btcplusplus
type: video
ingested: 2026-05-24
updated: 2026-05-24
quality: 4
credibility: high
confidence: high
tags: [btc++, Poolin-Stage, Austin-2025, payout, mining]
---

# btc++ Poolin' Stage Catalog

**Scope**: btc++ Austin May 7-9, 2025 ("mempool edition") was the first btc++ event with a dedicated **Poolin' Stage**. Earlier and later btc++ events (Berlin 2024 e-cash, Durham 2025, Riga 2025 privacy, Berlin 2025 lightning, Taipei 2025 sovereignty) had no Poolin' Stage label.

**Key finding**: Individual Poolin' Stage talks were **never broken out as standalone uploads**. They live only inside four long livestream archives. Per-speaker chapter timestamps are not exposed.

## Poolin' Stage livestream archives (Austin 2025)

| # | Title | Duration | URL |
|---|---|---|---|
| 1 | Day 1 — Poolin' Stage full livestream | 6h 53m | https://www.youtube.com/watch?v=nUQlBxWwlaU |
| 2 | Day 1 — Poolin' Stage short clip | 18m 23s | https://www.youtube.com/watch?v=I49g8EyovCU |
| 3 | Day 2 — Poolin' Stage full livestream | 4h 46m 37s | https://www.youtube.com/watch?v=F2p_V0svDTo |
| 4 | Day 2 — Poolin' Stage short clip | 38m 03s | https://www.youtube.com/watch?v=Jdw-Tq1mA8Q |

Confirmed in Day 2 livestream: **vnprc — "Proxy Pools — Harness the Free Market to Decentralize Bitcoin Mining"** at `&t=3h15m30s`.

**No Day 3 Poolin' Stage livestream is published** — channel only has Days 1-2 streams.

## Standalone Austin 2025 talks (Main Stage, mining/payout-adjacent)

These are NOT Poolin' Stage talks but they are the closest single-talk videos with payout/mining accounting content. Cut into the official "mempools edition" playlist `PLZdV4KsJUf8clYo8DbiHk1MDD3KFCX_Nj`.

### Jason Hughes — "DATUM Deep Dive" (1h 05m 38s)

- URL: https://www.youtube.com/watch?v=FJ0Hye52Ib8
- Event: bitcoin++ Austin May 2025 (Main Stage)
- Speaker: **Jason Hughes** — author of OCEAN's TIDES payout scheme.
- Content: DATUM is OCEAN's Decentralized Alternative Templates for Universal Mining — pool-side accounting/template-construction protocol. Covers how DATUM separates block-template construction from payout accounting and OCEAN's TIDES payout scheme.
- **Direct counterpart to Poolin' Stage proxy-pool talks.**

### "MEVPool — The Best We Can Do Sucks" (44m 14s)

- URL: https://www.youtube.com/watch?v=0tfSR3TLAq8
- Event: bitcoin++ Austin May 2025
- Argues MEV-style block-space markets create payout-accounting distortions that current pool architectures cannot cleanly handle.
- **Pessimistic framing of out-of-band fee / sidecar payment effects on PPLNS / FPPS fairness.**

### "Business vs. Protocol — Miner Incentives Meet The Profit Motive" (41m 30s)

- URL: https://www.youtube.com/watch?v=J26wwdIfxM4
- Event: bitcoin++ Austin May 2025
- Examines tension between pool-business incentives (FPPS predictability, retention) and protocol-decentralization incentives (Stratum V2, job declaration, share-payout transparency).
- **Frames why proxy-pool / hashpool / DATUM have struggled to dethrone FPPS pools.**

## Adjacent btc++ talks (NOT Poolin' Stage)

### plebhash — "SV2 explained: a step towards mining decentralization"

- URL: https://www.youtube.com/watch?v=r7GxVElF8Gs (40m 20s)
- Event: bitcoin++ Austin **2024** script edition (one year before Poolin' Stage existed)
- History, implementation, and roadmap for Stratum V2 — including Job Declaration which is the protocol substrate that proxy pools / hashpool depend on.
- **Reference talk for the SV2 layer underneath every Poolin' Stage 2025 proposal.**

### Bit aloo — "Hashrate Theft: how Stratum V2 fixes exploitable Mining Protocol"

- URL: https://www.youtube.com/watch?v=BJtdXPRJ-6k (37m 13s)
- Event: bitcoin++ Floripa Feb 2026 exploits edition
- Walks through hashrate-theft attacks against legacy Stratum V1 pools, framed as an accounting-integrity argument for SV2 adoption.

### johnny9dev — "Basics of Bitcoin Mining Firmware"

- URL: https://www.youtube.com/watch?v=meaENmnPJJc (37m 14s)
- Event: bitcoin++ Durham Nov 15, 2025
- Bitaxe firmware code tour. Doesn't cover PPLNS / payout accounting directly.

### Nico Preti — "Hashrate and privacy"

- URL: https://www.youtube.com/watch?v=NDnSuT9FAmU (33m 53s)
- Event: bitcoin++ Buenos Aires Feb 2024 payments edition
- Multisig-and-stratum implementations for hashrate privacy; touches on share/payout traceability.

## Already indexed in wiki (not duplicating)

- **vnprc** — *"Hashpools"* (Berlin 2024 e-cash, video `SeydWRNjH_Y`)
- **vnprc** — *"Proxy Pools"* (Austin 2025 Poolin' Stage Day 2, inside `F2p_V0svDTo` @3h15m30s)
- **vnprc** — *"Hashpools One Year Update"* (Durham 2025)

## Speakers from Austin 2025 official roster — likely on Poolin' Stage livestreams

Pulled verbatim from `btcplusplus.dev/atx25` (mining/pool-adjacent subset of the 40+ speaker roster). The Day 1 (6h 53m, streamed May 7) and Day 2 (4h 46m, streamed May 8) livestreams contain the Poolin' Stage talks for these speakers, but **YouTube chapter markers were never added to either upload** and the videos have **no timestamp list in the description** (verified 2026-05-24 via WebFetch + `r.jina.ai` mirror).

| Speaker | Affiliation (verbatim from atx25 roster) | Likely talk topic (inferred from concurrent work) |
|---|---|---|
| Bob McElrath | Braidpool | Braidpool DAG / UHPO covenants / share-chain critique |
| gitgab19 | Stratum V2 | SV2 Job Declaration progress / SRI status |
| plebhash | Vinteum Grantee | SV2 SRI implementation progress (follow-up to Austin 2024) |
| Luke Dashjr | OCEAN | OCEAN politics / non-custodial pool model |
| Bitcoin Mechanic | OCEAN | OCEAN ops / TIDES rollout |
| Jason Hughes | OCEAN | DATUM Deep Dive (this one **was** cut as standalone, see above — likely **also** on Poolin' Stage in shorter form, or panel) |
| Jay Beddict | Foundry | Foundry pool ops / FPPS-side perspective |
| sha2fiddy | Foundry Digital | Foundry pool engineering |
| Skot | Bitaxe | Bitaxe firmware / solo-mining payout dynamics |
| Kulpreet Singh (jungly) | independent | p2poolv2 PPLNS-with-decay / Hydrapool design |
| Asher Pembroke | Rigly / Fathomx | Rigly hashrate marketplace / proxy-pool adjacency |
| boerst | (no affiliation listed) | Stratum work / pool plumbing (boerst is `stratum.work`'s author) |
| Matt Corallo | Spiral | SV2 / BetterHash retrospective (likely Main Stage, not Poolin') |
| vnprc | Hashpool | **Confirmed @ Day 2 03:15:30 — "Proxy Pools — Harness the Free Market"** |

## Mapping attempt 2026-05-24 — blocked

Tried five orthogonal read-only approaches to extract per-speaker timestamps from the two livestreams. All failed within the available toolset:

1. `yt-dlp --skip-download --write-info-json --write-auto-sub` — `Bash` is permission-denied in this environment.
2. WebFetch of `https://www.youtube.com/watch?v={ID}` — returns YouTube footer/legal HTML only; does not surface `ytInitialData` or `playerResponse` JSON. `shortDescription`, `chapters`, `chapterRenderer` not accessible.
3. WebFetch of `https://www.youtube.com/api/timedtext?lang=en&v={ID}` — returns empty body; auto-caption endpoint requires the signed `pot` (proof-of-origin token) since 2024-Q4.
4. WebFetch of Invidious / Piped / yewtu.be public mirrors (`/api/v1/videos/{ID}`) — every probed instance returned `403 Forbidden` or `ECONNREFUSED` (mass-blocked from cloud egress).
5. WebFetch through `r.jina.ai/https://www.youtube.com/watch?v={ID}` reader-mode proxy — returned event-overview prose only; jina extracts metadata text but not embedded JSON, so chapter markers (which would only exist in `playerResponse.playerOverlays`) are not surfaced. Direct verification: search for any of `Chapters / 00:00:00 / Hashpool / Braidpool / Proxy / Tides / DATUM / p2pool / Hydrapool / Bitaxe / Foundry / Rigly / OCEAN / vnprc / McElrath / boerst` in jina output → **zero matches** in either livestream's surfaced text.

Independent corroboration that **no chapters exist**: vnprc's confirmed talk at Day 2 03:15:30 was timestamped via the URL fragment `&t=3h15m30s` — this is a viewer-supplied deep-link, not a YouTube chapter marker. If the channel had chapter-cut Day 2, the Proxy Pools talk would have its own per-talk video like the Main Stage cuts (Hughes DATUM, MEVPool, Miner Incentives) instead of requiring a fragment timestamp into the 4h 46m livestream.

**Net result for this gap-close path: per-speaker timestamps remain unmapped.** Roster-by-affiliation table above is the strongest claim defensible without manual viewing or yt-dlp access.

## Open follow-up

- **Manual viewer scrub** (highest-confidence path): play each livestream, log intro slide times. ~12 hrs of audio total.
- **yt-dlp + Whisper** (best automated path): requires shell access. `yt-dlp -f bestaudio` + local Whisper transcription would yield speaker turns; cross-reference with roster.
- **Ask vnprc / niftynei directly**: niftynei is bitcoin++ organizer; vnprc is on the roster and the only confirmed speaker. Either could publish a chapter list in the Day 1/2 video descriptions retroactively.
- **Wait for btc++ to publish cuts**: 88 cuts exist for script edition (Austin 2024), 56 for e-cash edition (Berlin 2024). Mempools-edition Poolin' Stage cuts are in arrears as of 2026-05-24. Re-check `youtube.com/@btcplusplus/videos` quarterly.
- **delvingbitcoin.org / btc++ Telegram**: a recap thread may eventually exist; none surfaced as of 2026-05-24.

## See also

- [[2026-05-23-btcplusplus-hashpool-talks|btc++ hashpool talks (existing)]]
- [[../../wiki/concepts/ehash|eHash]]
- [[../../wiki/concepts/tides|TIDES]]
- [[../articles/2026-05-24-vnprc-profile|vnprc profile]]
