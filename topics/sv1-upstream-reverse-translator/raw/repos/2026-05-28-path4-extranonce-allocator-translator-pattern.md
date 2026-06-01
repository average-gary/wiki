# path4 - ExtranonceAllocator (Translator pattern is documented in-source)

**Source type**: repos
**Path**: `/Users/garykrause/repos/stratum/sv2/channels-sv2/src/extranonce_manager/`
**GitHub**: https://github.com/stratum-mining/stratum/tree/main/sv2/channels-sv2/src/extranonce_manager
**Date observed**: 2026-05-28

## Why this matters

The reverse translator's hardest stateful problem is mapping the SV1 single `extranonce1` (one shared value for the whole upstream connection) into per-SV2-channel `extranonce_prefix`es so multiple SV2 downstream miners can share one upstream pool connection. This crate has a purpose-built abstraction with a translator-specific code path **already documented in-source**.

## Layout (from extranonce_manager/mod.rs docstring)

```
| upstream_prefix | local_prefix | local_index | rollable |
```

- **upstream_prefix**: bytes assigned by upstream node (= SV1 extranonce1 in reverse translator)
- **local_prefix**: caller-owned static bytes — server identifier or tag, can be empty
- **local_index**: per-channel dynamic bytes — the allocator hands these out
- **rollable**: remaining space for the downstream miner

## Two constructors

```rust
ExtranonceAllocator::new(local_prefix_bytes, total_extranonce_len, max_channels)
// For root pool — no upstream

ExtranonceAllocator::from_upstream_prefix(upstream_prefix, local_prefix_bytes, total_extranonce_len, max_channels)
// For JDC / Translator / Proxies — receives extranonce_prefix from upstream
```

The docstring (lines 91-141) explicitly calls out three uses:
1. Pool (root)
2. JDC / Translator / Proxies (receives upstream prefix)
3. **Translator: pinning rollable to a downstream-chosen size** — uses `local_prefix_bytes` as slack to absorb extra upstream space.

## Reverse translator mapping

When reverse translator's upstream SV1 connection completes `mining.subscribe`:
- `extranonce1` = bytes from subscribe response (variable length, e.g. 4 bytes)
- `extranonce2_size` = e.g. 4 bytes (so SV1 miner would use total=8 bytes)
- `total_extranonce_len = extranonce1.len() + extranonce2_size` = 8

Reverse translator allocator:
```rust
let allocator = ExtranonceAllocator::from_upstream_prefix(
    extranonce1.to_vec(),     // upstream_prefix from SV1
    Vec::new(),               // local_prefix_bytes (or some slack)
    total_extranonce_len,     // 8
    max_sv2_channels,         // e.g. 256
).unwrap();
```

Per SV2 channel:
```rust
let prefix = allocator.allocate_extended(rollable_for_sv2_miner)?;
// AllocatedExtranoncePrefix - released on drop
```

## RAII model

`AllocatedExtranoncePrefix` holds a `Weak` ref to the allocator's bitmap. On drop, it atomically clears its bit. **No manual release API.** Server-side channel constructor `ExtendedChannel::new_for_pool` takes `AllocatedExtranoncePrefix` directly, so when the channel is dropped (SV2 client disconnects), the slot frees.

## Key findings

- **Q5/Q6 (extranonce mapping)**: This is THE primitive for the reverse translator's hardest mapping problem. Use `from_upstream_prefix(sv1_extranonce1, ...)`. No new code needed.

- **Bitmap memory** (from docstring): 256 channels = 32 B, 65,536 channels = 8 KB, 16M channels = 2 MB. A reverse translator with `max_channels = 256` is essentially free.

- **Hard constraint**: `total_extranonce_len <= MAX_EXTRANONCE_LEN = 32`. Because SV1's standard `extranonce1.len() + extranonce2_size` is typically 4-8 bytes, there's plenty of headroom for a `local_index` byte plus rollable space. A single byte of `local_index` supports 256 SV2 channels per SV1 pool connection.

- **Real-world constraint**: many SV1 pools advertise `extranonce2_size = 4` and `len(extranonce1) = 4`, total = 8. Subtract 1 byte for `local_index` = 7 bytes for `rollable`. That's enough rollable space for SV2 miners but tight. If pool advertises `extranonce2_size = 8`, total = 12+, plenty.

- **`SetExtranoncePrefix` from upstream**: when SV1 pool sends `mining.set_extranonce` mid-session, reverse translator must rebuild the allocator (since `upstream_prefix` changes), which means ALL existing SV2 channels need a fresh `SetExtranoncePrefix` SV2 message. Channel state survives, but extranonce_prefix mutates via `ExtendedChannel::set_extranonce_prefix` (which already exists, server/extended.rs).

## Ingest justification

`ExtranonceAllocator::from_upstream_prefix` is the intentionally-translator-shaped primitive — its very docstring describes the reverse translator's main allocation problem and shows how to size `local_prefix_bytes` to control downstream rollable size. Zero new allocation logic needs to be written.
