---
title: "Developing on Coldcard (external developer access)"
source: "https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/dev-access.md"
type: articles
ingested: 2026-08-10
tags: [coldcard, development, firmware-signing, dfu, simulator, custom-firmware, corrupt-flash, key-zero]
summary: "Explains that external developers can and may build their own Coldcard firmware, and what that costs them. The 'hard core' path builds a full DFU image signed with the non-production key zero shipped in the GitHub tree and installs it via the normal microSD, USB-upload or VirtDisk routes; any Python code and even the MicroPython interpreter itself can be replaced, but the bootrom cannot be changed and still runs first. Because such a build is not signed by a factory key, a warning screen and forced delay always occur - and unlike pre-Mk4 devices, 'blessing' custom firmware to get the green light no longer avoids that delay. The main PIN must still be entered before new firmware installs, and a crash before the code runs far enough to accept a corrected image bricks the device, making bugs in the boot and login sequence fatal. Softer paths are developing against the Simulator and submitting a PR for Coinkite security review, or emailing support and waiting. Closes with the corrupt-flash case: a red light means flash changed without the secure checksum inside SE1 being updated first."
collection: "coldcard"
adapter: git
upstream_id: "docs/dev-access.md"
upstream_type: git-file
revision: "43b2139227149c281141d08c612afd13c434d456"
sha: "c0fe68648295906c88324901406d3d374c5a0aaf"
canonical_url: "https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/dev-access.md"
content_format: markdown
license: "MIT (Coinkite Inc.)"
authors: [Coinkite Inc.]
fetched: 2026-08-10
---
# Developing on COLDCARD

Yes, external developers can modify COLDCARD and make their own versions!

## Approaches

### Hard Core

- build a new image, all the way to a DFU file (see `../stm32/Makefile`)
- sign with non-production key, provided in github tree (key zero)
- install your DFU file using existing upgrade methods (microSD, usb upload, VirtDisk)
- you can replace any part of the python code, and even the mpy interpreter itself
- you cannot change the bootrom, and it still runs first
- since your code is not signed by a factory key, a warning and forced delay always occurs:

![custom warning screen](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/dev-custom.png)

- in versions before the Mk4, if you had the green light set, via blessing the custom firmware,
  this delay/warning could be avoided, but that is no longer the case.
- you can distribute your DFU file to the world, but everyone who runs it will see above warning
- remember the main PIN has to be set and provided correctly before new firmware can be installed
- your COLDCARD will be bricked if your code crashes before it gets running "enough" that you
  can upload a corrected version. Bugs in the boot & login sequence are fatal in that sense.

### Medium Core

- develop your changes using the Simulator (see `../unix`)
- submit a PR (pull request) explaining your new feature or fix.
- Coinkite team will review for security and other code-quality issues
- your PR could get merged into the next Coinkite firmware release for all to use.

### Soft Core

- send an email to support asking for your improvements to be implemented.
- await reply patiently.

## Corrupt Flash

If the red/green light is red, this means some part of flash was
changed without the secure checksum inside SE1 being first updated.
The upgrade process does this correctly in Mk4, and there is no
point in time the checksum is wrong, so there should be no way to see this
screen:

![warning screen](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/dev-warning.png)

But it will be shown if the COLDCARD finds its flash checksum does
not match the checksum held in SE1, secured by the main PIN. This
can be false positive, but in Mk4 we've worked hard to avoid those cases.

A checksum error on the firmware itself (the main code) will always
fail with a "(lemon icon) Firmware?" screen. The broken firmware is not
started, but it's possible to recover the COLDCARD using a firmware loaded
from an SD Card.

You cannot load *new* code via the SD Card firmware recovery mode.
It requires the new firmware (based on whatever is found on SD Card)
to have a checksum that already matches the value found in SE1.
This means only the signed firmware that was attempting to be
installed during the power-fail can be loaded, and not new code you
may have written.


## Shortcuts and Accelerations

- You can access a micropython REPL if you are willing to break your case
  and attach to the test points along right edge of board, marked: G=Gnd, R=Rx, T=Tx.
  It's a serial port with 3.3v TTL signals running
  at 115,200 bps. Enter the REPL by pressing `^C` after enabling the REPL in
  Advanced > Danger Zone > I Am Developer. > Serial REPL

- To skip the prompts for the PIN, assuming correct PIN is '12-12'... run this code
  in the REPL:

```python
from nvstore import SettingsObject
s=SettingsObject()
s.set('_skip_pin', '12-12')
s.save()
```

---

## Ingest note

Repository-relative links in the body above were repointed to absolute GitHub URLs pinned to `43b2139`. Link text and all prose are unchanged; only the destinations were rewritten, since repo-relative paths do not resolve inside the wiki.
