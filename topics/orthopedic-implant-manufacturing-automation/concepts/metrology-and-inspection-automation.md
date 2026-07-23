---
title: Metrology & Inspection Automation
type: concept
created: 2026-07-22
updated: 2026-07-22
tags: [cmm, industrial-ct, optical-metrology, machine-vision, ai-inspection, sampling, cleanliness, closed-loop]
confidence: high
---

# Metrology & Inspection Automation

Inspection is where "maximal automation" meets the regulatory reality: because you often
**cannot fully inspect** a finished implant (internal AM porosity, fatigue life, sterility),
some verification is by *validated process* rather than measurement. What *can* be automated,
increasingly is.

## The automated metrology stack

([metrology](../raw/data/2026-07-22-automated-metrology-cmm-ct.md))

| Tool | What it verifies | Automation |
|---|---|---|
| **CMM** (Zeiss ShuttleLoad / MultiLoad) | Dimensional GD&T, form | **Cobot/robot part loading → unmanned overnight runs** |
| **Industrial CT** | Internal porosity, lattice integrity, trapped powder | **Only NDT method for AM internal features**; automated stage; big data |
| **Optical / vision GD&T** (VisionGauge) | 2D/3D dimensions, edges | Fast, non-contact, in-line |
| **AI cosmetic vision** | Scratches, cosmetic/surface defects | In-line; **but black-box validation limits** (see below) |
| **Surface metrology** | Ra/Rz on bearing surfaces | Automated profilometry / interferometry |

**Closed-loop is the enabler.** In the lights-out cell, **CMM results route automatically back
to the CNC in real time** so the cell self-corrects with no operator
([Flexxbotics/Mach](../raw/repos/2026-07-22-flexxbotics-mach-medical-lights-out-cell.md)).
Parts held to <25% of a 1 mm tolerance band. This is the single mechanism that makes
unmanned, *regulated* production feasible.

## Industrial CT: the AM-specific gate

For additive parts, internal porosity and lattice defects are invisible to surface metrology.
**Industrial CT is the only non-destructive way to see them**
([metrology](../raw/data/2026-07-22-automated-metrology-cmm-ct.md)). But CT is slow and data-
heavy, so the industry is split between **100% CT** and **validation-by-monitoring** (melt-pool
tomography as the record — EOSTATE Exposure OT / Smart Fusion,
[serial AM cases](../raw/repos/2026-07-22-serial-am-oem-cases-stryker-lima-orchid.md)). Which
is acceptable is a regulatory/risk decision, not a technical one.

## AI vision and its validation ceiling

AI machine vision reliably flags scratches and cosmetic defects, but a **black-box model can't
be fully validated** for a safety-critical accept/reject decision
([AI vision](../raw/articles/2026-07-22-ai-cosmetic-visual-inspection-limits.md)). The
practical pattern is **two-tier human escalation**: AI auto-passes clear-good and clear-bad,
and escalates the ambiguous middle to a human inspector. This keeps a validated human in the
loop where the model's confidence is low — a recurring theme of the
[regulatory envelope](the-regulatory-envelope.md).

## Sampling: why implants trend to 100% / c=0

Traditional AQL sampling (ANSI/ASQ Z1.4) accepts a lot after inspecting a sample, but for
implants the trend is **100% inspection with zero-accept (c=0)** because the cost of an escaped
defect is catastrophic ([sampling](../raw/data/2026-07-22-inspection-sampling-cleanliness-standards.md),
21 CFR 820.250). Automation is what makes 100% inspection economically possible — you can't
hand-CMM every part, but you can cobot-load a CMM 24/7.

## Cleanliness verification

Post-clean, implants must meet particulate/residue limits — **ISO 19227** cleanliness and a
particulate index ([sampling](../raw/data/2026-07-22-inspection-sampling-cleanliness-standards.md)).
Verified by automated extraction + particle counting / gravimetric methods, tied to the
cleaning validation ([back-end](../raw/data/2026-07-22-sterilization-packaging-cleaning.md)).

## See also

- [The Process Chain & Station Map](process-chain-and-station-map.md)
- [Finishing & Coating Automation](finishing-and-coating-automation.md)
- [The Regulatory Envelope](the-regulatory-envelope.md)
- [Limitations & Bottlenecks](limitations-and-bottlenecks.md)
- [Build Playbook](../reference/build-playbook.md)
