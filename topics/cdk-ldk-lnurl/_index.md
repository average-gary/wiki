---
title: CDK + LDK + LNURL — Wiki
type: wiki-root
created: 2026-05-28
updated: 2026-05-28
scope: hub-topic
---

# CDK + LDK + LNURL — Wiki

Topic wiki for **deploying LNURL using Cashu Dev Kit's LDK node**. Covers the CDK (`cashubtc/cdk`) lightning-backend feature flag set, the embedded LDK Node that ships with `cdk-mintd` (`cdk-ldk-node` crate, added v0.12.0 / Aug 2025), and the surface needed to expose LNURL-pay / LNURL-withdraw / Lightning Address endpoints in front of the mint.

## Layout

- `wiki/concepts/` — atomic concept articles
- `wiki/topics/` — synthesizing topic articles
- `wiki/reference/` — pointers to specs, crates, related projects
- `raw/` — ingested source material with provenance
- `output/` — generated artifacts
- `theses/` — testable claims for follow-up research

## Stats

- Sources ingested: **28** (9 articles, 9 papers, 10 repos)
- Articles compiled: **10** wiki articles (7 concepts + 1 topic + 1 reference) + **3 theses**
- Outputs: 0
- Theses: 3 (1 supported high-confidence, 1 partially supported high-confidence, 1 investigating)
- Last research sessions: 2026-05-28 deep round (topic) → 2026-05-28 thesis round (description_hash)

## TL;DR

- **CDK has a first-class LDK Node backend** (`cdk-ldk-node` crate, since v0.12.0). Build with `cargo install cdk-mintd --features ldk-node` or use the `cdk-mintd-ldk-<version>` release artifact.
- **CDK ships NO LNURL endpoints on the mint side.** A bridge process is required (canonical: [cashubtc/npubcash-server](https://github.com/cashubtc/npubcash-server)).
- **The bridge calls NUT-04 / NUT-05** on cdk-mintd to translate LNURL flows into Cashu mint-quote / melt-quote calls.
- **LUD-06's `description_hash` binding** is the central design tension. **LDK Node itself accepts caller-supplied 32-byte description_hash** via `Bolt11InvoiceDescription::Hash(Sha256)` since v0.5.0 — see [[theses/ldk-node-receive-description-hash.md|thesis: Supported, high confidence]]. The remaining gap is purely CDK-side (NUT-04 has no description_hash field; cdk-ldk-node calls `Direct(_)` only). Today's workaround is two LN nodes (npub.cash style); a small CDK PR closes the gap.
- **LDK Node is positioned as testing-tier** by its own README. CLN/LND remain the production default for high-stakes mints. See [[wiki/concepts/ldk-node-footguns.md|footguns]] for the open issues (#381 panic-on-persistence, #834 Tor bypass, #913 LSPS2 first-HTLC).

## Start here

- [[wiki/topics/deployment-playbook.md|Deployment playbook]] — the actionable end-to-end recipe (the deliverable)
- [[wiki/concepts/cdk-architecture-and-backends.md|CDK architecture and backends]] — orientation
- [[wiki/concepts/ldk-node-embedding.md|LDK Node embedding inside cdk-mintd]] — config surface
- [[wiki/concepts/lnurl-bridge-pattern.md|LNURL bridge pattern]] — why and how a bridge sits in front
- [[wiki/concepts/lnurl-cdk-design-tensions.md|Design tensions]] — description_hash, custody, trust anchor
- [[wiki/concepts/ldk-node-footguns.md|LDK Node footguns]] — open issues operators should know
- [[wiki/reference/specs-and-repos.md|Reference: specs and repos]] — comprehensive link index

## Open questions

- ~~Can `Bolt11Payment::receive` in LDK Node v0.7 accept caller-supplied `description_hash`?~~ **Resolved** — yes, since v0.5.0. See [[theses/ldk-node-receive-description-hash.md|thesis: Supported]].
- Will a CDK PR add `description_hash` to NUT-04 + plumb it through `cdk-ldk-node`, enabling single-LN-node spec-compliant LNURL? See [[theses/single-ln-node-deployment-feasibility.md|thesis: Partially Supported]].
- Below what reserve size is cdk-ldk-node operationally safer than cdk-cln/cdk-lnd? See [[theses/ldk-node-vs-cln-for-mints-under-1btc.md|thesis]].
- Will hold-invoice support land in LDK Node v0.8? Required for clean LNURL-withdraw atomicity and NWC `make_hold_invoice`.
- Will VSS persistence become configurable from cdk-mintd TOML, or remain a custom-build-only knob?

## Adjacent wikis

- [[../ldk-server/_index.md|ldk-server]] — LDK Server daemon (gRPC); related but distinct (CDK embeds LDK Node directly, not LDK Server)
- [[../fedimint/_index.md|fedimint]] — Federated ecash; uses LDK Node embedded in Fedimint Gateway (parallel pattern)
- [[../bitcoin-mining-payout-schemas/_index.md|bitcoin-mining-payout-schemas]] — covers hashpool.dev (Cashu mint redenominating mining shares); the canonical motivating use case for embedded LDK
- [[../iroh-transport-stratum-v2/_index.md|iroh-transport-stratum-v2]] — adjacent (LDK ecosystem)
