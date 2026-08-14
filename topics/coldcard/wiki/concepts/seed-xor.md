---
title: "Seed XOR"
category: concept
sources:
  - raw/articles/2026-08-10-coldcard-seed-xor.md
  - raw/articles/2026-08-10-coldcard-temporary-seeds.md
  - raw/articles/2026-08-10-coldcard-release-history-mk3.md
  - raw/articles/2026-08-10-coldcard-release-history-q.md
created: 2026-08-10
updated: 2026-08-10
tags: [coldcard, seed-xor, bip-39, seed-backup, plausible-deniability, xor, seedplate, open-standard]
aliases: ["SeedXOR", "split seed backup", "seedxor.com"]
confidence: high
volatility: cold
verified: 2026-08-10
summary: "Splits one BIP-39 seed into N parts that are each themselves a valid BIP-39 seed of the same length, recombined by bit-wise XOR. All N parts are required because any strict subset is a different valid wallet. Covers the checksum-bit exclusion, deterministic vs TRNG part generation, the paper-computable procedure, the duress applications, and the ways the scheme leaks."
---

# Seed XOR

> The metal-backup problem: a SEEDPLATE survives fire, but it stores a cleartext secret that anyone
> holding it can spend. Encrypted digital backups are not discreet and you can be compelled to
> produce the passphrase. Seed XOR's answer is to make **each part look exactly like an ordinary
> wallet**, so there is nothing to identify as a share of anything.

Seed XOR is an **open standard** — Coinkite explicitly grants use of the name and requires no
licence, asking only that implementations match the documented process and interoperate.

## The construction

Take N BIP-39 phrases of the same length (12, 18 or 24 words) and XOR them together bit by bit. The
result is another phrase of the same length. Because XOR is commutative and associative, **parts
combine in any order**.

The subtlety is the checksum. Each part's final word carries a normal BIP-39 checksum, which is what
makes the part a valid standalone wallet — but **those checksum bits are excluded from the XOR**:

| Seed length | Checksum bits excluded |
|-------------|-----------------------|
| 24 words | last 8 bits |
| 12 words | last 4 bits |

So each part's checksum protects that part's own integrity, and the reassembled seed gets its
checksum recomputed from the XOR result. On paper you can determine every word of the result except
the final one, whose leading hex digit(s) are known but whose checksum bits need SHA256 — which is
why the worked examples end with `final word between: gas [300] - lend [3FF]` and then name the
correct word. For 24-word XOR there is exactly **one** valid final word in the indicated range once
the other 23 are entered.

## Stated properties

- Every part **looks and operates as a valid BIP-39 wallet** — importable anywhere, fundable.
- Parts **combine in any order**.
- **You must have all parts.** Any strict subset is itself a valid Seed XOR wallet — a *different*
  one — so a partial collection yields a plausible but wrong wallet rather than an error.
- **No new recording tools needed.** Each part is an ordinary phrase and fits a standard SEEDPLATE.
- **Up to N-1 parts leak nothing** about the original.

That third property is the one that does the deniability work: finding two of three plates does not
tell an attacker they have two of three.

## Generating parts

`Advanced > Danger Zone > Seed Functions > Seed XOR > Split Existing`, choosing 2, 3 or 4 parts,
then choosing how the parts are drawn:

- **Deterministic.** `double-SHA256` over the fixed string `Batshitoshi`, your master secret, and the
  per-part text `0 of 4 parts` (0-based index). The advantage is repeatability — you can re-split
  tomorrow and confirm you wrote the words down correctly.
- **TRNG.** Random bytes from the device's true random number generator, double-SHA256'd, sized to
  the secret: 16, 24 or 32 bytes for 12, 18 or 24 words.

Either way only N-1 parts are generated this way; the **final part is the XOR of the others against
your secret**, and Coinkite notes it contains just as much entropy as the rest.

Because TRNG mode draws from the device's random number generator, seeds and parts produced on
affected firmware are in scope for the 2026 advisory — see
[[entropy-advisory-2026|The 2026 entropy advisory]]
([The 2026 entropy advisory](entropy-advisory-2026.md)).

## Restoring, and using parts as temporary seeds

`Advanced/Tools > Danger Zone > Seed Functions > SeedXOR > Restore Seed XOR`, supplying all parts.
Pressing `(2)` activates the restored seed as a **temporary seed** rather than adopting it as the
master — useful for checking a balance without committing. See
[[temporary-seeds-and-seed-vault|Temporary seeds and Seed Vault]]
([Temporary seeds and Seed Vault](temporary-seeds-and-seed-vault.md)).

From 1.3.0Q the Q can import parts as **SeedQR** codes and can XOR an arbitrary file supplied as a
(BB)QR share.

## Duress applications

The docs are direct about this: splitting a seed multiplies the coercion games available. You can
fund individual parts and subsets so that none is obviously empty, then "give up" all but one part
and the attacker still gets nothing usable. Any two existing SEEDPLATEs you already hold can be
imported together to create a **new** wallet that is their XOR — no re-engraving needed.

See [[trick-pins-and-duress-wallets|Trick PINs and duress wallets]]
([Trick PINs and duress wallets](trick-pins-and-duress-wallets.md)) for the on-device counterpart.

## Where it leaks

Coinkite documents the leaks rather than burying them, and they are worth restating:

- **Recording the original's checksum word** alongside the parts (recommended, so you can confirm
  correct reassembly) **reveals 3 bits of your real wallet** and confirms to a holder that a correct
  subset has been assembled.
- **Deterministic mode is detectable.** An attacker who has all N parts can import them into a
  Coldcard, split again deterministically, and see whether they get the same values. Matching values
  prove the seed was split by a Coldcard; non-matching means either TRNG mode or an incomplete set —
  which itself is information.
- The scheme is **N-of-N only**. There is no threshold recovery: lose one plate and the seed is gone.
  That is the deliberate trade against Shamir-style schemes, which leak the existence of a threshold
  structure.

## Practical note on hand-rolled parts

If you pick parts yourself (words drawn from a hat), you still need each part's checksum word to be
valid. The documented trick: on a fresh Coldcard with no secret, enter 23 words and the device offers
the 8 possible final words; pick one, record it, then cancel the import.

## Version history

| Version | Change |
|---------|--------|
| 4.1.0 (Mk3) | Seed XOR introduced — split, restore, paper-computable, SEEDPLATE-compatible |
| 1.3.0Q | Import parts via SeedQR; XOR an arbitrary file supplied as a (BB)QR share |

## Evidence status

`confidence: high` — unusually for this topic. Seed XOR is a pure specification with two fully worked
examples (24-word and 12-word, 3 parts each) and an XOR lookup table, so the mechanism is verifiable
on paper without trusting the device. What remains first-party-only is the claim about *practical*
deniability, which is a judgement about attackers rather than a property of the maths.

## See Also

- [[encrypted-backup-and-transfer|Encrypted backup and transfer]] ([Encrypted backup and transfer](encrypted-backup-and-transfer.md)) — the other backup route, and its different trade-offs
- [[seed-generation-and-derivation|Seed generation and derivation]] ([Seed generation and derivation](seed-generation-and-derivation.md)) — TRNG, dice rolls, BIP-39 and BIP-85
- [[temporary-seeds-and-seed-vault|Temporary seeds and Seed Vault]] ([Temporary seeds and Seed Vault](temporary-seeds-and-seed-vault.md)) — restoring a split as a temporary seed
- [[trick-pins-and-duress-wallets|Trick PINs and duress wallets]] ([Trick PINs and duress wallets](trick-pins-and-duress-wallets.md)) — on-device coercion responses
- [[entropy-advisory-2026|The 2026 entropy advisory]] ([The 2026 entropy advisory](entropy-advisory-2026.md)) — TRNG-mode parts are in scope
- [[coldcard-overview|COLDCARD — overview]] ([COLDCARD — overview](../topics/coldcard-overview.md)) — product context
- [[release-timeline|Release timeline]] ([Release timeline](../references/release-timeline.md)) — 4.1.0 and 1.3.0Q in context

## Sources

- [Seed XOR](../../raw/articles/2026-08-10-coldcard-seed-xor.md) — the specification, checksum-bit exclusion, `Batshitoshi` derivation, XOR table, worked examples, leak disclosures
- [Temporary seeds](../../raw/articles/2026-08-10-coldcard-temporary-seeds.md) — restoring a Seed XOR as a temporary seed
- [Mk3 release history](../../raw/articles/2026-08-10-coldcard-release-history-mk3.md) — 4.1.0 introduction
- [Q release history](../../raw/articles/2026-08-10-coldcard-release-history-q.md) — 1.3.0Q SeedQR and file-share import
