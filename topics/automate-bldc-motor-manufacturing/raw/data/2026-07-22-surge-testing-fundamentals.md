---
title: "Surge Testing Fundamentals — Turn-to-Turn Fault Detection (Electrom + MDS + Schleich)"
source: https://electrominst.com/test-technology/surge-test-methods/
source_2: https://www.motordiagnosticsystems.com/surge-testing-white-paper
source_3: https://www.schleich.com/en/test-method/testing-the-turn-to-turn-fault/
type: data
tags: [surge-test, turn-to-turn, insulation, ear, partial-discharge, ieee-522]
credibility: high
confidence: high
retrieved: 2026-07-22
summary: Quantified explanation of surge waveform analysis and automated EAR pass/fail — the core "why surge beats DC" argument for winding QC.
---

# Surge Testing Fundamentals

- **Surge test is the only test that finds weak turn-to-turn insulation** — low-voltage DC hi-pot and IR can't stress inter-turn insulation and give false results.
- **Voltage per IEEE 522** (example: 460 V motor → **1920 V** surge); pulse **rise time ~100 ns**; minimum **5 pulses**. Rise time is decisive: a slow 1000 ns pulse induces much lower terminal voltage and misses faults. Voltage distribution is non-uniform — the first turn sees the most (transmission-line effect), so faults concentrate at coil entry.
- **Fault physics**: a turn-to-turn short reduces inductance L, raising resonant frequency per **f = 1/(2π√LC)**, shifting waveform zero-crossings.
- **Pass/fail via Error Area Ratio (%EAR / %WD)**: pairwise comparison of the three phase surge waveforms. Identical = 0%; slight ~4%; noticeable >10% = fail. **Pulse-to-pulse EAR (ppEAR)** ramps voltage in ~25 V steps (480 V motor: 500→3300 V); "shark-teeth" spikes flag intermittent breakdown.
- **PD-on-surge** detection uses an RF receiver at the zero-volt axis. **VFD relevance**: PWM drives create spikes 2–3× line voltage → void-initiated PD, making surge+PD essential for inverter-fed motors.
- **Schleich**: surge creates a damped sinusoid with winding-characteristic frequency/amplitude/damping; a **spatial probe locates the shorted turn**. Equipment tiers: surge to 3–50 kV, HV DC to 6 kV, IR to 500 GΩ, temperature-compensated resistance, automated Polarization Index (PI).
