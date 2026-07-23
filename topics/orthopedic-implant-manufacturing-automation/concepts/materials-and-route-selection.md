---
title: Materials & Route Selection — the Unifying Logic
type: concept
created: 2026-07-22
updated: 2026-07-22
tags: [materials, titanium, cocrmo, stainless, tantalum, peek, uhmwpe, ceramic, astm, machinability]
confidence: high
---

# Materials & Route Selection

This is the **unifying concept** of the whole topic. Everything downstream — which forming
route, how bad the tool wear, whether polishing is a bottleneck — is set by the material's
**thermal conductivity + hardness/reactivity**. Pick the material and you have largely picked
the automation problem.

## The core physics

- **Low thermal conductivity → heat stays at the cutting edge → tool wear → slow, coolant-
  heavy, sister-tooled machining.** This is titanium's curse.
- **High hardness → grinding/polishing not turning → hand-labor bottleneck** unless automated
  finishing is deployed. This is CoCr's curse.
- **Chemical reactivity / high melting point → exotic forming (CVD, sinter).** This is
  tantalum's and ceramic's story.

## The material-by-material map

| Material | ASTM | Where used | Forming route | Automation pain point |
|---|---|---|---|---|
| **Ti-6Al-4V (ELI)** | F136 / F1472 / F3001 | Stems, cups, cages, screws | AM (ideal) or 5-axis | 6.7 W/m·K → **80% of heat into edge**; work-hardens; needs HPC/cryo coolant ([Ti](../raw/data/2026-07-22-titanium-machinability-tool-wear.md)) |
| **CoCrMo** | F75 (cast) / F1537 (wrought) | Femoral heads, knee femorals, bearings | Cast or wrought → 5-axis | >50 HRC → **hand-polish bottleneck** ([CoCrMo](../raw/data/2026-07-22-cocrmo-femoral-head-machining.md)) |
| **316L / F138 SS** | F138 | Trauma plates, screws, temporary | Swiss / 5-axis | **Most machinable metal** — the easy case |
| **Tantalum** | (porous "Trabecular Metal") | Porous ingrowth structures | **CVD on carbon skeleton** | 2980 °C mp forces CVD-on-carbon; PM/AM emerging ([Ta](../raw/papers/2026-07-22-porous-tantalum-routes.md)) |
| **PEEK / CFR-PEEK** | F2026 | Spinal cages, radiolucent | Injection-mold **or** machine | CFR-PEEK abrasive → needs **PCD tooling** ([PEEK/SS](../raw/data/2026-07-22-peek-stainless-machinability.md)) |
| **UHMWPE** | F648 | Bearing liners/inserts | Machine → crosslink → stabilize | Gamma-crosslink + **vitamin-E** stabilization + inert sterilize ([UHMWPE](../raw/papers/2026-07-22-uhmwpe-crosslink-vitamin-e.md)) |
| **Alumina/zirconia (BIOLOX delta)** | F2393 | Ceramic femoral heads | **Sinter then diamond-grind** | Brittle; finishing defects = crack initiators ([ceramic](../raw/papers/2026-07-22-biolox-delta-ceramic-rationale.md)) |

## The three "shapes" of automation problem

1. **Machine it** (Ti, CoCr, SS, PEEK): automation = 5-axis/Swiss + coolant + tooling
   strategy + automated finishing. Titanium and CoCr are the hard cases; SS is easy.
2. **Print it** (Ti porous, emerging Ta): automation = AM + the post-processing tail
   ([forming routes](forming-routes-machining-am-forging-casting.md)).
3. **Form-then-densify/finish it** (tantalum CVD, ceramic sinter+grind, UHMWPE
   crosslink): automation = specialized process cells, less "machine tending."

## Why titanium is both the best and worst

Titanium's low conductivity and reactivity make it **miserable to machine** (heat, tool wear,
work hardening) but **ideal for AM** (it fuses cleanly and its porous lattices osseo-
integrate). This is why the industry pushes titanium implants toward additive and reserves
machining for CoCr/SS — the material physics, not fashion, drives the route
([Ti](../raw/data/2026-07-22-titanium-machinability-tool-wear.md),
[L-PBF vs EBM](../raw/data/2026-07-22-lpbf-vs-ebm-process-physics.md)).

## See also

- [Forming Routes](forming-routes-machining-am-forging-casting.md)
- [Finishing & Coating Automation](finishing-and-coating-automation.md)
- [The Process Chain & Station Map](process-chain-and-station-map.md)
- [Limitations & Bottlenecks](limitations-and-bottlenecks.md)
- [Build Playbook](../reference/build-playbook.md)
