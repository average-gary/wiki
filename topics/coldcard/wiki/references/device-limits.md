---
title: "Device limits"
category: reference
sources:
  - raw/articles/2026-08-10-coldcard-limitations.md
  - raw/articles/2026-08-10-coldcard-secure-elements.md
  - raw/articles/2026-08-10-coldcard-nfc-coldcard.md
  - raw/articles/2026-08-10-coldcard-spending-policy.md
  - raw/articles/2026-08-10-coldcard-msg-signing.md
created: 2026-08-10
updated: 2026-08-10
tags: [coldcard, limits, limitations, psbt-size, multisig, sighash, microsd, bbqr, secure-notes, reference]
aliases: ["limitations", "maximum sizes", "MAX_PATH_DEPTH", "15 co-signers"]
confidence: high
volatility: warm
verified: 2026-08-10
summary: "Every documented hard ceiling and refusal, in tables: PSBT and transaction sizes by model, the 15-co-signer scriptSig limit, PIN length range, MicroSD and NFC and BBQr sizes, SIGHASH policy, fee-rejection thresholds, address-search depth, Secure Notes fields, and the change-output script requirements matrix. Also records the known-false-negative cases where the device answers wrongly rather than erroring."
---

# Device limits

> Coinkite publishes a `limitations.md` and this article is mostly a restatement of it, organised for
> lookup. Two things make it worth reading rather than skimming: several limits are **refusals** rather
> than ceilings (coinbase transactions, `SIGHASH_NONE`, high fees), and a handful of cases produce a
> **wrong answer rather than an error**, which is the more dangerous category.

Version-gated behaviour is noted where the source gives it. Where no model is named, the limit applies
across the line.

## Seeds and keys

| Limit | Value |
|-------|-------|
| BIP-39 import word counts | **12, 18 or 24** |
| BIP-39 wordlist | **English only** |
| BIP-39 passphrase length | **100** characters |
| XPRV import | assumed **top-level**; parent fingerprint and depth **not stored** |
| SLIP-132 keys | readable, but the **implied address format is stripped** |
| `MAX_PATH_DEPTH` | **12** |
| USB show-address subkey path | ≤ **16** levels (incl. master fingerprint) |
| Duress wallets | from **24- or 12-word** seeds only |
| XFP uniqueness | **required** across multisig co-signers |

## PINs

| Limit | Value |
|-------|-------|
| PIN sizes | **2-2 through 6-6** (prefix-suffix), digits only |
| Reserved | `999999-999999` was reserved for 'clear pin'; **now available again** |
| Failed attempts before brick | **13** |
| Trick PIN slots | **14**; Mk4 avoids slot 10 → **13**; Q → **14** |
| Duress Trick PIN cost | **2** contiguous slots (**3** for legacy duress) |
| Delta Mode PIN | must be the **same length** as the true PIN and differ only in the **final 4** positions |
| Fast Wipe MCU key slots | **256** (lifetime) |

## Transactions

| Limit | Mk3 | Mk4 / Mk5 / Q |
|-------|-----|---------------|
| Max PSBT size | **384 k** | **2 M** |
| Max inputs | **20** | any, bounded by the 100 k final txn |
| Max outputs | **250** | any, bounded by the 100 k final txn |
| Tested at | — | **250 inputs + 2000 outputs** |
| Minimum outputs | ≥ **1** | ≥ **1** |

Refusals and policies:

- **Coinbase transactions are refused outright.**
- Fees **> 10 %** are rejected (setting: 10 % / 25 % / 50 % / no limit); fees **> 5 %** warn (formerly
  1 %).
- **SIGHASH**: all six types supported; anything other than `ALL` warns; **`NONE` and
  `NONE|ANYONECANPAY` are rejected by default** (a setting allows them).
- **No U2F / WebUSB** — native applications only.

## Multisig

| Limit | Value |
|-------|-------|
| Max co-signers | **15** — imposed by the **1650-byte `scriptSig`** limit |
| Consensus would allow | 20 (and caps each stack element at **520 bytes**) — Coldcard still stops at 15 for segwit too |
| Multisig wallets per PSBT | **exactly one** |
| Mk3 storage | 8 M-of-3 wallets, **or** one M-of-15 |
| Signatures per pass | **one per input** |
| Change outputs | must match the **active** wallet |
| Wallet name | printable ASCII, `range(32,127)` |
| Non-standard scripts | not supported |

Finalization depends on the medium:

| Medium | Result |
|--------|--------|
| MicroSD / Virtual Disk | **both** a signed PSBT and a finalized txn |
| QR / NFC | finalized txn if complete, else signed PSBT |
| USB | signed PSBT unless `--finalize` is passed |

### BIP-67 sorting

| Route | Produces |
|-------|----------|
| PSBT import | `sortedmulti` only |
| Coldcard as coordinator | always `sortedmulti` |
| Coldcard text format | `sortedmulti` only |
| **BIP-383 descriptor import** | the way to get `multi(...)` |

Consequences: a backup containing `multi(...)` **must only be restored on firmware that supports
`multi()`**; `wsh(multi(2,B,A))` is rejected as a duplicate of `wsh(multi(2,A,B))`; two wallets
differing **only** in BIP-67 sorting are likewise duplicates.

## Change-output script requirements

What a PSBT must supply for an output to be recognised as change:

| Output type | `redeemScript` | `witnessScript` |
|-------------|----------------|-----------------|
| `p2pkh` | — | — |
| `p2wpkh-p2sh` | required: `0x00 + 0x14 + HASH160(key)` | — |
| `p2wpkh` | — | — |
| `p2sh` | required, ends `0xAE` | — |
| `p2wsh-p2sh` | optional but **must be correct** if present: `0x00 + 0x20 + sha256(witnessScript)` | **required** |
| `p2wsh` | — | **required** |

P2PK code exists but is **untested and unused**.

## Storage and transports

| Limit | Value |
|-------|-------|
| MicroSD capacity | ≤ **32 GB** (**8 GB or smaller recommended**) |
| NFC NDEF payload | ≤ **8000** bytes |
| PushTX URL | approaches 8000 bytes against ~4 k server/phone limits |
| BBQr payload | ≤ **2 MiB** |
| BBQr progress display | per-part when ≤ **14** parts, otherwise a percentage |
| Signature file (`Verify Sig File`) | ≈ **10 kB** |
| Debug USB serial | disabled by default; **even when enabled it only echoes output and accepts no input** — use the hardware port |

### QR auto-detection (Q)

Recognised: PSBT (base64 or hex), wire transaction (base64 or hex), XPRV/XPUB, addresses, BIP-21 URIs,
seed words (truncated or full), **SeedQR — but not Compact SeedQR**.

Not recognised: **binary QR**. A bad-checksum payload is shown as text. Pasting into a secure note is
assumed complete at **>60 characters**.

## Secure Notes (Q)

| Limit | Value |
|-------|-------|
| Password entropy | F1–F5 give ≥ **126 bits**, **except F3 ≈ 48 bits** |
| Title / Sitename / Username | ≤ **32** characters |
| Password field | ≤ **128** characters |
| Note text | unlimited — but **large notes degrade performance system-wide** |
| Cross-model restore | **a Q backup restored on Mk4 loses its notes** |

## Spending Policy

| Limit | Value |
|-------|-------|
| Whitelist | **25** addresses |
| Cosign key C | **12 or 24 words only** — not an XPRV |
| Velocity | max magnitude per txn **plus** a minimum block-height gap from the previous `nLockTime` |
| Web2FA devices | any number enrolled, but **all share one secret** |
| PSBT warnings | **any** warning (e.g. huge fees) causes rejection |

Two operational traps here. The PSBT creator **must set `nLockTime`** for velocity to work. And
velocity counts from signing, not broadcasting: **sign but never broadcast and you still wait out the
policy**.

## Answers that are wrong rather than absent

The category worth knowing about, because nothing surfaces an error:

- **Address ownership search** covers only the first **1528** addresses (**764 per keychain**).
  Unexplored sub-accounts are not searched.
- It **does not search the Seed Vault** at all.
- **XFP collisions inside the Seed Vault** — two entries with the same fingerprint — produce **false
  negatives**.
- No **real-time clock**: backup metadata carries the **firmware release date**, not the current date.
- On restore, "forgotten" PINs are not restored, any Trick PIN matching the restored true PIN is
  **dropped**, and a Delta Mode PIN incompatible with the new true PIN is **dropped**.

## Development

Building the firmware is supported on **macOS and Linux only**.

## Evidence status

`confidence: high` — these are Coinkite's own published limits, mostly numeric, and many are
independently checkable (the 1650-byte `scriptSig` limit, the 520-byte stack-element cap, BIP-67, the
BIP-383 descriptor route). `volatility: warm` rather than `cold` because limits are exactly the kind of
value that moves between releases: the fee-warning threshold already changed from 1 % to 5 %, and the
Mk3-to-Mk4 PSBT jump shows the pattern. Untested claims are labelled as such upstream (the P2PK path)
and the "tested 250 in / 2000 out" figure is a test result, not a bound.

## See Also

- [[coldcard-overview|COLDCARD — overview]] ([COLDCARD — overview](../topics/coldcard-overview.md)) — product context for the model split
- [[airgap-signing-workflows|Air-gapped signing workflows]] ([Air-gapped signing workflows](../topics/airgap-signing-workflows.md)) — the workflows these ceilings constrain
- [[signing-formats|Signing formats and standards]] ([Signing formats and standards](signing-formats.md)) — the formats and BIPs referenced above
- [[model-and-version-matrix|Model and version matrix]] ([Model and version matrix](model-and-version-matrix.md)) — per-model capability differences
- [[memory-map-and-key-slots|Memory map and key slots]] ([Memory map and key slots](memory-map-and-key-slots.md)) — where the 256 key slots and 14 SE2 pages live
- [[spending-policy-and-two-factor|Spending Policy and two-factor]] ([Spending Policy and two-factor](../concepts/spending-policy-and-two-factor.md)) — the policy limits in context
- [[trick-pins-and-duress-wallets|Trick PINs and duress wallets]] ([Trick PINs and duress wallets](../concepts/trick-pins-and-duress-wallets.md)) — slot accounting and restore behaviour
- [[pin-entry-and-rate-limiting|PIN entry and rate limiting]] ([PIN entry and rate limiting](../concepts/pin-entry-and-rate-limiting.md)) — PIN sizes and the 13-attempt brick
- [[seed-generation-and-derivation|Seed generation and derivation]] ([Seed generation and derivation](../concepts/seed-generation-and-derivation.md)) — import rules and path depth
- [[connectivity-and-nfc|Connectivity and NFC]] ([Connectivity and NFC](../concepts/connectivity-and-nfc.md)) — the NDEF and URL size ceilings
- [[encrypted-backup-and-transfer|Encrypted backup and transfer]] ([Encrypted backup and transfer](../concepts/encrypted-backup-and-transfer.md)) — what a backup does and does not carry across models
- [[release-timeline|Release timeline]] ([Release timeline](release-timeline.md)) — when limits changed

## Sources

- [Limitations](../../raw/articles/2026-08-10-coldcard-limitations.md) — the great majority of this article: seeds, PINs, transaction sizes, multisig, BIP-67, SIGHASH, fees, change-script matrix, storage, QR detection, Secure Notes, address search, spending policy
- [Dual secure elements](../../raw/articles/2026-08-10-coldcard-secure-elements.md) — 256 replaceable MCU keys, 14 SE2 slots, 13-attempt counter
- [NFC](../../raw/articles/2026-08-10-coldcard-nfc-coldcard.md) — the 8 kB NDEF ceiling
- [Spending Policy](../../raw/articles/2026-08-10-coldcard-spending-policy.md) — whitelist size and policy restrictions
- [Message signing](../../raw/articles/2026-08-10-coldcard-msg-signing.md) — the ~10 kB signature-file limit
