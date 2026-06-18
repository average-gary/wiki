---
title: "EthnTuttle/nutchain — Nostr-based game engine spec with FROST threshold randomness"
source: https://github.com/EthnTuttle/nutchain
type: repo
tags: [nostr, cashu, gaming, cryptography, threshold-randomness, decentralized, ecash, frost, threshold-oprf, game-engine, spec]
fetched: 2026-06-17
confidence: high
summary: |
  NutChain is a draft design specification for a turn-based game engine built on Nostr events
  and threshold cryptography. It enables fully self-sovereign gameplay via a hash-linked chain
  of signed Nostr events, using a Threshold OPRF (Oblivious Pseudorandom Function) over
  Cashu's BDHKE blind signature scheme for unbiasable distributed randomness. Specification-only
  (no implementation in this repo); sister repos `kirk` and `manastr` carry the implementation.
---

# EthnTuttle/nutchain

> **Repository purpose**: Specification document for a Nostr-event-sourced turn-based game
> engine with threshold-cryptographic distributed randomness. The repo contains a single
> ~61 KB README (the spec); no implementation code lives here.

## Repo Metadata

| Field | Value |
|---|---|
| Owner | EthnTuttle |
| Repo | nutchain |
| Default branch | `master` |
| Last commit | 2026-03-09 (`24918c9` "update") |
| Total commits | 6 |
| License | None specified |
| Language | Markdown (spec only) |
| Size | ~61 KB |
| Stars / Forks | 0 / 0 |

## Mission / Intent

NutChain proposes a **cryptographic game engine** that combines:

- **Nostr events** as the message bus and ordered transcript (hash-linked, signed)
- **Threshold cryptography** for distributed randomness, so no single player can bias outcomes
- **Cashu's BDHKE blind signature** primitive lifted into a **Threshold OPRF** (RFC 9497 + JKKX17)
- **ChillDKG** (Blockstream Research BIP draft) for distributed key generation without a trusted dealer

The result: turn-based gameplay where every state transition is a verifiable, ordered Nostr
event, and any randomness used in the game is bound to a public commitment from the requesting
player and cannot be ground or biased by any single party.

> "Verifiable, ordered game state via a hash-linked Nostr event chain" — Fully self-sovereign
> gameplay without trusted intermediaries.
>
> "Unbiasable randomness via Cashu's BDHKE blinding scheme extended to a Threshold OPRF across
> the player set."

## Architecture

### Three-phase game lifecycle

1. **Setup** — game creation, player confirmation, Distributed Key Generation (ChillDKG), launch
2. **Gameplay** — players publish moves (`GAME_ACTION` events), request randomness when needed,
   maintain optional private state via commit-reveal pairs
3. **Teardown** — game conclusion + result events recorded on the event chain

### Nostr event schema

- **14 event kinds** in the addressable range `30800–30814`
- Each event references its predecessor via the `e` tag → hash-linked chain
- Sequence numbers enforce strict event ordering
- Domain separation across event kinds (setup / gameplay / DKG / randomness request / etc.)

### Cryptographic stack

| Component | Source | Purpose |
|---|---|---|
| BDHKE | Cashu | Single-signer blind signature foundation |
| ChillDKG | Blockstream Research (BIP draft) | DKG without trusted dealer |
| DLEQ proofs | Chaum-Pedersen | Verify partial responses without revealing secrets |
| Threshold OPRF | RFC 9497 + JKKX17 | Distributed randomness across players |
| SHA-256 + domain separation | Standard | Commitment / hash binding |

### Threshold fault tolerance

`t = floor(2n/3) + 1` (Byzantine majority).
- n ≤ 3: unanimity required
- n=4: tolerates 1 offline player
- n=7: tolerates 2 offline

## Repository structure

The repo contains exactly one file:

```
nutchain/
└── README.md (60,789 bytes)
```

No `Cargo.toml` / `package.json` / source / tests / CI. **Specification stage**, no
implementation.

## Dependencies

None (specification only). Reference set:

- Cashu BDHKE — https://cashu.space/
- ChillDKG BIP draft (Blockstream Research)
- RFC 9497 (OPRF)
- Fedimint (referenced as inspiration)

## Relationship to sister repos

- **kirk** ([EthnTuttle/kirk](https://github.com/EthnTuttle/kirk)) — Rust impl of the trustless
  gaming protocol; uses CDK (Cashu Dev Kit) + `nostr-sdk` v0.35; commit-reveal with Cashu
  tokens. Active (last touched 2026-01-29; 23 commits, ~432 KB).
- **manastr** ([EthnTuttle/manastr](https://github.com/EthnTuttle/manastr)) — Full multiplayer
  strategy game; Rust (96.8 %), workspace-organized (`shared-game-logic`, `game-engine-bot`,
  `integration_tests`, `service-orchestrator`); zero-coordination architecture (game engine
  validates only). Active (last touched 2025-08-26; 53 commits, ~1.3 MB).

**Working hypothesis** (refined as kirk/manastr ingests complete):
- nutchain = abstract cryptographic spec
- kirk = library/protocol Rust impl
- manastr = production reference game on top

## Commit history

| Date | SHA | Message |
|---|---|---|
| 2026-03-09 | 24918c9 | update |
| 2026-03-04 | 8cf6818 | Fix evaluation point security issue, DAG refs, game_id bootstrap, addressable event semantics |
| 2026-03-03 | 3271c46 | Fix 12 inaccuracies: ChillDKG, event kind collisions, NIP-01 compliance, hash_to_curve, verification, domain separation |
| 2026-03-03 | 606fb58 | Add references section with academic literature and standards |
| 2026-03-03 | 3a53ee1 | Refactor spec: correct FROST/TOPRF distinction, expand DKG and signing detail |
| 2026-03-01 | d8c6b05 | Initial spec: NutChain game engine |

Pattern: an intense refinement burst in early March 2026 around cryptographic correctness
(FROST vs TOPRF, evaluation-point security, domain separation, NIP-01 compliance).

## Status & quality

| Dimension | Assessment |
|---|---|
| Stage | Specification / design (pre-implementation in this repo) |
| Recency | Active — last commit 2026-03-09 |
| Maturity | Explicitly draft; calls for "formal security review" before production |
| CI / tests | None |
| Documentation | Excellent — comprehensive single-file spec with TOC, refs, threat model, explicit limitations |
| README quality | Outstanding |

## Key quotes

> "Deterministic Authoritative Source of Randomness (DASoR): [Players] collectively hold
> authority over randomness generation, with threshold-of-participants signatures serving as
> commitments and responses to random challenges."

> "No single player can bias the outcome. The requesting player cannot grind favorable results
> because the commitment is public and precedes responses. Co-signers cannot influence the
> output because they sign blinded messages."

> "Every game produces a linear, hash-linked sequence of Nostr events. Each event references
> its predecessor via the `e` tag and carries an incrementing sequence number. This structure
> makes the entire game history tamper-evident and verifiable by any observer."

> "Known Limitation: The composability guarantee for ChillDKG with Threshold OPRF (rather than
> FROST signing) remains unproven. While ChillDKG is proven secure with FROST, careful further
> consideration is needed for other schemes. Since NutChain is a game engine with no financial
> custody at stake, this is considered acceptable."

## Wiki extraction notes

- Concept articles to derive: **DASoR** (deterministic authoritative source of randomness),
  **threshold OPRF over BDHKE**, **hash-linked Nostr event chain**, **NutChain event-kind range
  (30800–30814)**, **ChillDKG-for-games**, **Byzantine-threshold game roster**.
- Cross-reference: fedimint (BDHKE/blind signatures), clink-protocol (Nostr-as-transport), other
  Cashu work.
