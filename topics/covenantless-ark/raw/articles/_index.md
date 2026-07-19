---
title: articles
type: raw-subindex
---

# articles

- [[2026-07-16-implementations-arkade-os-docs.md]] — Arkade OS official docs: batch-swap lifecycle, forfeit, checkpoint txs, intents (Q5)
- [[2026-07-16-implementations-second-bark-docs.md]] — Second's bark docs: round lifecycle, hash-lock vs connector forfeits (Q5) **[SUPERSEDED by the 2026-07-17 collection below]**

### second.tech/docs Learn-section collection (ingested 2026-07-17)

- [[2026-07-17-second-tech-docs-learn-manifest.md]] — **collection manifest** (scope + exclusions + supersedes note)
- [[2026-07-17-second-docs-learn-intro.md]] — Intro to the Ark protocol
- [[2026-07-17-second-docs-learn-rounds.md]] — Ark rounds (Taproot/MuSig, hash-locked forfeits, 1-2h cadence)
- [[2026-07-17-second-docs-learn-vtxo.md]] — Ark VTXOs (quad-tree, CLTV/CSV `<144>` scripts, statechain)
- [[2026-07-17-second-docs-learn-forfeits.md]] — Ark forfeits (hash-lock vs connector, exit paths)
- [[2026-07-17-second-docs-learn-exit.md]] — Ark emergency exits (root→leaf sequence, cancellable)
- [[2026-07-17-second-docs-learn-lifetime.md]] — VTXO lifetime (expiry, sweep, liveness)
- [[2026-07-17-second-docs-learn-board.md]] — Ark boarding (six confirmations, atomic)
- [[2026-07-17-second-docs-learn-payments.md]] — Ark payments / arkoor (double-spend deterrents)
- [[2026-07-17-second-docs-learn-offboard.md]] — Ark offboarding (cooperative vs emergency exit)
- [[2026-07-17-second-docs-learn-liquidity.md]] — Ark liquidity (cost formula, capital lockup)
- [[2026-07-17-second-docs-learn-fees.md]] — Ark fees (categories, hybrid pricing)
- [[2026-07-17-second-docs-learn-payments-lightning.md]] — Lightning payments (HTLC gateway, ~3d receive VTXO)
- [[2026-07-17-second-docs-learn-payments-on-chain.md]] — On-chain payments (**hArk live Jan 2026**, immediate broadcast)
- [[2026-07-17-second-docs-learn-glossary.md]] — Ark protocol glossary (authoritative terms)

### bark repo design-docs collection (git, ingested 2026-07-17)

Manifest: [[../repos/2026-07-17-collection-bark-repo-manifest.md]] (gitlab.com/ark-bitcoin/bark @ 4f1b646a, MIT)

- [[2026-07-17-bark-repo-checkpoints-01-partial-exit-attack.md]] — partial-exit attack (checkpoint motivation): 4-ary arkoor tree → 1024 VTXOs → forfeit-broadcast DoS
- [[2026-07-17-bark-repo-checkpoints-02-neighbour-exit.md]] — neighbour-exit problem: shared-tx change VTXO dragged on-chain
- [[2026-07-17-bark-repo-checkpoints-03-designing-checkpoints.md]] — checkpoint tx design: two-output `A+S or S+T`, bounds server cost to one tx
- [[2026-07-17-bark-repo-docs-offboard-swaps.md]] — hArk breaks in-round offboards; connector swaps for instant offboards
- [[2026-07-17-bark-repo-docs-addresses.md]] — Ark address format (bech32m ark1/tark1, BOAT-001, policies, delivery)
- [[2026-07-17-bark-repo-docs-mailbox.md]] — Unified Mailbox (planned); non-interactive hArk refresh
- [[2026-07-17-bark-repo-docs-movements.md]] — wallet movement/accounting data model (7 subsystems)
- [[2026-07-17-bark-repo-readme.md]] — repo README (bark/captaind, MSRV, security keys)
- [[2026-07-17-bark-repo-bark-readme.md]] — bark crate README (Rust API tour; pointer doc)
- [[2026-07-16-foundations-roose-delving-clark-policies.md]] — Roose (Delving #1602): exact clArk node/leaf/exit policies (Q5)
- [[2026-07-16-dropout-roose-delving-ark-case-for-ctv.md]] — Roose (Delving #1528): receiver-DoS asymmetry, interactivity (Q5)
- [[2026-07-16-evolution-roose-hark-erk.md]] — Roose (roose.io): dual-timelock model, hArk/Erk successors (Q5)
- [[2026-07-16-foundations-ark-protocol-org-docs.md]] — ark-protocol.org: pseudo-covenant, ephemeral keys, timelock values (Q4)
- [[2026-07-16-foundations-optech-ark.md]] — Bitcoin Optech Ark page: round model, expiry, CTV positioning, timeline (Q4)
- [[2026-07-16-evolution-adios-expiry-delegation.md]] — Ark Labs: Delegation/Intents, expiry-as-step-backwards admission (Q5)
- [[2026-07-16-evolution-unlock-liquidity-tree-signing.md]] — Ark Labs: log2(n) tree-signing optimization, OOR (Q5)
- [[2026-07-16-criticism-spark-ark-explained.md]] — Spark research: quantified criticisms (competitor bias noted) (Q4)
- [[2026-07-16-criticism-shinobi-ark-vs-lightning.md]] — Shinobi/Bitcoin Magazine: ASP liquidity, cross-ASP contagion (Q3)
- [[2026-07-16-news-mainnet-launches.md]] — Second bark + Ark Labs Arkade mainnet launches, funding, timeline (Q4)
