# Log — Automating Brushless Motor Manufacturing

## [2026-07-22] init | topic wiki created

New hub topic created for question research: "how to automate brushless motor manufacturing."
Question mode — decomposed into sub-questions covering the process chain, automation systems,
winding/magnet/assembly stations, test/EOL, economics/scale, and vendor landscape.

## [2026-07-22] research --deep | round 1 | 8 agents → 28 sources, 9 articles

**Mode:** Question research, `--deep` (8 parallel agents). Decomposed into 8 sub-questions, one
agent each:

1. **Process chain** — station-by-station build sequence + automation-difficulty map.
2. **Stator winding** — needle/flyer/linear/hairpin, fill-factor ladder, topology→machine.
3. **Magnet handling & magnetization** — post-assembly magnetization, bonding, brittleness, retention.
4. **Core & assembly** — lamination stamping/stacking, impregnation, shrink-fit, bearings.
5. **Quality & EOL test** — distributed strategy, surge/PD, back-EMF, cogging, machine vision.
6. **Economics & scale** — volume/mix thresholds, ROI, line architecture, capacity anchors.
7. **Vendor landscape** — winding/integration/magnetizer/press/test/MES vendors by category.
8. **Limitations & gotchas** — the steelman of what's hard and when *not* to automate.

**Ingestion:** 28 sources after dedup (10 articles, 15 data, 3 repos). Deduped 6 duplicate finds
(Odawara-hairpin, Honest stator-winding, Marposs EOL cluster, surge-test cluster, winding-limits
cluster, magnet-bonding cluster). Credibility: iFactory + ynypm marked low / figures flagged
illustrative; vendor-landscape given a verification-tier caveat.

**Compilation:** 7 concept articles + `reference/vendor-landscape.md` + `reference/build-playbook.md`
(the Question-Mode deliverable) + `output/playbook-...-2026-07-22.md` standalone artifact.

**Headline findings:** (1) winding is the hardest station and its method is set by winding topology,
not chosen freely; fill factor is a method-set ladder. (2) The key rotor-automation trick is
inserting *unmagnetized* magnets and magnetizing in-line post-assembly. (3) Surge+PD is the only
turn-to-turn insulation detector — mandatory for PWM drives. (4) Automation is a volume/mix
decision (ROI ~18–36 mo at >85% uptime for high-volume low-mix). (5) Buy the hard stations from
specialists and integrate.

**Progress score:** ~82/100. **Gaps:** slotless-stator process differences; bearing/end-cap/
Hall-sensor station automation detail; independent (non-vendor) material-cost drivers.
**Derived theses (for `--mode thesis`):** in-line magnetization as highest-ROI rotor decision;
surge+PD as the dominant field-failure predictor for PWM motors; flexible-cells beat a dedicated
line below ~50k units/yr per design.
