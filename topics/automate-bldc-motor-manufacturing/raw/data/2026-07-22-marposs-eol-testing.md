---
title: "End-of-Line & Back-EMF Testing of Electric Motors (Marposs)"
source: https://www.marposs.com/eng/application/end-of-line-testing-of-electric-motors
source_2: https://www.marposs.com/eng/application/back-emf-test
source_3: https://www.marposs.com/eng/electrical-testing-of-electric-motors/
type: data
tags: [eol-test, back-emf, hipot, surge, nvh, test-placement, vendor]
credibility: high
confidence: high
retrieved: 2026-07-22
summary: Authoritative EOL test-equipment vendor — full test menu, back-EMF method detail, and where tests sit in the chain (pre/post-impregnation vs full assembly).
---

# EOL & Back-EMF Testing (Marposs)

**Full EOL test menu (100%, one integrated station, DC/AC/sync/async):**
insulation resistance (IR), dielectric strength (hi-pot), **surge test**, partial-discharge (PD), **back-EMF**, friction + iron-loss, no-load test, load test, plus **vibration/noise (NVH)**.

**Back-EMF (BEMF) — detects magnet defects directly:** "any anomaly such as a damaged, partially demagnetised or missing magnet will result in a reduction in the BEMF from the expected value." Amplitude ∝ rotor speed × field strength.
- **Two production methods**: (1) *Standard* — de-energized motor spun by a coupled active brake at constant speed, sampling phase-to-phase voltages; (2) *Dynamic* — motor driven to target speed by inverter, inverter disconnects, induced voltages sampled during coast-down.
- Metrics: RMS, peak-to-peak, **FFT spectral analysis**, THD, three-phase ripple/balance. Deeper localization via Hall-sensor magnetic-field mapping.

**Test-station placement across the chain:**
- **Pre-impregnation stator**: winding resistances + inductances, parasitic capacitances, insulation condition — catch winding faults before varnish seals them in.
- **Post-impregnation stator**: insulation-state check validating impregnation.
- **Rotor functional control**: varies by motor type.
- **Full-motor EOL**: the key QC gate; in-line or off-line.
