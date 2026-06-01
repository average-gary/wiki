---
title: "Operator value and threat model for the SV2-DATUM proxy"
category: concept
sources:
  - raw/articles/2026-06-01-path5-datum-gateway-readme.md
  - raw/articles/2026-06-01-path5-mempool-pool-rankings.md
  - raw/articles/2026-06-01-path5-tides-payout-mechanics.md
  - raw/articles/2026-06-01-path5-hashpool-architecture.md
  - raw/articles/2026-06-01-path5-braiins-sv2-features.md
  - raw/articles/2026-06-01-path5-template-similarity-bitmex.md
created: 2026-06-01
updated: 2026-06-01
tags: [operator-value, threat-model, ocean, tides, sv2, custody, censorship-resistance]
confidence: high
---

# Operator value and threat model for the SV2-DATUM proxy

Why would anyone deploy this? Honest read: **operator value is real but narrow** — connectivity bridge for SV2-fleet miners who want OCEAN's TIDES payout. Not a meaningful new censorship-resistance or trust-minimization layer.

## Per-hypothesis verdict

| # | Hypothesis | Verdict | Strongest evidence |
|---|---|---|---|
| 1 | SV2-firmware fleet wants OCEAN/TIDES | **Supported** | DATUM Gateway is SV1-only to ASIC; OCEAN ~3.22% network share is non-trivial; TIDES is genuinely differentiated |
| 2 | Internal Noise transport between miner and proxy | **Supported but modest** | Braiins SV2 explainer confirms Noise NX, but value is small when miner+proxy share an operator |
| 3 | Hierarchical extranonce per ASIC channel | **Unclear** | SRI supports it natively, but DATUM Gateway's per-channel attribution to TIDES coinbase splits is undocumented |
| 4 | Hashpool front-ending OCEAN | **Refuted (today), possible future** | Hashpool is a self-finding pool with its own bitcoind, not an OCEAN proxy |
| 5 | Censorship-resistance preservation | **Preserved but not enhanced** | Template authority lives at gateway+Knots layer; SV2 is transparent to template choice. DATUM provides the CR; SV2 doesn't add to it. |
| 6 | SRI dev tooling against DATUM upstream | **Supported** | A real-pool SV1 upstream with non-trivial properties (Knots, TIDES) is a useful test target distinct from synthetic SV2 pools |
| 7 | Multi-pool failover with DATUM as one of N | **Unclear** | No public stack ships this today |

**See**: [[../../raw/articles/2026-06-01-path5-mempool-pool-rankings]], [[../../raw/articles/2026-06-01-path5-tides-payout-mechanics]], [[../../raw/articles/2026-06-01-path5-braiins-sv2-features]].

## Threat-model map

```
                        ┌─────────────────┐
                        │   OCEAN pool    │  ◀── sees: 1 share-submitter,
                        │ (TIDES coinbase)│      opaque downstream fleet
                        └────────┬────────┘
                                 │ SV1 + proprietary DATUM protocol
                                 │ (libsodium ChaCha20-Poly1305; not Noise)
                        ┌────────▼────────┐
                        │ DATUM Gateway   │  Knots-recommended bitcoind
                        │  + bitcoind     │  Operator's payout addr lives here
                        └────────┬────────┘
                                 │ local TCP (SV1 stratum, port 23334)
                        ┌────────▼────────┐
                        │ SV2-front Proxy │  ◀── THE NEW TRUST PRINCIPAL
                        │ (Rust, Tokio,   │      Holds: OCEAN payout addr,
                        │  channels-sv2)  │      all downstream SV2 sessions,
                        └────────┬────────┘      per-channel share attribution,
                                 │ SV2 + Noise   TIDES re-distribution logic
                +────────────────┼────────────────+
                │                │                │
          ┌─────▼────┐     ┌─────▼────┐    ┌─────▼────┐
          │ SV2 ASIC │     │ SV2 ASIC │    │ SV2 ASIC │
          │ (Braiins │     │ (Braiins │    │ (Braiins │
          │  OS+)    │     │  OS+)    │    │  OS+)    │
          └──────────┘     └──────────┘    └──────────┘
```

### Attacker positions

| Position | Mitigated by SV2 proxy? |
|---|---|
| LAN attacker between miner ↔ proxy | **Yes** (Noise NX between miner and proxy) |
| WAN attacker between proxy ↔ OCEAN | **No** (SV1 link is unchanged; libsodium box exists but is on the gateway-to-OCEAN hop, not on the proxy-to-gateway hop in Phase 1) |
| Compromised proxy operator | **No** — full TIDES capture + per-miner payout fraud possible |
| Malicious upstream OCEAN | **Same as today** (TIDES is auditable but rarely audited) |
| Censoring proxy operator | **Possible** — proxy can override miner template choice in model (a) |

## Honest operator-fit read

**Who would actually deploy this:**

1. **Small/mid SV2-firmware farms aligned with OCEAN's decentralization politics** — owners of BraiinsOS+ ASICs who *want* TIDES + Knots-policy templates and would otherwise be blocked by the SV1-only gateway. **The only crisp value-add.**
2. **SRI contributors** wanting a non-trivial real-world upstream to exercise translator + JD code paths against. Dev-tooling case.
3. **Mining-Lightning service providers** who want SV2-encrypted miner sessions (anti-hijack on hostile networks like co-lo facilities) but can't get them while mining to OCEAN today. Niche but real.

**What they concretely gain:**

- Noise NX between miner and proxy (anti-hashrate-hijack on the LAN/WAN miner-side hop only).
- Ability to keep an SV2 firmware stack instead of dual-booting / downgrading to SV1 just to talk to OCEAN.
- Multi-channel SV2 session management (extranonce isolation per ASIC) — a cleaner internal farm topology than DATUM's single SV1 allocator.

**What they DO NOT gain (don't be sold this):**

- *Additional* censorship resistance beyond what DATUM already provides. The template authority lives at the gateway+bitcoind layer; SV2 is transparent.
- *Non-custodial* end-to-end. **The proxy operator becomes a tiny pool**: they hold the OCEAN payout address and must redistribute TIDES proceeds to downstream miners. This *regresses* the non-custodial property at the proxy boundary.
- *Decentralized* template choice for downstream miners. In the realistic deployment ([[sv2-downstream-architecture#recommended-model-plain-sv2-pool-front-no-jds-no-jdc|model (a)]]), the proxy operator picks transactions via Knots + Gateway. Downstream SV2 JD semantics are not propagated to OCEAN.

## Bottom line

**The trust delta vs running standard DATUM Gateway alongside SV1 firmware:**

- **Negative on custody** — proxy becomes a payout bridge; downstream miners must trust it to redistribute.
- **Neutral on censorship** — DATUM already had this; SV2 doesn't add it.
- **Positive on transport security and channel hygiene** — Noise NX + extranonce isolation.

For a single-operator farm with full LAN control, the marginal benefit is small. For a multi-tenant or hostile-network deployment with SV2-firmware miners that *insist* on OCEAN/TIDES, the bridge function is the entire reason to build this.

The honest pitch: **"OCEAN/TIDES connectivity for an SV2 firmware fleet."** Not "SV2 censorship resistance with OCEAN" — that's already what plain DATUM gives you.

## Hashpool intersection

Hashpool ([[../../bitcoin-mining-payout-schemas/wiki/concepts/ehash|ehash]]) is currently a self-finding pool with its own bitcoind, NOT an OCEAN proxy ([[../../raw/articles/2026-06-01-path5-hashpool-architecture]]). A future variant could redenominate OCEAN/TIDES shares as Cashu eHash via this proxy, with OCEAN seeing one fat customer (the hashpool operator). This is a hypothesized but unbuilt composition. Suggested follow-up thesis.

## See also

- [[sv2-downstream-architecture]] — the architecture that this analysis is about
- [[ocean-sv2-stance-and-prior-art]] — why this market is small
- [[datum-protocol]] — what survives unchanged at the egress
- [[../../bitcoin-mining-payout-schemas/wiki/concepts/datum]] — DATUM in payout-schema context
- [[../../sv1-upstream-reverse-translator/wiki/concepts/customer-segments-and-tam|TAM analysis for the generic SV2-downstream pattern]]
