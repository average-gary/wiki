---
title: "nvidia-smi — power cap, persistence mode, dmon (does NOT persist across reboots)"
source: https://docs.nvidia.com/deploy/nvidia-smi/index.html
type: article
tags: [nvidia-smi, power-cap, persistence-mode, systemd, gtx-1060]
date: 2026-05-21
quality: 6
confidence: high
agent: 8
summary: "CRITICAL: -pm and -pl do NOT persist across reboots. Must re-apply via systemd oneshot at boot. GTX 1060 mobile typical default 60-80W TGP. Cap at 65-70W for 24/7 thermal headroom on GS63VR."
---

# nvidia-smi power management

## Power limit (`-pl`)

```bash
nvidia-smi --query-gpu=power.min_limit,power.max_limit,power.default_limit,power.limit --format=csv
nvidia-smi -pl 65       # cap at 65W (requires root)
```

- Integer or float watts
- Requires root
- Kepler family and newer
- Must be between min and max power limits reported by the system
- GTX 1060 mobile typical default: 60-80W TGP

## Persistence mode (`-pm`)

```bash
nvidia-smi -pm 1
```

- Driver stays loaded when idle → faster startup, more stable power management
- Default: Disabled

## CRITICAL: neither persists across reboots

> "After each reboot persistence mode defaults to Disabled."

The same applies to `-pl`. Both must be re-applied at every boot.

## systemd oneshot (correct fix)

`/etc/systemd/system/nvidia-tuning.service`:

```ini
[Unit]
Description=NVIDIA persistence and power limit
After=nvidia-persistenced.service

[Service]
Type=oneshot
ExecStart=/usr/bin/nvidia-smi -pm 1
ExecStart=/usr/bin/nvidia-smi -pl 65
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable --now nvidia-tuning.service
```

## Monitoring (`dmon`)

```bash
nvidia-smi dmon                        # default columns
nvidia-smi dmon -s p                   # power and temperature
nvidia-smi dmon -d 5                   # 5-second updates
nvidia-smi dmon -i 0                   # specific GPU
nvidia-smi dmon -c 10                  # 10 samples then exit
nvidia-smi dmon -s pucvmet -o DT       # power, util, clocks, voltage, mem, encoder, temp + date/time
```

## Recommended starting point for GS63VR thermals

```bash
nvidia-smi -pm 1
nvidia-smi -pl 65        # GTX 1060 mobile, sustained 24/7 inference
```

Pascal mobile thermal throttle starts ~83°C, hard cap ~92°C. Cap at 65W to keep steady-state under 75°C with cooling pad.
