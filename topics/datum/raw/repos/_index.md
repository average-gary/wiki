---
title: Repos
type: index
updated: 2026-06-01
---

# Repos (11)

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [2026-05-28-datum-gateway-repo.md](2026-05-28-datum-gateway-repo.md) | Collection manifest for `OCEAN-xyz/datum_gateway` @ `a3da9e69` (HEAD); 2 child articles captured. | collection-manifest, git, datum, ocean | 2026-05-28 |
| [2026-06-01-path1-datum-protocol-h.md](2026-06-01-path1-datum-protocol-h.md) | `src/datum_protocol.h` — 32-bit packed header, 5-bit opcode, 3 encryption flags, 8-job ring, 4 MB cmd ceiling. | datum-protocol, c-source, wire-format | 2026-06-01 |
| [2026-06-01-path1-datum-protocol-c.md](2026-06-01-path1-datum-protocol-c.md) | `src/datum_protocol.c` — libsodium handshake (Ed25519 + X25519 + crypto_box), header-obfuscation chain seeded by `0xb10cfeed` (PR #202 hardens). | datum-protocol, c-source, libsodium, encryption | 2026-06-01 |
| [2026-06-01-path1-datum-coinbaser-c.md](2026-06-01-path1-datum-coinbaser-c.md) | `src/datum_coinbaser.c` — V2 coinbaser blob parser; max 512 outputs; literal `memcpy` "in order provided"; 16-bit unique-identifier in scriptSig. | datum, coinbase, c-source | 2026-06-01 |
| [2026-06-01-path1-datum-blocktemplates-c.md](2026-06-01-path1-datum-blocktemplates-c.md) | `src/datum_blocktemplates.c` — GBT pull (`getblocktemplate`), `["segwit"]` rules, `sizelimit`/`weightlimit` parsed but not enforced (Knots-vs-Core is editorial). | datum, gbt, blocktemplates, c-source | 2026-06-01 |
| [2026-06-01-path1-datum-sockets-c.md](2026-06-01-path1-datum-sockets-c.md) | `src/datum_sockets.c` — hand-rolled `epoll_wait(timeout=7ms)` + pthread; max_threads=8, max_clients_per_thread=128. | datum, c-source, networking, epoll | 2026-06-01 |
| [2026-06-01-path3-sri-extended-channel-server.md](2026-06-01-path3-sri-extended-channel-server.md) | `channels_sv2::server::extended::ExtendedChannel` — state machine, `new_for_pool` constructor, `validate_share` path. Reusable as-is. | sri, channels-sv2, sv2-proxy | 2026-06-01 |
| [2026-06-01-path3-sri-jobstore-jobfactory.md](2026-06-01-path3-sri-jobstore-jobfactory.md) | `JobStore` trait + `DefaultJobStore`; `JobFactory::new_extended_job` is the GBT→`NewExtendedMiningJob` bridge with OCEAN-output injection slot. | sri, jobstore, jobfactory, sv2-proxy | 2026-06-01 |
| [2026-06-01-path3-sri-extranonce-allocator.md](2026-06-01-path3-sri-extranonce-allocator.md) | SV2 hierarchical extranonce vs DATUM 12-byte flat; bridge recipe (`total_extranonce_len = 12`). | sri, extranonce, sv2-proxy, datum | 2026-06-01 |
| [2026-06-01-path3-sri-handlers-async-trait.md](2026-06-01-path3-sri-handlers-async-trait.md) | `HandleMiningMessagesFromClientAsync` — the trait the proxy implements; 7 leaf handlers. | sri, handlers-sv2, async, sv2-proxy | 2026-06-01 |
| [2026-06-01-path3-stratum-translation-and-codec.md](2026-06-01-path3-stratum-translation-and-codec.md) | Wire pipeline crates (codec/noise/framing/parsers); `stratum-translation` only relevant if also serving SV1. | sri, codec-sv2, noise-sv2, framing-sv2 | 2026-06-01 |

## Categories

- **collection-manifest**: 2026-05-28-datum-gateway-repo.md
- **datum gateway C source (Path 1)**: 2026-06-01-path1-datum-protocol-h.md, 2026-06-01-path1-datum-protocol-c.md, 2026-06-01-path1-datum-coinbaser-c.md, 2026-06-01-path1-datum-blocktemplates-c.md, 2026-06-01-path1-datum-sockets-c.md
- **SRI codebase reads (Path 3)**: 2026-06-01-path3-sri-extended-channel-server.md, 2026-06-01-path3-sri-jobstore-jobfactory.md, 2026-06-01-path3-sri-extranonce-allocator.md, 2026-06-01-path3-sri-handlers-async-trait.md, 2026-06-01-path3-stratum-translation-and-codec.md
