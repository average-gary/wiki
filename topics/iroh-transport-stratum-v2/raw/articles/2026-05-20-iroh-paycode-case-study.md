---
title: "Iroh in Production: Paycode (payment terminals)"
source_url: https://www.iroh.computer/blog/paycode
type: case-study
date: 2026-03-26
org: n0-computer / Paycode (Carlos Diez)
credibility: high
quality: 5
relevance: direct
tags: [iroh, production, payment, embedded, applied]
ingested: 2026-05-20
---

# Paycode case study — Iroh in payment terminals

Best public proof point that Iroh is production-grade for binary,
latency-sensitive, financially-significant workloads on heterogeneous hardware.

## Architecture

- Replaced **on-site server hardware** (MQTT brokers, HTTP servers, local WiFi
  servers) at highway toll booths with direct device-to-device Iroh.
- Single-point-of-failure removed.
- Connection bootstrap via QR code:
  ```
  encode(iroh_ticket) → NodeID + Addrs + RelayURL
  → scan QR → add_endpoint_addr → resolve(NodeID) → endpoints → connected
  ```

## Direct analog for SV2

The "iroh ticket" pattern is the equivalent of the SV2 authority-pubkey-in-URL
encoding (`stratum2+tcp://thepool.com:34254/<base58check>`). A pool publishes
an iroh-ticket for its endpoint; miners scan/import.

## Defense-in-depth

> "raw payment data stays on the payment terminal, and any resulting transaction
> data is encrypted into a secure payload before leaving the device."

Iroh treated as a **"blind command and control channel"** — payload is
application-encrypted before it hits the transport. Mirrors SV2's Noise model:
even if iroh's TLS-RPK were stripped, the SV2 ciphertext (under Noise_NX)
remains confidential.

## Cross-language deployment

- Rust core embedded in **Kotlin Android PoS app**.
- **Published .NET 6 NuGet package** for Windows 7 terminals.
- Hardware: **dual-core Intel CPUs with up to 8GB of RAM**.

> "iroh was super easy to use. ... I started hacking and was able to integrate
> it into our Kotlin PoS app and have a published .NET NuGet package for our
> client to use in that month."

Month-scale integration timeline by a non-Rust shop.

## Implications for SV2

- ASIC management controllers and Bitaxe-class miners (modest CPU, modest RAM)
  are well within Iroh's hardware envelope.
- The Kotlin/.NET FFI work is a credible existence proof for non-Rust SV2
  clients (e.g., a JS-based miner UI) running over Iroh.
- The "ticket = pubkey + addrs" pattern maps cleanly onto SV2 authority-pubkey
  publication, with the addrs giving a hint that may be invalidated as the
  pool's network changes — exactly the failure mode a DNS-pinned URL has today.
