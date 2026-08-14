---
title: "Reproducible builds and developer access"
category: concept
sources:
  - raw/articles/2026-08-10-coldcard-notes-on-repro.md
  - raw/articles/2026-08-10-coldcard-dev-access.md
  - raw/articles/2026-08-10-coldcard-firmware-readme.md
  - raw/articles/2026-08-10-coldcard-release-history-mk3.md
created: 2026-08-10
updated: 2026-08-10
tags: [coldcard, reproducible-builds, docker, supply-chain, signit, key-zero, simulator, repl, licensing]
aliases: ["make repro", "check-repro", "key zero", "Coldcard simulator"]
confidence: high
volatility: cold
verified: 2026-08-10
summary: "`make repro` rebuilds the firmware in Docker, downloads the published release from coldcard.com, and diffs hexdumps with the 64-byte signature blanked out to prove a bit-for-bit match. Developer access is real but costly: build with the public key zero, accept a permanent warning and forced delay, and know that a crash in the boot or login path bricks the device. Covers signit, the corrupt-flash red light, the serial REPL, and the licensing split."
---

# Reproducible builds and developer access

> Two claims that would be marketing anywhere else are, here, mechanised: **you can rebuild the exact
> bytes running on your device**, and **you can run your own code on it**. The first is verified by a
> makefile target; the second costs you a permanent warning screen and the risk of bricking.

Reproducible builds arrived in **4.0.0** (Mk3), alongside the licence change from GPL to MIT + CC.

## How `make repro` proves it

The entrypoint is `stm32/shared.mk`:

```makefile
repro: submods-match code-committed
repro:
	docker build -t coldcard-build - < dockerfile.build
	(cd ..; docker run $(DOCK_RUN_ARGS) sh src/stm32/repro-build.sh $(VERSION_STRING) $(HW_MODEL) $(PARENT_MKFILE))
```

Two prerequisites do real work before anything builds: **`submods-match`** (submodules at the expected
commits) and **`code-committed`** (clean working tree). Without those a "reproducible" build proves
nothing about the source you think you are building. `$(HW_MODEL)` is `mk4` or `q1`;
`$(PARENT_MKFILE)` is `MK-Makefile` or `Q1-Makefile`.

Inside Docker:

1. `mkdir /tmp/checkout` and **mount a tmpfs** over it — the build workspace never touches disk.
2. `git clone /work/src/.git firmware`, then `git submodule update --init` under `external/`.
3. Install **`signit`** (the in-tree signing/inspection tool, `cli/signit.py`).
4. Look up the release filename in `signatures.txt`, then **`wget` the official DFU from
   coldcard.com** — e.g. `2022-10-05T1724-v5.0.7-mk4-coldcard.dfu`.
5. `make -f MK-Makefile setup`, then build `firmware-signed.bin`, `firmware-signed.dfu`,
   `production.bin`, `dev.dfu`, `firmware.lss`, `firmware.elf`.
6. `rsync` the artifacts back to `/work/built`.
7. Run `check-repro` against the downloaded binary.

Note step 4: the comparison target is fetched **from Coinkite's own server, inside the container**.
That is the right design — the thing you want to check is the binary the vendor actually ships — but it
does mean the verification depends on coldcard.com serving the genuine file at that moment. The
`signatures.txt` lookup and the ECDSA check are what constrain that.

## `check-repro`, and why a plain checksum will not do

```makefile
check-repro: TRIM_SIG = sed -e 's/^00003f[89abcdef]0 .*/(firmware signature here)/'
check-repro: firmware-signed.bin
	$(SIGNIT) split $(PUBLISHED_BIN) check-fw.bin check-bootrom.bin
	$(SIGNIT) check check-fw.bin
	$(SIGNIT) check firmware-signed.bin
	hexdump -C firmware-signed.bin | $(TRIM_SIG) > repro-got.txt
	hexdump -C check-fw.bin        | $(TRIM_SIG) > repro-want.txt
	diff repro-got.txt repro-want.txt
```

The key insight the docs spell out: **an identical checksum is impossible as-is**, because signature
data is embedded in the binary and your build cannot produce Coinkite's signature. So:

- `signit split` separates the DFU into **main firmware** and **bootloader** (`start 293 for 870400
  bytes: Firmware`, `start 870701 for 114688 bytes: Bootrom`).
- `signit check` validates each one's ECDSA signature — against the factory key for the release, or
  against the public **debug key zero** for your own build.
- `TRIM_SIG` blanks the **64 bytes** of signature in both hexdumps, substituting a common string.
- `diff` compares. Everything else must match exactly.

A `signit check` header for v5.0.7 shows what is being compared:

```
     magic_value: 0xcc001234
       timestamp: 2022-10-05 17:24:55 UTC
  version_string: 5.0.7
      pubkey_num: 1
 firmware_length: 870400
       hw_compat: 0x8 => Mk4
 ECDSA Signature: CORRECT
```

`pubkey_num: 1` for the release versus `pubkey_num: 0` for the local build is exactly the expected
difference — and the build log says so out loud: `You don't have that key (1), so using key zero
instead!` Note the timestamps differ too (2022-10-05 vs 2022-10-24) yet the diff still succeeds, which
tells you the timestamp lives inside the trimmed header region rather than the compared body.

Success prints: *"You have built a bit-for-bit identical copy of Coldcard firmware for v5.0.7"*.

## Running your own code

The dev-access doc opens with "Yes, external developers can modify COLDCARD and make their own
versions!" — and then lists the price honestly.

### Hard core

- Build a full DFU (`stm32/Makefile`) and sign with **key zero**, the non-production key shipped in the
  GitHub tree.
- Install by the normal routes: microSD, USB upload, VirtDisk.
- You can replace **any Python code, and the MicroPython interpreter itself**.
- You **cannot change the bootrom**, and it still runs first.
- Because it is not factory-signed, **a warning screen and forced delay always occur**. On pre-Mk4
  devices "blessing" custom firmware to get the green light avoided that delay; **on Mk4 it no longer
  does**.
- You may distribute your DFU freely — everyone who runs it sees the same warning.
- **The main PIN must still be entered** before new firmware installs.
- **Bugs in the boot and login sequence are fatal**: if your code crashes before it runs far enough to
  accept a corrected image, the device is bricked.

That last point is the real barrier. Firmware freedom is genuine, and the cost of a mistake is the
hardware.

### Medium core

Develop against the **Simulator** (`unix/`), submit a PR, Coinkite reviews for security and code
quality, and it may ship in a release. The changelogs credit outside contributors by handle
(`thanks to @craigraw` for the ≤71-byte nonce grinding in 4.1.2, `thanks to @Damir` for the legacy
input amount spoofing fix in 5.5.1), so this path demonstrably works.

### Soft core

Email support and wait.

## Corrupt flash: what the red light means

A **red** light means part of flash changed **without the secure checksum inside SE1 being updated
first**. The Mk4 upgrade process always updates the checksum before touching flash, so there is no
point at which the checksum is legitimately wrong — the screen should be unreachable. False positives
are possible; Coinkite says it worked hard on Mk4 to avoid them.

A checksum error on the **main firmware** shows a "**Firmware?**" screen with a lemon icon. The broken
firmware does not start, and recovery from SD card is possible — but with a constraint that also
closes a developer shortcut: **the SD-card firmware must already match the checksum in SE1**, so you
can only load the signed image that was mid-install during a power failure, **not new code you wrote**.
See [[firmware-authenticity-and-upgrades|Firmware authenticity and upgrades]]
([Firmware authenticity and upgrades](firmware-authenticity-and-upgrades.md)).

## The serial REPL

Documented, and requiring physical damage by design:

- **Break the case** and attach to the test points along the right edge of the board: `G` = Gnd,
  `R` = Rx, `T` = Tx.
- 3.3V TTL serial at **115,200 bps**.
- Enable at `Advanced > Danger Zone > I Am Developer. > Serial REPL`, then press `^C`.

The documented PIN-skip shortcut, which is only sane on a development unit:

```python
from nvstore import SettingsObject
s = SettingsObject()
s.set('_skip_pin', '12-12')
s.save()
```

## Licensing

The repository moved from **GPL to MIT + CC** in **4.0.0**. Firmware source is MIT (Coinkite Inc.).
The `hardware/` directory is different and the distinction is not cosmetic: it is **proprietary**,
published for research and testing only, and the notice states it does *"NOT grant license of this
information for comercial use"* [sic]. Reproducible builds and PRs are fully open; replicating the
hardware commercially is not licensed.

## Evidence status

`confidence: high`. This is the best-evidenced article in the topic: the makefile rules, the Docker log
transcript and the `signit` output are mechanical artifacts rather than claims, and the whole procedure
is designed to be run by a third party — which is the definition of verifiable. The `signit` line
numbers cited upstream (`cli/signit.py:153-175` for `split`, `176-243` for `check`) refer to files not
ingested here, so those specific references are unchecked. Nothing here demonstrates that a repro build
of a *current* release succeeds; the transcript is for v5.0.7.

## See Also

- [[firmware-authenticity-and-upgrades|Firmware authenticity and upgrades]] ([Firmware authenticity and upgrades](firmware-authenticity-and-upgrades.md)) — the world checksum, the genuine light, and why SD recovery cannot load new code
- [[security-architecture|Security architecture]] ([Security architecture](../topics/security-architecture.md)) — published key zero and the never-upgradable bootloader as stated limits
- [[coldcard-overview|COLDCARD — overview]] ([COLDCARD — overview](../topics/coldcard-overview.md)) — evidence status and the licensing split
- [[memory-map-and-key-slots|Memory map and key slots]] ([Memory map and key slots](../references/memory-map-and-key-slots.md)) — firmware and bootloader regions the DFU split corresponds to
- [[release-timeline|Release timeline]] ([Release timeline](../references/release-timeline.md)) — 4.0.0 repro builds and the licence change
- [[connectivity-and-nfc|Connectivity and NFC]] ([Connectivity and NFC](connectivity-and-nfc.md)) — the UART test points among the device's physical interfaces
- frostsnap wiki: [Custom firmware on locked devices](../../../frostsnap/wiki/concepts/custom-firmware-on-locked-devices.md) — the enforcement path read from `mk4-bootloader` C source: the 25-second key-zero penalty quantified, DFU fused off at RDP2, and the dated commit (`58edd613`, 2022-01-26) that removed the pre-Mk4 bless-and-ship path
- frostsnap wiki: [Wallet firmware port outcomes](../../../frostsnap/wiki/references/wallet-firmware-port-outcomes.md) — why no third-party firmware exists for any hardware wallet in this class

## Sources

- [Notes on reproducible builds](../../raw/articles/2026-08-10-coldcard-notes-on-repro.md) — the `repro` and `check-repro` makefile rules, Docker transcript, `signit split`/`check` output, `TRIM_SIG`
- [Developer access](../../raw/articles/2026-08-10-coldcard-dev-access.md) — key zero, the permanent warning and delay, brick risk, corrupt-flash red light, serial REPL and `_skip_pin`
- [Firmware README](../../raw/articles/2026-08-10-coldcard-firmware-readme.md) — MIT licensing and the proprietary `hardware/` carve-out
- [Mk3 release history](../../raw/articles/2026-08-10-coldcard-release-history-mk3.md) — 4.0.0 repro builds and the GPL → MIT+CC change; contributor credits
