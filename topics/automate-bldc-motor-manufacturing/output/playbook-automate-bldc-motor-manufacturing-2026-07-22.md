---
title: "Playbook — How to Automate Brushless Motor Manufacturing"
type: output
kind: playbook
created: 2026-07-22
updated: 2026-07-22
tags: [playbook, how-to, automation, bldc, pmsm, deliverable]
question: "How to automate brushless motor manufacturing"
confidence: high
---

# Playbook: How to Automate Brushless Motor Manufacturing

**The question:** *How do you automate the manufacturing of brushless (BLDC / PMSM) motors?*

This is the standalone, actionable answer produced by the research round of 2026-07-22 (28 sources,
9 compiled articles). The in-wiki, cross-linked version lives at
[reference/build-playbook.md](../reference/build-playbook.md); this artifact is self-contained for
sharing. It is organized as the sub-questions the research decomposed the question into, then a
decision-ordered how-to.

## The one-paragraph answer

Automating brushless-motor manufacturing means **sequencing the build into stations and automating
each to a different degree**, because they differ enormously in difficulty. In rough order of
hardness: **stator winding** (hardest) → **magnet insertion/bonding** → **rotor balancing**, while
**lamination stamping, testing, and press assembly** are already commodity-automated. The three
industry enablers are: (1) choose the **winding method to match your winding topology**; (2) insert
**unmagnetized magnets and magnetize in-line afterward**; and (3) run **100% end-of-line + in-process
testing** feeding an MES. *Whether* to automate is a volume/mix decision — automate high-volume,
low-mix designs; keep the long tail manual. For the hard stations, **buy from specialists and
integrate** rather than build.

## Key findings by sub-question

### What is the process chain? (the stations to automate)

Lamination stamping → stacking → slot insulation → **stator winding** → termination/weld →
impregnation → magnet insertion → shaft press-fit → **balancing** → **in-line magnetization** →
housing/bearing assembly → stator–rotor integration → **100% EOL test**. Automation difficulty is
*not* uniform: winding and magnet handling are hard; stamping, pressing, and testing are commodity.

### How do you automate winding? (the hardest station)

Pick the machine by winding topology, because your electromagnetic design already fixes concentrated
vs. distributed:

| Motor | Topology | Machine | Fill factor |
|-------|----------|---------|-------------|
| Small inner-rotor BLDC | Concentrated | Needle winder | 65–75% |
| Outer-rotor BLDC | Concentrated | Flyer winder | 45–55% |
| High-fill compact servo | Concentrated | Segmented-stator (linear + join) | 70%+ |
| EV traction / e-axle | Distributed | Hairpin (bar) line | 60–80% |

Fill factor is a **ladder set by method**, not a dial. Segmented stators win when you need high fill
plus easy automated termination. Hairpin's fill-factor win comes with a defect surface (120+ weld
joints; porosity from insulation residue) — budget for two-step laser cleaning.

### How do you handle the magnets? (the key rotor trick)

**Insert unmagnetized magnets, magnetize in-line afterward** with a capacitor-discharge pulse through
a custom fixture, then verify flux. This removes the jamming, crushing-hazard, and debris problems of
handling live magnets. Bond with automated dosing after plasma surface activation. NdFeB is brittle
(weak in tension, ~75–80 MPa) — grippers must avoid tensile/peel loads. Design rotor tip speed against
the retention limit: **bond-only < 100 m/s**, else add a sleeve (metal to ~250 m/s, CFRP to ~360 m/s),
and validate retention at max speed *and* temperature (the CTE trap).

### How do you test it? (what makes automated building worth it)

Distributed, not bolted-on: pre-impregnation electrical tests, in-process machine vision, and a 100%
EOL station running IR + hi-pot, **surge + PD** (the only turn-to-turn insulation detector — mandatory
for PWM drives), **back-EMF** (magnetization health), cogging/friction torque, and no-load/load. All
feeds an **MES** for genealogy, reject/hold, SPC, and IATF-16949 records.

### When does it pay? (the economics)

A capital-for-labor trade decided by **volume and mix**. Mass/low-mix → dedicated line (ROI ~18–36
months at >85% uptime). Variable batch → flexible/reconfigurable cells. High-mix/low-volume →
changeover cost crushes ROI; stay manual. Transport choice *is* the flexibility lever: rotary indexing
for one design; independent movers (XTS-class) for many variants on one line. Real anchors: EV hairpin
lines at 200k+ units/yr; integrated e-axle lines ~175k units/yr.

### Who do you buy from?

- **EV traction:** GROB, Aumann, Comau, Elmotec-Statomat/Schaeffler, Krause Automation (winding +
  turnkey); Schuler/ANDRITZ, Bruderer (laminations); Schleich, Marposs (test).
- **Small BLDC:** Marsilli, Nittoku, Odawara, or Chinese turnkey houses (Nide, MNY, HONEST); needle/
  flyer machines; trickle impregnation.
- **Magnetizing / bonding:** Laboratorio Elettrofisico, Magnet-Physik; Rimac, ACAM.
- **MES:** Bosch Nexeed, Siemens Opcenter, Critical Manufacturing, Tulip.

## Actionable steps (decision order)

1. **Decide whether to automate at all.** Volume <hundreds/yr → stay manual. Tens of thousands →
   flexible cells. 100Ks+ → dedicated line. Dozens of variants → automate only the high-runners.
2. **Fix winding topology → winding method** (Decision 1 table above). This is the first commitment;
   everything else follows.
3. **Design the rotor for post-assembly magnetization** (insert unmagnetized → bond → press-fit +
   balance → magnetize + verify).
4. **Lay out the stations** in build order and balance takt to the winding station (the bottleneck).
5. **Choose transport = flexibility** (rotary for one design; independent movers for variants).
6. **Build the distributed test strategy in from day one**, feeding an MES.
7. **Buy the hard stations from specialists; integrate the line.**
8. **Design against the known failure modes**: latent winding insulation damage (→ surge test),
   hairpin weld porosity (→ laser clean), magnet chipping (→ gripper loads), CTE retention trap
   (→ hot+fast validation), changeover cost (→ don't automate high-mix low-volume).

## Worked paths

- **Small BLDC (pump/fan/drone):** flyer or needle winder + trickle impregnation + CD magnetizer +
  compact EOL; flexible cells; Chinese turnkey line or Marsilli/Nittoku/Odawara.
- **EV traction / e-axle:** hairpin (bar) line with two-step laser weld cleaning + VPI impregnation +
  induction shrink-fit + full surge/PD/BEMF EOL; independent-mover transport; GROB/Aumann/Comau/
  Schaeffler-class integrator; MES-integrated at 175k–200k+ units/yr.

## Derived theses (candidates for `--mode thesis` follow-up)

1. *"Post-assembly (in-line) magnetization is the single highest-ROI automation decision on the rotor
   line — it eliminates more failure modes than any other rotor-side choice."*
2. *"For inverter-fed (PWM) BLDC/PMSM, surge + partial-discharge testing is the only EOL test that
   meaningfully predicts field insulation failures; omitting it dominates warranty returns."*
3. *"Below ~50k units/yr of any single design, flexible cells beat a dedicated line on total cost per
   motor once changeover is priced in."*

## Sources

Compiled from 28 ingested sources — see [raw/_index.md](../raw/_index.md). Highest-confidence
primary vendor/standard sources: Marsilli, Aumann, GROB, Schleich, Comau, Magnet-Physik, Schuler,
Bruderer, Nittoku, Beckhoff/GROB (hairpin line architecture), Schaeffler (e-axle capacity), Marposs
(EOL), Electrom/MDS/Schleich (surge). Vendor-blog ROI/volume figures are flagged illustrative in
[Line Economics](../concepts/line-economics-and-architecture.md).

## See also

- [Build Playbook (in-wiki, cross-linked)](../reference/build-playbook.md)
- [Topic index](../_index.md)
