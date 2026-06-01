# path4 - channels_sv2 crate (low-level repo)

**Source type**: repos
**Path**: `/Users/garykrause/repos/stratum/sv2/channels-sv2/`
**GitHub**: https://github.com/stratum-mining/stratum/tree/main/sv2/channels-sv2
**Crate name**: `channels_sv2` v6.0.0
**Date observed**: 2026-05-28

## Crate structure

```
sv2/channels-sv2/src/
  bip141.rs                          # BIP141 SegWit strip helper
  chain_tip.rs                       # ChainTip type
  client/                            # Mining-client side state (no_std capable)
    extended.rs                      # ExtendedChannel (client perspective)
    standard.rs / group.rs
    share_accounting.rs
  server/                            # Mining-server side state
    extended.rs                      # ExtendedChannel (server perspective)
    jobs/                            # JobFactory, JobStore
    share_accounting.rs
  extranonce_manager/                # ExtranonceAllocator
    allocator.rs / prefix.rs / bitvector.rs / mod.rs
  merkle_root.rs / target.rs / outputs.rs
  vardiff/                           # Vardiff state machines
```

## Direct relevance to the reverse translator

The reverse-translator role inhabits **two abstractions simultaneously**:
1. SV2 *server* facing the SV2 mining client downstream — uses `channels_sv2::server::extended::ExtendedChannel<J>`.
2. SV1 *client* facing the SV1 pool upstream — uses `sv1_api::IsClient` (no analogous channels_sv2 abstraction).

Note: the *forward* translator-proxy (sv2-apps) does the inverse: SV1 server downstream + SV2 client upstream, and uses `channels_sv2::client::extended::ExtendedChannel`.

## Key findings

- **`server::extended::ExtendedChannel<J>` is exactly the abstraction needed for the SV2 downstream side** of the reverse translator. It already provides: `validate_share`, `on_new_template` (via JobFactory), `on_set_new_prev_hash`, `set_target`, share-batch-acknowledgement, version-rolling enforcement, and stale/past/active job tracking. It is generic over `J: JobStore<ExtendedJob>` so the reverse translator can substitute its own job store that pulls jobs from the SV1 upstream rather than from a template provider.

- **Job factory dependency is the reverse translator's hard problem**: `server::ExtendedChannel::new_for_pool` requires a `JobStore` and `JobFactory`. The factory expects template-distribution-style inputs (NewTemplate + SetNewPrevHash). The reverse translator does NOT have access to a template provider — it only has SV1 `mining.notify` messages, which give a *pre-built* coinbase (prefix + suffix + merkle path). The reverse translator therefore needs a NEW `JobStore` impl that builds `ExtendedJob` directly from SV1 notify messages, bypassing the factory.

- **Extranonce manager has explicit "Translator" use case** (extranonce_manager/mod.rs lines 91-141): docstring literally describes "JDC / Translator / Proxies (receives upstream extranonce prefix)" via `ExtranonceAllocator::from_upstream_prefix(upstream_prefix, local_prefix_bytes, total_extranonce_len, max_channels)`. For the reverse translator, `upstream_prefix = SV1 extranonce1` (received from `mining.subscribe` response), `total_extranonce_len = extranonce1.len() + extranonce2_size`, and the allocator sub-divides for per-SV2-channel prefixes.
  - Layout per docs: `upstream_prefix | local_prefix | local_index | rollable`
  - For reverse translator: `upstream_prefix = SV1 extranonce1`, `local_index = per-SV2-channel ID`, `rollable = SV2 miner's rollable space`. Total must equal `len(extranonce1) + extranonce2_size`.

- **Share validation reuses verbatim**: `client::extended::ExtendedChannel::validate_share` (lines 490-647 of client/extended.rs) does full Bitcoin-header reconstruction, merkle-root recomputation, target comparison, BIP320 version-rolling enforcement, duplicate detection, block-found detection. The reverse translator's downstream (SV2 client) shares should be validated by `server::extended::ExtendedChannel::validate_share` (mirror impl on server side). Crucially, **the reverse translator must NOT submit shares upstream that don't meet at least the SV1 pool's expected difficulty**, otherwise the upstream pool will see SubmitSharesError and may ban the connection. The local validate_share is the right place to enforce this, but the reverse translator must compute the right *job-target* — the SV1 difficulty translated into a Target via `Target::from_difficulty()` from bitcoin crate.

- **No async; pure state machines.** `channels_sv2` is `no_std` compatible (client side) and contains zero networking. This means the reverse translator binary brings its own runtime (tokio expected, matching sv2-apps convention) and uses these state machines as data structures.

- **Vardiff is reusable**: `channels_sv2::vardiff::classic::VardiffState` adjusts SV2 channel target based on observed share rate. For reverse translator, vardiff on the SV2 downstream side is fully usable — the *upstream* difficulty (from SV1 pool) acts as a ceiling; the reverse translator sets each SV2 channel's target somewhere between min_target and the SV1 pool's target.

## Specific reusable types

| Reusable type | Module | Use in reverse translator |
|---|---|---|
| `ExtranonceAllocator::from_upstream_prefix` | extranonce_manager::allocator | Sub-allocate SV1 extranonce space per SV2 channel |
| `AllocatedExtranoncePrefix` | extranonce_manager::prefix | RAII-released slot — drop = release |
| `server::extended::ExtendedChannel<J>` | server::extended | SV2 channel state per downstream miner |
| `server::share_accounting::ShareAccounting` | server::share_accounting | Per-channel share counting |
| `vardiff::classic::VardiffState` | vardiff | Per-channel difficulty adaptation |
| `bip141::try_strip_bip141` | bip141 | Strip SegWit data from SV1 coinbase before stuffing into SV2 NewExtendedMiningJob |
| `chain_tip::ChainTip` | chain_tip | Track current prev_hash/nbits/min_ntime — fed from SV1 notify, also gates share validation |
| `merkle_root::merkle_root_from_path` | merkle_root | Already used inside validate_share |
| `target::hash_rate_to_target`, `target::bytes_to_hex` | target | Channel target sizing on UpdateChannel |

## Ingest justification

The `channels_sv2` crate provides 80% of the SV2-side state machinery the reverse translator needs without modification — `server::ExtendedChannel`, `ExtranonceAllocator::from_upstream_prefix` (which the docs explicitly call out as a translator use case), share accounting, and vardiff are all reusable as-is. The only NEW component on the SV2 side is a custom `JobStore` impl that ingests SV1 `mining.notify` instead of template-distribution `NewTemplate`.
