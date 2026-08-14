---
title: "Connectivity and NFC"
category: concept
sources:
  - raw/articles/2026-08-10-coldcard-nfc-coldcard.md
  - raw/articles/2026-08-10-coldcard-nfc-pushtx.md
  - raw/articles/2026-08-10-coldcard-hardware-details.md
  - raw/articles/2026-08-10-coldcard-menu-tree.md
  - raw/articles/2026-08-10-coldcard-usb-batteries.md
  - raw/articles/2026-08-10-coldcard-release-history-mk4-mk5.md
created: 2026-08-10
updated: 2026-08-10
tags: [coldcard, nfc, iso-15693, ndef, pushtx, virtual-disk, microsd, bbqr, usb, antenna]
aliases: ["NFC-V", "Type 5 tag", "PushTX", "virtual disk"]
confidence: medium
volatility: cold
verified: 2026-08-10
summary: "The physical and logical ways data moves in and out: MicroSD, USB, virtual disk, NFC (Type 5 / ISO-15693, ≤8k NDEF, unencrypted) and Q's QR scanner with BBQr. Covers per-model antenna locations and how to destroy them, the NDEF record types, PushTX's after-the-hash URL scheme, and the standards-paywall complaint Coinkite files in its own docs."
---

# Connectivity and NFC

> An air-gapped signer is defined as much by its interfaces as by its crypto. Every one of them is a
> way in, so each is individually disableable — and the NFC antenna can be physically destroyed with a
> knife, with instructions provided.

## The five transports

| Transport | Models | Character |
|-----------|--------|-----------|
| **MicroSD** | all | the baseline air gap. Q has two slots; some operations require slot A |
| **USB** | all | needs a data-capable cable; forced off after a backup/clone restore |
| **Virtual disk** | Mk4/Mk5/Q | device appears as a USB drive; auto mode picks up PSBTs, ignores files already containing `-signed` |
| **NFC** | Mk4/Mk5/Q | Type 5 tag, ≤8k NDEF, **unencrypted** |
| **QR / BBQr** | Q only | scanner plus display; BBQr chunks up to 2MiB across animated frames |

Menu guards in the menu tree reflect this directly: `[IF NFC ENABLED]`, `[IF QR SCANNER]`,
`[IF VIRTDISK ENABLED]`, `[IF QWERTY KEYBOARD]`, `[IF BATTERIES]`. Features do not merely fail when a
transport is off — the menu items are absent.

Workflow-level use of these transports is in
[[airgap-signing-workflows|Air-gapped signing workflows]]
([Air-gapped signing workflows](../topics/airgap-signing-workflows.md)).

## Finding the NFC antenna

Genuinely necessary information, because a tap that misses looks like a broken feature:

| Model | Antenna |
|-------|---------|
| **Mk4** | PCB trace loop, centred **under the `8` key** |
| **Mk5** | a discrete coil (**`L6`**) in the **top-right corner** |
| **Q1** | flexible "sticker" antenna **behind the display**. The green **`D12`** LED below the bottom-right of the display is the *activity indicator*, not the antenna |

You also need your phone's antenna location — usually top, middle or bottom of the back, rarely marked,
so look up the model.

## Disabling and destroying NFC

The layered off-switches, in order of severity:

1. **Settings menu disable** — the tag chip is *completely* disabled; "there is no way to probe, detect
   or access the Coldcard over RF."
2. **Even when enabled**, the tag chip stays disabled unless the device is actively sharing something.
3. **Energy harvesting is disabled** in the chip, so it does nothing when the Coldcard is powered down,
   regardless of the NFC setting.
4. **Physical destruction**, with per-model instructions:
   - **Mk4** — cut the trace labelled `NFC` inside the MicroSD card hole, with a sharp knife point.
   - **Mk5** — no such trace; the `L6` coil must be physically removed.
   - **Q1** — cut the trace labelled `NFC DATA` **under the batteries**.

Point 3 is the one worth pausing on: a passive NFC tag that harvests energy would be readable from a
powered-off device. Disabling harvesting is what makes "off" mean off.

## What NFC does not protect

Stated plainly in the source, and repeated here because it is easy to miss:

- **NFC traffic is not encrypted** and is subject to eavesdropping.
- While NFC is active, the device is **uniquely identifiable**: the anti-collision protocol requires a
  **64-bit unique ID** baked into the tag chip and shared automatically. Only during active transfers,
  not when idle — but a transfer is exactly when an observer is likely to be present.

So NFC is a convenience transport, not a confidential one. Anything sensitive crossing it needs its own
encryption layer — which is precisely what
[[encrypted-backup-and-transfer|Key Teleport]] ([Encrypted backup and transfer](encrypted-backup-and-transfer.md))
provides.

## The lower layers

- Chip acts as a **Type 5 NFC tag**; radio standard **NFC-V / ISO-15693**, 13.56 MHz carrier.
- Effectively exposes a flash memory of up to **8 kB**, organised per **NDEF**.
- NFC-V provides **CRC16** per low-level message — error detection only, no tamper protection.

**Desktop testing caveat:** most USB contactless readers **will not work**, because they implement
ISO-14443A/B rather than NFC-V. Smartphones all support NFC-V and are the intended target; generic tag
readers can view what the device shares.

## Coinkite's standards-paywall complaint

Unusual for a product doc and worth preserving, because it explains a documentation limitation rather
than excusing one. ISO and the NFC Forum sell their specifications — membership from a few thousand
dollars, or a few hundred per PDF. Coinkite therefore **cannot link to reference standards** and must,
in its own words, *"hand-wave about our interpretation of their standards documents."* Its stated
position: the policy "is not in the public interest and is hindering adoption of their standards and
even technological progress in general. Good interoperability is critical with radio standards."

The practical consequence for a reader of this wiki: the NDEF details below are Coinkite's
interpretation, not a citation, and cannot be checked against the standard without paying for it.

## NDEF record types

An NDEF message is a list of records, each with a type and a payload. Order is **not defined and may
change**. Types are shown as full URNs (RFC 2141) but only the final two parts go on the wire (e.g.
`bitcoin.org:psbt`), with **TNF=4** (NFC Forum external type) supplying the `urn:nfc:ext:` prefix.
Coinkite uses NFC Forum Local Types for new work and invites other Bitcoin developers to use the same
types.

### Simple data

| Purpose | Type | Body |
|---------|------|------|
| **General QR replacement** — press `(3)` on any QR screen | `urn:nfc:wkt:T` | ASCII text, whatever the QR held |
| **Payment address** | `urn:nfc:wkt:T` | bech32 or base58 address; multiple addresses separated by `0x0a` |

Note what the QR-replacement path implies: **xpubs and even seed words** can leave over NFC this way,
"after enough warning screens".

### Complex data

A label record first, then binary records:

| Record | Type | Body |
|--------|------|------|
| **Text label** | `urn:nfc:wkt:T` | "Partly signed PSBT", "Deposit Address", "Signed Transaction" — a title for the share |
| **SHA256 checksum** | `urn:nfc:ext:bitcoin.org:sha256` | exactly 32 binary bytes over the payload that **directly follows** |
| **TXID** | `urn:nfc:ext:bitcoin.org:txid` | exactly 32 binary bytes |
| **PSBT** | `urn:nfc:ext:bitcoin.org:psbt` | binary BIP-174 PSBT, first five bytes `psbt\xff`; may be unsigned, partly signed or complete |
| **Transaction** | `urn:nfc:ext:bitcoin.org:txn` | binary wire-ready txn, typically starting `0x02 0x00 0x00 0x00` |
| **Wallet export** | `application/json` | JSON |

The SHA256 record's purpose is stated with care: it is for **end-to-end error detection** and
**"does not protect against tampering."** That distinction is exactly right and often blurred
elsewhere — a checksum transmitted alongside the data it covers, over an unauthenticated channel, is a
corruption check and nothing more.

The upstream Examples section reads "**comming soon**" and is empty at this revision.

## PushTX

Tap the Coldcard with a phone after signing and a browser opens a page that broadcasts the
transaction. The payload rides **after the `#`** — `t=` (base64url transaction) and `c=` (rightmost 8
bytes of its SHA256) — so it never reaches the server as a query string. Configure at
`Settings > NFC Push Tx`; coldcard.com and mempool.space are built in, or point it at your own page
(`coldcard-pushtx.html` is a single-file reference; mempool.space PR #5132 is the upstream
integration).

Two honest limits from the doc: URLs approach **8000 bytes** against roughly 4k server and phone
limits, and — regarding the hosted option — **"CloudFlare sees all"**. Multisig transactions became
finalizable in 5.4.2/1.3.2Q, which is what made PushTX useful for multisig.

## Other physical interfaces

- **Serial UART** test points on the right edge (`G`/`R`/`T`), 3.3V TTL at 115,200 bps — **requires
  breaking the case**. See
  [[reproducible-builds-and-developer-access|Reproducible builds and developer access]]
  ([Reproducible builds and developer access](reproducible-builds-and-developer-access.md)).
- **Batteries** (Q only): 3× AAA. USB power banks work; the documented community tip is the
  **AUKEY PB-N54** with the power button pressed **twice** to enter low-current mode — a real problem
  because many banks shut off when a load draws too little current. That note is a genuine four-line
  community stub credited to A. Buttarello via `t.me/coldcard/16439`.
- **Hardware schematics and BOMs** exist in the repository (`hardware/`) covering Q rev D, Mk5 rev F,
  Mk4 rev D and Mk3 rev B — enough, Coinkite says, "to build your own Coldcard from off-the-shelf
  parts", shared for security researchers. Excluded: the custom plastic case, the barcoded secure bag
  and the pin-recovery card. **This directory is proprietary** — research and testing only, and
  Coinkite "does NOT grant license of this information for comercial use" [sic].

## Reliability history

The changelogs show connectivity as a recurring source of bugs rather than a solved problem:

| Version | Change |
|---------|--------|
| 5.0.6 | Virtual Disk security release |
| 5.3.3 / 5.4.3 | repeated fixes where export menus became inescapable with **both** NFC and VirtDisk disabled |
| 5.4.2 / 1.3.2Q | signing products can leave by a different medium than they arrived |
| 5.5.1 / 1.4.1Q | NFC tag kept alive longer for iOS; VirtDisk **and** NFC disabled before HSM mode |
| 1.4.1Q | major **QR-scanner robustness** work; BIP-21 `amount` decimal-scaling bug fixed |

The 5.5.1 "disable VirtDisk+NFC before HSM" entry is the interesting one architecturally: entering a
restricted mode now closes the transports first.

## Evidence status

`confidence: medium`. Antenna locations, NDEF types and the disable/destroy instructions are specific
and first-party. The NFC security claims (tag fully disabled, energy harvesting off) are assertions
about firmware and chip configuration that nothing here verifies. The standards interpretation is
explicitly flagged by Coinkite as interpretation. The `hardware/` schematics would let a researcher
check the antenna and trace claims, and are the one part of this article with an independent
verification path — under a licence that permits exactly that use and no more.

## See Also

- [[airgap-signing-workflows|Air-gapped signing workflows]] ([Air-gapped signing workflows](../topics/airgap-signing-workflows.md)) — using these transports to move PSBTs
- [[encrypted-backup-and-transfer|Encrypted backup and transfer]] ([Encrypted backup and transfer](encrypted-backup-and-transfer.md)) — Key Teleport adds the encryption NFC lacks
- [[security-architecture|Security architecture]] ([Security architecture](../topics/security-architecture.md)) — unencrypted NFC in the admitted-limits list
- [[spending-policy-and-two-factor|Spending Policy and two-factor]] ([Spending Policy and two-factor](spending-policy-and-two-factor.md)) — the NFC tap that carries the Web2FA URL
- [[reproducible-builds-and-developer-access|Reproducible builds and developer access]] ([Reproducible builds and developer access](reproducible-builds-and-developer-access.md)) — the serial REPL test points
- [[signing-formats|Signing formats and standards]] ([Signing formats and standards](../references/signing-formats.md)) — the PSBT and export formats these records carry
- [[coldcard-overview|COLDCARD — overview]] ([COLDCARD — overview](../topics/coldcard-overview.md)) — product context
- [[model-and-version-matrix|Model and version matrix]] ([Model and version matrix](../references/model-and-version-matrix.md)) — which models have which transports
- [[device-limits|Device limits]] ([Device limits](../references/device-limits.md)) — the 8k NDEF and ~4k URL ceilings
- [[release-timeline|Release timeline]] ([Release timeline](../references/release-timeline.md)) — the dated connectivity bugfix history
- [[seed-generation-and-derivation|Seed generation and derivation]] ([Seed generation and derivation](seed-generation-and-derivation.md)) — USB keyboard emulation for BIP-85 passwords

## Sources

- [NFC](../../raw/articles/2026-08-10-coldcard-nfc-coldcard.md) — antenna locations, disable and destroy instructions, NFC-V lower layers, the standards-paywall complaint, all NDEF record types
- [NFC PushTX](../../raw/articles/2026-08-10-coldcard-nfc-pushtx.md) — after-the-hash URL scheme, backends, size and privacy limits
- [Hardware details](../../raw/articles/2026-08-10-coldcard-hardware-details.md) — schematics and BOMs by revision, exclusions, the proprietary licence
- [Menu tree](../../raw/articles/2026-08-10-coldcard-menu-tree.md) — transport guards on menu items
- [USB batteries](../../raw/articles/2026-08-10-coldcard-usb-batteries.md) — the AUKEY PB-N54 low-current-mode tip
- [Mk4/Mk5 release history](../../raw/articles/2026-08-10-coldcard-release-history-mk4-mk5.md) — Virtual Disk security release, inescapable-menu fixes, transport-crossing exports, iOS tag timing
