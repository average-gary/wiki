---
title: Notes Index
type: raw-index
created: 2026-07-18
updated: 2026-07-29
---

# Notes

Session-derived lessons-learned and working notes (learned by doing/analyzing, not ingested from external sources).

| Note | Date | Lessons | Summary |
|---|---|---|---|
| [[2026-07-18-ll-proxy-held-vtxo-ark-sv2-extension|Proxy-held VTXO keys + SV2 Ark-claim extension]] | 2026-07-18 | 4 | Proxy holding VTXO keys neutralizes Ark's receiver-presence + expiry blockers (unlocks clArk sans CTV/CSFS) but reshuffles custody; a trust-reducing SV2 claim extension must carry VTXO leaf/path + exclusivity proof, not just the amount. |

## Cross-domain source notes (2026-07-29)

Primary-text reads on non-mining material, kept here because they have no natural `papers`/`repos`/`articles` home.

- [[2026-07-29-self-blinding-system-architectures|Self-blinding system architectures — OHTTP, split-trust relays, multi-vendor TEEs, Prio/DAP]] — 8-row transferability ranking with the trust each substitutes in; the Prio framing correction (population totals vs. exact per-recipient totals); SGAxe/ÆPIC/CVM-SoK on why attestation is weaker than advertised; PCC's log-gated key wrapping as the most transferable mechanism
- [[2026-07-29-fincen-td10000-regulatory-attribution-posture|Regulatory posture on pool attribution — FinCEN, TD 10000, OFAC, compulsion]] — §5.4 exempts pool distributions unless the operator hosts wallets; §4.5.1(a)/(b) make anonymizing transmitters ineligible and blinding a Travel Rule violation; TD 10000's validator carve-out never says "mining pool"; Lavabit and the untested warrant canary
