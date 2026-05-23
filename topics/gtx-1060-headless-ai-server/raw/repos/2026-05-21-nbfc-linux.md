---
title: "nbfc-linux — NoteBook FanControl (C port)"
source: https://github.com/nbfc-linux/nbfc-linux
type: repo
tags: [fan-control, msi, laptop-server, nbfc, ec, headless]
date: 2026-05-21
quality: 4
confidence: medium
agent: 8
summary: "C port of NoteBook FanControl — automatic and manual fan control via 312 JSON model configs. Pre-allocates memory + OOM-killer protection (good for 24/7 daemon). Verify GS63VR config exists in compatibility DB before relying on it."
---

# nbfc-linux

## Why this matters for GS63VR

Since [[msi-ec]] does not support the GS63VR, `nbfc-linux` is the realistic primary fallback for fan control.

## Setup

```bash
# Arch
sudo pacman -U arch-linux-nbfc-linux-git-0.4.1-x86_64.pkg.tar.zst
# Debian/Ubuntu
sudo apt install ./debian-bookworm-nbfc-linux_0.5.2_amd64.deb

sudo nbfc update                                   # download latest configs
sudo nbfc config --set auto                        # auto-detect
# OR if auto fails:
sudo nbfc rate-config -a                           # list compatible configs
sudo nbfc config --set "MSI GS63VR ..."            # manually pick

sudo nbfc restart -r                               # read-only test mode
nbfc status                                        # show fan speeds
sudo nbfc restart                                  # write mode (real control)
sudo systemctl enable nbfc_service                 # start at boot
```

## Manual / auto control

```bash
nbfc set -s 60                                     # 60% fan
nbfc set --auto                                    # back to auto
```

## Custom sensors (since 0.3.16)

```bash
nbfc sensors list
sudo nbfc sensors set -f <FAN_INDEX> -s <SENSOR> -a <Average|Min|Max>
```

## Why it's safe for 24/7

> "explicitly protects from OOM killer and pre-allocates memory at startup so the daemon cannot run out of memory during runtime"

- EC backend prefers `ec_sys` kernel module, falls back to `/dev/port` or `acpi_ec`
- Service: `nbfc_service.service`
- Config: `/etc/nbfc/nbfc.json`
- 312 JSON model configs maintained
- **Verify GS63VR config exists in the online compatibility DB before relying on it.** If absent, you can author one (the format is documented), or use BIOS Cooler Boost + cooling pad.
