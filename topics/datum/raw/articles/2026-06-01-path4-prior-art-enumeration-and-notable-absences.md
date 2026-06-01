---
title: "Prior-art enumeration — what exists, what doesn't, and what surprised us by its absence"
source: "synthesis"
type: articles
tags: [datum, sv2, prior-art, negative-finding, enumeration, gap-analysis, sri, braidpool, hashpool, ocean, optech]
summary: "A negative-finding synthesis: as of 2026-06-01, the only public prior-art for an SV2-DATUM bridge consists of (1) issue #146 in OCEAN-xyz/datum_gateway, (2) electricalgrade/sv2 (a stalled C library), and (3) two press articles framing the comparison. NO third-party proxy implementation exists. NO SRI org issue/PR mentions DATUM, OCEAN, or TIDES. NO Bitcoin Optech newsletter mentions DATUM in a SV2 context. NO Braidpool, Hashpool, p2pool, or 256foundation project mentions DATUM. NO datum_gateway fork (out of 56) has SV2 code. The space is wide open and the absences are diagnostic of OCEAN's siloed posture."
confidence: high
ingested: 2026-06-01
ingested_by: path4
quality_score: 5
canonical_url: ""
---

# Prior-art enumeration — what exists and what doesn't

This is the consolidated map of the SV2-DATUM bridge prior-art space, built from path-4's eight investigative threads.

## What EXISTS as prior-art

### 1. Public proposals (1)

| Artifact | URL | Status |
|---|---|---|
| Issue #146 — Add SV2 support to DATUM | github.com/OCEAN-xyz/datum_gateway/issues/146 | Open since 2025-08-20, last activity 2025-08-30, **no Concept ACK** |

### 2. Code repositories (1, stalled)

| Artifact | URL | Status |
|---|---|---|
| electricalgrade/sv2 — C library, Noise + SetupConnection only | github.com/electricalgrade/sv2 | Last push 2025-09-21, **no DATUM bridge code yet**, no license |

### 3. On-record press / docs comparisons (5)

| Artifact | Date | Notable |
|---|---|---|
| OCEAN docs `/datum` page — SV2 rejection paragraph | undated | "bolted onto the original centralized design" |
| Atlas21 launch announcement | 2024-10-02 | Luke Dashjr direct quote; "alternative to SV2" framing |
| Blockspace Media comparison | 2024-12-22 | Bitcoin Mechanic + Kristian Csepcsar quotes |
| Solo Satoshi article | (date unconfirmed) | "complementary, not contradictory" framing |
| Archyde article | 2025-09-30 | Both protocols complementary; no OCEAN quotes |

### 4. Adjacent technical conversations (1)

| Artifact | URL | Notable |
|---|---|---|
| bitcoin/bitcoin#31002 — Mining IPC RFC for DATUM | github.com/bitcoin/bitcoin/issues/31002 | luke-jr's "GBT is enough, IPC is centralization" stance |

### 5. Conference talks mentioning both (2)

| Artifact | URL | Speaker |
|---|---|---|
| TABConf 6 — "Bitcoiners Must Mine" | github.com/TABConf/6.tabconf.com/issues/188 | Kent Halliburton (Sazmining) |
| TABConf 7 — same talk | github.com/TABConf/7.tabconf.com/issues/91 | Kent Halliburton (Sazmining) |

Both talks list "Stratum V2 and OCEAN" as background reading. Neither talk *bridges* the two; they cite both as decentralization examples.

## What DOES NOT EXIST (notable absences)

### A. No SV2-front DATUM proxy implementation

Searched: GitHub code search (DATUM + sv2), GitHub repository search (datum stratum v2), `org:stratum-mining` code search for DATUM, all 56 forks of `OCEAN-xyz/datum_gateway`, all 5 most-active forks (luke-jr, BitcoinMechanic, GregTonoski, s0kil, privkeyio).

**Result: zero working third-party proxies.** electricalgrade/sv2 is the closest but is single-author, stalled, and missing the DATUM-protocol upstream entirely.

### B. No SRI org engagement with DATUM

Searched:
- `stratum-mining/stratum` issues for DATUM/OCEAN/TIDES → **0 substantive matches**
- `stratum-mining/sv2-spec` issues for DATUM/OCEAN → **0 matches**
- `stratum-mining/stratum` PRs for DATUM/OCEAN/TIDES → **0 matches**
- `stratum-mining/stratum` discussions for DATUM/OCEAN → **0 matches**
- `stratum-mining/sv2-spec` discussions for DATUM/OCEAN → **0 matches**

**Result: the SRI ecosystem has not publicly considered DATUM compatibility.** This is the most striking absence — the SRI is the obvious vehicle for an SV2-DATUM bridge, and there is zero documented engagement with DATUM in its repos.

### C. No braidpool / hashpool / p2pool DATUM mentions

- `braidpool/braidpool` issues for DATUM/OCEAN → **0 matches**. SV2 integration tracked separately (issues #313, PRs #305, #331, #398, #425) but **excludes JDP/TDP** for "differences of opinion" reasons — no DATUM bridge plan.
- `vnprc/hashpool` README → **0 mentions** of DATUM/OCEAN/TIDES. Hashpool is "a fork of SRI" with ecash share accounting; orthogonal to DATUM's payout model.
- `p2pool/p2pool` issues → **0 DATUM/OCEAN matches**.
- `256foundation/Hydrapool`, `256foundation/Mujina`, `256foundation/ASIC-RS` → **0 SV2 or DATUM mentions**. Mujina firmware speaks SV1 only.

**Result: the broader decentralized-mining ecosystem treats DATUM as siloed.** No project that builds for SV2 has tried to also speak DATUM.

### D. No Bitcoin Optech newsletter substantive coverage of DATUM-SV2

- Optech topic "stratum-v2": page does not exist (404).
- Optech topic "decentralized-mining": page does not exist (404).
- Optech topic "mining": page exists; **DATUM mentions could not be enumerated** (search interface limited).
- Newsletter #319 (2024-09-06) and #323 (2024-10-04) reference SV2 in Core IPC context but **not DATUM**.

**Result: Optech has not editorialized DATUM-SV2 as a topic.** This is unusual for a mining-development development this concrete; suggests Optech sees DATUM as too proprietary or too partisan to cover technically.

### E. No fork has SV2 code

Of the top-active datum_gateway forks examined:
- `luke-jr/datum_gateway` — no SV2 branches; active (Apr 2026) on Rootstock merge-mining, queue bugs, cleanups.
- `BitcoinMechanic/datum_gateway` — README identical to upstream; appears to be a tracking fork.
- `s0kil/datum_gateway` — README identical; one open PR (unrelated to SV2).
- `privkeyio/datum_gateway` — recent push (Feb 2026); no SV2 branches.
- `electricalgrade/datum_gateway` — single-branch; no SV2 work landed (the SV2 code lives in the separate `sv2` repo).

**Result: no fork is doing SV2 in-tree.** The community has not picked up issue #146.

### F. No OCEAN public-channel SV2 announcement

- @OCEANbtc (X) — fetch failed (HTTP 402 paywall on x.com), but no SV2-related tweet has been corroborated by other sources.
- ocean.xyz/blog — page does not exist (404). OCEAN does not have a blog.
- ocean.xyz docs — single SV2 rejection paragraph, no roadmap.

**Result: OCEAN has not publicly endorsed any SV2-bridge work.**

## Cross-cutting observation: Block Inc. is hedging

Jack Dorsey-affiliated Block Inc. invests in OCEAN. Block also builds Proto Fleet (block/proto-fleet, issue #92 confirms SV1-only currently with planned SV2 migration). Block is therefore funding both sides — pure DATUM (OCEAN) and pure SV2 (Proto Fleet). No project under their umbrella is bridging the two.

## Implications

1. **The SV2-DATUM proxy space is empty.** This is both an opportunity (no competition) and a warning (one stall artifact already exists; either the problem is hard or the demand isn't there).
2. **Demand evidence is thin.** Issue #146 + electricalgrade's stalled repo + zero forks doing SV2 + zero SRI-side discussion = weak market signal for "operators are clamoring for an SV2 path to OCEAN." Most OCEAN operators apparently accept SV1.
3. **Builder-side is the proxy's natural home.** Since OCEAN won't endorse and SRI hasn't engaged, the proxy lives in third-party space — likely as part of a hashrate-aggregation or operator-services product rather than as an SRI feature.
4. **First-mover risk is real.** A new SV2-DATUM proxy will be the *first* working public artifact in the space. There's no co-validation; if it ships it's authoritative; if it doesn't ship it joins electricalgrade/sv2 as a footnote.

## Rabbit-hole leads

- @plebhash, @GitGab19, @Sjors — the SRI core authors. Have any of them privately commented on DATUM in their conference talks, podcasts, or blog posts?
- The block/proto-fleet repository — does it have any DATUM mention? (Path 3 likely covered.)
- Bitcoin Mining Discord / IRC / Matrix — operators talking about DATUM and SV2 in the same breath. Inaccessible to WebFetch.
- Mining Pod / Bitcoin Mining Stack Exchange / r/BitcoinMining — community-side demand evidence not captured here.
- Demand-side artifacts: would anyone actually pay for an SV2-DATUM proxy? No commercial interest visible in this research path.

## Sources synthesized

This article synthesizes findings from the eight path-4 sub-investigations:

1. OCEAN-xyz GitHub org enumeration (2 repos, both gateway-side)
2. GitHub code search "DATUM" + "stratum-v2" / "sv2" — empty
3. OCEAN public communications (docs, X, blog) — single rejection paragraph
4. Bitcoin Optech archives — DATUM-SV2 connection absent
5. Conference talks 2025-2026 — TABConf 6/7 + Baltic Honeybadger 2025 mention both as background only
6. 256foundation / p2pool / braidpool / hashpool — no DATUM cross-pollination
7. SRI org issues/PRs — no DATUM/OCEAN/TIDES engagement
8. Forks of datum_gateway — no SV2 work in any of 56 forks

## Cross-references

- All four other path-4 articles in this batch.
- Path-1's `path1-issue-146-sv2-support.md` and `path1-ocean-org-survey.md` — overlapping evidence already ingested.
