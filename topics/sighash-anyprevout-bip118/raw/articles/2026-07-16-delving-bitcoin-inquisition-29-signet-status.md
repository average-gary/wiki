---
title: "Bitcoin Inquisition 29.1 / 29.2 — APO signet deployment status (ajtowns, Delving Bitcoin)"
source: "https://delvingbitcoin.org/t/bitcoin-inquisition-29-1/2019"
type: articles
ingested: 2026-07-16
tags: [bitcoin-inquisition, signet, anyprevout, ctv, op-cat, csfs, activation-status, ajtowns, delving-bitcoin]
summary: "Primary status snapshots from BIP-118 co-author AJ Towns. BIP-118 APO has been active on the default public Bitcoin Inquisition signet since block 106704 (2022-09-06, via PR#84), bundled with CTV (BIP-119), OP_CAT (BIP-347), CSFS (BIP-348), OP_INTERNALKEY (BIP-349), and (in 29.2, Feb 2026) BIP-54 Consensus Cleanup. APO remains signet-only experimental as of Feb 2026; no mainnet activation."
---

# Bitcoin Inquisition 29.1 / 29.2 — APO signet deployment status

Primary posts by **AJ Towns (ajtowns)**, BIP-118 co-author.
Second URL: https://delvingbitcoin.org/t/bitcoin-inqusition-29-2/2236 (29.2, 2026-02-07).

## 29.1 (2025-09-30)

- **BIP-118 SIGHASH_ANYPREVOUT has been active on the default (public) Inquisition
  signet since block 106704, dated 2022-09-06** (added via PR#84). This is the
  concrete "anyprevout signet" deployment.
- Inquisition signet bundles five consensus features: BIP-118 (APO), BIP-119 (CTV),
  BIP-347 (OP_CAT, active 2024-04-30), BIP-348 (CSFS), BIP-349 (OP_INTERNALKEY).
- Built on Bitcoin Core 29.1; explicitly for experimental signet consensus research,
  not mainnet.

## 29.2 (2026-02-07 — most recent snapshot)

- Base Bitcoin Core 29.3rc2; still carries **BIP-118 APO** alongside CTV, OP_CAT,
  CSFS, OP_INTERNALKEY, and now **BIP-54 Consensus Cleanup**.
- Timeline: APO + CTV active on signet since Sept 2022; OP_CAT + CSFS activated April
  2025; BIP-54 triggered for activation ~Feb 2026.
- Confirms APO remains a signet-only experimental feature as of Feb 2026;
  transactions using these features only relay among Inquisition-compatible nodes.

## Bottom line

APO is **not on mainnet** but **is deployed and testable on Bitcoin Inquisition
signet**, maintained by co-author AJ Towns.
