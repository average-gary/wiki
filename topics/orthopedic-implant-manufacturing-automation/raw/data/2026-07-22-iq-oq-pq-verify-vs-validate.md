---
title: "IQ/OQ/PQ Process Validation + Verify-vs-Validate Decision Tree"
source: https://www.greenlight.guru/blog/iq-oq-pq-process-validation
source_2: https://www.orielstat.com/blog/medical-device-process-validation/
type: data
tags: [regulatory, process-validation, iq-oq-pq, ghtf, cpk, revalidation, special-processes]
credibility: high
confidence: high
retrieved: 2026-07-22
summary: Operationalizes 820.75 into the IQ/OQ/PQ workflow every automated implant process must pass, the verify-vs-validate decision logic (GHTF-aligned), and revalidation triggers. Notably, automation HELPS PQ (repeatable machine control → high Cpk) even as qualification remains non-negotiable per-process overhead.
---

# IQ/OQ/PQ + Verify-vs-Validate

GHTF-aligned (SG3-N99-10), from established medical-device QMS vendors.

**The decision:** if post-production testing reliably confirms quality → **verification** suffices; otherwise **validation** is mandatory (mirrors 820.75(a) / ISO 13485 §7.5.6). Validation required when end-product tests lack sensitivity, when confirming quality needs **destructive/clinical testing**, or when process capability is unknown/marginal.
- **Validation-required examples** (exactly the implant special processes): sterile package sealing (inspection destroys it), **welding, soldering, heat-treating, plating/coating, injection molding, aseptic filling.**
- **Verification-suitable:** manual cutting, visual PCB inspection.

**The three qualifications:**
- **IQ** — equipment/utilities/instrumentation installed per spec.
- **OQ** — challenges the process across anticipated ranges including **worst-case conditions**; establishes control limits, failure modes, action levels. (Where automation must prove robustness across parameter extremes.)
- **PQ** — demonstrates the process **consistently produces acceptable product under normal production over the long term**; uses statistical tools / process-capability (Cpk/Ppk). **Automation helps here** — tight repeatable machine control yields high Cpk.

**Revalidation / requalification triggers (820.75(c)):** equipment relocation/major repair, **new tooling, software/firmware changes**, utility modifications, calibration failures, repeated deviations, complaint spikes, capacity expansion.

**Automation implication:** IQ/OQ/PQ is the mandatory gate before any automated implant process runs production — non-negotiable overhead **per process, per line, per significant change**.
