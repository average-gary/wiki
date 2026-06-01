---
title: "Lightning payouts"
category: concept
sources:
  - raw/articles/2026-05-28-ocean-lightning-payouts.md
  - raw/articles/2026-05-28-ocean-intro-to-lightning.md
created: 2026-05-28
updated: 2026-05-28
tags: [ocean, lightning, bolt12, payouts, bip-322, mining-pool, alby-hub, core-lightning]
aliases: ["BOLT12 payouts", "OCEAN Lightning Payouts"]
confidence: high
volatility: hot
verified: 2026-05-28
summary: "OCEAN's optional Lightning Network payout rail using BOLT12 reusable offers. Miners link a BOLT12 offer to their on-chain payout address via a BIP-322 (or legacy) signed message. Failures fall back to on-chain at 0.01048576 BTC. Wallet support is fluid — Alby Hub v1.21.2+ is currently broken (March 2026 advisory)."
---

# Lightning payouts

> An OCEAN-side payout rail option that sits on top of [[tides-payout|TIDES]] ([TIDES payout](tides-payout.md)) — TIDES still computes how much a miner earned per block; Lightning Payouts changes *how* OCEAN delivers it. Strictly speaking this is orthogonal to DATUM Gateway, which only cares about template construction and share submission. Documented here because operators running DATUM against OCEAN often want to know the payout-rail story.

## Volatility note

This article is `volatility: hot`. Wallet compatibility for BOLT12 changes month-to-month — the underlying spec is stable, but implementation conformance is not. Re-verify wallet support before relying on anything claimed below; the Alby Hub advisory in this article is a worked example of how fast this surface moves.

## What it is

OCEAN supports paying miner rewards over Lightning Network instead of (or before falling back to) on-chain, using **BOLT12 offers** rather than BOLT11 invoices.

The choice of BOLT12 is mechanical, not aesthetic:

- **BOLT11** invoices are single-use. A pool can't pay the same miner repeatedly without the miner generating a fresh invoice each time, which doesn't fit a recurring-payout model.
- **BOLT12** offers are reusable, static payment requests — closer to "an email address for payments." One offer can serve unlimited payouts. Same offer over many blocks; same offer across difficulty adjustments.

A BOLT12 offer is roughly: tagged hashes + wallet signatures that the pool can verify and pay against, on demand, repeatedly.

## The opt-in flow

1. Stand up a BOLT12-capable Lightning node and open channels with sufficient inbound liquidity.
2. Generate a BOLT12 offer in the wallet.
3. On OCEAN dashboard → **My Stats** → **Configuration**, paste the offer.
4. Set block height to "latest."
5. Generate the unsigned message via the dashboard.
6. Sign that message with the **on-chain payout address** (BIP-322 or legacy formats) — proves you control the address that's been receiving on-chain rewards.
7. Submit the signature.

The address-linking step is the security boundary: anyone could paste an offer, but only the owner of the on-chain payout address can sign the binding message.

## Signing methods (per the OCEAN guide)

| Wallet | Path |
|---|---|
| Electrum | Tools → Sign/Verify Message → paste message → select address → sign → copy Base64 signature |
| Sparrow Wallet | Tools → Sign Message → input address + message → export signature |
| Ledger | Connect via Electrum's sign-message feature |
| Trezor | Trezor Suite → Tools → Sign & Verify |
| Coldcard | Advanced → MicroSD → Sign Text File → upload + sign |

Caveat from the guide: large BOLT12 offers with blinded paths can exceed message-signing size limits on some signers (Coldcard is the named example). If the offer is large, fall back to a wallet whose signer doesn't truncate.

## On-chain fallback — 0.01048576 BTC

When Lightning payouts fail (insufficient inbound liquidity, channel issues, etc), OCEAN retries each block until the miner's accumulated unpaid earnings reach **0.01048576 BTC** (= 1,048,576 sats = 2²⁰ sats, ≈ 1.05 mBTC). At that threshold, the pool pays on-chain to the linked Bitcoin address.

The threshold is a deliberate compromise: low enough that a miner's rewards aren't held indefinitely, high enough that on-chain fees don't dominate. Not configurable per-miner; it's a pool policy.

## Supported implementations (as of December 2025)

| Implementation | Notes |
|---|---|
| Alby Hub | Self-custodial with BOLT12 — see advisory below |
| Core Lightning (CLN) | Routing-node operators |
| Eclair | Routing-node operators |
| LDK-based wallets | All LDK-based wallets should support BOLT12 |
| Lexe | App |
| Coinos | Custodial |
| Lightspark | Planned, no ETA |
| Phoenix Wallet | Planned, no ETA |

## Critical compatibility — Alby Hub v1.21.2+ (March 2026)

> *"Recent versions of Alby Hub (v1.21.2 and above) are currently incompatible with OCEAN's BOLT12 payout system, commonly causing 'error decoding lightning_bolt12' failures."*

Recommended workarounds, in OCEAN's listed order:

1. Core Lightning (CLN)
2. Lexe app
3. Eclair
4. Coinos (custodial)
5. **Alby Hub v1.21.0 — fresh installs only** (existing v1.21.2+ installs cannot downgrade in place)

Concrete operator advice: if you currently use Alby Hub for OCEAN payouts and it auto-updates, payouts will silently start failing into the on-chain fallback. Pin the Alby Hub version, or migrate to one of the other listed wallets, or accept the on-chain rail.

## Troubleshooting

| Symptom | Likely cause / fix |
|---|---|
| Payment fails | Insufficient inbound liquidity → add liquidity |
| Invalid offer | Verify BOLT12 format and node status |
| Signature error | Confirm on-chain address matches payout address; check BIP signing format |
| No payouts | Verify dashboard shows earnings; LN attempts run before on-chain fallback kicks in |

OCEAN's contact for this rail is `lightning@ocean.xyz`.

## What this means for the DATUM Gateway operator

Mostly: nothing. DATUM Gateway is on the template-construction and share-submission side. Whether the resulting earnings get delivered via the [[gateway-data-flow|coinbase generation transaction]] ([Gateway data flow](gateway-data-flow.md)), via Lightning, or eventually fall back on-chain is a pool-side decision the operator opts into separately on the OCEAN dashboard.

The one operational coupling: TIDES + non-custodial coinbase payouts (the "default" delivery rail at OCEAN) is the *only* path that's truly non-custodial. The Lightning rail interposes a Lightning node — typically miner-operated, which keeps non-custody intact, but in the case of Coinos (custodial), introduces a third party between the pool and the eventual settlement. Read the trust model carefully if non-custody is a requirement.

## See Also

- [[datum-gateway-overview|DATUM Gateway — overview]] ([DATUM Gateway — overview](../topics/datum-gateway-overview.md)) — DATUM is template-side; Lightning is payout-side
- [[tides-payout|TIDES payout]] ([TIDES payout](tides-payout.md)) — computes the payout amounts that this rail delivers
- [[datum-history-and-motivation|DATUM — history and motivation]] ([DATUM history and motivation](datum-history-and-motivation.md)) — names non-custodial coinbase payouts (not Lightning) as the DATUM incentive

## Sources

- [Lightning Payouts](../../raw/articles/2026-05-28-ocean-lightning-payouts.md) — opt-in flow, supported wallets, Alby Hub advisory
- [Introduction to the Lightning Network](../../raw/articles/2026-05-28-ocean-intro-to-lightning.md) — BOLT11 vs BOLT12 background
