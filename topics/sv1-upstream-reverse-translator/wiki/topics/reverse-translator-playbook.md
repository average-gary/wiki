---
title: "Reverse-translator playbook (SV2 downstream / SV1 upstream)"
category: topic
status: active
created: 2026-05-28
updated: 2026-07-27
verified: 2026-07-27
volatility: hot
confidence: high
sources:
  - raw/repos/2026-05-28-path1-sri-stratum-translation-crate.md
  - raw/repos/2026-05-28-path2-sri-translator-role.md
  - raw/repos/2026-05-28-path4-stratum-translation-crate.md
  - raw/repos/2026-05-28-path4-channels-sv2-reuse.md
  - raw/repos/2026-05-28-path4-handlers-sv2-bidirectional.md
  - raw/repos/2026-05-28-path4-sv1-api-isclient-trait.md
  - raw/repos/2026-05-28-path4-workspace-layout-and-integration-tests.md
  - raw/papers/2026-05-28-path3-sv2-spec-discussion-deployment-scenarios.md
  - raw/articles/2026-05-28-path5-sjors-bio-recruiting.md
  - raw/data/2026-05-28-path5-mempool-space-pools-snapshot.md
  - raw/repos/2026-07-27-blitzpool-rental-proxy-sv2-to-sv1-translator.md
tags: [playbook, reverse-translator, sv2-downstream, sv1-upstream, sri, prior-art]
summary: "A practical synthesis of the four research paths that returned implementation-relevant material. This is the deliverable: read this article and you should know what the reverse translator is, why it exists, what it preserves and loses, where in the SRI codebase it goes, and who would deploy it."
---

# Reverse-translator playbook

A practical synthesis of the four research paths that returned implementation-relevant material. This is the deliverable: read this article and you should know what the reverse translator is, why it exists, what it preserves and loses, where in the SRI codebase it goes, and who would deploy it.

> **Read the prior art first (added 2026-07-27).** This playbook was written believing no SV2→SV1 translator existed. One does: `warioishere/blitzpool-rental-proxy`, AGPL, deployed, with the reverse leg hand-authored in `src/proto/translate.rs`. Study it before writing code — see [[../concepts/prior-art-blitzpool-rental-proxy]]. It does not replace this playbook (its surrounding role is a rental broker, its correctness is unverified, and AGPL blocks copying into MIT/Apache-2.0 SRI), but it settles several questions this playbook left open and corrects one of its estimates.

## What it is

A new SRI role that **inverts the existing translator-proxy direction**. The existing translator-proxy is SV1-miner ↔ SV2-pool (forward). The reverse translator is **SV2-miner ↔ SV1-pool** (reverse / down-to-up).

- Downstream (SV2): faces SV2-native miners, SV2-aware proxies, hashpool-style settlement layers, or the operator's own SV2 pool front. Speaks SV2 binary frames over Noise NX.
- Upstream (SV1): connects to the operator's chosen SV1 pool — Foundry, AntPool, F2Pool, Luxor, MARA, etc. Speaks SV1 JSON-RPC over plain TCP (or TLS-tunneled).

The role lives in a new crate at `sv2-apps/roles/reverse-translator/`, parallel to the existing `miner-apps/translator/`. **See**: [[../concepts/architecture-and-state-machine]].

## Why it exists

By hashrate, ~96%+ of Bitcoin's network hashrate is paid out by pools whose public stratum endpoint is SV1 in 2026. DEMAND is the only major SV2-native pool. An SV2 stack that cannot mine to Foundry / AntPool / F2Pool / Luxor / MARA in 2026 is a stack with effectively one production destination. The reverse translator is the bridge over the adoption-time gap. **See**: [[../concepts/customer-segments-and-tam]].

## What survives the egress

| Survives | Partially survives | Lost |
|---|---|---|
| Internal Noise NX transport | Hierarchical extranonce_prefix | Job Declaration Protocol (JDP) |
| Internal binary framing | Async share submit (egress is sync RTT) | Custom block-template selection |
| BIP-310 / BIP-320 version rolling | Multi-channel abstraction | Censorship resistance via miner templates |
| SRI codec / noise / binary crate reuse | Per-channel SetTarget (egress = single SV1 difficulty) | MEV retention via coinbase control |
| | Standard / Extended channels (collapse at egress) | Header-only mining |
| | Group channels (no SV1 broadcast primitive) | Noise NX from proxy to upstream |
| | Hashrate-hijacking prevention (internal only) | Spec-conformant V2→V1 reference |

Tally: 9 lost, 9 partially lost, 1 lost-but-replaceable (TLS+pinning DIY), 4 survive. **See**: [[../concepts/sv2-features-lost-with-sv1-upstream]].

## Honest pitch

> "SV2 *operational hygiene* with your existing pool."

Not "SV2 censorship resistance with your existing pool" — that requires upstream cooperation and is structurally lost. The honest value prop is internal-network transport encryption, hierarchical extranonce, async submit between miner and proxy, and SRI codebase reuse.

## How to translate the messages

Full mapping is in [[../concepts/sv2-sv1-primitive-mapping]]. Key transitions:

- `SetupConnection` → drives 3 SV1 RPCs (`mining.configure` / `mining.subscribe` / `mining.authorize`) before downstream setup completes.
- `OpenExtendedMiningChannel` → allocate sub-prefix from `ExtranonceAllocator::from_upstream_prefix`, return `OpenExtendedMiningChannel.Success` synthesized from the cached SV1 subscribe response.
- `mining.notify` → synthesize `NewExtendedMiningJob` (`coinbase_tx_prefix`/`coinbase_tx_suffix` from coinb1/coinb2; `merkle_path` from merkle_branch). If `clean_jobs=true`, also broadcast `SetNewPrevHash`.
- `mining.set_difficulty` → `SetTarget` (precise; `target = diff1_max / difficulty`). **Use bdiff** (`0x00000000FFFF0000…`, i.e. `rust-bitcoin`'s `Target::difficulty_float`), not pdiff — the two are ~0.0015% apart, cannot cause a rejected share, and bdiff is what makes a miner read back exactly the difficulty the pool set. This corrects the pdiff formula still shown in [[../concepts/sv2-sv1-primitive-mapping]] and [[../reference/sv2-sv1-message-mapping-table]], both of which now flag the conflict as unresolved-but-lean-bdiff.
- `SubmitSharesExtended` → `mining.submit` (strip `extranonce_prefix` bytes; lookup string job_id; map channel_id → worker_name).
- SV1 submit ack → batch into `SubmitShares.Success` or map error string → typed `SubmitShares.Error`.

## Implementation surface — what's reusable, what's new

### Reusable as-is from `stratum-mining/stratum`

- `channels_sv2::server::extended::ExtendedChannel<J>` — per-SV2-channel state with custom `JobStore`.
- `channels_sv2::extranonce_manager::ExtranonceAllocator::from_upstream_prefix` — docstring literally calls out the translator use case.
- `channels_sv2::vardiff::classic::VardiffState`, `bip141::try_strip_bip141`, `chain_tip::ChainTip`, `merkle_root::merkle_root_from_path`.
- `handlers_sv2::HandleMiningMessagesFromClientAsync` (the `FromClient` / `FromServer` trait split is already direction-symmetric).
- `sv1_api::IsClient` for the upstream-pool task (port `sv1/examples/client_and_server.rs`'s Client to tokio).
- `parsers_sv2`, `codec_sv2`, `framing_sv2`, `noise_sv2` — wire pipeline unchanged.
- `stratum_translation::build_sv2_open_extended_mining_channel` (forward helper, but reusable here).

### New pure helpers in `stratum_translation` (budget 500–1000 LOC)

- `build_sv2_new_extended_mining_job_from_sv1_notify(notify, sv2_job_id, version_rolling_allowed)`.
- `build_sv2_set_target_from_sv1_set_difficulty(set_difficulty)` (uses `Target::from_difficulty(f64)` from the bitcoin crate — **bdiff**-based; see the difficulty note below).
- `build_sv1_submit_from_sv2_submit_shares_extended(share, sv1_job_id_string, user_name, extranonce1_len)`.

**Estimate revised 2026-07-27**: this section previously said ~150 LOC. That is the cost of the three signatures, not of the translation layer — blitzpool's `translate.rs` is 33 855 bytes (~900–1100 lines), and while it also carries target math and probe logic assigned elsewhere here, 150 is a floor rather than a forecast.

### New role binary in `sv2-apps/roles/reverse-translator/` (~1500-2500 LOC)

- `impl sv1_api::IsClient` for upstream-pool tokio task.
- `impl HandleMiningMessagesFromClientAsync` for per-SV2-connection state.
- A new `JobStore<ExtendedJob>` impl that builds jobs from SV1 notify (the existing `JobFactory` expects `NewTemplate`, which the reverse translator does not have).
- HashMap ID translation: `job_id u32 ↔ string`, `channel_id ↔ sv1_user_name`.
- TOML config: upstream URL, listen addr, max channels, vardiff params, per-pool error-string mapping.

### New integration tests (~500 LOC)

- Fake SV1 pool harness using `sv1_api::IsServer` + tokio TCP listener.

**See**: [[../concepts/architecture-and-state-machine]], [[../../raw/repos/2026-05-28-path4-channels-sv2-reuse|channels_sv2 reuse]], [[../../raw/repos/2026-05-28-path4-stratum-translation-crate|stratum_translation crate]].

## Hard problems baked in

1. **BIP141 lossiness**. SV1 mining.notify gives a coinbase that lacks the SegWit witness commitment; SV2 NewExtendedMiningJob expects unstripped. Pass-through stripped form; SV2 client must accept. **Protocol-fidelity concession** for any SV2-on-SV1-pool design.
2. **Mid-session `mining.set_extranonce`**. Forces `SetExtranoncePrefix` to all SV2 channels and an allocator rebuild; in-flight shares may fail upstream during the transition. **Known design answer**: pick the strategy by cause — force a miner reconnect for operator-initiated upstream changes, re-point in place (`SetExtranoncePrefix` + `SetTarget`) for automatic failover, so a flapping pool can't storm the miner with reconnects. See [[../concepts/architecture-and-state-machine]] § Upstream switching.
3. **Per-pool error-string mapping**. Foundry, AntPool, F2Pool error wording differs; the mapping table is per-pool config.
4. **Authentication mismatch**. SV2 has Noise public-key auth; SV1 is username/password. Translator holds SV1 credentials per channel.
5. **Future-job optimization is lost**. SV1 always sends prev_hash with the notify.
6. **Covert AsicBoost is structurally precluded**. Treated as a SegWit safety property, not a regression.

## Customer segments

1. **SRI / SV2 ecosystem developers** — first user. Without this, SV2 stack development is testable only against SRI's regtest pool or DEMAND.
2. **Hashpool / Cashu mining-mint experimenters** — small, motivated.
3. **Mid-size operators on BraiinsOS+ paid out by Foundry / AntPool / F2Pool** — largest theoretical TAM; smallest active demand today.
4. **Hashrate brokers** — Luxor, NiceHash. Architectural fit; commercial pull pending.
5. **Solo / OCEAN / p2pool** — *not customers* (they want to avoid centralized pools).

**See**: [[../concepts/customer-segments-and-tam]].

## Build path of least resistance

0. **Read `blitzpool-rental-proxy`'s `src/proto/translate.rs` end to end** (added 2026-07-27). ~1000 lines that already answer byte order, difficulty convention, and version-rolling mask handling for this exact direction. AGPL — read it, cite it, do not paste it into an MIT/Apache-2.0 PR. Also worth reading: `detect.rs` (first-byte protocol detection) and the README's upstream-switching section. See [[../concepts/prior-art-blitzpool-rental-proxy]].
1. **Open a draft PR against `stratum-mining/stratum`** adding the three new pure helpers in `stratum_translation`. Cite [[../concepts/sv2-spec-issue-102-the-canonical-reference|sv2-spec issue #102]] in the PR description. Cite [[../../raw/articles/2026-05-28-path5-sjors-bio-recruiting|Sjors's recruiting bio]] for community alignment. **And cite blitzpool as evidence of demand**: an independent operator shipped these conversions out-of-tree specifically because `stratum_translation` provides only the forward leg. "Someone already paid this cost separately" is a materially stronger argument for merging inverse helpers than "someone might want this," and any further rental/self-hosting operator hitting the same wall pays it again.
2. **Open a companion draft against `stratum-mining/sv2-apps`** scaffolding `roles/reverse-translator/` from the existing `miner-apps/translator/` layout.
3. **Implement upstream `IsClient` task first** — it can be exercised against a real Foundry / AntPool endpoint in unit tests without any SV2 surface.
4. **Implement downstream `ExtendedChannel<J>` with a custom JobStore** — exercise against `sv2_test_client` from this repo.
5. **Stitch the two halves with a shared `Arc<Mutex<State>>`** + mpsc channels. Reuse the forward translator's task scaffolding.
6. **Add the fake-SV1-pool integration test** using `sv1_api::IsServer`.

**Build-environment note**: SRI's crates.io releases do not compile together at current majors (`mining_sv2`'s derives reference `super::binary_sv2`). Depend on the git workspaces, pin revs, and unify `stratum-core` with `stratum-apps`' transitive copy on the same branch. Enable `stratum-core`'s `translation` feature for `stratum_translation` + `sv1_api`.

## Spec contribution opportunity

The SV2 spec section 10.4.5 (V2→V1) is literally `...`. Filling it in — even with a brief description matching the implementation — is a high-leverage adjacent contribution and provides cover for the reference role to land.

As of 2026-07-27 this got easier, not harder: there is now a running implementation to describe, so §10.4.5 is a documentation exercise rather than a design one. The spec-side gap is entirely untouched by blitzpool's existence — #102 still open, #103 still stale, §10.4.5 still `...`.

## See also

- [[../concepts/sv2-sv1-primitive-mapping]]
- [[../concepts/sv2-features-lost-with-sv1-upstream]]
- [[../concepts/architecture-and-state-machine]]
- [[../concepts/customer-segments-and-tam]]
- [[../concepts/sv2-spec-issue-102-the-canonical-reference]]
- [[../concepts/prior-art-blitzpool-rental-proxy]] — read before building
- [[../../../stratum-sri/_index|stratum-sri wiki]] — SRI low-level repo it lives in
- [[../../../sv2-p2pool-integration/_index|sv2-p2pool-integration]] — adjacent forward-direction topic
- [[../../../iroh-transport-stratum-v2/_index|iroh-transport-stratum-v2]] — orthogonal transport concern
- [[../../../bitcoin-mining-payout-schemas/_index|bitcoin-mining-payout-schemas]] — what the upstream SV1 pool dictates
- [[../reference/sv2-sv1-message-mapping-table.md|Reference — SV2 ↔ SV1 message mapping table]]
