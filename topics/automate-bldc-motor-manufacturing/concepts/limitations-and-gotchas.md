---
title: Limitations & Gotchas
type: concept
created: 2026-07-22
updated: 2026-07-22
tags: [limitations, contrarian, defect-modes, changeover, fill-factor, weld-porosity, diy]
confidence: high
---

# Limitations & Gotchas

The steelman of what makes brushless-motor automation hard — and when *not* to automate. Read this
before committing capital.

## 1. Winding resists automation more than anything else

- **Fill-factor ceiling**: automated round-wire winding realistically caps at **60–70%**; 80%+ needs
  segmented stators, compression winding, or hairpin — each adding cost/complexity
  ([Windings.com](../raw/articles/2026-07-22-winding-automation-limits-manual-case.md)).
- **Tension instability**: wire tension drifts with spool friction, feed angle, and speed; fine-gauge
  wire loops or crushes. Batch-to-batch material variation (wire dia, insulation thickness, lamination
  consistency) disrupts coil formation ([Park Magazine](../raw/articles/2026-07-22-winding-automation-limits-manual-case.md)).
- **Latent insulation damage**: enamel scratched/pinholed during feed/insertion/shaping "may go
  unnoticed until final testing or after the motor is in service" — the argument for
  [surge testing](quality-and-eol-testing.md) every unit.

## 2. Hairpin: the fill-factor win comes with a defect surface

- **Welding is the primary failure point**: a 60-slot, 4-layer stator has **120+ weld joints**; one
  cold/porous weld fails the whole motor ([Patsnap](../raw/articles/2026-07-22-hairpin-defects-fill-factor.md)).
- **Porosity** comes from insulation residue (H/C) entering the melt pool; mechanical stripping
  removes copper and leaves fit-up gaps ([Coherent](../raw/articles/2026-07-22-hairpin-weld-stripping-coherent.md)).
- **AC losses** (skin + proximity) escalate at 200–600 Hz; PWM harmonics hurt high-speed efficiency —
  a hairpin motor can be *worse* than round wire at high RPM if not designed for it
  ([Patsnap](../raw/articles/2026-07-22-hairpin-defects-fill-factor.md)).

## 3. Magnets fight back

- **Brittleness**: sintered NdFeB is weak in tension (75–80 MPa) and **chips** under peel/tensile
  gripper loads ([Mainrich](../raw/data/2026-07-22-magnet-retention-bonding-limits.md)).
- **Magnetized-part hazard**: crushing risk to operators, robot-jamming, debris attraction — the whole
  reason for [post-assembly magnetization](magnet-handling-magnetization.md).
- **CTE trap**: a rotor can **pass a cold bench test and fail at max speed + temperature** because
  magnet/sleeve/steel expand differently.
- **Eddy-current tuning** in the magnetizing pulse is non-obvious and geometry-specific.

## 4. The changeover-cost counter-case

Automation is a fixed cost; manual is variable. For **customized, prototype, or high-mix low-volume**
production, manual winding still wins ([CN Honest](../raw/articles/2026-07-22-winding-automation-limits-manual-case.md)):
a full automated line costs "hundreds of thousands to over a million," and every product changeover
demands reprogramming, recalibration, and new dedicated fixtures — whereas a manual operator swaps
simple tooling. Shops with dozens of variants get low utilization and prohibitive ROI. Automate the
**high-volume, low-mix** designs; keep the long tail manual or on flexible cells. See
[Line Economics](line-economics-and-architecture.md).

## 5. The DIY ceiling

A hobbyist Arduino/stepper winder is great for *learning* winding mechanics and prototyping pole
configs, but its own builder admits "this machine is not accurate" — no guaranteed fill factor, turn
count, or production volume ([Hackaday](../raw/repos/2026-07-22-diy-mini-bldc-winder.md)). Below a real
volume, buy winding as a service or buy a tabletop machine from a specialist; don't expect DIY to hit
commercial consistency.

## 6. Thinly-documented stations (open gaps)

Public sources are sparse on **bearing insertion**, **end-cap/end-bell assembly**, **Hall-sensor /
encoder placement**, and **lead/connector attachment** — they appear as station names but without
automation detail ([Honest rotor line](../raw/data/2026-07-22-shrink-fit-and-rotor-line-stations.md)).
Also thin: **slotless-stator** process differences, and independent (non-vendor) material-cost drivers
(copper scrap, magnet/rare-earth, electrical steel). These are the top research gaps — see the
[topic index](../_index.md#remaining-gaps).

## See also

- [Stator Winding Automation](stator-winding-automation.md)
- [Magnet Handling & Magnetization](magnet-handling-magnetization.md)
- [Quality & EOL Testing](quality-and-eol-testing.md)
- [Line Economics & Architecture](line-economics-and-architecture.md)
