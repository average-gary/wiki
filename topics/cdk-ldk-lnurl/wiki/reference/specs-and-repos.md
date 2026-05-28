---
title: "Specs and repos — quick reference"
type: reference
created: 2026-05-28
updated: 2026-05-28
tags: [reference, specs, repos]
---

# Specs and repos

## Cashu

- [cashubtc/cdk](https://github.com/cashubtc/cdk) — Rust workspace. Crates: `cdk`, `cdk-common`, `cdk-mintd`, `cdk-cln`, `cdk-lnd`, `cdk-lnbits`, `cdk-fake-wallet`, **`cdk-ldk-node`**, `cdk-payment-processor`, `cdk-postgres`, `cdk-mint-rpc`, `cdk-bdk`
- [cashubtc/nutshell](https://github.com/cashubtc/nutshell) — Python reference implementation (predates CDK)
- [cashubtc/nuts](https://github.com/cashubtc/nuts) — protocol specs (NUTs)
  - NUT-04 — mint tokens (deposit) [[../../raw/papers/2026-05-28-cashu-nut-04-mint.md|raw]]
  - NUT-05 — melt tokens (withdrawal) [[../../raw/papers/2026-05-28-cashu-nut-05-melt.md|raw]]
  - NUT-23 — bolt11 method-specific behavior
  - NUT-25 — bolt12
  - NUT-30 — onchain
  - NUT-20 — pubkey-locked minting (bridge-relevant)
- [cashubtc/npubcash-server](https://github.com/cashubtc/npubcash-server) — canonical LNURL bridge [[../../raw/repos/2026-05-28-cashubtc-npubcash-server.md|raw]]

## LDK

- [lightningdevkit/ldk-node](https://github.com/lightningdevkit/ldk-node) — embeddable LN node
  - [docs.rs Builder](https://docs.rs/ldk-node/0.7.0/ldk_node/struct.Builder.html) — full API surface [[../../raw/repos/2026-05-28-ldk-node-builder-api.md|raw]]
  - v0.7.0 release notes [[../../raw/articles/2026-05-28-ldk-node-v0-7-0-release-notes.md|raw]]
- [lightningdevkit/rust-lightning](https://github.com/lightningdevkit/rust-lightning) — LDK protocol layer
- [lightningdevkit/ldk-server](https://github.com/lightningdevkit/ldk-server) — daemon wrapping LDK Node (different deployment shape; see [[../../../ldk-server/_index.md|adjacent wiki]])

## LNURL

- [lnurl/luds](https://github.com/lnurl/luds) — spec home [[../../raw/papers/2026-05-28-lnurl-luds-index.md|index raw]]
  - LUD-01 base encoding
  - LUD-03 withdraw [[../../raw/papers/2026-05-28-lnurl-lud-03-withdraw.md|raw]]
  - LUD-04 auth
  - LUD-06 pay [[../../raw/papers/2026-05-28-lnurl-lud-06-payrequest.md|raw]]
  - LUD-09 successAction
  - LUD-12 comments
  - LUD-16 Lightning Address [[../../raw/papers/2026-05-28-lnurl-lud-16-lightning-address.md|raw]]
  - LUD-17 protocol schemes
  - LUD-18 payerData
  - LUD-21 verify [[../../raw/papers/2026-05-28-lnurl-lud-21-verify.md|raw]]

## LSP

- [BitcoinAndLightningLayerSpecs/lsp](https://github.com/BitcoinAndLightningLayerSpecs/lsp) — LSPS specs
  - LSPS1 — static channels
  - LSPS2 — JIT channels [[../../raw/papers/2026-05-28-lsps2-jit-channels.md|raw]]
- bLIP-0025 — `extra_fee` TLV consumed by LSPS2

## Nostr (adjacent)

- [nostr-protocol/nips/47.md](https://github.com/nostr-protocol/nips/blob/master/47.md) — NIP-47 NWC [[../../raw/papers/2026-05-28-nip-47-nostr-wallet-connect.md|raw]]
- [DoktorShift/NUTbits](https://github.com/DoktorShift/NUTbits) — NWC bridge for Cashu (NWC analog of npubcash-server)

## Deployment tooling

- [asmogo/cashu-operator](https://github.com/asmogo/cashu-operator) — K8s operator for cdk-mintd [[../../raw/repos/2026-05-28-asmogo-cashu-operator.md|raw]]

## People

- **thesimplekid (tsk)** — CDK release maintainer; PR #904 author (cdk-ldk-node)
- **callebtc** — original Cashu / nutshell author
- **vnprc** — hashpool / parasite-pool
- **crodas** — CDK contributor (WalletTrait unification)
- **asmo** — cdk-ldk-node config maturation in v0.15
- **egge21m** — npubcash-server maintainer
- **fiatjaf** — LNURL creator
- **akumaigorodski** — LNURL co-author, LUD-16 co-author
- **andreneves** — Lightning Address (LUD-16) co-author, ZBD founder
- **tnull** — LDK Node maintainer
