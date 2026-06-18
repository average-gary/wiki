---
title: "Cashu vulnerability disclosure: keyset-ID collision + poisonous-airdrop attack"
source: https://conduition.io/code/cashu-disclosure/
type: article
tags: [cashu, security, vulnerability, nut-09, nut-13, keyset-collision, gaming-implications]
fetched: 2026-06-17
confidence: high
credibility: high
quality_score: 5
relevance: direct
direction: opposes
summary: |
  conduition.io disclosure showing NUT-13's deterministic-secret derivation reduces 64-bit
  keyset IDs to a 31-bit secret-derivation space (`% (2**31 - 1)`), enabling collision-grinding
  by an attacker who runs a malicious mint. Combined with NUT-09 restore, the attacker can fork
  a victim's coin: airdrops pre-poisoned tokens to the victim, who swaps them at the target
  mint with reused secrets/blinding factors, after which the attacker queries `/v1/restore` on
  the target and harvests blind signatures it can redeem. Fix requires a protocol-level
  keyset-ID v2 (HMAC compartmentalization).
---

# Cashu Vulnerability Disclosure (conduition)

## Source

- URL: https://conduition.io/code/cashu-disclosure/
- Author: conduition
- Quality: 5 (gold-standard technical critique)

## Findings

- **Keyset-ID collisions are exploitable.** NUT-13 reduces 64-bit keyset IDs to a 31-bit integer
  space (`% (2**31 − 1)`) for deterministic-secret derivation. An attacker can grind a malicious
  mint with a colliding keyset against a target mint.
- **Poisonous-airdrop attack** — malicious mint airdrops tokens; victim swaps them; victim
  reuses the same secrets / blinding factors against the target mint due to the collision.
  Attacker queries the target's NUT-09 `/v1/restore` to harvest blind signatures on those same
  blinded messages.
- **Silent coin-fork**: victim ends up holding proofs that look valid but are replayable
  against the target mint by the attacker.
- **NUT-13** has no requirement that mints validate keyset IDs — so mints can pick arbitrary
  IDs.
- **Fix**: protocol change — HMAC-based compartmentalization, "keyset ID v2."

## Why this matters for nostr-ecash gaming

Any gaming protocol that treats Cashu proofs as escrow inherits this attack surface. The
specific NUTs implicated (NUT-09 restore + NUT-13 deterministic secrets) are precisely the
ones used in any practical game flow that needs to recover state, replay tokens, or operate
across mint upgrades. The kirk / nutchain / manastr designs all rely on these primitives.

## Quotes

> "An attacker can grind a malicious mint with a colliding keyset ID against any target mint."
>
> "On overage the code logs an error and returns success anyway, marking proofs as spent — so
> the loss is invisible to users until the mint becomes insolvent." (companion finding from
> the "Rug the Mints" disclosure — see separate raw source.)
