---
title: "stratum-sniffer — MITM Noise-termination architecture (not a passive tap)"
source_url: https://github.com/stratum-mining/stratum-sniffer
source_url_2: https://crates.io/crates/integration_tests_sv2
type: repo
retrieved: 2026-07-21
credibility: high
corroboration: "gap-2 agent (cloned + read full repo + crate tarball)"
tags: [stratum-v2, stratum-sniffer, integration_tests_sv2, noise, MITM, mining-device, wire-inspection]
summary: "stratum-sniffer is a thin CLI over integration_tests_sv2::Sniffer — an ACTIVE MITM proxy that terminates two Noise sessions with its OWN hardcoded keypair (impersonating the pool), not a passive tap. SV2's Noise_NX encryption means you cannot read a third party's session without keys/MITM. The recommended daemon path: be your own SV2 client."
---

# stratum-sniffer — MITM architecture

## What it actually is

`stratum-sniffer` is a ~40-line CLI wrapper around `integration_tests_sv2::sniffer::Sniffer`
(SV2) / `SnifferSV1` (SV1). Config: `server_addr` (upstream pool), `listen_addr` (local
bind), `sv2` (bool). It is **not a passive tap** — it's an **active MITM/transparent
proxy**: the miner connects to the sniffer's `listen_addr`; the sniffer opens its own TCP
connection to the pool; it terminates two separate connections and relays decoded frames.

## The Noise mechanism (the crux)

- Toward the miner, the sniffer is a Noise **Responder** using a **hardcoded keypair**:
  pubkey `9auqWEzQDVyd2oe1JVGFLMLHZtCo2FFqZwtKA5gd9xbuEu7PH72` +
  secret `mkDLTBBRxdBv998612qipDYoTK3YUrqLe8uWw7gu3iXbSrn2n`
  (`Responder::from_authority_kp(...)`). The miner MUST be reconfigured to trust this
  pubkey.
- Toward the pool, it's a Noise **Initiator** via `Initiator::without_pk()` (does NOT
  verify the pool cert).
- Two independent Noise sessions: decrypt on one leg → parse `AnyMessage` → log/queue →
  re-encrypt → forward. It never "decrypts a third party's session"; it terminates both.
- Single-shot, test-grade ("connect a client 1x; restart after disconnect").

## What it decodes

Full SRI `AnyMessage<'static>`: `Common`, `Mining`, `JobDeclaration`,
`TemplateDistribution`, `Extensions` (TLV). **`NewExtendedMiningJob` (msg 0x1f) is
surfaced** with `coinbase_tx_prefix`/`coinbase_tx_suffix` readable as struct fields.
Inspection API: `next_message_from_downstream()/_upstream()`, `wait_for_message_type`,
plus active `InterceptAction::IgnoreMessage`/`ReplaceMessage` (fault injection). Reuses
the SRI parsing stack: `parsers_sv2`, `codec_sv2`, `framing_sv2`, `noise_sv2`,
`network_helpers`, `key_utils`.

## Why this matters for the daemon

**SV2 is Noise_NX + AEAD (ChaCha20-Poly1305) encrypted end-to-end.** A pure passive tap
(libpcap, port mirror, Wireshark) captures only ciphertext — session keys are ephemeral
(derived per-handshake), and the pool's authority secret is held only by the pool. You
**cannot** silently observe an unmodified miner's real pool session. No in-org Wireshark
SV2 dissector exists (and it'd be near-useless on encrypted traffic).

**→ Don't build the daemon on the Sniffer/MITM path.** Instead, **be your own SV2
client** (like `integration_tests_sv2`'s `mining_device`): the daemon completes the Noise
handshake itself, holds the session keys by construction, and receives
`NewExtendedMiningJob` in plaintext-to-it. Pin the pool's authority pubkey via
`Initiator::new(Some(pk))`. The Sniffer's value is (a) a reference for driving the SRI
Noise+parser stack, and (b) a lab/debug MITM + fault-injection tool.
