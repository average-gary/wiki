---
title: "frostsnap_cst816s: no_std CST816S Touchpad Driver"
source: "https://github.com/frostsnap/frostsnap/blob/c319850a77cf077febbd9bccd9dffdf7b666b009/cst816s/README.md"
type: articles
ingested: 2026-08-10
tags: [frostsnap, cst816s, touchscreen-driver, no-std, esp32c3, hardware-interrupts, embedded-hal, bsd-3-clause]
summary: "A no_std Rust driver for the Hynitron CST816S capacitive touchpad used in the Frostsnap hardware signing device. Supports blocking reads of touch events, slide and long-press gestures, ESP32-C3 hardware interrupt handling, and an event queue for buffering. Derived from Todd Stellanova's cst816s crate and Felix Weidinger's fork; licensed BSD-3-Clause rather than the monorepo's MIT."
collection: "frostsnap"
adapter: git
upstream_id: "cst816s/README.md"
upstream_type: git-file
revision: "c319850a77cf077febbd9bccd9dffdf7b666b009"
sha: "a7ca6e3d479d9f7f83b64cb6828957e760c49811"
canonical_url: "https://github.com/frostsnap/frostsnap/blob/c319850a77cf077febbd9bccd9dffdf7b666b009/cst816s/README.md"
content_format: markdown
license: "BSD-3-Clause"
authors: [Todd Stellanova, Felix Weidinger]
fetched: 2026-08-10
---

# frostsnap_cst816s

A no_std driver for the Hynan / Hynitron CST816S touchpad device with ESP32 interrupt support, used in the Frostsnap hardware signing device.

This driver is based on the original [cst816s](https://github.com/tstellanova/cst816s) crate by Todd Stellanova and [Felix Weidinger's fork](https://github.com/fxweidinger/cst816s).

## Features
- Blocking mode read of available touch events
- Reading slides and long press gestures  
- Hardware interrupt support for ESP32C3
- Event queue for buffering touch events

## Original Work

This crate is derived from:
- Original implementation: https://github.com/tstellanova/cst816s by Todd Stellanova
- Fork with improvements: https://github.com/fxweidinger/cst816s by Felix Weidinger

## Resources
- [Datasheet](https://github.com/tstellanova/cst816s/blob/main/CST816S_V1.1.en.pdf)
- [Reference Driver](https://github.com/tstellanova/hynitron_i2c_cst0xxse) in C, from Hynitron

## License

BSD-3-Clause, see `LICENSE` file.

---

## Ingest note

Hardware-relevant detail: the presence of a capacitive touch controller and the
`frostsnap_widgets` crate confirm the device has a touchscreen UI, which matters
for the security model's requirement in `SECURITY.md` that the user "verify what
you are approving on the device's own screen." This crate requires riscv32 and is
therefore excluded from the workspace's `default-members`.
