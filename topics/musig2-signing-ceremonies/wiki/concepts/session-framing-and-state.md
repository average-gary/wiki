---
title: "Session Framing and State"
category: concept
sources: [raw/articles/2026-07-16-bip-373-musig2-psbt-fields.md, raw/articles/2026-07-16-bolt2-interactive-tx-construction.md, raw/articles/2026-07-16-bolt-simple-taproot-channels-musig2.md, raw/repos/2026-07-16-lnd-musig2-signer-api.md, raw/articles/2026-07-16-bip-327-musig2-spec.md]
created: 2026-07-16
updated: 2026-07-16
tags: [session-framing, wire-protocol, state-machine, session-id, psbt, tlv, coordinator, lightning, lnd, stateless-nonce]
aliases: [session framing, wire protocol framing, MuSig2 session state, ceremony framing]
confidence: high
volatility: warm
verified: 2026-07-16
summary: "How a MuSig2 ceremony is carried over a real transport. BIP-327 specifies the cryptography but leaves framing to the application. Real systems use three patterns: PSBT-as-session-container (BIP-373, hardware wallets), message-piggybacking with TLVs (Lightning simple taproot channels), and an RPC session keyed by session_id (LND). The session must persist the secret nonce between rounds — or regenerate it deterministically to avoid persistence."
---

# Session Framing and State

> BIP-327 defines *what* the two rounds compute but deliberately says nothing about *how* the messages travel between signers — that is left to the application/transport layer. A running MuSig2 deployment must therefore answer a set of framing questions: how is a session identified and correlated across parties, who collects and aggregates the nonces (coordinator vs. peer-to-peer), how are the two rounds synchronized, and where does each signer's secret-nonce state live between Round 1 and Round 2. The observed deployments cluster into three framing patterns.

## What must be framed

- **Session identity.** A stable identifier that correlates a party's Round-1 nonce with its Round-2 partial signature and distinguishes concurrent sessions.
- **Round synchronization.** A signal that Round 1 is complete (all nonces in) before anyone signs.
- **Topology.** Either a central **coordinator/aggregator** collects nonces and partial sigs and redistributes, or peers exchange in a **full mesh**.
- **State between rounds.** Each signer holds a live `SecNonce` from Round 1 until the aggregate nonce arrives in Round 2. This state is exactly what must never be duplicated — see [[nonce-reuse-catastrophe|Nonce-Reuse Catastrophe]] ([Nonce-Reuse Catastrophe](nonce-reuse-catastrophe.md)).

## Pattern 1 — PSBT as the session container (BIP-373)

For hardware wallets and coordinator apps, the ceremony state rides inside a shared **PSBT** passed among signers. BIP-373 defines per-input key types:

- `PSBT_IN_MUSIG2_PARTICIPANT_PUBKEYS` (`0x1a`) — ordered participant list defining aggregation order.
- `PSBT_IN_MUSIG2_PUB_NONCE` (`0x1b`) — a signer's Round-1 public nonce (66 B).
- `PSBT_IN_MUSIG2_PARTIAL_SIG` (`0x1c`) — a signer's Round-2 partial signature (32 B).

Here the **session identity is implicit** in the `(participant pubkey, aggregate pubkey, tapleaf hash)` tuple inside the PSBT, and the PSBT itself is the passed-around session object. Round 1 appends `PUB_NONCE` fields; Round 2 appends `PARTIAL_SIG` fields; a finalizer runs `PartialSigAgg`.

## Pattern 2 — Message-piggybacking with TLVs (Lightning simple taproot channels)

Lightning's dual-funding [[interactive-tx-wire-protocol|interactive transaction protocol]] ([interactive transaction protocol](interactive-tx-wire-protocol.md)) already frames a two-party ceremony keyed by `channel_id`. Simple Taproot Channels fold MuSig2 into it **without adding round trips** by attaching nonces/partial-sigs as TLV fields on existing messages:

- `open_channel`/`accept_channel` and `channel_ready` carry `next_local_nonce` (TLV type 4, 66 B).
- `funding_created`/`funding_signed` and `commitment_signed` carry `partial_signature_with_nonce` (TLV type 2, 98 B = 32-byte partial sig ‖ 66-byte nonce).
- `revoke_and_ack`/`channel_reestablish` carry `next_local_nonces` (TLV type 22) — a **map from `funding_txid` to a nonce**, supporting multiple concurrent commitments and reconnection recovery.

Critically, this pattern **avoids persisting the secret nonce**: nonces are regenerated deterministically from the revocation shachain (`musig2_shachain_root = hmac("taproot-rev-root" ‖ funding_txid, sha256(shachain_root))`; height N uses the Nth shachain leaf as the `rand'` input to `NonceGen`). Because each commitment height derives a *distinct* nonce, this is safe determinism, not the banned kind — it never reuses a nonce, and it removes the backup/restore footgun entirely. Nonces are discarded on disconnect and recovered via `channel_reestablish`.

## Pattern 3 — RPC session keyed by session_id (LND)

LND's `signrpc` exposes the ceremony as a stateful RPC sequence:

1. `MuSig2CombineKeys` (stateless key-agg helper)
2. `MuSig2CreateSession` → returns a **`session_id`** and the local public nonces
3. `MuSig2RegisterNonces` (Round 1; repeatable as peers' nonces arrive; sets `have_all_nonces`)
4. `MuSig2Sign` (Round 2; callable **only once per `session_id`**)
5. `MuSig2CombineSig`

Here the **`session_id` is the explicit correlation handle**, the `have_all_nonces` flag is the explicit round-synchronization gate, and the once-per-session signing rule is the reuse guard. The caller acts as one signer collecting others' nonces — a coordinator-style topology.

## The framing/crypto boundary

The recurring lesson across all three patterns: the cryptographic core (BIP-327) is identical, but the **framing** — session ID, round gate, topology, and secret-nonce lifecycle — is where interoperability, liveness, and much of the security risk actually live. Two implementations can both be BIP-327-correct yet fail to interoperate because they frame the session differently.

## See Also

- [[interactive-tx-wire-protocol|Interactive Transaction Wire Protocol]] ([Interactive Transaction Wire Protocol](interactive-tx-wire-protocol.md)) — the Lightning framing skeleton MuSig2 is layered onto
- [[nonce-reuse-catastrophe|Nonce-Reuse Catastrophe]] ([Nonce-Reuse Catastrophe](nonce-reuse-catastrophe.md)) — why the secret-nonce lifecycle dominates framing design
- [[dropout-abort-and-robustness|Dropout, Abort, and Robustness]] ([Dropout, Abort, and Robustness](dropout-abort-and-robustness.md)) — reconnection, restart, and round-timeout handling
- [[musig2-protocol|The MuSig2 Protocol]] ([The MuSig2 Protocol](musig2-protocol.md)) — the SecNonce and SessionContext structures being framed
- [[musig2-interactive-signing-ceremonies|MuSig2 Interactive Signing Ceremonies]] ([MuSig2 Interactive Signing Ceremonies](../topics/musig2-interactive-signing-ceremonies.md)) — the umbrella topic

## Sources

- [BIP-373: MuSig2 PSBT Fields](../../raw/articles/2026-07-16-bip-373-musig2-psbt-fields.md) — the PSBT-as-session-container framing
- [BOLT: Simple Taproot Channels (MuSig2)](../../raw/articles/2026-07-16-bolt-simple-taproot-channels-musig2.md) — TLV piggybacking and stateless shachain nonce regeneration
- [BOLT #2: Interactive Tx Construction](../../raw/articles/2026-07-16-bolt2-interactive-tx-construction.md) — channel_id session identity and turn-taking
- [LND MuSig2 Signer API](../../raw/repos/2026-07-16-lnd-musig2-signer-api.md) — the session_id RPC framing and have_all_nonces gate
- [BIP-327: MuSig2 Specification](../../raw/articles/2026-07-16-bip-327-musig2-spec.md) — the SessionContext and the framing/crypto boundary
