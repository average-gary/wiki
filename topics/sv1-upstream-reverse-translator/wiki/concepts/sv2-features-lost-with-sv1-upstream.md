---
title: "SV2 features lost when the upstream pool is SV1"
category: concept
status: active
created: 2026-05-28
updated: 2026-07-27
verified: 2026-07-27
volatility: warm
confidence: high
sources:
  - raw/papers/2026-05-28-path3-sv2-spec-job-declaration-protocol.md
  - raw/papers/2026-05-28-path3-sv2-spec-protocol-security-noise.md
  - raw/papers/2026-05-28-path3-sv2-spec-discussion-deployment-scenarios.md
  - raw/papers/2026-05-28-path3-sv2-spec-mining-protocol-channels-extranonce.md
  - raw/repos/2026-05-28-path3-sri-stratum-mining-stratum.md
  - raw/data/2026-05-28-path5-mempool-space-pools-snapshot.md
  - raw/repos/2026-07-27-blitzpool-rental-proxy-sv2-to-sv1-translator.md
tags: [sv2, feature-loss, jdp, censorship-resistance, noise-transport, authority-pubkey]
summary: "A reverse translator gives an operator the SV2 stack experience internally, but the upstream SV1 pool dictates everything that survives across the egress boundary. This article enumerates exactly which SV2 features survive, partially survive, are replaceable, or are fully lost. Built from Path 3."
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

## The authority key has no SV1 counterpart to lose (confirmed in code, 2026-07-27)

The table above rates authority-bound server identity at egress **lost-but-replaceable** — the reasoning being that TLS with certificate pinning could substitute. A shipped implementation shows the loss is sharper than "replaceable" suggests.

Blitzpool's upstream descriptor ([[prior-art-blitzpool-rental-proxy]]) is:

```rust
UpstreamTarget { url, user, password, authority_pubkey: Option<String> }
```

`authority_pubkey` is the pool's Noise authority public key in base58, verified during the SV2 upstream handshake. It is **SV2-only and ignored entirely by the SV1 adapter**, and the degraded case is documented in-source: "when `None`, the link is encrypted but unauthenticated."

Two things follow:

1. **The loss is structural in the type, not just operational.** With an SV1 upstream there is no field to populate and no handshake step to verify against — the translator cannot know it is talking to the pool it thinks it is, at the protocol level. TLS+pinning remains a real substitute, but it is a *different* trust anchor bolted on outside the mining protocol, configured and rotated separately, and no SV1 pool obliges you to use it.
2. **Even SV2 upstreams degrade silently when the key is omitted.** Encrypted-but-unauthenticated is the default when an operator leaves the pubkey unset, which is a MITM surface that looks fine in logs. Any reverse translator config should make the authority key mandatory-by-default for SV2 upstreams, and should say plainly in its docs that no equivalent exists for SV1.

The honest restatement: at egress against SV1, authority-bound identity is **lost, with an out-of-band replacement available but not protocol-enforced**.

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
- [[prior-art-blitzpool-rental-proxy]] — an implementation that pays these costs in production
- [[architecture-and-state-machine.md|Reverse-translator architecture and state machine]]
- [[../topics/reverse-translator-playbook.md|Reverse-translator playbook (SV2 downstream / SV1 upstream)]]
