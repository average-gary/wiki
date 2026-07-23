---
title: "Vendor Landscape — Ortho Implant Manufacturing Automation"
type: reference
created: 2026-07-22
updated: 2026-07-22
tags: [vendor-landscape, cmo, machine-tools, robotic-finishing, additive-oem, metrology, market]
confidence: high
---

# Vendor Landscape

Who to buy from, organized by station. Synthesized from the
[CMO/vendor source](../raw/repos/2026-07-22-cmo-vendor-landscape-market.md),
[serial-AM cases](../raw/repos/2026-07-22-serial-am-oem-cases-stryker-lima-orchid.md), and the
[lights-out cell](../raw/repos/2026-07-22-flexxbotics-mach-medical-lights-out-cell.md).

## Contract manufacturers (CMOs)

The consolidated pure-play landscape (outsourcing is the market's primary driver):

- **Tecomet** (merged with **Orchid**, May 2026) — 24 sites; forging, casting, machining,
  photochemical etching, finishing, AM, bone-ingrowth coatings, sterile packaging. The
  dominant scaled platform.
- **Paragon Medical** (Marmon / Berkshire Hathaway), **Viant**, **Integer Holdings**,
  **ARCH Medical Solutions**, **Autocam Medical**, **Avalign Technologies**, **CRETEX
  Medical**, **LISI Medical**, **Norman Noble**.

## Machine-tool builders (5-axis / Swiss / automation)

- **DMG MORI** — DMU 60 eVo 5-axis (CoCr knee at 40k rpm, Ra 0.8→0.3 µm); MATRIS / PH-Cell /
  AMR automation.
- **Willemin-Macodel** — Series 30–80 (hip/plate/screw/cage/knee/dental); robots + cobots.
- **Tornos** — SwissDECO / EvoDECO / SwissNano (Ti/PEEK/CoCr/SS); RoboBar.
- **Star**, **Citizen Cincom** — Swiss-type lathes (bone screws).
- **Matsuura** — MAM72 (72 h unmanned, up to 32-pallet towers, 330–530-tool magazines).
- **Mazak** — multi-tasking / mill-turn.

## Robotic finishing integrators

- **Acme Manufacturing** — FANUC authorized integrator; **>150 turnkey robotic finishing
  systems installed for orthopedics** (most of any vendor); programmable force compliance;
  knee/hip/plate/acetabular/spine; CoCr/zirconium/Ti in cast/forged/MIM/machined.
- **AV&R** — 75% cycle-time cut, ±15 µm removal consistency.
- **PushCorp** — active-force-control end-effectors.
- Mass-finishing / electropolish: **DLyte** (dry electropolishing), **Rösler** (drag
  finishing), **OTEC** (stream finishing).

## Metal-AM OEMs

- **EOS** (500+ M290 medical systems; Ti64 ELI + CoCr; EOSTATE Exposure OT + Smart Fusion).
- **Nikon SLM**, **GE Additive / Arcam (Colibrium)** (EBM — Spectra L), **Renishaw**,
  **3D Systems**, **AddUp** (FormUp 350).
- Powder + handling: **AP&C** powders + **Powder Recovery Station (PRS 30)**.

## Automation / cell orchestration

- **Flexxbotics** (FlexxCORE — connects robot + heterogeneous CNC + IT; closed-loop CMM→CNC).
- **Universal Robots** (cobot machine-tending), **FANUC**, **ABB** (6-axis plasma-spray
  coating), **Okuma** (5-axis in the lights-out cell).

## Metrology

- **Zeiss** — CMM with ShuttleLoad / MultiLoad automated part loading; industrial CT.
- **VisionGauge** — optical GD&T.

## Serial-AM production references (who's actually doing it)

- **Stryker** — AMagine / Tritanium (300k+ devices/10 yr; Cork, Ireland).
- **Lima / Enovis** — Trabecular Titanium via 15 Arcam EBM machines (~100k patients).
- **Orchid** — Arcam Spectra L fleet (stackable EB-LPB).
- **restor3d** — custom-at-scale (Durham NC).

## See also

- [Build Playbook](build-playbook.md)
- [Economics & Line Architecture](../concepts/economics-and-line-architecture.md)
- [Forming Routes](../concepts/forming-routes-machining-am-forging-casting.md)
- [Finishing & Coating Automation](../concepts/finishing-and-coating-automation.md)
