---
title: "Stratum V2 spec — 02 Design Goals + 04 Protocol Security (HOM intent, Noise_NX transport)"
source_url: https://github.com/stratum-mining/sv2-spec/blob/main/02-Design-Goals.md
source_url_2: https://github.com/stratum-mining/sv2-spec/blob/main/04-Protocol-Security.md
type: article
retrieved: 2026-07-21
credibility: high
corroboration: "02 from trust-model agent; 04 from client-flow + trust-model agents"
tags: [stratum-v2, design-goals, header-only-mining, noise, Noise_NX, secp256k1, chacha20poly1305, transaction-selection]
summary: "SV2 design goals (header-only mining is an explicit goal; transaction selection is quarantined to a separate channel) and the Noise_NX encrypted transport that wraps every session. Authentication proves pool identity, not honesty."
---

# SV2 spec — 02 Design Goals + 04 Protocol Security

## 02 Design Goals — why the coinbase is often invisible

- Explicit goal: **"Support header-only mining (not touching the coinbase
  transaction) in as many situations as possible."** HOM (no coinbase) is intended,
  not a limitation to route around.
- Transaction selection deliberately quarantined: **"Use a separate communication
  channel for transaction selection so that it does not have a performance impact
  on the main mining/share communication."**
- Miner tx choice is optional and out-of-band: "Allow miners to (optionally) choose
  the transaction set they mine through work declaration on some independent
  communication channel."
- Three pool modes: **disabled** (pool decides everything — the default), **client-push**,
  **client-declared**.

Implication: in the most common (standard-channel, no-job-declaration) config, the
pool holds coinbase authority and a passive daemon has *nothing to check*.

## 04 Protocol Security — the encrypted transport

- Handshake pattern: **`Noise_NX`** — augmented by server authentication via a
  simple 2-level PKI.
- Curve: **secp256k1**; signatures: **Schnorr per BIP340**. Hash: **SHA-256**.
  AEAD: **ChaCha20-Poly1305 (ChaChaPoly)**.
- Phases: (1) `-> e`; (2) `<- e, ee, s, es, SIGNATURE_NOISE_MESSAGE`; (3) initiator
  validates the server via `SIGNATURE_NOISE_MESSAGE`.
- The certificate (`SIGNATURE_NOISE_MESSAGE`) carries `version`, `valid_from`,
  `not_valid_after`, `signature`. After success both sides hold `CipherState`
  objects and AEAD-encrypt all traffic.
- Security motivation is **privacy** (an adversary must not be able to estimate a
  miner's performance from wire data), not payout honesty.

**Key limit:** authenticating the pool proves *who* it is, **not** that its jobs,
coinbase, or payouts are honest. "Authentication verifies identity, not
trustworthiness of business practices." The daemon must complete the Noise_NX
handshake before any mining message.
