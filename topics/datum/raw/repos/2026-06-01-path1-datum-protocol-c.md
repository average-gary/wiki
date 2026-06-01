---
title: "datum_protocol.c — DATUM Protocol client implementation"
source: "https://raw.githubusercontent.com/OCEAN-xyz/datum_gateway/master/src/datum_protocol.c"
type: repos
tags: [datum, datum-protocol, encryption, handshake, libsodium, share-submission, ocean, c-source]
summary: "62 KB C file implementing the DATUM Protocol client: libsodium-based handshake (sealed-box hello + Ed25519 signatures + crypto_box_beforenm precomputation), MurmurHash3-style XOR-feedback header obfuscation, share-submission opcode 0x27 with 12-byte extranonce and conditional username/merkle/coinbase fields, datum_state machine 0→3 (init → handshake → encrypted → ready)."
confidence: high
ingested: 2026-06-01
ingested_by: path1
quality_score: 5
canonical_url: "https://github.com/OCEAN-xyz/datum_gateway/blob/master/src/datum_protocol.c"
license: MIT
revision_branch: master
---

# datum_protocol.c — client implementation

The 62 KB C source that implements every byte of the protocol on the gateway side. This is where opcode dispatch, libsodium calls, and the share-submission encoding actually live.

## The handshake (the most security-sensitive moment in DATUM)

### Step 1 — Client hello

The client constructs an initial "hello" buffer and seals it with the pool's published X25519 public key. Field order (verbatim from the source):

```c
memcpy(&hello_msg[i], local_datum_keys.pk_ed25519, crypto_sign_PUBLICKEYBYTES);   // long-term signing pubkey (32B)
i += crypto_sign_PUBLICKEYBYTES;
memcpy(&hello_msg[i], local_datum_keys.pk_x25519, crypto_box_PUBLICKEYBYTES);     // long-term encryption pubkey (32B)
i += crypto_box_PUBLICKEYBYTES;
memcpy(&hello_msg[i], session_datum_keys.pk_ed25519, crypto_sign_PUBLICKEYBYTES); // session signing pubkey (32B)
// followed by session X25519 pubkey, version string, random nonce seed
```

The whole payload is signed by the client's long-term Ed25519 key, then sealed via `crypto_box_seal()` to the pool's known X25519 pubkey. So:

- **Authentication** of the client identity comes from the Ed25519 detached signature.
- **Confidentiality** of the hello comes from the sealed-box (one-shot, anonymous-sender X25519).
- **Forward secrecy** of subsequent traffic comes from the **session** keypairs — the long-term keys are only used to sign-and-prove identity, not to encrypt the channel.

This is conceptually similar to a Noise IK handshake but built from libsodium primitives rather than the Noise spec itself. It's NOT Noise.

### Step 2 — Server response and precomputation

Server echoes the client's keys, ships its own session keys plus an MOTD, and signs the response. Client validates and runs:

```c
crypto_box_beforenm(precomp, server_session_x25519_pk, client_session_x25519_sk)
```

producing a precomputed shared secret used with `crypto_box_easy_afternm()` / `crypto_box_open_easy_afternm()` for all subsequent traffic. This is libsodium's standard authenticated-encryption fast path: ChaCha20-Poly1305 under the hood, with 24-byte nonces.

### Step 3 — Header XOR obfuscation seed

Both sides initialize a `sending_header_key` from a client-chosen `nk` seed via:

```c
uint32_t datum_header_xor_feedback(const uint32_t i) {
    uint32_t s = 0xb10cfeed;
    uint32_t h = s;
    uint32_t k = i;
    k *= 0xcc9e2d51; k = (k << 15) | (k >> 17); k *= 0x1b873593;
    h ^= k;
    h = (h << 13) | (h >> 19);
    h = h * 5 + 0xe6546b64;
    h ^= 4;
    h ^= h >> 16; h *= 0x85ebca6b;
    h ^= h >> 13; h *= 0xc2b2ae35;
    h ^= h >> 16;
    return h;
}
```

That's MurmurHash3's 32-bit finalizer with a `0xb10cfeed` ("blocfeed") init constant. The XOR rolls forward each header to obfuscate the otherwise-fixed framing pattern from passive observers — the README's "obfuscate communications somewhat so a MITM is unable to glean useful or accurate insight" claim. Note: this is **not cryptographic encryption of the header** (the body is encrypted separately); it's traffic-analysis resistance only.

PR #202 (open as of 2026-05-21) replaces the initial `nk` seed source with libsodium's `randombytes_buf()`. The fact this needed a fix suggests the original seed had weaker entropy properties.

## State machine

| `datum_state` value | Meaning |
|---|---|
| 0 | Initialization |
| 1 | Handshake pending |
| 2 | Encrypted session established |
| 3 | Fully configured, ready to mine |

The transition 2 → 3 happens after the pool sends a `0x99` (client configuration) sub-message under `proto_cmd=5`, which carries pool-side configuration including the per-miner unique ID, coinbase tag overrides, and likely starting difficulty.

## Share-submission code path

Primary function: `datum_protocol_pow()` (formats and queues) → `datum_protocol_mining_cmd()` (encrypts under `proto_cmd=5` and sends).

Share-submit sub-opcode is `0x27` (under `proto_cmd=5`). Field layout per share:

| Field | Size | Notes |
|---|---|---|
| Job ID | varies | references one of up to 8 active DATUM jobs |
| Coinbase ID | 1 byte | which of the 6 coinbase variants the share used |
| Flags | 1 byte | `is_block`, `subsidy_only`, `quickdiff` bit flags |
| Target byte | 1 byte | difficulty marker |
| ntime | 4 bytes | block timestamp |
| Nonce | 4 bytes | the actual PoW |
| Version | 4 bytes | block version (with rolling bits) |
| Extranonce | 12 bytes | gateway-side extranonce |
| Username | conditional | included only if `pool_pass_full_users` is on |
| Optional 0x01 marker | varies | merkle branches |
| Optional 0x02 marker | varies | full coinbase data |
| End-marker `0xFE` | 1 byte | + random padding |

Note the 12-byte extranonce — this is significantly larger than SV1's typical 4–8 byte extranonce2 and broadly aligns with SV2's extended-channel `extranonce_prefix` semantics. The conditional username field is the wire-level expression of the `pool_pass_full_users` config knob.

Shares are tracked via `datum_last_accepted_share_tsms` with a 30-second response-timeout watchdog.

## Function-name catalog

| Function | Purpose |
|---|---|
| `datum_protocol_client()` | Main event loop; manages connection, receives/sends |
| `datum_protocol_send_hello()` | Initiates handshake with sealed key-exchange message |
| `datum_protocol_server_msg()` | Decrypts and dispatches incoming server commands |
| `datum_protocol_pow()` | Formats and queues share submission |
| `datum_protocol_mining_cmd()` | Encrypts and sends `proto_cmd=5` mining subcommand |
| `datum_protocol_job_validation_stxlist()` | Responds to short-txn-list request (compact block) |
| `datum_protocol_handshake_response()` | Validates server handshake, derives session secret |
| `datum_encrypt_generate_keys()` | libsodium key generation (Ed25519 + X25519) |
| `datum_encrypt_prep_precomp()` | `crypto_box_beforenm` for session encryption |
| `datum_header_xor_feedback()` | MurmurHash3-style XOR roll for header obfuscation |
| `datum_protocol_coinbaser_fetch()` | Sends `0x10` coinbaser request, waits for `0x11` response |
| `datum_increment_session_nonce()` | 24-byte nonce monotonic increment with overflow handling |

## Coinbaser request/response (opcodes 0x10/0x11)

The fetch request body (under `proto_cmd=5, subcmd=0x10`):

```
[ available_value: 8 bytes LE ]
[ previous_block_hash: 32 bytes ]
[ padding ]
```

Response body (under `proto_cmd=5, subcmd=0x11`) is the binary V2 coinbaser blob — see `datum_coinbaser.c` source ingest.

## Job-validation error codes (under proto_cmd=5, subcmd=0x50)

| Code | Meaning |
|---|---|
| `0xF0` | Stratum job not found |
| `0xF1` | Block template missing |
| `0xF2` | Transaction count exceeds limit |
| `0xF3` | Invalid job index |
| `0xF4` | Invalid transaction ID |

## Timeout configuration

- Global server-silence threshold: `datum_config.datum_protocol_global_timeout_ms` (config-tunable).
- Share-response timeout: 30 seconds hard.
- Coinbaser fetch: 5-second `pthread_mutex_timedlock`.

## Key takeaways for the SV2-downstream-proxy design

1. **Encryption is libsodium, not Noise.** A translator must speak libsodium handshake on the DATUM side and Noise on the SV2 side; these don't share key material.
2. **Sub-opcode tree under `proto_cmd=5` is where almost all logic lives.** Mapping SV2 messages to DATUM is mostly mapping under this one parent opcode.
3. **The `0x27` share-submit opcode has a 12-byte extranonce already** — close enough to SV2 extended-channel semantics that translation should be cheap.
4. **30-second share-response timeout** matches SV2 expectations but means the proxy has to surface ack latency back to the SV2 downstream cleanly.
5. **The `ACCEPTED_TENTATIVELY` (0x55) response has no SV1 or SV2 equivalent** — the proxy must decide whether to map it to `SubmitSharesSuccess` (optimistic) or hold the ack (correct but stalls miner stats).

## Sources

- [datum_protocol.c @ master](https://github.com/OCEAN-xyz/datum_gateway/blob/master/src/datum_protocol.c) — 62,428 bytes at HEAD `a3da9e69` (2026-04-06).
- PR #202 — `protocol: Use libsodium randombytes_buf for initial sending_header_key` — open 2026-05-20.
