# coldcard

> COLDCARD — Coinkite's Bitcoin hardware wallet. Dual-secure-element key storage, PIN and anti-phishing design, Trick PINs and duress wallets, backup and secret-transfer schemes, reproducible builds, and the shipped-change record across the Mk3, Mk4/Mk5 and Q product lines.

Last updated: 2026-08-10

## Statistics

- Sources: 35 raw documents (1 collection manifest + 34 children)
- Articles: 21 compiled wiki articles (13 concepts, 3 topics, 5 references, 0 theses)
- Outputs: 0 generated artifacts
- Last compiled: 2026-08-10
- Last lint: 2026-08-10

## Quick Navigation

- [All Sources](raw/_index.md)
- [All Articles](wiki/_index.md)
- [Concepts](wiki/concepts/_index.md)
- [Topics](wiki/topics/_index.md)
- [References](wiki/references/_index.md)
- [Outputs](output/_index.md)
- [Configuration](config.md)
- [Activity Log](log.md)

## Scope

See [config.md](config.md) for full scope. In brief: the COLDCARD hardware wallet as documented by
Coinkite itself — an STM32L4 device with one or two secure elements, sourced from the
`coldcard/firmware` repository's `docs/` tree, its architecture READMEs, and the per-model release
histories, all pinned to revision `43b2139`.

## Read This First

The repository README at this revision opens with a **live security advisory**, not a product
introduction: firmware from 2021 to July 2026 contained a bug producing **poor entropy**, and any
secrets generated on a Coldcard in that window should be regenerated with funds moved on chain
immediately. Master seeds are stated trustworthy only from releases after:

| Line | Fixed version |
|------|---------------|
| Mk4, Mk5 | 5.6.0 |
| Q1 | 1.5.0Q |
| Mk3 | 4.2.0 |
| Edge (Mk/Q) | 6.6.0 |

A BIP-39 passphrase mitigates some risk, but only to the extent of the entropy the passphrase
itself adds; dice rolls contribute 2.5 bits each. See
[firmware README](raw/articles/2026-08-10-coldcard-firmware-readme.md) and
[Mk3 release history](raw/articles/2026-08-10-coldcard-release-history-mk3.md), where 4.2.0 is
recorded as the hotfix for legacy hardware. Any article touching seed generation, backup or
recovery must carry this context.

Compiled treatment: [The 2026 entropy advisory](wiki/concepts/entropy-advisory-2026.md)
(`volatility: hot`). Entry points for the compiled wiki are
[COLDCARD — overview](wiki/topics/coldcard-overview.md) and the
[Model and version matrix](wiki/references/model-and-version-matrix.md).

## Source Highlights

The substance of this ingest sits in five documents:

- **[Security Model](raw/articles/2026-08-10-coldcard-security-model.md)** — the design goal stated
  plainly: SE1, SE2 *and* the MCU must all be compromised before the seed leaks. Also the fullest
  account of the Trick PIN menagerie, and of Delta Mode, which differs from the true PIN only in its
  last four digits and deliberately produces invalid signatures to defend against an attacker who
  already holds the XPUB.
- **[Secure Elements](raw/articles/2026-08-10-coldcard-secure-elements.md)** — the dual-vendor
  argument (ATECC608 and DS28C36B, so one vendor's bug is unlikely to be the other's), the exact
  key-splitting construction, and a striking deliberate asymmetry: SE2 *cannot* validate a PIN at
  all, has no rate limiting and a 6ms attempt rate, so the entire rate-limiting burden rests on SE1.
- **[PIN Entry](raw/articles/2026-08-10-coldcard-pin-entry.md)** — 818 lines, the largest source
  here. The two-BIP-39-word anti-phishing response as an evil-maid detector, the brick-me PIN that
  rolls the pairing secret to a forgotten value with no delay, and the duress wallet that opens
  silently as though it were the wallet you chose.
- **[Limitations](raw/articles/2026-08-10-coldcard-limitations.md)** — Coinkite's own catalogue of
  what the device refuses to do. The fastest route to an accurate answer about multisig ceilings,
  PSBT sizes, SIGHASH policy, fee guards and slot accounting.
- **[Seed XOR](raw/articles/2026-08-10-coldcard-seed-xor.md)** — splitting one BIP-39 seed into N
  parts that are each themselves valid BIP-39 seeds, so every part can hold honeypot funds and any
  strict subset is a different valid wallet. Includes paper-computable worked examples.

## Notes on This Ingest

- **Symlink dedup.** The requested scope named 37 files, but three are git symlinks:
  `History-Mk4.md` and `History-Mk5.md` both point at `History-Mk.md`, and
  `stm32/mk4-bootloader/README.md` points at `stm32/bootloader/README.md`. 34 distinct blobs became
  34 children; the aliases are tabulated in the
  [manifest](raw/repos/2026-08-10-collection-coldcard.md).
- **Licensing is split.** Firmware and docs are MIT-style, but `hardware/README.md` states that the
  schematics and BOM remain Coinkite copyright, are for research and testing only, and that
  commercial use is **not** licensed.
- **Two broken upstream links.** `security-model.md` linked a non-existent
  `mk4-secure-elements.md`; the unambiguous target was `secure-elements.md` and the destination was
  corrected. `temporary-seeds.md` links `upgrade.md` three times and no such file exists at this
  revision — preserved as dead rather than guessed at. Both are recorded in the affected children.
- **These are first-party documents.** Authoritative for design intent, not independent evidence
  that the guarantees hold in silicon. No third-party audit results are attached to any of them.

## Open Questions

Not answered by the ingested docs; would need source reading or external research:

- Are there published third-party audits or teardowns of the Mk4/Mk5/Q dual-SE design, and do they
  corroborate the split-key construction as documented?
- What was the actual root cause of the 2021–2026 entropy bug? The tip commit here
  (`rng: discard 12 words after SEIS clear per RM0432 32.3.7`) hints at STM32 TRNG conditioning —
  the linked Coinkite backgrounder would settle it.
- How does the SE1 attempt counter interact with Trick PIN slots in practice — can a duress or
  countdown PIN be used to exhaust or manipulate the main PIN's attempt accounting?
- What does `ckcc-protocol` expose over USB, and how much of the on-device policy (Spending Policy,
  2FA, warnings) is enforceable only on-device versus negotiable by the host?
- ~~How does the Coldcard threat model compare with distributed-key approaches such as FROST (see
  hub topic `frostsnap`) — single-device hardening versus splitting the key across locations?~~
  **Answered 2026-08-10** by thesis research in the `frostsnap` wiki: the two models are near-inverses
  (per-device hardening with dual SEs and trick PINs, versus threshold distribution with no per-device
  PIN or secure element), and the roots of trust cannot emulate each other — see
  [Root-of-trust portability](../frostsnap/wiki/concepts/root-of-trust-portability.md). Practically,
  Coldcard already meets the threshold goal on its own terms: EDGE ships MuSig2 on Mk4 with a
  vendor-documented t-of-n taptree policy — see
  [Threshold signing paths on Coldcard](../frostsnap/wiki/topics/threshold-signing-paths-on-coldcard.md).

## Recent Changes

- 2026-08-10: Compiled 35 raw sources into 21 articles — 13 concepts, 3 topics, 5 references, 232 cross-references. One `hot` article: [The 2026 entropy advisory](wiki/concepts/entropy-advisory-2026.md).
- 2026-08-10: Topic wiki created. Scoped collection ingest of `coldcard/firmware` @ `43b2139` — 35 raw sources.
