---
title: "Fleet Ops Numerical Baseline 2026"
type: data
ingested: 2026-06-01
quality: 4
confidence: medium
tags: [benchmarks, throughput, scale, cadence, ed25519, ct-log, rekor, encoding]
relevance: [single-slot-identity, signed-envelopes, audit-logs]
note: "Synthesized from Data/Stats agent's 8 sources; some search-aggregator URLs collapsed into this single data note rather than ingested individually."
sources_consolidated:
  - https://tailscale.com/kb/1085/auth-keys
  - https://ed25519.cr.yp.to/
  - https://www.gstatic.com/ct/log_list/v3/log_list.json
  - Mender survey Nov 2025 (cited)
  - Balena pricing pages
  - Sigstore Rekor public dashboards
---

# Fleet Ops Numerical Baseline (mid-2026)

Reference numbers for sizing decisions. All claims are pinned to primary sources; aggregated here so design docs don't have to re-derive them.

## ed25519 perf

### x86 (cr.yp.to, 2.4 GHz quad-core)

| Operation | Cycles | Throughput |
|---|---|---|
| Sign | 87,548 | ~109k sigs/sec |
| Verify (single) | 273,364 | ~9k verifies/sec |
| Verify (batch of 64) | 134,000 avg | **~71k verifies/sec batch** |

- Public key: **32 bytes**
- Signature: **64 bytes**
- Security: 2^128 (≈ NIST P-256, RSA-3000)

### Cortex-M4 (efficient impl, 168 MHz)

| Operation | Cycles | At 168 MHz |
|---|---|---|
| Keygen | 200,000 | — |
| Sign | 240,000 | **~700 signs/sec** |
| Verify | 720,000 | **~233 verifies/sec** |

**Implication**: an ESP32-class fleet member can sustain a few hundred verifies/sec — enough for an audit-log heartbeat (1/min) with margin. Not enough for high-rate per-event signing.

## Encoding sizes

Relative size index, JSON = 1.0:

| Format | Index | Notes |
|---|---|---|
| Protobuf | **0.3×** | smallest |
| CBOR | 0.7× | binary, signing-suitable (det-CBOR) |
| MessagePack | 0.7× | binary, no canonical form spec |
| JSON | 1.0 | baseline |
| TOML, YAML | "significantly larger" | unsigned source format only |

Concrete: realistic payload **Protobuf 8.7 KB vs JSON 39.2 KB** (~4.5× compression).

Encode speed: Protobuf ~3× JSON; decode ~4× JSON.

## Tailscale rotation defaults

| Item | Default |
|---|---|
| Node key auto-expiry | **180 days** |
| Auth key max | 90 days |
| Tagged-device key expiry | **disabled by default** |
| OAuth access token | 1 hour (not configurable) |

## CT log MMD targets (gstatic v3 log list)

| Generation | MMD | Operators |
|---|---|---|
| Classic Trillian | **86,400 sec (24h)** | Argon, Nimbus, DigiCert, Sectigo Mammoth/Sabre, TrustAsia |
| Tiled (2025+) | **60 sec** | Let's Encrypt Sycamore/Willow, Sectigo Elephant/Tiger, Geomys Tuscolo, IPng Halloumi/Gouda |

8 active CT log operators in 2026.

## Production transparency-log scale

### Sectigo Sabre2026h1 (retired shard)
- Final tree size: **88.74 M entries** in a 6-month shard
- Implied: ~493k entries/day per shard

### Cloudflare Nimbus2025
- ~33 M read API requests/day (~380 req/s)
- ~6 M write API requests/day (~70 req/s)

### CT Radar global
- Indexes **~1.5 billion certificates** total across active logs

### Sigstore Rekor (Oct 2025)
- Sample log index: **262,231,672** entries (~262 M)
- ~46 months from 1M (Dec 2021) to 262M
- ~5.7 M entries/month, ~190k/day, **~2.2 entries/sec** average
- BigQuery public dataset launched 2025-08-15

## Fleet size landscape (Balena, Mender)

| Provider | Tier breakpoints |
|---|---|
| Balena | free 10 / prototype 20-30 / pilot 50-60 / **production 100-110** |
| Balena | largest reference: **200,000 LoRaWAN devices in 1 yr** |
| Mender | references **>100,000 devices**; Siemens, ZF cited |
| Mender survey Nov 2025 | **84% of OEMs deploy updates ≥ quarterly** |

## What this implies for the topic

1. **Append-only log throughput**: Rekor's ~2.2 entries/sec mean rate is light. A 1000-device fleet emitting one audit event per device per minute = ~17 events/sec — well within Rekor's headroom and an order of magnitude below Cloudflare Nimbus's write rate. Audit-log scale is not a bottleneck for any fleet under ~10k devices.

2. **Encoding choice**: Protobuf wins on wire size by 3-4×. CBOR (det-CBOR) wins on signing-toolchain availability (COSE_Sign1). For long-lived edge envelopes, choose **CBOR/COSE if you want IETF-standard signing**, **protobuf if you want raw wire efficiency**. **TOML is not in the running** for the signed bytes (per [[2026-06-01-toml-no-canonical-form]]).

3. **ed25519 perf**: not a bottleneck on x86 (gateway/server), borderline on M4 (microcontroller). For sub-Cortex-M class, use ed25519 sparingly (boot-time + once-per-config-change), not per-event.

4. **Rotation cadence**: 180-day default (Tailscale node keys) is the conservative anchor. 90 days for shared-secret-equivalents (auth keys). Hour-level for OIDC/WIF tokens. Pick per-tier, not one-size-fits-all.

5. **MMD = 60 sec is achievable in 2025+** with tiled logs — good ceiling for "near-realtime" audit assertions.

## See also

- [[2026-06-01-ed25519-provable-security]]
- [[2026-06-01-rfc-9052-cose-structures]]
- [[2026-06-01-rekor-v2-ga]]
- [[2026-06-01-tailscale-auth-keys]]
- [[2026-06-01-balena-supervisor-api]]
- [[2026-06-01-mender-device-auth]]
