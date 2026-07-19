# concepts Index

Last updated: 2026-07-16

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [The MuSig2 Protocol](musig2-protocol.md) | Two-round n-of-n Schnorr multisig (BIP-327): key aggregation, the two rounds, the two-nonce trick, data structures, tweaking, security assumptions. | musig2, two-round, key-aggregation, bip-327, secnonce | 2026-07-16 |
| [Nonce Commit/Reveal Rounds](nonce-commit-reveal-rounds.md) | The commitment pre-round: why MuSig1 needed three rounds, how MuSig2's two-nonce hash-binding replaces it, how FROST keeps a precomputable commitment. | nonce-commitment, commit-reveal, three-round, concurrent-security | 2026-07-16 |
| [Nonce-Reuse Catastrophe](nonce-reuse-catastrophe.md) | Reusing a secret nonce leaks the key; in MuSig2 even one reuse is exploitable via concurrent sessions + Wagner. Deterministic-nonce ban, API guards, fresh-nonce-on-retry. | nonce-reuse, key-extraction, wagner-attack, secnonce, security | 2026-07-16 |
| [Session Framing and State](session-framing-and-state.md) | How the two rounds are carried on the wire: PSBT-as-session (BIP-373), TLV piggybacking (Lightning), session_id RPC (LND). Session identity, round gates, secret-nonce lifecycle. | session-framing, wire-protocol, session-id, psbt, tlv, coordinator | 2026-07-16 |
| [Dropout, Abort, and Robustness](dropout-abort-and-robustness.md) | MuSig2 is non-robust: any dropout aborts the ceremony. Identifiable abort via PartialSigVerify; fresh nonces on retry; ROAST adds robustness only to threshold schemes. | dropout, abort, robustness, identifiable-abort, roast, liveness | 2026-07-16 |
| [Deterministic vs Random Nonces](deterministic-vs-random-nonces.md) | Determinism is safe single-signer, fatal in multiparty; MuSig2 mandates randomness; MuSig-DN restores safe determinism with a ZK proof; LN uses distinct-per-height shachain derivation. | deterministic-nonces, musig-dn, rfc-6979, bip-340, stateless-signing | 2026-07-16 |
| [MuSig2 vs FROST/ROAST](musig2-vs-frost-roast.md) | Three interactive Schnorr ceremonies compared on threshold structure, round structure, and robustness. Why ROAST can't make n-of-n MuSig2 robust. | musig2, frost, roast, threshold-signatures, comparison, robustness | 2026-07-16 |

## Recent Changes

- 2026-07-16: Created 7 concept articles in the founding research round (protocol, commit/reveal rounds, nonce-reuse, session framing, dropout/abort, deterministic-vs-random nonces, MuSig2-vs-FROST/ROAST).
