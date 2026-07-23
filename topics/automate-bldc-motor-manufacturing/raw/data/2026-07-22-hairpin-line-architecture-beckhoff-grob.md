---
title: "GROB Hairpin Stator Line — Flexible Transport Architecture (Beckhoff)"
source: https://www.blog.beckhoffus.com/post/electric-vehicle-motor-manufacturing
source_2: https://www.beckhoff.com/en-en/company/news/flexible-control-technology-with-fast-cycle-times-increases-efficiency-in-hairpin-stator-production-lines.html
type: data
tags: [line-architecture, takt-time, flexible-transport, xts, hairpin, ev-traction]
credibility: high
confidence: high
retrieved: 2026-07-22
summary: Best concrete real-numbers example of modern EV traction-motor line architecture and the shift to software-defined flexible transport.
---

# GROB Hairpin Stator Line Architecture (Beckhoff)

- **Cycle time 2.3 s per hairpin**; each stator needs **~200 hairpins in ~50 different designs** — takt is set at the sub-component level, not the finished motor.
- Motion: **57 NC axes** (40 real, 5 virtual, 12 XTS movers), 4 GROB spindles, 270 DI / 150 DO, **4 ms PLC cycle**.
- Uses **Beckhoff XTS linear transport** (oval 3 m track, 12 independently-controlled movers) rather than fixed rotary indexing — enables flexible positioning at bending/camera stations and just-in-time parameter recalculation per hairpin design.
- Inline error detection with automated rework; single line accommodates **50 variants without hard retooling** — concrete example of flexible/reconfigurable transport (independent-mover) vs rotary indexing.
- Process steps: wire supply, on-the-fly copper stripping, feed, inspection, press-fit/cut, 2D + 3D bending, pre-insertion. GROB = global market leader in hairpin traction-motor tech.
