---
title: "Expected-value checks — taxonomy"
type: concept
created: 2026-07-21
updated: 2026-07-21
confidence: high
tags: [coinbase, verification, scriptPubKey, payout, op_return, bip34, merkle-root, feasibility]
---

# Expected-value checks — taxonomy

"Does the coinbase match an expected value?" is not one check — it's a family. Each
check targets a different coinbase field and has a different feasibility depending on
channel type. This table is the core decision aid for the daemon.

## The checks

| # | Check | Coinbase field needed | Standard channel (merkle root only) | Extended channel (prefix+suffix) |
|---|-------|----------------------|-------------------------------------|----------------------------------|
| a | Output pays an **expected scriptPubKey / address** | a payout `tx_out.scriptPubKey` | **No** | **Yes** — parse outputs, match SPK bytes |
| b | Output **value** = expected subsidy+fees or expected split | `tx_out.value` (8-byte LE) | **No** | **Yes** — read value, compare |
| c | scriptSig contains **expected pool sig / miner tag** | arbitrary scriptSig region | **No** | **Yes**, *if* the tag is in the visible prefix/suffix (not inside the rolled extranonce window) |
| c′ | scriptSig contains **BIP34 height** = expected | first scriptSig push | **No** | **Yes** — almost always in `coinbase_tx_prefix` |
| c″ | scriptSig contains **merged-mining tag** `0xfabe6d6d` | 44-byte MM header | **No** | **Yes**, if in visible bytes |
| d | Expected **OP_RETURN witness commitment** / custom OP_RETURN | an output scriptPubKey | **No** | **Yes** — locate OP_RETURN, match marker + 32-byte commitment |
| e | Reconstructed coinbase folds to the **expected/header merkle root** (whole-coinbase integrity) | full coinbase + `merkle_path` | **Partial** — you have the root but nothing to derive it from | **Yes** — the core self-consistency check |
| f | Witness **reserved value** present/expected | coinbase input **witness** | **No** | **No** — not in SV2 prefix/suffix (needs full witness tx) |

— [[raw/articles/2026-07-21-coinbase-structure-merkle-reconstruction-refs]],
[[raw/articles/2026-07-21-sv2-spec-mining-protocol-channels-jobs]],
[[raw/papers/2026-07-21-bip34-height-in-coinbase]],
[[raw/papers/2026-07-21-bip141-segwit-witness-commitment]]

## Bottom line

Every content-level check (a–d) and the integrity check (e) require the **raw coinbase
bytes** → an **extended channel** or a local template. On a **standard channel** the
daemon can verify *nothing* about the coinbase. Bytes the pool reserves for the miner's
own `extranonce` are not fixed and must not be treated as an expected constant. The
segwit witness reserved value (f) is outside even the extended-channel coinbase split.

For where "expected value" itself comes from (subsidy+fees, declared payout splits),
see the SV2 Template Distribution `coinbase_tx_value_remaining` and the JD first-output
rule. — [[raw/articles/2026-07-21-sv2-spec-template-distribution-protocol]],
[[raw/articles/2026-07-21-sv2-spec-job-declaration-protocol]]

## See also

- [[wiki/concepts/coinbase-transaction-anatomy]]
- [[wiki/concepts/coinbase-reconstruction-and-merkle-fold]]
- [[wiki/concepts/coinbase-verification-trust-model-limits]]
