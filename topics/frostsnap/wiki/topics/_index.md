# topics Index

> Compiled topics articles for frostsnap.

Last updated: 2026-08-10

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [porting-frostsnap-to-other-hardware.md](porting-frostsnap-to-other-hardware.md) | Synthesis of what moving Frostsnap's firmware to other silicon costs, in four difficulty tiers: new board ~200 LOC, new chip same HAL ~3 weeks, new vendor ~7–10 months and ~20k lines, and a locked third-party product with no successful precedent. Covers what is genuinely portable and why `DeviceHal` matters. | porting, firmware-portability, esp32c3, stm32l4, feasibility, devicehal | 2026-08-10 |
| [threshold-signing-paths-on-coldcard.md](threshold-signing-paths-on-coldcard.md) | The shorter route to the same goal: Coldcard EDGE already ships MuSig2 on Mk4 with a documented t-of-n taptree policy and two-round nonce state. Maps the remaining gap to true FROST — missing scalar ops in `ngu.secp256k1`, no upstream FROST module, no FROST PSBT fields, and DKG as the unsolved piece. | coldcard, musig2, frost, bip-445, chilldkg, libngu, psbt, interop | 2026-08-10 |

## Categories

- **portability**: porting-frostsnap-to-other-hardware.md
- **interop**: threshold-signing-paths-on-coldcard.md

## Recent Changes

- 2026-08-10: First two topics compiled from thesis research on `frostsnap-firmware-on-coldcard-mk4`.
- 2026-08-10: Directory created by topic init.
