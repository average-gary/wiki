---
title: Commit-reveal token pattern
type: concept
created: 2026-06-17
updated: 2026-06-17
confidence: high
tags: [commit-reveal, anti-cheat, kirk, manastr, nip-101p]
---

# Commit-reveal token pattern

The shared anti-cheat primitive in every project surveyed:

1. **Commit phase** — player publishes a SHA-256 hash (or other binding commitment) of
   their token data / shuffle seed / move payload to a Nostr event. Tokens / data NOT
   included.
2. **Play phase** — players act on inferred information; commitment is binding.
3. **Reveal phase** — player publishes the committed token / seed. Validator checks
   `sha256(reveal) == commitment`; mismatch is publicly signed evidence of cheating.

## Why this exists

Without commit-reveal, the first-to-publish player can wait, see the opponent's move, then
play optimally. Commit-reveal forces simultaneous decisions in an asynchronous transport.

## Implementations

| Project | Reveal target |
|---|---|
| [[raw/repos/2026-06-17-ethntuttle-kirk.md|kirk]] | Cashu Game tokens; mint validates that revealed C-values hash to challenge commitments |
| [[raw/repos/2026-06-17-ethntuttle-manastr.md|manastr]] | Cashu token secrets; SHA-256 hash committed in kind 31002, revealed later same-kind |
| [[raw/repos/2026-06-17-docnr-nostr-poker-nip101p.md|NIP-101p / nostr-poker]] | Dealer's shuffle seed — `sha256(seed \|\| canonical(seats) \|\| hand_n)` in kind 1652, revealed in kind 1658 |

## Failure modes (the unsolved part)

- **Pre-arrangement** — if two players collude before the match, commit-reveal does
  nothing (NIP-101p calls this out explicitly).
- **DoS by non-reveal** — a player who knows they've lost can refuse to reveal. Kirk +
  manastr respond with timeout-based forfeit; the reveal becomes "publish or forfeit
  stake."
- **Equivocation** — publishing different commitments to different relays. Mitigation: relay
  multi-fetch + dispute-event audit trail.

## Cryptographic note

Commit-reveal binds but does not hide if the commitment space is small. For e.g. dice rolls,
collisions are trivial to brute-force. Mitigations: salt with a server-provided nonce,
threshold-aggregate (see [[wiki/concepts/threshold-oprf-dasor|DASoR]]), or use the C-value
pattern where the commitment is to a Cashu-mint-witnessed value (forces collusion with the
mint to grind).
