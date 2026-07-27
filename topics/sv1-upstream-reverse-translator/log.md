# Log — sv1-upstream-reverse-translator

## [2026-05-28] init | topic wiki created (research session starting)

## [2026-05-28] research | "Stratum v1 upstream of Stratum v2 — A reverse-translator" → 28 sources ingested, 6 articles compiled (5 paths × 8 sub-agents = 40 parallel agents in --plan + --deep mode)

- Path 1 (primitive mapping): 8 sources — SV1 spec, BIP-310/320, SV2 spec, AsicBoost, pdiff/bdiff, SRI stratum-translation crate.
- Path 2 (prior art): 7 sources — sv2-spec issue #102 (canonical reference), SRI translator role, hashpool, Braiins farm-proxy, p2poolv2, hydrapool, stratum-bridge altcoin pattern.
- Path 3 (feature loss): 7 sources — SV2 spec sections (JDP, security, channels, deployment scenarios, design goals), Braiins SV2 overview, SRI repo.
- Path 4 (architecture): 6 sources — stratum-translation crate, channels-sv2, handlers-sv2 bidirectional, sv1-api IsClient trait, extranonce-allocator translator pattern, workspace layout.
- Path 5 (customer segments): 6 sources — mempool.space hashrate snapshot, pool software landscape, Sjors's recruiting bio, DEMAND + dmnd-easy-sv2, Luxor, customer segments synthesis.

Compiled: 1 topic article (playbook), 5 concept articles, 1 reference table.
Cross-path connections: spec issue #102 (Path 2) ↔ Sjors recruiting bio (Path 5) ↔ section 10.4.5 blank (Path 3) → coherent "named-but-unimplemented" narrative.

## [2026-07-27] ingest | warioishere/blitzpool-rental-proxy — working bidirectional SV1<->SV2 translator (raw/repos/2026-07-27-blitzpool-rental-proxy-sv2-to-sv1-translator.md)

MATERIAL FINDING: contradicts this wiki's 2026-05-28 conclusion that the reverse translator is "greenfield from a code perspective." Repo created 2026-06-27 (a month after that research, so it did not exist to be found), crate `stratum-rental-proxy` v0.3.1, AGPL-3.0-or-later, yourdevice.ch / Blitzpool Contributors, ~80 commits, last push 2026-07-05, self-described "Beta. Deployed and running." 0 stars / 0 forks — unnoticed, not unbuilt.

- `src/proto/translate.rs` (33.9 KB) doc-comment states the split verbatim: SV1-miner<->SV2-pool conversions "are provided by `stratum_translation`"; SV2-miner<->SV1-pool is "the inverse, built here" (mining.notify -> NewExtendedMiningJob + SetNewPrevHash; set_difficulty -> SetTarget; SubmitSharesExtended -> mining.submit). Independently confirms the Path-1 finding about which leg SRI ships. Tension with the playbook's ~150 LOC estimate (not like-for-like; that file also carries bdiff math + probe logic).
- Correctness details: 32-byte LE targets, SV1 prev-hash per-word swap via the sv1_api PrevHash newtype, bdiff convention (diff 1 = 0x00000000FFFF0000...) matching rust-bitcoin Target::difficulty_float so a miner reads back exactly what the pool set, BIP320 VERSION_ROLLING_MASK 0x1fffe000, reuses stratum_core::channels_sv2::merkle_root (matches the Path-4 channels-sv2-reuse recommendation).
- Upstream switching solved two ways by cause: operator-initiated (idle-pool edit / rent start / rent end) forces a miner reconnect for a clean re-handshake ("a live re-point a miner might silently ignore would waste every share"); automatic failover re-points in place via SV1 set_extranonce+set_difficulty+notify(clean) or SV2 SetExtranoncePrefix+SetTarget ("keeps a flapping pool from storming the miner with reconnects").
- Protocol detection: downstream peeks (not consumes) the first byte on a shared port ({ / whitespace -> SV1, else SV2); upstream detection is folded into connect with UPSTREAM_PROBE_TIMEOUT 3s, native tried first and socket reused on success, translation only on failure.
- Existence proof for the hypothesized hashrate-broker segment: seller's rig mines its own default pool while Idle, reroutes server-side to the buyer when Rented{order_id}, reverts on deadline/budget; rented shares credit the BUYER, seller earns a rental fee; billing in TH-day (HASHES_PER_TH_DAY = 1e12*86400); per-rig 10-min hashrate slots with 7-day retention; orders persisted in SQLite so a rental resumes on miner reconnect; per-order same-protocol fallback pool.
- SRI consumption datapoint: SV2 is feature-gated and pulled from git not crates.io, with a documented reason — "the crates.io releases at current majors don't compile together (mining_sv2's derives reference super::binary_sv2)". stratum-core branch=main features=[translation]; stratum-apps rev 27985c63.
- Features-lost datapoint: UpstreamTarget.authority_pubkey is SV2-only (base58 Noise authority key, verified at handshake; None = "encrypted but unauthenticated"), ignored by the SV1 adapter — with an SV1 upstream there is no authority key to verify at all.

Claims verified against committed source via the GitHub contents API (translate.rs, session.rs, orders.rs, detect.rs, hashrate.rs, Cargo.toml), not from the README alone — hence confidence high on existence, though translator CORRECTNESS is unverified (no test run, no interop check, author says "expect rough edges"). Five follow-ups recorded in the source file: revise the issue-102 greenfield claim, reconcile the LOC estimate, absorb the reconnect-vs-in-place split into architecture-and-state-machine, add the authority-key point to features-lost, and consider citing this AGPL implementation when contributing inverse helpers upstream.

## [2026-07-27] compile | 1 source → 1 new article, 7 updated (prior-art-blitzpool-rental-proxy; sv2-spec-issue-102-the-canonical-reference, architecture-and-state-machine, sv2-features-lost-with-sv1-upstream, customer-segments-and-tam, sv2-sv1-primitive-mapping, reverse-translator-playbook, sv2-sv1-message-mapping-table)

Compiled the 2026-07-27 blitzpool-rental-proxy ingest and resolved all five follow-ups it recorded. Every compiled article in the wiki was touched — the source falsified a conclusion the whole set was built on.

**New**: `wiki/concepts/prior-art-blitzpool-rental-proxy.md` (hot, confidence high). Separates what the implementation proves (feasibility, the stratum_translation directional split, channels_sv2 reuse, the broker segment, a solved switching design) from what it does not (translation correctness — unverified; the spec gap — untouched; maturity — 0 stars, 1 month old, single author, unreviewed). Records the byte-order convention, the bdiff rationale, BIP-320 mask, both detection strategies, the rental economics, and the SRI git-vs-crates.io dependency defect.

**Corrections made to existing articles:**
- `sv2-spec-issue-102`: "The work is greenfield from a code perspective" retired and replaced with a two-row gap table separating spec (still open, unchanged) from code (closed). The upstream-contribution pitch is now recorded as *stronger* post-blitzpool, and §10.4.5 as a documentation rather than design exercise.
- `architecture-and-state-machine`: ~150 LOC reframed as the cost of three signatures with a 500–1000 LOC budget for the translation layer; new § Upstream switching (cause-based reconnect-vs-in-place table with the asymmetry rationale and the `ActiveUpstream` indirection consequence); new § Upstream protocol detection; new § Build-environment caveat (crates.io majors don't compile together).
- `sv2-sv1-primitive-mapping`: new § "Unresolved: pdiff or bdiff?" — this wiki has been internally inconsistent since 2026-05-28 (tables prescribe pdiff; the playbook's prescribed `Target::from_difficulty` is bdiff-based). Recorded that the ~0.0015% spread cannot reject a valid share and matters only for difficulty readback fidelity, leaning bdiff, needing an empirical check. New § Byte order replacing the old "must verify per-pool" caveat.
- `sv2-features-lost-with-sv1-upstream`: authority-bound egress identity re-read from "lost-but-replaceable" to structurally lost — `UpstreamTarget.authority_pubkey` is SV2-only with no SV1 field to populate; also flags that `None` silently degrades SV2 upstreams to encrypted-but-unauthenticated.
- `customer-segments-and-tam`: hypothesis 3 upgraded from "unclear, leaning aspirational" to supported-at-small-scale; new § noting the realized customer is an independent operator, not Luxor/NiceHash, implying a long tail of builders rather than a few large buyers. Confidence lowered high → medium (market read partially falsified once).
- `reverse-translator-playbook`: opens with a read-the-prior-art-first callout; new build step 0 (read `translate.rs`, AGPL — cite don't paste); bdiff prescribed explicitly; LOC budget revised; hard problem #2 now points at the known design answer; build-environment note added; upstream-PR step now cites blitzpool as evidence of demand (follow-up 5).
- `sv2-sv1-message-mapping-table`: difficulty and prev_hash rows corrected; `SetExtranoncePrefix` row now distinguishes failover from operator-initiated switching.

**Step 0 placement pre-check**: all 35 raw files were already in canonical directories (no moves). Normalized 7 singular `type:` values to C2's plural enum (`article`→`articles`, `paper`×5→`papers`, `repo`→`repos`) and backfilled full frontmatter on 6 `path4-*` repo sources that predated the frontmatter convention entirely (they carried `**Source type**:` in the body). C13's alias tables are empty by design, so these were applied as direct normalizations rather than table-driven rewrites.

**Volatility**: 3 hot (prior-art, customer-segments-and-tam, playbook), 5 warm, 0 cold.

**Left open**: the pdiff/bdiff question needs an empirical pool+miner readback check; blitzpool's translator correctness is unverified and this wiki should not treat it as a reference implementation until someone runs it.
