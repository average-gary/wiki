---
title: "unattended-upgrades — pin NVIDIA driver to prevent stack breakage"
source: https://wiki.debian.org/UnattendedUpgrades
type: article
tags: [unattended-upgrades, apt-pinning, nvidia, cuda, ubuntu]
date: 2026-05-21
quality: 4
confidence: high
agent: 8
summary: "Without explicit pinning, an unattended-upgrade can bump the NVIDIA driver and break CUDA + ctranslate2 + PyTorch stack overnight. Pin nvidia-driver-535, libcuda1, cuda-* via /etc/apt/preferences.d/."
---

# Pin NVIDIA + CUDA against unattended-upgrades

## Install + reconfigure

```bash
sudo apt install unattended-upgrades
sudo dpkg-reconfigure unattended-upgrades   # accept defaults (security only)
```

Config files:
- Primary: `/etc/apt/apt.conf.d/50unattended-upgrades`
- Local override: `/etc/apt/apt.conf.d/52unattended-upgrades-local`

## Approach 1: Package blacklist in unattended-upgrades

In `/etc/apt/apt.conf.d/52unattended-upgrades-local`:

```
Unattended-Upgrade::Package-Blacklist {
    "nvidia-driver-535";
    "nvidia-driver-535-server";
    "nvidia-dkms-535";
    "libcuda1";
    "cuda-*";
};
```

## Approach 2: APT pinning (stronger)

`/etc/apt/preferences.d/nvidia`:

```
Package: nvidia-* libcuda* cuda-*
Pin: version 535.*
Pin-Priority: 1001
```

Priority 1001 means apt will REFUSE to upgrade these packages out of the 535 branch.

## Logs

`/var/log/unattended-upgrades/`. Add `apt-listchanges` for email notifications.

## Quarterly maintenance window

- Manually upgrade NVIDIA driver + CUDA together
- Test inference end-to-end (whisper RTF, pyannote DER, YOLO FPS)
- Snapshot rootfs (Btrfs/LVM) before doing so
- Roll back if anything regresses
