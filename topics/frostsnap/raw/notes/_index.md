# notes Index

> Raw notes sources for frostsnap. All current notes were gathered for the thesis
> `theses/frostsnap-firmware-on-coldcard-mk4`.

Last updated: 2026-08-10

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [2026-08-10-frostsnap-multiboard-history-esp32s3.md](2026-08-10-frostsnap-multiboard-history-esp32s3.md) | Dated git history of Frostsnap's own board/chip ports, including the `esp32s3` cross-ISA branch: 27 files, +1,579/−570, ~2 engineers × 3 weeks — but all within Espressif on `esp-hal`. | port-history, esp32s3, xtensa, multiboard, git-archaeology | 2026-08-10 |
| [2026-08-10-wallet-firmware-port-precedents.md](2026-08-10-wallet-firmware-port-precedents.md) | Reference class of every documented hardware-wallet MCU port with diffstats and outcomes: Jade ~10.5mo, Trezor F4→U5 ~7mo, Trezor→Model One abandoned after 6 years, Krux unstarted after 4. New board ≈200 LOC, new chip ≈20,000 lines. | reference-class-forecasting, trezor, jade, krux, seedsigner, porting-cost | 2026-08-10 |
| [2026-08-10-coldcard-mk4-custom-firmware-constraints.md](2026-08-10-coldcard-mk4-custom-firmware-constraints.md) | Bootloader enforcement read from shipping C: `FW_HEADER_MAGIC 0xCC001234`, `uECC_verify`, 25-second key-zero warning, `firewall_dispatch()`, DFU fused off at RDP2, one-way lockdown, MIT + Commons Clause. | coldcard, bootloader, code-signing, rdp2, firewall, dfu, brick-risk | 2026-08-10 |
| [2026-08-10-port-thesis-confounders-and-steelman.md](2026-08-10-port-thesis-confounders-and-steelman.md) | Eight confounders distorting the effort estimate (C1–C8) plus three steelman readings: crypto-on-thumbv7em plausible-but-uncertified, new-Cortex-M4-device supported, unlocked-board partially supported. | confounders, steelman, port-estimation, threat-model | 2026-08-10 |

## Categories

- **porting-evidence**: 2026-08-10-frostsnap-multiboard-history-esp32s3.md, 2026-08-10-wallet-firmware-port-precedents.md
- **target-constraints**: 2026-08-10-coldcard-mk4-custom-firmware-constraints.md
- **analysis**: 2026-08-10-port-thesis-confounders-and-steelman.md

## Recent Changes

- 2026-08-10: Thesis research wrote 4 notes for `frostsnap-firmware-on-coldcard-mk4` — Frostsnap's own port history, the wallet-port reference class, Coldcard's enforcement-level constraints, and the confounder/steelman analysis.
- 2026-08-10: Directory created by topic init.
