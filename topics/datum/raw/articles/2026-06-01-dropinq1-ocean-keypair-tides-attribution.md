---
title: "OCEAN keypair handling and TIDES attribution — the drop-in's load-bearing finding"
source: https://raw.githubusercontent.com/OCEAN-xyz/datum_gateway/master/src/datum_protocol.c
type: articles
tags: [datum-gateway, drop-in-replacement, ocean-handshake, ed25519, x25519, tides, attribution, load-bearing]
summary: "datum_gateway generates fresh Ed25519 + X25519 keypairs on every startup via crypto_sign_keypair / crypto_box_keypair. NO disk persistence. OCEAN cannot have a long-term identity for a gateway because the gateway doesn't have one. Therefore TIDES attribution is necessarily by per-share username (the miner's BTC payout address), not by gateway identity. This makes the drop-in dramatically simpler: no key import/migration, no on-disk state to preserve."
confidence: high
ingested: 2026-06-01
ingested_by: dropinq1
---

# OCEAN keypair handling and TIDES attribution

## The keypair is ephemeral — generated every startup

From `datum_protocol.c`:

```c
if (datum_encrypt_generate_keys(&local_datum_keys) != 0) {
    DLOG_FATAL("Could not generate our keys");
    return -1;
}
```

```c
int datum_encrypt_generate_keys(DATUM_ENC_KEYS *keys) {
    i = crypto_sign_keypair(keys->pk_ed25519, keys->sk_ed25519);
    if (i != 0) return i;
    i = crypto_box_keypair(keys->pk_x25519, keys->sk_x25519);
    ...
}
```

**No file I/O. No persistence. Every restart = new identity.** A grep of the module turns up no `fopen`, `write`, or path constants for key storage. There is no `~/.datum/keys/`, no `--keyfile` flag, nothing.

## What the gateway actually presents to OCEAN

In the handshake, the gateway seals an identity packet to OCEAN's pubkey:

```c
crypto_box_seal(&enc_hello_msg[sizeof(T_DATUM_PROTOCOL_HEADER)],
                hello_msg, i, pool_keys.pk_x25519);
```

The hello payload contains four keys (persistent + session Ed25519/X25519, all generated fresh at start). OCEAN verifies signatures from these in subsequent messages:

```c
crypto_sign_verify_detached(&data[h->cmd_len-crypto_sign_BYTES], data,
    h->cmd_len-crypto_sign_BYTES, pool_keys.pk_ed25519);
```

So OCEAN authenticates **the connection**, not a long-term gateway operator identity. Two restarts of the same gateway look like two different clients to OCEAN's TLS layer.

## TIDES attribution — by per-share username

Each share message carries the miner's username:

```c
char * const username = (char *)&msg[i];
if (((!datum_config.datum_pool_pass_full_users) &&
     (!datum_config.datum_pool_pass_workers)) || pow->username[0] == '\0') {
    i+=snprintf(username, 385, "%s", datum_config.mining_pool_address);
} else {
    // pass the miner-provided username (BTC address[.workername])
    ...
}
```

`pow->username` is whatever the SV1 miner sent in `mining.authorize` — the operator's BTC payout address, possibly with `.workername`. OCEAN's TIDES window aggregates shares **by username (BTC address)**, not by gateway pubkey. The gateway pubkey is connection-scoped only.

Cross-checked against the wiki's existing TIDES doc (`tides-payout.md`): TIDES is a sliding-window mechanism over share difficulty per payout address. The gateway is just a pipe; it doesn't carry an identity that affects payout.

## Why this matters for the drop-in

This is the biggest find of the drop-in survey:

1. **No key import / migration story needed.** A new SV2-fronted Rust gateway started in place of the C one will look identical to OCEAN — both look like fresh-keyed clients on first connect. Restart-day churn is zero, because every C-gateway restart already burns its keypair.

2. **No on-disk state to preserve.** The 8-job ring is in-memory only; share counters are in-memory; `datum_protocol.c` writes no state files. The drop-in can be stateless across restart and exactly match upstream behavior.

3. **TIDES windows roll up correctly across the swap.** Pre-swap shares from the C gateway and post-swap shares from the Rust drop-in are both attributed by the SAME username (the miner's BTC address). They land in the same TIDES bucket on OCEAN's side. The miner sees no payout discontinuity.

4. **Operator-perceived continuity is automatic** as long as: (a) the drop-in connects to OCEAN with valid handshake (any fresh keypair is fine), (b) miners reconnect to the same `:23334` and authenticate with the same BTC address (which they do — their config didn't change).

## What about gateway-level identity for ops dashboards

OCEAN's web UI may show "connected DATUM gateways" with their pubkeys; from the operator's perspective those entries already churn on every C-gateway restart. The drop-in inherits the same UX — there is no "this is the same gateway as yesterday" assertion to break.

## Caveat — what we did NOT verify

- We did not read OCEAN's pool-side code (closed). It is conceivable but unlikely that OCEAN has out-of-band per-instance reputation tied to a pubkey beyond the per-connection auth. Given the gateway publishes a fresh pubkey on every restart, OCEAN cannot rely on long-term gateway identity for attribution; this is a structural argument from the gateway side, not a confirmation from the pool side.
- `datum_pool_pass_full_users` and `datum_pool_pass_workers` config flags determine whether the username is forwarded in full or replaced by the gateway's `mining.pool_address`. The drop-in must preserve these semantics or TIDES attribution at the worker granularity changes.

## Drop-in compatibility verdict

**Trivial.** This is the easiest surface in the entire drop-in survey. There is no on-disk state, no long-term identity, no key migration, no TIDES discontinuity. The drop-in needs only: libsodium-equivalent (`ed25519-dalek` + `x25519-dalek` or `crypto_box`/`crypto_sign` via `dryoc`), generate fresh keys on startup, perform the handshake, and forward share messages with the username field unchanged.

## Justification

Resolves the highest-uncertainty question in the drop-in survey: "do we need to preserve a long-term gateway identity?" Answer: no, because no such thing exists in the C gateway today. This finding alone removes a class of risk from the drop-in design.
