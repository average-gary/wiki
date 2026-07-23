---
title: "21 CFR 820.75 — Process Validation (primary text)"
source: https://www.law.cornell.edu/cfr/text/21/820.75
type: data
tags: [regulatory, fda, process-validation, 21-cfr-820, iq-oq-pq, revalidation, qmsr]
credibility: high
confidence: high
retrieved: 2026-07-22
summary: The load-bearing regulatory clause — where a process output "cannot be fully verified by subsequent inspection and test," it must be validated with a high degree of assurance. This is the fulcrum that makes nearly all implant special processes legally mandatory to validate, wrapping every automated cell in an IQ/OQ/PQ envelope.
---

# 21 CFR 820.75 — Process Validation

Primary regulatory text (Cornell LII). The fulcrum of the whole "how far can you automate" question.

- **820.75(a)** — "Where the results of a process **cannot be fully verified by subsequent inspection and test**, the process shall be validated with a **high degree of assurance** and approved according to established procedures." Documentation: validation activities, results, dates, signatures of approvers, equipment used.
- **820.75(b)** — validated processes must be **monitored and controlled**; performed by **qualified individuals**; monitoring methods/data/dates/personnel/equipment documented.
  - *Automation implication:* even a lights-out cell needs qualified human oversight of process parameters — you remove the human from the material-handling loop, not the control loop.
- **820.75(c)** — on **changes or process deviations**, review/evaluate and **revalidate where appropriate**.
  - *Automation implication:* every firmware update, tooling swap, or robot re-teach potentially triggers revalidation — the hidden operating cost of automated lines and a pressure toward locked-down, change-controlled configurations.

**Overall automation implication:** implant "special processes" — machining Ti-6Al-4V/CoCr, additive/EBM, HIP, passivation, plasma/HA coating, laser welding, cleaning, terminal sterilization — nearly all produce outputs you cannot 100% non-destructively inspect, so they are **legally mandatory to validate**. Automation is always wrapped in an IQ/OQ/PQ envelope. Under QMSR (Feb 2026) this migrates conceptually to ISO 13485 §7.5.6 but the substance is intact.
