---
title: "Air-gapped signing workflows"
category: topic
sources:
  - raw/articles/2026-08-10-coldcard-electrum-usage.md
  - raw/articles/2026-08-10-coldcard-bitcoin-core-usage.md
  - raw/articles/2026-08-10-coldcard-bitcoin-core-2of2-descriptors.md
  - raw/articles/2026-08-10-coldcard-generic-wallet-export.md
  - raw/articles/2026-08-10-coldcard-nfc-coldcard.md
  - raw/articles/2026-08-10-coldcard-nfc-pushtx.md
  - raw/articles/2026-08-10-coldcard-bip-21-extensions.md
  - raw/articles/2026-08-10-coldcard-limitations.md
  - raw/articles/2026-08-10-coldcard-menu-tree.md
created: 2026-08-10
updated: 2026-08-10
tags: [coldcard, airgap, psbt, electrum, bitcoin-core, descriptors, nfc, pushtx, multisig, workflow]
aliases: ["Coldcard airgap workflow", "Coldcard PSBT workflow"]
confidence: high
volatility: warm
verified: 2026-08-10
summary: "How PSBTs get onto a Coldcard and signatures get back off: the five transports (MicroSD, USB, virtual disk, NFC, QR/BBQr), the wallet-export formats that bootstrap a watching wallet, the Electrum and Bitcoin Core descriptor flows, the worked 2-of-2 multisig tutorial, and PushTX for single-tap broadcast. Practical rather than architectural."
---

# Air-gapped signing workflows

> The Coldcard never watches the chain. Every workflow therefore has the same three beats: **export
> public keys** to a host that does watch, **carry an unsigned PSBT in**, **carry a signature out**.
> What varies is the transport and how much the host software already understands.

## Transports

Five, with meaningfully different properties. Which exist depends on the model — see
[[model-and-version-matrix|Model and version matrix]]
([Model and version matrix](../references/model-and-version-matrix.md)).

| Transport | Models | Notes |
|-----------|--------|-------|
| MicroSD | all | the baseline air gap; Q has two slots (A and B), some operations require slot A |
| USB | all | data-capable cable required; disabled by default in some restored states |
| Virtual disk | Mk4/Mk5/Q | device presents as a USB drive; auto mode picks up PSBTs; ignores files already containing `-signed` |
| NFC | Mk4/Mk5/Q | Type 5 / ISO-15693 tag, ≤8k NDEF, **unencrypted**, exposes a 64-bit tag ID |
| QR / BBQr | Q only | scanner plus display; BBQr chunks up to 2MiB across animated frames |

Two operational gotchas worth knowing up front, both from the changelogs: with *both* NFC and
Virtual Disk disabled there were repeated bugs where export menus became inescapable (fixed across
5.3.3/5.4.3), and settings restored from a backup or clone are forced back to USB/NFC/VirtDisk
**off** by default.

## Bootstrapping a watching wallet

The device exports public material in a dozen host-specific shapes from
`Advanced/Tools > Export Wallet` — Sparrow, Cove, Bitcoin Core, Nunchuk, Bull Bitcoin, Blue Wallet,
Electrum, Wasabi, Fully Noded, Unchained, Theya, Bitcoin Safe, Zeus, Samourai pre/post-mix — plus
three generic forms:

- **Generic JSON.** Master XPUB and XFP plus `bip44`, `bip49`, `bip84`, `bip48_1` and `bip48_2`
  blocks; `bip45` appears only when the account number is zero. `_pub` fields are SLIP-132.
- **Descriptor.** Single-sig with multipath `<0;1>/*`, or multisig `sortedmulti(M,...)`, each with a
  `#checksum`. From 5.1.0 both the multipath form and the two-descriptor form are supported.
- **Export XPUB.** BIP-84/44/49 XPUB, ZPUB/YPUB, XFP or master XPUB as a QR, with a 5.4.1 toggle
  between BIP-32 and obsolete SLIP-132 formats.

Format details are in [[signing-formats|Signing formats and standards]]
([Signing formats and standards](../references/signing-formats.md)).

## Electrum

Setup pairs the Electrum wallet with the Coldcard's seed over USB like a normal connected device.
Then, air-gapped:

1. Set amount and destination; press Preview, or press Send with the Coldcard disconnected.
2. In the transaction-details window use **Save PSBT** — potentially straight to the SD card. The
   filename encodes date, time and wallet name.
3. Move the card; pick **Ready To Sign**; select the transaction; confirm on screen; approve.
4. The device writes `<name>-final.txn` containing the transaction hex.
5. Back in Electrum: `Tools > Load Transaction > from File`, then Broadcast.

For recovery without the device, Electrum can import the 24 words with the **BIP39 seed** checkbox
under Options (Electrum warns it does not generate BIP-39 seeds and does not guarantee continued
support), or import an XPUB from `public.txt` — the `BIP44 / Electrum` section's `m/44'/0'` value.
Default derivation on import is `m/44'/0'/0'`; BIP-84 works, BIP-49 was marked not yet supported.

## Bitcoin Core

The recommended path needs Core v0.21.0+ and Coldcard 4.1.3+, and produces a wallet that is more
than watch-only — Core can build PSBTs in the GUI:

1. `File > Create Wallet` with **Disable Private Keys**, **Make Blank Wallet** and **Descriptor
   Wallet** all checked.
2. Export the descriptor from the device — single-sig via `Advanced > MicroSD card > Export Wallet >
   Bitcoin Core`, multisig via `Settings > Multisig Wallets > <wallet> > Descriptors > Bitcoin Core`.
3. Paste the `importdescriptor` line from `bitcoin-core-XX.txt` into Core's console.

Two documented snags: Core v24.1 rejects ranged descriptors carrying a label, so delete the
`"label": "Coldcard x0x0x0x0"` entry (5.1.3 removed it from the export); and importing an existing
wallet with history needs a rescan or removal of `timestamp=now`, otherwise the balance reads zero.

The older `importmulti` route (Core v0.19.0+) is documented but no longer recommended; it needs HWI
for spending and `addresstype=bech32` in `bitcoin.conf`.

## Worked multisig: 2-of-2 with Core

The `bitcoin-core2of2desc.md` tutorial is the most complete end-to-end example in the docs — one
Mk4 plus a bitcoind software signer, with a third watch-only wallet as coordinator, on regtest.
The load-bearing steps:

- Create `signer` as a descriptor wallet **with** private keys, then
  `keypoolrefill 100` — without this the signer can only sign index 0, because addresses are
  generated by the watch-only wallet. Repeat past 100 addresses.
- Create `watch_only` with private keys disabled.
- Take the `p2wsh_desc` template from the Coldcard's `ccxp-<xfp>.json`, splice in the other
  signer's key-origin-annotated xpub from `listdescriptors`, and substitute the real `M`.
- `getdescriptorinfo` to compute the checksum; write the single-line descriptor to the SD card;
  import on the Coldcard via `Settings > Multisig Wallets > Import from file`.
- Export back out for Core, import into `watch_only` (the signer refuses, having private keys).
- Sign with Core first (`walletprocesspsbt`), carry the half-signed PSBT to the device, which
  produces `core_signed-part.psbt`; then `finalizepsbt` and `sendrawtransaction`.

Note the asymmetry that tutorial exposes: Core cannot derive xpubs at will, so the example falls
back to a legacy `m/44'/1'/0'` derivation for the software signer rather than a BIP-48 multisig
path.

Multisig ceilings — 15 co-signers, one wallet per PSBT, unique XFPs mandatory, BIP-67 `sortedmulti`
by default with opt-in unsorted `multi(...)` from 5.4.0 — are in
[[device-limits|Device limits]] ([Device limits](../references/device-limits.md)).

## Verifying an address belongs to you

From 5.3.1/1.1.0Q the device can take a payment address (typed, scanned, or over NFC) and report
whether it belongs to a wallet it holds keys for — single-sig or multisig. It searches the first
1528 addresses (764 external + 764 change), caches as it goes, and worst case takes about two
minutes to rule an address out. A BIP-21 extension narrows the search:
`bitcoin:tb1q…?wallet=Haystack` restricts it to the named multisig wallet.

## Getting the transaction broadcast

- **Host broadcast.** The normal case: Electrum's Load Transaction, Core's GUI, or any tool given
  the `-final.txn` hex.
- **PushTX.** Tap the Coldcard with a phone and a browser opens a page that broadcasts the freshly
  signed transaction. The URL carries `t=` (base64url transaction) and `c=` (rightmost 8 bytes of
  its SHA256) after a `#`, so the payload never reaches the server as a query string. Configure
  under `Settings > NFC Push Tx`; coldcard.com and mempool.space are built in, or supply your own
  page — the single-file `coldcard-pushtx.html` and mempool.space PR #5132 are the references.
  Practical ceiling: URLs approach 8000 bytes against ~4k server and phone limits, and, as the doc
  puts it, "CloudFlare sees all". Multisig transactions became finalizable in 5.4.2/1.3.2Q, which
  is what made PushTX usable for multisig at all.

## Signing artifacts and re-export

From 5.4.2/1.3.2Q the signing products can leave by a *different* medium than they arrived — a PSBT
scanned in over QR can be written out to SD card. Batch signing of multiple PSBTs arrived in 5.1.3
(`Advanced/Tools > File Management > Batch Sign PSBT`, or `(9)` from Ready To Sign), and is offered
automatically when two or more signable PSBTs are on the card.

## See Also

- [[coldcard-overview|COLDCARD — overview]] ([COLDCARD — overview](coldcard-overview.md)) — the anchor article for this topic
- [[signing-formats|Signing formats and standards]] ([Signing formats and standards](../references/signing-formats.md)) — export shapes, BIP-137, BIP-322, descriptors
- [[device-limits|Device limits]] ([Device limits](../references/device-limits.md)) — PSBT sizes, multisig ceilings, SIGHASH and fee policy
- [[connectivity-and-nfc|Connectivity and NFC]] ([Connectivity and NFC](../concepts/connectivity-and-nfc.md)) — the transport layer in detail, including antenna locations
- [[spending-policy-and-two-factor|Spending Policy and two-factor]] ([Spending Policy and two-factor](../concepts/spending-policy-and-two-factor.md)) — what changes when the device signs autonomously
- [[release-timeline|Release timeline]] ([Release timeline](../references/release-timeline.md)) — when each transport and export format landed
- [[model-and-version-matrix|Model and version matrix]] ([Model and version matrix](../references/model-and-version-matrix.md)) — which models have QR, NFC, virtual disk
- [[encrypted-backup-and-transfer|Encrypted backup and transfer]] ([Encrypted backup and transfer](../concepts/encrypted-backup-and-transfer.md)) — moving secrets rather than transactions
- frostsnap wiki: [Threshold signing paths on Coldcard](../../../frostsnap/wiki/topics/threshold-signing-paths-on-coldcard.md) — how the two-round MuSig2 ceremony (RAM-only nonce state, strict round separation) rides on these same PSBT transports, and what a BIP-445 FROST binding would still need

## Sources

- [Electrum usage](../../raw/articles/2026-08-10-coldcard-electrum-usage.md) — Save PSBT flow, seed and XPUB import, derivation screen
- [Bitcoin Core usage](../../raw/articles/2026-08-10-coldcard-bitcoin-core-usage.md) — descriptor wallet setup, `importdescriptors`, v24.1 label snag
- [Bitcoin Core 2-of-2 descriptors](../../raw/articles/2026-08-10-coldcard-bitcoin-core-2of2-descriptors.md) — the worked regtest multisig tutorial
- [Generic wallet export](../../raw/articles/2026-08-10-coldcard-generic-wallet-export.md) — JSON and descriptor export shapes
- [NFC](../../raw/articles/2026-08-10-coldcard-nfc-coldcard.md) — tag type, record types, size limits
- [NFC PushTX](../../raw/articles/2026-08-10-coldcard-nfc-pushtx.md) — URL protocol and backend expectations
- [BIP-21 extensions](../../raw/articles/2026-08-10-coldcard-bip-21-extensions.md) — the `wallet=` ownership-search parameter
- [Limitations](../../raw/articles/2026-08-10-coldcard-limitations.md) — address-ownership search bounds, multisig constraints
- [Menu tree](../../raw/articles/2026-08-10-coldcard-menu-tree.md) — export menu contents and transport guards
