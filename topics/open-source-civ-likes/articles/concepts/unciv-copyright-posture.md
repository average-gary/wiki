---
title: Unciv Copyright Posture
type: concept
created: 2026-06-18
updated: 2026-06-18
confidence: high
sources:
  - raw/repos/2026-06-18-unciv.md
---

# Unciv Copyright Posture

[Unciv](../topics/unciv.md) is open about being a **"remake of Civ V"** —
not "inspired by," not generic 4X. This is unusual; many civ-clones
genericize their language to avoid drawing IP attention. Unciv does the
opposite, *and* publishes its own legal reasoning.

This article documents that reasoning, the boundaries Unciv draws, and
the tests it has not faced.

## The core legal claim — FL-108

Unciv rests its defense on **US Copyright Office circular FL-108**:
intellectual property rights do not apply to mechanics. Game *mechanics*
are not copyrightable; only *expression* is.

This is well-grounded in US case law. Tetris Holding v. Xio Interactive
(2012, D.N.J.) and Atari Games Corp. v. Oman (D.C. Cir. 1989) both
distinguish protectable expression from unprotectable mechanics. Unciv's
posture is mainstream copyright-defensible.

## The boundaries Unciv explicitly draws

The project's own FAQ admits two off-limits items:

1. *"definitely illegal to use any assets from the original game (images,
   sound etc) - they belong to Firaxis."* → **all assets must be replaced**.
2. Using *"the Civilization name"* or impersonating Civ branding is
   treated as *"probably illegal."*

The "Civilization" trademark is treated as **limited to the logo, not the
word** — but Unciv concedes this position has not been litigation-tested.

## Scope discipline as legal strategy

Unciv deliberately **refuses to add non-Civ-V features**. This is scope
discipline as a legal-defense posture:

> *Don't make Firaxis feel like you're competing on new ground.*

Stay strictly within Civ V's mechanical envelope; replace expression
(art, music, names); ship under MPL-2.0. Then any IP challenge has to
litigate FL-108 head-on.

## Tests Unciv has not faced

- **Has Firaxis publicly responded?** Not visibly. The asymmetry is
  notable: Unciv ships on Google Play, F-Droid, Steam (community version),
  the Mac Brew formula, and dozens of Linux package repositories. The
  silence is itself a data point — Firaxis's tolerance threshold is
  unclear but evidently above "shipping in major app stores."
- **Look-and-feel claim** (UI layout, art direction) — FL-108 covers
  mechanics. UI *can* attract copyright protection in some
  interpretations. Unciv's UI is not visually identical to Civ V, but
  it's recognizably civ-like; the line is blurry.
- **Trademark dilution**: even with logo-vs-word distinction, "Unciv" is
  arguably a portmanteau of "un + Civ" that traffics on the Civilization
  brand. Untested.
- **DMCA notices**: there's no public record of a DMCA takedown notice
  reaching Unciv's GitHub repo, F-Droid listing, or Google Play page.

## Why this matters for the wiki

Unciv's posture is the **best-documented OSS-civ-clone copyright stance
that has held up in production for years**. Any future civ-clone author
needs to read it; the FL-108 + asset-replacement + scope-discipline
combination is a working template.

## Comparison to other genres

OSS clones in adjacent genres take similar positions:

- **OpenRA** (Red Alert / Tiberian Dawn / Dune 2000) — engine is OSS;
  game data must be supplied separately by owning the original.
- **openage** ([covered here](../topics/landscape.md)) — same posture:
  reimplement the engine, require user-owned original assets.
- **DevilutionX** (Diablo) — engine OSS, asset extraction at runtime
  from owned MPQ.

Unciv differs by **shipping its own asset replacements** rather than
asking users to bring assets. That makes Unciv standalone-distributable
in a way OpenRA / openage / DevilutionX are not — and presumably *more*
exposed to IP challenge, not less. So far the FL-108 stance has held.

## See Also

- [Unciv](../topics/unciv.md)
- [Open Source Civ-Like Games — Landscape](../topics/landscape.md)
- [GitHub-as-mod-registry](github-as-mod-registry.md)
