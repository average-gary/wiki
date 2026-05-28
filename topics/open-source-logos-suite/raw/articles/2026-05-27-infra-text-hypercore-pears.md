---
title: "Pears / Hypercore / Hyperdrive — Append-Only P2P Stack"
source_url: "https://docs.pears.com/"
type: article
path: infra-text
date_ingested: 2026-05-27
date_published: unknown
tags: [decentralized, hypercore, holepunch, content-distribution]
quality: 3
confidence: medium
summary: "Holepunch's Pear runtime + Hypercore append-only signed log + Hyperdrive distributed filesystem. Production deployments exist (Keet, PearPass) but the JS-only runtime and tight ecosystem coupling make it a heavy bet for a single-purpose Bible-text channel."
---

# Pears / Hypercore / Hyperdrive — Append-Only P2P Stack

## Key findings

- **Hypercore** is a "distributed, secure append-only log" — every entry is cryptographically signed by the writer's keypair and the log root is a Merkle tree. Readers verify against the public key. This is closer to a versioned blob channel than a flat content-addressed blob store: each Hypercore is owned by exactly one writer.
- **Hyperdrive** layers a POSIX-ish filesystem on top of Hypercore, which is the natural primitive for a "publish a versioned Bible package" use case. Updating the ESV with a typo fix appends a new version without breaking the public key.
- **Pear / Bare**: Holepunch's bet is that you ship a JS runtime (Bare) instead of Electron and run P2P apps directly on the user's device. The runtime is desktop+mobile capable.
- **Production deployments**: Keet (E2EE chat/calls) and PearPass (password manager). Both are first-party. Third-party Pear apps are rare. This is in line with the previous Beaker/Dat ecosystem dying off in 2020 and being relaunched as Holepunch in 2023.
- **Hyperswarm DHT** for peer discovery is mature but JS-bound. There is no first-class Rust or Go client at parity, which matters if your Bible reader is a Tauri app or mobile native.

## Notable quotes / specifics

- Hypercore: "a distributed, secure append-only log for creating fast, scalable P2P applications".
- Hyperdrive: "a secure, real-time, efficient distributed P2P file-system".
- Most modules are marked stable, not experimental — a fair improvement over the Dat era.

## Source notes

Hypercore's append-only model is genuinely well-suited to "one publisher, occasional updates, many read-only consumers" — exactly the Bible-text shape. The blocker is ecosystem lock-in: you commit to JS/Bare for the consumer, and the network is small enough that you'd be running your own seeders anyway. Iroh-blobs gives you ~80% of the benefit (content-addressed verified streaming, multi-language SDKs, larger network effects via dumbpipe/sendme) without forcing the runtime choice. Pears is a serious option only if the Logos suite is itself a Pear app.
