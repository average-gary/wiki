---
title: "CDK v0.12.0 release notes — LDK Node backend debut"
type: article
source: https://github.com/cashubtc/cdk/releases/tag/v0.12.0
fetched: 2026-05-28
published: 2025-08-26
confidence: high
tags: [cdk, release-notes, ldk-node, history]
summary: The release that introduced cdk-ldk-node. PR #904 by thesimplekid, +7351/-401 lines. Also added: cdk-postgres backend, MintPayment lifecycle methods (start/stop), MSRV 1.85.
---

# CDK v0.12.0 — release notes

Released **2025-08-26**. Signed by `thesimplekid`. Anchor release for the LDK Node backend.

## Headline change

> Introduced **`cdk-ldk-node`** — an integrated Lightning backend that lets a single binary run both a Cashu mint and a Lightning node with full BOLT11 and BOLT12 support.

PR: [#904 "Cdk ldk node"](https://github.com/cashubtc/cdk/pull/904) by `thesimplekid`, opened 2025-07-23, merged 2025-08-25. Net +7351/-401.

## Companion features

- Local **admin web UI** — dashboard, channels, BOLT11/BOLT12 invoices, payments, on-chain. Default port 8091. **No auth — localhost only.**
- `MintPayment::start()` and `MintPayment::stop()` lifecycle methods added — explicitly to support backends like LDK Node that need an explicit start/stop dance (separate from being instantiated)
- `cdk-postgres` backend (mint-side database)
- MSRV bumped to **1.85.0**

## Maturity timeline (from this anchor through current)

| Release | Date | LDK-related changes |
|---|---|---|
| v0.12.0 | 2025-08-26 | LDK Node backend ships |
| v0.13.0 | 2025-09-23 | Web UI improvements (dynamic status, mobile); `cdk-mintd-ldk-0.13.0` artifact added |
| v0.14.0 | (late 2025) | BIP-353 wallet support; LNURL melt issue #1286 closed without merge |
| v0.15.0 | 2026-02-17 | LDK Node BIP39 mnemonic, configurable announcement addrs, configurable logging (by `asmo`) |
| v0.16.0 | 2026-03-31 | Stable; `cdk-mintd-ldk-0.16.0` artifact in releases |
| v0.17.0-rc.0 | 2026-05-22 | Pre-release |

## Other notable PRs touching cdk-ldk-node

- #1010 — additional config (2025-08-27)
- #1108 — Docker setup (2025-09-23, thesimplekid)
- #1242 — docker-compose setup (2025-10-31, gandlafbtc)
- #1312 — fee accounting (2025-11-20)
- #1399 — bump ldk-node 0.6 → 0.7 (2025-12-14)
- #1776 — node pubkey in UI (2026-03-26, Forte11)
- #1889 — fee accounting fix (2026-04-14)
- #1991 — amountless invoice checks (2026-05-22)

## Why this matters

This is the definitive timeline anchor for "when did LDK become a CDK backend?" Anything earlier in the cdk-mintd narrative was CLN/LND/LNbits/Fake-only.
