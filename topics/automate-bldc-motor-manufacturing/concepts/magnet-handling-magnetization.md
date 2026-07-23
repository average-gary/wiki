---
title: Magnet Handling & Magnetization
type: concept
created: 2026-07-22
updated: 2026-07-22
tags: [magnets, ndfeb, magnetization, post-assembly, capacitor-discharge, spm, ipm, adhesive]
confidence: high
---

# Magnet Handling & Magnetization

The rotor is where automation meets physics head-on. Permanent magnets are **brittle, hazardous when
magnetized, and unforgiving of misplacement** — which is exactly why the industry's central trick is
to *not magnetize them until the very end*.

## The pivotal decision: magnetize AFTER assembly

**Insert unmagnetized magnets → assemble/bond → magnetize in-line → verify flux.** This is the
automation-friendly path, and nearly every source converges on it
([Electric Motor Engineering](../raw/data/2026-07-22-pm-rotor-magnetization-process.md),
[Greensky station 8](../raw/articles/2026-07-22-greensky-bldc-factory-station-map.md),
[Honest rotor line](../raw/data/2026-07-22-shrink-fit-and-rotor-line-stations.md)):

- **Unmagnetized parts are trivial to handle** — they don't snap together, don't jam robot grippers,
  don't fly across a cell, and pose no crushing hazard to operators.
- **Magnetized NdFeB is a menace on a line**: singulation is hard, tooling must be non-magnetic,
  parts attract debris, and there is a genuine **operator crush-injury risk**
  ([Rimac](../raw/data/2026-07-22-magnet-bonding-machines-vendors.md)).

So insertion and magnetization are **distinct in-line stations**: assemble green, then pulse.

## How in-line magnetization works

Magnetizers are **capacitor-discharge (CD) pulse supplies** — banks of capacitors dumped through a
custom fixture coil ([Electric Motor Engineering](../raw/data/2026-07-22-pm-rotor-magnetization-process.md)):

- **CD magnetizer specs** (representative): charging voltage **1,000–5,000 V**, discharge energy up
  to **10 kJ** (units span 100 J to >100 kJ), **cycle time 5–20 s/piece**, robotic load/unload,
  integrated flux test ([MagnetAct](../raw/data/2026-07-22-magnet-bonding-machines-vendors.md)).
- **Fixtures are custom per rotor geometry** (V-shape/IPM, spoke, surface-mount) — driven by pole
  count, skew, stack height, magnet material. Applied with a **3–4× Von-Mises structural safety
  factor** because the pulse imposes large forces.
- **Eddy currents** during the pulse are the subtle hard part: the low-capacitance/high-voltage vs
  high-capacitance/low-voltage tradeoff is tuned to the conductivity of the magnet and surrounding
  parts, or the field won't fully penetrate.
- Different materials need different **saturation fields** (NdFeB, SmCo, ferrite, Alnico).
- **QC**: embedded flux sense coils verify immediately post-pulse; a full-rotor field scan can be
  stored as a serialized "rotor fingerprint"
  ([Magnetic Innovations](../raw/data/2026-07-22-magnet-bonding-machines-vendors.md)).

## Getting the magnets in: SPM vs IPM

Two rotor architectures, two insertion problems
([Rimac](../raw/data/2026-07-22-magnet-bonding-machines-vendors.md),
[Laserax](../raw/data/2026-07-22-laserax-rotor-manufacturing.md)):

- **SPM (surface permanent magnet)** — arc magnets **bonded** to the rotor OD. Automation emphasis:
  surface prep (**atmospheric plasma cleaning/activation**), precise **adhesive dosing**, controlled
  cure, defined press force. A robotic SPM cell may run ~120 s/pc
  ([ACAM](../raw/data/2026-07-22-magnet-bonding-machines-vendors.md)).
- **IPM (interior permanent magnet)** — magnets **inserted into slots** inside the laminated core.
  Dominant in EVs (higher RPM, thermal isolation, reluctance torque).

## The material constraints that bite

Sintered NdFeB is **strong in compression (~1000 MPa) but weak in tension (75–80 MPa) and brittle**
([Mainrich](../raw/data/2026-07-22-magnet-retention-bonding-limits.md)) — so grippers and insertion
tooling must avoid tensile/peel loads or magnets **chip**. Retention scales with rotor tip speed:

| Retention | Max tip speed | Note |
|-----------|--------------|------|
| Adhesive bond only | **< 100 m/s** | Epoxy ~17–20 MPa shear; weak in radial peel |
| Metal sleeve (Inconel/Ti/SS) | 150–250 m/s | |
| CFRP sleeve | up to ~360 m/s | Hoop stress ∝ speed² × radius² |

A nasty failure mode: differing **CTE** between magnet, sleeve, and rotor steel means a **cold bench
test can pass while the motor fails at max speed + max temperature**. Coercivity grade tracks thermal
rating (N42SH ~150°C, N42UH ~180°C, N35EH ~200°C).

## When you can't avoid pre-magnetized magnets

Some supply chains deliver already-magnetized magnets. Then you need **non-magnetic tooling**,
**polarity/orientation control systems** to prevent placement errors, and **per-magnet screening**
before placement ([Rimac](../raw/data/2026-07-22-magnet-bonding-machines-vendors.md),
[Magnetic Innovations](../raw/data/2026-07-22-magnet-bonding-machines-vendors.md)). It is strictly
harder than the magnetize-after path — avoid it if you control the design.

## See also

- [The Process Chain](process-chain.md)
- [Core & Assembly Automation](core-and-assembly-automation.md) — rotor shaft press-fit + balancing
- [Quality & EOL Testing](quality-and-eol-testing.md) — back-EMF detects magnetization defects
- [Vendor Landscape](../reference/vendor-landscape.md) — magnetizer & bonding-machine makers
