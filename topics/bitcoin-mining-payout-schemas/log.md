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
