---
title: "Unified Mailbox (bark docs/mailbox.md)"
source: "https://gitlab.com/ark-bitcoin/bark/-/blob/4f1b646ae3c4387bd374d835f76719637a48b846/docs/mailbox.md"
type: articles
ingested: 2026-07-17
tags: [collection, bark-repo, ark, mailbox, delivery, privacy, hark, bolt11, bolt12, planned]
summary: "bark's optional Unified Mailbox (mostly planned): server-side notification hub for wallet-relevant events (arkoor, BOLT-11/12, non-interactive hArk refresh VTXOs). Privacy from the public but not from the server (server can link all your Ark activity)."
collection: "bark-repo"
adapter: git
upstream_id: "docs/mailbox.md"
upstream_type: git-file
revision: "4f1b646ae3c4387bd374d835f76719637a48b846"
sha: "3bbfc10b7e4b3b815303b2c5af2463924a1f07cf"
canonical_url: "https://gitlab.com/ark-bitcoin/bark/-/blob/4f1b646ae3c4387bd374d835f76719637a48b846/docs/mailbox.md"
content_format: markdown
license: "MIT"
fetched: 2026-07-17
---

# Unified Mailbox (bark docs/mailbox.md)

Part of the [[../repos/2026-07-17-collection-bark-repo-manifest.md|bark-repo collection]]. NOTE: "most of this document describes planned features that are not available yet."

- Optional bark server feature: notify users of wallet-relevant events.
- **Privacy**: "gives privacy from the public, but not from the Ark server. When you use the mailbox, the server will be able to link all your Ark activity together, but none of the parties you transact with will be able to link any of your other payments."
- **Features** (planned):
  - receiving arkoor payments
  - receiving BOLT-11 invoice payments
  - receiving BOLT-12 invoice requests
  - receiving new VTXOs after a **non-interactive hArk refresh**
  - creating arkoor addresses with a **blinded mailbox ID**
- Confirms hArk enables **non-interactive refresh** (server issues refreshed VTXOs; user picks them up from the mailbox) — corroborates the reduced-interactivity direction.
