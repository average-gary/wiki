---
title: "iroh for payments — Paycode case study (iroh blog)"
source: https://www.iroh.computer/blog/paycode
type: article
tags: [iroh, paycode, qr-pairing, ticket, production, dotnet, kotlin]
date: 2026-06-01
publication_date: 2026-03-26
quality: 5
confidence: high
agent: 3
summary: "Dated 2026-03-26. Paycode connects payment terminals to POS at Mexican highway toll booths via iroh — no servers, full PCI compliance posture. QR codes encode iroh tickets (NodeId + relay info); gossip-based discovery establishes peer connections. Integration spans Rust core wrapped into a .NET 6 SDK for Windows 7 terminals, plus Kotlin POS app — a polyglot embedding pattern. Hardware: dual-core Intel CPUs up to 8 GB RAM, mixed Ethernet/Wi-Fi."
---

# Paycode — production iroh + QR pairing

Rare named, dated production iroh deployment with hardware specs and a QR-ticket pairing pattern.

## Deployment

- **Use case**: Mexican highway toll booth payment terminals talking to POS systems
- **Compliance**: PCI compliance posture (sensitive card data over iroh)
- **Topology**: serverless — terminals and POS systems peer-to-peer via iroh
- **Discovery**: gossip-based after initial QR pairing

## QR pairing pattern

- QR codes encode iroh tickets (NodeId + relay info)
- Initial scan establishes the trust + endpoint addressing
- After scan: gossip discovery handles ongoing connectivity

This is the same `EndpointTicket::from_str` → dial pattern available in any iroh app today.

## Polyglot embedding

| Side          | Stack |
|---------------|-------|
| Core protocol | Rust  |
| Windows 7 terminals | .NET 6 SDK (NuGet) wrapping the Rust core |
| POS application | Kotlin |

A multi-language deployment pattern — one Rust core, multiple FFI surfaces.

## Hardware profile (relevant to GTX 1060 server)

- Dual-core Intel CPUs
- Up to 8 GB RAM
- Mixed Ethernet / Wi-Fi
- Windows 7 era hardware

→ Iroh runs on this class of box. The GTX 1060 server (i7-7700HQ, 16 GB) has 2-4× the headroom.

## Operator quote

> "iroh was super easy to use… I started hacking and was able to integrate it into our Kotlin PoS app and have a published .NET NuGet package."
> — Carlos Diez, Head of Mobile/Front-end at Paycode

## What this validates for an Iroh AI server

1. **QR-ticket pairing is production-ready** — Paycode does it for payment terminals
2. **Polyglot FFI works** — Rust core + .NET/Kotlin bindings are realistic
3. **Mid-tier x86 hardware is sufficient** — no special CPU requirements beyond what BLAKE3 prefers (AVX2 helps but isn't required)
4. **Serverless mesh is real** — no central coordination beyond the iroh relays

## See also

- [[2026-06-01-iroh-tickets-security-model]] — what tickets do and don't guarantee
- [[2026-06-01-awesome-iroh]] — other shipping iroh apps
