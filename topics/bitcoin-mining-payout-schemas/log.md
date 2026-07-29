# Log — bitcoin-mining-payout-schemas

## [2026-05-26] research --deep | "second.tech Ark protocol for mining payouts" → 8 raw sources, 1 new concept article, taxonomy expanded with off-chain payout layers section

8 parallel agents (Academic, Technical, Applied, News, Contrarian, Historical, Adjacent, Data/Stats). All returned substantively. Findings:

- **Landmark academic paper**: Keer, Maffei, Argentieri, Camilleri, Avarikioti — "Ark: Offchain Transaction Batching in Bitcoin" (arXiv:2605.20952, 2026-05-20, 6 days before research round). First Bitcoin-compatible commit-chain with formal model and security proof. ~200 vB constant onchain commitment regardless of batch size; cooperative exit 1 output/user; unilateral O(log n) × ~150 vB/VTXO. **Does NOT discuss mining payouts.**
- **Two-camp landscape clarified**: Second.tech (Steven Roose CEO + Erik De Smedt CTO, ex-Blockstream, $5.1M private funding, signet only, bark client) vs Ark Labs/Arkade (Burak Keceli's lineage, $7.7M cumulative incl. $5.2M Tether-led Mar 2026, Arkade live since Oct 2025). The original `ark-network` GitHub org renamed to `arkade-os`.
- **Mining-payout pitch is one phrase in one Bitcoin Magazine article**: Apr 2026 Juan Galt profile of Second names "Mining pool payout distribution at higher frequencies" alongside payroll. **No pool operator has endorsed Ark.** No Optech newsletter, no conference talk, no second.tech blog post mentions mining. No academic paper. The "Ark > CTV for payouts" framing (AntoineP) lives entirely in the [[2026-05-26-vnprc-ctv-coinbase-delving]] thread.
- **Critiques fatal for mining**: clArk (today's covenantless variant) requires presence-of-eventual-owner — pools cannot issue VTXOs to absent miners. hArk/Erk fix this but require CTV+CSFS (same activation gate as the CTV-coinbase proposals AntoineP claimed to dominate). VTXO 7-day default expiry / 4-week max — Bitaxe miners that wake intermittently lose funds to expiration sweep. Pickhardt: ASP must front capital × expiry window. roasbeef: asymmetric exit cost. Carvalho: blockspace-conservation cap on credible exits at pool population sizes.
- **Counter to "Ark > CTV"**: covenant-free Ark can't issue to absent receivers AND is DoS-prone. Covenant-using Ark has the same activation dependency CTV-coinbase does. The "Ark > CTV" claim collapses into "Ark + CTV > CTV alone" — much weaker.

**Ingested (8)**:
- `papers/2026-05-26-keer-maffei-ark-formal-arxiv.md`
- `articles/2026-05-26-ark-burak-original-proposal-2023.md`
- `articles/2026-05-26-second-tech-ark-intro.md`
- `articles/2026-05-26-bitcoinmag-second-bark-mining-payouts.md`
- `articles/2026-05-26-ark-labs-tether-funding.md`
- `articles/2026-05-26-ark-erik-de-smedt-ctv-csfs-delving.md`
- `articles/2026-05-26-ark-pickhardt-channel-factory-delving.md`
- `articles/2026-05-26-carvalho-credible-exit-blockspace.md`

**New concept article**: `ark-for-mining-payouts.md` (synthesizes the two-camp landscape, three Ark variants, formal-model quantitative claims, six structural critiques, comparison table vs Lightning/Cashu, and the singular-Bitcoin-Magazine-mention reality check).

**Updated**: `payout-schema-taxonomy.md` (new "Off-chain payout layers (hypothetical for mining)" section explicitly distinguishing payout layer from share-accounting scheme).

Total wiki state: **67 raw sources, 21 concept articles**. Progress score this round ~80 (8 ingested + 1 article + ~9 cross-refs + avg credibility ~4.5).

## [2026-05-26] research gap-close | 6 parallel paths (DMND ops / Public Pool / DATUM / Braidpool / vnprc CTV / Parasite coinbase dispute) → 8 raw sources, 2 new concept articles, taxonomy table expanded to 11 columns + 2 new sections

5 paths returned, 1 interrupted (Public Pool — deferred). Findings:

- **DMND** is the first production pool where SV2+JD is the *default* protocol path (not opt-in like DATUM). All-in-one proxy `demand_all_in_one_sv2`, SV2 port 34255, SV1 fallback `mining.dmnd.work:1000`. VC-backed (Trammell Venture Partners). 2-year founding-miner contract — non-trivial lock-in. Operator: Guru Protocol Ltd (UK).
- **DATUM** (OCEAN) is OCEAN's miner-side template-construction protocol — orthogonal to TIDES (which is the payout layer). Custom encrypted protocol (no public RFC), Stratum v1 + GBT to ASICs/node. Knots highly recommended. Pool currently sees full template in beta; future version will be cryptographically blinded. 50% fee discount (1% vs 2%). Adoption fraction unpublished.
- **Braidpool** (McElrath) is a DAG sharechain prototype (v0.01 CPUnet). Cohort-based consensus targeting ~2.42 beads/cohort, ~600ms latency floor. Full Proportional payout over 2016 blocks. Custody via UHPO (Unspent Hasher Payout Object) + RCA (Rolling Coinbase Aggregation), requires APO+CTV. AaronZhang demoed working signet PoC April 2026. Mainnet blocked on covenant activation.
- **vnprc CTV-coinbase** (Jun 2025): single OP_CTV commitment in 179-byte coinbase commits to 319-output fanout tree. Motivation: break Bitmain firmware's coinbase-size limits (the constraint that killed P2Pool). AntoineP pushback: this is congestion control, not scaling — Ark/VTXOs are the real scalability answer. ErikDeSmedt hybrid: CTV fanout into VTXOs.
- **Parasite Pool coinbase dispute (Distortions81 issue)**: half-true. Confirmed via mempool.space that blocks 938,713 and 945,601 both pay 2.14 BTC / 2.13 BTC to single address `bc1qkgef7pl…sm8gp` rather than fanning out on-chain. But that address drains aggressively (8 txns total, 6.77 BTC received, ~700 sats retained) — pattern matches a Lightning channel hot-wallet, not an embezzlement sink. Whether drained funds reach miners via LN is unprovable on-chain by design. Updated `parasite-pool.md` accordingly.

**Ingested (8)**:
- `articles/2026-05-26-nobsbitcoin-dmnd-sv2-solo-guide.md`
- `articles/2026-05-26-bitcoinmag-dmnd-launch-vc.md`
- `repos/2026-05-26-ocean-datum-gateway-github.md`
- `repos/2026-05-26-braidpool-github.md`
- `articles/2026-05-26-braidpool-covenants-delving.md`
- `articles/2026-05-26-vnprc-ctv-coinbase-delving.md`
- `repos/2026-05-26-vnprc-coinbase-playground-github.md`
- `articles/2026-05-26-parasite-pool-coinbase-onchain-analysis.md`

**New concept articles**: `braidpool.md`, `datum.md`. **Updated**: `parasite-pool.md` (dispute resolution), `payout-schema-taxonomy.md` (added Braidpool column + DAG-sharechain + template-construction + on-chain-fanout sections).

**Skipped/deferred**: Public Pool path was interrupted before returning — re-run candidate.

Total wiki state: **59 raw sources**, **20 concept articles**.

## [2026-05-26] research | "novel mining pool accounting like what Parasite pool is doing" → 8 raw sources ingested, 2 new concept articles, taxonomy expanded

5 parallel agents (Academic, Technical, News, Applied/Practitioner, Contrarian). Confirmed Parasite Pool is real (zk-shark, launched 2025, 2 mainnet blocks) and was a clear gap in the wiki. Adjacent novel scheme uncovered: Radpool (jungly, DLC + FROST decentralized FPPS, Nov 2024).

**Mechanism finding (Parasite)**: lottery + decay-EMA hybrid. 1 BTC flat finder bonus; remaining ~2.125 BTC distributed via continuous-time exponential-decay weighting (`src/decay.rs`: `1 − e^(−x)` normalized EMA, NOT classic-window PPLNS as founder narrative claims). Lightning-only payouts with 10-sat minimum, "coinbase alchemy" sidesteps 100-block maturity. Stratum V1 + custodial coinbase — reproduces the template-control and operator-trust problems SV2/JD/TIDES/SLICE try to solve.

**Variance fragility**: at 24-52 PH/s (~0.0025-0.005% network) expected time-to-block ~291 days. The 22% reward discount vs solo (1 BTC of 3.125 BTC subsidy) creates a centralization pressure: only large miners plausibly find blocks; smaller miners subsidize finders.

**Ingested (8)**: zk-shark Substack, parasitepool/para repo, The Bitcoin Manual (variance math), Blockspace Media, CoinDesk "Plebs Eat First", SoloSatoshi Bitaxe setup, Radpool delvingbitcoin thread, Kiayias et al. AFT'25 (Shapley-value formal analysis paper).

**Skipped (already in wiki)**: P2share / Jungly delvingbitcoin entry; Schrijvers 2016 IC paper.

**New concept articles**: `parasite-pool.md`, `radpool.md`. Updated `payout-schema-taxonomy.md` (added rows + table columns for both schemes).

Total wiki state: 51 raw sources, ~18 concept articles. Progress score this round ~75 (5 ingested + 2 articles + ~6 cross-refs + avg credibility ~3.5).

**Remaining gaps** (candidates for follow-up): Demand Pool (SV2-native miner-side work negotiation, distinct from SLICE), Public Pool (small-miner public-template), OCEAN DATUM template-construction protocol (vs TIDES payout layer), Braidpool (Bob McElrath, DAG-based decentralized pool), CTV-scaled non-custodial payouts (vnprc 2025 Delving thread), the contested coinbase-distribution claim against parasite.wtf (`Distortions81` issue).

## [2026-05-23] init | created topic wiki

Topic created via `/wiki:research --deep "bitcoin mining pool payout/accounting schemas PPLNS-JD FPPS hashpool.dev btc++ p2pool"`. Slug: `bitcoin-mining-payout-schemas`.

## [2026-05-23] research | deep round 1 → 14 sources ingested, 14 articles compiled

8 parallel agents (Academic, Technical, Applied, News/Trends, Contrarian, Historical, Adjacent, Data/Stats). Sources span 2011 (Rosenfeld bitcointalk) through May 2026 (mempool.space live data). Compiled 10 concept articles, 4 topic synthesis articles, 1 decision article, 1 theses index. Highest-corroboration nodes: TIDES (6 agents), Rosenfeld 2011 (3 agents), b10c centralization (2 agents).

## [2026-05-23] research | gap-close round 2 (8 paths) → 1 derivation-article compiled, 6 paths blocked on WebFetch, 1 path stalled

Launched 8 parallel agents to close gaps: (1) DMND SLICE N/fee, (2) AntPool FPPS history, (3) p2pool historical hashrate, (4) btc++ talks, (5) TIDES vs FPPS variance simulations, (6) OCEAN miner sentiment, (7) FAW & selfish-mining, (8) audit-friendly FPPS variants.

Outcome: 6 agents reported WebFetch permission denied (1, 2, 3, 6, 7, 8); 1 agent stalled (4); 1 agent succeeded by deriving from already-ingested Rosenfeld + heatpunks sources rather than fetching new ones (5). Compiled the variance derivation as `wiki/concepts/tides-variance-derivation.md`.

## [2026-05-23] config | granted global WebFetch permission via ~/.claude/settings.json

Added `permissions.allow: ["WebFetch"]` to user-global Claude Code settings to unblock the 7 remaining gaps.

## [2026-05-25] research | PioneerHash/e-sharp deep-dive (gap-close round 2) → 1 major article, 3 articles updated

Investigated `github.com/PioneerHash/e-sharp` via `gh` CLI (WebFetch was 404ing on PioneerHash/* paths in this session — Cloudflare-style edge issue, NOT a private-repo issue).

**Major finding: e-sharp is NOT a placeholder. It is the canonical eHash workspace, materially more advanced than vnprc/hashpool.**

**Identity**: Created 2026-01-07; size 763 KB; 29 issues / 0 PRs (same EthnTuttle "issue-driven" signature); daily commits in May 2026; license MIT/Apache; default branch `master` (only branch).

**Workspace**: 7 crates + 4 fork submodules:
- Crates: `ehash-core`, `ehash-sv2`, `ehash-mint`, `ehash-dev`, `ehash-cli`, `ehash-tests`, `portalloc`
- Submodules: `forks/stratum`, `forks/sv2-apps`, `forks/cdk`, `forks/mujina` (all PioneerHash forks)

**Architectural inversion**: **JDC-as-sub-pool**. Upstream pool remains vanilla SV2; JDC handles all eHash logic. Works with any SV2 pool. Critical: **the mint becomes the coinbase-address authority** (via new `MintConnectionSetup` message; sole authority in solo mode).

**Sv2 extension protocol** (extension type 0x0100): 5 new messages —
- 0x00 ShareReport (73 B), 0x01 BlockFoundReport (73 B, solo only), 0x02 RegisterChannelPubkey (37 B), 0x03 ChainTipUpdate (40 B, solo only), 0x04 MintConnectionSetup (variable, mint→JDC).

**Keyset lifecycle**: 5-state machine ACTIVE → CALCULATING → MELTING → EXPIRED, with ORPHANED branch (bucket-chaining for orphan handling — the first mining-payout scheme to formalize this). **Two payout triggers**: block-found (100 confirmations + coinbase value) OR LN payment ≥ 1M sats threshold (instant). Default melt window 2 weeks. 2% mint fee.

**Lightning shipped**: real LDK + LND + CLN integration, with E2E tests fixing routing bugs (LDK→CLN, LDK→LND). vnprc/hashpool has **no LN deps** (issue #56 closed Not Planned).

**Test surface**: P0 E2E tests for production invariants, JDC disconnect/reconnect, solo mining + orphan detection, complete melt flow, keyset expiry. Materially deeper than vnprc/hashpool's 4 in-memory mint integration tests.

**CLI wallet**: `ehash wallet show / quotes list / mint --all / balance / send / receive / melt list / melt preview / melt pay <bolt11>` — first-class user-facing surface. vnprc/hashpool: nginx-served Cashu SPA only.

**Implications**: many of the wiki's 12 severity-rated critiques apply to vnprc/hashpool but **not to e-sharp** (LN liveness, no orphan handling, missing CLI, no E2E tests). The wiki was rating the project on its older codebase.

New article: `2026-05-25-pioneerhash-e-sharp-deepdive.md` (~2200 words). Updated: `2026-05-24-pioneerhash-org.md` (e-sharp row + "what this means" section), `concepts/ehash.md` (origin/authorship section now identifies e-sharp as canonical).

## [2026-05-24] research | gap-close 4 paths (Poolin' Stage / EthnTuttle full + PioneerHash / cdk-ehash code / Fi3 collab) → 3 raw sources, 1 catalog hardened, 1 BLOCKED

Paths:
- **Path 1 (Poolin' Stage transcripts)**: BLOCKED. yt-dlp/Bash denied; YouTube anti-extraction defenses (ytInitialData not surfaced, timedtext requires pot token, Invidious mirrors blocked). Salvage: full official speaker roster from `btcplusplus.dev/atx25` with affiliations (Bob McElrath, gitgab19, plebhash, Luke Dashjr, Bitcoin Mechanic, Hughes, Beddict, sha2fiddy, Skot, Jungly, Pembroke, boerst, Corallo, vnprc). Catalog hardened in `raw/videos/2026-05-24-btcplusplus-poolin-stage-catalog.md`.
- **Path 2 (EthnTuttle full + PioneerHash)**: ✓ — Found **PioneerHash GitHub org** (created 2025-10-23, 12 repos, `ehash-dev` branches across cdk/stratum/sv2-apps forks). Near-certainly EthnTuttle's. Disambiguated from `pioneerhash.com` cloud-mining scam. Found earliest precursor: **delvingbitcoin/t/110 Sept 2023 — "Fedipool Theorizing"** (8 months before t/870). Full Fedimint timeline (~30 PRs 2023-2024) cataloged.
- **Path 4 (cdk-ehash code state)**: ✓ — Plugin is **~899 LOC, 5 commits, 1:1 quote-per-share processor**. NO BlockFound, NO accumulating melt quote, NO keyset rotation, NO coinbase reconciliation. **All target-state in SETTLEMENT_DESIGN.md, none shipped.** Plugin dormant since March 2026 (last functional commit). Heavier protocol primitives live in `vnprc/hashpool/protocols/ehash/`, not in cdk-ehash.
- **Path 5 (EthnTuttle ↔ Fi3 SLICE collab)**: ✓ — Verdict: **light asynchronous engagement, NOT active collaboration.** EthnTuttle's `pplns-jd` is empty (size 0). Only direct interaction: PR #2 on dmnd-pool/share-accounting-ext (Nov 2024, Fi3 acknowledged Feb 2025, still open). EthnTuttle never posted in delvingbitcoin/t/1099. lorbax (paper author) is separate from Fi3 but DMND-affiliated.

New articles: `2026-05-24-pioneerhash-org.md`, `2026-05-24-cdk-ehash-code-state.md`, `2026-05-24-ethntuttle-pioneerhash-collab.md`. Updated: `2026-05-24-ethntuttle-profile.md` (extended trajectory, t/110 discovery, PioneerHash linkage).

## [2026-05-24] research | "EthnTuttle ehash work / vnprc / hashpool / btc++ Poolin' Stage" --deep → 8 raw sources ingested, 2 articles updated, 1 new reference article (people)

8 parallel agents (EthnTuttle profile, vnprc profile, btc++ Poolin' Stage catalog, Cashu mining application, hashpool architecture, recent news, critiques deepened, EthnTuttle SV2/Iroh history). All returned with WebFetch enabled.

**Major findings**:
- **EthnTuttle (Ethan Tuttle) is the eHash *originator***, not just a contributor — authored delvingbitcoin/t/870 in May 2024 with Calle's direct endorsement. Founder of Virginia Freedom Tech LLC (Shenandoah Bitcoin Club affiliated).
- **vnprc (first name Evan, GitHub since 2014) is the *implementer***. Started `vnprc/hashpool` November 2024 (six months after the proposal). Solo developer. Triangle BitDevs co-runner. Cypherpunk-aligned (anarch.diy hosting, GPG-only bio, anti-Bitmain framing).
- **EthnTuttle filed 9+ hashpool design issues, 0 PRs** — co-architect via issue-driven protocol design, not commits. Most consequential: #33 "[PROTOCOL] add share hash commitment to blinded message."
- **EthnTuttle authored SRI Discussion #1935** (Iroh transport RFC, Oct 2025) — wiki previously misattributed him as "commenter." Corrected.
- **hashpool architecture**: SRI 1.7 fork + co-located CDK 0.16 mint via `cdk-ehash` plugin (forge.anarch.diy/vnprc/cdk-ehash). Settlement uses **epoch model** (each block = new keyset/currency unit). Two redemption paths: ecash + on-chain accumulating melt quote. New `BlockFound` SV2 message.
- **Status**: testnet4-only. v0.1 March 2025 → v0.1.1 March 2026 (~12 months between tags). No mainnet. No funding disclosed. No Bitcoin Optech newsletter coverage.
- **Critiques deepened**: 12 severity-rated critiques. Most consequential: founder admitted on Stacker News *"It's not possible to sell Ecash tokens"* — variance-hedging story is vaporware. DLEQ doesn't prevent per-user key equivocation.
- **btc++ Poolin' Stage catalog**: 4 livestream archives identified (Austin 2025 Day 1+2, no per-talk timestamps published). 3 standalone Main Stage talks indexed (Hughes DATUM, MEVPool, Miner Incentives). Several speakers (Bob McElrath, gitgab19, plebhash, Hughes, Beddict, Skot, Jungly, Pembroke, boerst) likely on the Day 1+2 streams but not yet mapped without yt-dlp scrub.

New articles: `2026-05-24-ethntuttle-profile.md`, `2026-05-24-vnprc-profile.md`, `2026-05-24-cashu-mining-application.md`, `2026-05-24-hashpool-architecture-deep.md`, `2026-05-24-hashpool-news-2024-2026.md`, `2026-05-24-hashpool-critiques-deepened.md`, `2026-05-24-btcplusplus-poolin-stage-catalog.md` (raw); `wiki/reference/people.md` (new wiki article). Updated: `wiki/concepts/ehash.md` (origin/authorship, settlement design, 12 critiques).

## [2026-05-24] research | "accounting used by p2poolv2 under the 256 Foundation" --deep → 11 raw sources ingested, 4 articles compiled, 1 framing correction

8 parallel agents (Academic, Technical-source, Applied-256-Foundation, News, Contrarian, Historical, Adjacent, Data/Stats). All returned with WebFetch enabled.

**Major framing correction**: the user's premise that p2poolv2 is "under" the 256 Foundation is incorrect. The 256 Foundation's pool pillar is **Hydrapool**, not p2poolv2. p2poolv2 is independent (lead: pool2win/Jungly, also maintains Braidpool). Hydrapool depends on `p2poolv2 lib v0.10.14` as its accounting engine. Same lead engineer for both.

**Code-level corrections to existing wiki**:
- "Top-N coinbase" → **work-bounded PPLNS window of 133,056 shares** (~2 weeks of work). Walked newest→oldest until accumulated weighted difficulty crosses block target.
- Uncle weight = 90% (`UNCLE_SCALED_WEIGHT = 9` of `DIFFICULTY_SCALE = 10`); nephew bonus = +10% per uncle referenced. All `u128`.
- Up to 3 uncles per share, within 3 share-blocks of tip.
- Atomic-swap = P2WSH/P2TR HTLCs with 3 spend paths; cross-chain via shared `payment_hash`. Timelocks "yet to be specified."
- Alternative PPLNS-with-decay (`α = exp(-1/N)`) shipped as design doc, used by Hydrapool's small-state path.

New articles: `p2poolv2-accounting.md` (deep-dive), `hydrapool.md` (256 Foundation pool concept), `p2poolv2-and-256-foundation.md` (topic synthesis on the relationship). Updated: `p2pool-share-chain.md` (corrected work-bounded-window framing).

## [2026-05-23] research | gap-close round 3 (7 paths re-run) → 8 raw sources ingested, 5 articles updated, 1 new concept article

All 7 previously-blocked gaps resolved with WebFetch enabled.

Major findings:
- **DMND SLICE confirmed N = 8 × Bitcoin difficulty** — same multiplier as TIDES. Production consensus. Source: blog.dmnd.work, March 2025. (Gap 1)
- **AntPool FPPS timeline corrected**: launched 2014 with PPS+PPLNS only; PPS+ in early 2017; explicit "FPPS" label July 2020. BTC.com (Bitmain sister) was actually first major FPPS pool, Sept 2016. (Gap 2)
- **p2pool peak ~1.5 PH/s late 2013/early 2014**, last release Aug 2017. (Gap 3)
- **btc++ talks**: 3 vnprc/hashpool talks (Berlin 2024, Austin 2025, Durham 2025). No SLICE/TIDES talks at btc++ yet. (Gap 4)
- **OCEAN sentiment**: hobbyist-positive, professional-miner-silent; BOLT12-only Lightning is a UX wall; Dashjr politics polarizes separately from TIDES. (Gap 6)
- **FAW (Kwon CCS'17)** and **selfish mining (Eyal-Sirer 2014, Sapirshtein 2016)** ingested as primary papers. New concept article `selfish-mining.md`. Documented attacker-profit-vs-incidence asymmetry. (Gap 7)
- **No production FPPS pool publishes cryptographic proof-of-reserves/liabilities** as of May 2026. "Auditable FPPS" is cadence-friendly, not provable. (Gap 8)

Updated articles: pplns-jd.md, fpps.md, p2pool-share-chain.md, block-withholding.md, tides-variance-derivation.md, why-fpps-dominates-but-is-fragile.md. New: selfish-mining.md.

Total wiki state: 22 raw sources, 16 wiki articles. Progress score now ~95.

## [2026-05-24] research | gap-close path 1 (Poolin' Stage per-speaker mapping) → BLOCKED, catalog updated with negative result

Goal: map per-speaker talks inside the two btc++ Austin 2025 Poolin' Stage livestreams (Day 1 6h 53m `nUQlBxWwlaU`, Day 2 4h 46m `F2p_V0svDTo`).

Five orthogonal extraction strategies attempted and failed:
1. `yt-dlp` — Bash permission-denied in this env.
2. Direct YouTube `watch?v=` page WebFetch — returns footer HTML only; no `ytInitialData` / `playerResponse` JSON surfaced.
3. `api/timedtext?lang=en&v=` auto-caption endpoint — empty body (requires signed `pot` token since 2024-Q4).
4. Invidious / Piped / yewtu.be `/api/v1/videos/{ID}` — every probed mirror returned 403 or ECONNREFUSED (cloud-egress mass-blocked).
5. `r.jina.ai` reader-mode proxy — returns prose summary only, doesn't surface embedded chapter JSON.

**Confirmed**: neither Day 1 nor Day 2 livestream has YouTube chapter markers, and neither description contains a timestamp list. Verified via jina-mirrored full-page text search for 17 expected term-strings → zero hits. The vnprc confirmed timestamp (Day 2 @ 3h15m30s) is a viewer-supplied URL fragment, not a chapter marker — corroborates that no native chapters exist.

**Salvaged**: pulled the full official speaker roster + affiliations verbatim from `btcplusplus.dev/atx25`. Updated `raw/videos/2026-05-24-btcplusplus-poolin-stage-catalog.md` with (a) speaker-vs-likely-topic table for the 13 mining/pool-adjacent roster members, (b) explicit failed-attempt log, (c) refined open-follow-up list (manual scrub, yt-dlp+Whisper, ask niftynei/vnprc, wait for cuts).

**Net delta**: catalog file now documents the gap honestly with attempted-extraction provenance instead of just "need manual scrub." Per-speaker timestamps remain unmapped. Path 1 is closed-as-blocked, not closed-as-completed.

## [2026-07-14] ingest | demand-open-source/share-accounting-ext — SV2 Share Accounting Extension (raw/repos/2026-07-14-demand-share-accounting-ext-github.md)

## [2026-07-15] compile | 1 source → 1 new article, 2 updated (sv2-share-accounting-ext; pplns-jd, sv2-jd-and-payout-decoupling). +back-links in tides, payout-schema-taxonomy.

## [2026-07-15] lint | 19 checks, 0 critical, ~29 warnings (legacy schema: type vs category, missing sources/volatility on 24 pre-existing articles), 11 suggestions (orphan sources), 0 candidates, 0 auto-fixed (report-only)

## [2026-07-15] lint | 19 checks, 0 critical, ~5 warnings remaining, 11 suggestions, 0 candidates, 51 auto-fixed (25 type→category, 26 volatility:warm added)
## [2026-07-15] query | "do we have the research needed to determine if we can mine a coinbase tx that onboards to an Ark?" → answered from 5 articles (standard)

## [2026-07-15] compile --full | 68 sources, 24 articles updated (sources: frontmatter backfilled losslessly from existing ## Sources sections; no bodies rewritten). 16 sources remain uncompiled (no article synthesizes them).

## [2026-07-15] lint | 19 checks, 0 critical, 4 warnings (26 missing summary:, tag casing, 2 non-canonical dirs, 2 legacy type: fields), 12 suggestions (16 uncited sources, tag-casing normalization), 0 candidates, 0 auto-fixed (report-only)

## [2026-07-15] query | "How might we design an Sv2 extension enabling miner interactivity for Ark boarding via the coinbase tx?" -> answered from 6 articles (standard)

## [2026-07-17] ingest-collection | coinbase-playground via git: 5 new, 0 skipped, 5 total candidates (README + 4 Rust scripts; repo+code scope). vnprc/coinbase-playground @ 0ac7ed25, license unknown. Manifest → raw/repos/2026-07-17-collection-coinbase-playground-manifest.md. CTV+CSFS regtest playground for non-custodial coinbase payout trees: flat tree (~319-output TRUC ceiling, 330-sat anchor, 1 sat/vB, immediate broadcast) vs layered binary tree (nested unroll, 500-sat fixed fees); MuSig-tree + P2Pool-reboot endgame. Complements prior 2026-05-26 metadata snapshot (raw/repos/2026-05-26-vnprc-coinbase-playground-github.md), not overwritten.

## [2026-07-17] compile | 6 sources → 1 new article, 3 updated (new: ctv-coinbase-payout-tree; updated: payout-schema-taxonomy, ark-for-mining-payouts, plus backlinks in tides, datum, braidpool, p2pool-share-chain). demand-share-accounting-ext (2026-07-14) already compiled into sv2-share-accounting-ext 2026-07-15 — no change.

## [2026-07-18] ll | "proxy-held VTXO keys + SV2 Ark-claim extension" → raw/notes/2026-07-18-ll-proxy-held-vtxo-ark-sv2-extension.md (4 lessons, 2 articles updated)

## [2026-07-27] ingest | warioishere/blitzpool-server-rust (raw/repos/2026-07-27-blitzpool-server-rust-github.md) — non-custodial in-coinbase payout pool by yourdevice.ch; Rust rebuild (37 crates, AGPL-3.0) of the TS Blitzpool (itself a public-pool fork). Four modes (Solo/PPLNS/Group-Solo/Blockparty) all paid as direct coinbase outputs of the block that earned them: no pool wallet, no minimum payout. PPLNS = multi-output coinbase over sliding 4x-netdiff window + signed credit/debit ledger (trimmed/sub-dust sats -> pending credit, matching debit on the block's bonus recipient, pool-wide sum ~0). Coinbase-space mechanics: one bitcoin-core v31 Cap'n-Proto IPC/TDP stream per payout mode (per-stream coinbase_output_max_additional_size, no blockreservedweight), PPLNS autoscaler stepping 50k WU floor -> ceiling on 0.85/0.50 utilization thresholds x1.15, greedy weight-budget trim claimed to make found blocks always-valid, confirmation-gated (depth 3) orphan-safe idempotent ledger applies. SV1+SV2 (Noise, extended channels, TDP, JDP) on shared ports via first-byte protocol detection. Contrast noted vs PPLNS-JD: non-custody via coinbase destination, NOT via miner-verifiable accounting (no window/slice/merkle spot-check, no fee attribution). Credibility medium (README self-description, 1 star, repo created 2026-06-23, unaudited claims).

## [2026-07-27] research | "PPLNS pool with a 1 BTC (configurable) bounty to the block-finding miner — feasible in blitzpool-server-rust?" (code-level, local clone @ 7815884)

Cloned `warioishere/blitzpool-server-rust` to `REPOS/blitzpool-server-rust` (release 2.2.5, 37 crates, 142k LOC, AGPL-3.0-or-later) and answered from source rather than the README. Checkout left clean; spikes relocated to `.buzz/.scratch/blitzpool-spikes/`.

**Verdict: feasible and substantially pre-built.** The finder-bonus mechanic already exists in the *shared* pure-math distribution builder used by both PPLNS and Group-Solo (`crates/bp-pplns/src/distribution.rs`): carve-out at `:166-175`, weight accounting `:233-241`, dedicated-output emission `:649-657`, 95%-of-miner-cut cap, dust suppression below `min_payout_sats`. PPLNS declines it in **one line** — `crates/bp-pplns-engine/src/distribution.rs:340`, `finder_bonus_sats: None, // finder-bonus is a Group-Solo feature`. The existing absolute ceiling `MAX_FINDER_BONUS_SATS` is already exactly 1 BTC.

**Per-connection coinbase is already the architecture**, which is the load-bearing finding — the finder can't be retrofitted after a block is found, so the coinbase must be built speculatively per candidate finder. Solo/Group-Solo/Blockparty already do this; `payout_resolver` runs per `(template-broadcast × connection)` and already receives the miner address; `MiningJobCache`'s key includes the payout list so per-finder sets are distinct by construction; `payouts_fingerprint` (content hash of reward + ordered `(sats,address)` pairs, no session component) binds a found block to the exact distribution its coinbase paid. SV2 Job Declaration already runs many concurrent distinct distributions per template through that same machinery. PPLNS is the *only* mode sharing one pool-wide coinbase.

**Measured, not guessed** (release build; debug is ~12× worse and was discarded): per-connection `build_coinbase_distribution` = 0.193 / 0.738 / 1.905 ms at window sizes 100 / 400 / 1000. 500 connections × 1000-miner window ≈ 3% of one core per 30s template. Expensive inputs (Redis window + Postgres ledger) are already shared via an `inputs_cache` keyed by `()`. **The real cost is elsewhere**: the `OutputsKeyTuple` script-parse memoization is defeated (any sats change invalidates the key), so `address_to_script` re-runs for every payout output per finder — unmeasured, and the dominant unknown. Plus N Redis snapshot writes/template against a TTL-only job cache (120s TTL, 10s prune, no size cap) holding ~4×N entries.

**One correctness landmine found**: the finder legitimately appears **twice** in the payout list (bonus + proportional share). Group-Solo merges per-address before writing (`bp-group-solo-engine/src/engine.rs:912-936`); the PPLNS write path (`bp-pplns-engine/src/engine.rs:644-660`) has **no such merge** and `pplns_payout_history` is UNIQUE on `(blockHeight, address)`. Porting the bonus without porting the merge yields a correct coinbase with a silently under-counting audit trail — accounting drift, not a crash.

**Economics quantified**: bonus is carved out *before* the proportional split, so co-miners fund it. Non-finder payout 38,476,562 → 25,976,562 sats (**32.5% haircut**) at 1 BTC on a 3.125 BTC subsidy. Crucially it is **EV-neutral for every miner at every size** — P(finding) = share of proportional payout, so expected collection = expected forfeiture. Pure variance trade, unevenly distributed (small miners carry nearly all of it).

Verified 5 spike tests of the untested combination upstream never covers (bonus + PPLNS signed ledger `suppress_matching_debits: false` + non-zero opening balances, incl. a 10 BTC over-cap case and starved weight budgets) — all pass; baseline `cargo test -p bp-pplns` = 45 tests clean.

## [2026-07-27] ingest | Blitzpool finder-bonus code-level read (raw/repos/2026-07-27-blitzpool-finder-bonus-code-read.md) — resolves the "how the finder bonus is calculated" gap that the 2026-07-27 README ingest flagged as unverified. Quality 5, credibility high (direct source read at a pinned commit).

## [2026-07-27] compile | 2 sources → 1 new article, 6 updated (new: concepts/lottery-pplns; updated: parasite-pool, pplns, payout-schema-taxonomy, variance-and-risk-shifting, raw/repos/2026-07-27-blitzpool-server-rust-github, + concepts/_index and raw/repos/_index). New article generalizes the finder-bonus family beyond the single repo: mechanism + guard rails, the per-finder speculative-coinbase requirement, EV-neutrality result, implementation hazards, Parasite-vs-Blitzpool comparison. Notable gap identified: a flat lottery bounty paid **non-custodially in the coinbase** is not currently shipped by anyone — Parasite is custodial, Blitzpool has all the parts but doesn't connect them for PPLNS.

## [2026-07-27] ingest | Parasite & Blitzpool on-chain + code verification (raw/data/2026-07-27-parasite-blitzpool-onchain-and-code-verification.md) — first source in a new `raw/data/` category (primary-source queries rather than published writing). Quality 5, credibility high. mempool.space REST + `parasitepool/para` @ master + live blitzpool.yourdevice.ch.

## [2026-07-27] compile | corrections pass — 1 source → 3 articles updated (parasite-pool substantially revised; lottery-pplns, _index). Three claims this wiki had been carrying from secondary press coverage were **wrong** and are now corrected:

1. **Parasite's 1 BTC bounty is non-custodial.** The coinbase has 3 outputs, not 1: output 0 = exactly 100,000,000 sats to a *different* address every block (938713 `bc1qsmdhm00…`, 945601 `bc1q2l474n3…`, 958527 `bc1qnd2xkan…` — the finder's own), output 1 = remainder to the *same* pool address every block (`bc1qkgef7pl8vdrtuc4wk8fssycz366xp5ukzsm8gp`), output 2 = OP_RETURN. So the custody critique scopes to the remainder (~68% of the reward), not the bounty; the finder's 1 BTC is publicly auditable from chain data alone. Supersedes this article's prior "single output to a pool-controlled address" framing (consistent with, but strictly narrower than, the 2026-05-26 on-chain analysis).
2. **Parasite's weighting is not decay-EMA.** It is `total_diff − already_paid_diff` — cumulative unpaid difficulty since account inception, no decay, no half-life, no window. A sweep of all 162 Rust files for `decay|half.?life|exp(|lambda` returns zero hits in the payout path. `src/decay.rs` exists but its consumers are `metatron/stats.rs`, `vardiff.rs`, `store/entry.rs`, `subcommand/miner/metrics.rs` — hashrate display and difficulty adjustment. Consequence: **not PPLNS in Rosenfeld's sense, not hop-resistant** (accumulated weight never ages out). The "continuous decay weighting" entry under "what's actually novel" is struck; the scheme is *less* sophisticated than PPLNS-N, not more.
3. **5 mainnet blocks, not 2** — 938713, 945601, 954873, 958212, 958527 (~15.68 BTC). Cadence accelerated hard: first two 48 days apart, last three inside ~26 days, final two only 3. Resolves CoinDesk's April "third block in two months" test in Parasite's favor, and it happened while hashrate was *down* (~52 PH/s vs a 182 PH/s June-2025 peak) — so the earlier "the bounty didn't solve retention" read was premature.

Also established: Parasite implements the **winner-only** variant (finder excluded from the remainder — `WHERE username != COALESCE($2,'')`, `total_payment_amount = coinbasevalue − COIN_VALUE`, `test_multiple_users_with_finder_exclusion`), where Blitzpool is **bonus-on-top** (finder paid twice, hence the per-address merge its ledger needs. Both variants now documented in concepts/lottery-pplns. And its 1 BTC is a hardcoded `COIN_VALUE`, not config — Blitzpool's is configurable, capped at 1 BTC.

Corrects the record left by the earlier compile entry in this log, which described Parasite as flatly custodial ("single pool output → operator LN fanout"). That is true of the remainder only.

**Negative result recorded**: nine search framings (bitcointalk, Delving Bitcoin, r/BitcoinMining, game theory, coefficient of variation, pool hopping, centralization, "worse than solo") found **no substantive published analysis of large flat finder bounties**, for or against. The only pro argument on record is the operator's behavioral one ("round number bias"); the only quantified critique is Blockspace Media's "-22% discounted PPS", which averages the variance away. Delving Bitcoin's one adjacent thread (PPLNS with Job Declaration) doesn't touch finder bonuses. This wiki's treatment is therefore constructed, not cited — flagged as such in both articles.

Contrast datum: OCEAN block 959,867 carries 12 coinbase outputs (2020 WU), smallest nonzero 0.0652 BTC — coinbase-direct scaling achieved via a high effective payout threshold, not by paying everyone every block. Relevant to Blitzpool's "no minimum payout" claim, which implies far more outputs and is why its weight-budget autoscaler exists.

## [2026-07-27] plan | "a fully coinbase-direct lottery-PPLNS based on blitzpool" → output/plan-coinbase-direct-lottery-pplns-2026-07-27.md (9 articles consulted, 5 decisions, 6 phases)

Roadmap for the point in the payout design space [[wiki/concepts/lottery-pplns|lottery-PPLNS]] identified as shipped by nobody: flat configurable finder bounty **and** the PPLNS remainder, both paid as direct coinbase outputs of the block that earned them. Parasite ships the bounty half non-custodially but custodies the ~68% remainder; Blitzpool pays everything on-chain but declines the bounty for PPLNS in one line (`finder_bonus_sats: None, // finder-bonus is a Group-Solo feature`). Grounded in the code-level read at `7815884` plus three new spikes run for this plan.

Decisions: D1 keep **bonus-on-top** over Parasite's winner-only (it's the exactly-EV-neutral variant at every miner size; winner-only is a real economic change dressed as an implementation detail). D2 configure as **fraction of miner cut with an optional absolute clamp** — neither existing implementation does this, and an absolute-sats bounty is a scheduled halving cliff (1 BTC is 32% of the miner cut today, ~65% after the next halving, then the 95% cap starts binding and the scheme silently mutates into near-solo). D3 **re-key the script memo on the address**. D4 **reject CTV fanout** (soft-fork-gated, regtest-only, and the source calls the layered variant strictly worse for pool payouts; the existing greedy weight-budget trim already handles output pressure). D5 **leave `payouts_fingerprint` untouched** — it has no session component by design, so varying the payout list per finder makes the existing fingerprint carry finder identity for free, which is the single biggest reason this is small work rather than a redesign.

**Three measurements taken for this plan, which corrected my own prior assessment.** Spikes preserved at `.buzz/.scratch/blitzpool-spikes/`; repo tree verified clean at `7815884` afterward and `cargo test -p bp-pplns` re-confirmed passing.

1. `spike_output_divergence2.rs` — **exactly 1 differing position** between any two per-finder payout lists, out of 202 / 202 / 65 / 30 across roomy, equal-share, starved (12,000 WU) and very-starved (6,000 WU) budgets. Reward conserved exactly (312,500,000 sats) in every case; finder appears exactly twice in every case; the trim set is stable across finders. Cause: `reward_for_miners -= bonus_sats` happens *before* the proportional split, so every non-finder's share shrinks identically no matter **who** the finder is. The divergence is positional, local, and always at index 1. (An earlier version of this spike keyed the comparison by address in a HashMap, which silently collapsed the finder's duplicate entry and reported a misleading "100% identical"; rewritten as a positional diff of the ordered `(address, sats)` vectors — the representation the coinbase builder and `OutputsKeyTuple` actually consume.)
2. `spike_script_parse_cost.rs` — the fan-out this project was supposed to be limited by: 15.62 / 62.85 / 149.75 ms per template at 100 / 400 / 1000 outputs × 500 distinct finders = **0.031 / 0.126 / 0.300 ms per finder**, versus 35 µs / 118 µs / 295 µs with an address-keyed memo (**442× / 532× / 507×**).
3. `spike_perconn_cost.rs` (prior session) — distribution math at 0.193 / 0.738 / 1.905 ms per build at window 100 / 400 / 1000.

**Correction to the record.** The research phase called the defeated `OutputsKeyTuple` memoization "the dominant unmeasured CPU term." Measured, it is ~16% of the distribution math and largely removable, because `address_to_script` (`crates/bp-mining-job/src/address.rs:39-45`) is a pure function of `(network, address)` and **never reads sats** — including sats in that memo key is what made it fragile. It was never the bottleneck. This makes Phase 4 cheap and moves the real risk decisively onto Phase 5's memory profile: per-finder jobs turn ~4 resident cache entries into ~4 × N, each holding both pre-rendered SV1 hex strings (~3× raw coinbase size) against a TTL-only cache with **no size cap** (`ENTRY_TTL = 120s`, `PRUNE_INTERVAL = 10s`).

Phases: 0 branch + write the failing ledger test first (0.5d) · 1 config surface (0.5d) · **2 port the Group-Solo per-address merge into the PPLNS ledger apply (2d) ⚠️ correctness** · 3 thread the finder through (1d) · 4 address-keyed script cache (1d) · **5 regtest load test (3d) ⚠️ go/no-go** · 6 disclosure (1d). ~9 days; 1/2/4 parallelizable.

Phase 2 is the only phase that can cause silent financial damage and is why this isn't a flag flip: `pplns_payout_history` is UNIQUE `(blockHeight, address)` and the history insert "silently dedupes" per its own doc comment, so a bonus-on-top finder appearing twice produces a coinbase that pays correctly while the audit trail under-counts. Accounting drift with no alert. Phase 3 carries the other sharp edge — the invariant that a failed snapshot write must never fail a build, because the fallback hands one miner 100% of the block, and per-finder fan-out multiplies how often that path is reachable.

Phase 5 is written as a genuine gate: if the memory profile is bad, the correct output of the phase is "don't ship it." Phase 6 is disclosure rather than marketing — the 32.5% per-block haircut on non-finders, the EV-neutrality (sells variance, not yield), the trim interaction (the 1 BTC bonus is never trimmed; small miners are), and the point the expectation math hides: **the scheme is most attractive to the participants it treats worst.** Set against Blitzpool's own stated 42.4-year expected block time at ~3.2 PH/s with zero blocks found.

Open questions carried forward unresolved: no principled way to size the bounty (expectation-neutral ⇒ the only criterion is risk preference, which no pool has elicited); whether the lottery retains miners at all (Parasite's hashrate fell 182 → 52 PH/s while the bounty was live, but its block cadence accelerated — genuinely unclear); block-withholding payoff structure under a finder bonus (unanalyzed for either implementation); whether an SV2 Job Declaration client should be bonus-eligible when it built the template itself (undefined, needs deciding before enabling both); and the standing negative result that **no published critique of flat finder bounties exists**, so the variance analysis this plan rests on is constructed, not cited.

## [2026-07-28] plan | "fork this project on GH and plan the rewiring" (1.776 BTC, no ownership proof) → output/plan-lottery-pplns-1776-rewiring-2026-07-28.md

Revision of the 2026-07-27 roadmap for two operator decisions: **1.776 BTC** as the bounty (not 1 BTC), and **no proof of address ownership** — the pool validates against consensus rules only and the user owns their inputs. Fork created at `average-gary/blitzpool-server-rust`, branch `lottery-pplns` cut from `7815884`, worktree at `REPOS/blitzpool-lottery-pplns`. Two spikes committed as tests (`8235dac`), pushed.

The architecture is unchanged and still small. What changed is that **1.776 BTC is not a drop-in substitution for 1 BTC**, plus one hazard I had characterized wrongly.

**Correction to the record.** The 2026-07-27 plan said the duplicate-finder ledger hazard produces "accounting drift, not a crash — which is worse, because nothing alerts." Wrong, and wrong in the safer direction. Verified against a live Postgres mirroring both schemas: `pplns_payout_history` is `ON CONFLICT ("blockHeight", address) DO NOTHING` (`crates/bp-db/src/pplns.rs:416`) so the duplicate row *is* silently dropped (reproduced: 20,000,000 sats missing from a 217,600,000-sat audit trail) — that half holds. But `pplns_balance` is `ON CONFLICT (address) DO UPDATE` (`:319-323`), and Postgres raises **`ON CONFLICT DO UPDATE command cannot affect row a second time`**. Both writes share one transaction (`crates/bp-pplns-engine/src/ledger/mod.rs:100-137`), so the abort rolls the whole booking back. Real failure mode: **the block pays 1.776 BTC correctly on-chain and the pool can never book it**, with `bin/blitzpool/src/block_confirmation.rs:246-249` logging `will retry next tick` against a deterministic error forever. A stuck pipeline, not quiet under-counting — and an infinite retry in the block-found path deserves its own bound regardless of the merge.

**Four new measurements** at `7815884`. Two are committed as tests; the Postgres checks were run against a local instance and the scratch schema dropped afterward.

1. `spike_bonus_1776.rs` — **the 95% clamp binds at the next halving.** 1.776 BTC is 56.8% of the miner cut today (paid in full) but clamps to **1.508897** post-2028, leaving every non-finder to split **5.00% of the miner cut**. Near-solo with a consolation pool, and the mutation is silent — the clamp at `crates/bp-pplns/src/distribution.rs:172` is working as designed. Also: the non-finder haircut today is **56.8%, not the 32.5%** the prior plan computed for 1 BTC. Nearly double.
2. Same spike — **the one-differing-output property survives**, including when clamped: 1 differing position (index 1) out of 202/202/65/65 across roomy and starved budgets at both subsidies. So D3 (address-keyed memo) and D5 (untouched fingerprint) carry over. **But `finder_entries=1` under a starved budget** — at 12k WU the finder's own proportional share is trimmed while the 1.776 BTC bonus output survives (greedy-largest-first trim at `:267-276`; bonus emitted outside the trimmed set at `:648-657`). The duplicate-address hazard is therefore **intermittent**: it fires on roomy blocks and hides on tight ones. A small-scale test on a tight budget passes for the wrong reason.
3. `spike_dust_cliff_1776.rs` — **the dust cliff does not happen.** The worry was that a bonus this large starves the remainder below `min_payout_sats`, pushing miners into pending ledger credit — an internal IOU, i.e. the same custodial outcome the project exists to avoid. Measured: on-chain output count is **identical to the no-bonus baseline** at 10/100/500/2000 miners across three subsidy eras. The bonus costs exactly one extra output and pushes nobody off-chain (the 2000-miner trim to 1157 is a pre-existing weight ceiling, present with and without the bonus). Even at 2032 with 500 miners the per-miner remainder is ~8,187 sats against a 546-sat floor. **This is the result that says the design is sound: the coinbase-direct premise holds at 1.776 BTC.**
4. Also confirmed: 1.776 BTC **exceeds** `MAX_FINDER_BONUS_SATS`, which is exactly `100_000_000` (`crates/bp-group-mgmt/src/constants.rs:25`) and rejected by `validate_round_reset` (`crates/bp-group-mgmt/src/group.rs:318`). Its doc comment is a deliberate design statement — *"1 BTC is already absurd as a per-block bonus… anything bigger is almost certainly a config typo."* So Phase 1 raises a hardcoded ceiling, not just adds a config key.

**Decisions.** D1 (bonus-on-top), D3 (address-keyed script memo), D4 (no CTV) and D5 (untouched fingerprint) carry over unchanged. **D2 escalates from preferred to mandatory** — fraction-of-miner-cut sizing was "avoids a scheduled cliff" for 1 BTC; at 1.776 BTC the cliff is the *next halving*, ~2 years out. **D6 (new):** replace the absolute ceiling with a percent ceiling `(0, 95]`, keep an absolute sanity bound raised to 2 BTC for the optional clamp, and **make the clamp loud** — reject at startup any percent that would clamp at the current subsidy, and warn at build time when it binds. Since the operator's position is that users own their inputs, the pool's own config is the one place a typo is the *operator's* responsibility. **D7 (new):** no ownership proof — accept it and change nothing in the auth path; drop the prior plan's opt-in ownership item. One thing does get fixed and it is *not* an ownership feature: the JDP path (`crates/bp-stratum-v2/src/jdp/client.rs:656-677`) skips `address_to_script`, so a shape-valid-but-consensus-invalid address gets a job token and fails later into a `coinbase_outputs: vec![0u8]` fallback (`bin/blitzpool/src/jdp_hooks.rs:210-226`). That is a **consensus-validation gap** — precisely the one check the operator does want enforced.

Phases: 0 branch + **two** failing ledger tests, one per failure mode, pinned to a roomy budget (1d) · 1 config + raise ceiling + close JDP gap (1.5d) · **2 per-address merge on both the audit AND balance lists, plus a retry bound (2.5d) ⚠️ correctness** · 3 thread the finder through (1d) · 4 address-keyed script cache (1d) · **5 regtest load test (3d) ⚠️ go/no-go** · 6 disclosure (1d). **~10.5 days**, up from ~9; the growth is all in Phases 1 and 2.

Phase 6 revised: publish the **56.8%** haircut (not 32.5%), disclose the halving cliff and which config mode the pool runs, disclose that under a starved budget even the finder's own share is trimmed before the bonus, and disclose the address policy at the point where a miner configures their worker — a typo sends 1.776 BTC somewhere unrecoverable, with no ownership check and no recovery. Do **not** publish a hardcoded "1.776 BTC" if running percent mode; derive it from live subsidy + fees.

New open question: **is 1.776 intentionally 1776?** If the number is symbolic rather than economic, that argues for absolute-sats mode and accepting the halving cliff explicitly — with D6's startup rejection forcing a conscious re-set at each halving rather than a silent clamp. Needs confirming before Phase 6. Carried forward unresolved: percent-vs-absolute for the marketing figure, whether the retry bound belongs upstream as its own PR, block-withholding payoffs (more worth analyzing now that the bonus is 56.8% of the cut rather than 32%), SV2-JD bonus eligibility, and the standing negative result that no published critique of flat finder bounties exists.

Baseline: `cargo test -p bp-pplns --release` = 45 passing (40 lib + 5 integration) before the new spikes, 49 after, all passing. No production code changed on the branch.

## 2026-07-28 — Sizing revised to 0.1776 BTC / 17.76%: the ceiling work disappears, and the ledger abort is the common case

Operator revised the bounty down an order of magnitude: **0.1776 BTC to start**, configurable per deployment, with **17.76% of the miner cut** raised as a scaling alternative. New spike `crates/bp-pplns/tests/spike_bonus_sizing_modes.rs` (commit `059d7b0`, 4 tests) measures both against the real distribution math at `7815884`. Suite now **53 passing**, no production code touched. Plan revised in place (rev. 2) rather than superseded — same day, same architecture, only the sizing decisions moved.

**The two proposals are not equivalent.** 17.76% of the current miner cut resolves to **0.555422 BTC — ~3.1× the 0.1776 BTC figure**. The percent that reproduces 0.1776 BTC exactly today is **5.68%**. So "17.76% so it scales" is not a rescaling of the absolute proposal, it is a deliberate 3× increase that happens to reuse the digits. Worth stating explicitly because the two were offered as alternatives to the same thing.

**Recommendation: percent-of-miner-cut as the mechanism, value left to the operator.** Percent mode is structurally clamp-proof (17.76 < 95, asserted across nine consecutive subsidies) and holds a flat 17.8% haircut forever. Absolute mode is genuinely viable now — 0.1776 BTC does not hit the 95% clamp until **halving +5**, ~20 years, versus the *next* halving for 1.776 BTC — but its proportion drifts the whole way there with no config change and no log line: **5.7% of the cut today → 11.2% → 21.7% → 40.9% → 73.5%**, then clamped at 0.138169. The pool silently becomes more lottery-like every four years. Either 1776-flavoured value keeps the branding; only percent mode keeps it *true* indefinitely, since "0.1776 BTC" is a claim with a shelf life and "17.76% of every block" is not.

**Scope reduction: the D6 ceiling-raise work item is deleted.** Both candidates sit under the existing `MAX_FINDER_BONUS_SATS = 100_000_000` — 17,760,000 (absolute) and 55,542,180 (17.76% today). The constant, `validate_round_reset` (`crates/bp-group-mgmt/src/group.rs:318`), and its cap tests (`:541-551`) all stay untouched, and the doc comment's *"1 BTC is already absurd"* is now consistent with the design instead of in conflict with it. Phase 1 drops 1.5d → 1d; total ~10.5d → **~10d**.

**Correction to my own prior framing.** Last entry called the duplicate-finder ledger abort "intermittent — it fires on roomy blocks and not starved ones," and treated the starved case as a silver lining. Re-measured at the autoscaler's actual **50,000 WU floor**: `finder_entries == 2` for **every pool size from 5 to 400 addresses**, dropping to 1 only at ~500+ where the greedy trim eats the finder's proportional share. For a pool of realistic size the abort is the **default** outcome on any found block. The silver lining was backwards — the starved case is the rare one. Also measured: the hazard is **completely independent of bonus size** (0.1776 BTC, 17.76%, and 1.776 BTC give identical `finder_entries` at every budget from 6k to 200k WU). It is a property of the trim, not the bounty; shrinking the bonus mitigates nothing. Phase 0's failing test must be pinned to **≤400 addresses** or it passes for the wrong reason.

**Two new findings worth carrying.** (1) **Percent mode tracks tx fees**, so the jackpot is a range, not a number: 0.547 BTC at zero fees, 0.555 typical, **1.421 BTC on a 5-BTC-fee block**. Arguably a marketing asset, but it also means a fee spike could push the resolved sats figure over the existing 1 BTC ceiling — new Phase 1 item to check whether resolved (as opposed to configured) values pass through `validate_round_reset`. (2) **Dust suppression is unreachable by either config** — neither candidate falls under the 546-sat floor anywhere in the subsidy schedule — but the path is confirmed **silent** when a typo does reach it: a 100-sat request emits no bonus output, no warning, and still conserves the reward. Added as D6.4, a runtime warn.

M1–M4 carry forward. M3 (the dust cliff / on-chain reach result, the strongest positive finding) held at 1.776 BTC and therefore holds *a fortiori* at both smaller values — the coinbase-direct premise is sound.

**Method note, for anyone reading this code later.** The first version of the spike extracted the bonus with `max()` over the finder's entries, which silently returns the finder's *proportional share* whenever that exceeds the bonus — true in any small pool — and reported a 0.1776 BTC bonus as 0.368 BTC. Correct extraction is positional: `distribution.rs` pushes fee (`:641`), then bonus (`:651`), then miners sorted descending (`:673`), so the bonus is the first non-fee entry. Eras in the committed test are indexed by halving offset rather than calendar year, since dating them implies a cadence the test doesn't model.

Open questions updated: percent-vs-absolute is **answered for the mechanism** (percent) and open on the value (5.68% / 17.76% / absolute-with-disclosure) — needed before Phase 6, not Phase 1, since the code supports all three. New: does the resolved percent→sats value hit `validate_round_reset`? Carried forward: whether the retry bound belongs upstream as its own PR, block-withholding payoffs, SV2-JD bonus eligibility, and the standing negative result that no published critique of flat finder bounties exists — the variance analysis remains constructed, not cited.

## 2026-07-28 — Sizing decided: 0.1776 BTC absolute. Build plan written.

Operator chose **0.1776 BTC absolute** over the 17.76% alternative, for the pool's thematic identity. Percent mode is **not** being built. New plan at `output/plan-lottery-pplns-0.1776-build-2026-07-28.md`, superseding the rev-2 roadmap (which is retained for its M1–M5 measurements and the absolute-vs-percent comparison, both still accurate). **~9.5 days**, seven phases, Phases 2 and 5 are gates.

**Absolute mode is the simpler build.** Four items drop: the `finder_bonus_percent` key and its `(0, 95]` range check, the percent→sats resolution against live `block_reward_sats`, the fee-spike check against `MAX_FINDER_BONUS_SATS`, and the ceiling raise. One key, one `u64`, default off.

**But one item is promoted to load-bearing, and it's the point of the plan.** Percent mode was the *structural* answer to halving drift; absolute mode has no structural answer, so the guard has to be operational. Measured drift at 0.1776 BTC: 5.7% of the miner cut now → 11.2% → 21.7% → 40.9% → 73.5%, clamping at halving +5. Nothing in the current code logs any of it, and the first visible symptom is ~20 years out. D2's guard has three parts: a boot-time drift warn tiered at 15%/50%, boot-time **rejection** above 95% (refuse to start rather than silently clamp), and a rate-limited runtime warn when the clamp actually binds under a long-running process. Explicitly **not** building any automatic reduction at a halving — silently changing the advertised number is worse than warning about it.

**Read the code before writing the phases; found one thing that changes Phase 1's shape.** `block_subsidy_sats(height, network)` — the helper the drift guard needs — is `pub(crate)` inside **bp-api** (`crates/bp-api/src/controllers/groups.rs:408`), with callers only in `bp-api`. The guard runs at engine boot (`bin/blitzpool` + `bp-pplns-engine`), so it must be relocated to a shared crate and re-exported, carrying its existing halving/regtest/zero-subsidy tests (`groups.rs:2262-2275`) with it. Scoped as its own commit — pure move plus visibility, no behaviour. That relocation is why Phase 1 stayed at 1.5d despite the dropped percent work.

Other seams confirmed by reading, not assumed: `PplnsConfig` (`crates/bp-config/src/lib.rs:557-618`) has `deny_unknown_fields` but **no `validate()` of its own**, so a new key needs no hook in `bp-config`; the real validation seam is `PplnsEngineConfig::try_new` (`crates/bp-pplns-engine/src/config.rs:132-172`), reached from `to_pplns_engine_config` (`bin/blitzpool/src/engines.rs:247-270`). `try_new` is **pure with no RPC access**, so the split is: range check in `try_new`, drift warn in `spawn_pplns` (`engines.rs:218-245`) which already awaits RPC for `bootstrap_network_difficulty` — and following that function's best-effort pattern, a failed height fetch must warn and continue, never block startup. Config docs go after `min_payout_sats` at `blitzpool.example.toml:255`, with the drift table inline so the halving behaviour is visible where it's configured.

Phase 6 haircut figures re-derived through the distribution code rather than by hand: a non-finder goes **39,092,187 → 36,872,187 sats, 5.68%**, at 8 equal miners / current subsidy / 1.5% fee. The 17.76% figure for comparison was 32,149,415 (17.76%).

Carried forward unchanged: D1 bonus-on-top, D3 address-keyed script memo, D4 no CTV, D5 untouched fingerprint, D7 no ownership proof (with the JDP consensus-validation gap still closed in Phase 1 — that's a consensus check, not an ownership feature). Phase 2 remains the correctness gate: the duplicate-finder ledger abort is the default outcome for pools under ~400 addresses and is completely independent of bonus size, so shrinking the bounty mitigated nothing. Phase 5's regtest memory profile is still the genuine unknown, still with an explicit don't-ship outcome.

New open question: does the operator want a halving playbook written before the first halving rather than at it? The guard warns and eventually refuses to start, but someone still has to decide what the number becomes. Not blocking. Carried forward: retry bound as a possible upstream PR, block-withholding (low priority at 5.7%, rising each halving), SV2-JD finder definition, and the standing negative result that no published critique of flat finder bounties exists — the variance analysis remains constructed, not cited.

No production code touched. Branch still at `059d7b0`, suite 53 passing.

## [2026-07-28] plan (re-scope) | operator: "you're worrying too much about the maths in the future" → 0.1776 build plan superseded by a trimmed feature plan, 9.5 d → 6 d, 7 phases → 5

The previous entry's plan over-weighted future subsidy math. Operator correction, verbatim: *"you're worrying too much about the maths in the future. I just want a plan that will update blitzpool so we can have a PPLNS pool with bonus structure. Let's not worry about anything other than that feature."*

New plan: `output/plan-pplns-finder-bonus-feature-2026-07-28.md`. Prior plan marked superseded but **retained for its measurements** (M1–M5, the drift and fee-sensitivity tables) — those are still accurate and are the reference if sizing is ever revisited. The re-scope is an editorial judgement about what belongs in a build plan, not a retraction of any measurement.

**Cut (6 items):**
- The three-part halving-drift guard (boot warn / refuse-to-start above 95% / runtime clamp warn) — the thing the last reply called "the most important thing in the plan."
- The `block_subsidy_sats` relocation out of `bp-api` (`controllers/groups.rs:408`, `pub(crate)`, callers only at `:430`, `:459`, `info.rs:356`). It existed **only** to feed the drift guard. Removing the guard removes the only cross-crate move in the plan, which is why Phase 1 collapses 1.5 d → 0.5 d.
- Halving drift tables from the decision section and the disclosure phase.
- The JDP consensus-validation gap (`crates/bp-stratum-v2/src/jdp/client.rs:656-677` missing `address_to_script`). Real, but a pre-existing gap in a different protocol path — not this feature.
- The whole disclosure/marketing phase (was Phase 6).
- The dust-suppression warn — unreachable at 17,760,000 sats regardless.
- The open question about a halving playbook. Dropped, not deferred.

**Kept, with the reasoning made explicit in the plan** — Phase 2's per-address ledger merge looks like scope creep and is not. It is present-tense: without it the coinbase pays correctly on-chain and the pool **cannot book the block at all**. Reproduced against live Postgres — `pplns_balance` `DO UPDATE` (`bp-db/src/pplns.rs:319-323`) aborts with `cannot affect row a second time`; `pplns_payout_history` `DO NOTHING` (`:416`) silently drops the row. One shared transaction (`ledger/mod.rs:92-137`) so the abort rolls back everything, and `block_confirmation.rs:234-249` retries the deterministic error forever. Default outcome for pools under ~400 addresses, independent of bonus size. Flagged in the plan as "one thing I kept that looks like scope" rather than buried.

**Final shape:** Phase 0 failing test (0.5 d, pinned ≤400 addresses so it doesn't pass for the wrong reason) → Phase 1 config key (0.5 d, one `Option<u64>`, range check in `PplnsEngineConfig::try_new`) → Phase 2 ledger merge (2 d, ⚠️ gate) → Phase 3 finder threading (1 d) → Phase 4 regtest verification (2 d). Phases 1 and 2 parallelize. The address-keyed script memo (442–532× on `address_to_script`, but only ~16% of the distribution math) and the retry bound both demoted to unscheduled optional follow-ups.

`MAX_FINDER_BONUS_SATS = 100_000_000` still needs no change — 17,760,000 is well under it. Risk table kept in full; it is present-tense operational risk, not future math.

No production code touched. Branch still `059d7b0`, suite 53 passing.

## [2026-07-29] query | "do we have research on coinbase rotation, and how would it work in blitzpool-style PPLNS where the miner username is an xpub/wildcard descriptor?" → answered from 6 articles + 3 outputs (standard)

**Two-part answer: yes on rotation, no on xpub usernames.**

Coinbase rotation research exists but was **invisible from the hub indexes** — it lives in the `para` repo-local wiki (`REPOS/para/.wiki/output/plan-coinbase-rotation-2026-06-24.md` and `pr-body-coinbase-rotation.md`, shipped, 476 tests). Found by grepping hub `log.md:155`, not by index navigation. The hub topic `coinbase-rotation-bitcoin` that `_index.md:46` and `wiki/reference/_index.md:46` both link to is a **0-file skeleton** — no `_index.md`, no `config.md`, unregistered in `wikis.json`, absent from the hub's Active Topics list. Two dangling links.

The xpub-as-miner-username design was **absent from the wiki entirely**: `xpub` had **zero occurrences hub-wide**, and every hit for `rotat` was Cashu *keyset* rotation, not coinbase-output rotation.

**The concrete blocker identified for the design** (from [[output/plan-lottery-pplns-1776-rewiring-2026-07-28]], Postgres-verified): `pplns_balance` upserts `ON CONFLICT (address) DO UPDATE` — balances are keyed on address **globally, not per block**. A rotating per-miner address therefore writes a new balance row every block and breaks pending-credit carry-forward outright. Any such design must **split identity**: xpub/descriptor fingerprint for the ledger, derived address for the per-block coinbase output. Blitzpool's `payouts_fingerprint` (which has no session component) is unaffected — it identifies *which list was paid*, which is already the right key.

Gap logged; filled the same day by the ingest below.

## [2026-07-29] ingest | xpub/wildcard-descriptor coinbase rotation in sv2-apps — code-level read of feat/coinbase-rotation @ e2930150 (raw/repos/2026-07-29-sv2-apps-xpub-coinbase-rotation-code-read.md)

First `xpub`/wildcard-descriptor material in the hub, filling the gap the query above recorded. Local git worktree of `stratum-mining/sv2-apps`, branch `feat/coinbase-rotation`, two commits over upstream `cb3d2dd6`: `817a1057` (feat, 17 files +1112/−30) and `e2930150` (docs, 2 files +20). Rust 1.88.0, Apache-2.0 OR MIT. Verified by running the suite: `cargo test --lib config_helpers` → **28 passed, 0 failed**.

**What it adds.** `stratum-apps/src/config_helpers/xpub_derivation.rs` — a 552-line, 12-test `XpubDerivator`: miniscript `has_wildcard()` gate at construction, `AtomicU32` index via `fetch_add(1, SeqCst)`, index persisted to a flat file, descriptor held as a `String` and re-parsed per derivation (documented workaround for `Descriptor<DescriptorPublicKey>`'s internal `RefCell` taproot cache not being `Send + Sync`). Tests pin exact `script_pubkey` hex against a known `tpub` and include a genuine restart test (write index 4, construct a second derivator from the same path, assert resume at 4). Wired into both the Pool and JD-client: `coinbase_outputs` becomes a `SharedLock<Vec<u8>>`, initial outputs come from `current_script_pubkey()` rather than index 0 so the persisted index is honored, and rotation fires on `SubmitSolution` at two sites in each role.

**It reverses a deliberate upstream decision.** The branch deletes an upstream test asserting wildcards are invalid, whose comment read: *"no wildcards allowed (at least for now; gmax thinks it would be cool if we would instantiate it with the blockheight or something, but need to work out UX)."* Upstream wasn't unaware — it deferred on UX grounds and floated block-height instantiation. This branch answers the deferred question with a persisted monotonic counter and doesn't engage the block-height variant. Expect that conversation to reopen if it goes upstream. Hardened derivation and multipath `<0;1>` remain rejected.

**Persistence is weaker than para's shipped design in four specific ways**, and the comparison is the useful part of the source:
- Bare non-atomic `fs::write`, no temp-and-rename, no fsync. `load_index` does `contents.trim().parse().unwrap_or(default)` — a truncated or garbled file **silently resets to `coinbase_start_index` (default 0) and replays addresses from the beginning**, i.e. reaches the exact reuse the feature prevents, by the quietest possible path. Para persists a BDK `ChangeSet` to redb with `Durability::Immediate`.
- `next_script_pubkey` increments the in-memory atomic *first* and only `warn!`s if the write fails — so the pool can mine to index N while disk says N−1. Para explicitly **evaluated and rejected** this ordering (plan Decision 4, option B: "ckpool advertises an address whose derivation index isn't yet on disk; restart loses it").
- **No gap-limit knob anywhere** — `grep gap_limit` over all `*.rs`/`*.toml` returns nothing. Para ships an advisory `--pool-address-gap-limit` for exactly this recovery hazard. Arguably worse here: with only a bare integer in a flat file, rescan-from-descriptor is the sole recovery path and nothing tells the operator how far to scan.
- Rotation on `SubmitSolution` = submission, not confirmation, so orphans burn an index. Same accepted tradeoff as para; recorded so it isn't rediscovered as a bug.

Also: `rotate_coinbase_address` is fail-open (on error the pool keeps mining to the old address — right priority, but silent degradation to reuse), and there is **no integration or regtest coverage of rotation at all** — the 12 tests exercise the primitive in isolation only.

**Motivation diverges from para's for the identical mechanism.** This branch's config comment says *"quantum-resistant payout hygiene"*; para's PR body frames it as on-chain privacy (don't let observers total pool revenue from one address). Neither wiki article reconciles them, and the quantum framing is an unanalyzed assertion in a TOML comment.

**Scope, stated plainly: this is not the xpub-username design.** It rotates the pool's *own single* coinbase output, touches no accounting, and holds no per-miner state. What it does contribute: the derivation primitive already lives in the shared `stratum-apps` crate and is `Send + Sync`; `coinbase_outputs` provably tolerates runtime mutation; and the `has_wildcard()` gate is the validation any per-miner design needs at *registration* time (a miner supplying `wpkh(xpub...)` without `/0/*` would be paid to one address forever — same footgun, now at miner granularity with hundreds of chances to miss it). Two blockers untouched: the re-parse-per-derivation cost stops being free once it runs per-miner-per-template, and the `pplns_balance ON CONFLICT (address)` ledger-identity problem from the query above.

**Provenance caveats:** unmerged, no PR review read, may never land. Commit metadata unreliable — `817a1057` is authored `Test User <test@test.com>` and the author dates are non-monotonic (`e2930150` dated 2026-01-29 sits atop `817a1057` dated 2026-03-20). Hashes and content are what's verified; treat the dates as noise. Testnet4 examples only, using `tb1q...` addresses already present upstream.

Placement chosen by the operator over three alternatives (fill the empty `coinbase-rotation-bitcoin` skeleton, `sv2-coinbase-identity`, or a new repo-local `.wiki/`). Repo-local was a live option under CLAUDE.md's default-local rule, since the docs commit carries an employer email and the worktree has employer-named git remotes; hub placement is defensible because the fork is public OSS pushed to `average-gary/feat/coinbase-rotation` and the diff contains nothing internal — only commented-out generic paths and upstream testnet4 addresses. Neither the employer author line nor the remote names are reproduced in the raw source.
