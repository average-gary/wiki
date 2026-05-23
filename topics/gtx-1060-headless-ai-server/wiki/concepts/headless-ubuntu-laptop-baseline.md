---
title: "Headless Ubuntu 22.04 baseline for an MSI GS63VR"
type: concept
created: 2026-05-21
updated: 2026-05-21
verified: 2026-05-21
volatility: cold
confidence: high
sources:
  - raw/repos/2026-05-21-msi-gs63vr-config.md
  - raw/articles/2026-05-21-netplan-static-ip.md
  - raw/articles/2026-05-21-logind-conf-lid-switch.md
  - raw/guides/2026-05-21-fail2ban-ssh-ubuntu-22-04.md
---

# Headless Ubuntu 22.04 on MSI GS63VR

## TL;DR

Install **Ubuntu Server 22.04 LTS** (NOT desktop minimal). BIOS: disable Secure Boot, set Primary Display = IGFX, AHCI mode (default on this chassis). Network: ethernet only (Killer Wi-Fi ath10k_pci has known firmware issues on Linux). SSH: key-only auth + ufw + fail2ban. Lid-close: ignore via logind.conf — but **run with lid open** for thermal headroom on a thin gaming laptop.

## Why Server, not Desktop Minimal

- No GUI, no display manager → nothing to disable later
- Live-server installer has an "Install OpenSSH server" tickbox → day-1 SSH availability
- "Desktop minimal" still ships gdm3/gnome-shell that you'd just have to turn off

## BIOS settings on GS63VR

From [[m3c4j/msi-gs63vr-config|raw/repos/2026-05-21-msi-gs63vr-config]]:

| Setting | Value | Why |
|---------|-------|-----|
| Secure Boot | Disabled | Avoids signing dance later for proprietary NVIDIA driver if you switch off ubuntu-drivers; also unblocks throttled MSR writes |
| Primary Display | **IGFX** | Boot framebuffer drives via Intel HD 630; GTX 1060 visible only to CUDA |
| SATA Mode | AHCI | Default on GS63VR — unlike newer Intel laptops with VMD/RAID-On that need flipping |
| Wake on LAN | Enabled | Lets you wake the box remotely after `systemctl poweroff` |

GS63VR firmware has **no true mux switch** for muxless Optimus — Pascal mobile is Optimus-only. Setting Primary Display = IGFX is the closest you can get.

## Network: ethernet only

- **Killer E2400 Gigabit Ethernet** — works out of the box on 22.04 (`alx`/`atl1c` driver)
- **Killer 1535 Wi-Fi** (Atheros QCA6174 / `ath10k_pci`) — known firmware-crash and disconnect issues on Linux. **Don't trust it for 24/7 server.**

Static IP via [[netplan|raw/articles/2026-05-21-netplan-static-ip]] OR DHCP reservation on router by MAC. The DHCP reservation approach survives a reflash and is the lower-friction option.

For LAN discovery: `sudo apt install avahi-daemon` → `ssh user@gs63vr.local` works from macOS/Linux clients.

## Lid-close handling

Edit `/etc/systemd/logind.conf` ([[ref|raw/articles/2026-05-21-logind-conf-lid-switch]]):

```ini
[Login]
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
LidSwitchIgnoreInhibited=no
```

**Critical gotcha**: `HandleLidSwitchExternalPower` is "completely ignored by default for backwards compatibility." If you only set `HandleLidSwitch`, the suspend-on-lid still triggers when on AC.

Belt-and-suspenders:
```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

**Thermal note**: even with logind ignoring lid close, **run with lid open** on the GS63VR. Lid-closed reduces keyboard-area airflow and pushes the i7-7700HQ closer to throttle under sustained load. See [[gpu-thermals-and-ops]].

## SSH hardening (LAN-only box)

`/etc/ssh/sshd_config`:

```
PasswordAuthentication no
PermitEmptyPasswords no
PubkeyAuthentication yes
PermitRootLogin no
MaxAuthTries 3
LoginGraceTime 30
X11Forwarding no
AllowTcpForwarding no
ClientAliveInterval 300
ClientAliveCountMax 2
```

Validate before reload: `sudo sshd -t && sudo systemctl reload ssh`.

UFW:
```bash
sudo ufw default deny incoming
sudo ufw allow 22/tcp
sudo ufw enable
```

fail2ban: copy `/etc/fail2ban/jail.conf` → `jail.local`, set `[sshd] enabled = true`, restart. Defaults of `bantime=10m / findtime=10m / maxretry=5` are fine for LAN. ([[fail2ban guide|raw/guides/2026-05-21-fail2ban-ssh-ubuntu-22-04]])

For LAN-only: changing port 22 → custom is mostly noise. Skip port-knocking / 2FA unless your threat model demands it.

## Wake-on-LAN

```bash
sudo ethtool -s eno1 wol g     # one-shot
ethtool eno1 | grep Wake-on    # verify "Wake-on: g"
```

Persist via systemd-networkd `[Link] WakeOnLan=magic`, or NetworkManager `nmcli connection modify <name> 802-3-ethernet.wake-on-lan magic`, or a systemd oneshot.

Wake from another LAN host: `wakeonlan <MAC>`.

## See also

- [[pascal-driver-cuda-pinning]] — install NVIDIA driver next
- [[gpu-thermals-and-ops]] — 24/7 thermal/power tuning
- [[gpu-bench-and-smoke-tests]] — verify the install
