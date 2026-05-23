---
title: "logind.conf(5) — lid-switch directives + the external-power gotcha"
source: https://www.man7.org/linux/man-pages/man5/logind.conf.5.html
type: article
tags: [systemd, logind, lid-switch, headless, laptop-server]
date: 2026-05-21
quality: 5
confidence: high
agent: 1
summary: "Canonical reference for logind.conf. CRITICAL gotcha: HandleLidSwitchExternalPower is completely IGNORED by default for backwards compatibility — must be set explicitly, otherwise Ubuntu's default suspend-on-lid-close still applies on AC."
---

# logind.conf — lid-switch directives

## Verbatim

> "Controls how logind shall handle the system power, reboot and sleep keys and the lid switch to trigger actions."

## Three directives, with defaults

| Directive | Default |
|-----------|---------|
| `HandleLidSwitch` | `suspend` |
| **`HandleLidSwitchExternalPower`** | **completely ignored by default** (must be set explicitly) |
| `HandleLidSwitchDocked` | `ignore` |

Resolution order: docked → external power → otherwise plain `HandleLidSwitch`.

## Headless box recipe

`/etc/systemd/logind.conf` (under `[Login]` section):

```ini
[Login]
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
LidSwitchIgnoreInhibited=no
```

Apply:
```bash
sudo systemctl restart systemd-logind   # ends user sessions; do from console or expect SSH reconnect
# OR
sudo reboot
```

Verify:
```bash
loginctl show-logind | grep HandleLid   # all three should be 'ignore'
```

## Belt-and-suspenders (recommended)

```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

This completely disables system-wide sleep targets even if something else triggers them.

## Permitted values

`ignore`, `poweroff`, `reboot`, `halt`, `kexec`, `suspend`, `hibernate`, `hybrid-sleep`, `suspend-then-hibernate`, `sleep`, `lock`.

## Thermal note (GS63VR specific)

Even with logind ignoring lid close, **lid open is thermally better** on a thin gaming laptop — keyboard-area airflow matters under sustained load. Run lid-open-but-display-off if at all possible.
