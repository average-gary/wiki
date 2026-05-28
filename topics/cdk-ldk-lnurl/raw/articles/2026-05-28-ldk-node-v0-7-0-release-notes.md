---
title: "LDK Node v0.7.0 release notes"
type: article
source: https://github.com/lightningdevkit/ldk-node/releases/tag/v0.7.0
fetched: 2026-05-28
published: 2025-12-03
confidence: high
tags: [ldk-node, release-notes, splicing, async-payments, vss, lsps2]
summary: Channel splicing (experimental), Async Payments (BOLT12 static-invoice), Bitcoin Core REST chain source, VSS encryption improvements, LSPS2 client-trusts-LSP model. CDK v0.16+ uses ldk-node 0.7.
---

# LDK Node v0.7.0 — release notes

Released **2025-12-03**. Signed by `tnull`. CDK pinned to ldk-node 0.7 in PR #1399 (2025-12-14).

## Headline features

- **Channel splicing** (experimental) — adjust channel capacity in-flight without a close/reopen
- **Async Payments** — static-invoice serving + paying (BOLT12 path)
- **Bitcoin Core REST chain source** — `set_chain_source_bitcoind_rest(...)` — bulk REST sync + RPC for broadcast
- **VSS encryption/obfuscation scheme improved**, lazy deletes added (#689, #722, #627)
- **LSPS2 service** now supports **client-trusts-LSP model** (#687) — the alternative trust model
- **LDK 0.2** + **BDK 2.2** dependencies
- MSRV → 1.85

## VSS history

- **v0.4.0 (Oct 2024)** — VSS first added, marked experimental
- **v0.5.0 (Apr 2025)** — LSPS1/LSPS2 client/service support; BOLT12 `payer_note` / `quantity`
- **v0.7.0 (Dec 2025)** — VSS encryption hardening, LSPS2 trust-model expansion, splicing, async payments

## What's NOT in v0.7

- **Hold invoices** — not present in stable LDK Node releases through v0.7.0. Only spontaneous-payment custom-preimage and JIT manual-claim flows exist. This affects: LNURL-withdraw atomicity, NWC `make_hold_invoice` support, Fedimint Gateway's gateway HTLC flow.
- **Tor outbound proxying for ALL HTTP** — see open issue #834. RGS, pathfinding scoring, and VSS LNURL-auth still bypass `TorConfig`.

## Implications for CDK + LDK Node deployments

- Splicing means a CDK mint can grow channel capacity as deposits accumulate without forcing closing channels. Worth noting in the deployment playbook.
- Async Payments / static-invoice support gives BOLT12 a path to feature parity with Lightning Address. CDK exposes BOLT12 quotes via NUT-25.
- VSS hardening makes cloud-backed LDK Node persistence more viable, but the LNURL-auth dependency in the default VSS auth path remains a privacy footgun under Tor.
