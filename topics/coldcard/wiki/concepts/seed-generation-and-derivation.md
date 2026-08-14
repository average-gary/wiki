---
title: "Seed generation and derivation"
category: concept
sources:
  - raw/articles/2026-08-10-coldcard-firmware-readme.md
  - raw/articles/2026-08-10-coldcard-limitations.md
  - raw/articles/2026-08-10-coldcard-bip85-passwords.md
  - raw/articles/2026-08-10-coldcard-temporary-seeds.md
  - raw/articles/2026-08-10-coldcard-security-model.md
  - raw/articles/2026-08-10-coldcard-release-history-mk3.md
  - raw/articles/2026-08-10-coldcard-release-history-mk4-mk5.md
created: 2026-08-10
updated: 2026-08-10
tags: [coldcard, seed-generation, trng, dice-rolls, bip-39, bip-32, bip-85, xprv, lock-down-seed, entropy]
aliases: ["dice rolls", "BIP-85", "Lock Down Seed", "seed words"]
confidence: medium
volatility: warm
verified: 2026-08-10
summary: "Where a Coldcard's master secret comes from — TRNG, dice rolls, imported words, XPRV — and everything derived from it: BIP-39 passphrases, BIP-85 children (seeds, XPRVs, passwords, WIFs), duress wallets at reserved indices, and Lock Down Seed's irreversible XPRV conversion. Read alongside the 2026 entropy advisory, which is about exactly this path."
---

# Seed generation and derivation

> This is the article the **2026 entropy advisory** is about. Everything below describes how the master
> secret is produced and what hangs off it — and for firmware between 2021 and July 2026, the
> device-generated case was defective. Read
> [[entropy-advisory-2026|The 2026 entropy advisory]]
> ([The 2026 entropy advisory](entropy-advisory-2026.md)) **first**.

## Sources of a master secret

| Route | Notes |
|-------|-------|
| **TRNG** | the device's true random number generator; the default path |
| **Dice rolls** | user-supplied physical entropy, `seed = sha256(rolls as ascii)` |
| **Word import** | 12, 18 or 24 words, **English wordlist only**; BIP-39 passwords supported during import |
| **XPRV import** | a BIP-32 HD root private key; assumed top-level, parent fingerprint and depth **not stored** |
| **Tapsigner backup** | via the temporary-seed path |
| **Seed XOR restore** | recombining N parts — see [[seed-xor\|Seed XOR]] ([Seed XOR](seed-xor.md)) |
| **BIP-85 derivation** | a child of an existing master secret |

SLIP-132 keys (`xprv`/`yprv`/`zprv`) are accepted on import but the **implied address format is
stripped** — the device stores xpubs in BIP-32 format regardless, reading SLIP-132 when offered. The
5.4.1 export toggle between BIP-32 and "obsolete" SLIP-132 output is the mirror of that policy.

### Dice rolls

Added in **2.1.1** with the construction `seed = sha256(rolls as ascii)` and a recommendation of ≥99
rolls for 256 bits. **5.1.0** turned that into enforcement with statistical minimums:

| Words | Minimum rolls |
|-------|---------------|
| 12 | 50 |
| 24 | 99 |

Each roll contributes about **2.5 bits**, per the README's own arithmetic. Note what dice do and do not
fix: they bound how badly a user can under-supply entropy, and they are the mitigation the advisory
points to — but the roll-to-seed step still runs in firmware.

## BIP-39 passphrase

Introduced in **2.0.1**, up to **100 characters**. Two facts that matter more than the feature itself:

- From **5.2.0** the passphrase is **implemented internally as a temporary seed**, so it inherits that
  machinery — Seed Vault storage, per-wallet settings, the `[xfp]` home-menu indicator. See
  [[temporary-seeds-and-seed-vault|Temporary seeds and Seed Vault]]
  ([Temporary seeds and Seed Vault](temporary-seeds-and-seed-vault.md)).
- As a mitigation for a weak master seed it only contributes **its own** entropy. It does not repair
  the seed underneath.

Passphrases were also Coinkite's stated replacement for the **secondary wallet** removed at Mk3 — an
unlimited number of them, with no on-device trace. See
[[pin-entry-and-rate-limiting|PIN entry and rate limiting]]
([PIN entry and rate limiting](pin-entry-and-rate-limiting.md)).

## Lock Down Seed

`Advanced/Tools > Danger Zone > Seed Functions > Lock Down Seed`, from **2.0.1**. It cooks the master
seed and the active BIP-39 passphrase together into an **XPRV** and stores *that* as the master secret,
replacing the seed phrase. **This cannot be reversed.**

Why you would: other funds on the same words become unreachable from this device, so a Spending Policy
confined to this wallet really is confined. Cost: in XPRV mode the `Passphrase` menu item disappears
entirely, because BIP-39 passwords cannot apply to an XPRV secret. See
[[spending-policy-and-two-factor|Spending Policy and two-factor]]
([Spending Policy and two-factor](spending-policy-and-two-factor.md)).

## BIP-85

Introduced in **3.1.4**. `Advanced/Tools > Derive Seed B85` derives deterministic children from the
master secret. Available types:

- **12 / 18 / 24 words** — usable as a temporary seed
- **XPRV (BIP-32)** — usable as a temporary seed
- **Passwords** (BIP-85 PWD BASE64)
- **WIF** — the WIF Store arrived in 5.5.0, with watch-only descriptor export in 5.5.1

Only word-based and XPRV-based children can be activated as temporary seeds; passwords and WIFs cannot.

### Reserved duress indices

Duress wallets are BIP-85 children at fixed indices, which is what makes them reproducible from a
backup:

| Words | Reserved indices |
|-------|-----------------|
| 24 | 1001, 1002, 1003 |
| 12 | 2001, 2002, 2003 |

Duress wallets are supported only from 24- or 12-word phrases. A legacy path also exists: a 72-byte
duress secret at `m/2147431408'/0'/0'`, where `2147431408 = 0x80000000 - 0xCC10`. See
[[trick-pins-and-duress-wallets|Trick PINs and duress wallets]]
([Trick PINs and duress wallets](trick-pins-and-duress-wallets.md)).

### BIP-85 passwords and keyboard emulation

Added in **5.0.5** (Mk4/Mk5 5.0.5+, or any Q), requiring a **data-capable USB-C cable** — Coinkite's
own power-only cable will not do.

- Derivation is **BIP-85 PWD BASE64**, at `m/83696968'/707764'/21'/<index>'`.
- **Length is fixed at 21 characters**, giving ~**126 bits** of entropy. You cannot choose the length;
  Coinkite's reasoning is that 126 bits is on par with Bitcoin's own security model.
- Up to **10,000** indices.
- `Settings > Keyboard EMU > Enable` adds **Type Passwords** below Address Explorer. Selecting it
  switches USB into keyboard mode (`Switching...`), you pick an index, review the path and password on
  screen, place the cursor in the target field and press OK to send the keystrokes **plus Enter**.
  Exiting restores normal USB mode if it was on before, otherwise leaves USB disabled.
- Viewing without typing: `Advanced/Tools > Derive Seed B85 > Passwords`, which also offers `(1)` save
  to MicroSD **in cleartext**, `(2)` Virtual Disk, `(3)` NFC, `(4)` QR, `(6)` send keystrokes.

**The keyboard-layout trap**, documented with an example: keystrokes are interpreted by the *host's*
keyboard layout. The host must be **QWERTY** including the number row. On a German (QWERTZ) layout the
correct password `zYLoepugzdVJvdL56ogNV` is typed as `yZLoepugydVJvdL56ogNV` — y and z swapped. The
device is still deterministic (same index → same keystrokes) but **BIP-85 is no longer respected**, so
the password you can regenerate from the seed elsewhere will not match the one you set. Also noted:
KeePass2 2.45 on Ubuntu mistypes capitals due to the high-speed typing; use KeePassXC.

## Derivation and path policy

- **`MAX_PATH_DEPTH` = 12** (set in 3.0.2). Deeper paths are refused.
- For USB "show address" on multisig, subkey paths are limited to **16 levels** including the master
  fingerprint.
- Every co-signer's derivation path must be known and consistent with the PSBT.
- **XFP** (master fingerprint) display switched to network byte order in **2.1.0** — `0x0f056943`
  became `4369050F`. Old exports may show the other convention.
- **Duplicate XFPs are blocked** (3.2.1) and XFPs **must be unique** across multisig co-signers. An XFP
  of zero is accepted from 5.0.0 with a warning.

## Fingerprint collisions bite in practice

Worth surfacing because it produces silent wrong answers rather than errors: the address-ownership
search does **not** cover Seed Vault entries, and if two Seed Vault wallets share an XFP (same
descriptors, different seeds) you get **false negatives**. See
[[device-limits|Device limits]] ([Device limits](../references/device-limits.md)).

## Destroying a secret

- **`Destroy Seed`** — clears the seed, all settings, Seed Vault entries, Secure Notes and (from
  5.4.2/1.3.2Q) all Trick PINs from SE2. Effectively a factory reset that leaves the main PIN.
- **Fast Wipe** — advances the replaceable MCU key slot, making the stored ciphertext permanently
  undecryptable. 256 slots. See
  [[dual-secure-element-design|Dual secure-element design]]
  ([Dual secure-element design](dual-secure-element-design.md)).
- **Nuke Device** — 5.5.0/1.4.0Q, under Danger Zone.
- **Lock Down Seed** — not destruction, but irreversible.

## Evidence status

`confidence: medium`, `volatility: warm`. The derivation paths, index reservations, path-depth limits
and the fixed 21-character password length are precise and mostly checkable against the BIPs. What is
*not* established by these sources is the quality of the entropy at the top of the chain — which is
exactly what the 2026 advisory concerns, and why this article is `warm` rather than `cold`: the
generation path was under active change at the pinned revision. The BIP-85 password specification is
cited to a **fork** (`scgbckbone/bips`, `passwords` branch) rather than to the merged BIP text, so that
addition's standardisation status is not settled by what is here.

## See Also

- [[entropy-advisory-2026|The 2026 entropy advisory]] ([The 2026 entropy advisory](entropy-advisory-2026.md)) — the live defect in this exact path
- [[seed-xor|Seed XOR]] ([Seed XOR](seed-xor.md)) — splitting and recombining a seed
- [[temporary-seeds-and-seed-vault|Temporary seeds and Seed Vault]] ([Temporary seeds and Seed Vault](temporary-seeds-and-seed-vault.md)) — BIP-39 passphrase as a temporary seed, and BIP-85 activation
- [[trick-pins-and-duress-wallets|Trick PINs and duress wallets]] ([Trick PINs and duress wallets](trick-pins-and-duress-wallets.md)) — the reserved duress indices
- [[encrypted-backup-and-transfer|Encrypted backup and transfer]] ([Encrypted backup and transfer](encrypted-backup-and-transfer.md)) — what `mnemonic`, `xprv` and `raw_secret` mean in a backup
- [[dual-secure-element-design|Dual secure-element design]] ([Dual secure-element design](dual-secure-element-design.md)) — where the master secret is stored and how it is wiped
- [[spending-policy-and-two-factor|Spending Policy and two-factor]] ([Spending Policy and two-factor](spending-policy-and-two-factor.md)) — Lock Down Seed before setting a policy
- [[connectivity-and-nfc|Connectivity and NFC]] ([Connectivity and NFC](connectivity-and-nfc.md)) — USB keyboard emulation and the cleartext export options
- [[coldcard-overview|COLDCARD — overview]] ([COLDCARD — overview](../topics/coldcard-overview.md)) — product context
- [[device-limits|Device limits]] ([Device limits](../references/device-limits.md)) — path depth, wordlist and import constraints
- [[signing-formats|Signing formats and standards]] ([Signing formats and standards](../references/signing-formats.md)) — XFP conventions and key-origin export formats
- [[release-timeline|Release timeline]] ([Release timeline](../references/release-timeline.md)) — 2.1.1 dice, 3.1.4 BIP-85, 5.0.5 passwords, 5.1.0 roll minimums

## Sources

- [Firmware README](../../raw/articles/2026-08-10-coldcard-firmware-readme.md) — the advisory, dice-roll entropy arithmetic, BIP-39 passphrase mitigation caveat
- [Limitations](../../raw/articles/2026-08-10-coldcard-limitations.md) — BIP-39 and XPRV import rules, `MAX_PATH_DEPTH`, XFP uniqueness, duress word-length support, address-ownership collision false negatives
- [BIP-85 passwords](../../raw/articles/2026-08-10-coldcard-bip85-passwords.md) — PWD BASE64 path, fixed length 21 / ~126 bits, 10,000 indices, keyboard EMU flow, QWERTY layout trap, KeePass2 incompatibility
- [Temporary seeds](../../raw/articles/2026-08-10-coldcard-temporary-seeds.md) — which BIP-85 types can be activated, passphrase-as-temporary-seed
- [Security model](../../raw/articles/2026-08-10-coldcard-security-model.md) — reserved BIP-85 duress indices and the legacy duress path
- [Mk3 release history](../../raw/articles/2026-08-10-coldcard-release-history-mk3.md) — 2.0.1 passphrase and Lock Down Seed, 2.1.0 XFP byte order, 2.1.1 dice, 3.0.2 path depth, 3.1.4 BIP-85, 3.2.1 duplicate XFP block
- [Mk4/Mk5 release history](../../raw/articles/2026-08-10-coldcard-release-history-mk4-mk5.md) — 5.0.5 BIP-85 passwords and keyboard EMU, 5.1.0 dice minimums, 5.4.1 SLIP-132 toggle, 5.5.0 WIF Store
