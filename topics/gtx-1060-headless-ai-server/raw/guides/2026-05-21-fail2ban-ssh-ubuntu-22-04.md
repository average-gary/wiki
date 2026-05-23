---
title: "How To Protect SSH with Fail2Ban on Ubuntu 22.04"
source: https://www.digitalocean.com/community/tutorials/how-to-protect-ssh-with-fail2ban-on-ubuntu-22-04
type: guide
tags: [ssh, fail2ban, ubuntu-22-04, hardening]
date: 2026-05-21
quality: 4
confidence: medium
agent: 1
summary: "Canonical fail2ban-on-22.04 walkthrough. Don't edit jail.conf directly — copy to jail.local. Defaults: bantime=10m, findtime=10m, maxretry=5. Verify with iptables -S | grep f2b."
---

# fail2ban for SSH on Ubuntu 22.04

## Install

```bash
sudo apt update
sudo apt install fail2ban
```

Service installs but is **disabled by default** until enabled.

## Configure

> "YOU SHOULD NOT MODIFY [jail.conf]" — copy to a local override:

```bash
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local
```

Defaults under `[DEFAULT]`:
- `bantime = 10m`
- `findtime = 10m`
- `maxretry = 5`

Five failed logins in 10 minutes → 10-minute ban.

## Enable SSH jail explicitly

```ini
[sshd]
enabled = true
```

(SSH is enabled by default in modern fail2ban shipped with 22.04, but explicit > implicit.)

## Apply

```bash
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
sudo systemctl status fail2ban
```

## Verify active filtering

```bash
sudo iptables -S | grep f2b   # should show f2b chains
```

Test from a separate machine: attempt repeated failed SSH logins. Errors should shift from "Permission denied" to "Connection refused" once banned.
