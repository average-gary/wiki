---
title: "21 CFR 820.70(i) — Automated Processes / Software Validation"
source: https://kneat.com/articles/regulatory/21-cfr-820-70i-automated-processes-software-controls-compliance-guide/
source_2: https://www.law.cornell.edu/cfr/text/21/820.70
type: data
tags: [regulatory, fda, software-validation, csv, 21-cfr-820, mes, plc, robot-controller, machine-vision, qmsr]
credibility: high
confidence: high
retrieved: 2026-07-22
summary: 820.70(i) requires validating computer software used in production/QMS for its intended use, and all software changes before approval. The software layer of every automated cell is independently regulated on top of the physical process validation — a robotic cell needs both process PQ and control-software validation.
---

# 21 CFR 820.70(i) — Automated Processes / Software

- Verbatim: "When computers or automated data processing systems are used as part of production or the quality system, the manufacturer shall **validate computer software for its intended use** according to an established protocol. **All software changes shall be validated before approval and issuance.**"
- In-scope automation stack: **MES, LIMS, SPC software, automated inspection/test equipment, environmental monitoring, calibration management** — and by extension **PLCs, SCADA, CNC controllers, robot controllers, machine-vision systems**.
- *Automation implication:* the software layer of every automated cell is **independently regulated on top of** physical process validation. A robotic deburring cell requires **both PQ of the deburring process AND validation (CSV/CSA) of its control software**.
- "Intended use" is the anchor — risk scales with what the software touches (product quality vs. mere record-keeping).
- **QMSR (effective Feb 2, 2026)** folds this into ISO 13485 (§4.1.6 for QMS software, §7.5.6 for production software) while preserving substance. Firms referencing "820.70(i)" should update terminology before Feb 2026.
