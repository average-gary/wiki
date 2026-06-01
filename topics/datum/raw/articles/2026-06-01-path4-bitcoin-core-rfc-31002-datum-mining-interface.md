---
title: "Bitcoin Core issue #31002 — RFC: DATUM mining interface requirements"
source: "https://github.com/bitcoin/bitcoin/issues/31002"
type: articles
tags: [datum, ocean, bitcoin-core, mining-interface, stratum-v2, sjors, luke-jr, prior-art, governance]
summary: "Sjors opened bitcoin/bitcoin#31002 (2024-09-30) asking whether the new Bitcoin Core Mining IPC interface — designed with Stratum V2 in mind — needs additional methods for DATUM. The thread became the most public technical exchange between SV2-aligned Core developers and OCEAN's Luke Dashjr about DATUM's relationship to SV2-era infrastructure. luke-jr's 2024-10-05 comment is the single most direct on-record OCEAN-side statement of the SV2 stance: 'Bitcoin Core has been working toward trying to centrally dictate mining policy, so should really not be used for mining... there is already a generic/standard mining interface: getblocktemplate. It has worked for years and nothing additional is needed for DATUM.' Issue closed without action."
confidence: high
ingested: 2026-06-01
ingested_by: path4
quality_score: 5
canonical_url: "https://github.com/bitcoin/bitcoin/issues/31002"
---

# Bitcoin Core RFC #31002 — DATUM mining interface requirements

The cleanest single-link record of the political/technical stance OCEAN takes toward the SV2-aligned Bitcoin Core mining stack. Sjors plays interlocutor; luke-jr plays the OCEAN side; josibake plays "let's keep the interface generic"; jonatack provides the "DATUM is going public" timeline.

## Issue framing (Sjors, 2024-09-30)

Sjors's opening is deferential and probing:

> "The Mining interface is designed with Stratum v2 in mind, and can likely also be used to incrementally improve Stratum v1 applications. Ocean recently announced DATUM. It could be a good test for [this interface's generality]."

Methods listed in the proposed Bitcoin Core `Mining` IPC interface (relevant to any future DATUM-Core integration):

- `getTip()`
- `waitTipChanged()`
- `createNewBlock()` (with `BlockCreateOptions`)
- `processNewBlock()`
- `testBlockValidity()`

Plus proposals from related PRs:
- `getCoinbaseMerklePath()` and `submitSolution()` (PR #30955)
- `waitFeesChanged()` (Sjors#52)

## josibake (2024-10-02) — generic interface argument

> "I think this highlights a clear advantage of having a more 'generic' mining interface exposed over an IPC interface: different mining protocols can use the same interface from Bitcoin Core, without needing protocol specific changes for each protocol to be implemented in Bitcoin Core. As you mentioned, our current interface is designed with SV2 in mind, but given this is all relatively new code, it would be great to hear from the folks building DATUM whether or not this interface works out of the box and if not, what changes to the generic interface would be needed."

The cooperative ask was made.

## jonatack (2024-10-02) — DATUM source release timeline

> "I believe it may be MIT-licensed and public soon. Edit: was confirmed to me with an ETA of Oct 18 or before."

This dates DATUM's open-sourcing precisely; matches the public-beta launch that Atlas21 reported on Oct 2 referencing Oct 18 release.

## luke-jr (2024-10-05) — the OCEAN stance, on record

The most-quoted line in this whole research path. Verbatim:

> "Bitcoin Core has been working toward trying to centrally dictate mining policy, so should really not be used for mining. OCEAN/DATUM's goal is to decentralise mining, not merely switch the central dictator from Bitmain/Foundry to Bitcoin Core.
>
> That being said, there is already a generic/standard mining interface: getblocktemplate. It has worked for years and nothing additional is needed for DATUM."

Two explicit positions:
1. **Political:** Core's mining-policy work is treated as a centralising threat that DATUM is positioned against. OCEAN is building DATUM partly *because* it does not want to depend on Core's mining IPC, since that interface (according to luke-jr) reflects Core's policy preferences.
2. **Technical:** GBT (Getblocktemplate, BIP 22/23, 2012) is sufficient for DATUM. The new IPC interface adds nothing.

This is also where the SV2 ambient framing leaks in — the Core IPC was *designed for SV2*, so by rejecting the IPC, luke-jr is implicitly rejecting the SV2-aligned Core path. Not the SV2 wire protocol per se, but the assembly Core-IPC + SV2 the SRI ecosystem assumes.

## Sjors (2024-12-13) — practical reading of DATUM gateway

After reviewing the public DATUM Gateway README (no spec), Sjors enumerates two practical wins:

> "1. No need to tell users to manually set `-blockmaxsize` and `-blockmaxweight`, because `createNewBlock()` can pass a custom coinbase weight reservation through its `BlockCreateOptions` argument."
>
> "2. No need to use `-blocknotify` (which launches `datum_gateway` and presumably then calls `getblocktemplate`). Instead `datum_gateway` could run as a daemon and call `waitTipChanged()` and `waitNext()`."

Sjors confirms in passing:

> "Looking at the 'Template/Share Requirements for Pooled Mining' I don't see any blocking issues at first glance."

Translation: the Core `Mining` IPC could host DATUM's template-side logic with no spec changes.

## luke-jr (2024-12-21) — partial concession

> "Seems like it would be trivial to add this [coinbase weight reservation] to GBT. The current approach in Knots isn't ideal (since it would override blockmaxsize/weight if the miner intentionally sets them lower)."

He concedes the technical point but redirects: *fix GBT, don't migrate to the new IPC*. And:

> "GBT does already support longpolling, however, it's just not implemented in DATUM Gateway yet (see https://github.com/OCEAN-xyz/datum_gateway/issues/3)"

So DATUM's `-blocknotify` dependency is acknowledged as an artifact, not a design choice.

Closing position:

> "Seems like this would be better suited to a PR on the datum_gateway repo."

i.e., DATUM stays on its own track. No upstreaming to Core.

## Sjors (2024-12-24) — closes the thread

> "My only goal here is to figure out if the Mining interface needs anything for DATUM that it doesn't need for Stratum v2. Whether you actually use it is up to you of course."

Issue subsequently closed.

## Why this matters for the SV2-downstream-DATUM-proxy

1. **The OCEAN team will not converge with the SV2-aligned Core stack.** A proxy that wants to interoperate with DATUM upstream cannot rely on any future Core-side bridge — OCEAN has explicitly opted out of that path. The proxy must be a standalone bridge.
2. **GBT is the ground truth on the OCEAN side.** Anything DATUM consumes is downstream of `getblocktemplate`. The proxy doesn't need Core-IPC; it can lean on the same surface DATUM does.
3. **luke-jr's "central dictator" framing is the political cover.** OCEAN's decision to ignore SV2 is not purely technical; it is partly an expressed distaste for Core's mining-policy direction. SV2's success is bundled (in OCEAN's view) with Core's IPC. So an SV2-front proxy must not market itself as a Core-aligned project to the OCEAN side.
4. **The conversation has been dormant since Dec 2024.** No follow-ups, no DATUM-side spec submission, no Core-side accommodation. The two camps are not in active dialogue.

## Cross-references

- [Issue #146 in datum_gateway](https://github.com/OCEAN-xyz/datum_gateway/issues/146) (covered by path1) — the inverse direction: a contributor proposing SV2 inside DATUM. Same dynamic of OCEAN team being non-committal.
- PR #30955 in bitcoin/bitcoin — `getCoinbaseMerklePath`, `submitSolution` (Mining IPC additions).
- PR #31283 in bitcoin/bitcoin — `waitNext()` (mining IPC longpoll).
- PR #31384 in bitcoin/bitcoin — `-maxcoinbaseweight` discussion.

## Rabbit-hole leads

- Did anyone build a Core-IPC <-> DATUM bridge after this thread closed? Search bitcoin-dev list and GitHub for "DATUM Mining IPC" in 2025.
- jonatack's Oct 18 ETA — is there an OCEAN announcement post-MIT-licensing that mentions Core IPC explicitly?
- josibake — has she written follow-up about DATUM's relationship to Core's mining plumbing?

## Source

- Comments thread fetched via [api.github.com/repos/bitcoin/bitcoin/issues/31002/comments](https://api.github.com/repos/bitcoin/bitcoin/issues/31002/comments) on 2026-06-01.
