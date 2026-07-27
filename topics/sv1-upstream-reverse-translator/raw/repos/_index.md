---
title: Repos
type: index
updated: 2026-07-27
---

# Repos

## Existence proof — the reverse translator, built (2026-07-27)

- [[2026-07-27-blitzpool-rental-proxy-sv2-to-sv1-translator|warioishere/blitzpool-rental-proxy — working bidirectional SV1↔SV2 translator]] — **contradicts the 2026-05-28 "greenfield from a code perspective" conclusion.** Compiled into [[../../wiki/concepts/prior-art-blitzpool-rental-proxy|prior-art-blitzpool-rental-proxy]]. Deployed Rust proxy (v0.3.1, beta) that hand-authors the SV2-miner→SV1-pool direction in `src/proto/translate.rs` because `stratum_translation` ships only the SV1→SV2 leg. All four protocol combinations work. Also realizes the hypothesized hashrate-broker segment and solves upstream-switching (forced reconnect for operator changes, in-place `SetExtranoncePrefix`/`SetTarget` for failover).

## Path 1 — primitive mapping

- [[2026-05-28-path1-sri-stratum-translation-crate]]

## Path 2 — prior art

- [[2026-05-28-path2-sri-translator-role]]
- [[2026-05-28-path2-vnprc-hashpool]]
- [[2026-05-28-path2-braiins-farm-proxy]]
- [[2026-05-28-path2-p2poolv2]]
- [[2026-05-28-path2-stratum-bridge-altcoin-pattern]]

## Path 3 — feature loss

- [[2026-05-28-path3-sri-stratum-mining-stratum]]

## Path 4 — architectural design

- [[2026-05-28-path4-stratum-translation-crate]]
- [[2026-05-28-path4-channels-sv2-reuse]]
- [[2026-05-28-path4-handlers-sv2-bidirectional]]
- [[2026-05-28-path4-extranonce-allocator-translator-pattern]]
- [[2026-05-28-path4-sv1-api-isclient-trait]]
- [[2026-05-28-path4-workspace-layout-and-integration-tests]]
