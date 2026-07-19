# articles Index

Last updated: 2026-07-16

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [BIP-327: MuSig2 Specification](2026-07-16-bip-327-musig2-spec.md) | The normative MuSig2 spec: two rounds, SecNonce/PubNonce/SessionContext, all algorithms, nonce-generation rules, sign-once/erase, identifiable abort, tweaking. | bip-327, normative-spec, secnonce, session-context, identifiable-abort | 2026-07-16 |
| [BIP-373: MuSig2 PSBT Fields](2026-07-16-bip-373-musig2-psbt-fields.md) | PSBT key types carrying MuSig2 ceremony state (participant pubkeys 0x1a, pub nonce 0x1b, partial sig 0x1c); the PSBT is the session container for coordinator/hardware-wallet transport. | bip-373, psbt, session-framing, hardware-wallet | 2026-07-16 |
| [BOLT #2: Interactive Tx Construction](2026-07-16-bolt2-interactive-tx-construction.md) | Lightning dual-funding interactive-tx protocol: tx_add_input/output/tx_complete, channel_id session key, even/odd serial_id turn-taking, two-sided completion. Wire-protocol ceremony exemplar. | lightning, bolt-2, interactive-tx, session-framing, serial-id | 2026-07-16 |
| [BOLT: Simple Taproot Channels (MuSig2)](2026-07-16-bolt-simple-taproot-channels-musig2.md) | MuSig2 nonces/partial-sigs piggybacked into channel messages via TLV (next_local_nonce, partial_signature_with_nonce, next_local_nonces map); stateless nonce regen from the revocation shachain. | lightning, simple-taproot-channels, tlv, nonce-piggybacking, stateless-nonce | 2026-07-16 |
| [Kohen: Limited MuSig2 Nonce Reuse Attack](2026-07-16-kohen-musig2-nonce-reuse-attack.md) | Concrete algebra: single reuse trivially leaks single-signer key; in MuSig2 even one reuse is exploitable via ~256 concurrent sessions + Wagner (~2^37). | musig2, nonce-reuse, key-extraction, wagner-attack, forgery | 2026-07-16 |
| [Jonas Nick: MuSig2 Explainer](2026-07-16-jonas-nick-musig2-explainer.md) | Co-author's plain-language explainer: Drijvers concurrent-forgery, the two-nonce fix R_i = R_i,1 + b·R_i,2, and the backup/restore nonce-reuse footgun. | musig2, two-nonce, state-machine, backup-restore, drijvers-attack | 2026-07-16 |
| [Bitcoin Optech: MuSig Topic](2026-07-16-bitcoin-optech-musig-topic.md) | Ecosystem framing: round-count evolution, BIP-327/328/390/373 standardization timeline, libsecp256k1 + Lightning Loop adoption, interactive-ceremony context. | musig, standardization-timeline, adoption, interactive-ceremony | 2026-07-16 |

## Recent Changes

- 2026-07-16: Ingested 7 sources — 2 normative BIPs (327, 373), 2 Lightning BOLTs (interactive-tx, simple taproot channels), 2 security/explainer writeups (Kohen, Jonas Nick), and the Bitcoin Optech topic page.
