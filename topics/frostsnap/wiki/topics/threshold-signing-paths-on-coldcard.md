---
title: "Threshold signing paths on Coldcard"
category: topic
sources:
  - raw/articles/2026-08-10-coldcard-musig2-and-frost-paths.md
  - raw/notes/2026-08-10-port-thesis-confounders-and-steelman.md
  - raw/articles/2026-08-10-frostsnap-key-derivation-design.md
created: 2026-08-10
updated: 2026-08-10
tags: [coldcard, musig2, frost, bip-445, bip-373, bip-390, bip-328, chilldkg, libngu, psbt, threshold-signing, interop]
aliases: ["FROST on Coldcard", "MuSig2 on Mk4", "BIP-445 path"]
confidence: high
volatility: warm
verified: 2026-08-10
summary: "If the goal is threshold Schnorr signing on a Coldcard rather than Frostsnap's firmware specifically, the shortest path does not involve porting anything. Coldcard EDGE already ships MuSig2 on Mk4 from version 6.5.0X, implementing BIP-373, BIP-390 and BIP-328, and the vendor documents a t-of-n threshold workaround composing musig() aggregation inside a taptree. Crucially it already solves the piece that looks hardest for an air-gapped FROST signer: two-round interactive signing with RAM-only secret nonce state and strict round separation. The remaining gap to true FROST is narrow and specific. ngu.secp256k1 exposes a complete MuSig2 API behind the NGU_INCL_MUSIG build flag, but exposes no scalar arithmetic — seckey_tweak_mul, ec_pubkey_combine and friends return zero hits — so the Lagrange-coefficient math FROST needs requires a C-side addition, and upstream bitcoin-core/secp256k1 has no FROST module to enable. BIP-445 (number assigned 2026-01-30) is the standard to implement and states outright that its Tweak Context is identical to BIP-327's KeyAgg Context so existing code can be reused; it excludes key generation, deferring to ChillDKG, and defines no PSBT fields. So signing is close and DKG is the unsolved piece — which is exactly what Coldcard's air-gapped architecture is least able to host. Interop with actual Frostsnap devices is separately blocked: the wire protocol is frostsnap_comms rather than PSBT, and the security model requires factory-provisioned genuine devices."
---

# Threshold signing paths on Coldcard

The firmware-port question and the threshold-signing question are usually conflated. They have very
different answers. Porting Frostsnap onto a Mk4 is blocked
([see the thesis](../theses/frostsnap-firmware-on-coldcard-mk4.md)); getting threshold Schnorr signing
onto a Mk4 is **already done**, and getting *FROST* onto one is a bounded software project.

## What already ships

`docs/musig.md` (new_edge), verbatim: **"COLDCARD® `EDGE` versions support MuSig2 from version `6.5.0X`
& `6.5.0QX`"** — `X` = Mk4, `QX` = Q. Implements **BIP-373** (PSBT fields), **BIP-390** (`musig()`
descriptor key expression), **BIP-328** (aggregate-key derivation). Mk4 line at `6.5.0X - 2026-03-24`,
under a changelog heading "Shared Improvements - Both Mk4 and Q."

Vendor caveat: EDGE "has not yet been qualified and tested to the same standard as normal Coinkite
products… DO NOT use for large Bitcoin amounts."

### It already solves the hard part

The stateful interactive ceremony that looks like the blocker for threshold signing on an air-gapped
device is implemented and documented:

> "COLDCARD must stay powered up between 1st and 2nd round as necessary musig session data are stored in
> volatile memory only"

> "COLDCARD strictly differentiate between 1st & 2nd MuSig2 round. If COLDCARD provides nonce, it will
> not attempt to sign even if it could... To provide both nonce(s) & signature(s) signing needs to be
> preformed twice."

`shared/psbt.py` holds a module-level `MUSIG_SESSION_CACHE = {}` keyed by `session_digest`, with round
detection by `MUSIG_SESSION_CACHE.pop(session_digest, None)` — absent means round 1. **Multi-round
multi-signer signing over PSBT message passing already works on Mk4.**

### There is even a documented t-of-n workaround

> "Following policy is example how to do threshold multisig with MuSig2 (and Taptree) even thought
> MuSig2 is not a native threshold scheme"

```
tr(musig(@0,@1,@2),{{pk(musig(@0,@1)),pk(musig(@1,@2))},pk(musig(@0,@2))})
```

n-of-n aggregation composed into t-of-n by enumerating combinations in a taptree. Less elegant than
FROST — the taptree grows combinatorially, there is no DKG and no share rotation — but **available on
Mk4 today**. Constraints: one own key per `musig()`, xpubs only, sorted before aggregation, no hardened
derivation.

## The gap to true FROST

**Crypto layer.** `switck/libngu` (submodule `external/libngu`) wraps upstream
`bitcoin-core/secp256k1`, and `ngu.secp256k1` already exposes a complete MuSig2 API to MicroPython:
`MusigKeyAggCache`, `musig_pubkey_agg`, `musig_nonce_gen`, `MusigPubNonce`, `musig_nonce_agg`,
`MusigAggNonce`, `musig_nonce_process`, `musig_partial_sign`, `MusigPartSig`, `musig_partial_sig_agg`,
`musig_pubkey_{ec,xonly}_tweak_add`, plus `sign_schnorr`/`verify_schnorr`. Gated by `NGU_INCL_MUSIG ?= 0`
→ `ENABLE_MODULE_MUSIG`. **MuSig2 being EDGE-only is a compile flag, not an architecture limit.**

But: grepping `k1.c` for `seckey_tweak_add`, `seckey_tweak_mul`, `seckey_negate`, `ec_pubkey_combine`,
`ec_pubkey_tweak_mul` returns **zero hits**. FROST needs Lagrange-coefficient scalar multiply and point
addition for share handling. **A pure-MicroPython FROST is impossible on today's `ngu`** — a C-side
addition is required. And unlike MuSig2 there is no flag to flip: upstream `bitcoin-core/secp256k1` has
**no FROST module**. Out-of-tree options are `FrostDevKit/secp256k1-frost` (Bank of Italy `itcoin`
origin, RFC 9591) or Zcash Foundation's Rust `frost-secp256k1-tr`.

**Protocol layer.** BIP-445 (BIP-FROST-Signing, author Sivaram Dhakshinamoorthy, **number assigned
2026-01-30**, Draft) is the standard to implement, and it hands Coldcard a gift, verbatim:

> "Tip: The Tweak Context is identical to the _KeyAgg Context_ defined in BIP327. Implementations with
> existing BIP327 code can reuse it."

Coldcard *has* BIP-327 code. The structure matches too — two communication rounds, `secnonce` persisted
between them and never reused ("must **not** be executed twice with the same _secnonce_"; erase "by
overwriting it with 64 zero bytes"). Coldcard's RAM-only session cache with strict round separation is
already this design.

**Two scope gaps in the standard itself:** BIP-445 **excludes key generation**, deferring to
**ChillDKG** or RFC 9591/9792 Appendix C; and it defines **no PSBT fields**, so a BIP-373 analogue must
be written.

## The cheapest true-FROST path

1. Add a FROST module to `libngu` — a new build flag beside `NGU_INCL_MUSIG`, sourced from
   `secp256k1-frost` or built on newly exposed scalar ops.
2. Implement BIP-445 in `shared/psbt.py`, reusing the KeyAgg/Tweak context and the existing round
   machinery.
3. Define FROST PSBT fields (no standard exists).
4. Route it through Coinkite's review — "Develop against the Simulator / Submit a PR" is the only path
   that ends in factory-signed firmware without a permanent boot warning.

Weeks-to-months for someone already inside the codebase — a different order of magnitude from a firmware
port. **The unsolved piece is DKG, not signing**, and a distributed key-generation ceremony is precisely
what an air-gapped single-device architecture is least able to host.

## Constraints on this path

- **RAM bites.** Open PR #683 (third-party, 32 files, +13,031 lines, adding MuSig2 + Silent Payments with
  invented provisional PSBT fields) has two tests failing with **"Coldcard Error: buffer too small"** —
  a real datapoint on Mk4 memory pressure under multi-round multi-signer flows.
- **No vendor demand signal.** GitHub issue search on `Coldcard/firmware`: **`FROST` → 0 results**,
  `BIP-327` → 0, `musig` → 4, `taproot` → 10. No Coinkite blog post on MuSig2/FROST/threshold exists.
- **Mk4 is not deprecated for advanced features** — EDGE ships full Miniscript/MiniTapscript on Mk4 too,
  and 6.4.0X migrated all multisig wallets to internal Miniscript. Feature parity with Q is the norm.

## Display is not the binding constraint

Confirmed from source: **Q** (`shared/lcd_display.py`) is 320×240 colour, `CHARS_W = 34`, `CHARS_H = 10`,
QWERTY + QR scanner; **Mk4** (`shared/display.py`) is 128×64 `SSD1306_SPI` mono with a keypad.

Yet MuSig2 shipped on **both simultaneously**, because the transport is PSBT files/USB rather than an
on-screen device-to-device ceremony. A Q would help a *Frostsnap-style* UI (device enumeration, QR
coordinator handshake, DKG progress across N devices) — but that UI is only needed if you replicate
Frostsnap's interaction model. **The binding constraints are RAM and the missing DKG story.**

## Interop with real Frostsnap devices is separately blocked

Frostsnap's stated intent is interoperability. Adam Mashrique (hardware lead), quoted in Protos:

> "We want to set an open standard other vendors can implement. Our goal is for different makes of
> devices to be part of a FROST multisig wallet."

> "Our code on github is FOSS, so anyone is free to make and sell Frostsnap-compatible signing devices."

But today the wire protocol is **`frostsnap_comms`, not PSBT**, and the security architecture requires
genuine Frostsnap devices — factory-fused per-device secrets plus authenticity certificates, with the
key share encrypted under both the chip secret and a coordinator-derived key. A Coldcard cannot satisfy
that provisioning model. **The open standard Mashrique describes does not yet exist as a spec** — BIP-445
plus a PSBT binding plus ChillDKG is roughly what it would have to become.

## See Also

- [Porting Frostsnap to other hardware](porting-frostsnap-to-other-hardware.md)
- [Thesis: Frostsnap firmware on Coldcard Mk4](../theses/frostsnap-firmware-on-coldcard-mk4.md)
- [Root-of-trust portability](../concepts/root-of-trust-portability.md)
- coldcard wiki: [Airgap signing workflows](../../../coldcard/wiki/topics/airgap-signing-workflows.md)
- coldcard wiki: [Signing formats](../../../coldcard/wiki/references/signing-formats.md)
- hub topic `musig2-signing-ceremonies`
