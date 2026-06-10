---
title: "shocknet/CLINK GitHub repository — protocol spec home"
source: https://github.com/shocknet/CLINK
type: repo
ingested: 2026-06-09
path: spec-primitives
quality: 5
credibility: high
tags: [clink, nostr, lightning, shocknet, spec, repository, canonical]
---

## Source overview

The shocknet/CLINK GitHub repository is the canonical home for the Common Lightning Interface for Nostr Keys (CLINK) protocol specifications. It hosts the three primary specs (offers / debits / manage), repository assets (logos, architecture diagram), and serves as the coordination point for the protocol's evolution.

## Key findings

- CLINK = "Common Lightning Interface for Nostr Keys" — Nostr-native standards for Lightning Network interactions, leveraging Nostr's built-in transport, identity, and encryption.
- All CLINK specifications are released under public domain.
- Three specs live in `/specs/`: `clink-offers.md`, `clink-debits.md`, `clink-manage.md`.
- Three Nostr event kinds are reserved: **21001 (Offers), 21002 (Debits), 21003 (Manage)** — all in the ephemeral kind range (20000-29999).
- Three bech32 HRP prefixes are introduced: `noffer1...`, `ndebit1...`, `nmanage1...`.
- All event content payloads are encrypted with **NIP-44**.
- A mandatory `["clink_version", "1"]` tag appears on every CLINK event for protocol disambiguation/versioning.
- Repository structure: `.github/`, `specs/`, `CLINK_dark.svg`, `CLINK_light.svg`, `README.md`, `diagram.png`.
- The CLINK SDK is published as separate npm package `@shocknet/clink-sdk` (not part of this repo).
- Repo activity (as of 2026-06-09): 8 merged PRs, 1 open issue (#6 — Namecoin/NIP-05 alternative discovery).
- Recent PRs include #8 "revise debit k1" (Jun 9 2026), #4 "Manage" (Jul 31 2025) merging the Manage spec, and #7/#3 doc updates by contributor boufni95.
- The framing positions CLINK as an alternative to NWC (Nostr Wallet Connect), LNURL, and BOLT12 for Lightning UX over Nostr.

## Cited identifiers/keys

- Event kinds: **21001** (Offers), **21002** (Debits), **21003** (Manage)
- Bech32 HRPs: `noffer`, `ndebit`, `nmanage`
- Tag: `["clink_version", "1"]`
- `["p", "<recipient_pubkey>"]` tag on requests
- `["e", "<request_event_id>"]` tag on responses
- Encryption: NIP-44
- Encoding base: NIP-19 (bech32)
- Related: NIP-05 (identity discovery via well-known JSON), NIP-57 (zaps)

## Direct quotes

- "Common Lightning Interface for Nostr Keys"
- "All CLINK specifications are public domain."
- "Nostr-native standards for Lightning Network interactions, leveraging the protocol's built-in transport, identity, and encryption."

## Open questions surfaced

- Is the CLINK SDK feature-complete for all three primitives, or only Offers/Debits as the apps page implies?
- Does Lightning.Pub serve as the canonical reference implementation for the server side (it's referenced as such on apps.html), or is it consumer-only?
- What changed in PR #8 "revise debit k1" — does this break clients written to an earlier spec?
- The Manage spec only defines the `offer` resource; what other resources are planned (debit policies? account balances? routing config?)

## Why this source matters for the topic

This is the canonical, authoritative source for the protocol. Every claim about CLINK's wire format, event kinds, and primitives must trace back here or be considered third-party interpretation. It also reveals governance posture (single-org public-domain spec curated by shocknet-justin with light contributor involvement).
