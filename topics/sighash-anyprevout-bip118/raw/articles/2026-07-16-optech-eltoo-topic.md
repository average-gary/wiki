---
title: "Bitcoin Optech — eltoo topic"
source: "https://bitcoinops.org/en/topics/eltoo/"
type: articles
ingested: 2026-07-16
tags: [optech, eltoo, ln-symmetry, anyprevout, pinning, channel-factories, signet]
summary: "Optech's curated eltoo topic. Broadcasting an old state costs only fees (no penalty/toxic-waste loss); nodes store only the latest state. Benefits: reduces backup-failure risk, simplifies multi-party channels and channel factories, enables storage-limited devices. Depends on SIGHASH_ANYPREVOUT (BIP-118). Documents the LN-Symmetry rename (~2024) and transaction-introspection work to mitigate pinning."
---

# Bitcoin Optech — eltoo topic

## Key points

- In eltoo, broadcasting an old state costs only transaction fees (no penalty /
  toxic-waste loss); nodes need only store the latest state.
- Benefits: reduces risk from node/backup failures, simplifies **multi-party
  channels** and **channel factories**, and lets storage-limited devices (hardware
  wallets) safely participate.
- Depends on `SIGHASH_ANYPREVOUT` (BIP-118).
- Ongoing work addresses transaction introspection to mitigate **pinning attacks**.
- Documents the rename to **LN-Symmetry** (increasingly used from ~2024); tracks
  signet testing and a research implementation (results reported Jan 2024).
