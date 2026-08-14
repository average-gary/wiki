---
title: "Signing formats and standards"
category: reference
sources:
  - raw/articles/2026-08-10-coldcard-msg-signing.md
  - raw/articles/2026-08-10-coldcard-proof-of-reserves-bip-322.md
  - raw/articles/2026-08-10-coldcard-generic-wallet-export.md
  - raw/articles/2026-08-10-coldcard-bip-21-extensions.md
  - raw/articles/2026-08-10-coldcard-limitations.md
  - raw/articles/2026-08-10-coldcard-release-history-mk4-mk5.md
created: 2026-08-10
updated: 2026-08-10
tags: [coldcard, bip-137, bip-322, bip-174, psbt, message-signing, signed-exports, bip-21, wallet-export, descriptors, reference]
aliases: ["BIP-137", "BIP-322", "proof of reserves", "signed exports", "Verify Sig File", "Generic JSON"]
confidence: high
volatility: warm
verified: 2026-08-10
summary: "The wire formats a Coldcard produces and consumes: BIP-137 message signatures with the per-script-type header change at 5.1.0, detached .sig files for exports and exactly which key signs each one, BIP-322 proof-of-reserves PSBT requirements, the Generic JSON wallet export with its descriptor fields, and the BIP-21 wallet= extension. Includes the full list of standards implemented."
---

# Signing formats and standards

> A signer is only useful if the other side can read what it produces. This is the format reference:
> what goes on the wire, which key signs it, and which BIP governs. Workflow context is in
> [[airgap-signing-workflows|Air-gapped signing workflows]]
> ([Air-gapped signing workflows](../topics/airgap-signing-workflows.md)).

## Standards implemented

| Standard | Role |
|----------|------|
| **BIP-32** | HD derivation; the storage format for all xpubs |
| **BIP-39** | seed words (English only), passphrases |
| **BIP-21** | payment URIs, plus Coldcard's own `wallet=` extension |
| **BIP-44 / 49 / 84** | single-sig account schemes in exports |
| **BIP-45 / 48** | multisig account schemes in exports |
| **BIP-67** | `sortedmulti` — the only sorting Coldcard's own formats emit |
| **BIP-85** | deterministic child seeds, XPRVs, passwords, WIFs |
| **BIP-137** | message signing |
| **BIP-174** | PSBT |
| **BIP-322** | generic signed message / proof of reserves (signer only) |
| **BIP-383** | descriptor import — the route to `multi(...)` |
| **SLIP-132** | `ypub`/`zpub` read on import, optional on export |
| **RFC 6238** | TOTP for Web2FA |
| **FIPS-198-1** | HMAC, in the anti-phishing word derivation |

## BIP-137 message signing

Available since early firmware; the important change is at **5.1.0**.

| Firmware | Header byte |
|----------|-------------|
| Mk3 and Mk4 **up to 5.1.0** | the **compressed P2PKH** header byte for **all** script types |
| **From 5.1.0** | the **correct per-script-type** header |

That is a compatibility hazard in both directions: signatures made by old firmware over segwit
addresses carry the wrong header, and a strict verifier will reject them.

Routes in and out:

| Direction | Media |
|-----------|-------|
| Request in | USB (`ckcc`), a crafted file on MicroSD/Virtual Disk, NFC (Mk4/Mk5/Q) |
| Signature out | MicroSD, Virtual Disk, NFC, or **QR on Q** |

**Cross-verification note:** Bitcoin Core can only verify **P2PKH** message signatures. Coinkite points
users at `verifybitcoinmessage.com` for the other script types.

## On-device verification and signed exports

From **5.1.0**:

- `Advanced/Tools > File Management > Verify Sig File`, or
  `Advanced/Tools > NFC Tools > Verify Sig File`.
- For a **detached** signature, the device checks the digest named inside the message against the named
  file — **the file must be present**.
- Signature files are limited to roughly **10 kB**.
- Most MicroSD/Virtual Disk exports now ship a companion `.sig`: `addresses.csv` → `addresses.sig`.

### Detached signature construction

1. Take the **single SHA256** of the file contents.
2. Build `msg = <hex digest> + two spaces + <basename>`.
3. Hash that in the usual way: `"Bitcoin Signed Message:" + ser_compact_size(len(msg)) + msg`.

Note step 1: a **single** SHA256 of the file, not double — worth getting right when reimplementing.

### File format

```text
-----BEGIN BITCOIN SIGNED MESSAGE-----
f1591bfb04a89f723e1f14eb01a6b2f6f507eb0967d0a5d7822b329b98018ae4  coldcard-export.json
-----BEGIN BITCOIN SIGNATURE-----
mtHSVByP9EYZmB26jASDdPVm19gvpecb5R
IFOvGVJrm31S0j+F4dVfQ5kbRKWKcmhmXIn/Lw8iIgaCG5QNZswjrN4X673R7jTZo1kvLmiD4hlIrbuLh/HqDuk=
-----END BITCOIN SIGNATURE-----
```

### Which key signs which export

The part most likely to be needed and least likely to be guessed correctly:

| Export | Signing key |
|--------|-------------|
| Single-sig address explorer | the key of the **0th address** in the export |
| App-specific (Bitcoin Core, Electrum, Wasabi, Samourai Postmix/Premix, Descriptor) | `m/<app_deriv>h/<coin_type>h/<account>h/0/0` |
| Generic (Lily Wallet, Generic JSON, Dump Summary) | `m/44h/<coin_type>h/<account>h/0/0` |
| BIP-85 exports | the **BIP-85 application path** |
| Paper wallets | their own exported key |
| Multisig — descriptor | `my_key/0/0` |
| Multisig — generic XPUBs export | `m/48h/<coin_type>h/<account>h/2h/0/0` |
| Multisig — address explorer | `my_key/<change>/<start_index>` |

Multisig exports encode pubkeys as **P2PKH** addresses for signing purposes regardless of the wallet's
actual script type.

## BIP-322 / proof of reserves

Coldcard is a **signer only**. It validates the `to_sign` transaction, displays the message, and adds
signatures. Constructing and encoding the final BIP-322 string is the **finalizer's** job.

### Requirements on the PSBT

| Requirement | Detail |
|-------------|--------|
| Global field | `PSBT_GLOBAL_GENERIC_SIGNED_MESSAGE` (`0x09`) **must** be present |
| Message | non-empty, **≤ 330 characters** |
| Per input | `PSBT_IN_BIP32_DERIVATION` |
| P2SH-wrapped segwit | `PSBT_IN_REDEEM_SCRIPT` |
| P2WSH | `PSBT_IN_WITNESS_SCRIPT` |
| Inputs | ≥ 1; **input 0 must spend the `to_spend` output** |
| Input 0 UTXO | either `PSBT_IN_NON_WITNESS_UTXO` or `PSBT_IN_WITNESS_UTXO` |
| `to_sign` outputs | exactly **one null-data `OP_RETURN`** output |
| `to_sign` version | 0 or 2 |
| PSBT version | 0 or 2 |
| Foreign inputs | **none permitted** |

With **witness-UTXO only**, Coldcard **reconstructs the expected `to_spend` txid** from the message and
the scriptPubKey. With a **non-witness UTXO** it must be the full BIP-322 `to_spend` transaction: 1
input, 1 output, output `nValue` 0, prevout hash 0, prevout n `0xffffffff`, scriptSig
`OP_0 PUSH32 <message_hash>`.

### Output and UX

- **Always a signed PSBT, never a finalized transaction** — even with `ckcc unsigned.psbt --finalize`.
  The reason is sound: the address commits only to a *hash* of the pubkey or script, so the verifier
  needs the PSBT metadata to check anything.
- Labelled **`BIP-322 Message`** when only input 0 is present — no input/output counts shown.
- Labelled **`Proof of Reserves`** with the reserve amount when extra inputs exist (e.g.
  `Amount 0.20000000 BTC`, `21 inputs / 1 output`).
- Non-ASCII messages produce a warning.
- **Legacy proof-of-reserves PSBTs lacking the global field are rejected.**

Coinkite's own safety statement, quoted because it is the reassurance a reader wants: *"The signatures
created by the BIP-322 process will never be suitable for an on-chain Bitcoin transaction that could
move funds."*

## Generic JSON wallet export

`Advanced/Tools > Export Wallet > Generic JSON`. Offered alongside the wallet-specific formats and
intended for other wallet makers to adopt.

Top-level fields: `chain`, `xfp`, `account`, `xpub`. Then one sub-object per scheme:

| Key | Script type | Derivation |
|-----|-------------|------------|
| `bip44` | `p2pkh` | `m/44h/<coin>h/<acct>h` |
| `bip49` | `p2sh-p2wpkh` | `m/49h/<coin>h/<acct>h` |
| `bip84` | `p2wpkh` | `m/84h/<coin>h/<acct>h` |
| `bip48_1` | `p2sh-p2wsh` | `m/48h/<coin>h/<acct>h/1h` |
| `bip48_2` | `p2wsh` | `m/48h/<coin>h/<acct>h/2h` |
| `bip45` | multisig | `m/45h` — **only when the account number is zero** |

Per-section fields:

- `name`, `xfp`, `deriv`, `xpub`
- `desc` — a ready-to-import output descriptor **with `#checksum`**. Single-sig uses the `<0;1>/*`
  multipath form; multisig emits a `sortedmulti(...)` template with `M` and a trailing `...` as
  placeholders for your threshold and the other co-signers.
- `_pub` — the **SLIP-132** `ypub`/`zpub` form, which *implies* an address format
- `first` — the `/0/0` address; **single-sig sections only**, omitted for multisig

Three integration notes from the doc that cause real bugs when ignored:

1. The account number may be **anything up to 9999** — *"Don't assume it's zero."*
2. When building a PSBT, the master **XFP is the root of the subkey paths in the file** and you must
   supply the **full** path from master: `(m=0F056943)/84'/0'/123'/0/0`.
3. `_pub` implies a specific address format; `xpub` does not.

## BIP-21 `wallet=` extension

Coldcard's own extension, for accelerating **multisig** address-ownership checks: name the wallet an
address belongs to and the search goes straight there instead of sweeping every known multisig wallet.

```text
tb1q4d67p7stxml3kdudrgkg5mgaxsrgzcqzjrrj4gg62nxtvnsnvqjsxjkej0?wallet=goldmine

bitcoin:mtHSVByP9EYZmB26jASDdPVm19gvpecb5R?label=coldcard_purchase&amount=50&wallet=Haystack%20Four
```

The parameter is optional and percent-encoding applies to the name. Given the 1528-address search
ceiling in [[device-limits|Device limits]] ([Device limits](device-limits.md)), this is a performance
feature with correctness consequences.

## Evidence status

`confidence: high`. Formats are specified with worked examples, sample files and exact field names, and
almost all of it is independently verifiable against the referenced BIPs and against a real export. The
BIP-322 constraints are unusually precise for vendor documentation. `volatility: warm` because format
behaviour has already changed once in a breaking way (the 5.1.0 header-byte fix) and the signed-export
key assignments are the kind of table that grows with each new wallet integration. Not established
here: whether third-party verifiers actually accept Coldcard's BIP-137 output for every script type,
and the BIP-85 password path's specification status, which cites a fork rather than a merged BIP.

## See Also

- [[airgap-signing-workflows|Air-gapped signing workflows]] ([Air-gapped signing workflows](../topics/airgap-signing-workflows.md)) — the PSBT round trip these formats serve
- [[device-limits|Device limits]] ([Device limits](device-limits.md)) — SIGHASH policy, the change-script matrix, size ceilings
- [[coldcard-overview|COLDCARD — overview]] ([COLDCARD — overview](../topics/coldcard-overview.md)) — product context
- [[model-and-version-matrix|Model and version matrix]] ([Model and version matrix](model-and-version-matrix.md)) — which models offer QR and NFC output
- [[connectivity-and-nfc|Connectivity and NFC]] ([Connectivity and NFC](../concepts/connectivity-and-nfc.md)) — the NDEF records carrying PSBTs and exports
- [[seed-generation-and-derivation|Seed generation and derivation]] ([Seed generation and derivation](../concepts/seed-generation-and-derivation.md)) — XFP conventions and derivation policy
- [[encrypted-backup-and-transfer|Encrypted backup and transfer]] ([Encrypted backup and transfer](../concepts/encrypted-backup-and-transfer.md)) — the backup file's own format
- [[release-timeline|Release timeline]] ([Release timeline](release-timeline.md)) — 5.1.0 header fix and signed exports

## Sources

- [Message signing](../../raw/articles/2026-08-10-coldcard-msg-signing.md) — BIP-137, the 5.1.0 header change, detached signature construction and file format, per-export signing keys, Verify Sig File
- [Proof of reserves (BIP-322)](../../raw/articles/2026-08-10-coldcard-proof-of-reserves-bip-322.md) — PSBT field requirements, `to_spend` reconstruction, signed-PSBT-only output, UX labelling
- [Generic wallet export](../../raw/articles/2026-08-10-coldcard-generic-wallet-export.md) — JSON schema, per-scheme derivations, `desc`/`_pub`/`first` semantics, account-number and XFP integration notes
- [BIP-21 extensions](../../raw/articles/2026-08-10-coldcard-bip-21-extensions.md) — the `wallet=` parameter and examples
- [Limitations](../../raw/articles/2026-08-10-coldcard-limitations.md) — BIP-67 vs BIP-383, finalization by medium, SIGHASH policy
- [Mk4/Mk5 release history](../../raw/articles/2026-08-10-coldcard-release-history-mk4-mk5.md) — 5.1.0 signed exports and message-signing header fix
