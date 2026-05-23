---
title: "systemd journald — log retention for a 24/7 server"
source: https://manpages.debian.org/bookworm/systemd/journald.conf.5.en.html
type: article
tags: [systemd, journald, log-rotation, 24-7-server]
date: 2026-05-21
quality: 5
confidence: high
agent: 8
summary: "Defaults: 10% of FS up to 4GB. Recommended for small server: SystemMaxUse=500M, MaxRetentionSec=4week, Storage=persistent. Prevents log growth from filling the SSD over months."
---

# journald.conf for a small 24/7 server

## Recommended drop-in: `/etc/systemd/journald.conf.d/server.conf`

```ini
[Journal]
Storage=persistent
SystemMaxUse=500M
SystemKeepFree=1G
SystemMaxFileSize=50M
MaxFileSec=1week
MaxRetentionSec=4week
```

## Why these values

| Directive | Default | Recommended | Reason |
|-----------|---------|-------------|--------|
| `Storage` | `auto` | `persistent` | Logs survive reboots — useful for postmortem on a 24/7 box |
| `SystemMaxUse` | 10% of FS up to 4GB | 500M | Bound disk growth |
| `SystemKeepFree` | 15% of FS | 1G | Always leave headroom |
| `SystemMaxFileSize` | 1/8 of MaxUse, capped 128MB | 50M | Smaller files rotate faster |
| `MaxFileSec` | 1 month | 1 week | Easier postmortem windowing |
| `MaxRetentionSec` | 0 (disabled) | 4 weeks | Hard ceiling on retention |

## Apply

```bash
sudo systemctl restart systemd-journald
```

## For application logs (faster-whisper, pyannote workers)

Use `/etc/logrotate.d/<service>`:

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

`copytruncate` is the safest option when the worker doesn't reopen on SIGHUP.
