---
title: "DATUM Protocol"
category: concept
sources:
  - raw/articles/2026-05-28-datum-gateway-readme.md
  - raw/repos/2026-06-01-path1-datum-protocol-h.md
  - raw/repos/2026-06-01-path1-datum-protocol-c.md
  - raw/repos/2026-06-01-path1-datum-coinbaser-c.md
created: 2026-05-28
updated: 2026-06-01
tags: [datum, datum-protocol, ocean, mining, encryption, pool-protocol, libsodium]
aliases: ["DATUM wire protocol", "DATUM Prime protocol"]
confidence: high
volatility: warm
verified: 2026-06-01
summary: "DATUM is OCEAN's custom encrypted protocol between the DATUM Gateway (client) and DATUM Prime (pool). Wire format reconstructed from `src/datum_protocol.c`: 32-bit packed header (22-bit length, 5-bit opcode, 3 encryption flags), libsodium primitives (NOT Noise / NOT TLS), 8-job ring, 16-bit unique-identifier. v0.4.1-beta on master. Spec remains unpublished but the source is canonical."
---

# DATUM Protocol

> The encrypted custom wire protocol the DATUM Gateway uses to talk to a DATUM Prime pool. Unlike Stratum (v1 or v2), DATUM has **no mechanism for the pool to send a template down** — the gateway has already built it locally from the miner's own Bitcoin node. The protocol exists to negotiate payout, ship shares, and accept guardrails.

## Confidence note (upgraded 2026-06-01)

The wire-level specification is **still not public**, but Path 1 of the 2026-06-01 research reconstructed it from `src/datum_protocol.h`, `src/datum_protocol.c`, and `src/datum_coinbaser.c` directly. Confidence upgraded from medium → high. README still says "evolving, subject to change" — treat field-level details as code-anchored, not spec-anchored.

## Wire format

- **Header**: 32-bit packed: `cmd_len (22 bits)`, `reserved (2 bits)`, `is_signed (1)`, `is_encrypted_pubkey (1)`, `is_encrypted_channel (1)`, `proto_cmd (5 bits — only 32 commands max)`.
- **Frame ceiling**: 4 MB per command. Max 8 concurrent jobs in the ring.
- **Top-level commands observed**: `1` PING, `2` handshake response, `5` mining (workhorse), `7` server INFO. Almost all real traffic is `proto_cmd=5` with sub-opcodes:
  - `0x10` / `0x11` — coinbaser request / response
  - `0x27` — share submit
  - `0x50` — job validation (further sub-dispatched 0x10/0x11/0x12)
  - `0x8F` — share response
  - `0x99` — client config
  - `0xF9` — block notify

## Encryption — libsodium, not Noise

Pure libsodium primitives. **Not Noise. Not TLS.**

- **Handshake**: client sends a `crypto_box_seal()`-sealed hello carrying long-term + session Ed25519 + X25519 public keys, signed with the long-term Ed25519 key.
- **Steady state**: `crypto_box_beforenm()` precomputation + `crypto_box_easy_afternm()` (ChaCha20-Poly1305, 24-byte nonces).
- **Header obfuscation**: separate XOR-feedback chain seeded by client-chosen `nk`, evolved per packet via a MurmurHash3-32 finalizer. Original init constant is `0xb10cfeed`. **PR #202 (open) replaces the seed source with `randombytes_buf()`** — the original entropy was apparently weak.

## Share submission (`proto_cmd=5`, sub-opcode `0x27`)

Fields: `job_id`, `coinbase_id` (selects 1 of 6 pre-built variants), flags byte (`is_block` / `subsidy_only` / `quickdiff`), `target` byte, `ntime`, `nonce`, `version`, **12-byte extranonce**, conditional `username`, optional `0x01` merkle branches, optional `0x02` coinbase data, end-marker `0xFE` + random padding.

Three response codes:

- `ACCEPTED 0x50`
- `ACCEPTED_TENTATIVELY 0x55` — no SV1/SV2 equivalent. Reflects DATUM's "pool validates the block" trust model.
- `REJECTED 0x66`

30-second response timeout.

## Coinbase enforcement

Pool-supplied outputs land in a binary V2 coinbaser blob: `datum_id` + per-output `[outval LE 8B][slen 1B][script]`, parsed by `datum_coinbaser_v2_parse()`. Max 512 outputs; scripts validated 2-64 bytes with P2PKH detection. **The "in the order provided" requirement is a literal `memcpy` loop — no reordering is possible.**

scriptSig structure: `PUSHBYTES X | <Primary tag> | 0x0F | <Secondary> | <unique ID> | 0x00 | <Tertiary>`, max 86 bytes total. Pool override available via `override_mining_coinbase_tag_primary`.

The "unique identifier" is a **16-bit value (max 65,536 miners per pool)** hex-encoded into a 3- or 7-byte push.

## Protocol version + production drift

- **Master HEAD**: `DATUM_PROTOCOL_VERSION = "v0.4.1-beta"`.
- **Triple version bump on 2025-12-17** across three concurrent maintenance branches (0.2.6 / 0.3.3 / 0.4.1). Implication: **OCEAN runs older versions in production**; master is bleeding-edge.

## DATUM Prime is closed source

OCEAN-xyz GitHub org has only 2 public repos: `datum_gateway` (C client, 145 stars) and `datum-gateway-startos` (TS packaging, 12 stars). The pool-side daemon, TIDES calculator, and share-validation pipeline are all closed-source. **This sets a hard ceiling on offline development**: any third-party proxy, translator, or test harness must integration-test against the live OCEAN pool.

## Stated design goals

The README enumerates five core concepts of the protocol:

1. **Encrypt** communications between the Gateway and pool.
2. **Obfuscate** the encrypted traffic so a MITM can't infer useful operational information from ciphertext analysis.
3. **Retrieve generation-transaction payout splits** from the pool, so the locally-built template's coinbase distributes the reward according to pool policy (e.g. TIDES).
4. **Submit work** with enough metadata for the pool to validate and credit it.
5. **Communicate guardrails** — minimal requirements a template must meet to earn pooled rewards.

## What DATUM does NOT carry

The crucial negative space, also from the README: *"the DATUM protocol has no mechanisms for the pool providing the information needed to construct work or a block template."*

This is the architectural inversion vs Stratum:

| Stratum v1/v2 | DATUM |
|---|---|
| Pool → miner: full template/job | Pool → miner: payout outputs + guardrails only |
| Miner can't pick transactions | Miner picks transactions (via local node) |
| Pool censors trivially | Pool can only refuse to credit shares post-hoc |

## Pool-side trust today vs eventually

The current version of the protocol still has the pool validate the block after the miner coordinates with it. The README explicitly frames this as transitional:

> "This is strictly to ensure miners are not accidentally creating invalid blocks while DATUM is still undergoing testing. In a future version of the protocol, the pool will not be in charge of this function and will be almost completely blinded to the contents of the miner's block template."

So the present trust model:

- Pool sees enough of the block to validate it before it's broadcast.
- Pool can refuse to credit shares for blocks it doesn't like (effectively censoring after the fact).
- Future: pool is "almost completely blinded" to template contents — implementation details unspecified at this revision.

## Reward-system independence

DATUM is not bound to a specific payout scheme. The protocol coordinates "the appropriate generation transaction with the pool," so any pool implementation that can describe its desired coinbase outputs can in principle drive a DATUM gateway. The README's editorial preference is that pools should pay miners directly from generated payouts (à la OCEAN's TIDES) rather than custodying funds — but that's a property of the pool, not the protocol.

## Pool-required content in the coinbase

Per the README's *Template/Share Requirements for Pooled Mining* list, every submitted share must:

- Be a valid block under current consensus rules.
- Be for the current latest block height with a valid time.
- Include the **pool's generation-transaction outputs in the order provided**.
- Include the **primary coinbase tag** as provided by the pool.
- Include the **unique identifier** provided by the pool (per-miner, presumably for share-attribution).
- Meet or exceed the work target.

The "unique identifier" hook is interesting: it gives the pool a per-miner marker in the coinbase even though the pool didn't construct the rest of the template. This is the same broad problem covered in the `sv2-coinbase-identity` sibling wiki for Stratum V2's `user_identity` channel field — the SV2 answer is `extranonce_prefix`; the DATUM answer is "the protocol gives you a unique identifier you must include." Distinct mechanism, same goal.

## Failure mode: pool disconnect

When the gateway loses its DATUM Protocol connection and can't reconnect, by default it disconnects all stratum clients. README rationale: this lets miners' built-in failover swap to non-DATUM mining or a backup gateway, rather than silently mining work that won't be credited.

## See Also

- [[datum-gateway-overview|DATUM Gateway — overview]] ([DATUM Gateway — overview](../topics/datum-gateway-overview.md)) — where DATUM Protocol fits in the larger stack
- [[gateway-data-flow|Gateway data flow]] ([Gateway data flow](../concepts/gateway-data-flow.md)) — when on the runtime path DATUM messages are exchanged
- [[stratum-usernames-and-modifiers|Stratum usernames and modifiers]] ([Stratum usernames and modifiers](../concepts/stratum-usernames-and-modifiers.md)) — `pool_pass_full_users` controls how miner usernames cross the DATUM boundary
- [[deployment-and-node-config|Deployment and node config]] ([Deployment and node config](../concepts/deployment-and-node-config.md)) — operator-side setup for the link this protocol travels
- [[datum-history-and-motivation|DATUM — history and motivation]] ([DATUM history and motivation](../concepts/datum-history-and-motivation.md)) — why this protocol's negative-space property (no template flows down) is the whole point
- [[tides-payout|TIDES payout]] ([TIDES payout](../concepts/tides-payout.md)) — the generation-transaction output set that DATUM Protocol carries from the pool

## Sources

- [DATUM Gateway — README](../../raw/articles/2026-05-28-datum-gateway-readme.md) — *DATUM Protocol* and *Template/Share Requirements for Pooled Mining* sections
