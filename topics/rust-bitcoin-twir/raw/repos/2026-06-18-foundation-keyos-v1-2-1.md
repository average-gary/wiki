---
title: "Foundation Devices KeyOS v1.2.1 (Rust hardware wallet OS)"
source: https://github.com/Foundation-Devices/keyos/releases
type: release
tags: [foundation-devices, keyos, xous, slint, ngwallet, embedded, hardware-wallet]
ingested: 2026-06-22
date: 2026-06-18
verified: 2026-06-22
volatility: hot
credibility: high
twir-fit: yes-strong
twir-section: Project/Tooling Updates
agent: adjacent
---

# Foundation Devices KeyOS v1.2.1

Rust-heavy operating system powering Passport Prime hardware wallet. Released 2026-06-18 (4 days before today).

## Composition
- ~46.7% Rust, 34.4% C, 6.1% Slint UI markup.
- Built on **Xous kernel** (also Rust).
- `gui-app-bitcoin` Bitcoin app, persistent Rust services (filesystem, GUI server, camera), message-passing IPC.

## Companion repo: ngwallet
- "Foundation's next-gen wallet based on BDK."
- 99.9% Rust, 488 commits, 51 releases, latest v3.6.1 (2026-06-16).

## Note on the older Passport repo
- `Foundation-Devices/passport` (firmware in C/MicroPython, last release 2022) is **not** the Rust story.
- The new Rust story is **KeyOS + ngwallet on Passport Prime**.

## TWiR fit
- **Section**: Project/Tooling Updates — embedded-Rust-on-Bitcoin-hardware story is novel, freshly released, and rich enough to wrap in a deep-dive.
- Could also feed a "Rust Walkthroughs" piece if anyone writes about the architecture.
- Slint + Xous + Rust on a shipping signing device is a notable embedded Rust milestone.
- v1.2.0 was March 2026 ("Initial Public Release"); v1.2.1 last week.
