---
title: "Audit-Friendly vs Audit-Hostile FPPS — production landscape May 2026"
publication: medinaseri.substack.com + Antpool Zendesk + ocean.xyz
url: https://medinaseri.substack.com/p/bitcoin-mining-pool-payout-methods
type: article
ingested: 2026-05-23
quality: 4
credibility: medium
confidence: medium
tags: [FPPS, audit, auditable-FPPS, rolling-average, transparency]
---

# Audit-Friendly vs Audit-Hostile FPPS

## Naseri's distinction (verbatim)

- **Auditable FPPS** settles "24-hour interval at the end of each day UTC time… easy to audit with 0% error."
- **Rolling-average FPPS** uses "the average transaction fees for the past 144 blocks on a rolling basis… hard to audit."
- "If the pool settles payment every 30 min, you need to audit and calculate earnings 48 times a day which will make it almost impossible to audit."

Formula identical to standard FPPS, except the fee term is `24h average tx fees per block` (auditable) vs `144-block rolling average` (rolling).

Naseri names **only Lincoin** as offering Auditable FPPS "with all the necessary data that enables miners to verify their earnings without trusting the pool."

## Production landscape

| Scheme | Pool examples | Settlement | Miner-visible audit data | Trust requirement |
|---|---|---|---|---|
| **Auditable FPPS (24h)** | Lincoin (claimed); Antpool de-facto | 1×/day UTC | Per-account dashboard + CSV export; **no public cryptographic proof** | Trust pool's hashrate & difficulty inputs |
| **Rolling-average FPPS** | Most large pools (F2Pool, ViaBTC, Foundry; exact cadence undocumented publicly) | up to 48×/day | Per-account dashboard only | Trust pool fully; reconstruction "almost impossible" |
| **TIDES (non-custodial)** | OCEAN | Per-block via coinbase | On-chain coinbase = ledger; share log published by pool | Trust share-log integrity (mitigated by SV2 JD) |
| **SLICE** | DMND | Per-block | Same as TIDES + cryptographic share commitments | Lower; still pool-published shares |

## Key findings

1. **No production pool has published a public-audit framework or proof-of-reserves/liabilities for FPPS** as of May 2026. "Auditable FPPS" today means **cadence-friendly** (24h snapshot), not **cryptographically provable**.
2. **Lincoin's "Auditable FPPS" is a product label**, not a verifiable scheme. No signed merkle root, no PoR, no published audit report URL surfaced. Naseri (the article's author) is **affiliated with Lincoin** — the article doubles as marketing.
3. **Antpool's daily-settled FPPS** is structurally the same audit-friendly variant Naseri praises, but data is login-gated → **internal-only**. Third-party tools (Foreman) audit via the miner's own API key — same internal data, externally rehosted. Aligns with Naseri's "Auditable FPPS" cadence even though Antpool doesn't use that label.
4. **Non-custodial coinbase schemes (TIDES, SLICE) are categorically more auditable** than any FPPS variant because the on-chain coinbase tx *is* the payout receipt — no need to trust a pool dashboard. From OCEAN's TIDES doc:
   > FPPS is "completely opaque and nearly impossible to accurately verify"; TIDES is "provably fair… If a pool were running TIDES and it ended up not being 100% fair, it would be immediately obvious."
5. **Residual trust under TIDES/SLICE**: per [delvingbitcoin "PPLNS with Job Declaration"](https://delvingbitcoin.org/t/pplns-with-job-declaration/1099) — *"all of the validation data being used by miners is given out by the pool"* / *"what prevents a pool from diluting shares within a slice/window?"* Job Declaration (SV2) is the proposed mitigation, allowing miners to construct templates and verify their own share inclusion. Audit-trust collapses further under SV2 JD.

## Comparison line

The audit-friendly-FPPS vs audit-hostile-FPPS distinction is **real and useful for compliance reporting**, but does not close the trust gap that TIDES/SLICE close at the protocol layer. The custody-trust ceiling for FPPS is high regardless of audit cadence.

## Sources

1. **Naseri (2023, re-fetched 2026-05-23)** — taxonomy. Quality 4.
2. **Lincoin marketing page** — same article re-hosted. Quality 2 (marketing).
3. **Antpool Zendesk** — daily settlement docs. Quality 3.
4. **OCEAN TIDES docs** — non-custodial framing. Quality 4.
5. **delvingbitcoin "PPLNS with JD"** — residual-trust critique. Quality 4.

## See also

- [[../../wiki/concepts/fpps|FPPS]]
- [[../../wiki/concepts/tides|TIDES]]
- [[../../wiki/decisions/custody-tradeoffs|Custody Tradeoffs]]
