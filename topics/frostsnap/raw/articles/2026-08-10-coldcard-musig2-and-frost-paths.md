---
title: "Coldcard already ships threshold Schnorr on Mk4 — MuSig2, libngu, and the BIP-445 FROST path"
source: "https://github.com/Coldcard/firmware/blob/new_edge/docs/musig.md"
type: articles
ingested: 2026-08-10
tags: [coldcard, mk4, musig2, frost, bip-327, bip-373, bip-390, bip-328, bip-445, chilldkg, libngu, ngu-secp256k1, micropython, psbt, threshold-signing]
summary: "The nearest-easier-path finding, which reframes the port thesis. Coldcard EDGE firmware already implements MuSig2 on Mk4: docs/musig.md states verbatim 'COLDCARD EDGE versions support MuSig2 from version 6.5.0X & 6.5.0QX' where X is Mk4 and QX is Q, implementing BIP-373 (PSBT fields), BIP-390 (musig() descriptor key expression) and BIP-328 (derivation for aggregate keys). It already solves the hard part a FROST signer needs - two-round interactive signing with secret nonce state: 'COLDCARD must stay powered up between 1st and 2nd round as necessary musig session data are stored in volatile memory only' and 'COLDCARD strictly differentiate between 1st & 2nd MuSig2 round. If COLDCARD provides nonce, it will not attempt to sign even if it could... To provide both nonce(s) & signature(s) signing needs to be preformed twice.' The vendor even documents a threshold workaround: 'Following policy is example how to do threshold multisig with MuSig2 (and Taptree) even thought MuSig2 is not a native threshold scheme' with tr(musig(@0,@1,@2),{{pk(musig(@0,@1)),pk(musig(@1,@2))},pk(musig(@0,@2))}) - t-of-n threshold Taproot spending available on Mk4 today. Under the hood, switck/libngu (submodule at external/libngu) wraps upstream bitcoin-core/secp256k1 and its ngu.secp256k1 module already exposes a complete MuSig2 API to MicroPython: MusigKeyAggCache, musig_pubkey_agg, musig_nonce_gen, MusigPubNonce, musig_nonce_agg, MusigAggNonce, musig_nonce_process, musig_partial_sign, MusigPartSig, musig_partial_sig_agg, musig_pubkey_ec_tweak_add, musig_pubkey_xonly_tweak_add, plus sign_schnorr/verify_schnorr and keypair with xonly_tweak_add and ecdh_multiply. It is gated by build flags NGU_INCL_MUSIG ?= 0 and NGU_INCL_SCHNORR ?= $(NGU_INCL_MUSIG) mapping to ENABLE_MODULE_SCHNORRSIG and ENABLE_MODULE_MUSIG - so MuSig2 being EDGE-only is a compile flag, not an architecture limit. The gap for a pure-MicroPython FROST: grepping k1.c for seckey_tweak_add, seckey_tweak_mul, seckey_negate, ec_pubkey_combine, ec_pubkey_tweak_mul returns zero hits, so the Lagrange-coefficient scalar arithmetic FROST needs is not exposed; a C-side addition is required. Upstream bitcoin-core/secp256k1 has no FROST module, unlike MuSig2, so there is no flag to flip - out-of-tree options are FrostDevKit/secp256k1-frost (Bank of Italy itcoin origin, RFC 9591) or Zcash Foundation's Rust frost-secp256k1-tr. The protocol layer is MicroPython, not C: shared/psbt.py holds MUSIG_SESSION_CACHE = {} keyed by session_digest with round detection via MUSIG_SESSION_CACHE.pop(session_digest, None), and already parses PSBT_IN_MUSIG2_PARTICIPANT_PUBKEYS, PSBT_IN_MUSIG2_PUB_NONCE, PSBT_IN_MUSIG2_PARTIAL_SIG and PSBT_OUT_MUSIG2_PARTICIPANT_PUBKEYS; desc_utils.py has a MusigKey class and musig_synthetic_node() with MUSIG_CHAIN_CODE = sha256(b'MuSig2MuSig2MuSig2') for BIP-328. BIP-445 (BIP-FROST-Signing, author Sivaram Dhakshinamoorthy, number assigned 2026-01-30, status Draft) is the standard a Coldcard would implement, and it states verbatim 'Tip: The Tweak Context is identical to the KeyAgg Context defined in BIP327. Implementations with existing BIP327 code can reuse it.' BIP-445 excludes key generation, deferring to ChillDKG or RFC 9591/9792 Appendix C, and defines no PSBT fields. Coinkite has said nothing about FROST: GitHub issue search on Coldcard/firmware gives FROST 0 results, BIP-327 0, musig 4, taproot 10, and no Coinkite blog post on MuSig2/FROST/threshold exists. EDGE carries a vendor warning that it 'has not yet been qualified and tested to the same standard as normal Coinkite products... DO NOT use for large Bitcoin amounts.' Community-extension ceiling datapoint: open PR #683 (third-party macgyver13, 32 files, +13,031 lines) adds MuSig2 + Silent Payments with invented provisional PSBT fields, and two of its tests fail with 'Coldcard Error: buffer too small' - evidence Mk4 RAM bites on multi-round multi-signer flows. Frostsnap's own side: Adam Mashrique, quoted in Protos, 'We want to set an open standard other vendors can implement. Our goal is for different makes of devices to be part of a FROST multisig wallet' and 'Our code on github is FOSS, so anyone is free to make and sell Frostsnap-compatible signing devices' - but Frostsnap's wire protocol is frostsnap_comms, not PSBT, and its security architecture requires genuine Frostsnap devices with factory-fused per-device secrets and authenticity certificates, so no drop-in bridge exists today. Display comparison confirmed from source: Q shared/lcd_display.py WIDTH=320 HEIGHT=240 color with CHARS_W=34 CHARS_H=10, QWERTY, QR scanner; Mk4 shared/display.py WIDTH=128 HEIGHT=64 SSD1306_SPI mono. But MuSig2 shipped simultaneously on both under a changelog heading 'Shared Improvements - Both Mk4 and Q', because the round-trip transport is PSBT over files/USB rather than an on-screen device-to-device ceremony - so the display gap is not the binding constraint; RAM and the missing DKG story are."
thesis: frostsnap-firmware-on-coldcard-mk4
relevance: direct
evidence_strength: primary-source-code
direction: nuances
credibility: high
confidence: high
authors: [Coinkite Inc., switck, Sivaram Dhakshinamoorthy]
fetched: 2026-08-10
---

# Coldcard already ships threshold Schnorr on Mk4

This is the finding that reframes the thesis. The premise — that you would need Frostsnap's firmware
to get threshold Schnorr signing onto a Coldcard Mk4 — is largely moot.

## MuSig2 ships on Mk4 today

`docs/musig.md` (new_edge), verbatim: **"COLDCARD® `EDGE` versions support MuSig2 from version
`6.5.0X` & `6.5.0QX`"** — `X` = Mk4, `QX` = Q. Mk4 is explicitly supported. Implements **BIP-373**
(PSBT fields), **BIP-390** (`musig()` descriptor key expression), **BIP-328** (aggregate-key
derivation).

Release history: Mk4 line at `6.5.0X - 2026-03-24`, under a changelog heading **"Shared Improvements
- Both Mk4 and Q"**: "New Feature: Ability to sign MuSig2 UTXOs" and "New Feature: BIP-322 Proof of
Reserves for Miniscript & MuSig2 UTXOs."

Vendor caveat: EDGE "has not yet been qualified and tested to the same standard as normal Coinkite
products. It is recommended only for developers and early adopters for experimental use. DO NOT use
for large Bitcoin amounts."

## It already solves the hard part — two-round signing with nonce state

The stateful interactive ceremony that looks like the obstacle for FROST on an air-gapped device is
already implemented and documented, verbatim:

> "COLDCARD must stay powered up between 1st and 2nd round as necessary musig session data are stored
> in volatile memory only"

> "COLDCARD strictly differentiate between 1st & 2nd MuSig2 round. If COLDCARD provides nonce, it will
> not attempt to sign even if it could... To provide both nonce(s) & signature(s) signing needs to be
> preformed twice."

## The vendor even documents a threshold workaround

> "Following policy is example how to do threshold multisig with MuSig2 (and Taptree) even thought
> MuSig2 is not a native threshold scheme"

```
tr(musig(@0,@1,@2),{{pk(musig(@0,@1)),pk(musig(@1,@2))},pk(musig(@0,@2))})
```

**t-of-n threshold Taproot spending, on Mk4, today.** It is n-of-n aggregation composed into t-of-n
by enumerating combinations in a taptree — less elegant than FROST (taptree grows combinatorially, no
DKG, no share rotation), but shipped. Constraints: only one own key per `musig()` expression, keys
must be xpubs, sorted before aggregation, hardened derivation disallowed.

## The crypto surface: `ngu.secp256k1` already exposes MuSig2 to MicroPython

`switck/libngu` (submodule at `external/libngu`) wraps upstream `bitcoin-core/secp256k1`. Modules:
`ngu.hdnode`, `ngu.hash`, `ngu.secp256k1`, `ngu.random`, `ngu.codecs`, `ngu.hmac`, `ngu.ec`,
`ngu.cert`, `ngu.aes`.

`ngu.secp256k1` exposes: `MusigKeyAggCache`, `musig_pubkey_agg`, `musig_nonce_gen`, `MusigPubNonce`,
`musig_nonce_agg`, `MusigAggNonce`, `musig_nonce_process`, `musig_partial_sign`, `MusigPartSig`,
`musig_partial_sig_agg`, `musig_pubkey_ec_tweak_add`, `musig_pubkey_xonly_tweak_add`, plus
`sign_schnorr`/`verify_schnorr` and `keypair` (with `.xonly_tweak_add`, `.ecdh_multiply`).

Gated at build time, default off: `NGU_INCL_MUSIG ?= 0`, `NGU_INCL_SCHNORR ?= $(NGU_INCL_MUSIG)` →
`ENABLE_MODULE_SCHNORRSIG` / `ENABLE_MODULE_MUSIG`. **MuSig2 being EDGE-only is a compile flag, not
an architecture limit.**

### The one real gap for a MicroPython FROST

Grepping `k1.c` for `seckey_tweak_add`, `seckey_tweak_mul`, `seckey_negate`, `ec_pubkey_combine`,
`ec_pubkey_tweak_mul` → **all zero hits**. FROST needs Lagrange-coefficient scalar multiply and point
addition for share verification. You cannot write it in MicroPython on today's `ngu`; a C-side
addition is required.

Upstream `bitcoin-core/secp256k1` has **no FROST module** — unlike MuSig2, there is no flag to flip.
Out-of-tree options: `FrostDevKit/secp256k1-frost` (Bank of Italy `itcoin` origin, RFC 9591) or Zcash
Foundation's Rust `frost-secp256k1-tr`.

## The protocol layer is MicroPython, and reusable

`shared/psbt.py` holds `MUSIG_SESSION_CACHE = {}` (module-level, RAM-only) keyed by `session_digest`,
with round detection: `session_rand = MUSIG_SESSION_CACHE.pop(session_digest, None)` — absent means
round 1, else round 2. Signing is plain Python: `musig_nonce_gen` → `musig_nonce_agg` →
`musig_nonce_process` → `musig_partial_sign`.

PSBT fields already parsed and serialized: `PSBT_IN_MUSIG2_PARTICIPANT_PUBKEYS`,
`PSBT_IN_MUSIG2_PUB_NONCE`, `PSBT_IN_MUSIG2_PARTIAL_SIG`, `PSBT_OUT_MUSIG2_PARTICIPANT_PUBKEYS`, with
composite-key parsing (`parse_musig_composite_key`). `desc_utils.py` has a `MusigKey` descriptor class
and `musig_synthetic_node()` / `MUSIG_CHAIN_CODE = sha256(b"MuSig2MuSig2MuSig2")` for BIP-328.

**Multi-round threshold signing over PSBT message passing already works on Coldcard.**

## BIP-445 is the standard a Coldcard would implement

BIP-FROST-Signing, author **Sivaram Dhakshinamoorthy**, **number 445 assigned 2026-01-30**, status
Draft. The key adjacency, verbatim from the draft:

> **"Tip: The Tweak Context is identical to the _KeyAgg Context_ defined in BIP327. Implementations
> with existing BIP327 code can reuse it."**

Coldcard *has* BIP-327 code. Structural match to what Coldcard already does: two communication rounds,
`secnonce` state persisted between them and never reused — "The _Sign_ algorithm must **not** be
executed twice with the same _secnonce_", and implementations should "securely erase the _secnonce_
argument by overwriting it with 64 zero bytes after it has been read." Coldcard's RAM-only
`MUSIG_SESSION_CACHE` plus strict round separation is already this design.

Two scope gaps: BIP-445 **excludes key generation**, deferring to **ChillDKG** (Jonas Nick et al.) or
RFC 9591/9792 Appendix C; and it defines **no PSBT fields**, so a BIP-373 analogue would have to be
written.

## No vendor demand signal

GitHub issue search on `Coldcard/firmware`: **`FROST` → 0 results**; `BIP-327` → 0; `musig` → 4;
`taproot` → 10. `threshold` returns only unrelated PSBT/typo issues. No Coinkite blog post on
MuSig2/FROST/threshold exists (the blog is currently dominated by the July-2026 entropy advisory).

Mk4 is **not** deprecated for advanced features — EDGE also ships full Miniscript/MiniTapscript on
Mk4, and 6.4.0X migrated all multisig wallets to internal Miniscript representation. Feature parity
between Mk4 and Q is the norm.

## Community-extension ceiling, with a RAM datapoint

Open PR #683 (base `new_edge`, third-party `macgyver13`, **32 files, +13,031 lines**) adds MuSig2 +
Silent Payments with new provisional PSBT fields invented for the purpose
(`PSBT_IN_MUSIG2_PARTIAL_ECDH_SHARE`, `PSBT_IN_MUSIG2_PARTIAL_DLEQ`), partial ECDH shares + DLEQ
proofs. Two tests fail with **"Coldcard Error: buffer too small"** — evidence that Mk4's RAM budget
bites on multi-round multi-signer flows.

## Frostsnap's own position: interop, not firmware sharing

Adam Mashrique (Frostsnap hardware lead), quoted in Protos, verbatim:

> "**We want to set an open standard other vendors can implement. Our goal is for different makes of
> devices to be part of a FROST multisig wallet.**"

> "**Our code on github is FOSS, so anyone is free to make and sell Frostsnap-compatible signing
> devices.**"

But Frostsnap's wire protocol is `frostsnap_comms`, **not PSBT**, and its security architecture
requires genuine Frostsnap devices — ESP32-C3 with a factory-fused per-device secret and authenticity
certificates, key share encrypted under both the chip secret and a coordinator-derived key. A Coldcard
cannot satisfy that provisioning model. The standard Mashrique describes does not yet exist as a spec.

## Q vs Mk4 — not the binding constraint

Confirmed from source: **Q** (`shared/lcd_display.py`) `WIDTH = 320`, `HEIGHT = 240`, color LCD,
`CHARS_W = 34`, `CHARS_H = 10`, QWERTY, QR scanner, battery, dual microSD. **Mk4**
(`shared/display.py`) `WIDTH = 128`, `HEIGHT = 64`, `SSD1306_SPI` mono, keypad, no camera.

Yet MuSig2 shipped **simultaneously on both**, because the round-trip transport is PSBT files/USB, not
an on-screen device-to-device ceremony. The Q would help a *Frostsnap-style* UI (device enumeration,
QR coordinator handshake, DKG progress across N devices) — but that UI is only needed if you replicate
Frostsnap's interaction model. Implementing BIP-445 over PSBT needs no new UI beyond what Mk4 already
renders for MuSig2. **The binding constraints are RAM and the missing DKG story, not the display.**

## The cheapest true-FROST path

1. Add a FROST module to `libngu` — a new build flag beside `NGU_INCL_MUSIG`, sourced from
   `secp256k1-frost` or hand-rolled on newly exposed scalar ops.
2. Implement BIP-445 in `shared/psbt.py`, reusing the KeyAgg/Tweak context and the
   `MUSIG_SESSION_CACHE` round machinery.
3. Define FROST PSBT fields (no standard exists yet).
4. Route it through Coldcard's "Medium Core" path — submit a PR for Coinkite security review — since
   that is the only way to end up with factory-signed firmware and a green light.

Real work, plausibly weeks-to-months for someone inside the codebase, but a different order of
magnitude from a firmware port. **The unsolved piece is DKG, not signing** — and that ceremony is what
Coldcard's air-gapped architecture is least able to host.

## See Also

- [Coldcard Mk4 custom-firmware constraints](../notes/2026-08-10-coldcard-mk4-custom-firmware-constraints.md)
- coldcard wiki: [Airgap signing workflows](../../../coldcard/wiki/topics/airgap-signing-workflows.md)
- coldcard wiki: [Signing formats](../../../coldcard/wiki/references/signing-formats.md)
- hub topic `musig2-signing-ceremonies`
