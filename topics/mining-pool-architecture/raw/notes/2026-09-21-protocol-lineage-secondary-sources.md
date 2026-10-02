---
title: "Protocol lineage: getwork, Slush Pool, p2pool, and the Stratum V2 origin story (secondary sources)"
source: "https://en.bitcoin.it/wiki/Getwork"
related_sources:
  - "https://en.bitcoin.it/wiki/Slush_Pool"
  - "https://en.bitcoin.it/wiki/P2Pool"
  - "https://en.bitcoin.it/wiki/Stratum_mining_protocol"
  - "https://braiins.com/stratum-v2"
  - "https://stratumprotocol.org"
  - "https://ocean.xyz/docs/datum"
type: notes
ingested: 2026-09-21
tags: [getwork, longpoll, rollntime, noncerange, slush-pool, score-based-shares, pool-hopping, p2pool, share-chain, stratum-history, informal-standardisation, sv2-origin, datum-origin, protocol-lineage]
summary: "Secondary and vendor sources for the lineage, aggregated because none is primary and several are promotional. getwork: JSON-RPC over HTTP, a 60-second long-poll work lifetime, a fresh request on nonce exhaustion, byte-swapping and SHA-2 padding removal required client-side, extended by longpoll / rollntime / noncerange / failover before being superseded — the extensions are the diagnosis, each one buying more local iteration per server round trip. Slush Pool: announced 27 November 2010 as 'a cooperative mining server', the first known pool; began with an artificially low difficulty method, was pool-hopped, and moved to a score-based scheme weighting recent shares more — so the first architectural change in pool history was an anti-gaming accounting fix, not a performance one; coinbase tag /slush/, rebranded Braiins Pool September 2022. p2pool: Forrest Voight, announced 17 June 2011, share chain at a 30-second target with nodes retaining only the last 8,640 shares (~3 days), 99.5% to recent miners and 0.5% to the block announcer. Stratum wiki records the process criticism — no BIP, developed 'behind closed doors'. SV2 origin per Braiins: development from 2019 by Pavel Moravec and Jan Capek with Matt Corallo, spec published 13 November 2019, SRI v1.0 March 2024, motivated by V1's MITM exposure, the loss of miner template control, and hashrate growth from ~10 TH/s to ~600 EH/s."
credibility: low
credibility_score: 1
credibility_rationale: "Community wiki pages plus two vendor pages (Braiins on SV2, Ocean on DATUM). No primary documents. Dates are mostly corroborated by the primary sources ingested separately (the Stratum V1 BitcoinTalk announcement and BIP22/23), which is why this file is kept — but every claim of motive or merit is a secondary or self-interested characterisation."
confidence: low
confidence_rationale: "Dates and mechanics are consistent with the primary sources and can be relied on for narrative. Claims about WHY (design intent, competitive merit, 'first since 2017') are unreliable and flagged inline."
research_round: 1
research_agent: historical
primary_sources_separate: "The two primary lineage documents are ingested as their own files: raw/articles/2026-09-21-stratum-v1-original-announcement-slush.md and raw/papers/2026-09-21-bip22-bip23-getblocktemplate.md. Prefer those."
extraction_note: "Aggregated subagent extraction of six secondary/vendor pages. Marketing claims are labelled VENDOR CLAIM."
---

# Protocol lineage (secondary sources)

> Prefer the separately ingested primaries for anything load-bearing: the **Stratum V1 BitcoinTalk
> announcement (2012-09-11)** and **BIP 22/23 (2012-02-28)**. This file carries the surrounding
> narrative.

## `getwork` — the baseline and its failure

JSON-RPC over HTTP. The miner requests header data and searches for a solution. Superseded by
getblocktemplate, though the data format survives inside some mining software.

Constraints as documented:

- **Long-poll responses had a 60-second limit** before new work should be requested.
- **Nonce exhaustion forced a fresh request** — the fundamental problem, since exhaustion time falls
  linearly with hashrate.
- Client-side preprocessing required: **byte-swapping 32-bit chunks and removing SHA-2 padding.**

Extensions, and this is the informative part — **each one buys more local iteration per round trip**:

| Extension | What it bought |
|---|---|
| `longpoll` | server-initiated notification of new work |
| `rollntime` | adjust the timestamp and reset the nonce — more search space per job |
| `noncerange` | server-assigned nonce ranges for coordinated division of work |
| `hostlist`, `switchto` | failover |

**The diagnosis is legible in the extension list**: getwork's architecture coupled work generation to
validation and made the server's request rate scale with total hashrate. Every extension is an attempt
to amortise one server round trip over more hashes. Both successors — GBT (full template, local
assembly) and Stratum (server push, extranonce space) — are the same move taken to its conclusion. The
lineage from `rollntime` to BIP 310 version rolling is direct.

*(No bandwidth or latency figures, and no dates, are given on this page.)*

## Slush Pool — 27 November 2010

- Announced on BitcoinTalk as **"a cooperative mining server"**; the **first publicly known Bitcoin
  mining pool**.
- **Initial accounting used "an artificially low difficulty method"**, which proved **vulnerable to
  pool hopping** — miners switching based on round progress.
- **First architectural change: a score-based scheme in which older shares in a round are worth less
  than newer ones** ("Slush's method").
- Balances accrued server-side, paid at user-defined thresholds; fee settled around 2%.
- Coinbase tag `/slush/`. Rebrand to **Braiins Pool** announced 21 July 2022, effective September 2022;
  co-founders **Jan Čapek and Pavel Moravec**.

**Worth noting**: the very first change to pool architecture was **an accounting change to defeat
gaming**, not a performance change. The pattern holds across this entire topic — the recurring hard
problems are accounting and incentives, and the same two founders later designed Stratum V2.

## p2pool — 17 June 2011

**Forrest Voight.** Announced 17 June 2011; mainnet testing mid-July 2011; formal review 26 July 2011.

- **Share chain**: "a new block chain in which the difficulty is adjusted so a new block is found every
  30 seconds", running parallel to Bitcoin at 20× the rate.
- **Nodes retain only the last 8,640 shares (~3 days)** — a bounded-history design.
- Validity anchored via referenced Bitcoin blocks, preventing secret-chain attacks.
- Payout: **99.5% to recent contributors proportionally, 0.5% subsidy to the block announcer**; PPLNS
  shape, hopping-resistant.
- Requires each miner to run a **full Bitcoin node**.

Documented reasons adoption stalled: node requirement; **"P2Pool difficulty is hundreds of times higher
than on normal pools"**; expected orphan and dead-on-arrival shares reducing effective returns;
competitors (BitPenny, Eligius) offering comparable decentralisation more simply. Noted:
**"some Bitcoin supporters donate to P2Pool miners, resulting in average returns above 100% of expected
reward"** — i.e. adoption was partly subsidised, which is itself evidence the economics did not stand
alone. A "Lightning P2Pool" proposal addressed payout dust accumulation.

*(p2pool internals belong to `sv2-p2pool-integration`; the variance failure is documented with better
sources in the failure-modes note.)*

## The Stratum wiki page — process criticism

- Emerged **"late 2012"**, announced via Slush's pool site with alternative documentation by BTC Guild.
- **"The extension lacks a formal BIP describing an official standard, it has further developed only by
  discussion and implementation"**, occurring **"behind closed doors without input from the wider
  development and mining community."**
- Characterises GBT as "a mostly superior open standard protocol for mining" whose uptake Stratum's
  adoption diminished.

The process criticism is the durable content: the protocol carrying the overwhelming majority of
Bitcoin hashrate for over a decade **never had a specification with standing**. That is the gap SV2's
public spec and the SRI were meant to close, and it is why BIP 310 exists as a retrofit.

## Stratum V2 origin — VENDOR CLAIM (Braiins)

- Development from **2019** by **Pavel Moravec and Jan Čapek**, with **Matt Corallo** and others.
- Specification publicly released **13 November 2019**.
- **SRI v1.0 released March 2024** by an independent developer group.
- Now "maintained by an independent open source community" beyond Braiins.

Stated motivations:

1. **MITM exposure in V1** creating potential for **undetected hashrate hijacking** — with the page
   noting no confirmed major incident, only the architectural weakness. *(The peer-reviewed
   Recabarren & Carbunar paper supplies the working attack; this is the one motivation with independent
   support.)*
2. **Loss of miner template control** — under V1 miners "lost the ability to construct their own block
   templates (i.e. choose which transactions are in the blocks they mine)."
3. **Efficiency at scale** — hashrate grew from ~10 TH/s to ~600 EH/s, a claimed 60,000× increase,
   making V1's JSON untenable.

**VENDOR CLAIM, do not cite as measured**: "lean binary format, lowering CPU load and cutting bandwidth
use by about 60% for pools and 70% for miners." See the separate vendor-claims file for why these and
the related latency figures are not citable.

## DATUM origin — VENDOR CLAIM (Ocean)

Page published **29 September 2024**. Claims development origins tracing to 2012 concepts, miner-built
templates, direct non-custodial coinbase payouts, and a 50% pool-fee discount as incentive.

**VENDOR CLAIM, and demonstrably loose**: *"first fully decentralized mining protocol since 2017 when
the last decentralized pool shut down."* p2pool operated past 2017 (jtoomim's fork README reports
mainnet blocks in February 2018), and BIP23 specified miner template auditing in 2012. Treat the
priority claim as marketing. The *architecture* is real and is covered with better sources in the
DMND/DATUM deployment file.

## The lineage, compressed

```
solo (getwork)
  → first pool: Slush 2010-11-27  →  accounting fix (score-based) to stop hopping
  → decentralised attempt: p2pool 2011-06-17  →  plateaus on variance
  → formal standard: BIP22/23 2012-02-28 (miner template control specified)
  → de facto standard: Stratum V1 2012-09-11 (wins on deployability; templates become pool-side)
  → ASIC-era scaling: ckpool (~2014, date unverified) + BIP310 version rolling
  → security + efficiency redesign: SV2 spec 2019-11-13, SRI v1.0 2024-03
  → template decentralisation adopted: DATUM 2024-09, first SV2 JD block 2026-06-26,
    Core Mining IPC in official binaries (PR #31802 merged 2025-08-20)
```

**Four forcing functions, each naming what actually moved:**

1. **getwork → Stratum/GBT (2012)**: request rate scaling with hashrate; nonce exhaustion; the
   60-second work lifetime.
2. **GBT vs Stratum (2012)**: deployability beat decentralisation. Stratum claimed 10k+ connections at
   minimal CPU; GBT offered template auditing nobody was paying for.
3. **V1 → V2 (2019)**: industrial scale, MITM exposure, and the recognition that pool-side templates
   had become a governance problem.
4. **Centralised → decentralised templates (2024–26)**: concentration risk (top 3 ≈ 60% as of
   2026-09) plus, finally, tooling that made it affordable — `checkBlock()`, batched wtxid lookup,
   official multiprocess binaries.

**Unverified in this round**: ckpool's 2014 release date (README carries none; needs commit history or
a release announcement), and exact dates for the pushpool / eloipool / python-stratum-mining / MPOS /
NOMP generation.
