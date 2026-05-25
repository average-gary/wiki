---
title: "AntPool FPPS adoption history (corrected timeline)"
publication: bitcointalk + AntPool Zendesk + Tovanich 2022
url: https://bitcointalk.org/index.php?topic=1808582.0
url2: https://antpoolsupport-hc.zendesk.com/hc/en-us/articles/5983010227993
type: article
ingested: 2026-05-23
quality: 5
credibility: high
confidence: high
tags: [AntPool, FPPS, PPS+, history, Bitmain, BTC.com]
---

# AntPool FPPS Adoption — Corrected Timeline

The wiki's earlier claim that FPPS became default at AntPool ~2014 was **wrong**. Corrected timeline below.

## Timeline

| Date | Event | Source |
|---|---|---|
| March 2014 | AntPool launches with **PPS + PPLNS only**. No FPPS at launch. | Inferred from absence of FPPS in 2014-2016 records |
| September 2016 | **BTC.com pool** (also Bitmain) launches with FPPS as headline feature. First major pool to popularize FPPS. | Investopedia / CryptoSlate |
| Early 2017 (≤ 2017-02-28) | AntPool adds **PPS+** to homepage payout menu (alongside PPLNS+, PPS -3). PPS+ is the FPPS-equivalent variant: PPS for subsidy + averaged tx-fee bonus. | bitcointalk thread 1808582, dated 2017-02-28 |
| November 2019 | AntPool **on-chain payout topology changes** chain-like → tree-like. Backend overhaul preceding the formal "FPPS" labeling. | Tovanich et al. IEEE TVCG 2022 |
| **July 13, 2020** | AntPool adds payout method **explicitly labeled "FPPS"** distinct from PPS+. | AntPool Zendesk |

## What this changes for the wiki

Previous claim:
> "FPPS became default at AntPool ~2014."

Corrected claim:
> AntPool launched in March 2014 with PPS + PPLNS only. **PPS+** (FPPS-equivalent) appeared on AntPool's homepage by Feb 28, 2017. A payout method explicitly named **"FPPS"** was added July 13, 2020. **BTC.com** (also Bitmain) shipped FPPS earlier — September 2016 — and is the historical "first major FPPS pool."

## Why the correction matters

- The "FPPS dominance since 2014" framing overstates how long custodial FPPS-class schemes have been the default.
- The actual transition to FPPS-class default was **2016-2017** (BTC.com → AntPool PPS+ → wider industry).
- This puts FPPS dominance at ~10 years (2016-2026), not ~12.
- It also means the **fee-era inflection (~2032 post-subsidy) gives FPPS roughly the same length of dominance as it has had so far** — bolsters the "FPPS is structurally fragile" argument.

## Sources

1. **bitcointalk thread 1808582** — *"new antpool payout types PPS+, PPLNS+, PPS -3"*. Dated 2017-02-28. Quality 5 (primary, dated forum post).
2. **AntPool Zendesk article** — *"Miners Settings & Fees"*. Direct quote (via search snippet): *"FPPS (with effect from July 13, 2020)"*. Quality 5 (primary).
3. **Tovanich et al., IEEE TVCG 2022** — *Visual analytics of bitcoin mining pool evolution*. Documents the November 2019 chain → tree topology change. Quality 4.
4. **Investopedia / CryptoSlate** profiles — BTC.com FPPS launch September 2016. Quality 3 (secondary).

## See also

- [[../../wiki/concepts/fpps|FPPS concept article]] — needs correction
- [[../../wiki/topics/why-fpps-dominates-but-is-fragile|Why FPPS Dominates topic]]
