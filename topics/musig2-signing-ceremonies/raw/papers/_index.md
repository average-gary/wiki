# papers Index

Last updated: 2026-07-16

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [MuSig2: Simple Two-Round Schnorr Multi-Signatures](2026-07-16-musig2-paper-nick-ruffing-seurin.md) | The canonical MuSig2 paper: two-round, concurrently-secure, key-aggregating Schnorr multisig; first round preprocessable. | musig2, two-round, concurrent-security, key-aggregation | 2026-07-16 |
| [On the (in)security of ROS](2026-07-16-ros-attack-benhamouda-et-al.md) | Polynomial/sub-exponential attack on ROS; breaks concurrent naive two-round Schnorr multisig and original FROST — the attack MuSig2 resists. | ros-attack, wagner-attack, concurrent-security | 2026-07-16 |
| [Simple Schnorr Multi-Signatures (MuSig1)](2026-07-16-musig1-maxwell-poelstra-seurin-wuille.md) | Original MuSig: key aggregation in the plain public-key model; three-round variant with a nonce-commitment round (the round MuSig2 removes). | musig1, three-round, nonce-commitment, key-aggregation | 2026-07-16 |
| [MuSig-DN: Verifiably Deterministic Nonces](2026-07-16-musig-dn-deterministic-nonces.md) | Why RFC-6979-style determinism is unsafe in multisig; PRF-derived nonces + ZK proof for stateless signing. Contrast with BIP-340. | musig-dn, deterministic-nonces, nonce-reuse, zero-knowledge-proof | 2026-07-16 |
| [ROAST: Robust Asynchronous Schnorr Threshold Signatures](2026-07-16-roast-robust-asynchronous-schnorr-threshold.md) | Wrapper making FROST robust/asynchronous via a coordinator pool; defines robustness and the identifiable-abort requirement. | roast, robustness, identifiable-abort, dropout-handling | 2026-07-16 |
| [RFC 9591: The FROST Protocol](2026-07-16-rfc-9591-frost.md) | Standardized two-round t-of-n threshold Schnorr; precomputable commitment round, Coordinator role, explicitly non-robust. | frost, rfc-9591, threshold-signatures, commitment-round | 2026-07-16 |

## Recent Changes

- 2026-07-16: Ingested 6 primary papers (MuSig2, ROS attack, MuSig1, MuSig-DN, ROAST, RFC 9591 FROST) in the founding research round.
