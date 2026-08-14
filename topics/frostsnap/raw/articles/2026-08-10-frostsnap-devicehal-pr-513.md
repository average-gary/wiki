---
title: "Frostsnap PR #513 — Lift the device runtime into frostsnap_embedded behind DeviceHal"
source: "https://github.com/frostsnap/frostsnap/pull/513"
type: articles
ingested: 2026-08-10
tags: [frostsnap, hardware-abstraction, devicehal, frostsnap-embedded, porting, embedded-rust, no-std]
summary: "Open (not merged) pull request on branch `frostsnap-embedded-lift`, head 102efb5cb10b, that moves `DeviceLoop` and the device-side runtime out of the esp32-specific path into a new `frostsnap_embedded` crate behind a `DeviceHal` trait. PR body states the goal as 'so the same firmware logic can run on real hardware or a virtual/software HAL'. The module doc in `frostsnap_embedded/src/device_hal.rs` (143 lines) states that `device/` implements `DeviceHal`/`FirmwareServices` over esp-hal while a host/sim build implements them with in-memory peripherals, and that 'the portable run-loop only ever sees these traits - never `esp_hal`'. The trait carries six associated types: Storage (NorFlash + ReadNorFlash), Upstream and Downstream (SerialPort), Rng (RngCore + CryptoRng), Secrets (DeviceSecretDerivation), Firmware (FirmwareServices), plus companion traits Clock and TouchSource with a TouchGesture enum documented as a 'portable mirror of the CST816S gesture set the UI cares about'. Diffstat: device/src/esp32_run.rs -766 lines, ui.rs -159, touch_handler.rs -67 (deleted); new portable frostsnap_embedded/src/device_loop.rs +1196, framed_serial.rs +218, ui.rs +158; ESP-specific remnant shrinks to esp_ui.rs (+85) and firmware.rs (+149). A separate `FirmwareServices` trait isolates OTA and attestation as 'Device-only firmware/attestation services... Kept out of the portable core - exactly what the sim drops'."
thesis: frostsnap-firmware-on-coldcard-mk4
relevance: direct
evidence_strength: primary-source-code
direction: supports
credibility: high
confidence: high
authors: [frostsnap contributors]
fetched: 2026-08-10
---

# Frostsnap PR #513 — `DeviceHal` trait lift

## Why this matters to the port thesis

This is the single strongest piece of pro-thesis evidence found. The Frostsnap maintainers are
independently building the exact hardware-abstraction seam that any port to a different MCU would
need to implement. A porter would not have to invent the abstraction — only supply implementations
of six associated types.

## The trait surface

```rust
// frostsnap_embedded/src/device_hal.rs (143 lines)
type Storage:    NorFlash + ReadNorFlash   // embedded-storage traits
type Upstream:   SerialPort
type Downstream: SerialPort
type Rng:        RngCore + CryptoRng
type Secrets:    DeviceSecretDerivation
type Firmware:   FirmwareServices
```

Companion traits: `Clock { fn now_ms(&self) -> u64; }` — documented as "esp: wraps a TIMG timer;
host: a fake/atomic counter" — and `TouchSource`, whose `TouchGesture` enum is described as a
"portable mirror of the CST816S gesture set the UI cares about." The panel driver is therefore
already being abstracted behind a portable event type.

## Scale of the lift

| File | Delta |
|------|-------|
| `device/src/esp32_run.rs` | −766 |
| `device/src/ui.rs` | −159 |
| `device/src/touch_handler.rs` | −67 (deleted) |
| `frostsnap_embedded/src/device_loop.rs` | +1196 (portable) |
| `frostsnap_embedded/src/framed_serial.rs` | +218 (portable) |
| `frostsnap_embedded/src/ui.rs` | +158 (portable) |
| `device/src/esp_ui.rs` | +85 (ESP-specific remnant) |
| `device/src/firmware.rs` | +149 (ESP-specific remnant) |

Post-lift, the ESP-specific shell is roughly 234 lines against ~1,570 lines of portable run-loop.

## Caveats that limit how far this carries

- **The PR is open, not merged** as of 2026-08-10. On current `master` the run-loop still lives in
  esp-hal-typed `device/src/esp32_run.rs`. A porter today works against the unlifted tree.
- **The stated motivation is a software simulator, not a second physical MCU.** The seam serves
  porting incidentally; there is no maintainer statement about targeting another chip family.
- `FirmwareServices` fences off OTA and attestation as explicitly non-portable. Those are precisely
  the parts a Coldcard port would need to replace with something, and the trait does not say what.
- `DeviceSecretDerivation` abstracts the *interface* to device secrets, not the *root of trust*. On
  ESP32 the concrete impl reads read-protected eFuse HMAC keys; that has no STM32 analogue.

## See Also

- [Frostsnap device crate platform bindings](2026-08-10-frostsnap-device-crate-platform-bindings.md)
- [Frostsnap multi-board history and the ESP32-S3 port](../notes/2026-08-10-frostsnap-multiboard-history-esp32s3.md)
