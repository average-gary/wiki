---
title: NUT-11 P2PK reward-locking
type: concept
created: 2026-06-17
updated: 2026-06-17
confidence: high
tags: [cashu, nut-11, p2pk, schnorr, reward, kirk]
---

# NUT-11 P2PK reward-locking

[[raw/articles/2026-06-17-cashu-nuts-10-11-12-14-programmable-primitives.md|NUT-11]] adds a
**Pay-to-Public-Key** spending condition to a Cashu Proof: the proof is spendable only when
accompanied by a valid Schnorr signature over the proof's secret using the locking pubkey.

## Why this matters for gaming

- A **reward token** can be locked to the **winner's pubkey** at the moment of issuance
- Only the legitimate winner can spend it — even if the token leaks (e.g. if the mint
  prematurely publishes the unblinded value), no one else can redeem it
- The same Schnorr key the player uses for [[wiki/concepts/hash-linked-event-chain|Nostr
  event signing]] (NIP-01) co-binds to the P2PK lock — **one key, two layers**

## Capabilities NUT-11 brings

- **Single-key lock** (the basic case)
- **n-of-m multisig** via `pubkeys` + `n_sigs` tags — shared in-game item ownership
- **Locktime + refund** — `locktime`, `refund` pubkeys, `n_sigs_refund` — match-stake
  expiry / time-bounded escrow
- **Signature flags**:
  - `SIG_INPUTS` — per-input signatures
  - `SIG_ALL` — single signature covers ALL inputs and outputs (atomic state transition)

## Implementations

- [[raw/repos/2026-06-17-ethntuttle-kirk.md|kirk]] — reward tokens are NUT-11 P2PK-locked to
  the winner. `RewardTokenState` enum: `Locked` / `Unlocked`.
- [[raw/repos/2026-06-17-cashu-casino-and-other-cashu-games-survey.md|Cashu Casino, Monopoly,
  spacenut, etc.]] — **do not** use NUT-11. They treat ecash as a payment rail, not as a
  bearer asset bound to a player. This is the gap kirk fills.

## Hard caveat

NUT-11 doesn't help if the mint itself goes insolvent — the
[[raw/articles/2026-06-17-rug-the-mints-fee-bypass-nutshell-lnbits.md|fee-bypass attack]]
and [[raw/articles/2026-06-17-cashu-vulnerabilities-keyset-collision-and-poisonous-airdrop.md|keyset-collision attack]]
both attack at lower layers than spending conditions. P2PK is necessary, not sufficient.

## See also

- [[wiki/concepts/mint-as-referee]]
- Hub topic [[../../../fedimint/_index|fedimint]] for federation alternatives
