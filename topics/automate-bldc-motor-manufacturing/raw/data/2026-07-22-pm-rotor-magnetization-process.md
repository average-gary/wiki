---
title: "Magnetization Process for PM Rotors (Electric Motor Engineering)"
source: https://www.electricmotorengineering.com/magnetization-process-for-pm-rotors/
type: data
tags: [magnetization, post-assembly, capacitor-discharge, magnetizing-fixture, eddy-currents]
credibility: high
confidence: high
retrieved: 2026-07-22
summary: Best vendor-neutral explanation of why post-assembly magnetization dominates automated lines and how CD magnetizers + fixtures work.
---

# Magnetization Process for PM Rotors

- Endorses **post-assembly (in-situ) magnetization** as the automation-friendly path: rotors are assembled with **unmagnetized** magnets, then run through a cycle of "positioning, magnetization, measurement, and extraction" inside the production line.
- **Magnetizers are capacitor-discharge (CD) pulse supplies**: power capacitors with charge/discharge units. Configuration tradeoff — **low-capacitance/high-voltage vs high-capacitance/low-voltage** — chosen by the electrical conductivity of the magnet material + surrounding parts to control **eddy-current effects** during the pulse.
- **Magnetizing fixtures/yokes are custom per rotor geometry** (V-shape/IPM, spoke-type, surface-mount). Drivers: pole count, rotor skew, stack height, magnet material.
- Different materials need different **saturation fields (Hsat)**: NdFeB, SmCo, ferrite, Alnico each drive different magnetizer energy + fixture thermal/stress limits.
- **Structural safety factor 3–4× Von-Mises limit** on fixtures because the pulse + post-magnetization forces impose large mechanical loads.
- QC: **embedded flux sense coils** verify rotor flux immediately post-magnetization, integrated with mechanical inspection.
