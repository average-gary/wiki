---
title: "Acceptance sampling (AQL / Z1.4 / c=0), 100%-inspection driver & ISO 19227 cleanliness"
source: https://meddeviceguide.com/blog/acceptance-sampling-plans-aql-iso-2859-medical-device-guide
source_2: https://measurlabs.com/products/iso-19227-cleanliness-of-orthopedic-implants/
type: data
tags: [inspection, aql, ansi-z1.4, iso-2859, zero-acceptance, 21-cfr-820-250, iso-19227, cleanliness, particulate, spc]
credibility: high
confidence: high
retrieved: 2026-07-22
summary: The statistical-inspection backbone — 21 CFR 820.250 requires valid statistical rationale; ~99% of US firms use ANSI/ASQ Z1.4; Squeglia c=0 (Ac=0/Re=1) plans standard for medical; why safety-critical implant characteristics push toward 100%/c=0. Plus ISO 19227 cleanliness particulate index.
---

# Sampling Statistics + Cleanliness Standards

**Acceptance sampling (why implants trend to 100%/c=0):**
- **21 CFR 820.250** requires sampling plans with a "valid statistical rationale"; persists under QMSR (2026-02-02). **~99% of US device firms use ANSI/ASQ Z1.4** (FDA-recognized, equivalent to ISO 2859-1; both from cancelled MIL-STD-105E).
- Typical **AQL by defect class**: Critical = 0/0.065 (effectively zero acceptance, Ac=0/Re=1); Major 1.0–2.5; Minor 2.5–4.0. Example: 4,000-unit lot, Level II → code L → n=200; AQL 2.5 → Ac=10/Re=11.
- **Squeglia Zero-Acceptance (c=0)** plans (Ac=0/Re=1) standard in medical; index on **LTPD** at 5–10% confidence.
- **100% vs sampling:** sampling's advantage is cost (esp. destructive tests — peel strength, bioburden) + quantified risk (OC curves); it "screens, not improves" quality and doesn't replace validation (IQ/OQ/PQ) or SPC. Safety-critical implant characteristics therefore push toward **100% inspection or c=0**. Switching rules tie to lot history; FDA has issued **Form 483** for ignoring switching rules. Plans trace to ISO 14971 residual risk.

**ISO 19227 cleanliness (orthopedic implants):**
- Quantifies **particulate contamination** in size bins **25–50, 51–100, >100 µm**; a **contamination index** weights bins (0.1/0.2/5.0) for biological significance; blank-corrected; **index must not exceed 90** (limit from DIN EN ISO 8536-4).
- Sampling: **10 samples + blank for validation, 4 for routine** (refs AAMI TIR42). TOC/protein/endotoxin are separate residual/bioburden tests.
