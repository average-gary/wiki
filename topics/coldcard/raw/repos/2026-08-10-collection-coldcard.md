---
title: "Coldcard firmware — design docs and release histories (collection manifest)"
source: "https://github.com/coldcard"
type: repos
ingested: 2026-08-10
tags: [coldcard, coinkite, collection-manifest, hardware-wallet, bitcoin, secure-element, firmware, stm32l4, design-docs, release-history]
summary: "Collection manifest for a scoped git ingest of coldcard/firmware at revision 43b2139 — the 27 files in docs/, four architecture READMEs, and the release-history changelogs for the Mk3, Mk4/Mk5 and Q product lines. 34 distinct blobs became 34 child sources; three further in-scope paths are git symlinks to blobs already captured. Records the upstream repo inventory for the COLDCARD org, which first-party repos were excluded by the chosen scope, the six vendored forks, the split licensing between firmware (MIT-style) and hardware design files (proprietary, no commercial use), and the two broken relative links found upstream."
collection: "coldcard"
adapter: git
upstream_id: "coldcard/firmware"
upstream_type: git-repo
revision: "43b2139227149c281141d08c612afd13c434d456"
sha: "43b2139227149c281141d08c612afd13c434d456"
canonical_url: "https://github.com/coldcard/firmware/tree/43b2139227149c281141d08c612afd13c434d456"
content_format: markdown
license: "MIT (Coinkite Inc.); hardware/ design files proprietary"
authors: [Coinkite Inc.]
fetched: 2026-08-10
children: 34
---

# Coldcard firmware — collection manifest

Scoped git ingest of [`coldcard/firmware`](https://github.com/coldcard/firmware), pinned to

```
revision 43b2139227149c281141d08c612afd13c434d456
author   scgbckbone <scgbckbone@proton.me>
date     2026-08-04T11:16:19+02:00
subject  rng: discard 12 words after SEIS clear per RM0432 32.3.7
```

COLDCARD is a Bitcoin hardware wallet made by Coinkite Inc. (Toronto, Canada) —
[coldcard.com](https://coldcard.com), org tagline *"The right kind of security, for the
appropriate level of paranoia."* The `firmware` repo is the product's source of truth and
carries an unusually substantial `docs/` tree written, in its own words, "for you hackers out
there... but also for anyone who wants to understand why it's safe to put your moneys into
Coldcard."

## Scope of this ingest

The requested scope was **design docs plus release histories**: the whole of `docs/`, the
architecture-bearing READMEs, and the per-model release changelogs. Selected:

| Group | Paths | Count |
|-------|-------|-------|
| Design docs | `docs/*.md` (all) | 27 |
| Menu reference | `docs/menu-tree.txt` | 1 |
| Architecture READMEs | root `README.md`, `hardware/README.md`, `stm32/bootloader/README.md`, `stm32/mk4-bootloader/README.md` | 4 |
| Release histories | `releases/History-{Mk,Mk3,Mk4,Mk5,Q}.md` | 5 |
| **Nominal total** | | **37** |
| **Distinct blobs → children** | | **34** |

### Symlink deduplication

Three of the 37 in-scope paths are git symlinks (mode `120000`) rather than regular files, so
they carry no independent content. They were **not** written as separate children; each is an
alias for a blob already captured:

| Symlink path | Symlink blob | Resolves to | Captured as |
|--------------|--------------|-------------|-------------|
| `releases/History-Mk4.md` | `52359af` | `releases/History-Mk.md` | [release-history-mk4-mk5](../articles/2026-08-10-coldcard-release-history-mk4-mk5.md) |
| `releases/History-Mk5.md` | `52359af` | `releases/History-Mk.md` | [release-history-mk4-mk5](../articles/2026-08-10-coldcard-release-history-mk4-mk5.md) |
| `stm32/mk4-bootloader/README.md` | `299bcb1` | `../bootloader/README.md` | [bootloader-readme](../articles/2026-08-10-coldcard-bootloader-readme.md) |

Confirmed independently: `History-Mk.md`, `History-Mk4.md` and `History-Mk5.md` all hash to
MD5 `c0d3baec5c484b0c7fc6ac5ccf8f2f91` in the working tree, and the two bootloader READMEs both
hash to `8669abcacf7a396eff564ecac5b1dc51`. Writing three duplicate children would have
inflated the source count without adding information; the aliasing is recorded here instead.

So `History-Mk.md` is the Mk4/Mk5 history, and the Mk-specific files are pointers to it. The
Mk3 and Q lines have genuinely separate histories.

## Child sources

| Upstream path | Child | Blob |
|---------------|-------|------|
| `docs/README.md` | [2026-08-10-coldcard-docs-index](../articles/2026-08-10-coldcard-docs-index.md) | `d12402f` |
| `docs/security-model.md` | [2026-08-10-coldcard-security-model](../articles/2026-08-10-coldcard-security-model.md) | `03db46e` |
| `docs/secure-elements.md` | [2026-08-10-coldcard-secure-elements](../articles/2026-08-10-coldcard-secure-elements.md) | `44def43` |
| `docs/pin-entry.md` | [2026-08-10-coldcard-pin-entry](../articles/2026-08-10-coldcard-pin-entry.md) | `b9eae7b` |
| `docs/limitations.md` | [2026-08-10-coldcard-limitations](../articles/2026-08-10-coldcard-limitations.md) | `46f6da9` |
| `docs/memory-map.md` | [2026-08-10-coldcard-memory-map](../articles/2026-08-10-coldcard-memory-map.md) | `3be819d` |
| `docs/dev-access.md` | [2026-08-10-coldcard-dev-access](../articles/2026-08-10-coldcard-dev-access.md) | `c0fe686` |
| `docs/notes-on-repro.md` | [2026-08-10-coldcard-notes-on-repro](../articles/2026-08-10-coldcard-notes-on-repro.md) | `3106670` |
| `docs/upgrade-recovery.md` | [2026-08-10-coldcard-upgrade-recovery](../articles/2026-08-10-coldcard-upgrade-recovery.md) | `59e1cc7` |
| `docs/backup-files.md` | [2026-08-10-coldcard-backup-files](../articles/2026-08-10-coldcard-backup-files.md) | `81b146c` |
| `docs/temporary-seeds.md` | [2026-08-10-coldcard-temporary-seeds](../articles/2026-08-10-coldcard-temporary-seeds.md) | `8f646ae` |
| `docs/seed-xor.md` | [2026-08-10-coldcard-seed-xor](../articles/2026-08-10-coldcard-seed-xor.md) | `be32bb7` |
| `docs/key-teleport.md` | [2026-08-10-coldcard-key-teleport](../articles/2026-08-10-coldcard-key-teleport.md) | `9056e2d` |
| `docs/spending-policy.md` | [2026-08-10-coldcard-spending-policy](../articles/2026-08-10-coldcard-spending-policy.md) | `6938198` |
| `docs/microsd-2fa.md` | [2026-08-10-coldcard-microsd-2fa](../articles/2026-08-10-coldcard-microsd-2fa.md) | `9da4062` |
| `docs/web2fa.md` | [2026-08-10-coldcard-web2fa](../articles/2026-08-10-coldcard-web2fa.md) | `5fa88d6` |
| `docs/bip85-passwords.md` | [2026-08-10-coldcard-bip85-passwords](../articles/2026-08-10-coldcard-bip85-passwords.md) | `43beb3d` |
| `docs/msg-signing.md` | [2026-08-10-coldcard-msg-signing](../articles/2026-08-10-coldcard-msg-signing.md) | `6907e88` |
| `docs/proof-of-reserves-bip-322.md` | [2026-08-10-coldcard-proof-of-reserves-bip-322](../articles/2026-08-10-coldcard-proof-of-reserves-bip-322.md) | `4d2d66b` |
| `docs/generic-wallet-export.md` | [2026-08-10-coldcard-generic-wallet-export](../articles/2026-08-10-coldcard-generic-wallet-export.md) | `c6fe981` |
| `docs/bip-21-extensions.md` | [2026-08-10-coldcard-bip-21-extensions](../articles/2026-08-10-coldcard-bip-21-extensions.md) | `17a6b73` |
| `docs/nfc-coldcard.md` | [2026-08-10-coldcard-nfc-coldcard](../articles/2026-08-10-coldcard-nfc-coldcard.md) | `3ce0efb` |
| `docs/nfc-pushtx.md` | [2026-08-10-coldcard-nfc-pushtx](../articles/2026-08-10-coldcard-nfc-pushtx.md) | `7abf6ae` |
| `docs/usb-batteries.md` | [2026-08-10-coldcard-usb-batteries](../articles/2026-08-10-coldcard-usb-batteries.md) | `5a056dd` |
| `docs/electrum-usage.md` | [2026-08-10-coldcard-electrum-usage](../articles/2026-08-10-coldcard-electrum-usage.md) | `ef44d0a` |
| `docs/bitcoin-core-usage.md` | [2026-08-10-coldcard-bitcoin-core-usage](../articles/2026-08-10-coldcard-bitcoin-core-usage.md) | `a957177` |
| `docs/bitcoin-core2of2desc.md` | [2026-08-10-coldcard-bitcoin-core-2of2-descriptors](../articles/2026-08-10-coldcard-bitcoin-core-2of2-descriptors.md) | `2389780` |
| `docs/menu-tree.txt` | [2026-08-10-coldcard-menu-tree](../articles/2026-08-10-coldcard-menu-tree.md) | `89221f2` |
| `README.md` | [2026-08-10-coldcard-firmware-readme](../articles/2026-08-10-coldcard-firmware-readme.md) | `a3bfdf1` |
| `hardware/README.md` | [2026-08-10-coldcard-hardware-details](../articles/2026-08-10-coldcard-hardware-details.md) | `c2755f0` |
| `stm32/bootloader/README.md` | [2026-08-10-coldcard-bootloader-readme](../articles/2026-08-10-coldcard-bootloader-readme.md) | `13cbb42` |
| `releases/History-Mk.md` | [2026-08-10-coldcard-release-history-mk4-mk5](../articles/2026-08-10-coldcard-release-history-mk4-mk5.md) | `4d5f5bc` |
| `releases/History-Mk3.md` | [2026-08-10-coldcard-release-history-mk3](../articles/2026-08-10-coldcard-release-history-mk3.md) | `5bb0928` |
| `releases/History-Q.md` | [2026-08-10-coldcard-release-history-q](../articles/2026-08-10-coldcard-release-history-q.md) | `c71987d` |

## Upstream org inventory

The COLDCARD org holds 16 repositories: 10 first-party and 6 vendored forks.

### First-party repos

| Repo | HEAD at ingest | In this ingest? |
|------|----------------|-----------------|
| `firmware` | `43b2139` | **yes** (scoped) |
| `ckcc-protocol` | `3d1dfa8` | no — out of chosen scope |
| `ckbunker` | `ecc82b0` | no |
| `psbt_faker` | `2d42c86` | no |
| `push-tx` | `7a9a47c` | no |
| `recovery-images` | `ccafbb5` | no |
| `wordlist-paper` | `9afdc55` | no |
| `psbt_recovery` | `d827db6` | no |
| `modcryptocurrency` | `b90431f` | no |
| `coldcard-paper-wallet-templator` | `2f82223` | no |

The nine excluded repos were cloned and their HEADs recorded during discovery, but not ingested,
because the chosen scope was design documentation and release history rather than the full org.
`ckcc-protocol` (the USB protocol library) is the most obvious candidate for a follow-up ingest;
`push-tx` pairs with the `nfc-pushtx.md` doc captured here.

### Vendored forks (excluded as non-first-party)

`electrum`, `micropython`, `HWI`, `Bitcoin.org`, `bipentropy`, `stm32lib`. These are upstream
projects mirrored for build or integration purposes and carry their own upstream licences and
authorship; nothing from them is in this collection.

## Licensing

Split, and worth stating precisely because the repo is often described simply as open source:

- **Firmware / docs.** Both `LICENSE` and `COPYING-CC` read "(c) Copyright 2020 by Coinkite Inc."
  with MIT-style permission text. The GitHub API reports the licence as `NOASSERTION`, which
  reflects the non-canonical file wording rather than an absence of permission. Children carry
  `license: "MIT (Coinkite Inc.)"`.
- **Hardware design files.** `hardware/README.md` states that copyright in the schematics and BOM
  remains with Coinkite Inc., that the material is for research and testing purposes only with no
  warranties, and that Coinkite **does NOT grant license for commercial use**. That child carries
  the narrower `license` value, and the discrepancy is noted in its ingest note.

## Provenance and integrity

- Clone was `--depth 1`; `.git/shallow` pins `43b2139…`, so only the tip commit is present. Blob
  SHAs below are from `git ls-tree -r HEAD` at that revision.
- Every child carries `revision` (the commit SHA above) and `sha` (its own blob SHA), so the
  dedup key `collection` + `upstream_id` + `revision`/`sha` is exact.
- Child bodies were verified byte-for-byte against the git blobs after ingest; 34/34 matched
  modulo the deliberate link rewriting described below.
- Images, spreadsheets, PDFs and Python helper scripts inside `docs/` and `hardware/`
  (`*.png`, `*.jpg`, `*.pdf`, `*.xlsx`, `backup.7z`, `rolls.py`, `rolls12.py`,
  `sample-electrum-wallets/`) were not ingested — they are binary or code rather than prose. The
  markdown that references them now links to the pinned GitHub copies.

### Link rewriting

Repo-relative link destinations do not resolve inside the wiki, so all of them were repointed to
absolute GitHub URLs pinned to `43b2139`. Link text and prose are unchanged. Totals across the 34
children: **44** destinations pinned as-is, **1** corrected, **3** preserved as known-dead. All
relative links were confirmed to sit in prose, not inside code fences.

### Upstream defects found

| Where | Link | Disposition |
|-------|------|-------------|
| `docs/security-model.md:49` | `[Mk4's dual secure elements.](mk4-secure-elements.md)` | **Corrected** — no such file exists at this revision; the unambiguous intended target is `docs/secure-elements.md`. Destination repointed there, link text untouched. |
| `docs/temporary-seeds.md:4,69,87` | `[_(new in v5.0.7, …)_](upgrade.md)` ×3 | **Preserved as dead** — `docs/upgrade.md` does not exist at this revision and no unambiguous intended target exists. Pinned as-is; these will 404 upstream. |

Both are recorded in the affected children's ingest notes rather than silently repaired.

## Content notes

- `docs/menu-tree.txt` is plain text, not markdown, and its meaning lives in its indentation. It
  is reproduced byte-for-byte inside a fenced `text` block; `content_format: text` in frontmatter.
- The root `README.md` at this revision opens with a **live security advisory**, not a product
  intro: firmware from 2021 to July 2026 generated poor entropy, and secrets created in that
  window should be regenerated with funds moved on chain. Trustworthy floors are 5.6.0 (Mk4/Mk5),
  1.5.0Q (Q1), 4.2.0 (Mk3), 6.6.0 (Edge). `History-Mk3.md` carries the matching warning and shows
  4.2.0 as the hotfix. This is the single most consequential fact in the collection and is
  deliberately surfaced in the topic index.
- `docs/usb-batteries.md` is a 4-line community stub. Captured for completeness of the docs set;
  its summary says so.

## Confidence

These are Coinkite's own documents. They are authoritative for **design intent and stated
guarantees** — what the device is meant to do and why — and are not independent evidence that the
guarantees hold in silicon. The security-model, secure-elements and pin-entry documents in
particular describe an adversarial design without third-party audit results attached. Treat
security claims sourced only from here as `confidence: medium`; the release histories are stronger
evidence, since they are dated records of shipped changes including the project's own bug
admissions.
