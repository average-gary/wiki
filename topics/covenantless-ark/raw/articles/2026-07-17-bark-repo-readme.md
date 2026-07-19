---
title: "bark repository README"
source: "https://gitlab.com/ark-bitcoin/bark/-/blob/4f1b646ae3c4387bd374d835f76719637a48b846/README.md"
type: articles
ingested: 2026-07-17
tags: [collection, bark-repo, ark, clark, bark, captaind, second, msrv, overview]
summary: "bark repo overview: Ark implementation by Second — wallet 'bark', server 'captaind', plus protocol-primitive libraries. Client-server L2 for fast self-custodial payments; barkd (REST) and uniffi-bindings/Bark SDK for non-Rust use. ark-lib MSRV 1.74.0. MIT."
collection: "bark-repo"
adapter: git
upstream_id: "README.md"
upstream_type: git-file
revision: "4f1b646ae3c4387bd374d835f76719637a48b846"
sha: "1cd5d60c6ea823201f7c58eea5077d656c8d2825"
canonical_url: "https://gitlab.com/ark-bitcoin/bark/-/blob/4f1b646ae3c4387bd374d835f76719637a48b846/README.md"
content_format: markdown
license: "MIT"
authors: [Steven Roose, Erik De Smedt]
fetched: 2026-07-17
---

# bark repository README

Part of the [[../repos/2026-07-17-collection-bark-repo-manifest.md|bark-repo collection]].

- "Bark is an implementation of the Ark protocol on bitcoin, led by Second." Ark = "a bitcoin layer 2 for making fast, low-cost, self-custodial payments at scale... client-server model to enable users to transact off-chain while still being able to 'exit' their balances on-chain at any time."
- **Project components**:
  - The Ark wallet: **bark**
  - The Ark server: **captaind**
  - "A set of libraries containing all protocol primitives"
- **Non-Rust access**:
  - **barkd** — Ark wallet daemon exposing a REST API over HTTP; clients (TypeScript, C#) in the `barkd-clients` repo.
  - **uniffi-bindings** — for native desktop/mobile; in the `bark-ffi` repo; power the published **Bark SDK** packages.
- **Positioning vs Lightning**: "Lightning has been revolutionary... it's beginning to show its limitations — channel management and liquidity requirements." Ark: no channels to open, no on-chain setup, single off-chain balance for Ark/Lightning/on-chain payments, client-server (less complex than P2P).
- **How Ark works**: "multiple users to share control of a single bitcoin UTXO through a tree of pre-signed, off-chain transactions... users can always withdraw their bitcoin either cooperatively with the Ark server or unilaterally on-chain."
- **MSRV**: most crates unspecified; `ark-lib` (and `bark-bitcoin-ext`) MSRV **v1.74.0**.
- **Security**: report to `security@second.tech`; PGP keys `8CC974D9CFD034DCEED213B02A57E0A610D7F19C` (Steven Roose), `011E7F59B45397C4654D81298F44B2DD98E18528` (Erik De Smedt).
- **License**: MIT.
- Links: docs.second.tech, second.tech, blog.second.tech, community.second.tech.
