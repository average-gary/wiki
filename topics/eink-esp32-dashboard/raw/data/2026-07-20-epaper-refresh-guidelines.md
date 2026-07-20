---
title: "E-paper refresh guidelines — Waveshare & Good Display (180s, ghosting, temperature)"
source: https://docs.waveshare.com/4.26inch_e-Paper_G/FAQ
type: data
tags: [e-paper, refresh, ghosting, partial-refresh, full-refresh, lifespan, temperature, manufacturer]
date: 2026-07-20
quality: 5
confidence: high
summary: "Manufacturer refresh rules from Waveshare + Good Display FAQs: minimum ~180s between updates to protect panel lifetime; full clear after every 5 partial refreshes (and >=1 full/24h for color); color panels cannot operate sub-zero; put panel to sleep after refresh or risk irreversible damage; e-paper holds image at zero power."
---

# E-paper refresh guidelines (Waveshare + Good Display)

Hard manufacturer numbers the dashboard must respect. Corroborated across two independent manufacturer FAQs.

- **Minimum refresh interval ≥ 180 seconds** between updates to protect panel lifetime — don't refresh faster than ~3 min on many panels.
- Full refresh **flashes multiple times**; partial refresh has no flashing.
- **Full clear after every 5 partial refreshes** — otherwise ghosting worsens and "may even damage the screen." For multi/full-color panels: **≥1 full refresh every 24 hours** regardless.
- After each refresh, put the panel into **sleep mode or power it off** — leaving a panel powered/energized continuously can cause **irreversible screen damage**.
- **Multi-color e-paper cannot operate sub-zero (<0°C)**; below 0°C requires wide-temperature B/W panels only (heating film can extend range). Operating range 0–50°C, humidity 35–65% RH.
- **Bistable**: holds a static image with **zero power** indefinitely — the core reason e-paper suits slow dashboards (no draw between refreshes; mid-cycle power loss leaves last frame intact).
