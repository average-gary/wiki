---
title: "Frostsnap multi-board history and the measured ESP32-S3 port cost"
source: "https://github.com/frostsnap/frostsnap"
type: notes
ingested: 2026-08-10
tags: [frostsnap, git-history, multi-board, esp32s3, xtensa, qemu, porting-cost, feature-flags, hardware-abstraction]
summary: "Git-history audit of frostsnap/frostsnap (1,251 commits, 2022-09-16 to 2026-08-07) establishing that Frostsnap firmware has run on non-production hardware repeatedly. Origins were off-the-shelf: commit 82050de1 (2022-09-16, nickfarrow) 'init' under the crate name frost-device on an ESP-IDF stack; 69e377b8 (2022-10-10) 'add esp32-c3-dkc02 board support crate' vendored a BSP for the stock Espressif ESP32-C3-DevKitC-02 with led.rs, temp_sensor.rs, wifi.rs; removed 2022-12-20 in 0529339f. Commit 69780387 (2023-07-07) 'Purple and Blue Board (#65)' shipped a two-board feature matrix in device/Cargo.toml with per-board [[bin]] targets and required-features. Commit 91cdb937 (2023-06-16) carries a first-person maintainer statement on multi-board cost: 'With different bin and different feature flags for each board. Not really happy with this since they have different dependencies and so should be different crates.' Commit b65f24db (2023-06-20) created the hardware abstraction seam by splitting device/src/main.rs (-539) into esp32_run.rs (+338), the board-agnostic event loop still present today. Board binaries seen across all branches: blue.rs, purple.rs, v2.rs, dev.rs, frontier.rs, legacy.rs, widget_dev.rs, frostypede.rs, touchgrid.rs, adjusted_touchgrid.rs, efuse_check.rs, bug_minimal.rs, bug_maximal.rs, plus an ai-042c3 branch (Jan 2023, SSD1306 OLED board). Decisive finding: branch origin/esp32s3 (Apr-May 2026) ports the firmware to ESP32-S3, a different ISA (Xtensa LX7 rather than RISC-V) - commits 2dc22549 'ESP32-S3 working widget_dev' (2026-04-30), 3b183b6e 'Frostsnap firmware working in QEMU' (2026-05-15), e9a0e6ab 'Working click>touch emulation in QEMU' and 9df1953c 'Waveshare S3 pinout support' (2026-05-18, a third-party off-the-shelf board). That branch's device/Cargo.toml shows a chip-abstraction feature matrix (chip-esp32c3 / chip-esp32s3 / firmware / qemu-display / s3-fpc-board). Measured cost via git diff --stat master...origin/esp32s3 -- device/: 27 files, +1,579/-570, of which the genuinely new hardware files are peripherals_s3_fpc.rs (348), peripherals_s3_waveshare.rs (332), qemu_display.rs (178), qemu_touch.rs (54); existing peripherals.rs reworked +-207. Roughly 1,000 new lines in a peripherals layer, two engineers, about three weeks of commits. Critical qualifier: every one of these ports stayed inside the Espressif family on esp-hal - the abstraction seam is chip-esp32c3 vs chip-esp32s3, not esp vs stm32."
thesis: frostsnap-firmware-on-coldcard-mk4
relevance: direct
evidence_strength: primary-source-code
direction: nuances
credibility: high
confidence: high
authors: [Lloyd Fournier, Adam Mashrique, Nick Farrow]
fetched: 2026-08-10
---

# Frostsnap multi-board history and the measured ESP32-S3 port cost

## Off-the-shelf origins

| Date | Commit | Event |
|------|--------|-------|
| 2022-09-16 | `82050de1` | "init" (nickfarrow) — crate named `frost-device`, ESP-IDF stack (`esp-idf-svc`, `esp-idf-sys`) |
| 2022-10-10 | `69e377b8` | "add esp32-c3-dkc02 board support crate" — BSP for the **stock Espressif ESP32-C3-DevKitC-02** |
| 2022-12-20 | `0529339f` | Devkit BSP removed, −2,194 lines |
| 2023-05-31 | `e88bbd31`, `09e8752c` | "blue board" |
| 2023-06-16 | `91cdb937` | Purple + blue merged into one branch |
| 2023-06-20 | `b65f24db` | **Hardware seam created** — `main.rs` (−539) split into `esp32_run.rs` (+338) |
| 2023-07-07 | `69780387` | "Purple and Blue Board (#65)" — two-board feature matrix |
| 2023-10-03 | `7df0485b` | `purple.rs` deleted; consolidation onto own hardware |
| 2024-04/05 | `f4ee9a79`, `3fda5fdc` | v2 board display, touch, updown detect |
| 2025-09-05 | `72bd9b94` | `v2.rs` removed ("Arrange peripheral initialisation nicely (#305)") |

The two-board manifest, verbatim from `device/Cargo.toml` at `69780387`:

```toml
[features]
blue = ["air101"]
ai-042c3 = ["rgb-led", "dep:display-interface", "dep:ssd1306"]
air101 = ["dep:display-interface-spi", "dep:mipidsi", "dep:embedded-graphics-framebuf"]
air101-r2223 = []
rgb-led = ["dep:esp-hal-smartled", "dep:smart-leds"]
purple = ["dep:ssd1306", "dep:display-interface-spi", ...]

[[bin]]
name = "purple"
required-features = ["purple"]
[[bin]]
name = "blue"
required-features = ["blue"]
```

**Maintainer statement on multi-board cost** — commit body of `91cdb937` (LLFourn), verbatim:

> "With different bin and different feature flags for each board. **Not really happy with this since
> they have different dependencies and so should be different crates.**"

This is the only first-person developer statement on hardware portability found in public sources.
No interview, talk or blog post by Lloyd Fournier or Adam Mashrique stating an ESP32-C3 rationale or
a hardware-independence claim surfaced across four search queries.

## The decisive finding: a cross-ISA port already happened

Branch `origin/esp32s3` (Adam Mashrique + LLFourn, Apr–May 2026) ports the firmware to the
**ESP32-S3 — Xtensa LX7, a different instruction set from RISC-V**:

- 2026-04-30 `2dc22549` "ESP32-S3 working widget_dev"
- 2026-05-15 `3b183b6e` "Frostsnap firmware working in QEMU"
- 2026-05-18 `e9a0e6ab` "Working click>touch emulation in QEMU"
- 2026-05-18 `9df1953c` "Waveshare S3 pinout support" — a **third-party off-the-shelf board**

Chip abstraction on that branch:

```toml
default = ["chip-esp32c3", "stack_guard", "firmware"]
chip-esp32c3 = ["dep:esp32c3", "esp-hal/esp32c3", "esp-storage/esp32c3", "frostsnap_cst816s/chip-esp32c3", ...]
chip-esp32s3 = ["dep:esp32s3", "esp-hal/esp32s3", "esp-storage/esp32s3", "frostsnap_cst816s/chip-esp32s3", ...]
firmware = ["dep:frostsnap_core", "dep:frostsnap_comms", ...]
qemu-display = [...]
s3-fpc-board = []
```

Note `firmware = [...]` — the protocol/crypto core is explicitly factored apart from the chip layer.

**Measured cost** (`git diff --stat master...origin/esp32s3 -- device/`): **27 files, +1,579 / −570**.
New hardware files: `peripherals_s3_fpc.rs` (348), `peripherals_s3_waveshare.rs` (332),
`qemu_display.rs` (178), `qemu_touch.rs` (54); existing `peripherals.rs` reworked ±207.

**≈1,000 new lines in a peripherals layer, two engineers, about three weeks of commits.**

## The qualifier that decides the thesis

Every one of these ports stayed **inside the Espressif family on `esp-hal`**. The abstraction seam is
`chip-esp32c3` vs `chip-esp32s3` — not `esp` vs `stm32`. The tree carries 114 `esp_hal` references,
36 `riscv32imc`, plus `esp-storage`, `esp-bootloader-esp-idf`, ESP-IDF bootloader binaries, and
ESP32 eFuse / Digital-Signature-peripheral code (`ds.rs`, `efuse.rs`, `secure_boot.rs`).

The ESP32-S3 port reused: the same HAL crate family, the same linker-script mechanism, the same
eFuse/HMAC key-custody model, the same 240×280 color touch display, the same OTA image format. A
Coldcard port shares none of those.

## Frostsnap production hardware is also locked

`frostsnap_factory/PROVISIONING.md`, verbatim: **"Dev**: JTAG stays enabled, `SECURE_BOOT_INSECURE`
allows reflashing freely. / **Prod**: JTAG permanently disabled on first boot, full secure boot
enforcement." Production burns an RSA-3072 Secure Boot v2 key digest into eFuses with
`read_protect: true`. The portability lives in the source tree, not in retail devices.

## See Also

- [Device crate platform bindings](../articles/2026-08-10-frostsnap-device-crate-platform-bindings.md)
- [PR #513 — DeviceHal trait lift](../articles/2026-08-10-frostsnap-devicehal-pr-513.md)
- [Wallet firmware port precedents](2026-08-10-wallet-firmware-port-precedents.md)
