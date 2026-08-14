# theses Index

> Investigated claims for frostsnap, with rendered verdicts.

Last updated: 2026-08-10

## Contents

| File | Verdict | Confidence | Summary | Updated |
|------|---------|-----------|---------|---------|
| [frostsnap-firmware-on-coldcard-mk4.md](frostsnap-firmware-on-coldcard-mk4.md) | **Contradicted** (literal) / Partially Supported (narrow steelman) | high | "It would be easy to adapt Frostsnap firmware to run on a Coldcard Mk4." Wrong by ~2 orders of magnitude and blocked outright on shipping hardware: the claim conflates a new-board port (~200 LOC) with a cross-vendor HAL port (7–10 months, ~20k lines) and with running on a locked device whose bootloader cannot be replaced. Two popular anti-port arguments (flash size, missing HMAC) were refuted along the way. The underlying goal is much closer than the claim implies — Coldcard already ships MuSig2 on Mk4. | 2026-08-10 |

## Recent Changes

- 2026-08-10: First thesis compiled — `frostsnap-firmware-on-coldcard-mk4`, verdict Contradicted, confidence high, from 9 thesis-directed raw sources across 8 parallel research agents.
- 2026-08-10: Directory created by topic init.
