---
title: "PIN entry and rate limiting"
category: concept
sources:
  - raw/articles/2026-08-10-coldcard-pin-entry.md
  - raw/articles/2026-08-10-coldcard-secure-elements.md
  - raw/articles/2026-08-10-coldcard-security-model.md
  - raw/articles/2026-08-10-coldcard-menu-tree.md
created: 2026-08-10
updated: 2026-08-10
tags: [coldcard, pin, rate-limiting, key-stretching, hmac-sha256, brute-force, login-countdown, atecc608]
aliases: ["Coldcard PIN", "prefix suffix PIN", "13 attempts brick"]
confidence: medium
volatility: cold
verified: 2026-08-10
summary: "How the Coldcard checks a PIN and what stops an attacker guessing: the prefix/suffix split, the double-SHA256-over-pairing-secret hash, Mk3+ key stretching against usage-limited secure-element keys, the ~4 second measured cost per attempt, the 13-attempt hard brick, and the pre-Mk3 punitive delay table. Also the login countdown and Kill Key. Confidence medium: first-party design documentation."
---

# PIN entry and rate limiting

> A Coldcard PIN is entered in two halves. Between them the device shows you two BIP-39 words derived
> from the first half — the anti-phishing check. After the second half, an attempt is *committed*
> before it is evaluated, so guessing costs you one of a small, hard-limited budget.

## Entry sequence

1. Type the **prefix** (the digits before the dash).
2. The device shows two BIP-39 anti-phishing words. Verifying them is the user's job; a wrong pair
   means this is not your device or its state has changed. See
   [[anti-phishing-words|Anti-phishing words]] ([Anti-phishing words](anti-phishing-words.md)).
3. Type the **suffix**.
4. The device evaluates, in this order: **brick-me PIN**, then duress PINs, then increment the attempt
   counter, then the real PIN.

That ordering carries the design intent. The brick-me PIN is checked **first, before any Trick PIN or
the real PIN, and with no delay** — it destroys the pairing secret in roughly 50ms so that a
coerced user can render the device useless faster than an observer can intervene. And the attempt
counter is incremented **before** the real PIN is checked, so an interrupted or power-cut attempt
still costs an attempt.

On Q, `Calculator Login` replaces the PIN screen with a working calculator; you enter `12-12` or
`12 12` to log in, and `12-` to see anti-phishing words. From 1.3.4Q, a Q that would otherwise be
e-waste after 13 failures enters "forever calculator" mode regardless of that setting.

## The hash construction

The stored PIN value is:

```
SHA256( SHA256( pairing_secret ‖ purpose_salt ‖ pin_digits ) )
```

with a 32-byte pairing secret and a 4-byte purpose salt. Two documented purpose constants:

- `PURPOSE_NORMAL = hex('58184d33')`
- `PURPOSE_WORDS  = hex('73676d2e')` (the anti-phishing derivation)

Because the pairing secret is per-device and lives in PCROP-protected flash, the same PIN on two
Coldcards produces different values — no cross-device rainbow table.

## Key stretching (Mk3 and later)

Mk3 introduced the 608A and with it two stretching passes, both performed *by the secure element*:

1. HMAC-SHA256 against a key known **only to the 608a** — so the work cannot be replicated off-chip
   at all, at any speed.
2. HMAC-SHA256 again against a **usage-limited** key — one whose permitted use count the element
   itself enforces.

The pseudocode's iteration parameters:

```
KDF_ITER_WORDS = 12
KDF_ITER_PIN   = 8
final = SHA256( pairing_secret ‖ start ‖ 0x04 ‖ md )
```

**Documented inconsistency:** the pseudocode says `KDF_ITER_WORDS = 12` while the surrounding prose
says the anti-phishing derivation uses 16 iterations (≈2 seconds). Both appear in
`docs/pin-entry.md` at this revision. The discrepancy is upstream and is recorded here rather than
resolved by guessing; treat the exact iteration count for the words path as uncertain and the
order-of-magnitude cost (~2s) as the reliable figure.

## What an attempt actually costs

The document does the arithmetic and then reports the measurement, which is the more useful number:

| Quantity | Value |
|----------|-------|
| 608a bus | single-wire, 230400 bps |
| Bytes per iteration | ~220 → ≈8ms on the wire |
| Chip-side compute | ≥22ms |
| Per iteration | ≈30ms |
| 8 iterations, theoretical | ≈240ms |
| **8 iterations, measured** | **~4 seconds** |
| Anti-phishing (16 iterations) | ≈2 seconds |

The order-of-magnitude gap between theory and measurement is the interesting part: the practical
rate limit is far stronger than the bus arithmetic alone predicts.

## The hard limit: 13 attempts

Mk3 and later **brick themselves after 13 incorrect PINs**. Not "lock out", not "delay" — the device
becomes e-waste. This is announced with heavy on-screen warnings from 3.0.1 onward. A **correct PIN
resets the counter to 13.**

This replaced a graduated punitive-delay scheme. Pre-Mk3, failures earned:

| Failures | Delay |
|----------|-------|
| 1–2 | 15 seconds |
| 3–4 | 1 minute |
| 5–9 | 5 minutes |
| 10–19 | 30 minutes |
| 20–49 | 2 hours |
| 50+ | 8 hours |

Mk2's retry rate limiting was 150ms × 10 attempts, then 2.5s × 15, crashing at 25; Mk3 fixed it at
2 seconds. Delays are enforced **inside the bootloader** in 500ms increments, against an HMAC'ed
structure carrying a per-boot value so a recorded delay-complete token cannot be replayed.

## Login countdown

An orthogonal, user-chosen delay: enter the correct PIN, wait out a countdown of minutes to 28 days,
then enter it correctly a *second* time. Options run 5 minutes to "28 days later". Two properties
that changed over time:

- From 4.0.2 (Mk3) the countdown **survives power-off** and continues on next power-up.
- From 5.0.0, **powering down during the countdown resets the timer to full** — forcing an attacker
  (or you) to start over. That is a deliberate strengthening of the earlier behaviour.

Continuous power is required for the whole period. A "Countdown and Brick" variant (4.0.2, Mk3 only)
shows a normal-looking countdown while the device is already bricked, or alternatively consumes all
but the final PIN attempt.

## Kill Key

Off by default. A single keypress during login that immediately wipes the seed. On Q any letter can
be assigned, and it remains active throughout the login process — a fast destructive action available
before authentication completes.

## Secondary wallet: removed

Pre-Mk3 the device supported four wallets (main, secondary, duress, brick-me). Mk3 removed the
secondary wallet because the 608A provides only **one** usage-limited counter, and the secondary PIN
would have needed its own. BIP-39 passphrases became the recommended replacement — a better answer
anyway, being unlimited in number and leaving no on-device trace.

## Evidence status

`confidence: medium`. This is a first-party description of a rate-limiting design, and the most
security-critical numbers in it (the ~4 second measurement, the usage-limited key enforcement) are
Coinkite's own measurements of Coinkite's own hardware. The 13-attempt brick is corroborated by the
3.0.1 changelog entry, which is stronger evidence.

Not addressed by these documents: whether Trick PIN attempts interact with the main PIN's attempt
counter — i.e. whether a duress or countdown PIN can be used to exhaust or manipulate the budget.

## See Also

- [[security-architecture|Security architecture]] ([Security architecture](../topics/security-architecture.md)) — why all rate limiting lives in SE1
- [[dual-secure-element-design|Dual secure-element design]] ([Dual secure-element design](dual-secure-element-design.md)) — SE2 cannot validate a PIN, which is why this article is about SE1
- [[anti-phishing-words|Anti-phishing words]] ([Anti-phishing words](anti-phishing-words.md)) — the two words shown mid-entry
- [[trick-pins-and-duress-wallets|Trick PINs and duress wallets]] ([Trick PINs and duress wallets](trick-pins-and-duress-wallets.md)) — the alternate PINs checked during this same sequence
- [[coldcard-overview|COLDCARD — overview]] ([COLDCARD — overview](../topics/coldcard-overview.md)) — product and generation context
- [[memory-map-and-key-slots|Memory map and key slots]] ([Memory map and key slots](../references/memory-map-and-key-slots.md)) — the 508a/608a key-layout tables
- [[release-timeline|Release timeline]] ([Release timeline](../references/release-timeline.md)) — when the countdown, Kill Key and calculator login shipped
- [[device-limits|Device limits]] ([Device limits](../references/device-limits.md)) — PIN sizes and the 13-attempt brick
- [[spending-policy-and-two-factor|Spending Policy and two-factor]] ([Spending Policy and two-factor](spending-policy-and-two-factor.md)) — MicroSD 2FA hooks into this login sequence

## Sources

- [PIN entry](../../raw/articles/2026-08-10-coldcard-pin-entry.md) — entry sequence, hash construction, stretching, rate-limit arithmetic and measurement, delay tables
- [Secure elements](../../raw/articles/2026-08-10-coldcard-secure-elements.md) — attempt counter reset, SE2's 6ms unrestricted rate
- [Security model](../../raw/articles/2026-08-10-coldcard-security-model.md) — login countdown, Kill Key
- [Menu tree](../../raw/articles/2026-08-10-coldcard-menu-tree.md) — Login Settings menu and countdown options
