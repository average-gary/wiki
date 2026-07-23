---
title: "SV2 mining-client message flow"
type: concept
created: 2026-07-21
updated: 2026-07-21
confidence: high
tags: [stratum-v2, mining-client, SetupConnection, OpenExtendedMiningChannel, NewExtendedMiningJob, SetNewPrevHash, noise]
---

# SV2 mining-client message flow

The ordered sequence a downstream daemon follows to connect to a Stratum V2 pool and
start receiving jobs. Confirmed against the spec and the SRI reference client.

## The sequence

1. **Noise_NX handshake** — before any mining message. `-> e`; `<- e, ee, s, es,
   SIGNATURE_NOISE_MESSAGE`; initiator validates the pool's certificate. secp256k1 +
   BIP340 Schnorr, SHA-256, ChaCha20-Poly1305 AEAD. After this both sides encrypt all
   traffic. See [[wiki/concepts/coinbase-verification-trust-model-limits]] for why auth
   ≠ honesty. — [[raw/articles/2026-07-21-sv2-spec-design-goals-and-security]]
2. **SetupConnection / .Success** — `protocol: MiningProtocol`, `min_version:2,
   max_version:2`, `flags` (e.g. `REQUIRES_STANDARD_JOBS`, `REQUIRES_WORK_SELECTION`,
   `REQUIRES_VERSION_ROLLING`). `.Success` returns `used_version` + `flags`.
3. **OpenExtendedMiningChannel / .Success** — `request_id`, `user_identity`,
   `nominal_hash_rate`, `max_target`, `min_extranonce_size`. `.Success` returns
   `channel_id`, `target`, **`extranonce_size`**, **`extranonce_prefix`**,
   `group_channel_id`. (A daemon that wants to inspect the coinbase MUST open an
   **extended** channel — see [[wiki/concepts/standard-vs-extended-channels-coinbase-visibility]].)
4. **NewExtendedMiningJob** — arrives with `coinbase_tx_prefix`, `coinbase_tx_suffix`,
   `merkle_path`, `version`, `version_rolling_allowed`. If `min_ntime` is empty it is a
   **future job** (not yet mineable).
5. **SetNewPrevHash** — `job_id` (which future job to activate), `prev_hash`,
   `min_ntime`, `nbits`. Promotes a future job to active.
6. **Mine / check** — reconstruct the coinbase, verify against expectations
   ([[wiki/concepts/coinbase-reconstruction-and-merkle-fold]]).
7. **SubmitSharesExtended** — `channel_id`, `sequence_number`, `job_id`, `nonce`,
   `ntime`, `version`, **`extranonce`**. Pool replies `SubmitSharesSuccess` / `...Error`.

`SetTarget` (difficulty) and `SetExtranoncePrefix` may arrive asynchronously at any
time. — [[raw/articles/2026-07-21-sv2-spec-mining-protocol-channels-jobs]]

## In the SRI reference client

The `mining-device` role implements exactly this shape (though on a *standard*
channel): `connect()` → `SetupConnectionHandler` → `open_channel()` → frame loop over
`Mining::{...}`. The connect/handshake/loop scaffolding is directly reusable; only the
channel type and job-handling differ. — [[raw/repos/2026-07-21-sri-mining-device-reference-client]]

## See also

- [[wiki/concepts/standard-vs-extended-channels-coinbase-visibility]]
- [[wiki/concepts/sri-client-crate-stack]]
- [[wiki/topics/daemon-build-playbook]]
