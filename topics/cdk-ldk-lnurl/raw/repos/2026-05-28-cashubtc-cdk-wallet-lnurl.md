---
title: "cashubtc/cdk — wallet-side LNURL & lightning-address support"
type: repo
source: https://github.com/cashubtc/cdk/tree/main/crates/cdk
fetched: 2026-05-28
confidence: high
tags: [cdk, lnurl, lightning-address, wallet]
summary: CDK has LNURL/lightning-address support only on the wallet (sender) side. The mint binary cdk-mintd ships no LNURL endpoints. An operator must layer their own LNURL server on top.
---

# CDK wallet LNURL surface (and the mint-side gap)

## Wallet-side LNURL helpers (present)

In `crates/cdk/src/lightning_address.rs`:
- `LightningAddress` — typed `user@domain` address
- `LnurlPayResponse` — typed step-1 response (mirrors LUD-06)
- `LnurlPayInvoiceResponse` — typed step-2 response (`pr` + `routes`)

In `crates/cdk/src/wallet/melt/melt_lightning_address.rs`:
- `WalletTrait::melt_lightning_address_quote(address, amount_msat)` — resolves `user@domain` to LNURL-pay, fetches BOLT11, uses it for a NUT-05 melt
- `MintConnector::fetch_lnurl_pay_request` / `fetch_lnurl_invoice` — HTTP plumbing

So a CDK wallet can **send** to a Lightning Address (deposit-out / withdrawal flow), and BIP-353 (DNS-based BOLT12 / lightning-address resolution) was added in v0.14.0.

## Mint-side LNURL surface (absent)

`cdk-mintd` exposes only the Cashu NUT REST endpoints — `/v1/info`, `/v1/keys`, `/v1/mint/quote/bolt11`, `/v1/mint/bolt11`, `/v1/melt/quote/bolt11`, `/v1/melt/bolt11`, etc. There is **no** `/.well-known/lnurlp/<user>` handler, no `lnurlw://` endpoint, no NIP-05 NIP.

Issue [#1286 — "Add melt to lnurl like we have for bip353"](https://github.com/cashubtc/cdk/issues/1286) was opened 2025-11-16 and **closed without merge** (milestone 0.14.0). CDK has BIP-353 / lightning-address pay support on the wallet side; integration of `lnurl-rs`/`lnurl-pay` for outbound LNURL melts in the wallet, and any LNURL serving on the mint, are deprioritized in favor of BOLT12 / BIP-353.

## Example: `crates/cdk/examples/npubcash.rs`

CDK ships an example showing how to **call** `https://npub.cash/.well-known/lnurlp/{npub}` from a CDK wallet — confirming the canonical flow is "third-party LNURL bridge in front of (or beside) the mint." See [[2026-05-28-cashubtc-npubcash-server.md|npubcash-server]] for the bridge implementation.

## Implication for deployment

A `cdk-mintd` + `cdk-ldk-node` deployment does **not** become reachable as `mint@example.com` just by running it. Operators must:

- Run a separate LNURL/lightning-address server (npubcash-server, custom Axum/FastAPI, LNbits LNURLp + Cashu extension), or
- Add a reverse-proxy rewrite that fronts `/.well-known/lnurlp/<user>` with a small handler calling NUT-04 mint-quote, or
- Patch CDK to add a built-in LNURL handler (no upstream work-in-progress at time of writing).
