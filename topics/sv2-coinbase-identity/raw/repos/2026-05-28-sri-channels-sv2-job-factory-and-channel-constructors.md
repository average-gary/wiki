---
title: "SRI sv2-channels — JobFactory and channel constructors (Pool vs JDC)"
source_url: https://github.com/stratum-mining/stratum/tree/main/sv2/channels-sv2/src/server
source_type: code
ingested: 2026-05-28
credibility: high
confidence: high
tags: [SRI, stratum-v2, JobFactory, miner_tag, pool_tag, scriptSig, coinbase, ExtendedChannel, StandardChannel]
local_paths:
  - /Users/garykrause/repos/stratum/sv2/channels-sv2/src/server/extended.rs
  - /Users/garykrause/repos/stratum/sv2/channels-sv2/src/server/standard.rs
  - /Users/garykrause/repos/stratum/sv2/channels-sv2/src/server/jobs/factory.rs
---

# SRI Reference Implementation — coinbase tag plumbing

## Why this matters
This is the **decisive** piece of evidence for the thesis. The SRI reference implementation already has a `miner_tag` slot in the coinbase scriptSig and the byte budget reserves space for it — the Pool constructor simply hard-codes the slot to `None`. Wiring `user_identity` (or any function of it) into that slot is a one-line change that exercises an already-existing code path.

## Key findings

### 1. Extended channel constructors split Pool vs JDC paths
`ExtendedChannel::new_for_pool` (extended.rs:127-154):
> "For non-JD jobs, `pool_tag_string` is added to the coinbase scriptSig in between `/` and `//` delimiters: `/pool_tag_string//`"

→ Calls private `new(...)` with `miner_tag = None`.

`ExtendedChannel::new_for_job_declaration_client` (extended.rs:167-195):
> "The `pool_tag_string` and `miner_tag_string` are added to the coinbase scriptSig in between `/` delimiters: `/pool_tag_string/miner_tag_string/`"

→ Calls private `new(...)` with `miner_tag = Some(miner_tag_string)`.

The same pattern exists for `StandardChannel::new_for_pool` (standard.rs:122-145) and `StandardChannel::new_for_job_declaration_client` (standard.rs:158-182).

### 2. The size budget is symmetric — `miner_tag` bytes are pre-reserved
extended.rs:232-243 and standard.rs:217-227:
```rust
let script_sig_size = 5 + // BIP34
    1 + // OP_PUSHBYTES
    3 + // `/` delimiters
    pool_tag.as_ref().map_or(0, |s| s.len()) +
    miner_tag.as_ref().map_or(0, |s| s.len()) +
    1 + // OP_PUSHBYTES
    extranonce_prefix.len() +
    rollable_extranonce_size as usize;

if script_sig_size > 100 {
    return Err(ExtendedChannelError::ScriptSigSizeTooLarge);
}
```
The 100-byte Bitcoin consensus limit on coinbase scriptSig is enforced; `miner_tag` is part of the budget *whether or not it is set*.

### 3. The actual scriptSig assembly (factory.rs)
`JobFactory::op_pushbytes_pool_miner_tag()` (factory.rs:101-128) emits:
```
[OP_PUSHBYTES_n] / [pool_tag_string] / [miner_tag_string] /
```
Note: even when both are `None`, the delimiters `///` are still emitted. So a non-JD pool's coinbase scriptSig today contains `/pool_tag//` (empty miner slot).

`JobFactory::coinbase()` (factory.rs:596-602) layout:
```
script_sig =
   template.coinbase_prefix          // BIP34 height (~5 bytes, from TP)
 + op_pushbytes_pool_miner_tag       // / pool_tag / miner_tag /
 + OP_PUSHBYTES_X                    // for the full extranonce
 + zeros[full_extranonce_size]       // placeholder; split point
```

`coinbase_tx_prefix` ends just after the OP_PUSHBYTES for extranonce; `coinbase_tx_suffix` is everything after the extranonce zeros (factory.rs:621+).

### 4. `user_identity` storage
Both `StandardChannel` and `ExtendedChannel` store `user_identity: String` and expose a `get_user_identity()` getter (extended.rs:270, standard.rs:253). It is **not** passed into `JobFactory::new(version_rolling_allowed, pool_tag, miner_tag)`. The seam is unambiguous.

### 5. Per-channel job emission
extended.rs:472 — `on_new_template` calls `self.job_factory.new_extended_job(self.channel_id, ..., self.extranonce_prefix.as_bytes().to_vec(), template, coinbase_reward_outputs, self.get_full_extranonce_size())`. Each extended channel has its own `JobFactory` instance and emits jobs with its own coinbase prefix/suffix derived from its own `extranonce_prefix`.

The alternate `on_group_channel_job` path (extended.rs:530) is **opt-in** and only used when the Pool elects the broadcast group form — confirming per-channel emission is the default.

## Reading on the thesis
The thesis is **mechanically supported** by the SRI implementation:
1. The `miner_tag` slot exists in the data model.
2. The byte budget reserves space for it.
3. The scriptSig layout already serializes the slot (with empty contents in non-JD mode today).
4. `JobFactory::new(...)` accepts the parameter; `new_for_pool` simply chooses to pass `None`.

A Pool implementation wishing to embed a function of `user_identity` (truncated/hashed to fit the budget after subtracting BIP-34 + delimiters + extranonce ≤ 61 bytes per `op_pushbytes_pool_miner_tag` length check) into per-miner coinbase scriptSigs needs only to change `new_for_pool` to take a `miner_tag` derived from `user_identity` and pass it into `JobFactory::new`. Nothing in the spec or implementation prevents this.

## Caveat (anti-confirmation)
This is a non-JD, **Pool-side** tag. The miner has no cryptographic guarantee the Pool will actually include the tag, and other miners cannot verify the tag's binding to a particular `user_identity` without trusting the Pool. It is a *trusting* attribution, not a *signature* in the cryptographic sense — which the user already accepted as the charitable reading.
