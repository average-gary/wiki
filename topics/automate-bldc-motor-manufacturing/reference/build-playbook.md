---
title: "Build Playbook — How to Automate Brushless Motor Manufacturing"
type: reference
created: 2026-07-22
updated: 2026-07-22
tags: [playbook, how-to, automation, bldc, pmsm, decision-framework]
confidence: high
---

# Build Playbook: How to Automate Brushless Motor Manufacturing

The actionable answer to the original question. This is the opinionated, step-by-step path — what to
decide first, what to buy vs. build, and the order to automate the stations in. It synthesizes all
[concept articles](../_index.md) and the [vendor landscape](vendor-landscape.md).

## The one-paragraph answer

Automating brushless-motor manufacturing means **sequencing the build into stations and automating
each to a different degree**, because they differ enormously in difficulty. In rough order of
hardness: **stator winding** (hardest) → **magnet insertion/bonding** → **rotor balancing**, while
**lamination stamping, testing, and press assembly** are already commodity-automated. The industry's
key enablers are (1) choosing the winding method to match your winding topology, (2) **inserting
unmagnetized magnets and magnetizing in-line afterward**, and (3) **100% end-of-line + in-process
testing** feeding an MES. Whether to automate at all is a volume/mix decision: automate high-volume,
low-mix designs; keep the long tail manual. For the hard stations, **buy from specialists and
integrate** rather than build.

## Decision 0: Should you automate at all?

Answer these before spending a dollar ([economics](../concepts/line-economics-and-architecture.md)):

- **Annual volume?** <hundreds/yr of a design → stay manual. Tens of thousands → flexible cells.
  100Ks+ → dedicated line.
- **Product mix?** Dozens of variants kills automation ROI via changeover cost. Automate the few
  high-runners; keep the tail manual.
- **Payback tolerance?** Expect **~18–36 months** at >85% uptime for a well-matched high-volume line.
- **Labor cost + quality consistency?** These, not peak speed, usually justify the capital —
  "repeatability matters more than speed."

If the answer is "automate," continue.

## Decision 1: Winding topology → winding method (do this FIRST)

This single choice ripples through the entire line
([stator winding](../concepts/stator-winding-automation.md)). Your electromagnetic design already
fixes concentrated vs distributed; that fixes the machine:

| Your motor | Winding topology | Buy this machine | Fill factor |
|-----------|-----------------|-----------------|-------------|
| Small inner-rotor BLDC (pump, tool, drone) | Concentrated | **Needle winder** (or segmented-linear) | 65–75% |
| Outer-rotor BLDC (fan, gimbal, e-scooter) | Concentrated | **Flyer winder** | 45–55% |
| High-fill compact servo | Concentrated | **Segmented-stator** (linear winder + join) | 70%+ |
| EV traction / e-axle | Distributed | **Hairpin (bar) line** | 60–80% |

- **Prefer segmented stators** when you need high fill and easy automated termination — winding
  external teeth beats reaching a needle into a closed slot.
- **Budget for the hard sub-steps**: enamel stripping and welding for hairpin (two-step laser cleaning
  to avoid porosity); tension control for fine round wire.

## Decision 2: Design the rotor for post-assembly magnetization

The biggest automation win on the rotor side ([magnet handling](../concepts/magnet-handling-magnetization.md)):

1. **Insert unmagnetized magnets** (SPM bond onto OD, or IPM into slots) — safe, no jamming.
2. **Bond** with automated adhesive dosing after **plasma surface activation**; press with defined force.
3. **Press-fit the shaft** (pre-heat core, interference fit) and **balance** to ≥ G2.5.
4. **Magnetize in-line** with a capacitor-discharge pulse through a **custom fixture** (tune for eddy
   currents), then **verify flux** immediately.

Only fall back to pre-magnetized magnets if forced — then you need non-magnetic tooling + polarity
control + per-magnet screening. Design the rotor's tip speed against the retention limit: **bond only
< 100 m/s**, else sleeve (metal to 250 m/s, CFRP to ~360 m/s).

## The station-by-station build order

Automate in this order — mature/cheap stations first to get the line running, hard stations last
([process chain](../concepts/process-chain.md), [core & assembly](../concepts/core-and-assembly-automation.md)):

1. **Lamination stamping + stacking** — progressive die; choose the join: **interlock** (cheapest,
   in-die), **backlack bonding** (lowest loss/best NVH), or **laser weld** (accept the loss). Add
   stacking-pin alignment + force-distance QC.
2. **Slot insulation** — vision-guided paper insertion.
3. **Stator winding** — your Decision-1 machine. The bottleneck; balance the whole line's takt to it.
4. **Termination / weld** — laser/TIG/resistance + immediate continuity test.
5. **Impregnation** — **trickle for small BLDC** (fast/cheap), **VPI for EV/HV** (thorough).
6. **Rotor line** — insert magnets → bond → shaft press-fit → balance → **magnetize + flux check**.
7. **Housing assembly** — **induction shrink-fit** stator into housing (closed-loop PID; short thermal
   window) + servo-press bearings + end-caps.
8. **Stator–rotor integration** — precision air-gap alignment.
9. **EOL test** — see next section.

Between stations, choose **transport = flexibility**: rotary indexing for a single high-volume design;
**free-flow independent movers (XTS-class)** if you need many variants on one line.

## Build the test strategy in from day one

Testing is distributed, not bolted on at the end ([quality & EOL](../concepts/quality-and-eol-testing.md)):

- **Pre-impregnation**: resistance, inductance, insulation — before varnish seals faults in.
- **In-process machine vision**: winding defects, solder joints, magnet position + polarity.
- **100% EOL station**: IR + hi-pot, **surge + PD** (the *only* turn-to-turn detector — mandatory for
  PWM-driven motors), **back-EMF** (magnetization health), cogging/friction torque, no-load + load,
  NVH.
- **Feed everything to an MES** for part genealogy, automatic reject/hold, SPC, IATF-16949 records.

## Buy vs. build

**Buy the hard stations, integrate the line.** Nobody builds their own hairpin welder or CD magnetizer
([vendor landscape](vendor-landscape.md)):

- EV traction: GROB / Aumann / Comau / Schaeffler / Krause Automation (winding + turnkey), Schuler /
  Bruderer (laminations), Schleich (test).
- Small BLDC: Marsilli / Nittoku / Odawara or Chinese turnkey (Nide, MNY, HONEST); needle/flyer;
  trickle impregnation.
- Magnetizing: Laboratorio Elettrofisico, Magnet-Physik; bonding cells: Rimac, ACAM.

## Common failure modes to design against

From [Limitations & Gotchas](../concepts/limitations-and-gotchas.md):

- **Latent winding insulation damage** → surge-test every unit.
- **Hairpin weld porosity** → two-step laser clean before welding; 120+ joints means one bad weld
  scraps the motor.
- **Magnet chipping** → grippers must avoid tensile/peel loads on brittle NdFeB.
- **CTE trap** → validate rotor retention at max speed *and* max temperature, not cold.
- **Changeover cost** → don't automate a high-mix low-volume product; you'll never hit ROI.

## Scale reality check

- **Hobbyist / R&D**: a DIY stepper winder teaches mechanics but can't hold fill factor or turn count
  — buy winding as a service or a tabletop machine.
- **Small manufacturer**: flexible cells + Chinese turnkey winding lines; automate winding + test
  first (highest labor + quality payoff).
- **Gigafactory / EV**: full dedicated hairpin lines, 175k–200k+ units/yr, MES-integrated, flexible
  transport for variant coverage.

## See also

- [The Process Chain](../concepts/process-chain.md)
- [Stator Winding Automation](../concepts/stator-winding-automation.md)
- [Magnet Handling & Magnetization](../concepts/magnet-handling-magnetization.md)
- [Core & Assembly Automation](../concepts/core-and-assembly-automation.md)
- [Quality & End-of-Line Testing](../concepts/quality-and-eol-testing.md)
- [Line Economics & Architecture](../concepts/line-economics-and-architecture.md)
- [Limitations & Gotchas](../concepts/limitations-and-gotchas.md)
- [Vendor Landscape](vendor-landscape.md)
