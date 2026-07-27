---
title: ark-boarding-sv2-mining — raw/papers index
type: raw-subindex
---

# raw/papers

| File | Credibility | Direction | Source |
|---|---|---|---|
| bip-341-taproot | high | supports | BIP-341 (Taproot sighash) |
| bip-118-anyprevout | high | nuances | BIP-118 (APO) |
| bip-327-musig2 | high | supports | BIP-327 (MuSig2, "Deployed") |

- [[2026-07-17-bip-118-anyprevout.md|BIP-118: SIGHASH_ANYPREVOUT]] — APO lets signatures NOT commit to the exact UTXO, enabling dynamic rebinding / presign-before-it-exists…
- [[2026-07-17-bip-327-musig2.md|BIP-327: MuSig2 for BIP340 Multi-Signatures]] — Status Deployed; n-of-n (not threshold) aggregate Schnorr sig; Taproot-tweakable; on-chain footprint = single…
- [[2026-07-17-bip-341-taproot.md|BIP-341: Taproot signature message]] — Default sighash commits to the 36-byte outpoint plus sha_amounts and sha_scriptpubkeys — so a normal…
