# frostsnap

> Frostsnap — FROST threshold-Schnorr Bitcoin self-custody on distributed ESP32-C3 devices. Device/coordinator architecture, key derivation and coordinator authentication, the 25-word share backup scheme, secure-boot provisioning, and the project's stated threat model.

Last updated: 2026-08-10

## Statistics

- Sources: 21 raw documents (1 collection manifest + 11 children + 9 thesis-directed)
- Articles: 9 compiled wiki articles (3 concepts, 2 topics, 3 references, 1 thesis)
- Outputs: 0 generated artifacts
- Last compiled: 2026-08-10
- Last lint: 2026-08-10

## Quick Navigation

- [All Sources](raw/_index.md)
- [Concepts](wiki/concepts/_index.md)
- [Topics](wiki/topics/_index.md)
- [References](wiki/references/_index.md)
- [Theses](wiki/theses/_index.md)
- [Outputs](output/_index.md)
- [Configuration](config.md)
- [Activity Log](log.md)

## Scope

See [config.md](config.md) for full scope. In brief: the Frostsnap system —
FROST threshold signatures across daisy-chainable ESP32-C3 hardware devices with
a Flutter coordinator app, a `t`-of-`n` quorum, and a single Taproot public key
on-chain.

## Source Highlights

The substance of this ingest sits in four documents:

- **[Security Policy](raw/articles/2026-08-10-frostsnap-security-policy.md)** — the three-clause security
  model stated precisely, plus an unusually candid carve-out: corrupt devices can always refuse to sign or
  lie about backup words, so ransom is a known limitation rather than a bug.
- **[Key Derivation Design](raw/articles/2026-08-10-frostsnap-key-derivation-design.md)** — why coordinator
  authentication uses the reconstructed root polynomial image rather than a coordinator-generated key, and
  the XPUB-privacy argument for requiring `t` share images before a signing session can open.
- **[FROST Backup Scheme](raw/articles/2026-08-10-frostsnap-frost-backup-scheme.md)** — the 25-word format
  bit layout and the 8-bit polynomial checksum that defends against public-key substitution after restore.
- **[Device Provisioning](raw/articles/2026-08-10-frostsnap-device-provisioning.md)** — ESP32 Secure Boot v2
  key binding: key-agnostic binaries, public key in the signature block, hash burned to eFuse on first boot.

## Compiled Highlights

- **[Thesis: Frostsnap firmware on Coldcard Mk4](wiki/theses/frostsnap-firmware-on-coldcard-mk4.md)** —
  verdict **Contradicted** for the literal claim, Partially Supported for the narrow steelman. The
  research also refuted two popular anti-port arguments (flash size, missing HMAC peripheral).
- **[Porting Frostsnap to other hardware](wiki/topics/porting-frostsnap-to-other-hardware.md)** — four
  difficulty tiers, from ~200 LOC for a new board to no-successful-precedent for a locked device.
- **[Threshold signing paths on Coldcard](wiki/topics/threshold-signing-paths-on-coldcard.md)** — Coldcard
  already ships MuSig2 on Mk4; the remaining gap to FROST is `libngu` scalar ops, BIP-445 PSBT fields,
  and DKG.
- **[Root-of-trust portability](wiki/concepts/root-of-trust-portability.md)** — why key custody, not the
  HAL, is the least portable layer of a signing firmware.

## Open Questions

Not answered by the ingested docs; would need source reading or upstream research:

- What exactly travels over QR in the coordinator app (shares, PSBTs, addresses, device certificates)?
- How does the daisy-chain wire protocol work at the `frostsnap_comms` level, and what are its framing and
  replay properties?
- What does "verifiably contributing entropy" from the phone/laptop concretely mean in the keygen protocol?
- How does fingerprint grinding embed the checksum in polynomial coefficients, and what is its cost?
- How does Frostsnap's FROST usage compare to RFC 9591 and to ROAST-style robustness?
- Do `secp256kfun`/`schnorr_fun` actually build and pass tests on `thumbv7em-none-eabihf`? No
  `thumbv*-none-*` CI coverage exists anywhere.
- Will PR #513 (`DeviceHal`) merge, and does anyone implement it on a non-Espressif HAL?
- Does BIP-445 + ChillDKG become the "open standard other vendors can implement" that Frostsnap says it
  wants, and would a PSBT binding preserve its device-authenticity model?

## Recent Changes

- 2026-08-10: Thesis research (`--mode thesis --deep`, 8 agents) on Frostsnap-firmware-on-Coldcard-Mk4 — 9 raw sources ingested, first 9 compiled articles created, verdict rendered.
- 2026-08-10: Topic wiki created. Collection ingest of the frostsnap GitHub org — 12 raw sources.
