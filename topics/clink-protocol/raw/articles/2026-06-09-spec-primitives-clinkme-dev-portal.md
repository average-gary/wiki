---
title: "clinkme.dev — CLINK protocol portal (specs.html / index / apps.html)"
source: https://clinkme.dev
type: article
ingested: 2026-06-09
path: spec-primitives
quality: 4
credibility: high
tags: [clink, nostr, lightning, portal, specs, ecosystem]
---

## Source overview

clinkme.dev is the official portal for the CLINK protocol. Three pages were inspected: the homepage (high-level positioning + three primitives), specs.html (renders spec content client-side from /specs Markdown), and apps.html (compatible apps directory). It serves as the public-facing index over the GitHub spec repo.

## Key findings

- Tagline / definition: CLINK = "Common Lightning Interface for Nostr Keys" — "defines Nostr-native standards for Lightning Network interactions, leveraging the protocol's built-in transport, identity, and encryption."
- Three primitives shown on homepage:
  - **CLINK Offers** — "Static Payment Codes": "Request invoices over Nostr with a reusable string. No web server needed."
  - **CLINK Debits** — "Direct Payment Requests": "Authorize external Nostr accounts to pay invoices without pre-shared secrets."
  - **CLINK Manage** — "Delegated Permissions": "Enable marketplace apps to automatically manage payment offers for your node."
- Stated benefits: simplified UX via direct/spontaneous interactions, reduced infrastructure dependency by operating entirely over Nostr, enhanced security through signed events.
- Public domain status confirmed.
- specs.html is a client-side render — it fetches and displays the GitHub-hosted markdown specs. Direct fetch returns "Loading…" pending JS execution; canonical content is in the GitHub repo.
- Apps page categorizes ecosystem entries:
  - **Wallets**: ShockWallet (Offers + Debits, https://shockwallet.app), ZEUS (Offers, https://zeusln.app — "ZEUS Pay automatically furnishes offers to its users")
  - **Node/Wallet servers**: Lightning.Pub (Offers + Debits, https://lightning.pub) — implied reference implementation
  - **Apps/Utilities**:
    - Bridgelet (https://github.com/shocknet/bridgelet) — "Simple NIP-05, LNURL and Lightning Address bridge for your custom domain" (Offers)
    - CLINK SDK — JavaScript/TypeScript library (Offers + Debits)
    - Stacker News (https://stacker.news) — Offers
    - TakeMySats (https://takemysats.com) — Offers ("Merchant platform, accept sats as payment")
- No app shown supports Manage yet (as of 2026-06-09 listing). Manage is the newest primitive (PR #4 merged 2025-07-31).

## Cited identifiers/keys

- Domain: clinkme.dev
- Pages: /index, /specs.html, /apps.html, /contact.html
- Linked GitHub: github.com/shocknet/CLINK
- Reference wallet: ShockWallet
- Reference server: Lightning.Pub
- SDK: @shocknet/clink-sdk (npm)

## Direct quotes

- "Common Lightning Interface for Nostr Keys"
- "Request invoices over Nostr with a reusable string. No web server needed."
- "Authorize external Nostr accounts to pay invoices without pre-shared secrets."
- "Enable marketplace apps to automatically manage payment offers for your node."
- "All CLINK specifications are public domain."

## Open questions surfaced

- Which app/wallet pairs are interoperable end-to-end vs. only ShockWallet ↔ Lightning.Pub?
- Does ZEUS implement noffer parsing/payment, and does it use a generic Nostr relay or pin to specific ones?
- Are any non-shocknet wallets (Phoenix, Mutiny, Zeus, Alby) on a roadmap to support CLINK?
- Does the CLINK SDK target browser, Node.js, React Native, or all three?
- What's the actual deployment scale — pilot, niche, or production?

## Why this source matters for the topic

The portal anchors how the project markets itself and which ecosystem partners ShockNet acknowledges. It grounds the spec in real-world adoption claims and lists the apps that any compatibility/maturity assessment needs to verify. Combined with the GitHub repo, it gives a complete picture of the protocol's primary surfaces.
