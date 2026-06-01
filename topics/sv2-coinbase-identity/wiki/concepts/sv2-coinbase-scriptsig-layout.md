---
title: "SV2 coinbase scriptSig layout"
type: concept
created: 2026-05-28
updated: 2026-05-28
confidence: high
tags: [stratum-v2, coinbase, scriptSig, BIP-34, extranonce, pool-tag, miner-tag]
---

# SV2 coinbase scriptSig layout (Pool-finalized)

The Pool finalizes the coinbase from the [[Template Provider's NewTemplate|wiki/concepts/sv2-mining-protocol-overview]] skeleton plus its own scriptSig contribution.

## Layout (SRI reference impl)
```
script_sig =
    template.coinbase_prefix              // BIP-34 height, ~5 bytes (from TP)
  + OP_PUSHBYTES_n                        // 1 byte
  + b"/"                                  // delimiter
  + pool_tag_string (optional)
  + b"/"                                  // delimiter
  + miner_tag_string (optional)
  + b"/"                                  // delimiter
  + OP_PUSHBYTES_X                        // 1 byte
  + extranonce_prefix                     // pool-chosen, per-channel (B0_32)
  + rolling_extranonce                    // miner-rolled (extended) or filler (standard)
```

Source: `/Users/garykrause/repos/stratum/sv2/channels-sv2/src/server/jobs/factory.rs:101-128, 596-602`.

## 100-byte budget
Bitcoin consensus caps coinbase scriptSig at 100 bytes. SRI checks this at channel-construction time:
```rust
let script_sig_size = 5 + 1 + 3 + pool_tag.len() + miner_tag.len() + 1 + extranonce.len();
if script_sig_size > 100 { return Err(ScriptSigSizeTooLarge); }
```
— `extended.rs:232-243` and `standard.rs:217-227`.

After BIP-34 (5) + delimiters (3) + 2x OP_PUSHBYTES (2) + extranonce (≤32+rollable), the combined `pool_tag + miner_tag` budget is **at most ~58-61 bytes** depending on rollable size.

## What's in the slot today
- **Non-JD pool** (`new_for_pool`): `pool_tag = Some("..."), miner_tag = None` → scriptSig contains `/pool_tag//` (empty miner slot, but delimiters still emitted).
- **JD client** (`new_for_job_declaration_client`): `pool_tag = Option, miner_tag = Some("...")` → scriptSig contains `/pool_tag/miner_tag/`.

The empty-but-delimited miner slot is the seam the [[user_identity → coinbase tag thesis|theses/sv2-coinbase-identity]] points to.

## See also
- [[wiki/concepts/job-factory-and-coinbase-construction]]
- [[wiki/concepts/coinbase-ownership-pool-vs-jdc]]
- [[raw/repos/2026-05-28-sri-channels-sv2-job-factory-and-channel-constructors]]
- [[raw/articles/2026-05-28-sv2-spec-mining-protocol]]
