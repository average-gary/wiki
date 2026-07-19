---
title: "Bitcoin Covenant Proposals Compared: CTV, APO, OP_CAT (Spark)"
source: "https://www.spark.money/tools/bitcoin-covenant-proposals-compared"
type: articles
ingested: 2026-07-16
tags: [covenant-comparison, ctv, anyprevout, op-cat, lnhance, csfs, op-vault, activation-status, secondary-source, unverified-numbers]
summary: "A structured covenant comparison table (commit-to / soft-fork / activation / use-cases / recursion) for CTV, APO, OP_CAT, TXHASH (BIP-346), OP_VAULT. Use-case matrix: CTV does vaults/congestion-control but NOT LN-Symmetry; APO does LN-Symmetry/watchtowers but NOT vaults/congestion-control; CTV+CSFS (LNHANCE) does all of them except recursion; only OP_CAT enables recursion. NOTE: specific 2026 activation numbers (CTV signaling window 2026-03-30, 0% miner support May 2026, ~1000 APO signet txs) are unverified secondary claims — treat as low-confidence."
---

# Bitcoin Covenant Proposals Compared: CTV, APO, OP_CAT (Spark)

Secondary comparison source. Useful for the comparison-table dimensions; **specific
activation numbers/dates are unverified — flagged low-confidence.**

## Use-case matrix (structural, higher confidence)

- **CTV** does vaults / congestion-control / timeout-trees but **NOT** LN-Symmetry.
- **APO** does LN-Symmetry / watchtowers but **NOT** vaults / congestion-control.
- **CTV+CSFS ("LNHANCE")** does all of them except recursive covenants.
- Only **OP_CAT** enables recursion.
- **LNHANCE bundle** = CTV (BIP-119) + CSFS (BIP-348, OP_CHECKSIGFROMSTACK) +
  OP_INTERNALKEY; described as "the frontrunner combination among core developers for a
  potential soft fork."

## Activation status claims (LOW CONFIDENCE — unverified secondary)

- CTV — signaling window opened 2026-03-30 (timeout 2027-03-30), 0% miner support as
  of May 2026.
- APO — live on Bitcoin Inquisition signet since late 2022 (~1,000 test txs), no
  mainnet.
- OP_CAT (BIP-347) spec "Complete" Mar 2026, no mainnet attempt.
- **OP_VAULT (BIP-345) formally withdrawn May 2025, superseded by BIP-443
  OP_CHECKCONTRACTVERIFY.**

> These dated figures come from a single secondary source and should be verified
> against primary data (Delving Bitcoin / Optech) before being cited as fact. The
> ~1,000-signet-tx figure is corroborated qualitatively by ajtowns' signet-activity
> post (see the CTV/APO/CAT-signet-activity raw source).
