---
title: "Netplan — static IP configuration for Ubuntu 22.04"
source: https://netplan.readthedocs.io/en/latest/using-static-ip-addresses/
type: article
tags: [netplan, networking, static-ip, ubuntu-22-04]
date: 2026-05-21
quality: 5
confidence: high
agent: 1
summary: "Canonical Netplan static-IP YAML. Apply with `netplan try` (auto-rolls back if you lose connectivity) then `netplan apply`. For LAN headless: prefer DHCP reservation on the router (survives reflash); netplan static is fallback."
---

# Netplan static IP

## YAML schema

```yaml
network:
  version: 2
  ethernets:
    enp6s0:
      dhcp4: false
      dhcp6: false
      accept-ra: false
      link-local: []
      addresses:
        - 192.168.1.50/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        search:
          - lan
        addresses:
          - 192.168.1.1
          - 1.1.1.1
```

File: `/etc/netplan/01-netcfg.yaml` (or any `.yaml` under `/etc/netplan/`).

## Apply

```bash
sudo netplan try        # auto-rolls back if connectivity is lost
sudo netplan apply
```

## For finding the box on LAN

| Approach | Pros | Cons |
|----------|------|------|
| **DHCP reservation on router** | Survives OS reflash; central management | Needs router admin |
| Static IP via netplan | No router dep | Tied to specific install |
| mDNS via avahi-daemon | `ssh user@hostname.local` works on macOS/Linux | Some Windows clients lack support |

For headless GS63VR: **DHCP reservation by MAC** + `avahi-daemon` is the no-friction combo.
