---
title: "SV2 features lost when the upstream pool is SV1"
type: concept
status: active
created: 2026-05-28
updated: 2026-05-28
confidence: high
tags: [sv2, feature-loss, jdp, censorship-resistance, noise-transport]
---

# SV2 features lost when the upstream pool is SV1

A reverse translator gives an operator the SV2 stack experience internally, but the upstream SV1 pool dictates everything that survives across the egress boundary. This article enumerates exactly which SV2 features survive, partially survive, are replaceable, or are fully lost. Built from Path 3.

## The survival table

Tally: 9 lost, 9 partially-lost, 1 lost-but-replaceable, 4 survive.

| SV2 feature | Status with SV1 upstream | Severity |
|---|---|---|
| Job Declaration Protocol (JDP) | **lost** | Critical — kills SV2's headline political claim |
| Custom block template selection | **lost** | Critical — pool ships template |
| Censorship resistance via miner templates | **lost** | Critical — operator inherits SV1 pool's filtering |
| MEV retention via coinbase control | **lost** | Critical |
| Header-only mining (`merkle_root_only`) | **lost** | High — needs upstream cooperation |
| Group-channel broadcast | **lost** | High — SV1 has no broadcast primitive |
| Sequence-number ordering / batched ack | **lost** at egress | Medium — translator must buffer/coalesce |
| Per-channel `SetTarget` | **lost** at egress | Medium — SV1 = one difficulty per connection |
| Spec-conformant topology / reference impl | **lost** | High — no spec section, no SRI role |
| Noise NX miner ↔ proxy | **survives** | (internal only) |
| Noise NX proxy ↔ upstream | **lost** | High — plaintext SV1 egress |
| Hashrate-hijacking prevention | **partially-lost** | Medium — internal yes, egress no |
| Per-miner performance privacy from upstream | **lost** | Medium |
| Authority-bound server identity at egress | **lost-but-replaceable** | Medium — TLS+pinning DIY |
| 32-byte hierarchical extranonce_prefix | **partially-lost** | Medium — internal hierarchy works; one flat extranonce1 upstream |
| Standard channel (HOM) downstream | **partially-lost** | Medium — collapses at egress |
| Extended channel | **partially-lost** | Medium |
| Async share submit | **partially-lost** | Medium — egress is synchronous mining.submit RTTs |
| Multi-channel abstraction / channel multiplexing | **partially-lost** | Medium — collapses to single SV1 socket |
| Bandwidth reduction (binary framing, ~20-byte shares) | **partially-lost** | Low-Medium — internal only |
| Better miner attribution / per-channel identity | **partially-lost** | Low — mappable to SV1 worker names |
| Version rolling (BIP-310 / BIP-320) | **survives** | (both protocols support it) |
| Reuse of SRI codec / noise / binary crates | **survives** | (internal plumbing) |

**See**: [[../../raw/papers/2026-05-28-path3-sv2-spec-job-declaration-protocol|JDP spec]], [[../../raw/papers/2026-05-28-path3-sv2-spec-protocol-security-noise|Noise threat model]], [[../../raw/papers/2026-05-28-path3-sv2-spec-discussion-deployment-scenarios|spec section 10.4.5]].

## The strongest argument FOR

A reverse translator is a **migration on-ramp**: it lets an operator deploy the SV2 stack internally — gain Noise-encrypted intra-network transport, hierarchical extranonce for downstream proxies, async batched share submit between miner and proxy, and SRI codebase reuse — *while the upstream pool ecosystem drags its feet*. Pool-side SV2 adoption is slow (top-5 pools = 77.7% of network hashrate, none SV2-native — see [[../../raw/data/2026-05-28-path5-mempool-space-pools-snapshot|hashrate snapshot]]). An operator who has already invested in SV2-capable miners and middleware can keep using them without being held hostage to whichever pool they happen to want today. Version rolling, internal binary framing, and the operational discipline of running an SV2 stack all carry forward when the upstream eventually upgrades.

## The strongest argument AGAINST

**You pay the engineering cost of SV2 to deliver almost none of its value proposition.** Every politically and economically meaningful SV2 feature — JDP, custom templates, censorship resistance, MEV retention, end-to-end encryption to the pool, header-only mining — requires upstream cooperation and is *fully lost* against an SV1 pool. The spec authors literally left section 10.4.5 (V2→V1) blank ([[../../raw/papers/2026-05-28-path3-sv2-spec-discussion-deployment-scenarios|spec discussion]]). SRI ships no reference role. The lossy mapping at the egress (collapsing N channels to one connection, hierarchical extranonce to flat extranonce1, async submit to synchronous RTTs, per-channel difficulty to single difficulty) introduces bugs and operational complexity *without* compensating benefits. If the goal is anything beyond internal-network tidiness, **just run an SV1-only stack until the upstream pool actually upgrades**.

## Censorship resistance — the honest read

The SV2 marketing claim is that SV2 lets miners pick their own templates and resist pool censorship. A reverse translator pinned to an SV1 upstream **does not preserve this property**. The SV1 pool still constructs the block template, including the coinbase outputs and the transaction set. The miner's local SV2 stack just sees a `mining.notify` that it has to mine on. Pitching the reverse translator as "SV2 censorship resistance with your existing pool" is dishonest; the honest pitch is "SV2 *operational hygiene* with your existing pool."

## See also

- [[sv2-sv1-primitive-mapping]] — what survives in the messages
- [[customer-segments-and-tam]] — who actually wants this anyway
- [[sv2-spec-issue-102-the-canonical-reference]] — spec authors named the concept but left it underdocumented
