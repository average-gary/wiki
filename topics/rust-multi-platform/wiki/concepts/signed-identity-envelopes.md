---
title: "Versioned Signed Identity Envelopes — Encoding & Rotation"
type: concept
created: 2026-06-01
updated: 2026-06-01
verified: 2026-06-01
status: active
quality: high
volatility: medium
sources:
  - raw/guides/2026-06-01-rfc-9052-cose-structures.md
  - raw/repos/2026-06-01-dsse-envelope-spec.md
  - raw/repos/2026-06-01-tuf-spec.md
  - raw/repos/2026-06-01-sigstore-bundle-protobuf.md
  - raw/repos/2026-06-01-paseto-v4-public.md
  - raw/repos/2026-06-01-in-toto-attestation-statement.md
  - raw/repos/2026-06-01-uptane-standard.md
  - raw/guides/2026-06-01-rfc-7517-jwk.md
  - raw/guides/2026-06-01-rfc-9421-http-message-signatures.md
  - raw/articles/2026-06-01-rfc-8152-historical.md
  - raw/articles/2026-06-01-toml-no-canonical-form.md
  - raw/articles/2026-06-01-cendyne-ed25519-deep-dive.md
  - raw/articles/2026-06-01-nip-46-remote-signing.md
  - raw/articles/2026-06-01-nip-26-delegation.md
  - raw/papers/2026-06-01-ed25519-provable-security.md
  - raw/data/2026-06-01-fleet-ops-numerical-baseline.md
---

# Versioned Signed Identity Envelopes — Encoding & Rotation

How to design a long-lived ed25519-signed identity envelope that survives multiple schema revisions and key rotations without breaking deployed clients.

## TL;DR

- **Don't sign raw TOML.** TOML has no canonical form. Sign canonical-JSON (RFC 8785 JCS), deterministic CBOR (pinned to RFC 8949 §4.2), or protobuf wire format.
- **Use COSE_Sign1 (CBOR) or DSSE (JSON) as the envelope** — both have working canonicalization disciplines (sign-the-bytes for COSE, PAE for DSSE).
- **Three layers of versioning**: (1) envelope protocol version (un-spoofable prefix), (2) statement schema version (URI), (3) inner payload version (URI). Each evolves independently.
- **Two rotation idioms**: dual-sign chain (TUF, DSSE multi-sig) for offline/intermittent fleets, short-lived cert under long-lived root (Sigstore) for always-online.
- **Specify Ed25519-IETF (RFC 8032)** explicitly. Don't say "ed25519" — three security-distinct variants exist.
- **Pin one verifier impl** across server and edge — library divergence is real and exploited.

## Encoding choice

### TOML / YAML / raw JSON: do not sign

| Format | Canonical form | Signing-suitable? |
|---|---|---|
| TOML | NO (multiple representations of same data) | **No** |
| YAML | NO (same problem + indentation) | **No** |
| Raw JSON | ambiguous (key ordering, escape forms) | needs JCS |
| **Canonical JSON (RFC 8785 JCS)** | yes | Yes |
| **Deterministic CBOR (RFC 8949 §4.2)** | yes (pin spec version) | Yes |
| **Protobuf wire format** | yes (deterministic by tag number) | Yes |

See [[../../raw/articles/2026-06-01-toml-no-canonical-form|TOML has no canonical form]] for the concrete failure case.

**TOML can still serve as the human-edited source** — parse → project to JSON-with-sorted-keys → sign with JCS. Source format on disk ≠ signed bytes on the wire.

### CBOR vs Protobuf vs JSON for the wire

From [[../../raw/data/2026-06-01-fleet-ops-numerical-baseline|fleet-ops numerical baseline]]:

| Format | Size (rel JSON) | Speed (rel JSON) | Canonical form | IoT toolchain |
|---|---|---|---|---|
| Protobuf | **0.3×** | encode 3×, decode 4× | yes | requires .proto |
| CBOR (det-CBOR) | 0.7× | similar | yes | RFC 8949 |
| JSON (JCS) | 1.0× | baseline | yes (JCS) | universal |

**Recommendation by deployment target**:
- Constrained MCU (Cortex-M class): **CBOR/COSE_Sign1** — <2 KB parser footprint, IETF-standard signing
- Linux gateway / server: **CBOR or Protobuf** — both fine; CBOR if interop with COSE/SCITT/EAT, Protobuf if interop with Sigstore/in-toto bundles
- Web/JS/debugging: **JCS-canonical JSON** with PAE framing (DSSE-style)

## Envelope structure

### COSE_Sign1 (CBOR; [[../../raw/guides/2026-06-01-rfc-9052-cose-structures|RFC 9052]])

```
[ protected, unprotected, payload, signature ]
```

- `protected` is a CBOR-encoded **byte string** — signed verbatim, no canonicalization re-encode hazard
- `unprotected` is mutable, excluded from signature (use for ephemeral routing/transport metadata)
- Sign over `Sig_structure` containing context string `"Signature1"` + protected + ext-AAD + payload

This is the cleanest sign-the-bytes pattern in the industry.

### DSSE (JSON; [[../../raw/repos/2026-06-01-dsse-envelope-spec|DSSE spec]])

```json
{
  "payload": "<base64 bytes>",
  "payloadType": "<URI>",
  "signatures": [{"keyid": "...", "sig": "..."}]
}
```

PAE framing:
```
"DSSEv1" SP LEN(type) SP type SP LEN(body) SP body
```

The literal `"DSSEv1"` domain-separates these signatures from any other ed25519 signature the key produces. **PAE is the gold standard for length-prefixed pre-hash framing** — copy this in any custom envelope spec.

`signatures` is an array → multi-sig is first-class → dual-sign rotation works out of the box.

## Three-layer versioning

The cleanest version layout in the dataset is in-toto Statement v1 ([[../../raw/repos/2026-06-01-in-toto-attestation-statement|in-toto]]):

| Layer | Where | Cadence | Example |
|---|---|---|---|
| **Envelope protocol** | un-spoofable prefix or MIME | very rare (once per decade) | `"DSSEv1"`, `vnd.dev.sigstore.bundle.v0.3+json`, `v4.public.` |
| **Statement schema** | URI in `_type` | rare (once per major redesign) | `https://in-toto.io/Statement/v1` |
| **Predicate (payload)** | URI in `predicateType` | more often (new attrs) | `https://slsa.dev/provenance/v1` |

Each evolves on its own URI cadence; consumers branch on the URI. **No central registry needed.**

For a long-lived edge device identity envelope:
- v1 envelope (DSSE/COSE) — stable across the fleet's lifetime
- v1 statement schema — evolves rarely (once per fleet redesign)
- v1 predicate — evolves more often (new device attrs, attestation types)

### Where the version field LIVES matters

- **Un-spoofable**: outside the parsed structure (PASETO `v4.public.` prefix, Sigstore `media_type` MIME, in-toto `_type` URI). Cannot be silently swapped.
- **Spoofable unless inside protected bytes**: COSE `content type` header must be in `protected`; TUF `spec_version` must be inside `signed`.

If the version field is mutable, the protocol is downgrade-attackable.

## Key identification (`kid`)

Two competing approaches:

| Approach | Source | Property |
|---|---|---|
| Opaque hint | DSSE, COSE, JWS | applications must NOT trust kid for key selection without independent binding |
| Content-addressed | TUF (`SHA-256(canonical JSON of pubkey)`), SCRAPI (RFC 9679 COSE Key Thumbprint) | keyids cannot collide or be spoofed across rotations |

**Recommendation**: use content-addressed kids (RFC 9679 thumbprint). Removes a class of confusion bugs. Same trick TUF and SCITT use.

Bonus: with content-addressed kids, a `kid` "collision" (two valid keys sharing a kid) is structurally possible only during the rotation overlap window — exactly when you want it.

## Rotation: two idioms

### Dual-sign chain (TUF, DSSE multi-sig, COSE multi-sig)

Version N+1 must be signed by **both** a threshold of N's keys AND a threshold of N+1's own keys. Clients walk the chain incrementally.

- Works **offline** — verification doesn't need to reach a CA
- Requires explicit version monotonicity (counter inside `signed`)
- Threshold rule: dedupe `keyid` in signature array to prevent threshold inflation

Pattern transfers directly to edge fleet identity rotation. The "root" = the fleet identity directory; each version = one rotation round.

### Short-lived cert under long-lived root (Sigstore, X.509 PKI)

Long-lived root → short-lived (~10 min) signing cert via OIDC + Fulcio.

- Rotation pain **vanishes** — there's no long-lived signing key to rotate
- **Requires online sign** — bad fit for offline/intermittent edge

### Edge fleet recommendation

Default to **dual-sign chain** because edge fleets must function during connectivity gaps. Reserve Sigstore-style ephemeral identity for cloud-side fleet-management automation (where always-online is fair to assume).

Note Cosign v3 + sigstore-c (Apr 2026) close the embedded-verification gap — see [[../../raw/articles/2026-06-01-cosign-v3|Cosign v3]] — so the trade-off is shifting.

## Hot/cold key split (universal pattern)

Appears in NIP-46, NIP-26, Uptane Root, Matrix cross-signing (master vs self-signing), Sigstore (OIDC identity vs ephemeral signing key), TUF (offline root vs online roles).

**Edge fleets should not invent.** Pattern:

| Key | Lifetime | Where stored | What it signs |
|---|---|---|---|
| **Cold (root) key** | very long (5-10y) | offline / threshold-distributed | only re-keying ceremonies |
| **Per-device long-lived key** | long (180d-yrs) | TPM/SE on device | normal operations |
| **Per-session ephemeral** | short (mins-hrs) | RAM only | scoped messages |

Uptane formalizes this for automotive OTA — see [[../../raw/repos/2026-06-01-uptane-standard|Uptane Standard 2.0.0]]. The role-separation + offline-root + threshold + monotonic-version model is directly liftable.

## ed25519 specifics

### Variant selection ([[../../raw/papers/2026-06-01-ed25519-provable-security|Brendel et al. 2021]])

| Variant | EUF-CMA | SUF-CMA | M-S-UEO |
|---|---|---|---|
| Ed25519-Original (Bernstein 2011) | yes | **no** (malleable) | partial |
| **Ed25519-IETF (RFC 8032)** | yes | yes | yes |
| Ed25519-LibS (libsodium) | yes | yes | yes |

**Spec RFC 8032 explicitly.** SUF-CMA matters because signatures often double as idempotency keys. M-S-UEO matters because fleet directories have many keys.

### Library divergence ([[../../raw/articles/2026-06-01-cendyne-ed25519-deep-dive|Cendyne]])

Real, named incidents: Tor batch-verification bug, ZCash consensus crisis. **Pin one verifier impl** across server and edge. Don't mix dalek-server with libsodium-edge.

### Side channels

Fault attacks on ed25519 are practical with cheap SDR. Long-lived keys in physically accessible edge boxes are the worst case. **Pair with TPM/SE** if available, or accept the threat in the threat model.

### Public-key confusion

APIs that accept a separate pubkey parameter enable a known attack → wrap signing to derive pubkey internally.

## Worked envelope (sketch)

For an edge fleet device identity envelope, the recommended starting point:

```
Outer:    DSSE envelope (JSON)            -- multi-sig array enables rotation
          payloadType:
            "application/vnd.fleet.identity-statement+cbor"
                                          -- inner schema ID, un-spoofable
          PAE framing                     -- "DSSEv1" + length-prefixed bytes
          signatures: [{kid, sig}, ...]   -- kid = COSE Key Thumbprint (RFC 9679)

Inner:    Identity Statement (deterministic CBOR)
          _type:           "https://fleet.example/Statement/v1"
          subject:         [{ digest: { sha256: <hardware-fingerprint> } }]
          predicateType:   "https://fleet.example/predicate/Identity/v1"
          predicate:
            device_id:     <hardware-derived>
            slot_version:  <monotonic int>
            slot_epoch:    <epoch ID for freshness>
            attestation:   <RATS Evidence per RFC 9334>
            valid_from:    <ISO 8601>
            valid_until:   <ISO 8601>
            previous_kid:  <thumbprint of prior key, or null at v0>
```

This combines:
- DSSE PAE framing (no canonicalization bugs)
- DSSE multi-sig array (dual-sign rotation)
- in-toto-style three-layer URI versioning
- Det-CBOR inner statement (size, IoT-friendly)
- Content-addressed kid (RFC 9679)
- Hardware-derived subject digest (Mender pattern)
- `previous_kid` chain (auditable rotation history)

The audit log's job — see [[append-only-audit-logs-edge-rpc]] — is to record the sequence of these statements so any verifier can replay rotations and detect equivocation.

## See also

- [[single-slot-fleet-identity]] — what these envelopes describe
- [[append-only-audit-logs-edge-rpc]] — how envelope sequence is recorded
- [[../topics/edge-fleet-operational-patterns-2026|topic synthesis]]
