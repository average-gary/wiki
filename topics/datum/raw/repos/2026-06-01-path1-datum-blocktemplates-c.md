---
title: "datum_blocktemplates.c + README — GBT, Knots-vs-Core, blockmaxsize=3985000"
source: "https://raw.githubusercontent.com/OCEAN-xyz/datum_gateway/master/src/datum_blocktemplates.c"
type: repos
tags: [datum, getblocktemplate, bitcoin-knots, bitcoin-core, blockmaxsize, blockmaxweight, segwit, ocean, c-source]
summary: "datum_blocktemplates.c calls getblocktemplate with segwit rules and reads sizelimit/weightlimit/coinbasevalue/etc. from the response — but does NOT hardcode 3985000 or detect Knots-vs-Core. The 3985000 constant lives in the README as a recommended bitcoin.conf value (blockmaxsize and blockmaxweight) reserving 15 KB for the pool's generation transaction. Knots is recommended editorially in the README; there is no runtime check."
confidence: high
ingested: 2026-06-01
ingested_by: path1
quality_score: 4
canonical_url: "https://github.com/OCEAN-xyz/datum_gateway/blob/master/src/datum_blocktemplates.c"
license: MIT
revision_branch: master
---

# datum_blocktemplates.c — block-template fetching from the local node

A 19 KB module that owns the `getblocktemplate` (GBT) RPC loop. Worth ingesting for two reasons: it is the **integration point with bitcoind** (DATUM's whole architectural advantage), and it is where this path expected to find Knots-vs-Core enforcement logic — but it isn't there.

## Where 3985000 actually lives

Surprise: `3985000` is **not** in the C source. Searching `datum_blocktemplates.c` yields no hardcoded value, no equivalent macro. The constant lives in the **README's node-config section** as a *recommendation* to operators:

```
blockmaxsize=3985000
blockmaxweight=3985000
```

The 15 KB headroom (≈4 MB - 3985000 bytes) reserves space for the pool's generation transaction — which can be larger than typical because TIDES distributes to many addresses. If the operator forgets these settings, the local node may produce a template too dense to fit a multi-output coinbase, and shares will fail validation with `DATUM_REJECT_*` codes (see `datum_protocol.h` ingest).

This means: **the gateway does NOT enforce blockmaxsize at runtime**. It trusts the operator to configure their node correctly. A misconfigured operator simply submits invalid blocks and gets rejected by the pool — the failure surfaces as silent revenue loss, not a clean error.

## getblocktemplate call

```c
snprintf(gbt_req, sizeof(gbt_req),
  "{\"method\":\"getblocktemplate\",\"params\":[{\"rules\":[\"segwit\"]}],...}");
```

Hardcoded `["segwit"]` rules — taproot is not in the rules list, which is fine (taproot doesn't require an explicit GBT rule the way segwit did) but worth noting. No mention of `signet`, `taproot`, or alternative chain rules.

## Fields read from the GBT response

| Field | Use |
|---|---|
| `height` | Block height for BIP34 coinbase encoding |
| `coinbasevalue` | Total subsidy + fees available for the coinbase |
| `mintime`, `curtime` | ntime bounds passed to miners |
| `sizelimit`, `weightlimit` | Read but **not enforced** — used for diagnostics |
| `sigoplimit` | Sigop budget for transaction selection |
| `version`, `bits`, `previousblockhash`, `target` | Standard header fields |
| `default_witness_commitment` | The OP_RETURN commitment for the segwit-mtree root, stored as 95-char hex |
| `transactions[]` | Each carries `txid`, `hash` (witness-inclusive), and serialized data |

Notable: **the gateway trusts the local node's GBT output for transaction selection.** This is the whole point of DATUM — but it also means the local node's mempool policy (Knots-style filters, RBF policy, package relay decisions) determines which transactions get into the block. Knots's "fine controls over how they wish to construct their block templates" (per README) is achieved by Knots's modified GBT, not by anything DATUM does.

## Knots-vs-Core: editorial in README, absent in code

The README is opinionated:

> "Using Bitcoin Knots is highly recommended. This gives miners fine controls over how they wish to construct their block templates. Other node implementations that support GBT can also be used. This includes Bitcoin Core, but it is severely lacking in template control options."
>
> "...this disparity represents a centralizing force which partly defeats the purpose of decentralizing block template creation in the first place."

The C source has **zero version detection, zero Knots-specific code paths, zero Core-specific code paths**. From the gateway's perspective, any node that speaks GBT is fine; the editorial preference for Knots is purely about Knots offering more `bitcoin.conf` knobs that the operator (not the gateway) configures. Examples of Knots-specific knobs Knots adds that Core lacks:

- `-blocksonly` style mempool filters tunable per-transaction
- More aggressive rejection of OP_RETURN abuse
- Custom data-carrier size limits

None of these are visible to DATUM at runtime — they shape the GBT response the gateway receives, but the gateway treats it as opaque.

## Other recommended bitcoin.conf settings (from README)

```
blocknotify=killall -USR1 datum_gateway
maxmempool=1000
blockreconstructionextratxn=1000000
```

`blocknotify` triggers the `SIGUSR1` path that re-fetches GBT immediately on tip change (see `datum_blocktemplates_notifynew()`). `blockreconstructionextratxn` increases the orphan/extra-tx pool the node holds, helping with template freshness across reorgs.

## Function catalog

| Function | Purpose |
|---|---|
| `datum_gbt_parser()` | Parses the GBT JSON response into the internal template struct |
| `datum_gateway_template_thread()` | Main loop: poll GBT periodically, push new work to stratum and DATUM clients |
| `update_stratum_job()` | Broadcasts a fresh template to all connected stratum miners |
| `datum_blocktemplates_notifynew()` | SIGUSR1 handler — immediate GBT refresh on blocknotify |

## Implications for the SV2-downstream-proxy design

1. **Knots vs Core is the operator's problem, not the proxy's.** Whatever node is configured locally is what dictates template content. A proxy can ignore this entirely.
2. **The 3985000 reservation must still be set on the local node**, regardless of whether the upstream protocol is DATUM or SV2 + Job Declaration. SV2's Job Declaration subprotocol arguably reduces the need for the constant (since the pool can re-attempt template fitting), but as long as the proxy is using DATUM upstream the operator must still configure the headroom.
3. **There's no programmatic way for DATUM to refuse a non-Knots node.** A proxy writer who wanted to enforce Knots could check `getnetworkinfo` for the user-agent — but neither DATUM nor any planned SV2-translator does this today.

## Sources

- [datum_blocktemplates.c @ master](https://github.com/OCEAN-xyz/datum_gateway/blob/master/src/datum_blocktemplates.c) — 19,815 bytes at HEAD `a3da9e69`.
- [README.md @ master](https://github.com/OCEAN-xyz/datum_gateway/blob/master/README.md) — node-configuration section, 0.4.1-beta.
