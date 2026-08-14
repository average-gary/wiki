---
title: "Coldcard Internal Documentation (docs index)"
source: "https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/README.md"
type: articles
ingested: 2026-08-10
tags: [coldcard, documentation-index, hardware-wallet, coinkite]
summary: "Index of Coldcard's internal developer documentation, written 'for you hackers out there... but also for anyone who wants to understand why it's safe to put your moneys into Coldcard.' Annotates 28 sibling documents spanning the security model, PIN design, dual secure elements, developer access, memory map, reproducible builds, upgrade/recovery, backups, temporary seeds, Seed XOR, Key Teleport, spending policy, the 2FA mechanisms, message signing, wallet export formats, NFC, and documented limitations. Useful as the authoritative map of what Coinkite considers its public design record."
collection: "coldcard"
adapter: git
upstream_id: "docs/README.md"
upstream_type: git-file
revision: "43b2139227149c281141d08c612afd13c434d456"
sha: "d12402f73af49dfd6a44ed2b64c564b1d96d35ca"
canonical_url: "https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/README.md"
content_format: markdown
license: "MIT (Coinkite Inc.)"
authors: [Coinkite Inc.]
fetched: 2026-08-10
---
# Coldcard Internal Documentation

These docs are meant for you hackers out there... but also for anyone who
wants to understand why it's safe to put your moneys into Coldcard.

- [`security-model.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/security-model.md) The COLDCARD Mk4/Mk5/Q security model.
- [`pin-entry.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/pin-entry.md) Huge and detailed discussion of PIN codes and the security element that holds the secrets.
- [`secure-elements.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/secure-elements.md) How the dual secure elements work together.
- [`dev-access.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/dev-access.md) How developers can modify Coldcard to extend it.
- [`memory-map.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/memory-map.md) Memory map highlights
- [`notes-on-repro.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/notes-on-repro.md) Detailed breakdown of the reproducible build process.
- [`upgrade-recovery.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/upgrade-recovery.md) Firmware upgrade and recovery process.
- [`backup-files.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/backup-files.md) Some details of our encrypted backup files.
- [`temporary-seeds.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/temporary-seeds.md) Temporary (ephemeral) seeds and the Seed Vault.
- [`seed-xor.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/seed-xor.md) More about _Seed XOR_ feature, including fully worked Seed XOR example, and useful XOR lookup chart.
- [`key-teleport.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/key-teleport.md) Key Teleport: encrypted transfer of seeds and secrets between Q devices.
- [`spending-policy.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/spending-policy.md) Spending policy: autonomous signing with configurable limits.
- [`microsd-2fa.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/microsd-2fa.md) Using a MicroSD card as a second factor for login.
- [`web2fa.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/web2fa.md) Web 2FA authentication.
- [`bip85-passwords.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/bip85-passwords.md) Deriving deterministic passwords via BIP-85.
- [`msg-signing.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/msg-signing.md) COLDCARD message signing.
- [`proof-of-reserves-bip-322.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/proof-of-reserves-bip-322.md) BIP-322 generic signed message format and proof of reserves.
- [`generic-wallet-export.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/generic-wallet-export.md) Generic JSON wallet export file format.
- [`bip-21-extensions.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/bip-21-extensions.md) Coldcard's BIP-21 URI extensions, including multisig ownership address check.
- [`nfc-coldcard.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/nfc-coldcard.md) NFC support on Coldcard Mk4 and Q.
- [`nfc-pushtx.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/nfc-pushtx.md) NFC Push Transaction: broadcast a signed transaction via your phone.
- [`usb-batteries.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/usb-batteries.md) Using USB battery packs with Coldcard.
- [`electrum-usage.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/electrum-usage.md) Importing seed words into Electrum for funds usage (and other tips).
- [`bitcoin-core-usage.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/bitcoin-core-usage.md) How to use with Bitcoin Core.
- [`bitcoin-core2of2desc.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/bitcoin-core2of2desc.md) Airgapped 2-of-2 multisig with Bitcoin Core using descriptors.
- [`limitations.md`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/limitations.md) Documented limitations, policy choices, and TODO items.
- [`paperwallet.pdf`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/paperwallet.pdf) Example paper wallet template file.
- [`menu-tree.txt`](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/menu-tree.txt) Dump of the menu system. Incomplete, may be out of date.

---

## Ingest note

Repository-relative links in the body above were repointed to absolute GitHub URLs pinned to `43b2139`. Link text and all prose are unchanged; only the destinations were rewritten, since repo-relative paths do not resolve inside the wiki.
