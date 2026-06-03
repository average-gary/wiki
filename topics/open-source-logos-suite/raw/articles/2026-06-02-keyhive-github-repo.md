---
title: "inkandswitch/keyhive — Rust workspace for Keyhive and related crates"
url: https://github.com/inkandswitch/keyhive
retrieved: 2026-06-02
type: repo
---

GitHub repo for Ink & Switch's Keyhive project. Apache-2.0 licensed; created 2024-08-13; last push 2026-05-28; 208 stars, 14 forks. README explicitly labels it pre-alpha and warns "DO NOT use this release in production applications" with no completed security audit. Workspace contains three top-level crates: `keyhive_core` (signing, encryption, delegation), `keyhive_wasm` (TypeScript bindings via wasm-bindgen), and `beelay-core` ("auth-enabled sync over end-to-end encrypted data"). The `keyhive_core/src/` tree shows modules for `crypto`, `principal`, `event`, `listener`, `store`, `transact`, plus standalone `cgka.rs` (Continuous Group Key Agreement / BeeKEM), `ability.rs`, `access.rs`, and `contact_card.rs`. Active development with 178+ commits as of mid-2026; questions are routed to the `keyhive-beelay` channel of the Automerge Discord.
