---
title: "datum_coinbaser.c — pool-supplied coinbase outputs and tag enforcement"
source: "https://raw.githubusercontent.com/OCEAN-xyz/datum_gateway/master/src/datum_coinbaser.c"
type: repos
tags: [datum, coinbase, generation-transaction, ocean, tides, primary-tag, unique-id, c-source]
summary: "The 35 KB C file that parses the pool's binary coinbase-outputs response (max 512 outputs, P2PKH-validated, included in order with no reordering), inserts the primary/secondary/tertiary coinbase tags and a 16-bit per-miner unique ID, and generates 6 coinbase variants (empty, nicehash, antminer, whatsminer, huge, antminer2) for compatibility with diverse hardware."
confidence: high
ingested: 2026-06-01
ingested_by: path1
quality_score: 5
canonical_url: "https://github.com/OCEAN-xyz/datum_gateway/blob/master/src/datum_coinbaser.c"
license: MIT
revision_branch: master
---

# datum_coinbaser.c — coinbase enforcement on the gateway side

The wiki concept article notes that OCEAN enforces "must include generation-transaction outputs provided by the pool, in the order provided." This file is where that enforcement is implemented on the **gateway side** — the pool just sends the binary blob, and the gateway parses and packs it verbatim into the coinbase. There is no reordering, summing, or filtering: the client cannot lie about output ordering without the pool detecting it via block validation.

## V2 coinbaser binary format (the 0x11 response payload)

Parsed by `datum_coinbaser_v2_parse()`. Layout:

```
[ datum_id: 1 byte ]
For each output (max 512):
  [ outval: 8 bytes LE (satoshis) ]
  [ slen: 1 byte (script length, validated 2..64) ]
  [ script: slen bytes ]
```

Validation:

- Script-length range: 2–64 bytes.
- P2PKH pattern check: scripts beginning with `0x76` (OP_DUP) are recognized; others may be rejected or accepted (TIDES is currently P2PKH-heavy because the lightning-payouts wiki explains the address pre-LN was a workaround).
- **No reordering**: outputs are written into `available_coinbase_outputs[]` in receive order, then `memcpy`'d into the coinbase serialization in that same order:

  ```c
  memcpy(s->available_coinbase_outputs[cbvalid].output_script, &coinbaser[cidx], slen);
  ```

The "in the order provided" requirement from the README is a literal `memcpy` loop, not a sorted insert. If the gateway ever rearranges, the resulting block fails pool-side validation and the share is uncredited.

## The primary coinbase tag

Inserted by `generate_coinbase_input()` after BIP34 height encoding. Format inside the coinbase scriptSig:

```
PUSHBYTES X | <Primary tag> | 0x0F | <Secondary tag> | <unique ID push> | 0x00 | <Tertiary tag>
```

(The `0x0F` and `0x00` are separator bytes between tags; total tag space is capped at 86 bytes.)

The primary tag comes from `datum_config.mining_coinbase_tag_primary`, but **when DATUM is active the pool can override it** via `override_mining_coinbase_tag_primary`. This means OCEAN can globally enforce a coinbase signature like `/OCEAN.XYZ/` or whatever brand the pool wants visible in the chain — the gateway honors the override. (This is also the lever that lets a future protocol revision require a stronger commitment, e.g. a hash of pool policy.)

## The 16-bit unique identifier

```c
uchar_to_hex(&cb[i], (datum_config.coinbase_unique_id & 0xFF));
uchar_to_hex(&cb[i], ((datum_config.coinbase_unique_id >> 8) & 0xFF));
```

A 16-bit (2-byte) per-miner ID, hex-encoded into a 3-byte or 7-byte push immediately after the primary/secondary tags. The pool assigns this during the 0x99 client-configuration message at handshake time; every share's coinbase from this miner carries this ID. That's how the pool maps shares back to a payout account when the gateway constructs the template locally.

16 bits = 65,536 distinct miners per pool. That's enough for OCEAN's current scale but is a hard cap that the SV2 transition would naturally lift (SV2's `extranonce_prefix` is variable-length).

## The 6 coinbase variants

`generate_coinbase_txns_for_stratum_job()` produces six pre-built coinbases:

1. Empty
2. NiceHash (NiceHash-compatible padding)
3. Antminer
4. Whatsminer
5. Huge (long-form, for templates with many outputs)
6. Antminer2 (variant for newer Antminer firmware)

Why six? Different miners require different scriptSig padding patterns — particularly older firmware that hard-codes assumptions about extranonce position. By pre-building six and letting the gateway pick per-miner, DATUM avoids per-share regeneration cost while supporting hardware in the wild. The share-submission opcode 0x27 carries a `coinbase_id` byte specifying which variant was used.

This is **a hidden compatibility burden a downstream-SV2-proxy would inherit** — if the proxy sits between DATUM and SV2 miners, the SV2 extended-channel coinbase doesn't need this fan-out, but the upstream DATUM session still does.

## TIDES references

The file mentions `// possibly TIDES data` in a comment but TIDES math itself is upstream — the gateway just packs whatever outputs the pool sends. The TIDES distribution is computed pool-side and arrives as a flat output list; the gateway is TIDES-agnostic.

Leftover funds (the dust between coinbase value and the sum of pool-supplied outputs) are written into the coinbase's `coinb2` payment slot at:

```c
sprintf(&s->coinbase[0].coinb2[cb2idx[0]], "%016llx", __builtin_bswap64(s->coinbase_value - mval));
```

Where this dust goes is set elsewhere (typically a pool fee address) — the pool tells the gateway the destination via the same coinbaser response.

## Function catalog

| Function | Purpose |
|---|---|
| `datum_coinbaser_v2_parse()` | Parses the binary coinbaser response from the pool |
| `generate_coinbase_input()` | Builds coinbase scriptSig: BIP34 height + tag tree + unique ID |
| `generate_base_coinbase_txns_for_stratum_job()` | Creates empty/subsidy-only coinbases (used pre-pool-response and for solo mining) |
| `generate_coinbase_txns_for_stratum_job()` | Generates the 6 variants once per job |
| `datum_coinbaser_thread()` | Background thread that periodically refetches coinbasers |

## Why this matters

For a downstream-SV2 proxy talking DATUM upstream, three coinbase-layer problems land squarely in this file:

1. **Variant fan-out**: SV2's job-distribution model doesn't generate 6 variants — but the upstream DATUM session expects coinbase_id ∈ {0..5}. The proxy must pick one.
2. **Unique ID injection**: SV2 miners don't know about DATUM's 16-bit unique ID. The proxy must inject it into the coinbase before it can be a valid DATUM share.
3. **Tag override**: If the OCEAN pool overrides `mining_coinbase_tag_primary`, the SV2 miner's NewExtendedMiningJob `coinb1` must include that override — the proxy can't let the miner pick.

This is the meatiest cross-protocol-translation problem of the whole design: the SV2 mining channel's coinbase commitment and DATUM's coinbase commitment are negotiated by different parties on different timelines.

## Sources

- [datum_coinbaser.c @ master](https://github.com/OCEAN-xyz/datum_gateway/blob/master/src/datum_coinbaser.c) — 35,705 bytes at HEAD `a3da9e69` (2026-04-06).
