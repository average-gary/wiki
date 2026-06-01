---
title: "Lightning Payouts"
source: "https://ocean.xyz/docs/lightning"
type: articles
ingested: 2026-05-28
tags: [ocean, lightning, bolt12, payouts, bip-322, mining-pool]
summary: "OCEAN's How-To guide for opting into Lightning Network payouts using BOLT12 offers. Covers BOLT12-capable wallet requirements, the on-chain-address-to-offer signed-message linking flow, the 0.01048576 BTC on-chain fallback, supported implementations (Alby Hub, Core Lightning, Eclair, LDK, Lexe, Coinos, Phoenix planned), and a March 2026 incompatibility advisory for Alby Hub v1.21.2+."
collection: "ocean-docs"
adapter: "wayback-cdx"
upstream_id: "lightning"
upstream_type: "wayback-snapshot"
canonical_url: "https://ocean.xyz/docs/lightning"
content_format: "html"
authors: ["Bitcoin Mechanic", "Vincenzo"]
fetched: 2026-05-28
extraction_tool: "WebFetch"
---

# Lightning Payouts

> OCEAN supports Lightning Network payouts via BOLT12 offers — "a modern
> protocol for reusable, privacy-enhanced payment requests on the Lightning
> Network." The user links their OCEAN Bitcoin payout address to a BOLT12
> offer via signed-message verification.

## Requirements

- A Lightning node supporting BOLT12.
- Sufficient inbound liquidity, open channels.
- A wallet supporting Bitcoin message signing (Electrum, Sparrow, Ledger,
  Trezor, hardware wallets).
- Caveat: large BOLT12 offers with blinded paths may exceed message-signing
  size limits on some signers (e.g. Coldcard).

## Fallback Mechanism

If Lightning payouts fail (e.g. insufficient liquidity), OCEAN retries each
block until accumulated earnings reach **0.01048576 BTC**, then pays on-chain
to the user's Bitcoin address.

## Supported Implementations (as of December 2025)

| Implementation | Notes |
|---|---|
| Alby Hub | Self-custodial with BOLT12 support — but see March 2026 advisory below |
| Core Lightning (CLN) | Routing-node operators |
| Eclair | Routing-node operators |
| LDK-based wallets | All LDK-based wallets should support BOLT12 |
| Lexe | (app) |
| Coinos | (custodial) |
| Lightspark | Planned, no ETA |
| Phoenix Wallet | Planned, no ETA |

## Configuration Flow

1. OCEAN dashboard → **My Stats** → **Configuration**.
2. Paste BOLT12 offer.
3. Set block height to "latest".
4. Generate the unsigned message.
5. Sign the message with the on-chain payout address's private key
   (BIP-322 or legacy formats).
6. Submit the signature to confirm.

## Signing Methods

- **Electrum:** Tools → Sign/Verify Message → paste message → select address
  → sign → copy Base64 signature.
- **Sparrow Wallet:** Tools → Sign Message → input address + message →
  export signature.
- **Ledger:** Connect via Electrum's sign-message feature.
- **Trezor:** Trezor Suite → Tools → Sign & Verify.
- **Coldcard:** Advanced → MicroSD → Sign Text File → upload + sign.

## Critical Compatibility Update — March 2026

> "Recent versions of Alby Hub (v1.21.2 and above) are currently incompatible
> with OCEAN's BOLT12 payout system, commonly causing
> 'error decoding lightning_bolt12' failures."

Recommended workarounds:

1. Core Lightning (CLN)
2. Lexe app
3. Eclair
4. Coinos (custodial)
5. Alby Hub v1.21.0 — *fresh installs only*

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| Payment fails | Inbound liquidity insufficient — add liquidity |
| Invalid offer | Verify BOLT12 format and node status |
| Signature error | Confirm on-chain address matches payout, BIP signing format |
| No payouts | Verify dashboard earnings; LN attempts precede on-chain fallback |

## Support

Contact: `lightning@ocean.xyz`

## Scope Note

This source is primarily relevant to OCEAN operator-side payout rails, not
to DATUM Gateway directly. Cross-reference with
`bitcoin-mining-payout-schemas` if a payout-mechanism article is later
compiled.
