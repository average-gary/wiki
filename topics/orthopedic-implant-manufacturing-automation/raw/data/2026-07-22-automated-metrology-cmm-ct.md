---
title: "Automated metrology — cobot-loaded CMM (Zeiss), industrial CT for AM porosity, optical GD&T"
source: https://www.zeiss.com/metrology/us/systems/cmms/automation-integration/loading.html
source_2: https://industrialinspection.com/2024/05/14/ct-scanning-additive-manufacutured-am-parts/
source_3: https://www.nelpretech.com/blog/why-ct-scanning-is-the-only-reliable-way-to-inspect-complex-additive-manufacturing-geometries
source_4: https://www.visionxinc.com/applications/medical-manufacturing/orthopedic-implant-inspection-measurement/
type: data
tags: [metrology, cmm, automation, industrial-ct, additive-manufacturing, porosity, gd-t, optical-comparator, inspection]
credibility: high
confidence: high
retrieved: 2026-07-22
summary: Automated dimensional metrology stack — Zeiss ShuttleLoad/MultiLoad pallet loaders for unmanned CMM shifts, in-line integration logic, industrial CT as the only NDT for AM internal lattice/porosity (detects trapped powder), and VisionGauge optical GD&T (±0.0001").
---

# Automated Metrology — CMM, Industrial CT, Optical GD&T

**Automated CMM loading (Zeiss + integration engineering):**
- **ShuttleLoad** (pallet workpiece changer, unmanned shifts, PRISMO/CONTURA); **MultiLoad** (serves up to 4 CMMs, 16 pallet storage, "completely unmanned shifts"); **Duplex** dual-pallet parallel load/unload during measurement. Also **3D Infotech UMA** cobot CMM-tending via PolyWorks (auto load/unload + conform/non-conform sorting).
- In-line integration logic: with a robot moving parts CNC→CMM there may be **three parts "in flight" (wash, buffer, CMM)** → needs **PLC-driven queue tracking** so dimensional corrections apply only to subsequent runs. **Moving-table CMM preferred for robotic integration** (external loading zone protects measuring volume; bridge/gantry risk weeks-long repair on collision).

**Industrial CT for AM internal geometry (the only NDT that works for lattices):**
- CT is the **only non-destructive way to inspect internal AM features** tactile probes/vision can't reach — critical for lattice/porous titanium.
- Quantifies **porosity % by volume, defect size distribution, spatial location, 3D render, STL export**; detects **trapped/unfused powder in closed cavities** (lighter gray) — clinically important (unreleased powder → inflammation, impaired vascularization). Detects delamination, micro-cracks, sub-mm strut deviation across thousands of lattice junctions; micron-level resolution; wall-thickness + part-to-CAD deviation mapping.
- (CT vendors Nikon/Zeiss METROTOM/Werth/Waygate/North Star noted but not deep-fetched — a gap.)

**Optical dimensional + GD&T (VisionGauge):**
- Digital optical comparator, **±0.0001" on the shop floor**; **CAD Auto-Pass/Fail** inspects directly vs CAD (true position); computer-controlled multi-angle LED illumination for cosmetic aid. On hip/knee/spine/IM-nail/screw ("Tooth Checker" thread tool). "100% pass is an absolute necessity"; auto SPC output.
