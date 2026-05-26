---
title: "How to Connect Your Bitaxe to Parasite Pool (SoloSatoshi)"
publication: solosatoshi.com
url: https://www.solosatoshi.com/how-to-connect-your-bitaxe-to-parasite-pool/
type: article
ingested: 2026-05-26
quality: 4
credibility: medium
confidence: high
tags: [parasite-pool, bitaxe, setup, practitioner, xverse, lightning]
---

# Connecting a Bitaxe to Parasite Pool — SoloSatoshi

Operator-facing setup guide. The only source with verbatim configuration values.

## Stratum config

- **Endpoint**: `parasite.wtf:42069`
- **Username schema**: `<onchain-btc-addr>.<worker>.<lightning-addr>@parasite.sati.pro` (with `@sati.pro` fallback)
- Standard Stratum V1 — works with stock Bitaxe firmware.

## Wallet dependency

- **Hard requirement: Xverse browser-extension wallet**, configured to derive both the onchain BTC address AND a Lightning address from the same wallet.
- Recommended to use a fresh Xverse wallet (don't reuse an Ordinals/legacy BTC wallet).
- Other Lightning-address-issuing wallets are not listed as supported.

## UX / verification

- Bitaxe OLED displays `parasite.wtf` once connected.
- Pool dashboard at `parasite.space`, search by onchain address.
- "Loyalty" metric on dashboard (definition not public).

## Practitioner caveats noted

- Beta — no payout assurance, no block found at time of writing.
- Three-part username string is error-prone; mistyping the LN address forfeits payouts silently with no rebind.
- No registration / no email — purely stateless via auth string.

## Why ingestion-worthy

Only source that captures the actual operator configuration with copy-paste fidelity. Essential for any wiki entry that operators will read.

## See also

- [[2026-05-26-parasitepool-para-github]] (repo)
- [[2026-05-26-zkshark-parasite-pool-substack]]
