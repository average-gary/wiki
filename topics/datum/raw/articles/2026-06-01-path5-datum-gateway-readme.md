---
title: "DATUM Gateway README - Protocol, Node, and Hardware Requirements"
url: https://github.com/OCEAN-xyz/datum_gateway/blob/master/README.md
source_type: code-readme
ingested_by: path5
ingested_on: 2026-06-01
quality: high
relevance: critical
hypotheses_addressed: [1, 5, 7]
---

# DATUM Gateway README - Protocol, Node, and Hardware Requirements

## Provenance
Official OCEAN-published README for `OCEAN-xyz/datum_gateway`. Authoritative on
what DATUM Gateway actually does and what it requires today (mid-2026 still in
public beta).

## Key Findings

- **ASIC-side protocol is Stratum V1 only.** "Currently the DATUM Gateway
  supports communication with mining hardware using the Stratum v1 protocol
  with version rolling extensions (aka 'ASICBoost')." **No SV2 downstream
  support exists.** This is the keystone fact that makes a Path-3 SV2-front
  proxy non-redundant.
- **Bitcoin Knots highly recommended.** "Using Bitcoin Knots is highly
  recommended" because Bitcoin Core "is severely lacking in template control
  options." Core works via GBT but loses much of DATUM's selling point. An
  SV2-front proxy that wraps DATUM Gateway inherits this Knots-bias unless the
  proxy operator deliberately routes around it.
- **DATUM Protocol (gateway -> pool) is proprietary and unpublished.** "The
  protocol itself was made from the ground up as a custom protocol. Its
  specification is evolving, subject to change, and will be published
  elsewhere." This means any SV2-front proxy must use DATUM Gateway as a
  black-box upstream; building a native SV2 -> OCEAN bridge that skips Gateway
  is not feasible without reverse-engineering the protocol.
- **Operator responsibilities at the gateway:** synced full node, block
  template configuration, RPC credentials, API password management. An
  SV2-front proxy *adds* responsibilities, not replaces them.

## Hypothesis-by-Hypothesis Implications

- **H1 (SV2-firmware fleet wants TIDES):** STRONGLY SUPPORTED. SV1-only
  downstream is exactly the gap a Translator-style proxy would close.
- **H5 (censorship-resistance preservation):** SUPPORTED with caveat. DATUM's
  censorship story is anchored in Knots policy and miner-driven templates. An
  SV2 proxy that simply forwards SV1 work upward leaves DATUM's properties
  intact, but does not extend SV2's miner-side template authority through to
  OCEAN unless OCEAN itself adopted JD-Client semantics (which DATUM Gateway
  already replicates outside of SV2).
- **H7 (Knots requirement):** UNCLEAR but TILTED. The recommendation lives at
  the gateway/node layer, not at the SV2 layer. A proxy doesn't escape the
  Knots-recommendation; it inherits it.

## Threat-Model Implications
The proxy operator runs DATUM Gateway and a node, holds the OCEAN payout
address (TIDES destination), and now also fronts SV2 sessions. Compromise of
the proxy = compromise of the gateway = TIDES payouts captured. The
proprietary-protocol fact also means the proxy operator can't independently
audit the Gateway-to-OCEAN exchange.

## Ingest Justification
Establishes the SV1-only downstream constraint that motivates a Path-3 proxy
in the first place. Single most load-bearing source for Path #5.
