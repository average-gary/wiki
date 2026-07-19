---
title: "MuSig2 Implementations & Specs"
category: reference
sources: [raw/articles/2026-07-16-bip-327-musig2-spec.md, raw/articles/2026-07-16-bip-373-musig2-psbt-fields.md, raw/articles/2026-07-16-bolt-simple-taproot-channels-musig2.md, raw/articles/2026-07-16-bolt2-interactive-tx-construction.md, raw/repos/2026-07-16-libsecp256k1-musig-module.md, raw/repos/2026-07-16-lnd-musig2-signer-api.md, raw/papers/2026-07-16-rfc-9591-frost.md, raw/papers/2026-07-16-roast-robust-asynchronous-schnorr-threshold.md, raw/articles/2026-07-16-bitcoin-optech-musig-topic.md]
created: 2026-07-16
updated: 2026-07-16
tags: [reference, bip-327, bip-373, rfc-9591, libsecp256k1, lnd, implementations, specs, standardization-timeline]
aliases: [MuSig2 specs, MuSig2 implementations, MuSig2 reference list]
confidence: high
volatility: hot
verified: 2026-07-16
summary: "Curated reference: the specifications, standards, and implementations relevant to MuSig2 interactive signing ceremonies, with a standardization timeline and an implementation-status table. Includes a correction on where MuSig2 lives in the Rust ecosystem."
---

# MuSig2 Implementations & Specs

> A curated map of the specifications and code that define and realize MuSig2 signing ceremonies. Facts here are volatility `hot` — implementation status and version numbers change; re-verify before relying on a status claim.

## Specifications & standards

| Spec | What it defines | Status |
|------|-----------------|--------|
| **BIP-327** | The MuSig2 protocol: rounds, algorithms, `SecNonce`/`PubNonce`/`SessionContext`, nonce rules, identifiable abort, tweaking | Deployed; v1.0.3 (2026-01-05) |
| **BIP-373** | MuSig2 PSBT fields (`PSBT_IN_MUSIG2_PARTICIPANT_PUBKEYS` 0x1a, `PUB_NONCE` 0x1b, `PARTIAL_SIG` 0x1c) | Added 2024 |
| **BIP-328** | MuSig2 key derivation | Added 2024 |
| **BIP-390** | MuSig2 descriptors | Added 2024 |
| **BOLT #2** | Lightning interactive tx construction + dual funding (the framing skeleton) | Active |
| **BOLT: Simple Taproot Channels** | MuSig2 folded into channel messages via TLV; feature bits 80/81 | Extension BOLT (merged per Optech #404, May 2026) |
| **RFC 9591** | FROST (t-of-n threshold Schnorr) — comparison point | Informational, June 2024 |

## Implementations

| Implementation | Language | Notes |
|----------------|----------|-------|
| **libsecp256k1 / secp256k1-zkp** MuSig module | C | Canonical reference; implements BIP-327 v1.0.0; built behind `--enable-experimental`. Struct-level nonce-reuse guards. |
| **rust-secp256k1-zkp** `musig` | Rust | The Blockstream-fork binding. `SecretNonce` is non-`Copy`/non-`Clone`; `partial_sign` takes ownership. **Note:** MuSig2 is *not* in the mainline `rust-secp256k1` crate (v0.31.1 has no musig module) — it lives in `secp256k1-zkp`. |
| **LND** MuSig2 Signer API (`signrpc`) | Go | RPC ceremony keyed by `session_id`; `have_all_nonces` round gate; sign-once-per-session. Marked HIGHLY EXPERIMENTAL. Protocol v0.4.0 (x-only) and v1.0.0rc2 (compressed). |
| **Lightning Loop** | Go | Defaulted to MuSig2 in 2025. |

## Standardization timeline

- **2018** — MuSig1 published (three-round variant; two-round proof found flawed).
- **2020** — MuSig2 paper (eprint 2020/1261); MuSig-DN (CCS 2020); ROS attack (eprint 2020/945).
- **2021** — MuSig2 at CRYPTO 2021.
- **2022** — ROAST at ACM CCS 2022; BIP-327 assigned (2022-03-22).
- **2023** — BIP-327 becomes the official MuSig2 spec.
- **2024** — BIPs 328/390/373 added; RFC 9591 (FROST) published.
- **2025** — libsecp256k1 MuSig2 implementation completed; Lightning Loop defaults to MuSig2.
- **2026** — BIP-327 v1.0.3; simple taproot channels merged as an extension BOLT (Optech #404).

## Rust ecosystem correction

A frequent mistake: assuming `rust-secp256k1` (the mainline crate) exposes MuSig2. It does not — its modules are ecdsa, schnorr, ecdh, ellswift, etc. MuSig2 in Rust is provided by **`secp256k1-zkp` / `rust-secp256k1-zkp`**, which bind to Blockstream's `secp256k1-zkp` C fork. Depend on the `-zkp` crate for MuSig2 work.

## See Also

- [[musig2-interactive-signing-ceremonies|MuSig2 Interactive Signing Ceremonies]] ([MuSig2 Interactive Signing Ceremonies](../topics/musig2-interactive-signing-ceremonies.md)) — the umbrella topic
- [[musig2-protocol|The MuSig2 Protocol]] ([The MuSig2 Protocol](../concepts/musig2-protocol.md)) — what BIP-327 specifies
- [[session-framing-and-state|Session Framing and State]] ([Session Framing and State](../concepts/session-framing-and-state.md)) — the framing patterns these specs enable
- [[musig2-vs-frost-roast|MuSig2 vs FROST/ROAST]] ([MuSig2 vs FROST/ROAST](../concepts/musig2-vs-frost-roast.md)) — the RFC 9591 / ROAST comparison

## Sources

- [BIP-327: MuSig2 Specification](../../raw/articles/2026-07-16-bip-327-musig2-spec.md)
- [BIP-373: MuSig2 PSBT Fields](../../raw/articles/2026-07-16-bip-373-musig2-psbt-fields.md)
- [BOLT: Simple Taproot Channels (MuSig2)](../../raw/articles/2026-07-16-bolt-simple-taproot-channels-musig2.md)
- [BOLT #2: Interactive Tx Construction](../../raw/articles/2026-07-16-bolt2-interactive-tx-construction.md)
- [libsecp256k1 / secp256k1-zkp MuSig module](../../raw/repos/2026-07-16-libsecp256k1-musig-module.md)
- [LND MuSig2 Signer API](../../raw/repos/2026-07-16-lnd-musig2-signer-api.md)
- [RFC 9591: The FROST Protocol](../../raw/papers/2026-07-16-rfc-9591-frost.md)
- [ROAST: Robust Asynchronous Schnorr Threshold Signatures](../../raw/papers/2026-07-16-roast-robust-asynchronous-schnorr-threshold.md)
- [Bitcoin Optech: MuSig Topic](../../raw/articles/2026-07-16-bitcoin-optech-musig-topic.md)
