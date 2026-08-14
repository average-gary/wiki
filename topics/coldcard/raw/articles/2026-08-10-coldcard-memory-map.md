---
title: "Coldcard Memory Map"
source: "https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/memory-map.md"
type: articles
ingested: 2026-08-10
tags: [coldcard, memory-map, stm32l4, bootloader, firewall, pcrop, flash-layout, sram]
summary: "Address-space layout for the STM32L4-family MCU (1-2MB flash, 128k-512k SRAM depending on Mk2/3/4), where all memory types share one 32-bit address space. Explains that the bootloader runs first and enables hardware firewall features that reset the chip on inappropriate access, so bootloader flash cannot be read back; bootloader integrity is instead verifiable by supplying a 32-bit nonce and receiving a SHA256 of itself with that nonce as prefix, covering 0x08000000 to 0x08007800 (0x0801c000 on Mk4). Gives per-model tables: for Mk3, code at 0x08000000, the sensitive pairing-secret flash page at 0x08007800, interrupt handlers and file header at 0x08008000, 848k of main flash for the MicroPython and Coldcard C code at 0x0800c000, a 128k internal FAT 'patch' area at 0x080e0000, SRAM2 regions for MicroPython and the bootloader, a read-only page at 0x10007c00 holding the once-per-boot root seed nonce and a copy of the firmware signature, and SRAM1 at 0x20000000; plus the corresponding Mk4 layout and a section on security measures."
collection: "coldcard"
adapter: git
upstream_id: "docs/memory-map.md"
upstream_type: git-file
revision: "43b2139227149c281141d08c612afd13c434d456"
sha: "3be819d450ab0c0032d9daa71ffe101410170943"
canonical_url: "https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/memory-map.md"
content_format: markdown
license: "MIT (Coinkite Inc.)"
authors: [Coinkite Inc.]
fetched: 2026-08-10
---
# Coldcard Memory Map

## Background

The microprocess on the Coldcard is from the STM32L4 family. It comes with
one or 2 megabytes of flash, and 128k to 512k of SRAM depending on Mk2/3/4.
All types of memory share the same 32-bit address space.

The bootloader code runs first, and enables specific hardware
firewall features, which cover various parts of the address space.
The firewall will reset the chip when inappropriate access are made,
so for example, you cannot see any of the flash used by the boot loader.

If you want to verify the contents of the boot loader, you can give
it a 32-bit nonce and it will provide a SHA256 of itself with that
nonce as a prefix. That hash covers `0x0800 0000` to `0x0800 7800`
(to `0x0801 c000` for mk4).
Flash above `0x0800 8000` (Mk4: `0x0802 0000`) can be examined
directly from python programs.

## Memory Layout

(Mk3)

| Start         | Size      | Notes
|---------------|-----------|--------------------------
| 0x0800 0000   | 0x7800    | Mapped at zero briefly at boot time. Code. see `stm32/bootloader`
| 0x0800 7800   | 0x0800    | Sensitive "pairing secret" flash page (2k)
| 0x0800 8000   | 16k       | Interrupt handlers, file header (Micropython and Coldcard code)
| 0x0800 c000   | 848k      | Main flash area for Micropython / Coldcard C code.
| 0x080e 0000   | 128k      | Internal FAT filesystem (the "patch" area, for custom python)
| 0x1000 0000   | 0x6000    | SRAM2 area used by micropython code: disk caches, byte arrays, stack
| 0x1000 6000   | 0x1c00    | SRAM2 area used by boot loader
| 0x1000 7c00   | 0x0400    | Read-only. "Root seed" (once per bootup nonce), copy of firmware sig
| 0x2000 0000   | 96k       | SRAM1: heap and working SRAM for micropython

(Mk4)

| Start         | Size      | Notes
|---------------|-----------|--------------------------
| 0x0800 0000   | 112k      | Bootloader code, including reset vector. See `stm32/mk4-bootloader`
| 0x0801 c000   | 8k        | Sensitive "pairing secrets" for SE1 and SE2
| 0x0801 e000   | 8k        | MCU keys, consumable; 256 32-bit write-once slots.
| 0x0802 0000   | 16k       | Interrupt handlers, file header (Micropython and Coldcard code)
| 0x0802 4000   | (~2m)     | Main flash area for Micropython / Coldcard C code.
| 0x0818 0000   | 512k      | Internal LFS filesystem (holds settings)
| 0x2000 0000   | 640k      | SRAM1,2,3: used by micropython code: disk caches, byte arrays, stack
| 0x2009 e000   | 8k        | Top of SRAM3 reserved for bootloader


## Security Measures

- (Mk1-3) On entry the bootloader always wipes its entire working SRAM2 area. You may change
  it, or even use it for very temporary storage, but it will be destroyed once the callgate
  into the bootloader is accessed.
- (Mk4) On entry the bootloader wipes the SRAM it's allocated before and after use.
- All of SRAM is cleared on boot up, and when the "secure logout" feature is used.
- DFU firmware updates can only affect areas at and above the bootrom. Upgrade process will
  have not effect if you give a DFU file which changes another area. Built-in DFU is disabled 
  once the system leaves the factory.
- If you manage to erase the entire chip's flash (not clear that's possible), then you will
  lose the pairing secret (0x0800 7800 / 0x0800 c000) and be unable to communicate with the
  secure element(s).
- Boot up verification process does a double-SHA256 over all of flash (including the pairing
  secret area) and also a few registers that are loaded from flash cells.
  See `verify.c` in `stm32/bootloader`.


