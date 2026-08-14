---
title: "Dual secure-element design"
category: concept
sources:
  - raw/articles/2026-08-10-coldcard-secure-elements.md
  - raw/articles/2026-08-10-coldcard-security-model.md
  - raw/articles/2026-08-10-coldcard-memory-map.md
  - raw/articles/2026-08-10-coldcard-bootloader-readme.md
created: 2026-08-10
updated: 2026-08-10
tags: [coldcard, secure-element, atecc608, ds28c36b, key-hierarchy, aes-256-ctr, hmac-sha256, vendor-diversity]
aliases: ["SE1 and SE2", "Coldcard split key", "ATECC608 DS28C36B"]
confidence: medium
volatility: cold
verified: 2026-08-10
summary: "On Mk4/Mk5/Q the seed is AES-256-CTR encrypted in MCU flash under a key that exists nowhere: it is HMAC-SHA256 over secrets held separately in SE1 (Microchip ATECC608), SE2 (Maxim DS28C36B) and a write-once MCU flash slot. Covers the vendor-diversity argument, the exact construction, the deliberate asymmetry that SE2 cannot validate a PIN, and Fast Wipe / Fast Brick. Confidence medium: first-party design intent, no third-party audit."
---

# Dual secure-element design

> The design goal Coinkite states: **all three of SE1, SE2 and the MCU must be compromised** before
> the master seed can be recovered. Two of the three are secure elements from *different vendors*,
> chosen so that a break in one company's part is unlikely to also be a break in the other's.

## Generational context

| Line | Secure elements |
|------|-----------------|
| Mk1, Mk2 | ATECC508A only — 72 bytes of secret behind a 4–12 digit PIN |
| Mk3 | ATECC608A only — same shape, better part, adds key stretching |
| Mk4, Mk5, Q | SE1 = ATECC608 **plus** SE2 = Maxim DS28C36B |

On Mk1–Mk3 the seed lived *inside* the single secure element. On Mk4 and later it lives encrypted in
MCU flash, and the secure elements hold **shares of the key** rather than the secret itself. That
inversion is the whole architectural change.

## The threat model this answers

The secure-elements document assumes an attacker who has opened the case, can probe the buses between
MCU and both elements, and can de-solder parts to mount an **active man-in-the-middle** on the
one-wire and I²C links. Encrypting the seed at rest in MCU flash and splitting the key means bus
observation alone yields nothing useful; the pairing secrets make MiTM insertion detectable.

## The key construction

The seed is encrypted with **AES-256-CTR**. Details as documented:

- **Key:** `k = HMAC-SHA256(key = mcu hmac key, msg = SE2 easy key ‖ SE2 hard key ‖ current replaceable mcu key)`
- **Nonce:** the first 15 bytes of the `mcu hmac key`, followed by a zero byte.
- **Integrity:** 32 zero bytes are appended and encrypted alongside, acting as the MAC; keyslot 10
  holds the check value.

Read the message carefully: two of the three inputs come from **SE2**, one from **MCU flash**. SE1
does not contribute a share of this key directly — SE1's role is authentication and rate limiting
(it holds the pairing secret and gates access to the whole flow), while SE2 and the MCU hold the
confidentiality shares. That is why "compromise all three" is the claim rather than "compromise any
two of three".

There are fifteen 32-byte slots on SE2 in the documented key table (SE serial numbers, an
`SE joiner` pubkey, an `SE2 comms` pubkey, easy/hard keys, spare secrets and the long secret among
them). Slot-level detail is tabulated in
[[memory-map-and-key-slots|Memory map and key slots]]
([Memory map and key slots](../references/memory-map-and-key-slots.md)).

## Pairing secrets

Each device holds 32-byte pairing secrets in PCROP-protected bootloader flash — at `0x0801c000`
(8k) on Mk4/Q1, `0x08007800` on Mk1–Mk3. They bind this MCU to *these* secure elements. Two
consequences the bootloader README states plainly:

- You must **wipe flash whenever you change the 508/608**, because there is no code path to erase the
  pairing secret and flash cannot be selectively rewritten.
- Dumping the pairing area on a non-production unit yields a misleading file: unused MCU key slots
  read as unprogrammed cells (all ones), and writing that back trips an assert on the next MCU key
  attempt. You must trim to the non-ones content.

"Knowledge of" a shared secret is proven without transmitting it: a `Nonce` command (20 bytes of
`numin` expanded to 32) followed by `CheckMac`, with `GenDig` used for encrypted reads and writes.

## The deliberate asymmetry: SE2 cannot validate a PIN

This is the most surprising documented property, and it is a design choice rather than a limitation
being apologised for. SE2:

- **cannot validate a PIN at all**;
- has **no rate limiting**;
- answers at roughly a **6ms** cadence.

So SE2 is unsuitable as an authentication oracle and is not used as one. All PIN validation, attempt
counting and rate limiting live in SE1 — see
[[pin-entry-and-rate-limiting|PIN entry and rate limiting]]
([PIN entry and rate limiting](pin-entry-and-rate-limiting.md)). SE2's jobs are storage: key shares,
Trick PIN slots, spare secrets, the long secret.

The security consequence is worth stating rather than glossing: **brute-force resistance rests
entirely on SE1**, while **confidentiality of the seed rests on SE2 plus the MCU**. Those are
different single points of failure for different properties.

## Trick PIN storage on SE2

Trick PINs occupy 14 slots, laid out with the PIN hash on **even** pages and its associated secret on
**odd** pages. The low bits of the stored value are masked out and repurposed as `tc_arg` and
`tc_flags` — the argument and behaviour flags for that trick. Delta Mode uses `tc_arg` to record
which four digits of the real PIN were substituted. Spare secrets are 3 × 72 bytes; the long secret
is 416 bytes (its API changed between generations).

Slot accounting is fiddly and matters in practice: Mk4 avoids slot 10, leaving 13 usable; Q has 14;
a duress wallet consumes 2 contiguous slots (3 for the legacy layout). See
[[trick-pins-and-duress-wallets|Trick PINs and duress wallets]]
([Trick PINs and duress wallets](trick-pins-and-duress-wallets.md)).

## Fast Wipe

MCU flash holds **256 write-once "replaceable MCU key" slots** (8k at `0x0801e000` on Mk4, 32-bit
slots). Because the current replaceable MCU key is an input to the seed-decryption HMAC, advancing
to the next slot renders the stored ciphertext permanently undecryptable — the seed is gone without
erasing anything large.

Properties Coinkite highlights:

- One slot is consumed per wipe, giving 256 wipes over the device's life.
- **No slot is chosen at the factory**, so a fresh unit's slot usage reveals nothing.
- The wipe happens **entirely inside the MCU with no external signalling** — an attacker watching the
  buses sees nothing that distinguishes it from ordinary operation.

The count is visible under `Advanced > Danger Zone > MCU Key Slots`.

## Fast Brick

The complement to Fast Wipe. Instead of advancing the MCU key, the device rotates **SE1's pairing
secret** to a fresh random nonce that nobody records. SE1 then cannot be talked to by this MCU, and
because the pairing secret cannot be erased or rewritten, the unit is permanently e-waste. This is
what the brick-me Trick PIN and the Kill Key invoke, and it completes in roughly 50ms.

## Evidence status

`confidence: medium`. The construction above is Coinkite's own description of its design; no
third-party audit or teardown is attached to these documents. The captured constants that *are*
independently checkable — SE serial numbers, the `SE joiner` and `SE2 comms` public keys — are
reproduced in the source doc but nothing here verifies them against silicon.

Open question worth flagging: how the SE1 attempt counter interacts with Trick PIN slots in
practice — whether a duress or countdown PIN can be used to manipulate the main PIN's attempt
accounting is not addressed by these documents.

## See Also

- [[security-architecture|Security architecture]] ([Security architecture](../topics/security-architecture.md)) — how this layer composes with the bootloader and MCU
- [[coldcard-overview|COLDCARD — overview]] ([COLDCARD — overview](../topics/coldcard-overview.md)) — product context and generation table
- [[pin-entry-and-rate-limiting|PIN entry and rate limiting]] ([PIN entry and rate limiting](pin-entry-and-rate-limiting.md)) — where SE1 carries the load SE2 cannot
- [[trick-pins-and-duress-wallets|Trick PINs and duress wallets]] ([Trick PINs and duress wallets](trick-pins-and-duress-wallets.md)) — what occupies SE2's 14 slots
- [[memory-map-and-key-slots|Memory map and key slots]] ([Memory map and key slots](../references/memory-map-and-key-slots.md)) — addresses, slot tables, PCROP regions
- [[firmware-authenticity-and-upgrades|Firmware authenticity and upgrades]] ([Firmware authenticity and upgrades](firmware-authenticity-and-upgrades.md)) — SE1 also holds the firmware world checksum
- [[anti-phishing-words|Anti-phishing words]] ([Anti-phishing words](anti-phishing-words.md)) — the `pin stretch` slot also derives the two words
- [[model-and-version-matrix|Model and version matrix]] ([Model and version matrix](../references/model-and-version-matrix.md)) — which generations have SE2 at all
- [[seed-generation-and-derivation|Seed generation and derivation]] ([Seed generation and derivation](seed-generation-and-derivation.md)) — where the master secret comes from before it is encrypted

## Sources

- [Secure elements](../../raw/articles/2026-08-10-coldcard-secure-elements.md) — threat model, key construction, 15-slot table, Fast Wipe and Fast Brick, SE2's PIN limitation
- [Security model](../../raw/articles/2026-08-10-coldcard-security-model.md) — generational shift from one element to two
- [Memory map](../../raw/articles/2026-08-10-coldcard-memory-map.md) — pairing secret and MCU key slot addresses
- [Bootloader README](../../raw/articles/2026-08-10-coldcard-bootloader-readme.md) — pairing secret handling and the wipe-on-SE-change rule
