---
title: "Cashu mining application — delvingbitcoin/t/870 (EthnTuttle May 2024)"
publication: delvingbitcoin.org
url: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870
date: 2024-05
type: article
ingested: 2026-05-24
quality: 5
credibility: high
confidence: high
tags: [Cashu, eHash, EthnTuttle, NUT-02, keyset, Calle, primary]
---

# Ecash TIDES using Cashu and Stratum v2 (delvingbitcoin/t/870)

The canonical technical proposal that introduced **eHash** to the Bitcoin mining-payout discussion. EthnTuttle authored it; thread continued into January 2025 with **Calle (Cashu creator), vnprc (later hashpool implementer), Matt Corallo, davidcaseria** participating.

## The central reinterpretation: keyset = difficulty target

Cashu NUT-02 keysets are normally power-of-two sat denominations. EthnTuttle's proposal:

> Each public key in the keyset corresponds to a **difficulty target** rather than a sat denomination.

A blinded signature is "valued" by the difficulty target it commits to. TIDES (the OCEAN payout scheme) uses that target as the weighting function for payout. **This is the central mining-specific re-interpretation of Cashu** — no new NUT required.

## Keyset rotation drives epochs

The pool rotates the active keyset on:
- (a) block-find, OR
- (b) network difficulty adjustment

Each epoch's eHash tokens are a claim on **that epoch's** block rewards. Keyset rotation effectively imposes a time-bucketed "Proof of Liabilities" structure on the mint.

This is the design that hashpool implemented, with the addition of **accumulating melt quotes** for the on-chain redemption path.

## Calle's direct endorsement (paraphrased)

> "Your approach is more simple and doesn't require the mint operator to store outstanding blind messages."

The Cashu creator publicly validated that the eHash variant **avoids state bloat in the mint** by treating each share submission as ephemeral rather than persisting B_ values.

## Critiques on record

- **1440000bytes**: regulator/custodial-mixer risk for the mint operator
- **MattCorallo**: questioned whether faster-than-PPLNS payout velocity actually matters operationally
- **davidcaseria**: pushed for clarity on multi-redemption mechanics

vnprc later constrained the design to **"one redemption per eHash token"** specifically because tokens are not linkable back to underlying shares post-blinding.

## NUTs reused (no new NUT proposed)

- **NUT-00** (BDHKE) — core blind-signature mechanics
- **NUT-02** (keysets) — repurposed (sat denomination → difficulty target)
- **NUT-04 / NUT-05** (mint / melt) — issuance and Lightning redemption boundaries
- **NUT-10 / NUT-11** (P2PK spending conditions) — let pools restrict redemption
- **NUT-12** (DLEQ proofs) — cryptographic non-repudiation for tokens

The mining-specific extension lives in **Stratum V2 message extensions**, not in a new NUT.

## Significance

This thread is the **conceptual antecedent of hashpool**. EthnTuttle authored the design (May 2024); vnprc began implementing it as `vnprc/hashpool` in November 2024 (six months later); the project has since advanced to v0.1.1 (March 2026) on testnet4 with the architecture broadly faithful to the original proposal.

## Sources

- delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870 (primary)
- Cashu NUT-12: https://github.com/cashubtc/nuts/blob/main/12.md
- Cashu NUTs index: https://github.com/cashubtc/nuts

## See also

- [[2026-05-24-ethntuttle-profile|EthnTuttle profile]]
- [[2026-05-24-vnprc-profile|vnprc profile]]
- [[../../wiki/concepts/ehash|eHash concept]]
- [[../repos/2026-05-23-cashu-nuts|Cashu NUTs (existing wiki article)]]
