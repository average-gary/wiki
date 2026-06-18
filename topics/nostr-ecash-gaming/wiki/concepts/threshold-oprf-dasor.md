---
title: Threshold-OPRF DASoR
type: concept
created: 2026-06-17
updated: 2026-06-17
confidence: high
tags: [nutchain, threshold-cryptography, oprf, frost, chilldkg, randomness, dasor]
---

# Threshold-OPRF DASoR

DASoR — **Deterministic Authoritative Source of Randomness** — is
[[raw/repos/2026-06-17-ethntuttle-nutchain.md|nutchain]]'s design for unbiasable distributed
randomness in P2P games where there is no central referee.

## Construction

1. Players run **ChillDKG** (Blockstream Research draft BIP) at game start to produce a
   joint group key without a trusted dealer. Sub-protocols: SimplPedPop + EncPedPop +
   CertEq.
2. When a game step needs randomness, the requesting player publishes a **public commitment**
   to a Nostr event (binds the request, prevents grinding).
3. A threshold of t = floor(2n/3) + 1 players co-sign a **blinded message** using their key
   shares — a Threshold OPRF over Cashu's BDHKE primitive.
4. **Lagrange interpolation** combines the partial responses into the unbiasable seed.

## Properties

- **No single player can bias**. A threshold collusion is required.
- **The requesting player cannot grind**. The commitment is public and pre-dates the
  responses.
- **Co-signers cannot influence the output**. They sign blinded messages without seeing the
  secret (this is the OPRF property — same trick Cashu's mint uses for note issuance,
  here lifted into a threshold setting).
- **Publicly verifiable**. DLEQ proofs (Chaum-Pedersen) certify each partial response.

## Threshold table

| n (players) | t (threshold) | Tolerates offline |
|---|---|---|
| 3 or fewer | n (unanimity) | 0 |
| 4 | 3 | 1 |
| 7 | 5 | 2 |

## Known limitation

ChillDKG is proven secure with **FROST signing**, not with a Threshold OPRF. The
composability in nutchain's setting is **unproven**. The author acknowledges this and
accepts it because nutchain has **no financial custody at stake** — randomness is bound to
game state only, not to ecash payouts. This is the central caveat.

## Contrast with kirk's C-value approach

[[wiki/concepts/c-value-game-piece|kirk]] uses a single Cashu mint's blind-signature C-value
as the randomness primitive — needs a trusted (or trust-shifted) mint. nutchain uses the
**player set itself** as the threshold mint, eliminating the external mint from the RNG
loop (but retaining it for any token escrow).

## Sources

- [[raw/repos/2026-06-17-ethntuttle-nutchain.md]]
- [[raw/papers/2026-06-17-chaum-blind-signatures-1982-foundational.md]] (BDHKE root)
