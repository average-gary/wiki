# concepts Index

> Compiled concepts articles for frostsnap.

Last updated: 2026-08-10

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [platform-coupling-and-the-devicehal-seam.md](platform-coupling-and-the-devicehal-seam.md) | How tightly Frostsnap's firmware is bound to ESP32, and the `DeviceHal` trait (PR #513, open) being built to loosen it. Measured: 110 `esp_*` occurrences, 86 `esp_hal::` paths, naive 7.9% workspace share undercounting ~3× because 45 of 80 widget files assume `Rgb565`. | esp-hal, devicehal, portability, no-std, rgb565 | 2026-08-10 |
| [root-of-trust-portability.md](root-of-trust-portability.md) | Why the least portable part of signing firmware is its root of trust, not its HAL: read-protected eFuse HMAC identity derivation vs Coldcard's dual secure elements behind a `firewall_dispatch()` callgate. Includes the refutation of the "no HMAC peripheral" claim. | root-of-trust, efuse, hmac, secure-element, key-custody | 2026-08-10 |
| [custom-firmware-on-locked-devices.md](custom-firmware-on-locked-devices.md) | How a device can be open-source and still closed to custom firmware: header/signature gates, the 25-second key-zero boot penalty, DFU fused off at RDP2, the one-way lockdown, and the missing iteration loop that bricks bring-up work. | code-signing, rdp2, dfu, brick-risk, key-zero, commons-clause | 2026-08-10 |

## Categories

- **portability**: platform-coupling-and-the-devicehal-seam.md, root-of-trust-portability.md
- **device-constraints**: custom-firmware-on-locked-devices.md, root-of-trust-portability.md

## Recent Changes

- 2026-08-10: First three concepts compiled from thesis research on `frostsnap-firmware-on-coldcard-mk4`.
- 2026-08-10: Directory created by topic init.
