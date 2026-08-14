---
title: Wiki articles
type: index
updated: 2026-08-10
---

# Wiki articles (21)

| Layer | Count |
|---|---|
| [[concepts/_index\|Concepts]] | 13 |
| [[topics/_index\|Topics]] | 3 |
| [[references/_index\|References]] | 5 |
| [[theses/_index\|Theses]] | 0 |

## Start here

- [[topics/coldcard-overview|COLDCARD — overview]] ([COLDCARD — overview](topics/coldcard-overview.md)) — anchor article
- [[concepts/entropy-advisory-2026|The 2026 entropy advisory]] ([The 2026 entropy advisory](concepts/entropy-advisory-2026.md)) — read before generating any seed (volatility: hot)
- [[references/model-and-version-matrix|Model and version matrix]] ([Model and version matrix](references/model-and-version-matrix.md)) — check any capability claim against a model and a version

## Topics

- [[topics/coldcard-overview|COLDCARD — overview]] ([COLDCARD — overview](topics/coldcard-overview.md))
- [[topics/security-architecture|Security architecture]] ([Security architecture](topics/security-architecture.md))
- [[topics/airgap-signing-workflows|Air-gapped signing workflows]] ([Air-gapped signing workflows](topics/airgap-signing-workflows.md))

## Concepts

- [[concepts/entropy-advisory-2026|The 2026 entropy advisory]] ([The 2026 entropy advisory](concepts/entropy-advisory-2026.md)) (volatility: hot)
- [[concepts/dual-secure-element-design|Dual secure-element design]] ([Dual secure-element design](concepts/dual-secure-element-design.md))
- [[concepts/pin-entry-and-rate-limiting|PIN entry and rate limiting]] ([PIN entry and rate limiting](concepts/pin-entry-and-rate-limiting.md))
- [[concepts/anti-phishing-words|Anti-phishing words]] ([Anti-phishing words](concepts/anti-phishing-words.md))
- [[concepts/trick-pins-and-duress-wallets|Trick PINs and duress wallets]] ([Trick PINs and duress wallets](concepts/trick-pins-and-duress-wallets.md))
- [[concepts/seed-generation-and-derivation|Seed generation and derivation]] ([Seed generation and derivation](concepts/seed-generation-and-derivation.md))
- [[concepts/seed-xor|Seed XOR]] ([Seed XOR](concepts/seed-xor.md))
- [[concepts/encrypted-backup-and-transfer|Encrypted backup and transfer]] ([Encrypted backup and transfer](concepts/encrypted-backup-and-transfer.md))
- [[concepts/temporary-seeds-and-seed-vault|Temporary seeds and Seed Vault]] ([Temporary seeds and Seed Vault](concepts/temporary-seeds-and-seed-vault.md))
- [[concepts/spending-policy-and-two-factor|Spending Policy and two-factor]] ([Spending Policy and two-factor](concepts/spending-policy-and-two-factor.md))
- [[concepts/firmware-authenticity-and-upgrades|Firmware authenticity and upgrades]] ([Firmware authenticity and upgrades](concepts/firmware-authenticity-and-upgrades.md))
- [[concepts/reproducible-builds-and-developer-access|Reproducible builds and developer access]] ([Reproducible builds and developer access](concepts/reproducible-builds-and-developer-access.md))
- [[concepts/connectivity-and-nfc|Connectivity and NFC]] ([Connectivity and NFC](concepts/connectivity-and-nfc.md))

## References

- [[references/model-and-version-matrix|Model and version matrix]] ([Model and version matrix](references/model-and-version-matrix.md))
- [[references/release-timeline|Release timeline]] ([Release timeline](references/release-timeline.md))
- [[references/device-limits|Device limits]] ([Device limits](references/device-limits.md))
- [[references/signing-formats|Signing formats and standards]] ([Signing formats and standards](references/signing-formats.md))
- [[references/memory-map-and-key-slots|Memory map and key slots]] ([Memory map and key slots](references/memory-map-and-key-slots.md))

## Reading notes

- **Every capability claim is model-gated and version-gated.** The same menu path may be absent on an
  apparently identical device; check
  [[references/model-and-version-matrix|Model and version matrix]]
  ([Model and version matrix](references/model-and-version-matrix.md)) before quoting a feature.
- **These sources are first-party.** All 34 raw sources are Coinkite's own design docs and changelogs
  at revision `43b2139`. Articles resting only on design-doc assertions carry `confidence: medium` and
  attribute claims to Coinkite rather than stating them as verified properties.
- **Upstream inconsistencies are reproduced, not corrected** — the 2065-03-05 date typos, the duplicated
  5.3.3 heading, the 1 MB vs 2 MB PSBT disagreement, the Mk3 pairing-secret address given two ways.
  Each is flagged in the article that carries it.
