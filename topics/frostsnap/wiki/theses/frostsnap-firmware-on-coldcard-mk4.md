---
title: "Thesis: It would be easy to adapt Frostsnap firmware to run on a Coldcard Mk4"
type: thesis
status: completed
created: 2026-08-10
updated: 2026-08-10
verdict: contradicted
confidence: high
core_claim: "Frostsnap's ESP32-C3 device firmware could be adapted to run on Coldcard Mk4 hardware with low engineering effort."
key_variables: [cpu-isa-and-hal, firmware-stack, secure-element-provisioning, display-and-transport, code-signing-and-distribution]
falsification: "The port requires simultaneously replacing the HAL, the secure-element/provisioning layer, and the display/transport layer — or a hard blocker exists (bootloader rejects non-MicroPython images, SE-bound secrets unusable by foreign firmware, no viable display driver path, or licensing bars redistribution)."
tags: [frostsnap, coldcard, firmware-porting, esp32c3, stm32l4, embedded-rust, feasibility]
---

# Thesis: It would be easy to adapt Frostsnap firmware to run on a Coldcard Mk4

## Core Claim

Frostsnap's device firmware — the Rust `no_std` binary that holds a FROST share, participates in
keygen, and signs — could be retargeted onto stock Coldcard Mk4 hardware with low effort, in the
sense that the FROST logic carries over and only thin platform glue needs rewriting.

## Key Variables

1. **CPU/ISA + HAL.** Frostsnap targets `riscv32imc-unknown-none-elf` (ESP32-C3) against `esp-hal`.
   Coldcard Mk4 is an STM32L4-family ARM Cortex-M4 (Thumb-2).
2. **Firmware stack.** Frostsnap is bare-metal `no_std` Rust. Mk4 runs MicroPython plus C code
   beneath a bootloader that can never be field-upgraded and always runs first.
3. **Secure-element / provisioning model.** Frostsnap binds to ESP32 Secure Boot v2, eFuse and the
   DS peripheral. Mk4 splits secrets across SE1 (ATECC608) and SE2 (DS28C36B) with a
   PCROP-firewalled bootloader holding long-term secret bytes.
4. **I/O surface.** Frostsnap expects a graphical display (CST816S touch controller, custom font
   generator) and a daisy-chain UART bus between devices. Mk4 offers a small mono OLED, USB,
   microSD and NFC — no touch, no daisy chain.
5. **Code-signing / distribution path.** Mk4 explicitly permits custom firmware signed with the
   published non-production "key zero", but such images carry a permanent warning screen and forced
   delay, require the main PIN to install, and brick the device if the boot/login path crashes.
   Firmware is MIT; the schematics and BOM are proprietary and not licensed for commercial use.

## Testable Prediction

If the thesis holds, a port is mostly mechanical: retarget the Rust build to `thumbv7em`, swap
`esp-hal` for `stm32l4xx-hal`/Embassy, reuse `frostsnap_core` / `schnorr_fun` / `secp256kfun`
unchanged, and reach a working signing flow on unmodified Mk4 hardware without redesigning key
storage, the display layer, or the inter-device transport.

## Falsification Criteria

The thesis fails if the port demands *simultaneous* replacement of the HAL, the secure-element and
provisioning layer, and the display/transport layer — i.e. everything except the pure-Rust crypto
core. It fails hard if any of these are true:

- The Mk4 bootloader will not start an arbitrary bare-metal image (only signed MicroPython-based
  firmware).
- Secrets held in SE1/SE2 are reachable only through Coldcard's own bootloader-resident code, so a
  foreign firmware cannot use the secure elements at all and must invent its own key storage.
- No practical driver path exists for the Mk4 display and input hardware from Rust.
- Licensing prevents building or distributing the result.

## Scope Boundary

In scope: anything that speaks to *porting feasibility* — ISA and HAL portability, `no_std` crypto
crate portability, bootloader and secure-boot constraints, secure-element access from custom
firmware, display/input driver availability, flash and RAM budgets, and prior art in moving wallet
firmware between MCUs.

Out of scope (skip as tangential): FROST protocol theory, MuSig2 protocol detail (see hub topic
`musig2-signing-ceremonies`), Coldcard product marketing and reviews, general hardware-wallet
buyer's guides, and Frostsnap threat-model debate that does not touch the port.

## Evidence For

Sorted by evidence strength. Note that the strongest supporting evidence supports a *narrower* claim
than the thesis states — see Nuances.

### Strong

- **A portability seam is being built deliberately.** PR #513 `frostsnap-embedded-lift` lifts the run
  loop behind a six-associated-type `DeviceHal` trait (`Storage: NorFlash + ReadNorFlash`, `Upstream`/
  `Downstream: SerialPort`, `Rng: RngCore + CryptoRng`, `Secrets: DeviceSecretDerivation`,
  `Firmware: FirmwareServices`), with the module doc stating "the portable run-loop only ever sees these
  traits — never `esp_hal`." Diffstat deletes `esp32_run.rs` (−766), `ui.rs` (−159),
  `touch_handler.rs` (−67) in favour of `frostsnap_embedded/src/device_loop.rs` (+1,196).
  *Source: `raw/articles/2026-08-10-frostsnap-devicehal-pr-513.md`*
- **Frostsnap has already crossed an ISA boundary cheaply.** The `origin/esp32s3` branch (Apr–May 2026)
  ported RISC-V RV32IMC → Xtensa LX7 in **27 files, +1,579/−570**, ~1,000 new peripheral lines, ~2
  engineers × 3 weeks, reaching "Frostsnap firmware working in QEMU" (`3b183b6e`). ISA is demonstrably
  not the expensive variable.
  *Source: `raw/notes/2026-08-10-frostsnap-multiboard-history-esp32s3.md`*
- **The crypto core is genuinely `no_std` and already builds bare-metal.** `frostsnap_core`,
  `schnorr_fun`, `secp256kfun` are `#![no_std]` with no C or `libsecp256k1` dependency in the default
  path, and Frostsnap compiles them today for `riscv32imc-unknown-none-elf` — so essentially no host-OS
  assumptions remain to break on ARM.
  *Source: `raw/articles/2026-08-10-embedded-rust-portability-limits.md`*
- **The destination MCU is a first-class Rust target.** Mk4's MCU is confirmed **STM32L4S5VI** from
  Coinkite's own build files (`CMSIS_MCU = STM32L4S5xx`, `MICROPY_HW_MCU_NAME "STM32L4SxVI"`), and
  `embassy-stm32` carries an **exact `stm32l4s5vi` feature** among 139 STM32L4 features — `cm4`, 2 MB
  flash, 640 KB SRAM, with `RNG`/`AES`/`HASH`/`USB_OTG_FS`/`SPI1`/`I2C1`/`OCTOSPI1` all present and
  `erase_size 4096` / `write_size 8` making a `NorFlash` impl mechanical.
  *Source: `raw/articles/2026-08-10-embedded-rust-portability-limits.md`*
- **FROST already runs on this exact core family.** `PoneBiometrics/JavGar_master` demonstrates FROST
  2-of-3 on an STM32 **Nucleo-L476RG** (Cortex-M4) under Zephyr over UART. Feasibility of FROST on
  Cortex-M4 is settled — on an open board.
  *Source: `raw/notes/2026-08-10-port-thesis-confounders-and-steelman.md`*
- **The firmware fits, and the two loudest "impossible" arguments are false.** Stripping ESP-only
  packaging (a verified all-zero 55,948-byte MMU-alignment segment at load address `0x0`, headers,
  checksum, appended SHA-256, sector padding, 4,096-byte Secure Boot v2 signature block) leaves
  **1,419,688 bytes vs 1392K `FLASH_TEXT` — 5,720 under**, ~533 KB under `FW_MAX_LENGTH_MK4`. And
  STM32L4S5 **does** have hardware HMAC-SHA256 (`HASH_BASE` present, `HASH_CR_MODE` bit 6 selects HMAC,
  `HAL_HMACEx_SHA256_Start` exposed).
  *Source: `raw/data/2026-08-10-frostsnap-coldcard-resource-fit-audit.md`*

### Moderate

- **Drivers are portable in principle.** Frostsnap's display path uses `mipidsi` with
  `models::ST7789`, which depends only on `embedded-hal ^1.0` + `embedded-graphics-core`; only the SPI
  bus handle is ESP-typed. `embedded-hal` 1.0.0 (2024-01-09) is stable with no 2.0 planned, and
  `ssd1306` 0.10.0 is an existence proof of one driver crate serving both `esp-hal` and
  `embassy-stm32`.
- **Coldcard publishes a custom-firmware key.** "Key zero" has shipped publicly since 2018 specifically
  to permit third-party builds, and `verify.c` accepts `pubkey_num == 0` images. The door is nominally
  open.
- **Mk4 has more RAM than the source platform.** 632 KiB internal SRAM vs the ESP32-C3's 313 KiB DRAM
  (against a 256 KiB Frostsnap heap), plus 8 MB of memory-mapped PSRAM.

### Weak

- **Partial ports do succeed at the crypto layer.** Trezor issue #1919: a hobbyist got "mostly the
  basics, key and mnemonic generation, key derivation, display addresses" of Trezor legacy firmware onto
  RP2040 unaided — evidence that the portable ~20% really is portable.

## Evidence Against

### Strong

- **The reference class says 7–10 months and ~20,000 lines for a cross-vendor port, with a high failure
  rate.** Jade ESP32→S3 (*same vendor*): ~10.5 months, 114 files, +9,222/−11,340. Trezor F4→U5 (*same
  vendor*): ~7 months, 256 files, +17,547/−1,118. Trezor core→Model One (*same vendor, same ISA, own
  hardware*): **abandoned after 6 years** — "After 6 years we can close this issue as we do not have any
  intention to do such thing anymore." Krux's funded device-agnostic goal: **unstarted after 4 years**.
  SeedSigner→ESP32: 6 full-time weeks → **emulator only**.
  *Source: `raw/notes/2026-08-10-wallet-firmware-port-precedents.md`*
- **The boot/trust layer is exactly what kills these ports.** Trezor #24's checklist at close: HAL
  (display, touch, USB) ✅ and all five `modtrezor*` modules ✅, but **`boardloader/bootloader` ❌**. The
  application layer ported; the boot layer did not. Mk4's boot layer is the part that cannot be replaced
  at all.
- **A foreign binary never boots on a Mk4.** `verify_header()` requires magic `0xCC001234`, a version
  string, a timestamp bounds check, `pubkey_num < NUM_KNOWN_PUBKEYS` (6 keys), a passing
  `uECC_verify`, and an OTP anti-downgrade check, with a 128-byte header at `(0x4000 - 128)`. A raw
  `riscv32imc` ELF — or any bare `.bin` — is rejected before execution.
  *Source: `raw/notes/2026-08-10-coldcard-mk4-custom-firmware-constraints.md`*
- **The root of trust cannot be translated, only rebuilt.** Frostsnap derives its device identity keypair
  via `hmac.hash("frostsnap-device-keypair", &device_id_seed)` over a key in **read-protected eFuse**
  (`KeyPurpose::HmacUpstream`) that software never sees; HMAC also gates share encryption (`Key2`) and
  RNG seeding (`Key3`). Mk4 instead gates all secrets behind `firewall_dispatch()` — ~25 fixed methods,
  `good_addr()` pointer-checked, "so we aren't tricked into revealing our secrets" — and STM32's HASH
  block has **no key store**, so the key must be fed from flash or RAM. This is a
  security-architecture rewrite, not a HAL swap.
  *Source: `raw/data/2026-08-10-frostsnap-coldcard-resource-fit-audit.md`*
- **There is no iteration loop.** `docs/dev-access.md`: "your COLDCARD will be bricked if your code
  crashes before it gets running 'enough' that you can upload a corrected version. Bugs in the boot &
  login sequence are fatal in that sense" — and SD recovery "cannot load **new** code" because the
  checksum must already match SE1. Bring-up *is* a stream of early-boot crashes. This multiplies every
  other cost.
- **DFU is fused off and the lockdown is one-way.** `dispatch.c` case 2 returns `EPERM` ("we cannot
  support DFU in secure mode anymore") under `flash_is_security_level2()`; `main.c` calls
  `LOCKUP_FOREVER()`. `flash_lockdown_hard()` is documented as "a one-way trip," and case 102 notes
  "production units will be: `flash_lockdown_hard(OB_RDP_LEVEL_2);` // No change possible after this."
- **Zero prior art in seven years.** Three independent search engines return **no** instance of anyone
  running third-party, community or ported firmware on any Coldcard. The only "forks" are passive
  mirrors of Coinkite's tree. A published custom-firmware key has existed since 2018-07-24.

### Moderate

- **The vendor deliberately closed the path.** Commit **`58edd613`, 2022-01-26, Peter D. Gray, "Updates
  for Mk4"** deleted the pre-Mk4 text "you can take factory-fresh Coldcards, destroy the tamper-evident
  bag, and load your firmware onto them before shipping to your customers," along with the bless-for-
  green-light path and the entire Medium Core REPL/`boot2.py` workflow. This was a dated, intentional
  ratchet — not an oversight.
- **A permanent 25-second boot penalty.** `warn_fishy_firmware()`: `const int wait = 100;` under
  `#if RELEASE`, looping `delay_ms(250)` = **25 seconds every boot, forever**, for key-zero firmware,
  with the vendor confirming the Mk4 bless escape is gone.
- **The coupling is ~3× larger than a naive count suggests.** 110 `esp_*` occurrences / 86 `esp_hal::`
  paths look like 7.9% of a 79,282-line workspace — but 58% of `device/` lines are architecture-specific
  end-to-end, and **45 of 80 `frostsnap_widgets` files reference `Rgb565`** (318 occurrences) against a
  128×64 **1-bit mono** target. Honest estimate: **15,000–20,000 lines touched**.
  *Source: `raw/articles/2026-08-10-frostsnap-device-crate-platform-bindings.md`*
- **The I/O model collapses.** ST7789 240×280 colour + CST816S capacitive touch + a two-UART daisy chain
  (GPIO18/19 up, GPIO21/20 down, presence detect on GPIO0/GPIO10) against a 128×64 mono OLED, a keypad,
  USB/microSD/NFC and **no inter-device bus at all**. Frostsnap's core interaction model — devices
  talking to each other in a chain — has no hardware to run on.
- **A/B OTA does not fit.** `partitions.csv` sizes each app slot at 1724K; two slots + 512K `nvs`
  ≈ 4.2 MB against Mk4's 1984K FLASH region. One slot alone exceeds it. Single-image-only would be
  forced, i.e. no rollback on a device where a bad image is unrecoverable.
- **Licensing bars a commercial result.** Coldcard firmware is MIT **+ Commons Clause** (which strips
  "Sell"); `hardware/README.md` states Coinkite "does NOT grant license of this information for
  comercial use." Frostsnap is plain MIT — the combination conflicts.

### Weak

- **Upstream maintenance policy.** Trezor's stance on port patches (matejcik, 2021-11-23) — "if it's
  anything more significant or intrusive, then no, because that would effectively be dead code in our
  repo that is likely to get broken" — is not Coinkite's policy, but it is the norm in this class and
  predicts that a port would be an unmaintained fork.
- **Ecosystem churn.** `esp-hal-embassy` is deprecated in favour of `esp-rtos 0.3.0`; Frostsnap pins a
  private `esp-hal` fork (rev `6ecaa2eb`). A port starts from a moving fork, not a release.

## Nuances & Caveats

- **The claim's difficulty tier is misidentified.** The evidence supports three distinct tiers: new
  *board*, same chip ≈ **200 LOC** (Jade PR #290 = 4 files, +217/−0); new *chip*, same HAL vendor ≈
  **3 weeks** (Frostsnap's own `esp32s3` branch); new *vendor*, new HAL ≈ **7–10 months / ~20,000
  lines**. Frostsnap→Coldcard is the third tier *plus* a locked third-party product — a category with
  **no successful precedent in the reference class**. Citing the `esp32s3` port as evidence of ease is
  the central error: that port stayed inside Espressif on `esp-hal` behind a chip feature flag.
- **`no_std` ≠ portable.** The Rust Embedded Book is explicit: `embedded-hal` makes *drivers* portable,
  while the HAL implementation and the application/init layer must be rewritten per chip, the latter
  "requir[ing] the most adaptation efforts" because peripheral init "differs, sometimes drastically so."
  `no_std` removes the OS, not the chip.
- **FROST needs a heap.** `schnorr_fun/src/lib.rs` gates it `#[cfg(feature = "alloc")] pub mod frost;`,
  and `frostsnap_core` enables `alloc`. Any port must supply a global allocator (`embedded-alloc` for
  `esp-alloc`). "Pure `no_std`, no heap" is false for this stack.
- **The crypto-on-ARM claim is plausible but uncertified.** docs.rs builds only
  `x86_64-unknown-linux-gnu` for both crypto crates, and upstream `secp256kfun` CI's ARM entry is
  *hosted* `armv7-unknown-linux-gnueabihf` under `cross` — **zero `thumbv*-none-*` coverage** anywhere.
  The inference from the existing `riscv32imc` build is strong, but it is an inference.
- **Two anti-thesis arguments had to be discarded.** "It doesn't fit in flash" and "STM32L4S5 has no
  HMAC" are both false. Anyone reaching the right conclusion via those routes reached it by luck. The
  flash margin is also thin (~5.7 KB) and measured on the *ESP* build — a Thumb-2 recompile changes text
  size, so "roughly at parity" is the honest statement, not "comfortably fits."
- **The RSA/HMAC dependency runs opposite to intuition.** Missing PKA/CRYP (verified absent) costs almost
  nothing, because Frostsnap's RSA use is verify/attestation only (`secure_boot.rs` RSA-PSS verify called
  once from `ota.rs:450`; `ds.rs` factory attestation) while Bitcoin signing is Schnorr in
  `frostsnap_core`. HMAC — which *is* present in hardware — is the load-bearing primitive, and the
  problem with it is key custody, not acceleration.
- **The threat models don't match either.** Frostsnap has no PIN, no passphrase and no per-device secure
  element for the coordinator; it leverages the phone's secure element and relies on **threshold
  distribution** rather than per-device hardening. Coldcard is the inverse — dual SE, trick PINs,
  anti-phishing words, RDP2. Even a *successful* port yields a device whose security properties match
  **neither** product: Frostsnap's protocol on hardware whose trust anchors it cannot reach, with
  Coldcard's defenses bypassed rather than inherited.
- **Display is not the binding constraint for the adjacent goal.** Coldcard shipped MuSig2 on the 128×64
  mono Mk4 and the 320×240 colour Q *simultaneously*, because the transport is PSBT over files/USB rather
  than an on-screen ceremony. It *is* a real constraint for a Frostsnap port, which needs the on-device
  multi-party UI.
- **The underlying goal is far closer than the thesis implies.** Coldcard **already ships MuSig2 on Mk4**
  (EDGE `6.5.0X`, BIP-373/390/328), including a vendor-documented t-of-n taptree policy
  `tr(musig(@0,@1,@2),{{pk(musig(@0,@1)),pk(musig(@1,@2))},pk(musig(@0,@2))})`, and already implements
  two-round signing with RAM-only nonce state. BIP-445 states its Tweak Context "is identical to the
  KeyAgg Context defined in BIP327. Implementations with existing BIP327 code can reuse it." The gaps are
  narrow and specific: `ngu.secp256k1` exposes no scalar arithmetic (`seckey_tweak_mul`,
  `ec_pubkey_combine` → 0 hits), upstream secp256k1 has no FROST module, no FROST PSBT fields exist, and
  **DKG is unsolved** (deferred to ChillDKG). See
  [Threshold signing paths on Coldcard](../topics/threshold-signing-paths-on-coldcard.md).
- **Interop is Frostsnap's stated goal but not yet a spec.** "We want to set an open standard other
  vendors can implement" (Adam Mashrique) — but the wire protocol is `frostsnap_comms`, not PSBT, and the
  security model requires factory-provisioned genuine devices with authenticity certificates. No
  drop-in bridge exists.

## Verdict

**Status**: **Contradicted** (literal claim) / **Partially Supported** (narrow steelman)

**Confidence**: **High** — primary-source code on both sides, measured diffstats for the reference
class, and a byte-level audit that eliminated the two false arguments. Confidence is lower (medium) only
on the effort *magnitude* for the hypothetical unlocked-board variant.

**Summary.** "Easy" is wrong by roughly two orders of magnitude, and for the shipping Coldcard Mk4 the
port is not merely hard but blocked. The claim conflates three different tasks: adding a new *board*
(~200 LOC), moving to a new *chip* within one HAL vendor (Frostsnap's own `esp32s3` branch: 27 files,
~3 weeks), and moving to a new *vendor's* HAL (the reference class: 7–10 months, ~20,000 lines, frequently
abandoned). Targeting a Mk4 is the third, plus a fourth category the reference class contains no
successful instance of — a locked commercial device whose bootloader always runs first and cannot be
replaced, whose secure elements are reachable only through a foreign callgate ABI that offers no
equivalent of the read-protected-eFuse HMAC primitive Frostsnap's identity derivation is built on, whose
DFU is fused off at RDP level 2, and which bricks on early-boot bugs with no recovery path for new code.
Everything except the FROST/crypto core must be rewritten simultaneously: HAL, runtime, linker script,
allocator, flash/OTA, secure boot, key custody, the entire `Rgb565` widget tree against a 1-bit mono
panel, and the daisy-chain transport for which no hardware exists. **This is the falsification criterion
stated in advance, met on every clause.**

**Strongest supporting evidence.** PR #513's `DeviceHal` trait is a real, deliberate portability seam
("the portable run-loop only ever sees these traits — never `esp_hal`"); the crypto stack is genuinely
`#![no_std]` and already builds bare-metal; `embassy-stm32` has an exact `stm32l4s5vi` feature; and FROST
2-of-3 already runs on a Nucleo-L476RG, the Mk4's core family. Note that all of this supports building a
*new* Cortex-M4 FROST device, not running Frostsnap on a Mk4.

**Strongest opposing evidence.** Trezor issue #24 — same vendor, same ISA, own hardware, in-house team,
full schematics, no adversarial bootloader — **abandoned after 6 years** with HAL ✅ and
`boardloader/bootloader` ❌. That is the *easy* version of this task, and the exact layer that killed it is
the layer Mk4 makes immutable. Alongside it: `verify_header()`'s `0xCC001234` + `uECC_verify` gate,
`firewall_dispatch()`'s ~25-method callgate, `LOCKUP_FOREVER()` on DFU at RDP2, the one-way
`flash_lockdown_hard()`, and **zero third-party Coldcard firmware in the seven years since key zero was
published**.

**Key caveats.** Two popular anti-port arguments are false and were discarded: the image *does* fit
(1,419,688 vs 1,425,408 bytes once ESP MMU padding and signature blocks are stripped — though only by
~5.7 KB, measured on the ESP build), and STM32L4S5 *does* have hardware HMAC-SHA256. The genuine
resource failure is the OTA layout (~4.2 MB of partitions vs a 1984K region), not code size. And the
claim's *underlying goal* is much closer than the claim itself: **Coldcard already ships MuSig2 threshold
Schnorr on Mk4**, with a documented t-of-n taptree policy and the two-round nonce machinery BIP-445 would
reuse.

**What would change this verdict.**

1. Coinkite reopening a vendor-blessed third-party firmware path for Mk4 (reversing `58edd613`) — this is
   the single load-bearing blocker; without it the rest is moot.
2. A demonstrated bare-metal non-MicroPython image booting on an RDP2 Mk4 signed with key zero — no such
   artifact exists.
3. PR #513 merging *and* someone publishing a working `DeviceHal` implementation on `embassy-stm32`,
   which would convert the Tier-3 estimate from inference to measurement.
4. A `frostsnap_widgets` mono/1-bit rendering backend landing upstream, removing the largest non-HAL
   rewrite.
5. Evidence that `secp256kfun`/`schnorr_fun` build and pass tests on `thumbv7em-none-eabihf` (currently
   zero `thumbv*-none-*` CI coverage anywhere).

**Suggested follow-up theses.**

- "A new Cortex-M4 FROST signer can reuse `frostsnap_core` and `frostsnap_widgets` with under 5,000 lines
  of new platform code" — the steelman worth testing, with Nucleo-L476RG prior art as a starting point.
- "Implementing BIP-445 in Coldcard's existing MuSig2 codepath is under 3,000 lines, and DKG is the only
  genuine blocker."
- "Coldcard Mk4's RAM budget cannot support a t-of-n FROST DKG ceremony" — PR #683's "buffer too small"
  failures are the first datapoint.
- "Frostsnap's `frostsnap_comms` could be bridged to PSBT without weakening its device-authenticity
  model" — tests whether the stated open-standard goal is reachable without new hardware.
