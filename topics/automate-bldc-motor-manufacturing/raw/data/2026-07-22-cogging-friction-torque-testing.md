---
title: "Cogging & Friction Torque Testing System (Vali Dynamics)"
source: https://www.validynamics.com/mctf/
type: data
tags: [cogging-torque, friction-torque, eol-test, fft, test-bench]
credibility: medium
confidence: high
retrieved: 2026-07-22
summary: Hard numbers on how cogging/detent and friction torque are automatically measured with FFT and limit-based pass/fail.
---

# Cogging & Friction Torque Testing (Vali Dynamics)

- **Cogging torque** measured peak-to-peak (magnet-pole/tooth interaction, unpowered); **friction torque** measured as average (bearings, assembly tolerance, brush friction).
- Method: a precision reduction motor back-drives the DUT at **0.5–20 rpm** while measuring torque vs angular position (CW/CCW/bidirectional under software).
- Accuracy: torque sensor **0.1% F.L.**, angle **0.01°**; sampling 48,000 pts/rev at 0.5 rpm; torque ranges **10 mN·m to 10 N·m**.
- Software outputs angle-torque + polar charts + **FFT**, stores/compares up to 5 curves, exports Excel/TXT, **pass/fail against customizable preset limits**.
