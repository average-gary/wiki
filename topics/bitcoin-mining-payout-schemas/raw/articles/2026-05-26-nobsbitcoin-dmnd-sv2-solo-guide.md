---
title: "Step-by-Step Guide for StratumV2 Solo Mining on DEMAND (NoBSBitcoin)"
publication: nobsbitcoin.com
url: https://www.nobsbitcoin.com/step-by-step-guide-for-stratumv2-solo-mining-on-demand/
type: article
ingested: 2026-05-26
quality: 5
credibility: high
confidence: high
tags: [demand-pool, dmnd, stratum-v2, job-declaration, solo, sv2-default, operational]
---

# DMND — SV2+JD Default Operational Guide (NoBSBitcoin)

The only public source with concrete endpoints/ports/binaries for DMND. Anchors what "default operation" actually looks like.

## Default protocol path (key finding)

**DMND is the first production pool where Stratum V2 + Job Declaration is the default protocol path** — not opt-in like OCEAN/DATUM.

- All-in-one proxy binary: `demand_all_in_one_sv2`
- SV2 port: `34255`
- SV1 fallback (deprecated escape hatch): `mining.dmnd.work:1000`
- Solo SV2 mode documented: `bitcoind -sv2 -sv2port=8442` + miner points at proxy `:34255`

## Why this is novel

OCEAN's DATUM is a custom protocol — "their own protocol… not standard Stratum V2, but functionally similar." DMND is the canonical **standards-track** SV2+JD reference implementation in production.

## See also

- [[2026-05-26-bitcoinmag-dmnd-launch-vc]] — VC backing + founding-miner economics
- [[2026-05-23-dmnd-demand-pool]] — existing SLICE payout-math entry
- [[../../wiki/concepts/pplns-jd]] — payout layer
