---
title: "shocknet/CLINK — repo metadata, commit history, contributors, PRs"
source: https://github.com/shocknet/CLINK
type: repo
ingested: 2026-06-09
path: origin
quality: 5
credibility: high
tags: [clink, shocknet, history, governance, contributors, commit-history, founding-date]
---

# Source overview

The canonical CLINK specification repository. GitHub API metadata, full commit
log, contributors list, FUNDING.yml, and the open/closed PR history together
provide the most authoritative record of who started CLINK, when, and how the
spec has evolved. All quotes below are pulled from the GitHub API
(`gh api repos/shocknet/CLINK/...`) on 2026-06-09.

# Key findings

## Repo identity

- **Full name:** `shocknet/CLINK`
- **Description:** "Common Lightning Interface for Nostr Keys"
- **Homepage:** https://clinkme.dev
- **Created:** **2025-05-05T18:13:05Z** — this is the founding date of CLINK as
  a published, named protocol.
- **Default branch:** `main`
- **License field:** `null` (the README states "All CLINK specifications are
  public domain.")
- **Topics:** `bitcoin, bolt11, lightning, lightning-network, nostr,
  nostr-protocol`
- **Stars (2026-06-09):** 22 — small but non-trivial; matches a year-old single-
  vendor spec with growing third-party uptake.
- **Forks:** 1
- **Has discussions:** true (only one pinned discussion: "Welcome to CLINK
  Discussions!" by shocknet-justin, 2025-07-05).

## Funding model (FUNDING.yml)

```yaml
# These are supported funding model platforms

github: [shocknet,]
```

The only funding channel declared inside the repo is **GitHub Sponsors pointed
at the `shocknet` organization**. There is no OpenSats, HRF, Spiral, Geyser,
or per-developer funding link. This corroborates the picture that CLINK is
funded out of ShockNet's own runway (with VC backing — see shock.network
source) rather than by a Bitcoin grant program.

## Authors / contributors (canonical)

GitHub's contributors API returns exactly **two** people:

| Login | Real name | Contributions to CLINK spec repo |
|-------|-----------|----------------------------------|
| `shocknet-justin` | Justin (shocknet) | 38 |
| `boufni95` | (resolved as "hatim boufnichel" in earlier ShockNet repos) | 2 |

`shocknet-justin`'s public GitHub profile:
- Name: "Justin (shocknet)"
- Bio: "Lightning Bitcoin and Nostr"
- Company: "@shocknet "
- Blog: shock.network
- Location: US
- Twitter: **@shocknet_justin**
- Telegram (linked from profile): https://t.me/justin_shocknet
- Joined GitHub: 2017-12-02
- Achievement badge: "Arctic Code Vault Contributor" (predates ShockNet — long-
  time OSS contributor)

`boufni95`:
- No public name on his own profile, but commits to other ShockNet repos
  (clink-demo, ClinkSDK) are authored as **"hatim boufnichel"**, identifying
  him as the second core ShockNet engineer.
- 28 public repos, GitHub member since 2017-11-09 — predates Justin's account
  by less than a month, suggesting they joined GitHub around the same time and
  have been collaborators for the ~8-year run of ShockNet.
- Contribution role: smaller author share on CLINK itself (2 commits) but
  primary author on the **ClinkSDK** TypeScript library and **clink-demo**
  (where he authored `first commit` in both repos), i.e. boufni95 implements,
  Justin specifies.

Public org members (`gh api orgs/shocknet/members`) returns only
**shocknet-justin** — Justin is the sole publicly listed member, consistent
with him being the founder/lead and the org's other contributors keeping their
membership private.

## First-commit history (origin trail)

Earliest commits to CLINK (oldest first; date | author | message):

```
2025-05-05T18:17:19Z | shocknet-justin | CLINK Initial Spec Commit
2025-05-05T18:38:27Z | shocknet-justin | copy
2025-05-06T14:50:22Z | shocknet-justin | versioning
2025-05-06T14:55:05Z | Justin (shocknet) | Merge pull request #1 from shocknet/master
2025-05-06T15:06:44Z | shocknet-justin | nip-05 update
2025-05-11T20:04:03Z | shocknet-justin | fix slop changes
2025-05-15T19:31:19Z | shocknet-justin | copy
```

The literal commit "**CLINK Initial Spec Commit**" on **2025-05-05 at 18:17 UTC**
by `shocknet-justin` is therefore the protocol's birthday in the public record.
The "fix slop changes" commit message a week in is interesting — Justin
appears to be the human curator on top of LLM-assisted drafting.

## Spec evolution timeline (PR-driven)

Pulled from the closed PR list:

| PR # | Title | Author | Created | Merged |
|------|-------|--------|---------|--------|
| 1 | Master | shocknet-justin | 2025-05-06 | 2025-05-06 |
| 2 | restore error codes | shocknet-justin | 2025-06-20 | 2025-06-26 |
| 3 | Update clink-manage.md | boufni95 | 2025-06-25 | 2025-06-25 |
| 4 | Manage | shocknet-justin | 2025-06-26 | 2025-07-31 |
| 7 | Update clink-debits.md | boufni95 | 2026-06-01 | 2026-06-01 |
| 8 | revise debit k1 | shocknet-justin | 2026-06-02 | 2026-06-09 |
| 9 | Readme | shocknet-justin | 2026-06-09 | 2026-06-09 |
| 10 | add takemysats | shocknet-justin | 2026-06-09 | 2026-06-09 |

Reading the gaps:
- **May 2025**: spec drafted (Offers + Debits)
- **June–July 2025**: `clink-manage.md` (delegated management, kind 21003)
  designed and merged — the third pillar of CLINK lands ~2 months in.
- **August 2025–April 2026**: a **~8-month quiet period** in the spec repo
  itself; one solo "field fix" commit on 2025-08-01 and "invoice expiry and
  desc" on 2025-09-16. This corresponds to the period when Justin was
  presumably driving Lightning.Pub / ShockWallet / Bridgelet / ClinkSDK
  reference implementations rather than spec churn.
- **June 2026**: a flurry of revisions — `clink-debits.md` revised, k1
  consumption clarified, QR standard added, README rewritten with logos for
  Zeus, Stacker.News, ShockWallet (sn), TakeMySats. The June 2026 churn maps
  to the public-launch moment when third-party wallets started shipping.

## Open issues — only one

A single open issue (#6, 2026-05-18) titled
**"CLINK over Namecoin: NIP-05 discovery without HTTPS"** by external
contributor `mstrofnone`. It proposes Namecoin-backed NIP-05 as a way to
finally close CLINK's last HTTPS dependency in the discovery leg. The issue
is open and unresolved — telling about CLINK's governance: external proposals
do reach the maintainer, but spec changes still flow through Justin.

## Governance signals

From the README "Contributing" section the project's stated process is:

1. Discussion (open an issue)
2. Implementation (working code first)
3. Documentation (PR with spec update)
4. Review (community feedback)
5. Acceptance ("Merge when consensus is reached")

But the **operational reality** from PRs is single-vendor: every spec-changing
PR was authored or merged by shocknet-justin; boufni95's PRs are limited to
in-place edits of files Justin owns; the only external proposal (issue #6)
is open and unmerged. This is a lightly-RFC-flavored, **maintainer-led
single-vendor governance model** — closer to NWC's early NIP-47 days than
to the Bolt12 / BLIPs multi-implementer process.

# Timeline events (concrete dates)

- **2018-03-08** — `shocknet` GitHub organization created.
- **2024-09-06** — `shocknet/clink-demo` first commit (by hatim boufnichel /
  boufni95). The CLINK *idea* therefore predates the public spec by ~8 months.
- **2024-09-08** — `shocknet/bridgelet` first commit ("Initial commit" by
  Justin) — LNURL/NIP-05 service "powered by Nostr Offers", the precursor.
- **2025-05-05 18:13 UTC** — `shocknet/CLINK` repo created.
- **2025-05-05 18:17 UTC** — "CLINK Initial Spec Commit" by shocknet-justin.
- **2025-05-26** — `shocknet/ClinkSDK` first commit by boufni95.
- **2025-06-13** — first draft of CLINK Manage (delegated management).
- **2025-07-05** — public Discussions opened with welcome announcement.
- **2025-07-31** — CLINK Manage spec merged (kind 21003 lands).
- **2026-05-18** — Namecoin discovery proposal opened by external contrib
  mstrofnone (issue #6, still open).
- **2026-06-01** — first real CLINK noffer zap between Zeus and ShockWallet
  (per justin_shocknet stacker.news post).
- **2026-06-09** — README rewritten and ecosystem table (Zeus, Stacker.News,
  TakeMySats, etc.) added; revised `clink-debits.md` k1 wording merged. This
  is effectively the **public launch / 1.0-readiness moment**.

# Direct quotes

> "Common Lightning Interface for Nostr Keys"
— GitHub repo description.

> "All CLINK specifications are public domain."
— README.md, Contributing/License section.

> "Implementation First: New specifications should demonstrate working
> implementations."
— README.md governance rule.

> "There should be no more than one way of doing the same thing."
— README.md governance rule (a clear "TIMTOWTDI is bad" stance, contra
LNURL's accreted alphabet soup).

> "Specifications should leverage Nostr's inherent capabilities (identity,
> events, encryption)."
— README.md governance rule (the "Nostr-native or it doesn't belong here"
test).

# Open questions

- Is there a written CLINK roadmap document anywhere? The repo has no
  `ROADMAP.md`, no GitHub Project board, and only one open issue. The
  forward-looking signals come from README's ecosystem table and Justin's
  social posts, not from the spec repo.
- Will hold-invoices be standardized as a CLINK kind (e.g., 21004), or kept
  out-of-spec and left to NWC? README and specs are silent.
- Is splice / channel-management functionality (the "node-ops" pillar)
  planned, or is `clink-manage` the maximum scope?
- What does "Merge when consensus is reached" mean operationally — does
  Justin solo-decide consensus, or is there a private channel of
  implementers (ShockNet + Zeus + Bridgelet + StackerNews) that vets
  changes? PRs do not reveal this.
- Will Justin accept a Namecoin discovery section into the spec (issue #6)?
  The answer will reveal whether CLINK governance can absorb truly external
  contributions.
- Is the spec versioning scheme (referenced by 2025-05-06 commit "versioning")
  documented anywhere? No `VERSION` or `CHANGELOG` is visible in the repo
  contents listing.

# Why this matters

The repo metadata is the only place that ties down with timestamps and
authorship the otherwise-fuzzy story of "who runs CLINK". It establishes:
(a) the protocol is **single-author, single-vendor** at spec level —
shocknet-justin is the BDFL; (b) it is **funded by ShockNet's own runway**
(GitHub Sponsors → org), not by Bitcoin grant programs; (c) the **clear
founding date of 2025-05-05** for citation purposes; (d) a **maturity ramp
from May 2025 → June 2026** that lines up with reference-implementation
development rather than spec churn — useful for assessing whether CLINK is
"stable enough to build on" in mid-2026.
