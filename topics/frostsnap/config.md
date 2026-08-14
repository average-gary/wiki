---
title: "frostsnap"
description: "Frostsnap — FROST threshold-Schnorr Bitcoin self-custody on distributed ESP32-C3 devices. Device/coordinator architecture, key derivation and coordinator authentication, the 25-word share backup scheme, secure-boot provisioning, and the project's stated threat model."
created: 2026-08-10
freshness_threshold: 70
---

# Wiki Configuration

## Scope

Research on [Frostsnap](https://frostsnap.com) ([github.com/frostsnap](https://github.com/frostsnap)) — a
distributed multisignature Bitcoin self-custody system using FROST threshold Schnorr signatures across
daisy-chainable ESP32-C3 hardware devices with a Flutter coordinator app. Covers:

- **System architecture**: the coordinator/signer split, `frostsnap_core` state management,
  `frostsnap_comms` protocol and message serialization, the Flutter + `flutter_rust_bridge` app, and the
  daisy-chain device topology.
- **Key generation and derivation**: devices explicitly not trusted to generate keys alone, verifiable
  entropy contribution from the user's phone/laptop, the `rootkey`/`appkey` derivation tree, and why devices
  delete `rootkey` and store no public keys.
- **Coordinator authentication**: share images presented on connect, reconstructing the root polynomial
  image from `t` shares as a universal credential, share encryption derived from it, and the XPUB-privacy
  rationale for not letting any coordinator open a signing session.
- **Backup and recovery**: the `frost_backup` 25-BIP39-word share format (256-bit scalar + 8-bit polynomial
  checksum + 11-bit words checksum), fingerprint grinding for share discovery, public-key-substitution
  defense, and the `frostsnap-thaw` emergency xpriv/descriptor recovery path.
- **Device security**: ESP32 Secure Boot v2 key binding and eFuse burning, factory provisioning of DS keys
  and genuine-device certificates, dev-vs-prod JTAG posture, deterministic/Nix firmware builds, and
  on-device verification of what is being approved.
- **Threat model**: the project's three-clause security model (remote attacker vs. corrupt devices;
  physical attacker below threshold; corrupt coordinator app), the malicious-backup/ransom carve-out, and
  the 1,000,000-sat bounty framing.

Out of scope for this topic (covered elsewhere or only as comparison):

- MuSig2 as an interactive signing ceremony → see hub topic `musig2-signing-ceremonies`. FROST is compared
  against it (t-of-n vs n-of-n, robustness, round structure) but MuSig2 protocol detail belongs there.
- Federated Chaumian e-cash and guardian consensus → see hub topic `fedimint`.
- General Rust-Bitcoin ecosystem survey → see hub topic `rust-bitcoin-twir`.
- Upstream Espressif projects (`esp-hal`, `esp-pacs`, `esp-idf`) beyond how Frostsnap depends on them.

## Conventions

- **Distinguish first-party claims from verified properties.** Nearly all sources here are Frostsnap's own
  repository documentation. It is authoritative for *design intent and stated guarantees*, not independent
  evidence that the guarantees hold. Tag security claims accordingly and prefer `confidence: medium` for
  anything resting only on project self-description.
- Prefer primary sources: repository code and docs pinned to a commit, the FROST paper
  ([eprint 2020/852](https://eprint.iacr.org/2020/852.pdf)), RFC 9591, `secp256kfun`/`schnorr_fun` docs, and
  BIP-32/39/389 over secondary explainers or marketing copy.
- **Pin provenance to commits.** Raw sources carry `revision` (HEAD SHA) and `sha` (blob SHA). Because this
  is pre-1.0 software under active development, always cite the revision when stating how something works;
  re-ingest new revisions as new raw sources rather than editing existing ones.
- Treat the whole system as pre-1.0: all crates are `0.1.0` and the repo ships an "AS IS" disclaimer.
