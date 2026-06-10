---
title: CLINK origin and stewardship
type: concept
created: 2026-06-09
updated: 2026-06-09
confidence: high
sources:
  - raw/repos/2026-06-09-origin-shocknet-clink-repo.md
  - raw/articles/2026-06-09-origin-shock-network-homepage.md
  - raw/articles/2026-06-09-origin-clinkme-dev-contact.md
  - raw/repos/2026-06-09-origin-shocknet-ecosystem-history.md
---

# CLINK origin and stewardship

## Founding date

**2025-05-05 18:17 UTC** — first commit to `github.com/shocknet/CLINK`, message "CLINK Initial Spec Commit", author `shocknet-justin`.

## The pattern predates the spec

ShockNet shipped the CLINK pattern in production code **8 months before the spec was written**:

- **2024-09-06** — `shocknet/clink-demo` first commit (HTML, by hatim boufnichel / boufni95)
- **2024-09-08** — `shocknet/bridgelet` first commit, described verbatim as "**LNURL and NIP-05 service powered by Nostr Offers**" — the term "Nostr Offers" predates the formal CLINK noffer naming

CLINK is a formalization of an already-shipping pattern. This makes it lower-risk to build on than a fresh-paper spec — implementation experience is older than the spec.

## Authors / contributors

GitHub's contributors API for `shocknet/CLINK` returns exactly **two** people:

| Login | Identity | Contributions |
|-------|----------|---------------|
| `shocknet-justin` | Justin (ShockNet) | 38 commits |
| `boufni95` | Hatim Boufnichel | 2 commits |

`shocknet-justin` is also the **sole publicly-listed member** of the ShockNet GitHub org. His personal profile:
- Bio: "Lightning Bitcoin and Nostr"
- Company: "@shocknet"
- Blog: shock.network
- Twitter: @shocknet_justin
- Telegram: t.me/justin_shocknet
- Stacker News bio: *"Relentlessly Lightning Maxxing @ Lightning.Video | ShockWallet.app"*
- GitHub badge: Arctic Code Vault Contributor (long-time OSS contributor since 2017-12-02)

`boufni95`'s public GitHub uses no real name, but commits to other ShockNet repos identify him as **Hatim Boufnichel**. He is the primary author of ClinkSDK and clink-demo. Pattern: **Justin specifies, Hatim implements.**

## Identity equivalence: CLINK npub = ShockNet npub = Justin's npub

The Nostr public key
`npub1xvtwx6tduaxnn9v3y7uasskl277achgu0tu2qncmc7hdsz6y2zyqce64sa`
appears as the contact key on **both** clinkme.dev/contact.html and shock.network. There is no separate "CLINK Foundation" or "CLINK Working Group" Nostr identity. CLINK speaks with ShockNet's voice and ShockNet speaks with Justin's voice.

For wallet implementers verifying CLINK announcements, NIP-05 cross-references, or signed spec updates, the **trust anchor is one key**. If that key is compromised or rotated, both ShockNet and CLINK would need to coordinate a key migration simultaneously. There is no documented key-rotation process.

## Funding

VC-backed:

- Wolf Venture Capital
- Ride Wave Ventures
- **Fulgur Ventures** (Lightning-focused fund; Strike, Voltage, Fedi, Zeus alumni)

GitHub Sponsors via the org is the only on-repo funding channel. **Not** in any visible Bitcoin grant program (OpenSats, HRF Bitcoin Development Fund, Spiral, Brink) as of 2026-06-09. CLINK is therefore funded out of ShockNet's own VC runway, not by public grants.

The Fulgur connection plausibly explains Zeus Wallet's early CLINK Offers integration — Zeus is also Fulgur-portfolio.

## Governance posture

The README declares a five-step contribution process:

> 1. Discussion (open an issue)
> 2. Implementation (working code first)
> 3. Documentation (PR with spec update)
> 4. Review (community feedback)
> 5. Acceptance ("Merge when consensus is reached")

Operationally, however:
- Every spec-changing PR has been authored or merged by `shocknet-justin`.
- `boufni95`'s PRs are limited to in-place edits.
- The single open issue (#6, Namecoin discovery, by external `mstrofnone`) sits unmerged and without maintainer response.

This is **maintainer-led single-vendor governance** — closer to NWC's early NIP-47 days than to BOLT12 / BLIPs multi-implementer process.

The README also includes two notable governance principles:
> "There should be no more than one way of doing the same thing." — explicit "TIMTOWTDI is bad" stance, contra LNURL's accreted alphabet soup.
>
> "Specifications should leverage Nostr's inherent capabilities." — the "Nostr-native or it doesn't belong here" test.

## Spec evolution timeline

| Date | Event |
|------|-------|
| 2018-03-08 | ShockNet GitHub org created |
| 2019-10-17 | Lightning.Pub repo seeded |
| 2022-11-17 | wallet2 (current ShockWallet) seeded — first explicit Nostr in product framing |
| 2022-11-27 | SMART relay seeded |
| 2024-09-06 | clink-demo first commit |
| 2024-09-08 | bridgelet first commit ("LNURL and NIP-05 service powered by Nostr Offers") |
| 2024-11-16 | SanctumDK (remote-signer component) seeded |
| 2025-05-05 | **CLINK spec repo created** |
| 2025-05-26 | ClinkSDK first commit |
| 2025-06-25 | First draft of CLINK Manage |
| 2025-07-05 | GitHub Discussions opened with welcome announcement |
| 2025-07-31 | CLINK Manage spec merged (kind 21003 lands) |
| 2025-08-11 | ShockWallet `v0.0.20-beta` ships first Manage support |
| 2025-09-05 | Stacker News ships CLINK recv |
| 2025-09-14 | Stacker News ships CLINK send |
| 2025-10-18 | NymRank seeded (alternative NIP-05 discovery) |
| 2026-05-18 | Issue #6 opens (Namecoin discovery proposal) |
| 2026-06-01 | First reported cross-wallet noffer zap (Zeus ↔ ShockWallet) |
| 2026-06-09 | README rewritten + ecosystem table; revised debit `k1` wording (PR #8) merged — **public launch / 1.0-readiness moment** |

There was an **8-month spec-quiet period from August 2025 to April 2026**, corresponding to the time when reference-implementation work (Lightning.Pub, ShockWallet, ClinkSDK) was driving CLINK forward instead of spec churn.

## Direct quotes (governance-relevant)

> "All CLINK specifications are public domain."

> "Implementation First: New specifications should demonstrate working implementations."

> "There should be no more than one way of doing the same thing."

> "Specifications should leverage Nostr's inherent capabilities (identity, events, encryption)."

## What's missing

- No public ROADMAP.md
- No formal multi-vendor RFC process
- No security disclosure address
- No code of conduct or CLA
- No mailing list / newsletter / Substack
- No track record of conference appearances (Nostrasia, Bitcoin++, BTC Prague — none confirmed in public record reachable from research)
- No Bitcoin Optech newsletter mention as of 2026-06-09

## Open questions

- Is the Nostr key on contact.html Justin's everyday key or a project-only signing key? (Almost certainly the former — same key on stacker.news.)
- Will Justin accept Namecoin discovery (#6), or push NymRank as the official answer?
- What does "Merge when consensus is reached" mean operationally — solo-decide, or private channel with Zeus / SN / Bridgelet implementers?
- Is there a written ShockNet quarterly roadmap?
- Is there a CLINK paid offering or commercial license behind the scenes funding the open spec? VC funding usually requires a revenue thesis; the public surface doesn't yet show one.
- Will CLINK ever spawn a separate "CLINK Working Group" identity to decouple from ShockNet's commercial interests?

## See also

- [[clink-overview.md]]
- [[../topics/clink-roadmap-signals.md]]
- [[../reference/specs-and-repos.md]]
