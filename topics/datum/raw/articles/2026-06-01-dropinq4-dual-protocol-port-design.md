# Dual-Protocol Downstream: Port Design for SV1 + SV2 on One Binary

**Date:** 2026-06-01
**Sub-question:** Q4 / dual-protocol drop-in
**Sources:** sv2-spec/03-Protocol-Overview.md, sv2-spec/04-Protocol-Security.md (raw.githubusercontent.com),
SRI `stratum-core/stratum-translation` Cargo.toml, `OCEAN-xyz/datum_gateway` example config

## Recommendation: dual-port (configured), not single-port (sniffed)

Two listeners, two TCP ports, configured statically:

- `stratum.listen_port` (default 23334) — SV1, byte-for-byte compatible with current C
  gateway. **Existing OCEAN miners point here unchanged.**
- `stratum_v2.listen_port` (default 23335 or operator's choice) — SV2, plaintext-frames-then-
  Noise handshake on connect. Disabled by default; operator opts in.

**Why dual-port wins over a sniffing single-port listener** (despite single-port being
technically feasible):

1. SV1 default port (23334) is what OCEAN published in their docs and what every
   datum_gateway_config.json on disk in 2026 already specifies. Reusing this port means
   miners don't reconfigure on switch day. **Zero miner-side change is the load-bearing
   product property.**
2. SV2-capable miners (BraiinsOS+ and similar) configure a pool URL with port. They are
   already configured to point at SV2-aware pools (e.g., `stratum+tcp2://...`); operators
   can safely configure miners for the new port without disturbing the SV1 fleet.
3. Sniffing introduces a 100ms-or-so first-frame-wait latency on every connection,
   complicates testing, and adds a class of bugs (slow-loris connections, peeking semantics
   on TLS / Noise). Dual-port has none of this.
4. Operators reading `netstat -tlnp` see two distinct ports — easier to reason about,
   easier to firewall, easier to rate-limit per-protocol if needed.

**Operator opt-in default-off SV2** because: turning on SV2 with no SV2 miners costs
nothing, but if the binary advertises a port it doesn't support, operators get confused
support tickets. Better to require explicit `enabled: true`.

## Single-port sniffing IS technically trivial — kept as fallback option

If for some reason an operator can only expose one port (NAT-constrained home node), a
single-port sniffing mode is implementable in ~30 lines of Rust. Confirmed by the SV2 spec:

- **SV1 first frame**: ASCII JSON-RPC, always begins with `{"id":` (printable, byte 0x7b).
  Newline-delimited.
- **SV2 first frame** (per `04-Protocol-Security.md`): "64 bytes plaintext EllSwift encoded
  public key" sent by the initiator as Noise_NX Act 1. The bytes are uniformly random
  (cryptographic ephemeral key in ElligatorSwift encoding). Probability of byte 0 being
  0x7b is 1/256. Probability of bytes 0..5 being `{"id":` is 1/256^6 ≈ 0.

So a sniff implementation can:

```rust
let mut peek = [0u8; 1];
stream.peek(&mut peek).await?;
match peek[0] {
    b'{' => handle_sv1(stream).await,
    _    => handle_sv2_noise(stream).await,
}
```

This is correct with overwhelming probability and the failure mode (rare SV2 connection
whose ephemeral key happens to start with 0x7b) self-corrects: the SV1 JSON parser will
reject the binary noise frame, drop the connection, and the miner will retry. The miner's
retry would presumably succeed because the second connection's random pubkey almost
certainly does not start with 0x7b.

**But still: dual-port is the recommended default.** Sniffing is an opt-in compatibility
mode for unusual deployments.

## SRI's `stratum-translation` is the right SV1-side adapter

From `stratum-core/stratum-translation/Cargo.toml` (SRI repo, main branch as of 2026-05-28):

> Description: "Stratum V1 ↔ Stratum V2 translation utilities for reuse across proxies,
> apps, and firmware"
> Version: 0.3.0
> License: MIT OR Apache-2.0
> Dependencies: binary_sv2 v5.0.0+, mining_sv2 v10.0.0+, channels_sv2 v6.0.0+,
>               sv1_api v4.0.0+, tracing, bitcoin

This crate IS the heart of the dual-protocol implementation. The Rust drop-in design:

```
                      ┌───────── port 23334 ─────────┐
SV1 ASIC ─── TCP ────►│ sv1_api decoder              │
                      │   ↓                          │
                      │ stratum_translation::sv1→sv2 │──┐
                      └──────────────────────────────┘  │
                                                        ▼
                                                    ┌─────────────────┐
                                                    │ DATUM upstream  │
                                                    │ client (Rust    │
                                                    │ port of         │
                                                    │ datum_protocol.c)│
                                                    └─────────────────┘
                                                        ▲
                      ┌───────── port 23335 ─────────┐  │
SV2 ASIC ─── TCP ────►│ noise-sv2 + mining_sv2       │──┘
                      │ (channels_sv2 for groups)    │
                      └──────────────────────────────┘
```

Key decision: Both downstream paths fan in to **one** DATUM upstream client (one connection
to OCEAN). That client serializes shares from both protocol fan-ins onto the single DATUM
session.

## Per-channel isolation risk (Q4 sub-question 3)

Risk: SV1 share submission gets head-of-line blocked behind SV2 channel ops, or vice versa.

Mitigation: standard Rust async pattern is per-share message dispatch onto an mpsc channel
with the DATUM upstream as a single consumer. As long as that mpsc has bounded capacity
with backpressure (and the backpressure surfaces to the SV1/SV2 sides as "share rejected,
retry"), HOL blocking is bounded. The C `datum_protocol.c` already has an analogous design
(see "queue" module — `src/datum_queue.c`). Concretely:

- `datum_blocktemplates_notify_othercause()` is called after reconnect to force a fresh
  job push to all downstream miners. The Rust port should fan this notify out to BOTH SV1
  and SV2 listeners.
- The `mining.pool_address` based username tagging (see Q4 keypair article) means SV1 and
  SV2 share submissions look identical to OCEAN at the upstream-protocol level. No
  per-protocol attribution divergence.

## Coinbase-output (V2 coinbaser) consistency

From `src/datum_coinbaser.c`:

```c
if (datum_protocol_is_active()) {
    i = datum_protocol_coinbaser_fetch(s);
}
// ...
s->available_coinbase_outputs[cbvalid].value_sats = outval;
s->available_coinbase_outputs[cbvalid].output_script_len = slen;
memcpy(s->available_coinbase_outputs[cbvalid].output_script,
       &coinbaser[cidx], slen);
```

The same `available_coinbase_outputs` structure must populate:

- SV1 `mining.notify` — split as coinb1 / extranonce_placeholder / coinb2 (encoded via
  `sv1_api`).
- SV2 `NewExtendedMiningJob.coinbase_tx_outputs` — passed through more directly as the
  serialized output set.

Both encodings start from the same byte sequence (the OCEAN-supplied output set). **No
divergence in payout destination is possible** as long as both encoders read from the same
in-memory `available_coinbase_outputs[]` array. This is a key correctness invariant the
Rust drop-in must preserve and test against (golden-vector test: feed a known coinbaser
blob, assert SV1 coinb2 hash matches and SV2 outputs serialization matches expected
bytes).

## Open question for Q5/Q6 agents

- What is the SV2 `OpenExtendedMiningChannel` semantic mapping when the upstream is DATUM
  rather than a pool? DATUM jobs are constructed locally from bitcoind's `getblocktemplate`
  + OCEAN's coinbaser. Each downstream SV2 miner needs an extended channel; how is
  `extranonce_size` reserved across SV1 and SV2 miners sharing the same upstream?
