---
title: "How Decentralized is Bluesky Really?"
source_url: "https://dustycloud.org/blog/how-decentralized-is-bluesky/"
type: article
path: case
date_ingested: 2026-05-27
date_published: 2024-11-22
tags: [case-study, decentralized, bluesky, atproto, activitypub]
quality: 5
confidence: high
summary: "Christine Lemmer-Webber (ActivityPub co-author) argues Bluesky/ATProto is not meaningfully decentralized — it's a centralized 'Twitter replacement with credible exit.' Highly relevant precedent for what happens when a 'decentralized' app launches but everyone uses the company PDS."
---

# How Decentralized is Bluesky Really?

## Key findings

ATProto is architecturally a "shared heap" model — all content flows through centralized Relays that must process essentially all network data. ActivityPub uses message passing — only relevant servers receive relevant messages. The cost shape is dramatically different.

Empirical centralization signals:
- Relay storage requirements grew from 1TB (July 2024) to 5TB (November 2024) — 5x in four months. Effectively impossible for hobbyists to run a full Relay.
- `did:plc` identity remains controlled by Bluesky despite decentralization claims.
- Bluesky custodially holds most users' cryptographic keys.
- Nearly all handles map to `*.bsky.social`.
- Direct messages route entirely through Bluesky infrastructure — fully centralized, no federation at all.

## Notable quotes / specifics

- The author proposes Bluesky should rebrand as pursuing "credible exit" rather than claiming decentralization — more honest given actual architecture.
- The mail analogy: ActivityPub is "Alyssa writes a piece of mail to Ben, she sends it directly to Ben." Bluesky is "letters are dumped at a post office (called a 'relay')" for filtering.
- Migration between PDSes provides minimal actual independence because identity and DMs remain centralized.

## Source notes

This is the single most important case study for any project marketed as "decentralized" — empirical evidence that even a well-funded, technically competent team launching with decentralization as core marketing ends up de facto centralized. The lesson: "decentralized" is what users say they want; "credible exit" is what they actually use. Build for the latter.
