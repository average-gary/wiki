---
title: "BOLT 12 — Offer Encoding with transient payer keys and blinded paths"
source: https://github.com/lightning/bolts/blob/master/12-offer-encoding.md
type: article
tags: [bolt12, lightning, offer, transient-key, blinded-path, prior-art]
date: 2026-06-01
quality: 5
confidence: high
agent: applied
summary: "Offers are bech32-style TLV blobs with HRP `lno`. Payer authenticates with a transient invreq_payer_id (ephemeral pubkey), not a long-term identity. invreq_metadata carries derivation info so the payer can later prove key provenance to themselves. Recommended derivation: payer_id = base_pubkey + SHA256(base_pubkey || tweak)·G — i.e., BIP32-style key-tweak per request. Achieves unlinkable per-invoice subkeys without state. Blinded paths (offer_paths) hide issuer's real node_id behind ephemeral blinded_node_ids; rotated per offer. No revocation list — old keys just go unused."
---

# BOLT 12 — transient subkeys per offer

Lightning's solution to "I want a payment receipt that doesn't leak my long-term identity." The **per-use ephemeral subkey** pattern is highly relevant to iroh app token rotation.

## Tweaked-subkey derivation (the key insight)

```
payer_id = base_pubkey + SHA256(base_pubkey || tweak) · G
```

Where:
- `base_pubkey` = payer's long-term key
- `tweak` = per-request unique data
- `G` = secp256k1 generator

→ Each request gets a distinct subkey. The payer can later **prove provenance** of any subkey by revealing the tweak. Server cannot correlate subkeys to base_pubkey.

## invreq_payer_id

Per-request ephemeral pubkey. Sent to the merchant. Used to authenticate the invoice request without revealing the payer's long-term identity.

## invreq_metadata

Carries the tweak so the payer can later prove the subkey is theirs (e.g., for refund routing).

## Blinded paths

`offer_paths` hides the issuer's real node_id behind chains of ephemeral `blinded_node_ids`:

```
offer_path = [blinded_node_1, blinded_node_2, ..., blinded_node_n]
```

Each hop knows only its predecessor and successor. Issuer's identity is hidden until the final hop.

→ Per-offer rotation; blinded paths regenerate.

## Rotation cadence

**Per-invoice or per-offer.** No revocation list — old keys just go unused.

## Direct application to iroh app token

For the iroh app token with multiple authorized clients, BOLT 12's pattern means:

```rust
// Phone has master key
let master = load_master();

// To authenticate to iroh app `farm-ai-2026-Q2`:
let tweak = blake3::hash(format!("farm-ai 2026-Q2 session-{}", session_id).as_bytes());
let session_signing_key = master.tweak_add(&tweak);

// Send invreq-equivalent to iroh server:
let req = AuthRequest {
    session_pubkey: session_signing_key.public_key(),
    metadata: tweak,  // proves provenance later if needed
    sig_over_challenge: session_signing_key.sign(server_challenge),
};
```

→ Server can validate the session signature against `session_pubkey`. Cannot link `session_pubkey` to phone's master without seeing many sessions.

## Comparison to LUD-04

Both derive per-context subkeys. Differences:

| | LUD-04 | BOLT 12 |
|--|--------|---------|
| Derivation | BIP32 path from FQDN hash | Key-tweak from per-request data |
| Linkability | Same key per FQDN (correlatable across sessions on same domain) | Different key per offer/invoice |
| Use case | Repeated login to same site | One-shot payment authorization |
| Iroh fit | Persistent session (you're a known friend) | Ephemeral guest pairing |

## When to pick BOLT 12 style for iroh

For **guest pairing** where you don't want the homelab server to be able to correlate the same phone's appearances over time:

- Each pairing gets a fresh tweaked subkey
- Server stores `(subkey, capability, expiry)` — not "phone X has cap Y"
- Phone can prove provenance later (refund routing equivalent)

For **persistent friend allowlist**, LUD-04 or Tor v3 style (one stable key per friend) is simpler and sufficient.

## See also

- [[2026-06-01-lnurl-auth-derivation]]
- [[2026-06-01-tor-onion-v3-client-auth]]
- [[2026-06-01-iroh-docs-namespace-doctickets]]
