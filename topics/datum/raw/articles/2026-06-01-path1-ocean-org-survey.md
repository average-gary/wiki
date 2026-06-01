---
title: "OCEAN-xyz GitHub org survey — only the gateway is open-source; DATUM Prime is not"
source: "https://api.github.com/users/OCEAN-xyz/repos"
type: articles
tags: [datum, datum-prime, ocean, open-source-status, pool-side, source-availability]
summary: "OCEAN-xyz publishes exactly two repositories: datum_gateway (the C miner-side client, 145 stars) and datum-gateway-startos (a TypeScript packaging shim for StartOS, 12 stars). There is NO public OCEAN repository for the pool-side DATUM Prime daemon. Pool-side validation, payout computation, share-credit logic, and the DATUM Prime networking stack remain closed-source as of 2026-06-01. This is a load-bearing fact for anyone building a DATUM-protocol-compatible peer."
confidence: high
ingested: 2026-06-01
ingested_by: path1
quality_score: 5
canonical_url: "https://github.com/orgs/OCEAN-xyz/repositories"
---

# OCEAN-xyz GitHub org survey

Wanted: any open-source pool-side code from OCEAN. Found: nothing.

## The full inventory

OCEAN-xyz hosts exactly **two** public repositories:

| Repo | Description | Lang | Stars | Last push | Role |
|---|---|---|---|---|---|
| `datum_gateway` | "Decentralized Alternative Templates for Universal Mining" | C | 145 | 2026-04-06 | Miner-side client |
| `datum-gateway-startos` | "datum_gateway for startos" | TypeScript | 12 | 2026-04-07 | StartOS packaging |

Both repos are *gateway-side* — they live on the miner's hardware, not on OCEAN's pool servers.

## What's NOT public

There is no public repository for any of:

- The DATUM Prime pool-side daemon (the server the gateway connects to)
- The TIDES payout calculator
- The pool's share-validation pipeline
- The pool's coinbase-output generation logic (what fills the `0x11` coinbaser response)
- The pool's lightning-payout integration (referenced in the wiki's lightning-payouts.md article)

## Why this matters

### For protocol verification
The protocol can be **studied** from the C client (and this research path's other ingests cover that exhaustively), but it can only be **verified end-to-end** by running it against the live OCEAN pool. There's no test pool harness; there's no reference server. This sets a hard ceiling on how much of DATUM you can prototype offline.

### For the SV2-downstream-proxy design
A proxy that translates SV2 → DATUM upstream must run integration tests against OCEAN itself, with real shares (or shares that look real enough to be processed). There is no mocked DATUM Prime to develop against.

A practical workaround: the gateway's own client code (`datum_protocol.c`) can be linked or vendored as a library, so the proxy uses the gateway's exact handshake/encryption/opcode-encoding logic and only adds the SV2 translation layer on top. This is consistent with luke-jr's review comment on issue #146 ("better to have it be a pkg-config shared library we simply link to").

### For DATUM as an "open protocol"
The protocol is open in source-availability terms (the C client is MIT-licensed) but **not in spec terms** (no published Markdown/PDF spec) and **not in interoperability terms** (no second pool implements it; no second client exists at scale). Calling DATUM an "open protocol" requires asterisks.

Compare to:

| Protocol | Spec | Reference impl | Multiple impls in production |
|---|---|---|---|
| Stratum v1 | de-facto, BIP-style | several | yes (CKPool, public-pool, NOMP, etc.) |
| Stratum v2 (SRI) | spec.org spec | github.com/stratum-mining | growing (Braiins, Demand, JD Coinbase, etc.) |
| DATUM | header file in C source | datum_gateway only | OCEAN only |

## Org-level metadata

- OCEAN-xyz GitHub org has been active since 2024 (project page link confirms launch ≈ 2024-08).
- Bitcoin Ocean, LLC + Jason Hughes named in the LICENSE file as primary copyright holders.
- Individual contributor copyright lines from 2024–2025; luke-jr is the most active outside contributor.

## Implications

1. **DATUM Prime is OCEAN's competitive moat.** They've open-sourced the part that has to run on miners' hardware and kept the part that earns money. Standard SaaS pattern.
2. **A standalone "DATUM-compatible" pool is non-trivial to build.** Anyone wanting to ship a competing DATUM Prime pool would have to reverse-engineer the protocol from the client (which this research path's ingests now make possible) and then build TIDES + share-credit + custody themselves.
3. **The wiki should be honest about confidence levels.** Anything about "what DATUM Prime does" is reconstructed from the client; anything about TIDES math is the README's claims plus the existing tides-payout.md article. Direct verification against pool-side code is impossible.

## Rabbit-hole leads

- **luke-jr's personal repos.** As an outside contributor with deep gateway access, luke-jr might host an experimental pool-side prototype on his personal account. Worth a search.
- **OCEAN's website / docs.bitcoinocean.xyz.** May have non-source spec material that the gateway README points to but doesn't include. The existing path-5 ingest list shows several `ocean-*` articles already captured here — they should be cross-referenced for any DATUM-Prime architectural commentary.
- **Bitcoin-talk / nostr / OCEAN Discord.** Public discussion of pool-side internals (e.g. "what hashes does TIDES use") may surface details the source doesn't.

## Sources

- [OCEAN-xyz · GitHub](https://github.com/orgs/OCEAN-xyz/repositories) — public org repo list
- [datum_gateway repo](https://github.com/OCEAN-xyz/datum_gateway)
- [datum-gateway-startos repo](https://github.com/OCEAN-xyz/datum-gateway-startos)
