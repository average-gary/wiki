# data Index

> Raw data sources for frostsnap — measured artifacts and byte-level audits.

Last updated: 2026-08-10

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [2026-08-10-frostsnap-coldcard-resource-fit-audit.md](2026-08-10-frostsnap-coldcard-resource-fit-audit.md) | Byte-level audit of `firmware.bin` v0.3.0 refuting two anti-port claims: the image fits (1,419,688 vs 1392K after stripping 55,948 bytes of ESP MMU padding), and STM32L4S5 does have hardware HMAC-SHA256. Real obstacle is key custody; OTA layout is what actually doesn't fit. | flash-budget, esp-image-format, stm32l4s5, hmac, resource-fit, refuted-claims | 2026-08-10 |

## Categories

- **resource-audits**: 2026-08-10-frostsnap-coldcard-resource-fit-audit.md

## Recent Changes

- 2026-08-10: Thesis research wrote the resource-fit audit for `frostsnap-firmware-on-coldcard-mk4`, refuting the flash-size and missing-HMAC arguments.
- 2026-08-10: Directory created by topic init.
