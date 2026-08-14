---
title: "Frostsnap README (project overview)"
source: "https://github.com/frostsnap/frostsnap/blob/c319850a77cf077febbd9bccd9dffdf7b666b009/README.md"
type: articles
ingested: 2026-08-10
tags: [frostsnap, frost, threshold-signatures, taproot, schnorr, bitcoin-self-custody, daisy-chain, secp256kfun, distributed-multisig]
summary: "Top-level project overview for Frostsnap: a distributed multisignature Bitcoin self-custody system where devices in several physical locations hold FROST key shares and a user-chosen quorum (e.g. 2-of-3) must sign. Devices daisy-chain for setup and are explicitly not trusted to generate keys alone — the user's phone or laptop verifiably contributes entropy during keygen. Taproot's Schnorr threshold signatures give a single on-chain public key with single-sig fees and hidden multisig. Lists the four main components and the secp256kfun FROST implementation."
collection: "frostsnap"
adapter: git
upstream_id: "README.md"
upstream_type: git-file
revision: "c319850a77cf077febbd9bccd9dffdf7b666b009"
sha: "66ff7b5fad6015bb5f8c076614f5ac851fa96584"
canonical_url: "https://github.com/frostsnap/frostsnap/blob/c319850a77cf077febbd9bccd9dffdf7b666b009/README.md"
content_format: markdown
license: "MIT"
authors: [musdom, LLFOURN, nickfarrow, evanlinjin]
fetched: 2026-08-10
---

# Frostsnap

<img alt="Frostsnap daisy chain" src="https://frostsnap.com/frostypede_landscape.png" width=360>

[<img alt="Frostsnap" src="https://frostsnap.com/assets/frostsnap-logo.svg" width=360>](https://frostsnap.com)

_Frostsnap is the ultimate bitcoin self-custody system using the latest advancements in cryptography on distributed multisignature devices._

Having your keys in a single location makes you an inviting target to criminals. Sophisticated physical and digital thefts against bitcoin owners are becoming more prevalent.

Frostsnap devices distribute security across multiple locations using advanced multisignature. With a 2-of-3 setup, any two devices must sign to access your bitcoin. You can choose your number of devices and quorum.

Frostsnap devices can seamlessly connect together in a daisy-chain, providing an easy way to create or upgrade a Bitcoin wallet protected behind multiple devices.

Frostsnap devices are not trusted to generate keys on their own. Your phone or laptop participates in sensitive operations, including verifiably contributing entropy during key generation.

Bitcoin's Taproot upgrade has enabled elegant and secure Schnorr threshold signatures; a single public key that pays the same fees as single signature wallets, has hidden multisig for privacy, and straightforward recovery requirements.

## Code

Frostsnap uses our [FROST](https://eprint.iacr.org/2020/852.pdf) implementation from [secp256kfun](https://docs.rs/schnorr_fun/latest/schnorr_fun/frost/index.html).

This repository contains:

- **[device/](https://github.com/frostsnap/frostsnap/tree/c319850a77cf077febbd9bccd9dffdf7b666b009/device)** - ESP32 Rust firmware for frostsnap devices
- **[frostsnap_core/](https://github.com/frostsnap/frostsnap/tree/c319850a77cf077febbd9bccd9dffdf7b666b009/frostsnap_core)** - Core Rust library for coordinator and signer state management
- **[frostsnap_comms/](https://github.com/frostsnap/frostsnap/tree/c319850a77cf077febbd9bccd9dffdf7b666b009/frostsnap_comms)** - Communication protocol and message serialization
- **[frostsnapp/](https://github.com/frostsnap/frostsnap/tree/c319850a77cf077febbd9bccd9dffdf7b666b009/frostsnapp)** - Cross-platform Flutter wallet application and FROST coordinator

All code is free and open source under the MIT license.

## Security & Disclaimer

Rather than worrying about access to a single hardware wallet or physical seed, Frostsnap distributes security across multiple devices which should be stored in several different locations.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND. See [LICENSE](https://github.com/frostsnap/frostsnap/blob/c319850a77cf077febbd9bccd9dffdf7b666b009/LICENSE) for more info.

## Contributors

We welcome contributions or issues related to this software.

This software was originally built by @musdom, @LLFOURN, @nickfarrow, and @evanlinjin as part of the Frostsnap team.

Find us at [frostsnap.com](https://frostsnap.com) or [@FrostsnapTech](https://x.com/FrostsnapTech).

---

Stay Frosty.

---

## Ingest note

The five repository-relative links in the body above (`device/`, `frostsnap_core/`,
`frostsnap_comms/`, `frostsnapp/`, `LICENSE`) were repointed to absolute
GitHub URLs pinned to `c319850`. Link text and all prose are unchanged; only the
destinations were rewritten, since repo-relative paths do not resolve inside the
wiki.
