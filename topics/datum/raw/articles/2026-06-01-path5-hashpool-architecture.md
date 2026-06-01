---
title: "Hashpool Architecture - SV2 + Cashu eHash, Self-Pool Not Proxy"
url: https://github.com/vnprc/hashpool
source_type: code-readme
ingested_by: path5
ingested_on: 2026-06-01
quality: high
relevance: high
hypotheses_addressed: [4]
---

# Hashpool Architecture - SV2 + Cashu eHash, Self-Pool Not Proxy

## Provenance
Active vnprc/hashpool repo, README and v0.1.1 release notes (Bitcoin Core
30.2 integration, 2025-2026 development).

## Key Findings

- **Hashpool is a complete pool, not a proxy.** Architecture:
  `pool` (issues eHash, runs share accounting via Cashu mint) + `jd-server`
  (negotiates work with downstream) + Bitcoin Core 30.2 (template provider via
  IPC) + downstream `proxy` (SV1<->SV2 translation) + `jd-client` + CPU miner.
- **Hashpool runs its own bitcoind and finds its own blocks.** It does not
  forward shares to OCEAN, Foundry, or any external pool. The "luck risk"
  framing in the docs assumes hashpool *is* the block-finding entity.
- **Cashu eHash flow:** proxy bundles blinded message per share -> pool signs
  -> wallet stores message+signature pair as ehash token. Tokens accrue value
  if/when the pool finds a block.
- **Already SV2 downstream-capable** via the SRI Translator Proxy bundled in
  the architecture (SV1 miners served via translation; SV2 miners
  presumably served natively).

## Hypothesis Implications

- **H4 (hashpool front-ending DATUM/OCEAN):** REFUTED in current
  architecture. Hashpool today is not designed to use OCEAN as upstream.
  Doing so would require:
  1. swapping hashpool's `pool` block-finding role for a "DATUM Gateway
     wrapper" that presents an OCEAN-bound coinbase address instead of
     hashpool-controlled coinbase,
  2. adding TIDES-aware share accounting on top of Cashu eHash, OR redefining
     eHash redemption to settle from TIDES coinbase receipts,
  3. preserving Knots template policy through to OCEAN's expectations.
  None of this is present in 0.1.1.
- **The Path-3 SV2-front DATUM proxy is NOT hashpool.** They are different
  architectures with overlapping toolchain (SRI translator + JD).

## Threat-Model Implications
A *future* hashpool-on-OCEAN integration would compose two trust hops: SV2
miner trusts hashpool operator, hashpool operator trusts OCEAN. eHash gives
the miner instant liquidity but full counterparty exposure to the hashpool
mint. This is a stronger trust regression than the bare SV2-front proxy in
Path 3.

## Ingest Justification
Settles whether hashpool is "already this product" - it isn't. Closes off
hypothesis #4 as not currently realized while keeping it open as a future
composition.
