---
title: "CTV+CSFS: Can we reach consensus on a first step towards covenants? (Delving Bitcoin)"
source: "https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509"
type: articles
ingested: 2026-07-16
tags: [ctv, csfs, lnhance, anyprevout, ln-symmetry, activation-debate, steven-roose, ajtowns, delving-bitcoin]
summary: "March 2025 Delving Bitcoin thread (Steven Roose, AJ Towns) on the covenant activation path. The live debate centers on CTV+CSFS ('LNHANCE') as the 'first step,' NOT standalone APO activation. Roose argues CTV+CSFS is 'an equivalent for SIGHASH_ANYPREVOUT' enabling re-bindable signatures / LN-Symmetry (but only emulates the ALL variant, costing extra witness bytes). APO co-author AJ Towns is skeptical CTV+CSFS truly substitutes for APO."
---

# CTV+CSFS: Can we reach consensus on a first step towards covenants?

Delving Bitcoin thread, March 2025 (Steven Roose, AJ Towns, and others).

## Key points

- The active covenant activation debate centers on **CTV+CSFS ("LNHANCE")** as the
  "first step," NOT on activating APO alone — there is currently **no standalone APO
  activation proposal**.
- **Steven Roose** argues CTV+CSFS is "an equivalent for SIGHASH_ANYPREVOUT," enabling
  re-bindable signatures / Lightning Symmetry — but only emulates APO's **ALL variant**
  and costs **extra witness bytes**.
- **AJ Towns (APO co-author) is skeptical**: existing eltoo/LN-Symmetry research used
  APO plus the annex and custom relay rules, and no one has reproduced those results
  under CTV+CSFS.
- Core dispute: **theoretical equivalence vs. demonstrated production utility.**

This is the crux of why standalone APO has lost mainnet momentum: its flagship use
case (eltoo/LN-Symmetry) can arguably be delivered via CTV+CSFS without introducing a
new sighash flag — but that equivalence is contested by APO's own author.
