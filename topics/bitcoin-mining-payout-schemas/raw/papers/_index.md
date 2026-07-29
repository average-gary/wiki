---
title: Papers
type: raw-index
---

# Papers

- [[2026-05-23-rosenfeld-2011-pool-reward-analysis|Rosenfeld 2011 — Analysis of Bitcoin Pooled Mining Reward Systems]] (foundational)
- [[2026-05-23-schrijvers-2016-incentive-compatibility|Schrijvers et al. FC'16 — Incentive Compatibility]]
- [[2026-05-23-eyal-2015-miners-dilemma|Eyal IEEE S&P'15 — The Miner's Dilemma]]
- [[2026-05-23-eyal-sirer-2014-selfish-mining|Eyal & Sirer 2014 — Majority is Not Enough]] (selfish mining)
- [[2026-05-23-kwon-2017-faw|Kwon et al. CCS'17 — Fork After Withholding (FAW)]]
- [[2026-05-23-chatzigiannis-2022-diversification|Chatzigiannis et al. 2022 — Diversification Across Mining Pools]]
- [[2026-05-24-fiberpool-2025|FiberPool — Sakurai & Shudo 2025 (formal-properties baseline)]]
- [[2026-05-26-kiayias-aft-2025-shapley-oceanic-games|Kiayias et al. AFT'25 — Shapley Value vs Proportional in Oceanic Games]]
- [[2026-05-26-keer-maffei-ark-formal-arxiv|Keer, Maffei, Argentieri, Camilleri, Avarikioti — Ark formal model (arXiv 2026)]]

## Attribution privacy round (2026-07-29)

- [[2026-07-29-recabarren-carbunar-hardening-stratum|Recabarren & Carbunar PETS'17 — Hardening Stratum]] — StraTap 1.75–6.5 % and ISP-Log 0.53–34.4 % payout-prediction error; VarDiff calibration is the side channel; BiteCoin share hijacking and the Bedrock mining cookie
- [[2026-07-29-romiti-2019-mining-pool-payout-deanonymization|Romiti et al. WEIS'19 — Deep dive on BTC.com/ViaBTC/AntPool payouts]] — 92 %/75 %/30 % of individual miners identified from public chain data with no pool cooperation
- [[2026-07-29-bba-plus-black-box-wallets|BBA+ (CCS'17) / Black-Box Wallets (PoPETs 2020-0010)]] — the only primitive that natively accumulates quantitative weight; 16-bit prototype balance, ROS attack, Tor PoW micropayments. **Two entries retracted 2026-07-29** — see the correcting read below
- [[2026-07-29-maurer-2017-knapsack-coinjoin-arbitrary-values|Maurer et al. TrustCom'17 — Anonymity in CoinJoin with arbitrary values]] — plus WabiSabi (eprint 2021/206) and CoinJoin Sudoku; why a coinbase is a strictly easier subset-sum instance
- [[2026-07-29-withholding-detection-does-not-need-attribution|Withholding detection vs. attribution — Eyal, Rosenfeld, APoW, Towns]] — attribution-based detection already fails under full identity; Eligius 2014 address clustering is the one exception

## Blinded share-credit thesis round (2026-07-29)

Every source here corrects something in the round above. See
[[../../output/report-blinded-share-credit-thesis-2026-07-29|the round report]].

- [[2026-07-29-bedrock-primary-read-cookie-construction|Bedrock primary read — where the cookie actually goes]] — §8.3 selects the literal 32-byte prevout hash and **declines the scriptSig by name**, so the scheme is consensus-invalid for the share that is a block; no hardness assumption is named anywhere (§7.1 is a work-equivalence argument); the cookie rotates only on block-find (**~7.44 years for an S7**); and `store(M.uname, K_M, R_M, target)` keys the **vardiff target on identity**, breaking share *validation* upstream of crediting
- [[2026-07-29-stateful-vs-oneshot-credentials-no-separation|No separation between stateful accumulation and one-shot issuance]] — searched five ways for a lower bound; none exists, and two measured constructions put an update at ~1.2–1.4× an issuance. **Inverts** the Canard–Gouget "impossibility" (the BBA line cites it as the reason issuer and accumulator *must* share one key — Faller et al., IMACC 2021; the impossible notion is *Perfect* Anonymity, scoped to coin transfer between users) and retracts the ROS-breaks-ACL claim (retracted by the ROS authors; ACL now proven concurrently secure). Corrects ROS to **ℓ = 9**, not 256, and identifies **Chaum–Pedersen EUROCRYPT '92** as the "coins must grow" result people actually mean
- [[2026-07-29-blinded-accumulation-cost-at-real-share-rates|Blinded accumulation cost at real share rates]] — the quantitative re-read. **`Add` is 62 ms / 45 ms / 1,745 B, not `Sub16,lin`'s 122/182/~4 kB** — a 4.04× overstatement of pool-side credit cost; the 16-bit range limit binds **redemption only** (BBW Fig. 4 p.174); 7.2 cores at F2Pool scale batched at SV2's shipped `share_batch_size = 10`; measured share rates with vardiff sources, and SV2's `new_shares_sum` U64 as the value to credit
