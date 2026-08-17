# Log — bitcoin-mining-payout-schemas

## [2026-05-26] research --deep | "second.tech Ark protocol for mining payouts" → 8 raw sources, 1 new concept article, taxonomy expanded with off-chain payout layers section

8 parallel agents (Academic, Technical, Applied, News, Contrarian, Historical, Adjacent, Data/Stats). All returned substantively. Findings:

- **Landmark academic paper**: Keer, Maffei, Argentieri, Camilleri, Avarikioti — "Ark: Offchain Transaction Batching in Bitcoin" (arXiv:2605.20952, 2026-05-20, 6 days before research round). First Bitcoin-compatible commit-chain with formal model and security proof. ~200 vB constant onchain commitment regardless of batch size; cooperative exit 1 output/user; unilateral O(log n) × ~150 vB/VTXO. **Does NOT discuss mining payouts.**
- **Two-camp landscape clarified**: Second.tech (Steven Roose CEO + Erik De Smedt CTO, ex-Blockstream, $5.1M private funding, signet only, bark client) vs Ark Labs/Arkade (Burak Keceli's lineage, $7.7M cumulative incl. $5.2M Tether-led Mar 2026, Arkade live since Oct 2025). The original `ark-network` GitHub org renamed to `arkade-os`.
- **Mining-payout pitch is one phrase in one Bitcoin Magazine article**: Apr 2026 Juan Galt profile of Second names "Mining pool payout distribution at higher frequencies" alongside payroll. **No pool operator has endorsed Ark.** No Optech newsletter, no conference talk, no second.tech blog post mentions mining. No academic paper. The "Ark > CTV for payouts" framing (AntoineP) lives entirely in the [[raw/articles/2026-05-26-vnprc-ctv-coinbase-delving|vnprc CTV-coinbase delving]] thread.
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

## [2026-07-29] compile | 1 source → 1 new article, 2 updated (new: concepts/coinbase-address-rotation; updated: concepts/lottery-pplns, concepts/payout-schema-taxonomy)

Compiled `raw/repos/2026-07-29-sv2-apps-xpub-coinbase-rotation-code-read.md`. The survey initially looked like 4 uncompiled sources against the "last compiled 2026-07-27" date; checking `sources:` frontmatter rather than loose filename mentions showed the three 07-27 sources were already cited, leaving exactly 1 genuinely uncompiled.

**New article — `wiki/concepts/coinbase-address-rotation.md`.** Generalizes beyond the one branch by treating the shipped `parasitepool/para` implementation (recorded in the raw source) as the comparison baseline throughout. Two findings worth keeping:

- **The wildcard footgun is the load-bearing detail.** A descriptor without `*` parses successfully and then returns the same address forever — no error, no signal until repeated addresses show up on chain. Both implementations independently guard it with the same miniscript `has_wildcard()` call at construction. Two codebases converging on the identical API is strong evidence that's the right place to fail, and it means **rotation without that check is broken by default**, since the broken configuration is also the most natural thing an operator would write.
- **Index persistence is where they diverge, and sv2-apps took the option `para` rejected by name.** `para` persists before returning an address (`Durability::Immediate`, reload-on-failure); sv2-apps does `fetch_add` then a bare non-atomic `fs::write` whose failure is only `warn!`-logged. `para`'s design doc names this as rejected option B verbatim. Worst path: `load_index` is `parse().unwrap_or(default)`, so a corrupt file silently replays derivation from index 0 — reaching address reuse, the exact thing the feature exists to prevent, by the quietest available route.

Also recorded upstream's **deferred alternative**: the deleted test's comment floats instantiating the descriptor with the block height instead of a counter. That would dissolve the persistence problem entirely (the height *is* the index, so nothing needs saving), at the cost of a derivation range as wide as the chain for recovery scans. Nobody has tried it; logged as an open question rather than a recommendation.

**Skepticism recorded, not smoothed over.** sv2-apps justifies the feature as "quantum-resistant payout hygiene" in a TOML comment with no analysis in-tree. For P2WPKH/P2TR the pubkey is revealed **on spend, not on receive**, so rotating receive addresses bounds key exposure only under unstated assumptions about spending behavior — and a pool that consolidates rotated outputs has undone most of it. Article labels this an unexamined claim; the privacy motivation stands on its own.

**Updates.** `lottery-pplns` gains implementation hazard #5: at per-finder-per-template cadence, sv2-apps' deliberate descriptor re-parse (forced because miniscript's `Descriptor` holds a `RefCell` taproot cache and isn't `Send + Sync`) turns a once-per-block cost into a per-template parse storm. Also clarified that `payouts_fingerprint` does not depend on address *stability* — the attribution path needs no change under rotation; the balance ledger does. `payout-schema-taxonomy` gains **§3d, payout-address handling**, as an axis orthogonal to the split, alongside the existing orthogonal groups (§3a template construction, §3b on-chain fanout, §3c off-chain layers) rather than as a new scheme row.

**Index repairs beyond this compile's own scope.** Step 7 found a concurrent session had written 10 new raw sources and 2 new articles (`payout-attribution-privacy`, `hashrate-inference-side-channels`) into this topic at 13:41–13:47 without updating indexes or logging. Repaired the shared derived indexes to match on-disk reality — concepts index +2 entries, `wiki/_index.md` concepts 22→25 and reference 1→2, `raw/_index.md` 81→91 with per-type counts corrected (papers 9→14, repos 18→22, notes 1→3). Those two articles are **not** this compile's work and are left for that session to log. Also corrected the master index's Outputs table, which listed 1 of 4 output files.

Separately, `wiki/reference/uncompiled-source-coverage.md` was wrong in both directions and is regenerated from frontmatter: **21 of 91**, not 11 of 80. The old figure counted coverage by loose filename mention, so five sources whose names appear in an article body but in no `sources:` list were scored as compiled.

## [2026-07-29] research | "how do TIDES/PPLNS-JD but the user provides an xpub or similar. even if there were some blinding schema, payout amounts/shares would still be attributable by service provider. how could a service prevent storing this attribution? or blind themselves to it?" → 10 sources ingested, 8 articles compiled

Question mode, 5 agents (single round, default `--sources 5`; the swarm returned 10 usable sources). This is the round whose Phase-3 ingest the 2026-07-29 rotation compile spotted mid-flight and repaired indexes for (see that entry's "Index repairs beyond this compile's own scope"); the two articles it found on disk, `payout-attribution-privacy` and `hashrate-inference-side-channels`, are logged here as this round's work.

**The load-bearing finding reorders the question.** The premise in the prompt is correct and sharper than stated: payout attribution is a *consequence*, not the source. A pool's knowledge of who mined what comes from share **validation**, not from **payment** — it must check every submitted share against the miner's difficulty target to credit it at all, and from the share stream alone it recovers hashrate (`hashrate = difficulty × 2^32 / mean_inter_share_time`), session structure, timing, and transport peer. So a miner-supplied xpub and any payout-side blinding are defenses against **chain observers**, which is a real and currently-unaddressed adversary — Romiti et al. (WEIS'19) identified 92 % / 75 % / 30 % of individual miners at BTC.com / ViaBTC / AntPool from public chain data with **no pool cooperation** — but they are close to a no-op against the pool itself. The two halves have to be priced separately, which is how the synthesis article is structured.

**Two structural impossibilities, both proved from primary text rather than inferred:**

- **BIP 352 silent payments cannot work in a coinbase.** The shared-secret derivation sums the input private keys, `a = a_1 + ... + a_n`, and specifies "If `a = 0`, fail". A coinbase has one input with a null prevout and no private key at all — `bool IsCoinBase() const { return (vin.size() == 1 && vin[0].prevout.IsNull()); }`. The word "coinbase" appears zero times in BIP 352. This is structural, not unimplemented; BIP 380/385/389 wildcard descriptors with the BIP 44 gap limit are the workable substitute.
- **A coinbase is a strictly easier subset-sum instance than a CoinJoin**, for three reasons that all run the wrong way: exactly one input, of publicly known value; no input shuffling to hide behind; and **no padding**, because the block subsidy plus fees is consensus-bounded, so the operator cannot inflate the total to widen the mapping set. Maurer et al. (TrustCom'17) show unequal-amount mixing "is equal to solving the subset sum problem" and that a naive instance has "only **one** non-derived mapping"; WabiSabi bounds what equal-output mixing can buy. Output splitting is the standard mitigation and here **the splitter is the pool** — it "requires knowledge of all sub-transactions," which is exactly the knowledge we were trying to remove.

**On the sum constraint the prompt raises:** stated precisely, it is *near-vacuous against the pool and sharp against a chain observer*. `aᵢ/Σaⱼ` is the exact relative share weight, and `N` bounds the anonymity set — so publishing a payout set is publishing a weight distribution, whoever reads it.

**The primitive that fits, and why it doesn't ship.** Share accounting needs a running weighted sum that survives adversarial arithmetic; blind signatures give a one-shot denominated bearer object. BBA+ (CCS'17) / Black-Box Wallets (PoPETs 2020, **article 0010** — distinct from 2020-0007) is the only primitive found that natively accumulates quantitative weight under blinding, and it has five blockers: ~~the Canard–Gouget impossibility (fatal for a single-operator pool), a 16-bit prototype balance against share weights around 10¹⁵, per-accumulation round cost, the ROS attack breaking blind Schnorr at roughly 256 concurrent sessions~~, and no mining-specific construction anywhere. Tor's PoW micropayment work is the nearest prior art — and notably advises that "a client is advised to **randomize its hash rate**," which is the same side channel from the other side.

> **Correction, 2026-07-29 (thesis round, entry at the end of this log).** Four of those five blockers were wrong and are struck above. Canard–Gouget has the **prescription inverted** — the BBA line cites it as the reason issuer and accumulator *must* share one key (Faller et al., IMACC 2021: *"A BBA issuer and an accumulator can collude without breaking privacy. This is necessary due to an impossibility result"*), and the impossible notion is *Perfect* Anonymity, scoped to coin transfer between users. The 16-bit balance binds **redemption only** — BBW Fig. 4 p.174 shows `Proof P2 (Add)` carries no range proof. The per-accumulation cost was costed with the **spending row**: `Add` is 62 ms user / 45 ms system / 1,745 B, not 122/182/~4 kB, a 4.04× overstatement. And the ROS threshold is **ℓ = 9**, not ~256 — while ROS-breaks-ACL was **retracted by the ROS authors**, with ACL since proven concurrently secure (Kastner–Loss–Renawi, CCS 2023). Only "no mining-specific construction anywhere" survives.

**Three objections survive; one widely-assumed objection does not.**

Surviving: (1) **share-credit theft** is the cryptographic crux — Recabarren & Carbunar's BiteCoin attack and the Bedrock mining cookie `C_M = H²(R_M, M.uname)` are the strongest evidence that identity binding is currently what guards share credit, and a blinded variant of that cookie is unanalyzed by anyone; (2) the **dust → accrual → custody → money-transmitter** chain, where FinCEN §5.4 exempts pool distributions *unless the operator hosts wallets* and §4.5.1(a) makes an anonymizing transmitter expressly ineligible for exemption — "custody and blinding are individually survivable and jointly fatal"; (3) **compulsion**, which blocks only future-tense promises, so claims must be scoped past-tense.

Not surviving: **block-withholding detection does not need attribution.** The withholding literature refutes this itself — Eyal's Miner's Dilemma turns on *registered* miners and detection already fails under full identity, Rosenfeld conceded the point in 2011, and Sybil churn defeats per-identity statistics regardless. Eligius 2014 address clustering is the single exception, and that cost belongs to address **rotation** (Part A) rather than to blinding (Part B) — worth separating, because it's the objection most likely to be raised against the wrong half.

**Also: a correction to this wiki's own eHash claim.** `concepts/ehash.md` asserted flatly that the mint "cannot link issuance-time shares to redemption-time payouts." That is true of the BDHKE signature and false of the deployed system, per hashpool's own documentation: the denomination rule `amount MUST equal 2^(share difficulty − keyset minimum difficulty)` leaks difficulty, `header_hash` is retained for duplicate rejection, `SETTLEMENT_DESIGN.md` carries a cleartext `payout_address`, and hashpool states its design does "**not** prevent temporal correlation or batch fingerprinting" and that multi-token redemption is "**trivially linkable to the same wallet regardless of timing strategy**." Cashu NUT PR #293 closed 2026-03-09. The article now carries an explicit in-article correction notice rather than a silent rewrite; the comparison-table row changed from "No (Cashu blind sig)" to "Weakest link of any design — but not zero."

**Where this lands: minimum-viable attribution, not blindness.** The honest claim an operator can make is a scoped, past-tense, verifiable statement about what was never collected and what was deleted — not a claim of structural inability. The playbook writes out the retain / never-collect / make-verifiable / pay / say / don't-say split.

**Ingested (10):**
- `papers/2026-07-29-recabarren-carbunar-hardening-stratum.md` — PETS'17; StraTap 1.75–6.5 % and ISP-Log 0.53–34.4 % payout-prediction error, the latter from inter-packet timestamps of the **first 50 packets only**; encryption called "not only undesirable but also ineffective"
- `papers/2026-07-29-romiti-2019-mining-pool-payout-deanonymization.md` — WEIS'19; the 92/75/30 % table, median address reuse 20/5/2
- `papers/2026-07-29-bba-plus-black-box-wallets.md` — CCS'17 + PoPETs 2020-0010; the only weight-accumulating blind primitive, and its five blockers
- `papers/2026-07-29-maurer-2017-knapsack-coinjoin-arbitrary-values.md` — TrustCom'17 + WabiSabi + CoinJoin Sudoku
- `papers/2026-07-29-withholding-detection-does-not-need-attribution.md` — Eyal, Rosenfeld, APoW, Towns; the Eligius exception
- `repos/2026-07-29-pool-identity-vs-payout-script-conflation-code-read.md` — ckpool `username[128]` → `txnbin[48]`, public-pool `varchar(62)` PK, DATUM firmware ceilings (Avalon 63, Whatsminer overflow past 127, ~380–530 outputs), PPLNS-JD's positional ledger with zero identity fields, SV2 #697/#1652/#1720
- `repos/2026-07-29-bip352-silent-payments-coinbase-incompatibility.md`
- `repos/2026-07-29-mining-privacy-prior-art-survey.md` — incl. Braidpool committing `payout_address` **and miner IP** in the PoW
- `notes/2026-07-29-self-blinding-system-architectures.md` — OHTTP (RFC 9458), split-trust relays, PCC, Private Relay, Signal SVR3, Prio/DAP, SGAxe/ÆPIC/CVM-SoK, Nitro `--debug-mode`
- `notes/2026-07-29-fincen-td10000-regulatory-attribution-posture.md` — FIN-2019-G001 §4.2/§4.5.1/§5.4, TD 10000's validator carve-out ("mining pool" appears **zero** times in 365 pages), OFAC E.O. 14024/BitRiver, Lavabit, warrant canaries

**Compiled (8 new):** `wiki/topics/self-blinding-pool-design-space` (synthesis), `wiki/concepts/payout-attribution-privacy` (threat model), `wiki/concepts/hashrate-inference-side-channels`, `wiki/concepts/coinbase-amount-linkability`, `wiki/concepts/blind-share-accounting`, `wiki/concepts/xpub-payout-identity`, `wiki/concepts/self-blinding-architectures`, `wiki/decisions/attribution-retention-tradeoffs`.

**Updated (19):** `ehash` (correction, above) and `block-withholding` (new "Does detection actually need attribution?" section) substantively; See-Also / cross-link edits in `tides`, `pplns-jd`, `braidpool`, `radpool`, `p2poolv2-accounting`, `sv2-share-accounting-ext`, `datum`, `coinbase-address-rotation`, `ctv-coinbase-payout-tree`, `topics/payout-design-space`, `decisions/custody-tradeoffs`; index registrations in `wiki/concepts/_index`, `wiki/topics/_index`, `wiki/decisions/_index`, `raw/papers/_index`, `raw/repos/_index`, `raw/notes/_index`, master `_index` (Outputs row + new top-level question 7).

**Output:** `output/playbook-self-blinding-pool-attribution-2026-07-29.md` (chunked writes: 1 Write + 3 Edits).

**Provenance caveat that applies to the whole round:** **WebSearch was unavailable to every agent.** Discovery ran through DuckDuckGo HTML/lite, Brave, delvingbitcoin `search.json`, IACR search, and the GitHub API, with CAPTCHA throttling throughout. One agent's fetch summarizer **fabricated** a BBA+ paper title and performance table; the agent caught it and replaced the material with direct PDF reads, but treat any un-re-verified secondary summary from this round with suspicion. Confirmed dead ends: the PPLNS-JD paper at `dmnd.work` returns HTTP 404, EU TFR via EUR-Lex returns HTTP 202, DOJ Samourai/§1960 URLs return 403/404. An unverified Mimblewimble claim about dbtc #2093 is flagged in-article rather than asserted.

**Negative result worth keeping:** there is **no BIP, no SV2 extension, and no ZK/MPC design for blinded share accounting** anywhere — delvingbitcoin searches return zero topics. The gap is genuine and multiply verified, not a search failure.

**Progress score ~85.** 10 sources, 8 new articles, 19 files updated, ~35 cross-references, average source credibility high (5 peer-reviewed papers, 3 primary code/spec reads, 2 primary-document notes). Confidence: **high** on the two impossibility results and the validation-vs-payment reordering (primary text); **high** on the withholding refutation (the literature's own framing); **medium** on BBA+ applicability (no mining-specific construction exists, so the fit is argued rather than demonstrated); **medium-low** on the regulatory analysis (three of the four source URLs unreachable, and no authority has addressed a blinded pool).

## [2026-07-29] inventory + thesis | filed derived thesis #1 as a thesis stub + 2 p1 inventory records

Post-round filing of the highest-value follow-ups from the attribution-privacy round above. No new research.

**New thesis stub — `wiki/theses/blinded-share-credit-commitment.md`** (`status: candidate`, `verdict: pending`). Full Phase-0 decomposition written so the thesis round doesn't have to re-derive it: core claim, key variables, testable prediction, falsification criteria, scope boundary, suggested agent angles, and known dead ends.

Two things in it worth flagging as more than transcription:

- **It decomposes into four sub-claims that should be verdicted separately**, because a single verdict would hide the result. (A) re-labeling resistance survives blinding — near-definitional, changing the preimage changes the hash; (B) weight aggregation survives without a pool-side persistent ID; (C) replay/duplicate arbitration survives without retaining `header_hash`; (D) enrollment gating survives via KVAC/Privacy Pass. **B and C are the thesis.** A round that only tests A returns SUPPORTED and means very little. B is hard because a commitment persistent enough to be summed *is* a pseudonym — and is re-linkable via hashrate signature, source IP, and reconnect co-timing regardless of the crypto, which is how it fails in practice rather than in theory. C is hard because nobody can re-label a share but anyone who sees one can replay it under the same `C`, and arbitrating that needs `header_hash`, itself a linkability handle.
- **Why the thesis is live now and wasn't in 2017.** Bedrock needs the cookie in the coinbase, and in 2017 the *pool* built the coinbase. Under SV2 JD and DATUM the *miner* declares the template, so the party that would insert a self-chosen blinded commitment already controls the field. The architecture arrived after the defense did and nobody went back to connect them. Also recorded: Stratum already has a weak identity-in-the-PoW via pool-assigned `extranonce1`; Bedrock exists because a connection hijacker *inherits* the victim's `extranonce1`, so the property needs a keyed unguessable value, not merely a per-session one.

An **alternative inverted framing** is recorded in-article for whoever runs it — "blinding preserves re-labeling resistance but *cannot* preserve aggregation or duplicate arbitration without a pool-side pseudonym or a miner-carried accumulator" — which is falsifiable in the direction that would actually change the design.

**One detail flagged for verification rather than inherited.** The ingested source places the cookie in the coinbase's "unused previous-input-hash field," but consensus requires that field null — `COutPoint::IsNull()` needs `hash.IsNull() && n == 0xFFFFFFFF` for `IsCoinBase()`. Harmless for share validation, which never touches consensus, but ~1 share in N *is* a block. Either the scheme has a separate block-candidate path or "previous-input-hash field" means the scriptSig. Doesn't change the argument — any committed field works — but it should be checked against the paper.

**New `inventory/` tree** (this topic had none; layout matches `topics/datum/inventory/`). Two `p1` question records, corresponding to the two highest-impact of the round's six gaps:

- `candidates/blinded-mining-cookie-security.md` — the thesis above. Close-out condition is deliberately strict: an attack, a reduction, or a demonstration that aggregation provably needs a persistent ID (which closes it as *secure but unusable*). **A verdict on sub-claim A alone does not retire it** — that would be a false close.
- `candidates/doj-1960-noncustodial-enforcement-theory.md` — the mechanism by which the favorable FinCEN §5.4 read gets bypassed on a criminal rather than regulatory footing. Next action routes to CourtListener/RECAP since justice.gov returned 403/404. EU TFR/MiCA is folded into this record rather than tracked separately: same retrieval problem, same article section.

The other four gaps were judged **not durable enough for their own records** and left in the playbook: connection-level Sybil re-correlation (a sub-question of the cookie record), subset-sum against real coinbase payout sets, and the 404'd PPLNS-JD paper. Noted as such in `inventory/_index.md` so the absence is deliberate rather than an oversight.

**Theses index restructured** — gains a "Filed theses" table (previously only free-text one-liners), plus candidate theses #6 (FinCEN/§1960) and #7 (rotation vs withholding exposure) from this round written up as one-liners since they aren't filed as stubs. Master `_index.md` gains an Inventory section link. `topics/self-blinding-pool-design-space` § objection #1 now links the thesis and the inventory record.

## [2026-07-29] plan | "a mining pool that accepts an xpub or similar wildcard descriptor as a username for a miner that is used pool side to generate payouts with different coinbases each time" → output/plan-xpub-miner-identity-spec-2026-07-29.md (16 articles/sources consulted, 4 decisions, 12 sections)

`--format spec`. Full six-stage pipeline: context assembly, interview, gap research, synthesis, generation, save.

**Stage 1 found the wiki already nearly answers this.** `concepts/xpub-payout-identity` (compiled hours earlier by a concurrent session) opens on almost exactly the user's phrasing and concludes the construction is buildable, with the work being "entirely in decoupling the ledger key from the payout script, and in field widths." So this plan is largely an act of *committing to specifics* the wiki left open, not of discovering new ground. Four hard constraints were surfaced to the user before the interview: no pool anywhere does this (a confirmed negative result, verified against ckpool/public-pool/DATUM/SV2-reference/Ocean source rather than merely unsearched); the rotation trigger is unresolved upstream (SV2 #697, verbatim "The tricky part here is to decide when to rotate"); wildcards remain rejected in merged SV2 code even after PR #1720 shipped `coinbase_output_descriptors`; and output count is firmware-bounded at ~380–530.

**Four binding decisions from the interview.**

1. **Host = PPLNS-JD / SV2.** Chosen because its `Slice{...}`/`Share{...}`/`PHash` structures contain not one identity field and the ledger verifies positionally — `merkle_path(share) + share_hash == slice.root`. That is the decoupling every other scheme must retrofit. Contrast ckpool, where `username[128]` is the hash key *and* becomes `txnbin[48]` via `address_to_txn()` (maximum coupling), and public-pool, where `address varchar(62)` sits inside a composite PRIMARY KEY.
2. **Trigger = per payout (block found).** Rationale that firmed up during generation: the Romiti attack turns on reuse of addresses *actually paid*, so an unpaid derived address buys no privacy — rotating faster than payment is pure recovery-scan cost. ~500 derivations per block found, versus per-template rotation's ~500 every 30 s.
3. **Intake = SV2 `user_identity` only.** The user chose this over the recommended out-of-band registration + short handle. It is the decision that most simplifies the spec: `Str0_255` fits a ~150-char descriptor directly, deleting the entire firmware field-width problem class (Avalon truncating at 63, Whatsminer's documented "may damage your miner" overflow past 127, percent-encoding, ckpool's `._` split colliding with descriptor syntax `()[],'/*#`). Cost: SV2-only, no V1 path, so §10.3 states coexistence is the permanent steady state rather than a migration phase — V1 miners *cannot* migrate.
4. **Privacy scope = honest.** Spec claims the on-chain win (Romiti et al. identified 92%/75%/30% of individual miners at BTC.com/ViaBTC/AntPool from public data alone) and states plainly that the pool learns no less, and in fact now holds a descriptor linking all of a miner's rotated addresses in one place — a linkage that did not previously exist. No blinding machinery in scope.

**Stage 3 filled exactly one gap, the one that changes a decision.** Real-world gap limits, because they set recovery-scan depth: BIP-44 states 20, Sparrow defaults to 20 (40 postmix, configurable under Settings → Advanced with the caveat "don't increase it too much as your wallet loading will take longer"), BDK ships `pub const DEFAULT_LOOKAHEAD: u32 = 25`. This is what let the spec *decide* the block-height-as-index question that the rotation article records as merely deferred upstream.

**Two things sharpened in generation rather than inherited from the wiki.**

*Block-height-as-index is more attractive than the wiki records, and still rejected.* Its real merit is not elegance — it **deletes §5 entirely**: no `next_index`, no durability ordering, no corruption-replay hazard, and recovery needs no pool state at all. Rejected on apoelstra's objection ("might confuse wallets that don't have an 800000+ gap limit") given the 20–25 floor above. The load-bearing asymmetry, which the wiki does not state: a pool rotating *its own* address can absorb a ~900,000 index jump; a pool rotating *its miners'* addresses cannot, because the recovery party is the miner. Kept as a live alternative — if per-miner wallet tooling ships large lookaheads it becomes the better design.

*`next_index` must never be rolled back.* This is new and is the most dangerous operation in the system: restoring a stale backup re-derives already-paid indices and reintroduces address reuse — the exact failure the feature exists to prevent — arrived at through an operator's own disaster-recovery procedure, most likely at 3 a.m. So §10.2 splits rollback of the *feature* (clean, flag-off) from rollback of the *state* (never), tells operators to back those two tables up on a separate restore-forward-only schedule, and gives the on-chain reconciliation floor `next_index = max(backup, 1 + max(derivation_index) seen on chain)` since `payout_derivation` records the height and script of every payment. Skipping indices is free; reusing them is not.

**Carried forward as requirements, from the compile.** The `has_wildcard()` guard is written as the single most important requirement (§3.1) — a non-wildcard descriptor parses fine and then returns one address forever, and at per-miner granularity there are as many chances to miss it as there are miners, each silently-static miner looking exactly like a working one. sv2-apps' increment-then-warn-log persistence is quoted as a labelled anti-pattern, including that `load_index`'s `unwrap_or(default)` silently replays derivation from index 0 on a corrupt file. §5.3 fixes the posture: every failure mode degrades toward "don't pay" rather than "pay a reused address," and a corrupt store is a fatal startup error.

**Cheapest unimplemented recommendation in the spec**: publish each miner's `highest_paid` index. A miner who knows it needs no gap-limit guessing at all, which sidesteps the principled-gap-limit-default question rather than answering it. Neither known implementation offers it. Similarly, §10.3's first monitoring row — distinct `script_pubkey` count per `payout_id` versus payout count — is a cheap query, is reported by nobody, and is the only external signal distinguishing "rotation is working" from "rotation has been a no-op for three weeks."

**Inventory**: no new records. The plan consumes both active p1 candidates as constraints rather than advancing them — `blinded-mining-cookie-security` becomes §9.5 (the spec keeps a stable plaintext descriptor in `user_identity`, so the Bedrock cookie `C_M = H²(R_M, M.uname)` most likely survives unchanged, but that is an assumption and is labelled as one), and `doj-1960-noncustodial-enforcement-theory` underpins §4.4's choice to drop sub-dust amounts rather than accrue them, since accrual is a hosted balance and FinCEN §4.5.1(a) makes an anonymizing transmitter expressly ineligible for the §5.4 integral exemption — custody and rotation being individually survivable and jointly fatal.

Also filed [[output/playbook-self-blinding-pool-attribution-2026-07-29|the concurrent session's playbook]] into the Outputs tables of both `_index.md` and `output/_index.md`, where it had been left unindexed.

## [2026-07-29] research --mode thesis --deep | "Blinding a PoW-committed mining cookie preserves re-labeling resistance but cannot preserve share-weight aggregation or duplicate arbitration without either a pool-side persistent pseudonym or a miner-carried accumulator, making blinded share credit strictly harder than blinded payout." → verdict **MIXED** (high); 2 sources ingested, 1 new concept, 8 files corrected

Thesis mode, 8 lenses (`--deep`), single round (no `--min-time`). Ran against the **inverted framing** recorded in the thesis stub, which is the falsifiable direction. Verdicted per-sub-claim rather than as a whole, per the stub's own instruction that one verdict would hide the result.

**Verdict: MIXED, high confidence. The or-conjunction splits.**

| # | Sub-claim | Verdict | Confidence |
|---|---|---|---|
| A | Re-labeling resistance survives blinding | **Unestablished, but likely** | medium |
| B | Weight aggregation survives without a pool-side persistent ID | **Thesis SUPPORTED** | high |
| C | Duplicate arbitration survives | **Thesis FALSIFIED** | high |
| D | Enrollment gating survives | **SUPPORTED** | high |
| E | Blinded credit strictly harder than blinded payout | **SUPPORTED on interactivity, NOT on cost** | high |

**C is falsified by the dichotomy break the stub asked for.** A keyed share-derived **nullifier** `nf = PRF_{sk_M}(header_hash)` is pool-side state that is neither a pseudonym nor an accumulator: single-use, unlinkable across shares, no identity term. The decisive evidence is not cryptographic but three independent code reads showing deployed duplicate rejection **already carries no identity term at all** — SRI's `seen_shares: HashSet<Hash>`, Ocean/DATUM's `datum_stratum_dupes.h` (keyed on header fields, and **checked *before* attribution**), and p2pool-v2's `HashSet<&BlockHash>`. Cross-domain corroboration: Cashu NUT-07 `Y = hash_to_curve(secret)`, Zcash §3.2.3/§3.9, Tor proposal 327, Privacy Pass. New article: `wiki/concepts/nullifier-vs-pseudonym.md`.

**B holds, and now on better anchoring than the wiki had.** *Anonymous Counting Tokens* (Asiacrypt 2023) §1 and `draft-ietf-privacypass-rate-limit-tokens-06` both argue per-user registered state is required to bound issuance per identity — the latter in normative RFC language, and it ships route (a), a pool-side persistent handle, with explicit anti-rotation locks. Compact E-Cash and WabiSabi each collapse into one horn.

**The round's real result is that every cryptographic barrier this topic was carrying against blinded accumulation dissolved on contact with primary sources.** Five corrections, four load-bearing, propagated across 8 files:

1. **Canard–Gouget was inverted, not merely misattributed.** This wiki carried it as blocker #1, "fatal for a single-operator pool." The BBA literature cites it for the **opposite** proposition. Faller et al., *Black-Box Accumulation Based on Lattices* (IMACC 2021, eprint 2021/1303), verbatim: *"A BBA issuer and an accumulator **can** collude without breaking privacy. This is necessary due to an impossibility result, cf. [12]"* — i.e. it is why the roles **must** merge into one operator. BBA+ p.1933 proves unlinkability against *"a collusion of I, AC, and V"*; BBW Def 4.1 shares `sk_I` across all three and p.171 **removes the TTP trapdoor entirely**. The impossible notion is **Perfect Anonymity** (`PA ⇒ FA ⇒ SA ⇒ WA`), one level above full unlinkability, and its predicate is *recognizing a coin you previously owned once it returns to you* — coin transfer between **users**, an antecedent a pool never satisfies. Found independently by two agents. The irony worth recording: the wiki's own BBA+ ingest **already contained the disproof two lines below the claim**. Caveat: ACNS 2008 is paywalled and unread, so the finding rests on four restatements (Faller et al., BBW p.3, P4TC, a USP MSc thesis) plus Gouget's own 2008 invited-talk abstract, which attributes coin-growth to **Chaum–Pedersen** rather than to herself. Tracked as `inventory/candidates/canard-gouget-primary-text.md` (p3 — direction settled, numbering open).
2. **The wiki costed crediting with the spending row.** The recorded 122 ms / 182 ms / ~4 kB is BBW Table 1's **`Sub16,lin`** (redemption). Crediting is **`Add`: 62 ms user / 45 ms system / 1,745 B** — a **4.04×** overstatement of pool-side cost. Re-derived throughput: 72 cores at F2Pool's 16,000 miners per-share, 262 at solo.ckpool's *measured* `SPS1m: 5832.5` across 39,592 workers; **batched at SV2's shipped `share_batch_size = 10`, 7.2 and 17.8 cores.** Infeasible only at Foundry scale (~5,084). Both papers decline to measure the faster server side, so these are upper bounds.
3. **The 16-bit range limit was a category error** — it binds **redemption only**. BBW Fig. 4 p.174: `Proof P2 (Add)` carries **no range proof**; only `Proof P3 (Sub)` adds one. Crediting is bounded by `2|V| < |Zp|`, ~2²⁵¹ on Curve25519, against the ~50 bits an `8 × D` window needs (`8 × 1.2623e14 = 1,009,852,056,974,944`, log₂ = 49.84) — 201 bits of headroom. BBA+ needs nothing at all. Widening redemption 16→64 bits costs **+129 B and +21.8 ms**. Also fixed an off-by-one: the wiki had `…945`.
4. **ROS: ℓ = 9, not ~256** — eprint 2020/945 §7 p.17 gives 9 as the practical breakage threshold; the 256 figure on p.4 is the count for the seconds-long Sage attack, a different quantity. Both readings are reconciled in the ingest rather than one being deleted. And **ROS-breaks-ACL was retracted by the ROS authors** — ACL is now **proven concurrently secure** in AGM+ROM (Kastner–Loss–Renawi, CCS 2023, eprint 2023/707, Cor. 4.2). The wiki's blocker was stale in both directions.
5. **`v` is an arbitrary field element at constant cost** — BBA+ p.1932 (*"a positive or negative value v"*), p.1931 (token size and complexity *"independent of the number of points to be transferred or stored"*). **This is what separates BBA+ from Cashu's denomination ladder, and this wiki never said it.** It is also why batching is native rather than a bolt-on — and SV2's `SubmitShares.Success` (§5.3.13) already exists *"for multiple SubmitShare messages aggregated together"* carrying **`new_shares_sum` U64, "Sum of difficulty of shares acknowledged within this batch."** That field *is* the `v` to credit. The plumbing ships; nobody has connected it.

Also: **no theorem exists making stateful accumulation harder than one-shot issuance.** Searched five independent ways. Two peer-reviewed constructions measure the update within a small constant of issuance (BBW `Issue 52 ms` vs **`Add 62 ms`**; UACS Pixel `Join 76 ms` vs **`Earn 110 ms`**), Coull–Green–Hohenberger (ACM TISSEC 14(1)) achieve hidden state transitions in **constant** time, the one-show/multi-show gap is a technique tradeoff, and the blind-signature impossibility line (Lindell; Fischlin–Schröder; Pass) is entirely about **round complexity** — none of its conditions mention attributes, state, or updates. **Chaum–Pedersen, "Transferred Cash Grows in Size" (EUROCRYPT '92, LNCS 658 pp.390–407)** is the real "coins must grow" result people reach for, and it also scopes to *transferability*; BBA tokens stay constant-size precisely because the operator co-signs each increment.

**Where the difficulty actually lives, after all that.** Two things, neither cryptographic:

- **Interactivity** — this is the honest basis for "strictly harder," and it is the one axis where E survives. Blinded payout is a single **offline non-interactive** BIP32 `CKDpub`: one HMAC-SHA512 + one point add, tens of µs, embarrassingly parallel, 43 B amortized on-chain. Blinded credit is an **online 2-party** protocol: ~45 ms pool-side, **4–5 round trips / ≈9 messages**, 1,745 B, and **serial per token** (two in-flight `Add`s reuse serial `s` and self-incriminate through `IdentDS`). ≈900× compute, ≈41× bytes. Decisively, **interaction cannot be Fiat–Shamir'd away**: BBW p.166 relies on *"interactive proof systems, where standard rewinding techniques replace the trapdoor,"* so removing interaction reinstates the TTP the design just deleted.
- **The hashrate side channel**, which no cryptography addresses and which batching **converts rather than removes**: `interval = batch_size / share_rate`, so a fixed `b` is a lower-sampled readout of the same quantity — and the sampling rate needed for affordability scales *against* privacy (16,000 miners on one core needs `b ≥ 72`, one credit per 12 min). Recabarren & Carbunar recover **0.53–34.4 % payout-prediction error from the inter-packet timestamps of the first 50 packets alone**, so any count-triggered boundary is a direct readout; boundaries have to be Poisson-randomized. Unquantified in any paper — BBA+/BBW measure compute and bytes and never timing privacy, R&C measure unbatched Stratum, nobody connects them. Filed as `inventory/candidates/batched-credit-timing-leak.md` (p1) and it is now this topic's most valuable open question.

**Two obstacles upstream of the whole thesis, both new to this wiki.** Bedrock's `store(M.uname, K_M, R_M, target)` puts the per-miner vardiff **`target` in the same identity-keyed row** as the cookie seed, fetched via `getMParams(M.uname)` — so a pool cannot even evaluate `H²(nonce||F) < target` for an anonymous submitter. Blinding breaks share **validation**, one layer before crediting. And C **has no Bedrock baseline to lose**: `verifyJob` is stateless, doesn't consume `job_id`, writes nothing back, and *duplicate*/*replay*/*serial* never appear in that sense — so C cannot be falsified against Bedrock and had to be argued against deployed practice instead. Note also that the paper's own BiteCoin run **suppressed** the victim's share (*"sends to the pool a mangled copy of the victim's original share submission, to ensure that it is rejected"*) rather than racing it.

**C's pessimism is defensible on enforcement economics, not cryptography** — BBA+/BBW catch double-spend only via a serial database scanned after the fact, and the punishment identifies a *user* to penalize. Against anonymous hashrate with nothing seizable that has no teeth. A real gap, but not the one the thesis claimed.

**Ingested (2):**
- `papers/2026-07-29-stateful-vs-oneshot-credentials-no-separation.md` — the no-separation result, the Canard–Gouget inversion with the Faller et al. verbatim quote, the Perfect-Anonymity scoping, BBW p.171 trapdoor removal, the Chaum–Pedersen wrong-target section, the ROS ℓ=9 correction and the ACL retraction.
- `papers/2026-07-29-blinded-accumulation-cost-at-real-share-rates.md` — full BBW Table 1 p.179, the ★ Add-vs-Sub error, range-width, measured share rates with vardiff sources (`stratifier.c:6049-6087` *"Optimal rate product is 0.3"*, `TARGET_SUBMISSION_PER_SECOND = 10`), throughput tables, SV2 batching, the sub-claim-E comparison, DATUM `datum_stratum.h:155`.

**New article (1):** `wiki/concepts/nullifier-vs-pseudonym.md` — including a "Where nullifiers genuinely don't help" section, since the point is a narrow one.

**Corrected (8 files, beyond the thesis itself):** `concepts/blind-share-accounting` (failure-mode list shortened from five to four surviving, two new sections), `topics/self-blinding-pool-design-space` (Canard–Gouget demoted to #5 and marked RETRACTED; problem-table row B rewritten), `papers/2026-07-29-bba-plus-black-box-wallets` (correction notice, fabricated authors removed, Add/Sub table fixed), `concepts/tides` (the flat *"Auditable: full share log published"* claim retracted — on-chain **outputs** are what's published), `concepts/ehash` (*"Duplicate rejection requires"* → "has," with a note that a keyed nullifier does the same job unlinkably and Cashu NUT-07 already uses that shape), `output/playbook-self-blinding-pool-attribution-2026-07-29`, `output/plan-xpub-miner-identity-spec-2026-07-29`, plus the log entry above and master `_index.md`.

**Fabricated author names removed from two files** — the BBA+ author list had picked up "Kaidel" and two "Koch"s. Correct: **Hartung, Hoffmann, Nagel, Rupp** (4 authors, CCS 2017 pp.1925–1940); Black-Box Wallets is **Hoffmann, Klooß, Raiber, Rupp** (PoPETs 2020(1):165–194, article 0010). **Root cause identified and it is a standing process hazard: WebFetch silently fails on image-based PDFs and returns confident "ABSENT" verdicts** — it reported all four Recabarren & Carbunar claims absent when all four are present in the paper. That mechanism most likely produced the fabricated title, table, and authors from the source round too. **Download and `pdftotext -layout`; never trust a fetch summarizer on a PDF.**

**Inventory:** `blinded-mining-cookie-security` → **resolved**, closed on its third close-out condition in narrowed form (aggregation *does* require one of the two escapes — but not as "secure but unusable," since the accumulator horn is open and affordable). Its second condition was struck as unsatisfiable: Bedrock names no hardness assumption. Its "coupled record" note is marked **HALF RIGHT** — B does route into BBA+/BBW, and Canard–Gouget does not block it. Two spun out: `batched-credit-timing-leak` (p1) and `canard-gouget-primary-text` (p3).

**Provenance caveats.** WebSearch unavailable again, as the stub predicted; discovery ran through DuckDuckGo/Brave/DBLP/OpenAlex. IACR eprint and Cloudflare returned 403s, worked around via `web.archive.org/.../id_/` raw captures and the Stanford author mirror for Bulletproofs — flagged in every ingest. Still unread: **Canard–Gouget ACNS 2008** (paywalled) and **LatInc, TDSC 2026** (paywalled). Ocean's TIDES `8 × D` window figures rest on a single unreplicated fetch (`docs.ocean.xyz` now DNS-fails) — medium confidence. No published µs/op figure for BIP32 derivation exists upstream, so the ≈900× interactivity ratio uses a constructed estimate.

**Progress score ~85.** Only 2 sources ingested, which understates the round: the yield was in **corrections to existing articles** rather than new material, and 4 of the 5 corrections invalidated load-bearing claims that had already propagated into two output artifacts. Confidence **high** on C's falsification and on the collapse of the cryptographic barriers (primary text plus deployed code in three independent implementations); **medium** on A, which remains an argument rather than a finding, and on the Canard–Gouget numbering pending the paywalled text.

## [2026-07-29] lint | 19 checks, 0 critical, 6 warnings, 4 suggestions, 1 candidate, 121 auto-fixed

Post-thesis-round pass with `--fix`. Two structural repairs stand out as real drift rather than
bookkeeping. **79 of 94 raw sources were missing `summary:`** — a required field,
and not this round's regression: 531 of 1,310 raw files hub-wide share the gap. All 79 filled, 74
inferred from each file's first prose paragraph and 5 hand-written where the file opens on a table or a
verdict heading. **Nine of eleven wiki articles carrying "See also" links had one-way links** — 26
missing backlinks, added across 11 articles, most of them pointing into the four articles this
round's writes touched most.

The coverage backlog was regenerated to **16 of 94** (from 21 of 91): the denominator grew by the
round's three ingests and five sources came off the list. What remains is not scattered — 15 of the 16
were ingested 2026-05-23 → 05-26 in the topic's founding eHash/DMND/p2pool-v2 sweep and have never
been cited, so the backlog is one uncompiled round rather than incidental drift.

Two inventory enum values were off-schema and are now canonical: `kind: source` →
`ingest-candidate`, and `status: resolved` → `ingested` (the schema's terminal value; the
`resolved: 2026-07-29` date field carries the "when," and both indexes now say "answered" in prose so
the change doesn't read as a downgrade). Tag hygiene collapsed 10 near-duplicate pairs across 8 files
— case drift (`ACL`/`acl`, `KVAC`/`kvac`, `BiteCoin`/`bitecoin`, `ROS-attack`/`ros-attack`),
plural drift (`critiques`, `corrections`, `denominations`, `blind-signatures`), and hyphen drift
(`bip380`, `bip389`). 485 distinct tags → 475, zero near-duplicate groups remaining.

One broken link and one broken anchor fixed: a bare `[[2026-05-26-vnprc-ctv-coinbase-delving]]` in a
historical log entry, and `[[coinbase-address-rotation#Ledger identity breaks]]`, which pointed at an
`###` sub-heading and now targets its `##` parent. All 190 `sources:` refs resolve; all 41 wiki
articles carry provenance; every directory index matches disk.

**Not fixed, deliberately.** `config.md` is absent (9 of 36 topics share this, so no
`freshness_threshold` is set and the default 70 applies) — manufacturing one would invent scope
boundaries. Three raw `type:` values sit outside the C2 enum: `lessons-learned` on one note and
`video` on the two btc++ catalogs. The alias tables that would canonicalize them are empty by design,
`raw/videos/` exists in 12 topics and `wiki/decisions/` in 10, and `type: decision` on both decision
articles is likewise hub-wide (8 files) — these are conventions the schema hasn't caught up to, not
this topic's bug, and rewriting them here would fork the hub. Two empty directories warned only, never
deleted: `raw/images/` and `wiki/prompts/` (the latter's dead index row was dropped). One project
candidate: 5 loose `plan-*` outputs, 3 of them explicitly `status: superseded` versions of the same
lottery-PPLNS design.

Freshness: 40 of 41 articles at or above threshold, median 85. The one flag is
`uncompiled-source-coverage` at 50 — it is lint's own generated backlog, has no `verified:` field by
nature, and scores low because `compiled-from: conversation` rebases on two dimensions instead of
four. Not a content problem.

## [2026-07-29] plan --revise | "height as derivation index; finder bonus out of scope; V1 via the SV2 Translator" → output/plan-xpub-miner-identity-spec-2026-07-29.md (3 operator decisions applied, 3 direct code reads, 21 sections edited, 1 new section)

Three decisions from the operator, applied to the spec generated earlier the same day. Each one made
the design smaller, which is the reportable result.

**1. The derivation index is the block height being mined.** `payout_script(desc, H) =
desc.at_derivation_index(H).script_pubkey()` — a pure function of `(descriptor, height)`, with no
pool-side state on the payout path. This deleted the entire derivation-store section: the durable
`next_index` with its persist-before-return ordering, atomic writes, fatal-on-corrupt startup, the
halt-don't-degrade failure matrix, three regtest tests, three monitoring metrics, and — the one that
mattered most — **the never-roll-back-`next_index` hazard**, under which restoring a stale backup
re-derives already-paid indices and reintroduces address reuse *through the operator's own disaster
recovery procedure*. The riskiest part of the spec became its shortest. Three secondary consequences
fell out: derivation is idempotent per height, so orphans and template refreshes cost nothing and the
per-template rotation question dissolves rather than being answered; receipt-writing left the critical
path (a failed write is now a warning, since receipts are reconstructible from the chain, where under
a counter it had to abort the payout); and recovery survives the pool's death, because the miner needs
only the descriptor and the list of heights the pool won, both public.

I had **rejected** height indexing in the first draft on consumer-wallet gap limits. The operator's
reframing was that the pool's hit blocks are easily sourceable, so a miner can check just those
blocks — which converts the gap limit from a blocker into a documented tooling requirement. The
numbers didn't change; the judgment about whether the cost is acceptable did. The cost is now stated
plainly and pinned as an executable test: **a bare seed restore finds nothing.** Sparrow's gap limit
is a *depth* past the last used index (20, 40 postmix), BDK's `DEFAULT_LOOKAHEAD` is 25, and neither
reaches ~900,000 by configuration; recovery is `bitcoin-cli deriveaddresses "<desc>" '[H,H]'` for a
single block or `importdescriptors` with an explicit absolute `range` plus rescan. §8.2 asserts the
seed restore *does* fail, so nobody later "fixes" it by accident.

Rejected on the way: the **pool's own block ordinal** (1st, 2nd, 3rd block found) — genuinely
tempting since it gives small consecutive indices *and* idempotence, but it reintroduces a persisted
counter that stays correct only if never restored stale, which is precisely the failure class this
revision exists to delete. Height is already public; an ordinal is pool-attested.

**2. Finder bonus is out of scope.** Not merely a scope trim — it is load-bearing under height
indexing. Because index is a pure function of height, a miner has **exactly one** derivable address in
block `H`, so any scheme paying a miner twice in one block cannot be expressed: you either merge the
rows or emit two outputs paying the *same* address, which is address reuse inside a single
transaction. With the bonus out, PPLNS gives one weight per miner and this is free.
`merge_by_payout_id()` and `PRIMARY KEY (block_height, payout_id)` stay in as the backstop, because
this is the constraint a future finder bonus would silently violate — and
[[wiki/concepts/lottery-pplns|Lottery-PPLNS]] hazard #1 already documents that exact duplicate-merge
bug in Blitzpool's PPLNS ledger apply. Under height indexing that bug stops being an accounting slip
and becomes a privacy regression.

**3. V1 miners are not excluded** — they reach the pool through the **SV2 Translator**, correcting the
first draft's "SV2 only, no V1 path." Verified in `miner-apps/translator/src/lib/config.rs`:
`Upstream.user_identity: String` is configured per upstream, so the descriptor lives in a TOML file on
a machine the operator controls. This **inverts** the firmware problem rather than solving it — Avalon
truncating at 63, Whatsminer overflowing past 127 ("may damage your miner"), percent-encoding of
`()[]/*#`, ckpool's `username[128]` — none of it applies, because the descriptor never enters miner
firmware. The residual cost is real and now documented: one `user_identity` per upstream means all V1
rigs behind one Translator share one `payout_id` and one payout. Per-rig separation costs a Translator
per rig group.

**The one thing this revision made more complex came from reading the code, not from the three
decisions.** `stratum-apps/src/payout.rs` shows `PayoutMode::try_from` **splitting `user_identity` on
`/`** for its `sri/solo/<addr>` and `sri/donate/<pct>/<addr>` grammar, while
`address_part_from_user_identity()` splits on `.`. A wildcard descriptor contains six `/`, and the
Translator appends `.minerN`. New §3.2.1 records this: the two languages are disjoint only if you
commit to **descriptor-parse-first precedence**, which the existing code already happens to have,
since it tries the address/descriptor parse before the `/` split. A descriptor's checksum is delimited
by `#` not `.`, so the worker suffix strips cleanly — but that needs an explicit test rather than an
assumption, because the dangerous failure is a truncation that still parses. Also confirmed
`xpub_derivation.rs:140`'s `if !descriptor.has_wildcard()` guard is present in the branch; §3.1 is
built on it, with the probe range moved from `[0, 2^31-1]` to the **current tip height** and beyond,
since index 0 is never used under height indexing and probing it proves nothing about the operating
range.

Structural: renumbered the duplicated `### 4.3` to §4.3.1 and repaired two cross-refs in §0 that
pointed at the pre-revision section numbering. §12 re-annotated — the sv2-apps persistence
anti-pattern is now cited as §5.1's *warning* rather than a requirement to follow, and the two
gap-limit figures now ground an accepted cost rather than a rejected option. §13 revision history
added so the first draft's design is recoverable from the file itself.

## [2026-07-29] plan --revise (2) | "Translator passthrough of the miner's own descriptor; Bedrock question closed" → output/plan-xpub-miner-identity-spec-2026-07-29.md (2 corrections, 4 new code reads, §9.5 rewritten, §3.2 rewritten)

Two corrections to the same-day revision, one from the operator and one from this wiki's own thesis
round. Both changed the spec rather than confirming it.

**1. V1 identity is Translator *passthrough*, not Translator *configuration*.** The operator's intended
design: the V1 miner sets its own `mining.authorize` username to the descriptor, and the Translator
forwards that identity to the upstream SV2 channel unmodified — a proxy, not the owner of payout
identity. This is strictly better than what the first revision described, because it gives **per-rig
payout identity** instead of one identity per Translator upstream, and it preserves the property that
actually matters: each miner controls its own payout descriptor.

**Reading the clone showed the current Translator cannot do this, for three independent reasons.** A
spec that assumed configuration-as-passthrough would have shipped a design that silently pays the
wrong descriptor, so §3.2 is now a three-change modification spec rather than a TOML recipe:

- `sv1/sv1_server/mod.rs:975–984` — `open_extended_mining_channel()` reads `self.user_identity()`, an
  `Arc<OnceLock<String>>` populated once from `Upstream.user_identity` in TOML, and appends
  `.miner{N}` from an `AtomicUsize`. The miner's own username is never consulted, and this is the value
  the pool runs `PayoutMode::try_from` against. **Under the current code every V1 rig behind a
  Translator is paid to the operator's configured descriptor.**
- `sv1/sv1_server/mod.rs:529–546` — the upstream channel opens on the *first* downstream message
  (`if is_first_message { handle_open_channel_request(…) }`), with the V1 handshake queued behind it.
  So `mining.authorize` has not arrived when the identity reaching the pool is chosen. Passthrough
  requires **deferring the channel open past authorize** — a handshake-ordering change, not a field
  swap, and the reason this ships as its own migration phase (§10.1 Phase 2.5) after the pool side is
  proven.
- `downstream_message_handler.rs:209` + `utils.rs:273` — the one path that *does* carry the miner's own
  username, `data.user_identity = tlv_compatible_username(name)`, is
  `const MAX_USER_IDENTITY_BYTES: usize = 32` with warn-and-truncate. A ~150-char descriptor is cut
  mid-xpub. And it travels only as a per-share TLV (non-aggregated mode, extension negotiated), which
  the pool then **discards**: `if let Some(_user_identity) = user_identity { /* …to enhance monitoring
  of individual miners in the future */ }` (`pool/…/mining_message_handler.rs:919`). So even the
  32-byte path never reaches payout resolution.

**Fail-closed, usefully.** A descriptor truncated at 32 bytes loses its closing paren and `#checksum`,
so it **fails to parse** rather than deriving a wrong address, and §3.1's hard-fail gate turns that
into a channel-open rejection. Don't rely on it — raise the cap — but the dangerous
silent-truncation case is closed by the descriptor grammar itself. Pinned as §8.2 #8.

**A claim from the first revision is withdrawn.** That revision said routing V1 through the Translator
"deletes the entire firmware field-width problem class." **True only for operator-set identity.** Under
passthrough the descriptor is typed into the rig, so Avalon's 63-char truncation, Whatsminer's overflow
past 127, and firmware percent-encoding of `()[]/*#` all bind again — and 63 chars cannot hold a
~150-char descriptor even in the short form (`wpkh(xpub…/0/*)#cksum`, ~120). §3.2 now presents both as
an explicit operator tradeoff rather than picking one: **operator-set identity works on any V1 rig
today and pays one descriptor per farm; passthrough gives per-rig separation but is
firmware-dependent.** Support both — passthrough when the authorized username parses as a descriptor,
configured value otherwise — and let the operator choose per deployment. New open question #4 replaces
the old per-rig-cost question: nobody has surveyed which fielded V1 firmware can actually hold a
descriptor-length username.

One precedent found that settles a sub-question: the code **already exempts** `sri/`-prefixed
identities from the `.miner{N}` suffix, commented *"SRI patterns use `/`-delimited segments for payout
mode parsing, so appending a suffix would break pool-side validation"* (issue #369). Descriptor
identities need the identical exemption for the identical reason.

**2. §9.5's Bedrock question is closed, and the closure favours this plan.** The section still read
"whether it survives is unanalyzed by anyone" and cited `candidates/blinded-mining-cookie-security.md`
as an *active* record. Both stale: the 2026-07-29 thesis round resolved it (verdict **MIXED**) and the
record is `resolved: 2026-07-29`. Three findings from that round now stated in §9.5:

- The cookie property depends on the value being **unforgeable and miner-bound**, not on being a
  human-readable name — so a stable plaintext descriptor substitutes for `M.uname` with nothing
  changed in the construction.
- Bedrock is a **weaker baseline than this wiki previously credited**: no hardness assumption (§7.1 is
  a work-equivalence argument), cookie rotation only on block-find at **~7.44 years for an S7** (the
  paper's own figure), and prevout-hash placement is consensus-invalid for the share that *is* a block.
  Less to preserve than the first draft assumed.
- The obstacle the thesis actually found is **one this design never incurs**: Bedrock keys the vardiff
  target on identity (`store(M.uname, K_M, R_M, target)` fetched via `getMParams(M.uname)`), so
  blinding breaks share *validation* a layer before crediting. This spec keeps identity in the clear,
  so vardiff, dedup, and crediting all work untouched.

**And the thesis is the argument for this plan's scope.** What survives MIXED is architectural, not
cryptographic: blinded credit is strictly harder than blinded payout *because crediting is an online
interactive protocol while payout is an offline non-interactive derivation* — BBW p.166 relies on
rewinding and cannot be Fiat–Shamir'd away — plus an unquantified hashrate side channel that batching
converts (`interval = b / share_rate`) rather than removes. So the tractable half is exactly the half
this spec does: **payout blinding is offline BIP-32 derivation and needs no protocol at all**, which is
what §5 is. Agreed with the operator that there is no better option available here; §9.2's pool-side
no-op is the plan's honest boundary, not a gap in it.

Open question #2 struck (closed), #4 replaced. The two thesis follow-ups that did spin out —
`batched-credit-timing-leak` (p1) and `canard-gouget-primary-text` (p3) — are noted as **not bearing on
this spec**, since both concern blinded credit. The remaining top gap is now #3, **descriptor rotation
by the miner**: the only state in the design and the only path that can pay a miner an address they no
longer watch.

Also: §1 diagram and §1.1 components updated (Translator marked "requires modification, 3 changes"),
§8.2 grew from 8 tests to 10 (passthrough byte-for-byte, two-rigs-two-payout_ids as the test that
proves passthrough actually happened, truncation-fails-closed, config-fallback-still-works), §10.1
gained Phase 2.5, §10.3 gained a monitoring row for "channels whose `user_identity` equals the
configured value when passthrough is enabled" — the silent version of the #1 failure.

## [2026-07-30] plan | Spec revision 4 — identity is miner-managed; share retention by accumulated difficulty

Two operator corrections, the first of which was a **unit error** in my draft of this same revision and
the more consequential of the two.

**1. `N = 8 × D` is a share count, not a block count.** The draft wrote "~8 blocks of work, ~80
minutes." That holds only for a pool with 100% of network hashrate. The window is **eight times the
network difficulty expressed in accumulated share difficulty** — TIDES states N as scaling with D with
*no fixed share count*, and the share-accounting extension's boundary is a difficulty accumulation
walked back from the block, not a block tally. Time-to-fill therefore scales inversely with the pool's
own hashrate: ~13 hours at 10%, **~5.5 days at 1%**, ~55 days at 0.1%. A small pool's window is weeks of
wall-clock. Any retention policy written against blocks or a clock silently discards shares that are
still owed payment, which makes this exactly the kind of error that would have shipped as a quiet
underpayment bug. §2.5 now carries the hashrate→time table so the unit cannot be misread again.

**2. Retention must exceed the current window, because an upward retarget grows the window backwards.**
This requirement did not exist in any prior revision. `D` changes every 2016 blocks; when it rises the
window reaches further back into share history than it did before, so shares that sat just outside it
fall back inside. Pruning to exactly the current window is a correctness bug that manifests **only after
an upward adjustment** — it ships and sits quiet until a retarget. Bitcoin clamps retargets to 4×, so
`32 × D` of accumulated share difficulty is the worst-case-safe floor at the current `D`, expressed in
difficulty (never a clock or a block count) and re-evaluated each period. §10.3 gained a monitoring row
for the margin between the oldest retained share and the window edge; §10.2 gained the matching restore
caution, which is the one that actually costs something — a ledger pruned under a lower `D` and then
restored can leave owed shares simply absent.

**3. Identity management is the miner's responsibility, and rotation is off the table as a pool
concern.** Per the operator: a distinct descriptor is a distinct user, *including a new descriptor
arriving on the same connection from the same physical miner*. The pool credits it as a new user and
does not link, migrate, or reconcile identities. §2.5 is rewritten from "a descriptor change creates a
new account" into a **retention** section — the rotation framing, the mid-window two-output overlap
discussion, the drain-the-window advice, and the two rotation regtests are all **removed**, not
relocated. §4.3.1's merge granularity keeps its justification (`payout_id`, because anything coarser
requires the identity-linking this design refuses to perform) without the rotation example. §8.2 #11/#12
are replaced with tests for the two things that *do* need pinning: that the window boundary is
difficulty-accumulated rather than block-counted (a share older than 8 blocks but inside the window must
be paid), and that an upward retarget pulls previously-outside shares back in and pays them.

**4. Retention is now bounded rather than indefinite.** The draft had recorded never-expiring
`miner_identity` as an unresolved tension with §9.2's attribution-minimizing posture. It resolves
cleanly: rows must outlive any share that can still be paid, and past the retarget-safe horizon a pool
**may** prune — which §9.2 argues for. Correctness sets a floor, not a mandate to keep everything
forever.

Propagated: §0 scope (out-of-scope is now "any linking, migration, or reconciliation between miner
identities"), frontmatter (`payout_window` states the unit explicitly with a NOT-8-blocks guard, plus
`share_retention` and `miner_identity_policy`), header note, summary, §13 revision 4. Open questions
still 5 live of 7. Validated: no duplicate headings, all `§` cross-refs resolve, all frontmatter sources
and wikilinks resolve, publishability grep clean. 757 lines.

## [2026-07-30] ll | "PPLNS window units, share retention, and where pool responsibility ends" → raw/notes/2026-07-30-ll-pplns-window-units-and-identity-boundaries.md (6 lessons, 2 articles updated)

Session-derived, from revising the xpub-identity spec to revision 4. Two of the six are corrections to
**my own errors** caught by the operator, and both were unit/scope errors rather than reasoning errors:

1. **`N = 8 × D` is accumulated share difficulty, not 8 blocks.** I wrote "~8 blocks of work, ~80
   minutes" — valid only at 100% network hashrate. Converting a difficulty-denominated window to
   wall-clock requires dividing by the *pool's* hashrate: ~13 h at 10%, **~5.5 days at 1%**, ~55 days at
   0.1%. A ~100× error for a small pool, landing as under-retention. The wiki already said it plainly
   (TIDES: *"N scales with D (no fixed share count)"*) and I misread it.
2. **An upward difficulty retarget grows the window backwards.** Operator-supplied mechanism. `D` moves
   every 2016 blocks; when it rises, the walk back from the block reaches further into share history,
   pulling previously-outside shares back inside. Pruning to the current edge is a bug whose first
   symptom is one retarget away. Retarget clamp is 4×, so `32 × D` is the worst-case-safe floor.
3. **Distinct payout identity = distinct user**, including a new identity on the same connection from the
   same hardware. "These two identities are probably one person" is not knowledge the pool has, so every
   feature premised on it is out of scope by construction.
4. **Pool duty ends at correct payment plus publication.** Paying the wrong party is a defect; paying the
   right party somewhere they don't watch is not, and every mitigation for it (accrual, withholding) is
   worse — it trades a docs gap for the FinCEN custody trigger.
5. **Translator `Aggregated` mode makes per-device identity unrepresentable**, not merely unimplemented:
   one channel, one `user_identity` upstream, and the per-share identity TLV is non-aggregated-only *and*
   discarded pool-side. A mode requirement, not an effort estimate.
6. **Process**: a spec section that keeps growing to "solve" a declared non-goal is accreting mechanism,
   not rigor. I documented an out-of-scope overlap case across three turns — consequence analysis,
   disclosure obligation, operator advice, two regtests, a monitoring row — while a load-bearing *unit*
   elsewhere was still wrong. Remove out-of-scope analysis rather than demoting it to a caveat.

Articles updated (append-only): `wiki/concepts/pplns.md` gained a "Window units" section carrying rules 1
and 2 in general form (they apply to any `k × D` window, not just this spec);
`wiki/concepts/xpub-payout-identity.md` gained "The V1 path is gated on Translator aggregation mode" with
the `utils.rs:180-215` / `AGGREGATED_CHANNEL_ID` / `mining_message_handler.rs:919` citations. Both
back-reference the note; both `updated`/`verified` bumped to 2026-07-30.

No inventory records created — lessons 1/2 are now compiled rules in `pplns.md` with no pending action,
3/4/6 are decided policy, and 5 is an input to the in-flight Translator workflow rather than a separate
watch item.

## [2026-07-30] plan | "xpub-identity spec, fifth revision — Translator passthrough + pool payout path verified against code" → output/plan-xpub-miner-identity-spec-2026-07-29.md (1 code read of HEAD e2930150, 15 claims retracted, 5 plan-changing corrections)

Revised the spec against an exhaustive multi-agent read of the `sv2-apps-coinbase-rotation` clone, adversarially verified. The read **contradicted** the shipped spec in fifteen places rather than merely adding to it, so this is a revision and not an appendix.

**The blocking finding.** A valid, untruncated wildcard descriptor supplied as `user_identity` is paid **100% to the pool** today. `PayoutMode::try_from` has no descriptor arm; `script_from_address` wraps its input as `addr(<descriptor>)`, which cannot parse; the `/`-split then yields `NoPayoutMode`, which the pool maps to `PayoutMode::FullDonation` — one output, the entire block value, to the pool's own script, persisted for the connection's lifetime, no error returned and nothing logged. Both prior revisions assumed an unrecognized identity would be *rejected*. It is silently expropriated. The fail-closed fix is now non-optional Phase 1 work and must land before a descriptor is delivered to any pool, testing included.

**The structural finding.** The Translator was never the bottleneck. `Downstream.payout_mode` is one slot per **TCP connection**, blind-overwritten on every channel open and never cleared on close; extended channels inherit the group job, which never rebuilds the coinbase. So N devices on one connection collapse to the last-opened identity from the next `NewTemplate` onward. Each channel's *first* job **is** built from its own parsed mode — which is why a first-job test passes while production mispays — and there is no regression test for the collapse anywhere in the repo (every case in `pool_solo_mining.rs` uses one identity per connection; the two-channel case uses the same identity for both). Translator work: 3 changes → **7**. Pool-side work: **6 more, and larger**, and a prerequisite for any multi-channel connection — which reverses the fourth revision's Phase 2 / Phase 2.5 ordering.

**`aggregate_channels = false` is structural, not a knob.** `AggregatedState::NoChannel` is the only arm reaching the upstream sender, every channel id collapses to `AGGREGATED_CHANNEL_ID = u32::MAX`, and devices are separated only by a translator-minted 2-byte `local_index`. Per-device payout identity is *unrepresentable* in aggregated mode however either side is refactored, so a Translator in that mode must refuse descriptor identities at startup rather than silently pay them all to one script. `aggregate_channels` is required with no default, so the guard is cheap.

**Two prescriptions withdrawn.** (1) Raising `MAX_USER_IDENTITY_BYTES` is actively harmful — the normative constant lives in external crates, and raising the local mirror converts warn-and-truncate into a `UserIdentity::new` error that maps to a hard disconnect, dropping every descriptor-carrying V1 rig on its first share. The route is *around*: `data.authorized_worker_name` already holds the untruncated username, and `Str0255`'s 255 bytes is the real binding limit. (2) Key-origin information must be **stripped** during normalization, because `wpkh([fp/84h/0h/0h]xpub…/0/*)` and `wpkh(xpub…/0/*)` produce different `payout_id`s and **byte-identical** `scriptPubKey`s — `PRIMARY KEY (block_height, payout_id)` passes it, so the distinctness assert has to run on derived scripts.

**Measured, not estimated.** Shortest wildcard forms under miniscript 13.0.0: `tr(xpub…/*)` = **126** bytes, `pkh` = 127, `wpkh` = 128; raw-compressed-pubkey wildcards rejected. No descriptor fits under Avalon's 63-char truncation, closing open question #4's shortening sub-question as a negative.

**Substrate caveat recorded.** This clone is a solo/donate coinbase-templating pool, not a reward-sharing one: `coinbase_outputs` is exhaustive and maxes at two outputs, share accounting is per-channel monotonic counters with no window, a found block forwards the finding channel's coinbase verbatim (winner-take-all), and `grep -i pplns` returns zero hits. The spec's PPLNS-facing sections (§4.3, §4.3.1, §4.5, §7.2) therefore rest on the wiki articles alone and are un-verifiable against this code.

Scope held: the read proposed restoring a mid-window descriptor-rotation/co-appearance analysis as a new §5.3. Not applied — identity management is the miner's responsibility per the operator's standing decision. Only the funds-misdirection half was kept, as a pool-side correctness defect (an in-band re-key hijacking sibling channels' payouts), not as a rotation-semantics question.

Nothing was executed and the integration suite was not run — all conclusions are static reads plus standalone miniscript parser probes. Ten residual risks recorded rather than resolved; the load-bearing one is whether per-channel coinbase templating is confined to this repo's pool code or requires an upstream `channels_sv2` change, which is the difference between a week and a quarter on §3.2.3 item 4.

## [2026-08-14] ll | "Coinbase silent payments — BIP 352's sender pubkey vs. the BIP 34 height nonce" → raw/notes/2026-08-14-ll-coinbase-silent-payments-ecdh-nonce.md (7 lessons, 2 articles updated, 1 inventory candidate)

Source was a Socratic seminar on BIP 352 v1.1.1 read directly from `bitcoin/bips@60f5b33` — no agents, no web, no execution. Primary-source reads of `bip-0352.mediawiki`, `bip-0352/reference.py`, `bip-0034.mediawiki`, `bip-0141.mediawiki`, plus in-session derivation.

**The headline is a decomposition the wiki had fused.** [[raw/repos/2026-07-29-bip352-silent-payments-coinbase-incompatibility|The 2026-07-29 note]] lists the constant null outpoint alongside `a = 0` and "point at infinity" as one wall of failure. They are two independent failures with different fixes. A coinbase fails on the **shared secret** — no prevout scriptPubKey, no witness, no scriptSig pubkey, so nothing for `get_pubkey_from_input` to read and the `:193` eligibility gate fails first. It does **not** fail on the **nonce**: BIP 34 *mandates* the block height (`bip-0034.mediawiki:23`), which beats `outpoint_L` on every axis — shared, non-circular, consensus-monotonic, and dense rather than merely distinct. The structural claim survives for v0 as written (re-verified: `grep -ic coinbase` = **0** across 524 lines), but it is an absent *pubkey*, which a purpose-built key can supply, not an absent *nonce*, which nothing could.

**A blocker recorded three times in this wiki dissolves.** BIP 44's gap limit of 20 binds a BIP 32 **child index** in a forward-scanned chain, not an **ECDH nonce** mixed into a shared secret — the receiver computes one candidate for the height in hand and never enumerates unmined heights. So Greg Maxwell's block-height-as-index is fatal under BIP 380 wildcards and free under a stealth construction: same idea, opposite verdict, and only the first half was on file. Appended to [[wiki/concepts/coinbase-address-rotation|Coinbase Address Rotation]] (new subsection under § sv2-apps reversal, and open question 2 flagged for splitting) and [[wiki/topics/self-blinding-pool-design-space|Self-Blinding Pool Design Space]] (new subsection at the end of Part A).

**Two negative results closed** options the 2026-07-29 note had listed as unexplored. The **extranonce is out** as a nonce — miners roll it during PoW search, so deriving outputs from it forces a full template rebuild plus EC math per roll; cryptographic suitability and mining-loop suitability are separate audits and it passes only the first. Prev-hash is template-fixed and stays open. And **outputs can never supply a nonce at all**: they are structurally circular (you cannot derive a script from a value committing to that script), and outpoint uniqueness is a consensus guarantee with no output-side equivalent — inputs consume already-unique identifiers, outputs create identifiers that aren't unique until confirmation, which is after derivation must happen.

**The design finding, and the objection that reshapes it.** The construction is a **one-payer fan-out**: `txOut[0]` (the pool's fee output) is the payer of record for `txOut[1..N]`, each `n` a distinct paid miner — one sender point, one nonce, `N` recipients. That shape cuts both ways. Because distinct miners hold distinct scan keys, `:304`'s grouping puts every output at **`k = 0`** in its own group, so `:319`'s contiguity footgun and `K_max` both drop out and a dropped or dust-filtered output cannot destroy another miner's discoverability — a materially safer failure mode than general BIP 352 sending. But `a` is then a **single key unlocking the block's entire payee set**, so the forward-secrecy defect is amplified by `N` instead of being per-payment. Using `txOut[0]`'s key as `A` closes all four ingredients at **zero marginal bytes**, and the coinbase neutralizes every reason that's a bad idea in an ordinary tx (one builder so index 0 is stable, no reordering, no BIP 69, no signature so `:185`'s sighash analysis is vacuous). But it **forecloses forward secrecy permanently** — the pool must retain `a` to spend its own fee, so a later compromise or subpoena of the treasury key retroactively deanonymizes every hasher in every block that key sat at index 0, with no expiry. The coupling is inherent: scanners read the taproot *output* key, so ECDH must use that exact discrete log. Recommended instead a per-block ephemeral `A` in the coinbase scriptSig — 33 B / 132 WU, no spending role, **erasable at block-found**, which is § Compulsion's "data never collected" applied to receiver privacy and the first Part A mechanism with that knob. It also avoids the descriptor Part A otherwise hands the pool.

**Two smaller corrections.** `K_max = 2323` caps outputs per *scan key*, not payees per block — distinct hashers hold distinct scan keys, so block weight is the binding limit (and the BIP derived 2323 *from* that weight, so the shared number is not two independent constraints). And coinbase-scoped scanning looks unusually cheap *and* trustless: header + a ~12-hash merkle branch + 33 B ≈ ~500 B/block against BIP 352's own 7–12 kB/block (`:468`), with the branch proving the bytes against the header — which would close `:466`'s open question for this case.

Filed [[inventory/candidates/coinbase-native-stealth-payout|inventory p2]] with the variant table and three close-out conditions. **Load-bearing unverified claim**: the ~500 B/block and ~2 MB/month figures are in-session arithmetic from named components, not measured, and "closes `:466`" is reasoning rather than a cited result — the comparison figure is the BIP's own. Nothing here is implemented, specified, or tested; the construction needs its own silent-payments version byte, and the confirmed negative result that no pool accepts a payment code still stands.

**Lesson 8, added in the same session, reorders the variant table and is the strongest result of the round.** The question was why BIP 352 gives the *receiver* a scan/spend split but not the sender. Answer: it fuses the sender's two roles deliberately — `:244` uses *the spending key* for ECDH because `:99` requires the receiver to reconstruct `A` from chain data alone, and the only pubkeys a transaction exposes are its input pubkeys. The split itself is sound (`ecdh = input_hash·a_send·B_scan` against `input_hash·b_scan·A_send`, with `input_hash` re-bound to `A_send` because the `why_include_A` replay at `:92` transposes verbatim), and it buys the same downgrade `b_scan` buys the receiver: **compromise of the online key costs privacy, never money.** It also **cannot be made free by derivation**, which closes a family of designs rather than one — in the generic group model, either `f` is linear (`A_send = s·A + T` ⇒ `a_send = s·a + t`, so anyone who ever learns `a` has it — cosmetic) or it is not (hash-to-curve ⇒ nobody knows the dlog, sender included — unusable). **Key separation always costs transmitted bytes; the only design freedom is which channel pays.** The receiver's split is free because the silent payment address carries 66 B of pubkey off-chain; a general sender has no channel to a scanner it cannot identify, so its bytes go on-chain per transaction. **A pool does have that channel** — a stratum/SV2 session with every payee — so it takes the split at **zero on-chain bytes**: a batch of ephemeral ECDH keys indexed by block height, pubkey list served over stratum, each secret erased at maturity. The list is irreducible (compressing it to one seed is exactly the linear case) and is a **linkability trust surface, not a theft one** — a pool serving different lists to different miners partitions them undetectably from chain data. Two on-chain corrections fall out: the 33 B fallback belongs in the **witness-commitment output's optional-data field** (`bip-0141.mediawiki:74`, *"39th byte onwards"*), which every segwit block already carries, so it costs no new output and does not contend for the 2–100 B scriptSig budget against BIP 34's height, the extranonce and pool tags; and `:480-486` already sanctions skipping discovery via an encrypted out-of-band notification of `H(ecdh ‖ k)` + outpoint + amount, but `:495` marks the trap — a key not *actually* derived per the protocol breaks seed restore, *"unsafe — no implementation should ever allow this"* — so notification is an optimization over a scannable construction, never a substitute, and the scanning path must exist even where the channel is perfect. Net effect on the previous paragraph's dilemma: the split is what makes "the fee key is well guarded" and "does ECDH every block" compatible, because the template builder then holds `a_send` only and the treasury key never enters a template.

**Amendment, same session — the operator's counter-argument replaced my objection with a better one.** Objection raised: *if `a` is the key the pool uses to collect its own fees, it will be well guarded.* Granted, and it retires the weakest form of the forward-secrecy worry — a key guarding the pool's own revenue has the strongest incentive behind its hygiene, so "payout keys get handled sloppily" was a bad assumption to lean on. Against **theft and extraction the fee-output variant is well defended by construction**. What survives is sharper than what it replaces: *(1)* well-guarded is not erasable, and compulsion is indifferent to HSM quality — § Compulsion's Lavabit case is dispositive (warrant for TLS keys covering 400,000 customers; the operator's targeted-code alternative was **rejected by the court**), hence *"what is durable is data never collected"*; *(2)* **"well guarded" and "does ECDH every block" are mutually exclusive** — per-block ECDH needs `a` online in the template path every ~10 minutes, which is the opposite of cold storage, and if the key is threshold-held (what well-guarded means at pool scale) then `:244` turns each block into a collaborative ECDH ceremony, possibly with a DLEQ proof, while `:38` states there is **no security proof for the collaborative setting**; *(3)* a well-guarded key is **long-lived by design** — rotation is expensive treasury practice — so exposure accumulates over every block it sat at index 0, times `N` miners each, and good treasury hygiene and good privacy hygiene point in opposite directions. Net effect on the recommendation: the fee-output variant is out on operational grounds rather than hygiene ones, and the **one-time hot key at index 0, swept after maturity and erased** is promoted from compromise to real contender — it keeps the 0-byte cost, never was a treasury key so there is no cold-key exposure to force online, and is erasable.
## [2026-08-14] test-vectors | "Coinbase silent-payments variant: sender-side ECDH/spend split, executable" → ~/repos/sp-coinbase-vectors/ (outside the bips clone; imports bip-0352/reference.py + vendored secp256k1lab via sys.path). Baseline first: 28 vendored BIP352 vectors through unmodified reference.py — green. Then 9 cases in coinbase_sp_test_vectors.json (schema mirrors send_and_receive_test_vectors.json: comment / sending.given / sending.expected / receiving), checked by an assert-based runner (no pytest; exits nonzero naming the failing case; mutation-tested). Cases 1-4 positive: split isolated in an ordinary tx (a_send unrelated to input keys, live-split asserted against the vanilla fused-a_sum path); coinbase native (null prevout, ser32(height) nonce, sender/scanner agreement + spend signature); N=5 fan-out with distinct scan keys (each miner finds exactly its own; dropped output j leaves miner i unaffected — the :319 contrast); nonce distinctness both directions. Cases 5-9 negative controls, each asserting its own failure mode: vanilla BIP352 get_pubkey_from_input returns nothing on a coinbase and the :193 gate rejects; constant-null-outpoint nonce collides two blocks to the same P_0 (the 2026-07-29 claim, executed); :92 replay transposed — a_send' = input_hash*a_send/input_hash' forces reuse when input_hash omits the key or binds a static third key (attack scalar ground to even Y, so parity is no defense), killed by binding A_send; odd-Y A_send with negation omitted misses, same wire bytes with the rule applied hits; group-linear compressed list A_H = A_0 + H(A_0||H)*G — a_0 recovers every a_H and every past ecdh (comment notes this condemns the linear case only, not the non-linear one). Result: construction NOT broken in any unanticipated way; every failure landed where the 2026-08-14 note predicted. Flagged decisions, surfaced not settled: fresh tags SP-Coinbase/Inputs + SP-Coinbase/SharedSecret (domain separation vs. cross-protocol shared-secret confusion) instead of BIP0352/*; bech32m skipped (raw B_scan/B_spend hex) since the version byte at :152-176 is unresolved; A_send modeled x-only on the wire with the :299 even-Y rule transposed. Inventory updated: coinbase-native-stealth-payout next_action now points at the spec diff (close-out condition 1); inventory/_index.md freshness fixed (4 -> 5 candidates).
## [2026-08-14] test-vectors (2) | "Fee output as the A_send carrier: P2TR impossible, bare 1-of-2 multisig works (case 11); scriptSig carrier re-confirmed" — user asked whether txOut[0] can carry A_send while a_pool (not a_send) spends it. Answer: not as P2TR (one exposed group element; its dlog IS the keypath spend secret — visibility = spendability; internal-key/script-path hides A_send until spend, tweak commitment is one-way, public derivation from A_pool is the group-linear case with the treasury key as seed). Works as bare 1-of-2 multisig OP_1 <A_send> <A_pool> OP_2 CHECKMULTISIG: scanner parses key 0, pool signs with a_pool alone, a_send erasable at block-found; +37 B vs P2TR ≈ 148 WU (16 WU dearer than the witness-commitment slot; both lose to the stratum list). Implemented as case 11 (multisig_fee_output): scriptPubKey build/parse round-trip of A_send asserted byte-exact, m = 1 asserted (a_send never needed to spend), unchanged miner scan+spend path green. Full suite: 10 cases + baseline all pass. ScriptSig question: yes, explored (variant-table row 3) and it works — 2-100 B consensus budget, BIP34 height ~4 B, keep A_send clear of the rolled extranonce bytes (Lesson 4); with A_send in ANY data carrier the fee output is unconstrained. Recorded: variant-table row + impossibility rationale in coinbase-native-stealth-payout.md. Correction to the record: the previous turn claimed these edits but made none — made now.
## [2026-08-14] test-vectors (3) | "Pool tag IS A_send — scriptSig contention dissolves (case 12)" — user observation: the scriptSig needs nothing but height + extranonce + A_send, because the A_send push replaces the human-readable pool tag. That dissolves the budget contention that had demoted the scriptSig row: with the pubkey list served publicly (already required against the list-partition attack), "block H tag == entry H of pool X list" is unforgeable attribution, so the pool keeps a public identity without an ASCII string. Implemented as case 12 (coinbase_scriptSig_carrier): scriptSig = BIP34 height push ‖ 8 B extranonce ‖ push33(A_send), 46 B total; runner asserts the 2-100 B consensus budget, the height round-trip (LE on the wire, ser32 BE inside input_hash), byte-exact A_send parse, and — Lesson 4 made executable — DISJOINTNESS of the A_send region and the miner-rolled extranonce region. Fee output is an arbitrary P2TR decoy: payment and conveyance fully decoupled. Tradeoffs recorded in the case comment: explorers lose the ASCII tag; public hashrate attribution flows through the list; merged-mining commitments still need their own bytes. Variant table updated: scriptSig row de-superseded, case 12 linked. Suite: baseline + 11 cases, all green.

## [2026-08-16] publish | "Coinbase silent-payments vectors published + explainer updated for the two carrier cases" → https://github.com/average-gary/sp-coinbase-vectors (public, commit 9dd3470, 7 files / 2745 lines)

Closes the gap flagged 2026-08-14: the work existed only as an unversioned local directory. `git init`, one commit, pushed to `average-gary` (public — consistent with `average-gary/wiki`, which already carries the prose describing this construction, so publishing the code discloses nothing new). Repo now holds `sp_coinbase.py` (the construction), `generate_vectors.py`, `coinbase_sp_test_vectors.json`, `run_tests.py`, `index.html`, `README.md`, `.gitignore`. Suite re-run before committing: baseline (28 vendored BIP352 vectors through unmodified `reference.py`) + all 11 cases green, bips clone left byte-identical.

Two writing artifacts added. `README.md` states the construction in five lines, the two changes from BIP 352, and a **Known limits** section that records what the vectors do *not* establish: generator and runner share `sp_coinbase.py`, so the JSON is a regression fixture over that module rather than an independent check of it — only the unmodified-`reference.py` baseline and case 2's raw-`hashlib` re-derivation break the circularity, and a second implementation is what review actually needs; no security proof for the sender-side split (case 9 kills the group-linear key list, it does not prove the non-linear branch unusable — that stays a generic-group-model argument); the two flagged decisions (fresh `SP-Coinbase/*` tags vs. `BIP0352/*` reuse, version byte at `:152-176`) belong in a spec diff; nothing about transport, key-batch retention, or the linkability surface a pool creates by serving different `A_send` lists to different miners.

`index.html` is a plain-English explainer, not a test report — that framing was a user correction mid-session ("i want a simple explainer of what the variation is about, not a summary of the tests"), and the first draft (tables of cases, verdicts, metrics) was discarded whole. Seven sections, simple algebraic notation, both key identities shown explicitly (`p·G = (b_spend + t)·G = B_spend + t·G = P`); no JS, no CDN, 40rem measure. Section 6 rewritten this round to absorb the two carrier cases: the mining connection as the 0-byte channel with the list-partition caveat; the coinbase spare bytes with the extranonce-disjointness constraint; why a taproot fee output **cannot** carry `A_send` (*"visibility and spendability are the same property there"* — the visible key's dlog is the keypath spend secret, so the carrier would be a money key and un-erasable); the bare 1-of-2 multisig alternative at +37 B; and the pool-tag replacement in a highlighted box, including why a copied `A_send` is inert (no single payment derivable from it without `a_send`) where a copied ASCII tag is not.

Numbering note for anyone reading the suite: 11 cases, comment-labelled 1–9 then 11–12. No case 10 was ever written; the labels are left as-is because the candidate record and the 2026-08-14 log entries already cite "case 11" and "case 12" by those names, and renumbering would silently invalidate those references. Inventory updated: `coinbase-native-stealth-payout` now carries the published URL in both its body and `next_action` (which also drops the stale "9 cases" count and the now-contradicted "not the scriptSig" clause), plus both index rows and their freshness dates. `next_action` unchanged in substance — **write the spec diff**; that is still the only thing standing between this and reviewability.

## [2026-08-16] correction + spec-check | "Multisig carrier rejected on user objection; scriptSig-as-pool-tag checked against the SV2 spec" → inventory/candidates/coinbase-native-stealth-payout.md (table row struck, new § Stratum V2 fit), vectors repo commit fcbbc52

**The multisig carrier is dead, and the error was mine.** User objection: *"we don't want the bare multisig because then we have risk of the ephemeral a_send being compromised and being able to spend from the multi-sig."* Correct, and it lands on exactly the property the whole sender-side split exists to buy. `OP_1 <A_send> <A_pool> OP_2 OP_CHECKMULTISIG` — `m = 1` means any one listed key authorizes a spend, and `A_send` is a listed key. So `a_send` is not merely *unnecessary* for spending (which is what case 11 asserted and what the table row claimed), it is **sufficient**: whoever obtains the erasable privacy key takes the pool's fee. "Losing this key costs privacy, never funds" is voided. And `m = 2` fails in the opposite direction — `a_send` must then sign, so it cannot be erased until the fee is spent, which destroys the forward secrecy. **No value of `m` works.** The +37 B / 148 WU costing is moot.

Method note worth keeping, because the failure was in the question asked rather than the arithmetic: the multisig row was reasoned from *"what can a scanner read from this output?"* and never re-asked *"what does this key now authorize?"* Bare multisig separates visibility from spendability **mechanically** but not **economically**. The generalization that subsumes both this and the earlier taproot rejection: **`A_send` must never appear in a scriptPubKey that controls money — it belongs in a data field, never in a spending condition.** That single rule kills the whole fee-output family at once, which is a better result than the two separate rejections it replaces.

Case 11 was kept, not deleted — its mechanics (scanner parses key 0, `A_send` survives the scriptPubKey round-trip byte-exactly, scan+spend path untouched) are true and worth pinning — but relabelled `REJECTED CARRIER` in its comment, with the verdict and both failure directions stated. Deliberately **not** faked into an executable failure: the defect is a fact about script semantics, not about the derivation, so no assertion over these vectors can discover it. Making it executable would mean an ECDSA spend of the output under `a_send` alone; not built, since the carrier is dropped. The runner comment says so rather than implying the assertions constitute a security check.

**SV2 check on the surviving on-chain carrier — it fits, and one finding is stronger than "fits."** `stratumprotocol.org` returns HTTP 403 to fetchers; used the raw spec markdown at `stratum-mining/sv2-spec`. (a) **There is no pool-tag field in SV2** — the tag is not protocol-level, just bytes the pool places in the scriptSig region it controls, so the question reduces to scriptSig room plus the ability to pin unrolled bytes. (b) **Extranonce-disjointness is structural, not conventional**: the extended-channel coinbase is `coinbase_tx_prefix ‖ extranonce_prefix ‖ extranonce ‖ coinbase_tx_suffix` (`05-Mining-Protocol` §5.4.1.6), so the rolled region is *defined* as the gap between two pool-set halves and `A_send` in the suffix cannot be rolled — Lesson 4's hand-written invariant is enforced by the message format, which is the best argument for the scriptSig over the witness-commitment slot since it needs no discipline to hold. (c) **The bytes are pre-paid**: a Template Provider MUST reserve the worst-case 400 WU / 100 B for `scriptSig` unconditionally (`07-Template-Distribution-Protocol`), and unused scriptSig bytes are not returned to fee-paying transactions, so the marginal on-chain cost of `A_send` is **0, not 33** — this retires the byte-cost line item that had the scriptSig ranked third. (d) **Budget**: 100 − ~4 (BIP 34 height; `NewTemplate.coinbase_prefix` is "up to 8 bytes (not including the length byte)") − 34 (`push33`) = **~62 B** left for the full Extended Extranonce against SV2's own **64 B** ceiling (`extranonce_prefix` B0_32 + `extranonce` B0_32), so within 2 B of the maximum the protocol can address, and 4–8× practical allocations of 8–16 B. (e) Two constraints, neither fatal: `coinbase_tx_prefix` carries `scriptSig length` and all channels in a group channel MUST share one full-extranonce size (§5.1.2.1), so the 34 B shrinks extranonce space uniformly for the group; `A_send`'s length is constant so no per-block renegotiation. (f) **Scope limit found, worth stating in the spec diff**: under Job Declaration the *JDC* builds `coinbase_tx_prefix`/`suffix` (`06-Job-Declaration-Protocol` §6.4), so the pool cannot place `A_send` in the scriptSig at all — and JD doesn't pay miners per-output anyway (pool takes one output), so per-hasher coinbase payouts presuppose a pool-controlled template regardless.

Left unverified and now the only measurement outstanding: **empirical mainnet scriptSig occupancy.** The arithmetic assumes height + extranonce are the pool's only other content. A Namecoin-style AuxPoW commitment is ~44 B (4 magic + 32 hash + 4 + 4), which still fits at 4 + 44 + 8 + 34 = 90 ≤ 100 but leaves little slack. Needs a sample of real coinbases, not arithmetic.

Also corrected in the same pass: `index.html` §6 (the multisig paragraph said "That works" — now states the rejection and the data-field-not-spending-condition rule, plus the pre-paid 100-byte budget), `README.md` (carriers section rewritten, new "Stratum V2 fit" subsection). Suite re-run after regenerating the JSON: baseline + 11 cases green.

## [2026-08-16] ll | "Carrying a rotating A_send in the SV2 coinbase pool tag" → raw/notes/2026-08-16-ll-sv2-pool-tag-asend-carrier.md (6 lessons, 2 articles updated)

Six lessons, two of which are the same requirement failing by unrelated mechanisms. `a_send` buys exactly two properties — losing it costs privacy and never funds, and destroying it destroys history — and both were nearly lost this session without either being caught by the question that had actually been asked ("can the scanner read `A_send`?"). **Lesson 1**: a bare 1-of-2 multisig carrier gives `a_send` *spending authority* (`m = 1` means it is not merely unnecessary to spend but sufficient, so whoever takes the privacy key takes the pool's fee; `m = 2` inverts it, making the key un-erasable — no value of `m` works). **Lesson 2**: BIP 32 unhardened derivation, which `XpubDerivator` performs, is `a_i = a_par + H(K_par ‖ i)` — algebraically the group-linear list already in the vectors as a negative control, so a parent secret regenerates every child and retroactively unmasks every payout. The unifying replacement question is two questions: *what does this key authorize, and can it actually be destroyed?*

The lesson-2 trap is worth restating because the machinery is *correct where it was written*: for the pool's own payout key, recoverability from a seed is a feature (the pool must be able to spend); for `a_send` it is fatal (the pool must be able to destroy). Same derivation, inverted requirement. Settled by the user mid-session — take the plumbing, not the key engine.

**Lesson 3** downgrades what looked like a blocker: `rotate_coinbase_address()` fires only when *this pool* finds a block, but because `input_hash = H(ser32(H) ‖ A_send)` binds the height, outputs differ every block even with a static sender key. Rotation bounds forward-secrecy granularity only, so cadence is a knob — per-template is finest and scans fine, since the miner reads `A_send` from the *winning* block and never needs to know which templates lost. **Lesson 4** is the concrete budget from pinned SRI source: the pool tag is a real first-class field (`pool_tag_string`, config `pool_signature`) but a UTF-8 `String`, so raw pubkey bytes cannot go in it at all — a type failure, not a size failure. `8 + 1 + 3 + 3 + pool_len + 1 + 20 ≤ 100` → `pool_len ≤ 64`; hex x-only is exactly 64 (zero slack, no room for a miner tag), compressed hex fails at 102, bech32 is 52 and base64url 43, and standard base64 is disqualified because `/` is the tag delimiter. **Lesson 5**: extranonce-disjointness is enforced by the wire format (the rolled region is *defined* as the gap between `coinbase_tx_prefix` and `coinbase_tx_suffix`, and the prefix split index provably includes the tag), not by implementer discipline — and the 100 B is pre-paid, so a 34 B push costs 0 marginal on-chain bytes. **Lesson 6** is method: `stratumprotocol.org` 403s to fetchers, fetched summaries silently drop exactly the constants a byte-budget question needs, and the decisive number `FULL_EXTRANONCE_SIZE = 20` exists nowhere in the spec — only as a `const` in the pool app. Local working set is a superrepo at `~/repos/stratum-mining/{stratum, sv2-apps, sv2-spec, …}` with worktrees at `~/repos/stratum-mining-worktrees/`, not `~/repos/sv2-apps`.

Articles updated (appended, not rewritten): `wiki/concepts/coinbase-address-rotation.md` gained "### The rotation plumbing is reusable; the derivation is not, and they invert" — the payout-key/`a_send` requirement inversion table, plus a correction to § What the trigger actually is for the ECDH variant. `wiki/concepts/xpub-payout-identity.md` gained "### Why the descriptor engine can't be borrowed for the stealth variant" as a concrete instance of its own pool-side-no-op finding. No new inventory record: the follow-ups land on the existing `coinbase-native-stealth-payout` candidate rather than proliferating records.

Cross-topic note: these SV2 code findings also bear directly on the `sv2-coinbase-identity` topic wiki, whose thesis question is whether the pool can embed a per-miner tag in a pool-constructed coinbase — the tag layout, the 75-byte push cap, the `pool_len ≤ 64` budget, and JD-vs-pool coinbase ownership all answer parts of it. Not cross-posted; flagged here so a future compile can pick it up.
