---
title: "Kernel Bypass Surgery: A Viable Procedure for Maximizing QUIC Bandwidth?"
source_url: https://zirngibl.github.io/files/spaeth2026quicbypass.pdf
type: paper
date: 2026
authors: ["Späth et al."]
venue: IEEE NOMS 2026 (TUM / MPI)
credibility: high
quality: 5
relevance: indirect
tags: [quic, performance, ceiling, dpdk, contrarian]
ingested: 2026-05-20
---

# QUIC Performance Ceiling (Späth et al., NOMS 2026)

Peer-reviewed evidence that QUIC's userspace design imposes a structural
performance ceiling vs. kernel TCP that only DPDK / SR-IOV / GSO+GRO can close.

## Headline numbers

- Without kernel offload, four leading QUIC stacks (MsQuic, LSQUIC, quiche,
  picoquic) span **2.2–8.3 Gbit/s goodput**.
- Only **1 of 4 supports both GSO and GRO**.
- DPDK kernel-bypass lifts goodput up to **3× (LSQUIC, to 10.8 Gbit/s)** —
  baseline QUIC leaves 50–70% of NIC capacity on the floor.
- DPDK requires **exclusive NIC access** — impractical for multi-tenant pool
  ingress; SR-IOV virtual-function workaround necessary.
- DPDK-mode QUIC produces **burstier traffic**: CDF shows 99% of packets sent
  back-to-back vs. 50% spaced ≥2.9µs in kernel mode.

## Verbatim

> "A significant bottleneck arises from frequent context switches caused by the
> interaction with the kernel's socket interface for data transmission. This is
> intensified in QUIC, where functionalities formerly handled by the kernel's
> transport layer, such as acknowledgments, are implemented in user space."

> "Packet I/O has been identified as a primary performance bottleneck for QUIC
> implementations."

> "DPDK requires full NIC access, making it impractical, especially for the
> client side."

## Companion: SIGCOMM EPIQ 2020 (Yang/Eggert/Ott)

- Citing Google/Langley et al.: **"QUIC burns 3.5× more CPU cycles than
  TCP+TLS."**
- Single-connection POSIX-socket QUIC: 325–489 Mbit/s; netmap kernel-bypass:
  4121 Mbit/s — 10× gap.
- Data copies between user/kernel space: ~50% of CPU. With kernel-bypass, crypto
  becomes 40%+.
- 1% packet reorder rate: throughput collapse 3–5× for some QUIC stacks.

## Implications for SV2 over Iroh

- **For a typical miner**: traffic volume is tiny (a few KB/sec of shares + new
  templates). The per-packet CPU penalty is irrelevant. Iroh wins on connection
  resilience, not throughput.
- **For pool ingress**: a top-10 pool aggregating O(10⁵) miners pushes
  multi-Gbps inbound. The Quinn/noq stack (which Iroh uses) is in the same
  family as the four tested stacks — plan for ~50% extra CPU vs. TCP at the
  same workload, or invest in NIC offload.
- **Reordering sensitivity**: 1% reorder rate halves throughput on some QUIC
  stacks. Mining traffic over heterogeneous WAN paths is plausibly exposed.
  Mitigation: keep QUIC streams short (per-share, per-template) so reordering
  resets quickly.
- **Pool sizing rule of thumb**: budget 2–3× the CPU you'd use for SV2-over-TCP
  to handle the same number of miners over Iroh. This is offset by removing
  Noise_NX work if `PlainIrohConnection` mode is used.
