---
title: "UDI Direct Marking (21 CFR 801.45), Part 11 e-records, QMSR & EU MDR — traceability regime"
source: https://www.law.cornell.edu/cfr/text/21/801.45
source_2: https://www.law.cornell.edu/cfr/text/21/part-11
source_3: https://omtech.com/blogs/business-ideas/fda-compliant-laser-marking-best-practices-for-medical-tools
source_4: https://www.greenlight.guru/blog/qmsr-quality-management-system-regulation
type: data
tags: [regulatory, udi, laser-marking, 21-cfr-part-11, audit-trail, dhr, qmsr, eu-mdr, traceability]
credibility: high
confidence: high
retrieved: 2026-07-22
summary: The traceability/data-integrity leg — UDI direct-marking (permanent, on-device, plain-text + Data Matrix), laser marking as the de-facto method with implant-specific safety limits, Part 11 audit trails on all automated data capture, and the QMSR (Feb 2026) / EU MDR framework context.
---

# UDI Direct Marking + Part 11 + QMSR/EU MDR

**UDI direct mark (21 CFR 801.45):** reprocessed-and-reused devices and **implantable devices** must bear the UDI **permanently on the device**, as **(1) plain text and/or (2) AIDC** (Data Matrix). Exceptions: interferes with safety/effectiveness, not technologically feasible, or single-use with further processing. Framework: **21 CFR Part 830**; QMSR adds **820.45** labeling/packaging.
- UDI = **Device Identifier (DI)** + **Production Identifier (PI)** (lot/batch, serial, mfg/exp date), machine-readable (~3mm² Data Matrix, cell 0.1–0.15 mm) + human-readable (≥1.5 mm chars).

**Laser marking = de-facto method:** chemically bonded, resistant to sterilization/cleaning/wear/implantation. **MOPA fiber laser annealing** on stainless/Ti makes dark high-contrast marks via subsurface oxide **without removing material, altering roughness, or compromising passivation**; UV lasers for polymers.
- **Implant-specific safety limits that bound automation:** marks must not create **bacteria-trapping crevices** or **passivation-compromising corrosion sites**; on load-bearing geometry, engraving stays shallow **(0.02–0.05 mm)** to avoid **stress concentration**. Marking is a **validated special process**; legibility verified with a calibrated 2D reader **before and after every sterilization cycle**.

**Part 11 (electronic records/signatures):**
- §11.10 (closed systems): **validated systems**, secure computer-generated **time-stamped audit trails**, record protection/retention, **authority checks**, operational checks. §11.50/11.70 signature manifestation + non-detachable linking; §11.300 ID/password.
- *Automation implication:* the moment an automated line records data (machine logs, SPC, PQ results, e-batch records, MES, UDI serialization) it becomes an **electronic record** — forcing audit trails on every automated data capture and validated integrity, feeding lot-traceable **DHRs (820.184) / DMR (820.181)**. Dovetails with 820.70(i)/CSA.

**Framework context:**
- **QMSR** (Final Rule effective **Feb 2, 2026**) incorporates **ISO 13485:2016 by reference**, replacing the 1996 QSR. Adds 820.7/820.10/820.35/820.45. DHR/DMR/DHF no longer explicitly named (covered by ISO "Medical Device File"). **ISO 13485 certification ≠ QMSR compliance** — FDA inspections still apply. Validation substance (820.75, 820.70(i)) survives intact.
- **EU MDR (2017/745):** ortho implants generally **Class IIb/III**, need QMS (ISO 13485) + Notified Body assessment + **EUDAMED**/EU-UDI. Article 18 implant card — but **screws, wedges, plates, wires, pins, clips, connectors are exempt** (Art. 18(3)). A dual-market automated line must satisfy both UDI/traceability regimes.
