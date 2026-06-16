---
title: Fedimint — Wiki
type: wiki-root
created: 2026-05-28
updated: 2026-06-15
scope: hub
---

# Fedimint — Wiki

Knowledge base for [Fedimint](https://fedimint.org) — a federated Chaumian e-cash protocol for
Bitcoin custody and payments. Federations are run by guardians who collectively custody Bitcoin
and issue blinded e-cash notes to users; users transact privately, with Lightning gateways
bridging the federation to the wider network.

This wiki captures Fedimint's architecture, modular design (consensus, mint, wallet, lightning,
custom modules), federation operation, custody/recovery, gateways, and the broader research
agenda — including the active question of **multi-currency / multi-denomination support** and
the practical question of **how to write Fedimint modules (in-tree and FMCM) that participate in
the multi-currency surface**.

## Layout

- `wiki/concepts/` — atomic concept articles (modules, guardians, tiered notes, gateways, trait surface)
- `wiki/topics/` — synthesizing topic articles (multi-currency status, custody model, etc.)
- `wiki/reference/` — specs, crates, RFCs, links to upstream docs
- `raw/` — ingested source material with provenance
- `output/` — generated artifacts (playbooks, design notes)
- `theses/` — testable claims for follow-up research

## Stats

- Sources ingested: 15 (0 papers, 8 articles, 7 repos)
- Articles compiled: 14 (1 topic + 12 concepts + 1 reference)
- Outputs: 1 (playbook)
- Theses: 0
- Last research session: 2026-06-15 ("writing fedimint modules using multi-currency", 6 parallel agents)

## Start here

- [[output/playbook-writing-fedimint-modules-multi-currency-2026-06-15.md|Playbook: writing modules with multi-currency support]] ⭐ — actionable answer to "how do you write a Fedimint module that supports multi-currency in 2026?"
- [[wiki/topics/fedimint-multi-currency-status.md|Multi-currency status]] — three-path framing of how Fedimint actually handles non-BTC value today
- [[wiki/concepts/server-module-trait.md|ServerModule trait]] · [[wiki/concepts/client-module-trait.md|ClientModule trait]] — the module-authoring trait surface
- [[wiki/concepts/transaction-item-amounts.md|TransactionItemAmounts]] · [[wiki/concepts/primary-module-support.md|Primary module support]] — multi-unit consensus mechanics
- [[wiki/concepts/fmcm-upgrade-tax.md|FMCM upgrade tax]] — what writing out-of-tree costs you per minor release
- [[wiki/concepts/federation-trust-model.md|Federation trust model]] — risk surface that any multi-currency proposal multiplies
- [[wiki/concepts/off-mint-payments-bridge-pattern.md|Off-mint payments-bridge pattern]] — what BitSacco / ChapSmart actually do

## Open questions

- Will Fedimint's first production non-BTC mintv2 deployment carry real backing or remain synthetic?
- Will `MintGenParams` (and `ConfigGenModuleArgs`) regain per-module `GenParams` to unblock multi-asset operator surface? (Issue #8217)
- Will `gatewayd` ship the `GatewayPaymentHandler` extension API for non-BTC LN? (Discussion #8395, unimplemented)
- Will mintv2 deprecate mintv1? (Discussion #8680 makes the technical case; no roadmap PR.)
- Do two `mintv2` instances with different `amount_unit`s actually coexist correctly under load? (Not exercised by tests.)
- Will fedimint adopt a string/enum convention for `AmountUnit` to avoid id collisions across federations? (Currently opaque `u64`.)
- Cashu's NUT-02 multi-unit pattern is a clear template — will Fedimint converge or diverge?
- What does a trustless proof-of-reserves story look like for a federation issuing multiple units?
- Where will the regulatory line fall for federations that issue fiat-pegged or commodity-pegged units?
- Does the off-mint payments-bridge pattern (BitSacco-shape) make native multi-currency economically irrelevant for emerging-market use cases?
