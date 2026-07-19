---
title: Compiled Articles
type: index
updated: 2026-07-16
---

# Compiled Articles (8)

## Categories

- [[concepts/_index|Concepts]] (5)
- [[topics/_index|Topics]] (2)
- [[references/_index|References]] (1)
- [[theses/_index|Theses]] (0)

## Contents

| File | Category | Summary | Tags | Updated |
|------|----------|---------|------|---------|
| [topics/coinbase-outpoint-presigning.md](topics/coinbase-outpoint-presigning.md) | topic | Anchor synthesis: does APO presign a spend of an unmined coinbase outpoint? Yes via prevout omission (demonstrated on-chain), but APO's amount commitment vs variable coinbase value → use APOAS or fix value; CTV is the output-side alternative; maturity is separate. | coinbase-presigning, anyprevout, apoas, ctv | 2026-07-16 |
| [topics/anyprevout-status-and-activation.md](topics/anyprevout-status-and-activation.md) | topic | Draft soft fork, not on mainnet; Inquisition signet since 2022; momentum shifted to CTV+CSFS (LNHANCE), equivalence disputed by co-author. | bip-118, activation-status, signet, lnhance | 2026-07-16 |
| [concepts/anyprevout-sighash-semantics.md](concepts/anyprevout-sighash-semantics.md) | concept | Exact APO vs APOAS omissions, flag bytes, 0x01 pubkey prefix, key_version=0x01, tapscript-only. | anyprevout, apo, apoas, sighash, taproot | 2026-07-16 |
| [concepts/rebindable-signatures.md](concepts/rebindable-signatures.md) | concept | Signatures that omit the prevout bind to a class of outputs; powerful + dangerous; floating txs as covenants. | rebindable-signatures, anyprevout, covenant | 2026-07-16 |
| [concepts/eltoo-ln-symmetry.md](concepts/eltoo-ln-symmetry.md) | concept | APO's flagship motivation; state-number channel updates vs LN-Penalty; APOAS-based PoC; pinning. | eltoo, ln-symmetry, lightning, apoas | 2026-07-16 |
| [concepts/signature-replay-and-chaperone-signatures.md](concepts/signature-replay-and-chaperone-signatures.md) | concept | Central replay risk; chaperone sigs proposed then dropped; 0x01 opt-in + tapscript scoping; not recursive. | signature-replay, chaperone-signatures, anyprevout | 2026-07-16 |
| [concepts/coinbase-maturity-and-unknown-txid.md](concepts/coinbase-maturity-and-unknown-txid.md) | concept | Unknown txid + variable value + 100-block maturity — the three properties defining the coinbase-presigning problem. | coinbase-transaction, coinbase-maturity, bip-34 | 2026-07-16 |
| [references/covenant-primitives-comparison.md](references/covenant-primitives-comparison.md) | reference | APO vs CTV vs ANYONECANPAY vs NOINPUT vs CSFS comparison + coinbase-presigning fitness. | covenant-comparison, ctv, anyonecanpay, csfs | 2026-07-16 |

## Recent Changes

- 2026-07-16: compile — 8 articles created from 19 sources (2 topics, 5 concepts, 1 reference).
