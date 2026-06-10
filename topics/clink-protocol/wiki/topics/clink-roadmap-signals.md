---
title: CLINK roadmap signals
type: topic
created: 2026-06-09
updated: 2026-06-09
confidence: medium
sources:
  - raw/repos/2026-06-09-origin-shocknet-clink-repo.md
  - raw/articles/2026-06-09-origin-shock-network-homepage.md
  - raw/repos/2026-06-09-origin-shocknet-ecosystem-history.md
  - raw/articles/2026-06-09-spec-primitives-clink-issue-6-namecoin.md
---

# CLINK roadmap signals

CLINK has **no public ROADMAP.md, no project board, and only one open issue.** Direction must be inferred from ShockNet's adjacent repo activity and the README's ecosystem table. This page collects the signals.

Confidence is "medium" because the read is structural rather than authoritative — ShockNet has not published explicit forward-looking statements.

## What's actually happening (June 2026)

The June 2026 spec churn maps to a **public-launch / 1.0-readiness moment**:

- README rewritten with ecosystem table (Zeus, Stacker.News, ShockWallet, TakeMySats, Bridgelet, BXRD).
- Revised debit `k1` spec merged (PR #8, 2026-06-09).
- First reported cross-wallet noffer zap (Zeus ↔ ShockWallet) on 2026-06-01.
- ShockWallet `v0.0.28-beta` released 2026-06-06 with "update clink / noffer."

The 8-month spec-quiet period from August 2025 to April 2026 ended; the focus is now cross-vendor adoption.

## Signal 1: Discovery without HTTPS — NymRank, not Namecoin

The single open issue (#6, Namecoin discovery proposal by `mstrofnone`, 2026-05-18) sits unmerged with no maintainer response. Meanwhile ShockNet seeded its own [NymRank](https://github.com/shocknet/NymRank) repo on 2025-10-18, described as "Namespace for nostr based on social consensus."

**Read**: ShockNet has its own preferred answer (NymRank, Web-of-Trust over Nostr) and is unlikely to merge Namecoin support as-is. Expect a "CLINK over NymRank" pattern to appear before Namecoin support.

## Signal 2: Self-hosted node UX — Lightning.Pub one-click

Repo progression: Wizard (2019) → Umbrel (2021) → test-umbrel-store (2025-07). ShockNet is committed to making Lightning.Pub a one-click home-server install. CLINK's spec design (NIP-05 entry point, Lightning.Pub webhook integration, ephemeral payer keys) is built around this end-state — the family/SMB self-hosted node, not the SaaS custody node.

## Signal 3: Delegated signing — Sanctum + Manage convergence

[SanctumDK](https://github.com/shocknet/SanctumDK) (2024-11) is ShockNet's embedded component for Sanctum Remote Signer. It dovetails with `clink-manage.md` (delegated management, kind 21003).

**Speculative**: a "CLINK delegated signing" pattern combining Sanctum + clink-manage is plausible. This would close the revocation gap at the implementation layer (Sanctum can revoke delegations) even if the spec stays silent. Whether this gets formalized as a spec extension or stays implementation-specific is the open question.

## Signal 4: Nostr-native social — BXRD as consumer wedge

[BXRD.app](https://bxrd.app) is ShockNet's Nostr social client (per CLINK README, ships "Debit integration for Zaps"). The README ecosystem entry frames it as the consumer-facing showcase of CLINK Debits.

**Caveat**: bxrd.app's live landing page makes no CLINK reference as of 2026-06-09 — production-status uncertain. The README ecosystem-table claim and the live UX are not yet aligned.

## Signal 5: Streaming / video — Lightning.Video subscriptions

ShockNet has had a streaming/video theme since 2020 (`seed` repo for WebTorrent + Livestreaming over Lightning) and surfaces today as Lightning.Video. Justin's Stacker News bio: *"Relentlessly Lightning Maxxing @ Lightning.Video | ShockWallet.app"*.

CLINK Debits' recurring-budget shape (`{number, unit ∈ day|week|month}`) is the obvious primitive for streaming/subscription monetization. **Speculative roadmap item**: "CLINK debits for streaming sats/sec" — but no spec text exists for this yet.

## Signal 6: Wider wallet adoption is the immediate priority

Fresh README entries (Zeus default for ZEUS Pay users; Stacker.News send/receive zap wallet via CLINK) imply cross-vendor uptake is the immediate priority over new spec kinds. The **Fulgur Ventures connection** (Fulgur is investor in both ShockNet and Zeus) plausibly explains why Zeus was first; expect other Fulgur-portfolio wallets next.

## What is NOT on the indicated path

These features are **not** signaled by any ShockNet repo or README:

- **Hold invoices / `holdinvoice`** (BOLT11 add_index style, or NWC-style `make_hold_invoice`/`settle_hold_invoice`/`cancel_hold_invoice`). The CLINK Offers spec uses standard BOLT11 invoices end-to-end.
- **Channel/peer/routing management** (no analog to NWC's `get_info`, no LNDg-style RPCs).
- **Splices over CLINK**.
- **Multi-vendor RFC process** (no separate `clink-rfcs` repo, no invitation to other vendors to co-maintain).
- **BOLT12 bridge** (no `shocknet/bolt12-bridge` repo).
- **Rust SDK** — conspicuous gap given LDK/CDK/Iroh integration potential. Unblocks node-side integrations across the Rust Lightning stack. Not visible on github.com/shocknet.
- **Conference appearances** — no specific Nostrasia / Bitcoin++ / BTC Prague talk for CLINK was confirmed in research. Bitcoin Optech newsletter has zero CLINK mentions.

## Implication: CLINK's likely scope ceiling

A wiki reader expecting CLINK to evolve into a full Lightning-control protocol that competes with NWC's full RPC surface should adjust expectations downward. CLINK's signaled scope is:

- Identity-and-payment-flow protocol (Offers, Debits, Manage)
- Discovery hardening (NymRank)
- Wallet UX (BXRD, ShockWallet)
- Delegated signing (Sanctum + Manage)
- Reference server (Lightning.Pub one-click)

**Not**: a node-RPC replacement, a hold-invoice manager, a channel-control surface. NWC and CLINK are likely to coexist as **complementary, not competing**, from ShockNet's perspective.

## Open questions

- Will Justin accept a Namecoin discovery section into the spec (#6)? Or will NymRank be the official answer?
- Is NymRank intended as a replacement for the NIP-05/HTTPS hop or as additive option?
- Is the Sanctum Remote Signer being designed to deliberately back clink-manage delegations, or is the convergence accidental?
- What is `PlebCafe`? Empty repo, undescribed; could be the next CLINK-flavored consumer app.
- Is there a CLINK paid offering or commercial license behind the scenes? VC funding usually requires a revenue thesis; the public surface doesn't yet show one.
- Is there a written ShockNet quarterly roadmap update anywhere? Not surfaced in any repo, website, or social post discoverable from research.
- Will hold-invoices ever land as kind 21004 or are they out-of-scope?

## See also

- [[../concepts/clink-overview.md]]
- [[../concepts/clink-origin-and-stewardship.md]]
- [[../concepts/clink-discovery-and-nip05.md]]
- [[../concepts/clink-manage.md]]
