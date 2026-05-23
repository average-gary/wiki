---
title: "GS63VR 24/7 ops — thermals, power capping, fan control, services"
type: concept
created: 2026-05-21
updated: 2026-05-21
verified: 2026-05-21
volatility: warm
confidence: high
sources:
  - raw/repos/2026-05-21-msi-ec-gs63vr-unimplemented.md
  - raw/articles/2026-05-21-nvidia-smi-power-cap-persistence.md
  - raw/repos/2026-05-21-throttled.md
  - raw/repos/2026-05-21-nbfc-linux.md
  - raw/articles/2026-05-21-logind-conf-lid-switch.md
  - raw/articles/2026-05-21-systemd-journald-config.md
  - raw/articles/2026-05-21-unattended-upgrades-pin-nvidia.md
---

# GS63VR 24/7 operations

## CRITICAL hardware-specific finding

**GS63VR 7RF Stealth Pro is UNIMPLEMENTED in `msi-ec`** ([[ref|raw/repos/2026-05-21-msi-ec-gs63vr-unimplemented]]). EC versions `16K2ED61` / `16K2EMS1`, tracked in issues #88 and #247. This means:

- ❌ No sysfs fan control via `/sys/devices/platform/msi-ec/`
- ❌ No software battery charge limit (`charge_control_end_threshold` unavailable)
- ❌ No `shift_mode` / `cooler_boost` software toggle

Plan around this.

## Battery — fire safety first

The user mentioned the battery is "probably old/swollen." A swollen lithium battery is a **fire hazard**, not an inconvenience:

1. **Remove the battery before any 24/7 deployment.** GS63VR has internal battery — open chassis, disconnect connector from motherboard.
2. Without battery, system runs AC-only — a power blip will hard-shutdown.
3. **Add a small UPS** (CyberPower CP685AVR, APC BE600M1; ~$60) for graceful shutdown via NUT or apcupsd.

## GPU power capping

Pascal mobile thermal throttle starts ~83°C, hard cap ~92°C. GTX 1060 mobile typical TGP: 60-80W.

[[nvidia-smi power management|raw/articles/2026-05-21-nvidia-smi-power-cap-persistence]] — but **`-pm` and `-pl` do NOT persist across reboots**. Always set via systemd oneshot:

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

Conservative starting point: `-pl 65` (cap at 65 W). With cooling pad keeps steady-state under 75°C. Verify legal range first:
```bash
nvidia-smi --query-gpu=power.min_limit,power.max_limit,power.default_limit --format=csv
```

## CPU side — i7-7700HQ

[[throttled (erpalma)|raw/repos/2026-05-21-throttled]] handles PL1/PL2 + undervolt via MSR 0x150. i7-7700HQ is 7th-gen Kaby Lake → **undervolt works** (10th-gen+ are typically locked).

Conservative `/etc/throttled.conf` starting points:
- PL1=35W, PL2=45W (vs default 45W TDP — slightly relaxed for thermal headroom)
- Undervolt CPU Core / Cache: -80mV (validate over 4+ hours of mprime/prime95)
- Trip temp: 90°C
- Disable thermald: `sudo systemctl disable --now thermald`

**Plundervolt / Secure Boot caveat (CVE-2019-11157)**: Modern kernel lockdown may block MSR writes. With Secure Boot disabled (recommended for this setup) it's not an issue. Otherwise pass `lsm=capability,yama` to remove `lockdown` from LSM kernel param.

CPU governor: prefer **`schedutil`** (modern default, scales with load). Avoid `performance` (pegs i7-7700HQ at max boost continuously, generates idle heat).
```bash
sudo cpupower frequency-set -g schedutil
```

## Fan control fallback

Since msi-ec is unimplemented for GS63VR, the realistic fallback is [[nbfc-linux|raw/repos/2026-05-21-nbfc-linux]]:

```bash
sudo apt install ./debian-bookworm-nbfc-linux_0.5.2_amd64.deb
sudo nbfc update
sudo nbfc rate-config -a                        # list compatible configs
sudo nbfc config --set "MSI GS63VR ..."         # pick from list
sudo nbfc restart -r                            # read-only test mode
nbfc status
sudo nbfc restart                               # write mode
sudo systemctl enable nbfc_service
```

If no GS63VR config exists in the database: author one (format documented), or fall back to BIOS Cooler Boost button + cooling pad.

## Physical cooling

- **Cooling pad** — even basic dual-fan USB pad drops package temps 5-10°C under sustained load
- **Lid open** — even though logind ignores lid switch, lid open improves keyboard-area airflow on this thin chassis
- **Vertical orientation** ("on its side") — improves passive convection if you don't have rack space
- **Room placement** — cool, ventilated, off carpet

## logind + suspend disable

Beyond the [[lid-switch ignore|raw/articles/2026-05-21-logind-conf-lid-switch]], also mask sleep targets:
```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

## Log rotation

[[journald drop-in|raw/articles/2026-05-21-systemd-journald-config]] — `/etc/systemd/journald.conf.d/server.conf`:

```ini
[Journal]
Storage=persistent
SystemMaxUse=500M
SystemKeepFree=1G
SystemMaxFileSize=50M
MaxFileSec=1week
MaxRetentionSec=4week
```

App logs (faster-whisper-server, pyannote-server) — `/etc/logrotate.d/<svc>`:
```
/var/log/myservice.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
}
```

## Inference service template

```ini
[Unit]
Description=faster-whisper inference server
After=network-online.target nvidia-tuning.service

[Service]
Type=simple
User=ai
Group=ai
WorkingDirectory=/srv/whisper
Environment="HF_TOKEN=hf_..."
ExecStart=/srv/whisper/.venv/bin/python -m whisper_server
Restart=on-failure
RestartSec=10
StartLimitBurst=5
LogRateLimitIntervalSec=30s
LogRateLimitBurst=1000
NoNewPrivileges=yes
ProtectSystem=strict
ReadWritePaths=/srv/whisper /var/log

[Install]
WantedBy=multi-user.target
```

## Pin against unattended-upgrades

[[unattended-upgrades pin|raw/articles/2026-05-21-unattended-upgrades-pin-nvidia]] — `/etc/apt/preferences.d/nvidia`:
```
Package: nvidia-* libcuda* cuda-*
Pin: version 535.*
Pin-Priority: 1001
```

Without this, apt security upgrades can bump the driver and break ctranslate2/PyTorch overnight.

Quarterly maintenance window for explicit driver+CUDA upgrades; snapshot rootfs before; smoke-test all workloads after.

## Disk monitoring

```bash
sudo apt install smartmontools
sudo smartctl -a /dev/nvme0      # check Percentage Used and Available Spare
```

Sustained Whisper transcription writes lots of small temp files — consider mounting `/tmp` as tmpfs to spare SSD wear:
```
# /etc/fstab
tmpfs /tmp tmpfs defaults,noatime,nosuid,size=4G 0 0
```

## See also

- [[headless-ubuntu-laptop-baseline]] — initial install + SSH
- [[gpu-bench-and-smoke-tests]] — verify after applying caps
- [[pascal-driver-cuda-pinning]] — install driver before this
