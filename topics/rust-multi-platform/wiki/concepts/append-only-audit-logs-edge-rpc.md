---
title: "Append-Only Audit Logs over Edge RPC"
type: concept
created: 2026-06-01
updated: 2026-06-01
verified: 2026-06-01
status: active
quality: high
volatility: medium
sources:
  - raw/papers/2026-06-01-scitt-architecture-draft-22.md
  - raw/papers/2026-06-01-scrapi-draft.md
  - raw/guides/2026-06-01-rfc-9162-ct-2-0.md
  - raw/papers/2026-06-01-keytrans-protocol-draft.md
  - raw/papers/2026-06-01-seemless-paper.md
  - raw/papers/2026-06-01-coniks-paper.md
  - raw/papers/2026-06-01-verdict-transparency-dictionaries.md
  - raw/articles/2026-06-01-rekor-v2-ga.md
  - raw/articles/2026-06-01-cosign-v3.md
  - raw/articles/2026-06-01-cosign-keyless-overview.md
  - raw/articles/2026-06-01-haber-stornetta-1991.md
  - raw/articles/2026-06-01-schneier-kelsey-1998.md
  - raw/articles/2026-06-01-ct-split-view-attack.md
  - raw/data/2026-06-01-fleet-ops-numerical-baseline.md
---

# Append-Only Audit Logs over Edge RPC

How to record fleet-operational events (enrollments, key rotations, deauths, attestation evidence) so the record is tamper-evident at the edge **and** at the server, and so violations are detectable.

## TL;DR

- **Two halves, both needed**: device-local tamper-evident log (Schneier-Kelsey forward-secure hash chain) AND server-side transparency log (CT-style Merkle tree). They solve different threats.
- **Append-only is a property of the data structure, not the system.** Without witnesses or sufficient client gossip, a malicious server can fork views undetectably (split-view attack).
- **For small fleets (<100 devices), mirror the audit log into a public transparency service** (Rekor) — outsource witness infrastructure.
- **Wire format**: COSE_Sign1 statements + Merkle inclusion receipts (the SCITT pattern).
- **Throughput**: any fleet under ~10k devices is well below Rekor-scale (~2.2 entries/sec mean) — log volume is not a bottleneck.
- **Use tile-backed logs (Tessera / Rekor v2)**, not RFC 6962-era Trillian, for new builds in 2026+.

## Two halves

### Device-local: Schneier-Kelsey forward-secure hash chain (1998)

Tamper-evident log on a device that may itself be compromised later.

```
A_i = H(A_{i-1} ‖ data_i ‖ type_i)        # entry chain
K_i = H(K_{i-1})                          # key evolution
MAC_i = MAC(K_i, A_i)                     # entry MAC
# K_{i-1} is erased after K_i is derived
```

After capture, attacker cannot forge or undetectably edit prior entries because:
- Editing breaks the hash chain
- Forward-secure key evolution means prior MACs cannot be regenerated

### Server-side: Merkle log + Signed Tree Head (RFC 9162)

```
leaf hash:     H(0x00 ‖ data)
internal hash: H(0x01 ‖ left ‖ right)
STH:           sign(log_id, ts, tree_size, root_hash)
```

- **Inclusion proof**: O(log N) nodes prove a leaf is in the tree
- **Consistency proof**: O(log N) nodes prove tree N+1 extends tree N

Threat model is **inverted** from the device-local case: server is untrusted; trust comes from external witnesses or client gossip detecting forks.

**Both halves are needed.** Schneier-Kelsey alone doesn't catch a malicious server rewriting the version it shows you. CT alone doesn't catch a compromised device editing its own outbound stream before signing.

## The wire format question (SCITT)

The IETF SCITT working group's [[../../raw/papers/2026-06-01-scitt-architecture-draft-22|architecture draft]] formalizes the three primitives:

- **Signed Statement** — a `COSE_Sign1` envelope (CBOR) binding issuer identity to artifact metadata
- **Receipt** — a COSE-signed Merkle inclusion proof against a transparency-service tree
- **Transparent Statement** — signed statement carrying its receipt (often in COSE unprotected header)

[[../../raw/papers/2026-06-01-scrapi-draft|SCRAPI]] gives the REST API:

| Endpoint | Purpose |
|---|---|
| `GET /.well-known/scitt-keys` | COSE Key Set discovery |
| `POST /entries` | register a Signed Statement |
| `GET /entries/{id}` | retrieve receipt |

Sync (201 + receipt immediately) and async (303 → poll → 200) both supported. Errors use Concise Problem Details for CBOR (RFC 9290).

**Recommendation for new edge-fleet audit logs**: implement the SCITT data shapes (statement = COSE_Sign1, receipt = COSE-signed inclusion proof, kid = RFC 9679 thumbprint) even if you don't deploy a full SCITT Transparency Service. The wire format is rigorously specified, IETF-stable, and aligns with the supply-chain ecosystem.

## What "append-only" actually guarantees

[[../../raw/articles/2026-06-01-ct-split-view-attack|Split-view attack]] (Parker et al. + A-SIT):

A malicious log operator shows victim-A one view and victim-B another. Both views are **internally consistent**, **signed by the operator**, **append-only on their own**. Detection requires either:

1. **Client gossip** — fleet members compare STHs out-of-band
2. **Witness co-signing** — independent third parties co-sign STHs

For fleets of 10s-100s of devices, client gossip rarely reaches statistical detection threshold. Witnesses become the answer.

| Choice | Threat coverage |
|---|---|
| Server signs log; no witnesses | trusts server. **audit theater** |
| Server signs; clients gossip | catches forks IF fleet ≥ ~100 active devices |
| Server signs; 1-2 witnesses co-sign STH | catches forks at any size; witnesses = new SPOF |
| Server signs + mirror to Sigstore Rekor | witnesses-as-a-service via Rekor's witness pool |

**Apple PCC and Sigstore both adopted witness frameworks** rather than rely on log signatures alone — strong industry signal. [[../../raw/articles/2026-06-01-rekor-v2-ga|Rekor v2 GA]] (Oct 2025) integrates witness cosigning directly.

## Verifiable Key Directory primitive

The "current state with append-only history" abstraction (which is what fleet identity needs) maps to:

- [[../../raw/papers/2026-06-01-coniks-paper|CONIKS]] (USENIX 2015) — originating paper, per-epoch STR + sparse Merkle prefix tree
- [[../../raw/papers/2026-06-01-seemless-paper|SEEMless]] (CCS 2019) — formal aZKS model, monitoring cost independent of fleet size
- [[../../raw/papers/2026-06-01-keytrans-protocol-draft|KeyTrans]] (IETF draft 04, April 2026) — productized version, used by WhatsApp AKD at 2B-user scale
- [[../../raw/papers/2026-06-01-verdict-transparency-dictionaries|Verdict]] (NDSS 2022) — extends to "current value plus permitted-transition proof" via SNARKs

KeyTrans's two-tree design is the right shape:

- **Prefix tree** — `(label, version) → commitment(value)` — quick lookup of current state
- **Log tree** — chronologically appended prefix-tree roots — auditable history

For a fleet, label = device slot ID, version = rotation epoch, value = current pubkey/identity statement. This gives:
- O(log N) inclusion proofs
- Constant per-device monitoring cost
- VRF-derived search keys hide which device is being looked up
- Append-only history is verifiable across epochs

## Throughput sizing ([[../../raw/data/2026-06-01-fleet-ops-numerical-baseline|baseline]])

| System | Mean rate |
|---|---|
| Cloudflare Nimbus2025 (CT log) | ~70 req/s write, ~380 req/s read |
| Sigstore Rekor (Mar 2021 → Oct 2025) | **~2.2 entries/sec average** |
| Sectigo Sabre2026h1 (single shard) | ~493k entries/day |

**1000-device fleet × 1 audit event/min/device = ~17 events/sec** — well within Rekor's headroom and an order of magnitude below Cloudflare's write rate.

**Audit-log scale is not a bottleneck for any fleet under ~10k devices.** This is good news: you can lean on existing transparency-log technology even if your fleet is small.

## Tile-backed logs (Tessera) win in 2025+

[[../../raw/articles/2026-06-01-rekor-v2-ga|Rekor v2]] replaced Trillian with Tessera — tile-backed, CDN-cacheable read paths, lower op cost. New tiled CT logs (Let's Encrypt Sycamore/Willow, Sectigo Elephant/Tiger) target **MMD = 60 sec** instead of the classic 86,400-sec/24-hour MMD.

For 2026+ builds: copy this architecture, not RFC 6962-era Trillian.

## Edge RPC concerns

### Idempotency under retry

Exactly-once delivery is a myth. Design for at-least-once + idempotent ingest + dedup window keyed by `(device_id, event_id)`.

### Ordering

Ordering is only end-to-end if **the server assigns sequence numbers**. Client-stamped sequence numbers race under retry. Idempotency keys help dedup but don't establish total order. Use server-assigned global sequence + client-assigned `(device_id, monotonic_local_seq)` for local audit.

### Realtime vs batch tension

- Small writes blow bandwidth and battery on edge links
- Large batches lose recent events on crash
- Group-commit (io_uring style) is the working pattern, adds complexity

### Compaction breaks proofs

Any "we deleted old entries" mechanism invalidates historical inclusion proofs. **Append-only contract is all-or-nothing.** Plan for unbounded growth or accept losing proof-coverage of historical entries.

## Recommendation for a 2026+ edge-fleet audit log

1. **Device-local layer** (Schneier-Kelsey style):
   - Forward-secure hash chain with key evolution
   - On-disk JSONL or CBOR-Sequence
   - MAC each entry with the evolving key
   - Pre-pend STH on rollover for correlation with server log

2. **Server-side layer** (SCITT shape):
   - COSE_Sign1 statements per identity transition + per material event
   - Receipts as COSE-signed Merkle inclusion proofs
   - kid = RFC 9679 COSE Key Thumbprint
   - Tile-backed Merkle log (Tessera) — not Trillian
   - Target MMD ≤ 60 sec (modern tier)

3. **Witness layer**:
   - Mirror STHs into Sigstore Rekor (free witnesses-as-a-service for small fleets)
   - For large fleets, run 2-3 independent witness instances co-signing your STH

4. **Wire**:
   - Server-assigned global sequence
   - Client-assigned `(device_id, monotonic_local_seq)` for audit
   - Idempotency keys = `(device_id, event_id)`
   - At-least-once + dedup window (e.g., 24 hours)

5. **What to log**:
   - Slot enrollment, deauth, RMA
   - Key rotations (with `previous_kid` chain — see [[signed-identity-envelopes]])
   - Tier changes (Mender pattern)
   - Attestation Evidence (RATS RFC 9334 Passport-Model receipts)
   - Material configuration changes (signed target-state versions)

6. **What NOT to log**:
   - Per-RPC noise (rate-limit/heartbeat)
   - PII in plaintext (Evidence "reveal[s] a great deal of information about the internal state of a device")
   - Anything that can't be cleanly versioned (raw blob payloads — log a digest instead)

## See also

- [[single-slot-fleet-identity]] — what slot transitions are recorded
- [[signed-identity-envelopes]] — wire format of statements
- [[../topics/edge-fleet-operational-patterns-2026|topic synthesis]]
