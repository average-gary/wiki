---
title: "Encrypted backup and transfer"
category: concept
sources:
  - raw/articles/2026-08-10-coldcard-backup-files.md
  - raw/articles/2026-08-10-coldcard-key-teleport.md
  - raw/articles/2026-08-10-coldcard-release-history-mk3.md
  - raw/articles/2026-08-10-coldcard-release-history-mk4-mk5.md
  - raw/articles/2026-08-10-coldcard-release-history-q.md
created: 2026-08-10
updated: 2026-08-10
tags: [coldcard, backup, 7z, aes-256, key-teleport, ecdh, bbqr, cloning, recovery, entropy]
aliases: ["Coldcard backup file", "full backup", "Key Teleport", "Secure Device Cloning"]
confidence: high
volatility: cold
verified: 2026-08-10
summary: "Three ways secrets leave a Coldcard: the 7z AES-256 full backup encrypted under a 12-word TRNG passphrase (~132 bits), Secure Device Cloning between two units, and Key Teleport's ECDH-plus-password transfer between two Q devices. Covers the file format, the deliberately verifiable design, the layered Teleport crypto, and the stated limitations of each."
---

# Encrypted backup and transfer

> A hardware wallet that cannot export its secret is a single point of failure. Coldcard offers three
> exits, each with a different trust model: a **file** you carry, a **device-to-device clone**, and a
> **QR/NFC teleport** between two Q units. All three are deliberately built on inspectable primitives.

## The full backup file

`Advanced/Tools > Backup`. The device picks the passphrase and shows it to you; you write down 12
words.

| Property | Value |
|----------|-------|
| Container | standard **7z archive**, AES-256 in **CBC** mode |
| Key | SHA256 of the passphrase, hashed in the 7z-compatible way |
| Passphrase | **12 words** from the BIP-39 list, chosen by the device's **TRNG** |
| Claimed strength | ~**132 bits** without relying on key stretching |
| 7z extras | 16-byte salt, random 16-byte IV, a few tens of thousands of stretching rounds |
| Contents | **one** plain-text file with everything needed to recover elsewhere |

Coinkite's argument is explicit: the security rests on **key length**, not on 7z's KDF. The reasoning
is sound as far as it goes, and it is checkable — this is the point of using a standard format. Any
7z tool supporting AES256-SHA256 can open the archive; the passphrase is the words joined by single
spaces, lowercase. The docs ship a real example archive with its passphrase printed
(`spice until comfort zoo divide album erode yard inmate change quantum skate`) so you can verify the
claim yourself rather than take it.

Because the passphrase comes from the TRNG, backups made on firmware affected by the 2026 advisory
inherit its problem — see [[entropy-advisory-2026|The 2026 entropy advisory]]
([The 2026 entropy advisory](entropy-advisory-2026.md)).

### What is inside

```
# Coldcard backup file! DO NOT CHANGE.

# Private key details
mnemonic = "index abuse oil swift wolf ..."
xprv = "xprv9s21ZrQH143K2pSWq6uW4ARspjhHfzVWM1ceM2sPVJWS9QWeuHYRHbYFcL3F3199vUPFE2SpFEhxnZJKQhqbZSZxFkYCt1LJidizB8tqXM6"
raw_secret = "8272c026676defcc53c7307cd7714ee40c06f237f9000030077823457931dec785"

# Firmware version (informational)
# User preferences
```

Three sections: private key material (mnemonic, xprv, raw secret), informational firmware version,
and user settings. Either the `xprv` or the mnemonic imports into any other wallet, which is exactly
the emergency-recovery property the feature exists for.

The internal filename was the fixed string `ckcc-backup.txt` until **4.0.0**, which randomised it —
a metadata-leak fix, since 7z does not encrypt filenames. `7z l backup.7z` lists the name without a
passphrase and checks CRC32, so corruption is detectable without decrypting.

### What the backup covers

- **BIP-39 passphrase active:** the default backs up the **main** wallet, not the passphrase wallet.
  From **5.2.0** you can opt to back up the passphrase wallet too.
- **Temporary/ephemeral seed active:** the default flips — it backs up the **ephemeral** wallet
  instead of the main one. Worth knowing before you assume a backup contains your master seed.
- From 1.4.1Q, Secure Notes can be backed up **standalone** in their own encrypted file.

### Stated limitations

- Archive **filenames are not encrypted** — an observer sees there is one `word(number).txt` inside.
- The **device PIN is not preserved**.
- Coldcard reads only files it produced. Do not edit and restore; do not try to construct one.
- **Limited plausible deniability**: if compelled to decrypt, the file is obviously a Coldcard backup.
- Restored settings force USB, NFC and Virtual Disk back to **off**.
- **5.5.1/1.4.1Q fix:** a Delta Mode Trick PIN was **never restored from backup** before that
  release — see [[trick-pins-and-duress-wallets|Trick PINs and duress wallets]]
  ([Trick PINs and duress wallets](trick-pins-and-duress-wallets.md)).

## Secure Device Cloning

Introduced in **4.0.0** (Mk3): copy the seed and settings from one Coldcard to another using a
Diffie-Hellman key exchange to establish a shared secret, then **AES-256-CBC** for the transfer. It
avoids writing plaintext to the card, and unlike a backup file it does not require the user to
transcribe anything.

## Key Teleport (Q only)

Introduced in **1.3.2Q**. Purpose: move a small, very secret payload between two Q devices such that
nothing in the middle learns it. Q is required because QR is the final input path.

### The protocol

1. **Receiver** generates an EC keypair, stores it in settings, and publishes the pubkey as a QR (or
   over NFC). The pubkey is weakly encrypted under an **8-digit numeric code** that the receiver must
   convey by a *different* channel.
2. **Sender** scans the QR, is prompted for the numeric code, decrypts the pubkey, generates its own
   keypair, and does **ECDH**. Session key = `SHA256(X ‖ Y)` over the 64 bytes of the shared point's
   coordinates.
3. Sender picks an independent human-readable secret — the **"paranoid key"**, shown in the UX as
   *Teleport Password*: a random **40-bit** value displayed as **8 Base32 characters**.
4. Payload is **AES-256-CTR** encrypted under the paranoid key, then encrypted and MAC'd under the
   session key.
5. Receiver reconstructs the session key by ECDH, decrypts the outer layer, is prompted for the
   8-character password, and decrypts the inner layer.
6. Result lands in the **Seed Vault** or Secure Notes as appropriate, and the transfer keypair is
   **destroyed** — giving forward privacy.

The paranoid key is stretched with **PBKDF2-SHA512, 5000 iterations**, using the *session key as the
KDF key and the entered password as salt*, taking the upper 256 bits. Each layer carries a 2-byte
checksum (`SHA256(body)[-2:]`), so 4 bytes total overhead; length is not transmitted, so those
checksums are the only truncation defence.

### Data type codes

The first plaintext byte says what the payload is:

| Code | Payload |
|------|---------|
| `s` | 12/18/24 words, raw master, or xprv (17–72 bytes, internal format) |
| `x` | full XPRV — 4 bytes plus base58-*decoded* binary XPRV |
| `n` | one or many notes (JSON array) |
| `v` | Seed Vault export (JSON: one key plus name and source) |
| `p` | binary PSBT to be signed, possibly multisig |
| `b` | complete system backup file |

BBQr is always used, even for payloads that would fit a plain QR, and — because it is generated on
the embedded device — is always **uncompressed Base32**. Three new BBQr type codes: `R` (receiver
pubkey, 33 bytes compressed), `S` (sender pubkey ‖ data), `E` (multisig PSBT: 4-byte `randint` nonce
‖ data).

### The multisig PSBT variant

No receiver setup and **no numeric password** at all. The sender picks a random `randint` in
`0..2^28` and derives the receiver's pubkey at `.../20250317/(randint)` from the XPUB already shared
in the multisig wallet; the receiver searches its multisig wallets for a key that decrypts
successfully (checked by the inner checksum) and drops straight into signing. Coinkite recommends a
**daisy-chain** rather than a star pattern, because the device cannot arbitrarily combine partial
signatures — the signer who completes the Mth signature can finalise and, with PushTX, broadcast.

### The web component and its security argument

Teleporting a QR over NFC means handing the phone a long URL to a static site
(`keyteleport.com`, served from a public GitHub repo). The payload sits **after the `#`**, so it
never reaches GitHub's servers; JS resources carry content hashes; the site is HTTPS. The page
refuses to render anything that is not a correctly-encoded BBQr with type `R`, `S` or `E` —
deliberately, so it cannot be repurposed as a generic QR generator.

Two questions the docs answer head-on:

- **Why such short passwords?** Because they must be practical to read out over a phone call or write
  by hand. The mitigation is procedural — send the password by a different channel from the QR.
- **Is it safe to put the QR in the cloud?** Their answer is yes: the QR is ECDH-encrypted under a key
  that is destroyed after transfer (forward privacy), the cloud does not have the 8-character
  password, and the QR reveals nothing linkable to your device or coins.

### Honest weak point

The receiver's numeric code is only about **26 bits** and is stretched with a **single** round of
SHA256, and **no checksum verifies correct decryption** — so any code is accepted and will, with
near-50% odds, decrypt to a valid-looking pubkey. Its job is narrow: force out-of-band confirmation
so an injected MiTM pubkey is detected. It is not a confidentiality control, and the docs do not
present it as one. Practical ceiling: ~4k of encoded data, an HTTP limitation.

A **1.4.1Q** fix is worth noting for anyone relying on Teleport: a stale-data bug could teleport an
**unsigned** multisig PSBT, and a malformed full backup received by Teleport produced a Yikes error.

## Choosing between them

| Need | Route |
|------|-------|
| Offline, long-term, recoverable without a Coldcard | full backup file |
| Provision a second identical device | Secure Device Cloning |
| Get a secret to a remote party, both on Q | Key Teleport |
| Deniable physical backup | [[seed-xor|Seed XOR]] ([Seed XOR](seed-xor.md)) |

## Evidence status

`confidence: high`. The backup format is a standard container with a published example archive and
passphrase, so the central claim is independently verifiable. Key Teleport's construction is
specified precisely enough to critique — and the critique above (26-bit code, no checksum) comes from
Coinkite's own text. What is not verified here is the implementation: nothing in these sources
demonstrates the firmware does what the specs say.

## See Also

- [[seed-xor|Seed XOR]] ([Seed XOR](seed-xor.md)) — the deniable alternative to an encrypted file
- [[temporary-seeds-and-seed-vault|Temporary seeds and Seed Vault]] ([Temporary seeds and Seed Vault](temporary-seeds-and-seed-vault.md)) — where a teleported secret lands, and how ephemeral seeds change backup behaviour
- [[entropy-advisory-2026|The 2026 entropy advisory]] ([The 2026 entropy advisory](entropy-advisory-2026.md)) — backup passphrases come from the TRNG
- [[seed-generation-and-derivation|Seed generation and derivation]] ([Seed generation and derivation](seed-generation-and-derivation.md)) — what the `mnemonic`, `xprv` and `raw_secret` fields mean
- [[connectivity-and-nfc|Connectivity and NFC]] ([Connectivity and NFC](connectivity-and-nfc.md)) — the NFC and BBQr transports Teleport rides on
- [[trick-pins-and-duress-wallets|Trick PINs and duress wallets]] ([Trick PINs and duress wallets](trick-pins-and-duress-wallets.md)) — the Delta Mode restore bug
- [[security-architecture|Security architecture]] ([Security architecture](../topics/security-architecture.md)) — why ~132 bits and "no PIN in backup" matter architecturally
- [[airgap-signing-workflows|Air-gapped signing workflows]] ([Air-gapped signing workflows](../topics/airgap-signing-workflows.md)) — moving transactions rather than secrets
- [[release-timeline|Release timeline]] ([Release timeline](../references/release-timeline.md)) — 4.0.0 cloning, 5.2.0 passphrase backup, 1.3.2Q Teleport
- [[coldcard-overview|COLDCARD — overview]] ([COLDCARD — overview](../topics/coldcard-overview.md)) — product context
- [[device-limits|Device limits]] ([Device limits](../references/device-limits.md)) — backup and cross-model restore limits
- [[model-and-version-matrix|Model and version matrix]] ([Model and version matrix](../references/model-and-version-matrix.md)) — Key Teleport is Q-only; cloning from 4.0.0
- [[signing-formats|Signing formats and standards]] ([Signing formats and standards](../references/signing-formats.md)) — the export formats a backup and its `.sig` accompany

## Sources

- [Backup files](../../raw/articles/2026-08-10-coldcard-backup-files.md) — 7z/AES-256-CBC format, 12-word TRNG passphrase, ~132 bits, worked example, limitations
- [Key Teleport](../../raw/articles/2026-08-10-coldcard-key-teleport.md) — ECDH session key, paranoid key and PBKDF2 parameters, data type codes, BBQr codes, multisig variant, security discussion
- [Mk3 release history](../../raw/articles/2026-08-10-coldcard-release-history-mk3.md) — 4.0.0 Secure Device Cloning and the randomised inner filename
- [Mk4/Mk5 release history](../../raw/articles/2026-08-10-coldcard-release-history-mk4-mk5.md) — 5.2.0 passphrase-wallet backup, 5.5.1 Delta Mode restore fix
- [Q release history](../../raw/articles/2026-08-10-coldcard-release-history-q.md) — 1.3.2Q Teleport introduction, 1.4.1Q Teleport fixes and standalone Notes backups
