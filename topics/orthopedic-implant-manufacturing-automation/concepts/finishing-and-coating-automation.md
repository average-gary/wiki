---
title: Finishing & Coating Automation — Killing the Hand-Polish Bottleneck
type: concept
created: 2026-07-22
updated: 2026-07-22
tags: [polishing, electropolishing, mass-finishing, force-control, plasma-spray, ha-coating, passivation, anodize, marking]
confidence: high
---

# Finishing & Coating Automation

The **most counterintuitive finding of the whole topic**: manual polishing — for decades *the*
irreducible hand-labor step in orthopedic manufacturing — is now being automated to mirror
finish. This is where the biggest recent automation gains live.

## Killing the hand-polish bottleneck

CoCr femoral heads and knee bearings historically needed skilled hand polishing to reach a
mirror surface (Ra 0.01–0.05 µm) — a slow, variable, labor-intensive gate
([CoCrMo](../raw/data/2026-07-22-cocrmo-femoral-head-machining.md)). Four automated
technologies now displace it ([finishing](../raw/data/2026-07-22-automated-polishing-electropolish-massfinish.md)):

| Technology | Mechanism | Datapoint |
|---|---|---|
| **DLyte dry electropolishing** | Solid electrolyte media, electrochemical | **24 CoCr knee components to Ra < 0.05 µm in 60 min** |
| **Rösler drag finishing** | Part dragged through abrasive media | Batch, repeatable, geometry-following |
| **OTEC stream finishing** | High-speed media stream around fixtured part | Fast, edge-safe |
| **PushCorp active-force-control robotics** | Robot arm with closed-loop contact force | Follows freeform surfaces at constant pressure |

Turnkey integrators productize this: **Acme Manufacturing** has installed **>150 robotic
finishing systems for orthopedics** (FANUC-based, programmable force compliance across
knee/hip/plate/acetabular/spine); **AV&R** reports **75% cycle-time cut** with ±15 µm removal
consistency ([vendor landscape](../raw/repos/2026-07-22-cmo-vendor-landscape-market.md)).

**Why it matters:** removing the hand-polish gate is what makes an *end-to-end* automated line
plausible — it was the last major manual island in the metal chain.

## Coating (osseointegration surfaces)

Porous / bioactive coatings promote bone ingrowth and are highly automatable
([coatings](../raw/data/2026-07-22-coatings-passivation-anodize-marking.md)):

- **HA (hydroxyapatite) plasma spray** — applied by **6-axis robots (e.g. ABB)**;
  crystallinity spec **>62%**; controlled standoff/traverse.
- **Porous titanium coatings** — plasma spray or sintered beads; increasingly replaced by
  *integral* AM porosity (print the porous surface instead of coating it —
  [forming routes](forming-routes-machining-am-forging-casting.md)).
- **TiN / hard coatings** — wear resistance on articulating surfaces.

## Passivation, anodizing, marking (back-end surface ops)

All automatable wet/laser processes ([coatings](../raw/data/2026-07-22-coatings-passivation-anodize-marking.md)):

- **Passivation** — ASTM F86 / A967 (nitric or citric); removes free iron, restores oxide
  layer; automated tank lines.
- **Type II color anodizing** (AMS 2488) — color-codes titanium implants (size/laterality)
  with no dye; robotic rack handling.
- **UDI laser marking** — direct part mark per 21 CFR 801.45; **must not compromise the
  fatigue surface** (marking placement is a design constraint — see
  [Limitations](limitations-and-bottlenecks.md)).

## The finishing automation caveat

Finishing is now *automatable* but still *validation-bound*: surface roughness on a bearing
surface is safety-critical and not fully inspectable non-destructively, so the finishing cell
falls squarely under 21 CFR 820.75 process validation
([regulatory envelope](the-regulatory-envelope.md)). Automation removes the labor; it does not
remove the IQ/OQ/PQ burden.

## See also

- [The Process Chain & Station Map](process-chain-and-station-map.md)
- [Materials & Route Selection](materials-and-route-selection.md)
- [Metrology & Inspection Automation](metrology-and-inspection-automation.md)
- [The Regulatory Envelope](the-regulatory-envelope.md)
- [Limitations & Bottlenecks](limitations-and-bottlenecks.md)
- [Build Playbook](../reference/build-playbook.md)
