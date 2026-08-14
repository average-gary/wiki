---
title: "Confounders in the port-effort estimate, and the strongest steelman that survives"
source: "internal-analysis"
type: notes
ingested: 2026-08-10
tags: [confounders, steelman, port-estimation, selection-bias, survivorship-bias, frostsnap, coldcard, frost, threat-model]
summary: "Analysis pass isolating variables that make the port look easier or harder than it is, then steelmanning three narrower readings of the claim. Eight confounders identified. C1, HAL-lift-in-progress: PR #513 lifts the run loop behind a DeviceHal trait, which genuinely reduces the port surface, but it is OPEN not merged and its six associated types still require a full concrete implementation per platform - the trait boundary relocates the work, it does not remove it. C2, ISA-vs-vendor conflation: Frostsnap's own esp32s3 branch is cited as proof porting is cheap, but that port stayed inside Espressif on the same esp-hal with a chip feature flag flip, whereas STM32 means a different HAL crate, runtime crate, linker script and vendor entirely; the correct reference class is Trezor F4 to U5, not C3 to S3. C3, portable-crate share overcounted: naive line counting says 7.9 percent of the workspace is ESP-specific, but 58 percent of device/ lines are architecture-specific end-to-end and 45 of 80 frostsnap_widgets files reference Rgb565 (318 occurrences) against a 128x64 mono target, giving a realistic 15,000 to 20,000 lines touched. C4, unlocked-board vs locked-product: nearly all porting prior art targets dev boards with open JTAG and rewritable bootloaders; Mk4 ships RDP level 2 with DFU fused off and a one-way lockdown, which changes the task from engineering to circumvention-or-vendor-cooperation. C5, no-iteration-loop is a multiplier not an addend: docs/dev-access.md states bugs in the boot and login sequence brick the unit and SD recovery cannot load new code, so the normal 100-iteration bring-up loop has no cheap analogue; this is why Trezor #24 completed HAL but never boardloader/bootloader. C6, key-custody direction error: the naive reading is that Mk4's dual secure elements are a superset of the ESP32-C3's eFuse, so security is easier, but they are incompatible roots of trust - Frostsnap derives its identity keypair by HMAC over a read-protected eFuse key the software cannot see, while Mk4 gates all secret access behind firewall_dispatch() with about 25 fixed methods and a good_addr() pointer check, so the port must rebuild key custody rather than translate it. C7, the fits-in-flash red herring, resolved in the companion data note: the image does fit once ESP packaging is stripped, so anyone arguing the port is impossible on size is arguing from the wrong number, and anyone rebutting that argument has not thereby shown the port is easy. C8, the goal-substitution confound and the largest one: the thesis is about firmware, but the user-visible goal is FROST signing on a Coldcard, and Coldcard already ships MuSig2 threshold Schnorr on Mk4 with a documented t-of-n taptree policy, so the port is not on the shortest path to the goal. Three steelman readings evaluated. Steelman A, that Frostsnap's crypto crates compile for thumbv7em-none-eabihf: PLAUSIBLE and probably true since secp256kfun, schnorr_fun and frostsnap_core are all no_std with no C dependency and already build for a bare-metal riscv target, but NOT CI-verified anywhere (docs.rs is x86_64 only; upstream CI's ARM entry is hosted armv7-unknown-linux-gnueabihf under cross, so zero thumbv-none coverage) and FROST requires the alloc feature, so a global allocator must be supplied. Steelman B, that a NEW Cortex-M4 FROST signing device could reuse Frostsnap's portable crates: SUPPORTED, with direct prior art in PoneBiometrics/JavGar_master running FROST 2-of-3 on a Nucleo-L476RG, the same core family as the Mk4 MCU. Steelman C, that the port is tractable on an UNLOCKED STM32L4S5 board: PARTIALLY SUPPORTED - embassy-stm32 has an exact stm32l4s5vi feature and the peripherals exist, so this is a normal hard embedded project on the Trezor F4-to-U5 scale of roughly 7 months, but it is explicitly not what the thesis says, because 'a coldcard mk4' means the shipping locked product. Also recorded: Frostsnap's own threat model differs by design - the project states it has no PIN, no passphrase and no per-device secure element for the mobile coordinator, leveraging the phone's secure element and relying on threshold distribution instead of per-device hardening, which is close to the opposite of Coldcard's single-device-hardening philosophy, so even a successful port would produce a device whose security properties match neither product."
thesis: frostsnap-firmware-on-coldcard-mk4
relevance: direct
evidence_strength: analysis
direction: nuances
credibility: medium
confidence: medium
fetched: 2026-08-10
---

# Confounders and steelman

Written to separate the thesis's *stated* claim from the several nearby claims that are true, and to
name the variables that distort the effort estimate in each direction.

## Confounders

**C1 — HAL lift in progress (makes it look easier).** PR #513 lifts the run loop behind a `DeviceHal`
trait; the module doc says "the portable run-loop only ever sees these traits — never `esp_hal`."
Real and helpful. But it is **open, not merged**, and its six associated types (`Storage`, `Upstream`,
`Downstream`, `Rng`, `Secrets`, `Firmware`) each still need a full concrete implementation per
platform. **A trait boundary relocates the work; it does not remove it.**

**C2 — ISA-vs-vendor conflation (makes it look easier).** Frostsnap's `origin/esp32s3` branch is the
natural "see, they port cheaply" citation — 27 files, +1,579/−570, ~3 weeks. But it stayed inside
Espressif: same `esp-hal`, `chip-esp32c3` → `chip-esp32s3`. STM32 means a different HAL crate,
runtime crate (`cortex-m-rt` vs `riscv-rt`), linker script, and vendor. The correct reference class is
**Trezor F4→U5 (~7 months)**, not C3→S3.

**C3 — portable-crate share overcounted (makes it look easier).** Naive counting: 110 `esp_*`
occurrences over 79,282 workspace lines = **7.9%**. But 58% of `device/` lines are
architecture-specific end-to-end, and **45 of 80 `frostsnap_widgets` files reference `Rgb565`** (318
occurrences) against a 128×64 **mono** target. Realistic: **15,000–20,000 lines touched**.

**C4 — unlocked board vs locked product (makes it look easier).** Nearly all porting prior art targets
dev boards with open JTAG and rewritable bootloaders. Mk4 ships **RDP level 2**, DFU fused off,
one-way lockdown. That changes the task from *engineering* to *circumvention or vendor cooperation*.

**C5 — no iteration loop is a multiplier, not an addend (makes it look easier).**
`docs/dev-access.md`: bugs in the boot & login sequence brick the unit, and SD recovery "cannot load
**new** code." The normal 100-iteration bring-up loop has no cheap analogue. This is precisely why
Trezor #24 finished HAL ✅ but never `boardloader/bootloader` ❌.

**C6 — key-custody direction error (looks easier, is harder).** The naive reading: Mk4 has *two*
secure elements vs the C3's eFuse, so security is a superset. Wrong — they are **incompatible roots of
trust**. Frostsnap derives its identity keypair by HMAC over a read-protected eFuse key software never
sees (`KeyPurpose::HmacUpstream`); Mk4 gates every secret operation behind `firewall_dispatch()` with
~25 fixed methods and a `good_addr()` pointer check. The port must **rebuild** key custody, not
translate it.

**C7 — the "doesn't fit in flash" red herring (looks harder, isn't).** Resolved in the companion data
note: the image *does* fit once ESP packaging is stripped (1,419,688 bytes vs 1392K = 5,720 under).
Anyone arguing impossibility on size is arguing from the wrong number — **and anyone who rebuts that
argument has not thereby shown the port is easy.** Both sides of this sub-debate are noise.

**C8 — goal substitution (the largest confounder).** The thesis is about *firmware*. The user-visible
goal is *FROST signing on a Coldcard*. Coldcard **already ships MuSig2 threshold Schnorr on Mk4**,
with a vendor-documented t-of-n taptree policy. The port is **not on the shortest path to the goal**.

## Steelman A — "the crypto crates compile for `thumbv7em-none-eabihf`"

**Plausible, probably true, not verified.** `secp256kfun`, `schnorr_fun`, `frostsnap_core` are all
`#![no_std]`, no C dependency, and already build for a bare-metal `riscv32imc` target — so almost no
host assumptions remain to break on ARM. Against: docs.rs builds x86_64 only; upstream CI's ARM entry
is **hosted `armv7-unknown-linux-gnueabihf` under `cross`** (std, Linux) — **zero `thumbv*-none-*`
coverage**. And FROST needs `alloc` (`#[cfg(feature = "alloc")] pub mod frost;`), so a global
allocator (`embedded-alloc`) must be supplied. "Pure no_std, no heap" is false.

## Steelman B — "a new Cortex-M4 FROST device could reuse Frostsnap's portable crates"

**Supported.** Direct prior art: `PoneBiometrics/JavGar_master` runs **FROST 2-of-3 on a Nucleo-L476RG**
— same core family as the Mk4's STM32L4S5. This is the version of the claim that is simply true, and
it is not the version the thesis states.

## Steelman C — "the port is tractable on an *unlocked* STM32L4S5 board"

**Partially supported.** `embassy-stm32` has an exact `stm32l4s5vi` feature; RNG/AES/HASH/USB/SPI/I2C
all present; `NorFlash` is mechanical. This is a normal hard embedded project on the **Trezor F4→U5
scale (~7 months)** — not easy, but not blocked. It is explicitly **not what the thesis says**:
"a coldcard mk4" means the shipping, locked product.

## The threat models don't match either

Frostsnap's own design stance: no PIN, no passphrase, no per-device secure element for the coordinator
— it leverages the **phone's** secure element and relies on **threshold distribution** rather than
per-device hardening. That is close to the inverse of Coldcard's single-device-hardening philosophy
(dual SE, trick PINs, anti-phishing words, RDP2). Even a *successful* port would yield a device whose
security properties match **neither** product: Frostsnap's protocol running on hardware whose trust
anchors it cannot reach, with Coldcard's defenses bypassed rather than inherited.

## The counterfactual sane path

If the goal is a FROST signer with Coldcard-class hardware: build a **new** device on an unlocked
STM32L4/U5, reuse `frostsnap_core` + `schnorr_fun` + `frostsnap_widgets` (rewriting the color
assumptions), implement `DeviceHal` on `embassy-stm32`, and design key custody around whatever secure
element you actually solder down. That is Steelman B plus C — real work, tractable, and it produces a
device you can iterate on.

## See Also

- [Coldcard MuSig2 and FROST paths](../articles/2026-08-10-coldcard-musig2-and-frost-paths.md)
- [Embedded Rust portability limits](../articles/2026-08-10-embedded-rust-portability-limits.md)
- [Wallet firmware port precedents](2026-08-10-wallet-firmware-port-precedents.md)
