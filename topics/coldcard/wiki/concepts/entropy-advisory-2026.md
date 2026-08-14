---
title: "The 2026 entropy advisory"
category: concept
sources:
  - raw/articles/2026-08-10-coldcard-firmware-readme.md
  - raw/articles/2026-08-10-coldcard-release-history-mk3.md
  - raw/articles/2026-08-10-coldcard-release-history-mk4-mk5.md
  - raw/articles/2026-08-10-coldcard-release-history-q.md
  - raw/repos/2026-08-10-collection-coldcard.md
created: 2026-08-10
updated: 2026-08-10
tags: [coldcard, entropy-bug, security-advisory, seed-generation, trng, hotfix, bip-39]
aliases: ["Coldcard entropy bug", "poor entropy advisory", "2026 seed generation warning"]
confidence: high
volatility: hot
verified: 2026-08-10
summary: "Coldcard firmware from 2021 through July 2026 generated seeds with poor entropy. Coinkite's advisory says regenerate and move funds on chain. Fixed-version floors are 5.6.0 (Mk4/Mk5), 1.5.0Q (Q1), 4.2.0 (Mk3) and 6.6.0 (Edge). Volatility hot: this is a live advisory at the pinned revision and the root cause is not documented in these sources."
---

# The 2026 entropy advisory

> The `coldcard/firmware` README at revision `43b2139` does not open with a product description. It
> opens with a warning that seeds generated on the device over a five-year window were produced with
> **poor entropy**, and that affected secrets should be regenerated with funds moved on chain.

This is the single most consequential fact in the entire source collection, and every article in
this wiki that touches seed generation, backup or recovery carries a pointer back here — a standing
convention of this topic.

## Fixed-version floors

Coinkite states master seeds are trustworthy only from releases **after**:

| Line | Fixed version | Released |
|------|---------------|----------|
| Mk4, Mk5 | 5.6.0 | after 5.5.1 (2026-07-01) |
| Q1 | 1.5.0Q | after 1.4.1Q (2026-07-01) |
| Mk3 | 4.2.0 | 2026-07-31 |
| Edge (Mk/Q) | 6.6.0 | — |

Note what the historic changelogs do and do not show. `History-Mk.md` ends at **5.5.1** and
`History-Q.md` ends at **1.4.1Q**, both dated 2026-07-01 — i.e. *before* the fix on those lines,
with the note "See ChangeLog.md for more recent changes". So the fixed releases for Mk4/Mk5 and Q
are not described in the sources ingested here at all. Only Mk3's fix is:

> ## 4.2.0 - July 31, 2026
> - Hotfix to correct entropy bug and allow new seed generation on old hardware.

That one line is the clearest record in the collection of how the advisory was resolved for legacy
hardware. `History-Mk3.md` also carries the standing banner:

> **July 2026: Do not generate seeds on Mk3 hardware without 4.2.0 fixed version.
> Move funds to new seeds or a BIP-39 derived secret.**

with a pointer to `blog.coinkite.com/coldcard-mk3-seed-generation-warning/`.

## What the advisory says about mitigation

Two partial mitigations appear in the README, both qualified:

- **A BIP-39 passphrase** mitigates some risk — but only to the extent of the entropy the passphrase
  itself contributes. It does not repair the underlying seed.
- **Dice rolls** contribute about 2.5 bits each. The device has enforced statistical minimums since
  5.1.0 (at least 50 rolls for 12 words, 99 for 24), which bounds how badly a user can undermine
  their own entropy but says nothing about the firmware's own TRNG path.

The Mk3 banner's phrasing — "move funds to new seeds **or a BIP-39 derived secret**" — is the
practical instruction: derive fresh material rather than trusting what the device generated.

## Root cause: not documented here

None of the 35 ingested sources explains the defect. The strongest available hint is the tip commit
of the pinned revision itself:

```
43b2139  scgbckbone <scgbckbone@proton.me>  2026-08-04
rng: discard 12 words after SEIS clear per RM0432 32.3.7
```

RM0432 is the STM32L4+ reference manual and §32.3.7 covers TRNG error management — the "discard N
words after clearing the seed-error interrupt flag" discipline. That points at the STM32 hardware
RNG's conditioning path rather than at, say, a software PRNG seeding bug, but this is inference from
a commit subject, not a documented cause. The Coinkite blog backgrounder linked from the Mk3 history
would settle it and is not in scope for this ingest.

Note also that the tip commit is dated **2026-08-04**, four days after the Mk3 hotfix — RNG work was
still landing at the revision pinned here.

## Why this is `volatility: hot`

Three reasons:

1. It is a **live advisory** at the pinned revision, not a historical incident.
2. The **fixed releases on two of four lines are outside the ingested sources**, so the version table
   above is drawn from the README's claim rather than from changelog entries describing those
   releases.
3. **RNG commits were still landing** at the tip. Any re-ingest at a later revision is likely to
   change this article materially.

Re-verify against a newer revision of `README.md`, plus `ChangeLog.md` (not ingested), before
relying on the version floors.

## Scope boundary

The advisory is about **seed generation on the device**. It does not, on the evidence here, implicate:

- seeds imported from elsewhere (typed words, XPRV import, Tapsigner backup, Seed XOR restore);
- the signing path, PIN handling or secure-element key hierarchy;
- BIP-85 derivation from an unaffected master seed.

But a seed generated on affected firmware taints everything derived from it — duress wallets, BIP-85
children, Seed XOR splits and encrypted backups all inherit the problem, which is why those articles
cross-reference here rather than treating themselves as independent.

## See Also

- [[coldcard-overview|COLDCARD — overview]] ([COLDCARD — overview](../topics/coldcard-overview.md)) — the anchor article; leads with this advisory
- [[security-architecture|Security architecture]] ([Security architecture](../topics/security-architecture.md)) — the defences this bug bypassed entirely
- [[seed-generation-and-derivation|Seed generation and derivation]] ([Seed generation and derivation](seed-generation-and-derivation.md)) — TRNG, dice rolls, BIP-85, and what the advisory affects
- [[release-timeline|Release timeline]] ([Release timeline](../references/release-timeline.md)) — where 4.2.0 sits, and where the Mk4/Q histories stop
- [[encrypted-backup-and-transfer|Encrypted backup and transfer]] ([Encrypted backup and transfer](encrypted-backup-and-transfer.md)) — backup passphrases are TRNG-generated too
- [[seed-xor|Seed XOR]] ([Seed XOR](seed-xor.md)) — random-mode splits draw from the same TRNG
- [[model-and-version-matrix|Model and version matrix]] ([Model and version matrix](../references/model-and-version-matrix.md)) — per-line version floors in context
- [[firmware-authenticity-and-upgrades|Firmware authenticity and upgrades]] ([Firmware authenticity and upgrades](firmware-authenticity-and-upgrades.md)) — the firmware-defect case with no recovery key sequence
- [[temporary-seeds-and-seed-vault|Temporary seeds and Seed Vault]] ([Temporary seeds and Seed Vault](temporary-seeds-and-seed-vault.md)) — seeds generated on-device for vault entries are in scope
- [[trick-pins-and-duress-wallets|Trick PINs and duress wallets]] ([Trick PINs and duress wallets](trick-pins-and-duress-wallets.md)) — BIP-85 duress wallets inherit the master seed's entropy

## Sources

- [Firmware README](../../raw/articles/2026-08-10-coldcard-firmware-readme.md) — the verbatim advisory and the four fixed-version floors
- [Mk3 release history](../../raw/articles/2026-08-10-coldcard-release-history-mk3.md) — standing banner and the 4.2.0 hotfix entry
- [Mk4/Mk5 release history](../../raw/articles/2026-08-10-coldcard-release-history-mk4-mk5.md) — ends at 5.5.1, before the fix
- [Q release history](../../raw/articles/2026-08-10-coldcard-release-history-q.md) — ends at 1.4.1Q, before the fix
- [Collection manifest](../../raw/repos/2026-08-10-collection-coldcard.md) — the pinned revision and its RNG-related tip commit
