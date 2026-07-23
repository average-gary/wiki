---
title: "Can a miner open a Lightning channel with a coinbase output? (Bitcoin StackExchange #115588)"
source: "https://bitcoin.stackexchange.com/questions/115588/can-a-miner-open-a-lightning-channel-with-a-coinbase-output"
type: article
subtype: community-qa
retrieved: 2026-07-23
tags: [lightning, coinbase, funding, channel-open, stackexchange, coinbase-maturity]
credibility: low
evidence_strength: community-qa
direction: "nuances (supports feasibility of Reading B, cautions on practicality)"
bears_on: [B]
verification_note: "Direct fetch to bitcoin.stackexchange.com was blocked in the research environment; content recovered via search-engine snippets. Treat quotes as approximate and re-verify against the live page before relying on wording."
summary: "The thesis in miniature, asked publicly: can a standard 2-of-2 P2WSH funding output be provided as a coinbase output to open a channel? The community answer frames it as possible but impractical — the objection is the 100-block maturity period, not legality — matching the BOLT channel_ready coinbase rule."
---

# StackExchange #115588 — coinbase output to open a channel

> ⚠️ Content recovered via search snippets (direct fetch blocked). Re-verify wording.

- Question (the thesis in miniature): **"Assuming that the funding transaction uses
  a P2WSH output, can we open a channel by providing that standard 2-of-2 multisig as
  the coinbase output?"**
- Answer snippet: **"it would be impractical to open a channel with a coinbase
  output. For one, there is the maturation period for coinbase outputs. Since
  coinbase outputs can only be spent after 100 confirmations…"** — framed as
  **possible but impractical**, not impossible.

## Bearing on the thesis

- A low-credibility but exactly-on-point corroboration of Reading B: the 2-of-2
  funding scriptPubKey *can* be a coinbase output; the objection is latency/reorg
  (the 100-block maturity), not legality — matching the BOLT `channel_ready` coinbase
  rule and the consensus `COINBASE_MATURITY` constant from the higher-tier sources.
