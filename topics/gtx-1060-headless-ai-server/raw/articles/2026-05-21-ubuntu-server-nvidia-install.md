---
title: "Ubuntu Server Guide — Install NVIDIA Drivers"
source: https://ubuntu.com/server/docs/how-to/graphics/install-nvidia-drivers/
type: article
tags: [ubuntu-22-04, nvidia, headless, secure-boot, install-guide]
date: 2026-05-21
quality: 6
confidence: high
agent: 2
summary: "Official Ubuntu server install path: ubuntu-drivers install --gpgpu, then nvidia-utils-XXX-server. -server (ERD) variant preferred for compute. Pre-compiled signed kernel modules play nice with Secure Boot."
---

# Ubuntu Server NVIDIA Install Guide

## Key facts

- Two driver categories Ubuntu packages:
  - **UDA** (Unified Driver Architecture) — desktop/gaming
  - **ERD** (Enterprise Ready Drivers) — `-server` suffix, preferred for compute boxes
- Recommended tool: `ubuntu-drivers` — installs only **pre-built signed** drivers, Secure Boot compatible
- DKMS variants need manual MOK key enrollment

## Recommended commands (verbatim)

```bash
# Headless / compute / server box
sudo ubuntu-drivers install --gpgpu
sudo apt install nvidia-utils-535-server

# Or pin a specific version
sudo ubuntu-drivers install nvidia:535

# General desktop
sudo ubuntu-drivers install
```

## Secure Boot

> "Pre-compiled modules are signed and support Secure Boot. DKMS modules require custom key enrollment and don't support Secure Boot by default."

> "NVIDIA drivers installed from sources outside of those listed in this guide could potentially overwrite those provided by ubuntu-drivers and may break secure boot."

When using third-party drivers, Ubuntu auto-generates a Machine-Owner Key (MOK). At first reboot the MokManager UI prompts to enroll it. Manual enrollment: `sudo update-secureboot-policy --enroll-key`.

## Decision for GTX 1060 / GS63VR

```bash
sudo ubuntu-drivers install --gpgpu      # picks 535-server automatically
sudo apt install nvidia-utils-535-server
sudo systemctl enable --now nvidia-persistenced
nvidia-smi                                 # verify
```
