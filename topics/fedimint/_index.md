---
title: Fedimint — Wiki
type: wiki-root
created: 2026-05-28
updated: 2026-05-28
scope: hub
---

# Fedimint — Wiki

Knowledge base for [Fedimint](https://fedimint.org) — a federated Chaumian e-cash protocol for
Bitcoin custody and payments. Federations are run by guardians who collectively custody Bitcoin
and issue blinded e-cash notes to users; users transact privately, with Lightning gateways
bridging the federation to the wider network.

This wiki captures Fedimint's architecture, modular design (consensus, mint, wallet, lightning,
custom modules), federation operation, custody/recovery, gateways, and the broader research
agenda — including the active question of **multi-currency / multi-denomination support**.

## Layout

- `wiki/concepts/` — atomic concept articles (modules, guardians, tiered notes, gateways, etc.)
- `wiki/topics/` — synthesizing topic articles (multi-currency support, custody model, etc.)
- `wiki/reference/` — specs, crates, RFCs, links to upstream docs
- `raw/` — ingested source material with provenance
- `output/` — generated artifacts (playbooks, design notes)
- `theses/` — testable claims for follow-up research

## Stats

- Sources ingested: 9 (0 papers, 7 articles, 2 repos)
- Articles compiled: 8 (1 topic + 6 concepts + 1 reference)
- Outputs: 0
- Theses: 0
- Last research session: 2026-05-28 (initial round, "fedimint multi-currency support", 5 parallel agents)

## Start here

- [[wiki/topics/fedimint-multi-currency-status.md|Multi-currency status]] ⭐ — three-path framing of how Fedimint actually handles non-BTC value today
- [[wiki/concepts/federation-trust-model.md|Federation trust model]] — risk surface that any multi-currency proposal multiplies
- [[wiki/concepts/off-mint-payments-bridge-pattern.md|Off-mint payments-bridge pattern]] — what BitSacco / ChapSmart actually do

## Open questions

- Will Fedimint's first production non-BTC mintv2 deployment carry real backing or remain synthetic?
- Does the off-mint payments-bridge pattern (BitSacco-shape) make native multi-currency economically irrelevant for emerging-market use cases?
- Cashu's NUT-02 multi-unit pattern is a clear template — will Fedimint converge or diverge?
- What does a trustless proof-of-reserves story look like for a federation issuing multiple units?
- Where will the regulatory line fall for federations that issue fiat-pegged or commodity-pegged units?
