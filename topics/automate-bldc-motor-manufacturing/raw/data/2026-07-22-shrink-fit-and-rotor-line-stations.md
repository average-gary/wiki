---
title: "Stator Shrink-Fit & BLDC Rotor Assembly Line Stations (Induction-Heat + Honest)"
source: https://www.induction-heat.com/product/stator-heating-and-fitting-into-housing/
source_2: https://www.honest-hls.com/bldc-rotor-magnet-insert-machine
type: data
tags: [shrink-fit, induction-heating, press-fit, rotor-line, cycle-time, error-proofing]
credibility: medium
confidence: high
retrieved: 2026-07-22
summary: Physics + control of the stator-into-housing shrink-fit station, plus a full automated rotor line sequence with real cycle-time/yield numbers.
---

# Shrink-Fit & Rotor Assembly Line Stations

**Stator-into-housing shrink-fit (Induction-Heat):**
- **Induction heating** thermally expands the housing so the stator drops in with an interference fit; ~5 heating segments allow a tailored temperature profile.
- **Closed-loop PID** with infrared thermometers (±1%), heating resolution 0.1 s — needed because the thermal window before the housing re-shrinks is short.
- Output 10–50 kHz, 4–60 kVA. Workflow: manual load → **auto heat + auto press** → manual unload; automatic press removes insertion-force variability.
- Cooling water 20–40 L/min at 0.1–0.3 MPa; parameters stored for traceability. Line integration via RS-485, Profibus, CAN.

**BLDC rotor magnet assembly line (Honest):**
- **Station sequence**: core loading → core-and-shaft **press-fit** → magnet loading + assembly → steel sleeve + end-cap → **laser welding** → **magnetization + flux detection** → air-tightness test → unloading → tray stacking.
- **Cycle time 15 s/pc**, yield ≥98%, utilization 98%; 40 kW, air 0.4–0.6 MPa; PLC + HMI.
- **Error-proofing**: sensors + vision catch omissions/under-installs/mis-installs; interlocks, profiling jigs, guiding mechanisms.
- **Independent stations**: if one fails, the line skips to the next process to keep running. Confirms magnets inserted un-magnetized then magnetized in-line.
