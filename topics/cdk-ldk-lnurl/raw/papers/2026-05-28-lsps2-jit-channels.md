---
title: "LSPS2 — Just-In-Time Channels"
type: paper
source: https://github.com/BitcoinAndLightningLayerSpecs/lsp/blob/main/LSPS2/README.md
fetched: 2026-05-28
confidence: high
tags: [lsp, lsps2, jit-channels, inbound-liquidity, blip-25]
summary: Three-actor protocol (LSP, client, payer) for opening a channel and forwarding the first payment in one round-trip. The way a small Cashu mint with no inbound capacity can receive its first LN deposits.
---

# LSPS2 — JIT Channels

Spec home: `BitcoinAndLightningLayerSpecs/lsp` repo. LDK Node has client and service support; CDK's `cdk-ldk-node` exposes the client side via LDK Node config.

## Actors

- **LSP** — runs an LN node with capital, sells channels
- **Client** — receives the JIT channel (e.g., a small Cashu mint)
- **Payer** — sends the first HTLC that triggers channel opening

## Flow

1. Client calls `lsps2.get_info` (LSPS RPC) → LSP returns fee menu, supported channel sizes
2. Client calls `lsps2.buy(payment_size_msat, ...)` → LSP returns a temporary `scid_alias`
3. Client builds invoice using `scid_alias` as a route hint
4. Payer pays the invoice
5. LSP intercepts the HTLC at the alias, opens a channel to client (BOLT2 with `option_scid_alias`), forwards the HTLC

## Fee formula

```
opening_fee = max(min_fee_msat,
                  ((payment_size_msat × proportional + 999999) ÷ 1000000))
```

Implementations MUST detect arithmetic overflow.

## Trust models

- **"LSP trusts client"** (recommended default) — LSP broadcasts funding before preimage release. LSP risks its capital; client gets a clean channel.
- **"client trusts LSP"** — client releases preimage first; LSP can theoretically refuse to broadcast. Useful only when LSP reputation is established.

## bLIP-0025

LSPS2 references **bLIP-0025** for the `extra_fee` TLV that signals fee deductions on individual forwarded HTLCs. (The earlier task brief mentioned bLIP-50/bLIP-51; the actual relevant numbering is LSPS0/1/2/4 and bLIP-0025.)

## Known LDK Node footgun

Open issue [#913](https://github.com/lightningdevkit/ldk-node/issues/913) — LSPS2 JIT channels accepted via `TrustedChannelFeatures::ZeroConf` use the default 1000-sat reserve, which on small JIT channels eats enough capacity to make the first HTLC fail. Symptom: 4980 sats usable for a 4950 sat HTLC fails with "amount above max."

## Relevance to CDK + LDK + LNURL

A fresh CDK mint deployment with no manual channel-management practice can rely on LSPS2 to onboard its first deposits:

- Mint configures LDK Node `set_liquidity_source_lsps2(...)` pointing at an LSP (Olympus, Voltage, public LDK LSPs)
- First LNURL-pay deposit triggers JIT channel open
- After accumulating volume, the operator graduates to manual channel management or LSPS1 static channels

But the #913 bug means the very first payment may silently fail — operators should test on Mutinynet before opening for real deposits.

## Public LSP options

- **Olympus** by ZEUS
- **Voltage**
- **Lightspark**
- LDK-Node's experimental built-in LSP service (`set_liquidity_provider_lsps2`)
