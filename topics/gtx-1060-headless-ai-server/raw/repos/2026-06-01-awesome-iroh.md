---
title: "awesome-iroh — curated list of shipping iroh apps"
source: https://github.com/n0-computer/awesome-iroh
type: repo
tags: [iroh, ecosystem, apps, ssh, qr-pairing, file-transfer]
date: 2026-06-01
quality: 4
confidence: high
agent: 3
summary: "Authoritative roster of who's actually shipping on iroh, organized by category. SSH-over-iroh: iroh-ssh, do-ssh, Datum. File transfer: Sendme, ARK Drop, DataBeam, Quicksend, Strada, Alt-sendme. QR-pairing apps: ARK Drop Desktop and DataBeam ship QR-code device pairing UX as a named feature."
---

# awesome-iroh — the ecosystem map

Where to look for prior art when building any iroh application pattern.

## Categories

### Chat
- Delta Chat (peer channels backed by iroh)
- Dash Chat
- Weird

### File transfer (resumable + content-addressed)
- **Sendme** — n0 first-party CLI for ad-hoc file transfer
- **ARK Drop** (Desktop) — file transfer with QR-pairing
- **DataBeam** — multi-device file transfer with QR-pairing
- Quicksend
- Strada
- Alt-sendme

### Networking / devtools
- **Dumbpipe** — netcat-over-iroh (the primitive most others sit on)
- **iroh-ssh** — community SSH-over-iroh
- **do-ssh** — alternative SSH-over-iroh
- **Datum** — "expose local services to the internet" (closest analog to homelab tunnel)
- **Malai** — share dev server / SSH / TCP over P2P (HN: 2025-04-30)
- **pai-sho**

### Games
- Fish Folk Jumpy
- Bones engine
- Godot Iroh integration

### Collaboration
- Teamtype
- biter

### Production / enterprise
- **Fedimint** — federated chaumian e-cash (uses iroh as p2p transport)
- **Paycode** — payment terminals at Mexican toll booths (case study at [[2026-06-01-iroh-paycode-case-study]])

### Other
- Obsiroh (Obsidian sync)
- Pigg

## Why this matters

1. **Multiple independent SSH-over-iroh projects** (iroh-ssh, do-ssh, Datum, Malai) confirm pattern is real, not theoretical
2. **QR-pairing UX** ships in real apps (ARK Drop, DataBeam) — examples to study before designing pairing flow
3. **Datum is the closest analog** to a homelab "expose my AI server" use case — worth a deeper look

## See also

- [[2026-06-01-iroh-paycode-case-study]] — production iroh deployment with QR pairing
- [[2026-06-01-iroh-secure-video-everywhere-blog]] — iroh + MoQ + camera demo
