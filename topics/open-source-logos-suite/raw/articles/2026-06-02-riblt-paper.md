---
title: "Rateless Invertible Bloom Lookup Tables (Yang, Gilad, Alizadeh — SIGCOMM 2024)"
url: https://arxiv.org/abs/2402.02668
retrieved: 2026-06-02
type: spec
---

Academic paper underlying the RIBLT primitive Keyhive uses for membership and document-set reconciliation. Authors: Lei Yang, Yossi Gilad, Mohammad Alizadeh; submitted Feb 2024; published in ACM SIGCOMM 2024 (Sydney, August 2024). Headline result: a "novel encoder that incrementally encodes the set difference into an infinite stream of coded symbols, resembling rateless error-correcting codes." Versus prior IBLT schemes: 3–4× lower communication cost at similar CPU, or 2–2000× lower CPU at similar bandwidth. Real-world benchmark on Ethereum mempool sync delivered 5.6× lower end-to-end completion time and 4.4× lower communication cost vs the production system. The "rateless" property is the operational win: peers don't need to estimate set difference up front, they just keep streaming symbols until decoding succeeds — making it robust to unknown / variable peer divergence.
