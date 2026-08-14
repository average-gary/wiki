---
title: "Anti-phishing words"
category: concept
sources:
  - raw/articles/2026-08-10-coldcard-pin-entry.md
  - raw/articles/2026-08-10-coldcard-security-model.md
created: 2026-08-10
updated: 2026-08-10
tags: [coldcard, anti-phishing, evil-maid, bip-39, hmac-sha256, pin, device-substitution]
aliases: ["two words", "PIN prefix words", "Coldcard evil maid check"]
confidence: medium
volatility: cold
verified: 2026-08-10
summary: "Two BIP-39 words derived from your PIN prefix and a per-chip 256-bit key, shown before you type the rest of your PIN. A substituted or reflashed device cannot reproduce them, so they detect device swapping and evil-maid tampering. Covers the derivation, the ~4 million-combination search space, and the honest limits of the scheme."
---

# Anti-phishing words

> A counterfeit Coldcard can copy the case, the screen and the menus. It cannot show you the right two
> words, because producing them requires a secret held inside *your* device's secure element. Type
> only the first half of your PIN, look at the words, and stop if they are wrong.

## Derivation

The words come from the PIN **prefix** only — the digits before the dash — so they can be shown before
you commit the secret half:

1. `SHA256(prefix)`.
2. `HMAC-SHA256` (Coinkite cites FIPS-198-1) against a **256-bit key unique to that secure-element
   chip**, performed inside the element. The purpose salt for this path is
   `PURPOSE_WORDS = hex('73676d2e')`.
3. Take the **upper 22 bits** of the result.
4. Split into two 11-bit indices, each selecting a word from the BIP-39 wordlist.

22 bits gives **~4 million** possible word pairs (2048 × 2048). The derivation runs the same
key-stretching machinery as a PIN attempt — the prose puts it at 16 iterations, roughly 2 seconds,
which is also what makes it costly to farm.

## What it detects

The threat is device substitution: an attacker replaces your Coldcard with a lookalike that records
your PIN. Because the per-chip key never leaves the secure element and the attacker cannot extract it
from your original, their device cannot compute your word pair. Options open to them are all bad:

- Show *some* pair and hope you do not remember yours — you memorised two words, so this fails.
- Show nothing or an error — visibly wrong.
- Try to brute-force the pair — the derivation is rate-limited and the search space is ~4 million.

The same mechanism also flags a device whose flash has been altered, because the words path is bound
to the pairing secret alongside the genuine-light checksum. See
[[firmware-authenticity-and-upgrades|Firmware authenticity and upgrades]]
([Firmware authenticity and upgrades](firmware-authenticity-and-upgrades.md)).

## Honest limits

The scheme is elegant but narrow, and worth stating precisely:

- **It only works if the user actually checks.** There is no enforcement — the device shows the words
  and proceeds. A user who taps through learns nothing.
- **It requires the user to have memorised the pair**, which is an extra secret to remember alongside
  the PIN, and one that changes if the prefix changes.
- **It is per-prefix.** Different prefixes give different pairs, so a user who mistypes the prefix
  sees an unfamiliar pair and may misread it as an attack rather than as their own typo.
- **It protects the PIN, not the seed.** A successful check tells you it is safe to type the suffix.
  It says nothing about what the firmware does afterwards — that is the code-signing and genuine-light
  layer's job.
- **The Q's calculator login** reaches the words with `12-` (prefix then dash), which is a discoverable
  convention rather than a hidden one.

## Practical note

The words are shown between the two halves of PIN entry, which is also where the login delay and, on
pre-Mk3 devices, the punitive delay were felt. So on those devices "wait, then read two words, then
type the rest" is the normal login rhythm. See
[[pin-entry-and-rate-limiting|PIN entry and rate limiting]]
([PIN entry and rate limiting](pin-entry-and-rate-limiting.md)).

## Evidence status

`confidence: medium`. The construction is documented first-party and internally consistent; the
security argument (a counterfeit cannot compute the pair) follows if and only if the per-chip key is
genuinely unextractable, which rests on the secure element's own guarantees and is not independently
audited in these sources.

## See Also

- [[pin-entry-and-rate-limiting|PIN entry and rate limiting]] ([PIN entry and rate limiting](pin-entry-and-rate-limiting.md)) — the login sequence these words sit inside
- [[security-architecture|Security architecture]] ([Security architecture](../topics/security-architecture.md)) — where device-substitution detection fits among the layers
- [[dual-secure-element-design|Dual secure-element design]] ([Dual secure-element design](dual-secure-element-design.md)) — the per-chip key lives in SE1
- [[firmware-authenticity-and-upgrades|Firmware authenticity and upgrades]] ([Firmware authenticity and upgrades](firmware-authenticity-and-upgrades.md)) — the complementary check on the code that runs after login
- [[coldcard-overview|COLDCARD — overview]] ([COLDCARD — overview](../topics/coldcard-overview.md)) — product context
- [[memory-map-and-key-slots|Memory map and key slots]] ([Memory map and key slots](../references/memory-map-and-key-slots.md)) — the SE1 `pin stretch` slot this shares with PIN entry

## Sources

- [PIN entry](../../raw/articles/2026-08-10-coldcard-pin-entry.md) — derivation steps, FIPS-198-1 HMAC, 22-bit truncation, ~4M combinations, iteration cost
- [Security model](../../raw/articles/2026-08-10-coldcard-security-model.md) — the anti-phishing words in the broader login design
