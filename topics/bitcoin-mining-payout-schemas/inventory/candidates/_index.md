---
title: Candidates
type: index
updated: 2026-08-14
---

# Candidates (5 — 4 active/open, 1 closed)

| File | Kind | Status | Priority | Next Action | Updated |
|------|------|--------|----------|-------------|---------|
| [coinbase-native-stealth-payout.md](coinbase-native-stealth-payout.md) | question | open | p2 | Pick the sender-point variant — 33 B ephemeral key in coinbase scriptSig vs. 0-byte one-time hot key at `txOut[0]` swept at maturity (the pool's real fee key is out: cold/threshold custody and per-block ECDH are mutually exclusive). Then write it as a diff against BIP 352's Sender/Receiver sections with BIP 34 height as the nonce. | 2026-08-14 |
| [batched-credit-timing-leak.md](batched-credit-timing-leak.md) | question | active | p1 | Quantify hashrate recoverability from batched credit timing — simulate fixed vs Poisson-randomized boundaries at `b ∈ {10, 72, 1271}` against R&C's 0.53–34.4 % ISP-Log baseline. | 2026-07-29 |
| [doj-1960-noncustodial-enforcement-theory.md](doj-1960-noncustodial-enforcement-theory.md) | question | active | p1 | Retrieve the Samourai §1960 theory from CourtListener/RECAP (justice.gov 403/404) and reconcile against FinCEN §5.4. | 2026-07-29 |
| [canard-gouget-primary-text.md](canard-gouget-primary-text.md) | ingest-candidate | active | p3 | Obtain Canard & Gouget, *"Anonymity in Transferable E-Cash,"* ACNS 2008 pp.207–223 via institutional access; confirm the theorem number and exact scope. | 2026-07-29 |
| [blinded-mining-cookie-security.md](blinded-mining-cookie-security.md) | question | **ingested** *(answered — see `resolved: 2026-07-29`)* | p1 | None — closed 2026-07-29 by the thesis round on its third close-out condition, in narrowed form. | 2026-07-29 |
