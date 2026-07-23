---
title: Equipment & Turnkey-Line Vendor Landscape
type: reference
created: 2026-07-22
updated: 2026-07-22
tags: [vendors, winding-machines, integrators, magnetizers, presses, eol-test]
confidence: medium
---

# Equipment & Turnkey-Line Vendor Landscape

Who to call. The practical answer to "how do I automate this" is usually **buy the hard stations from
specialists and integrate**, not build from scratch. This is the vendor map by category, drawn from
live vendor pages ([full source note](../raw/repos/2026-07-22-equipment-vendor-landscape.md)).

> **Verification tier:** Marsilli, Aumann, GROB, Schleich, Comau, Magnet-Physik, Schuler, Bruderer,
> Nittoku were confirmed from live primary vendor pages (highest confidence). ATOP, Elmotec-Statomat's
> exact catalog, Laboratorio Elettrofisico's domain, and the Chinese integrators came from search
> aggregates — **link-verify before quoting or purchasing**.

## Winding machines (needle / flyer / linear / hairpin)

| Vendor | Country | Relevant products |
|--------|---------|-------------------|
| **Marsilli** | Italy | Spindle + flyer (to 24 spindles, wire 0.02–2.5 mm, 25,000 RPM); needle winding on open + closed stators; turnkey lines |
| **Aumann AG** | Germany (+CN, US) | Named models: **A-LWS** (linear), **A-NWS** (needle), **A-FWS** (flyer); hairpin; turnkey e-mobility lines |
| **Elmotec-Statomat** (Schaeffler) | Germany | Needle, flyer, twist-free, **wave/continuous-hairpin**, linear |
| **GROB-Werke** | Germany | Large-series stators/rotors; hairpin, continuous hairpin, insertion, needle — the EV-traction reference |
| **Odawara Automation** | Japan | Needle + high-speed stator winding + hairpin |
| **Nittoku** | Japan | Multi-axis FA coil-winding to tabletop; GWM nozzle-guide inner winders |
| **HONEST, BSTP/Bestop, DETZO, IMA, Huaguanie, NTO** | China | Small-motor mass-production winding lines |

## Turnkey line integrators / assembly automation

- **Comau** (Italy) — E-Transmissions & Hairpin Assembly, Racer-5 robots.
- **Marsilli / Aumann / GROB** — also full turnkey lines.
- **Krause Automation** (Germany) — the divested **thyssenkrupp System Engineering** e-mobility unit
  (historically hairpin stator lines). *Update stale thyssenkrupp references.*
- **Ningbo Nide Tech, MNY Intelligent Technology** (China) — BLDC / hairpin / e-drive turnkey lines.
- **Robotics in cells**: KUKA, ABB, FANUC, ATS Automation, Manz.

## Magnetizers & magnet handling

- **Laboratorio Elettrofisico** (Italy) — magnetizing systems + measurement integrated with
  automation; iMag Master.
- **Magnet-Physik Dr. Steingroever** (Germany) — magnetizers, custom fixtures/coils, PERMAGRAPH
  hysteresigraph, field scanners; ISO 17025 lab.
- **Brockhaus Measurements** (Germany) — magnetic material / lamination testing.
- **Rimac Machines, MagnetAct, Magnetic Instrumentation** — magnet-bonding + CD-magnetizer equipment
  ([specs](../raw/data/2026-07-22-magnet-bonding-machines-vendors.md)).

## Lamination stamping / stacking presses

- **Schuler Group** (Germany; now part of **ANDRITZ**, Austria) — cutting systems, high-speed presses,
  notching lines; E-Mobility division.
- **Bruderer AG** (Switzerland) — high-speed stamping presses; B3 control with integrated **BSP
  lamination-stacking** control.
- **Kienle + Spiess** (Germany) — lamination stacks/rotors/stators as a component supplier.
- **Oberg** (USA) — progressive dies / tooling.

## End-of-line test

- **Schleich GmbH** (Germany) — surge (PD), IR, hi-pot to **6 kV AC / 8500 V DC**, resistance, PI/DAR,
  function test. Products: **MTC3 R2**, **MotorAnalyzer3**, GLP series, Matrix (6–24 test points).
- **Marposs** (Italy) — E.D.C. EOL systems ([test detail](../raw/data/2026-07-22-marposs-eol-testing.md)).
- **Vali Dynamics** — cogging/friction torque benches ([spec](../raw/data/2026-07-22-cogging-friction-torque-testing.md)).

## MES / Industry 4.0

- **Bosch Nexeed**, Siemens Opcenter Execution, Critical Manufacturing, Tulip — part genealogy /
  traceability / quality gates ([detail](../raw/data/2026-07-22-bosch-nexeed-mes-industry40.md)).

## Segment cheat-sheet

- **Building EV traction / e-axle**: talk to GROB, Aumann, Comau, Schaeffler, Krause Automation
  (hairpin lines); Schuler/Bruderer (laminations); Schleich (test).
- **Building small BLDC (appliance/fan/pump/drone)**: talk to Marsilli, Nittoku, Odawara, or the
  Chinese turnkey houses (Nide, MNY, HONEST); needle/flyer machines; trickle impregnation.

## See also

- [The Process Chain](../concepts/process-chain.md)
- [Stator Winding Automation](../concepts/stator-winding-automation.md)
- [Line Economics & Architecture](../concepts/line-economics-and-architecture.md)
- [Build Playbook](build-playbook.md)
