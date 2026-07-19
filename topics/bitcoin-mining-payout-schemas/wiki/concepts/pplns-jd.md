---
title: PPLNS-JD / SLICE
category: concept
created: 2026-05-23
updated: 2026-07-15
verified: 2026-07-15
confidence: medium
volatility: warm
tags: [PPLNS-JD, SLICE, DMND, Demand-Pool, Stratum-V2, JD]
sources:
  - "raw/articles/2026-05-23-dmnd-demand-pool.md"
  - "raw/articles/2026-05-23-dmnd-slice-blog-pplns-jd.md"
  - "raw/repos/2026-05-23-stratum-v2-spec.md"
  - "raw/repos/2026-07-14-demand-share-accounting-ext-github.md"
---

# PPLNS-JD / SLICE

PPLNS variant where shares are bound to **SV2 Job-Declarator-declared jobs** — the miner picks the block template; the pool just counts shares.

Production deployment: **DMND / Demand Pool** as **SLICE**.

## Mechanism

- Miner runs a **Job Declarator Client (JDC)** alongside their mining stack.
- JDC builds a block template (selects transactions from the miner's own mempool).
- JDC sends `DeclareMiningJob` to the pool's **Job Declarator Server (JDS)**.
- Pool returns `DeclareMiningJob.Success` with a token authorizing payout to the miner if the block is found.
- Shares submitted under this job are scored PPLNS-style; if a share *is* a block, the coinbase pays per the JDS-allocated outputs.

This decouples **template construction** (miner) from **payout accounting** (pool) — the spec text in SV2-spec §6 is explicit:

> *"Pools…are only responsible for accounting shares and distributing rewards."*

## Why this changes payout fairness

Under FPPS, the pool decides which transactions go in the block. Under PPLNS-JD, the miner decides — so:
- **Miner captures the tx-fee revenue** they think appropriate (no FPPS averaging).
- **Pool can't censor** (it doesn't see the template content in coinbase-only mode).
- **Slice removes the FPPS subsidy** where miners pay (via fee) for the pool's transaction-filter policies.

## SLICE (DMND) operational claims

- Rejection rate: **0.0151%** (vs. 0.5–2% on Stratum V1).
- ~1–3 ms job-switch latency vs. ~200–300 ms on V1 — direct profitability lift.
- Zero hash-hijack incidents (binary encrypted framing eliminates SV1 plaintext attack).
- "Miners build the block. Miners keep the rBTC."

Operator: Guru Protocol Ltd (UK). Leadership: Alejandro De La Torre (ex-VP Poolin, CEO), Filippo Merli (long-time SRI contributor, CTO).

## Published parameters (DMND blog, March-April 2025)

**N is published** — closed by gap-research 2026-05-23.

- **N = 8 × Bitcoin network difficulty** — *same multiplier as TIDES*. Verbatim from DMND blog (2025-03-18, "Understanding SLICE (PPLNS+JD)"): *"DMND Pool uses the Bitcoin's network difficulty and multiplies it by 8 to create the look back window."*
- **Each share is paid across ~8 successive blocks** on average (8-block rolling window).
- **Share-difficulty target**: ~6 shares/minute per client.
- **Reject rate**: 0.0151% (vs 0.5–2% for typical SV1 pools).

The companion theoretical paper (lorbax/pplns-with-job-declaration) confirms the design rationale: *"N is not specified, but is suggested to be such that the sum at the denominator is a multiple [of] the bitcoin difficulty (for Ocean TIDES this multiple is 8)."* DMND's deployed N matches the TIDES-aligned suggestion.

**TIDES and SLICE converge on N = 8 × D.** Production consensus for "PPLNS done right with non-custodial coinbase payout."

## Still-open gaps

- **BTC-leg pool fee** — not published. The rBTC side-payout is explicit 0% pool cut: *"There is no revenue share. There is no pool wallet sitting in the middle."* The BTC subsidy/fee leg remains undisclosed.
- **Minimum payout / withdrawal threshold** — not published.
- KYB onboarding required (DMND changelog 2026-05-12) — implies fee terms may be **negotiated/contractual** rather than published.

## Comparison to TIDES

Both are PPLNS-derived non-custodial schemes with **identical N = 8 × D**:

| | TIDES (OCEAN) | SLICE (DMND) |
|---|---|---|
| Window N | **8 × D, scales with D** | **8 × D, scales with D** |
| Shares bound to | Pool template (or DATUM) | JD-declared (miner template) |
| Payout custody | None (coinbase) | None (coinbase) |
| Template control | Pool default; DATUM option | Always miner |
| Standard BTC fee | 2% (1% DATUM) | Not published |
| rBTC side-payout | n/a | 0% pool cut |
| Spec doc | Public | Public (blog.dmnd.work, 2025) |

These are **complementary, not competing**. TIDES + DATUM is OCEAN's version of the same idea (PPLNS done right + miner templates).

## Miner-verifiable payout (the accounting extension)

PPLNS-JD as described above still asks the miner to *trust* the pool's window arithmetic. The [[sv2-share-accounting-ext|SV2 Share Accounting Extension]] (extension type 32) closes that gap: it is a wire protocol letting a miner **audit** a reward window by spot-sampling slices and shares and proving each one — share PoW validity, merkle inclusion in the slice root, that summed share difficulty does not exceed the slice's, and that share fees stay within the slice's reference-job fees plus a delta. It is the on-the-wire counterpart to the theoretical PPLNS-with-Job-Declaration design (lorbax/pplns-with-job-declaration) that this article's N = 8 × D discussion draws on. Reference implementation: the `demand-share-accounting-ext` Rust crate (v0.0.13, pre-1.0; activation handshake still TODO). It reduces — but does not fully eliminate — trust in the pool, since a single audit samples only part of the window.

## Sources

- [[../../raw/articles/2026-05-23-dmnd-demand-pool|DMND / Demand Pool article]]
- [[../../raw/articles/2026-05-23-dmnd-slice-blog-pplns-jd|DMND blog — Understanding SLICE (PPLNS+JD), 2025-03-18]] — primary spec for N = 8 × D
- [[../../raw/repos/2026-05-23-stratum-v2-spec|Stratum V2 Specification — §6 Job Declaration]]
- [[../../raw/repos/2026-07-14-demand-share-accounting-ext-github|demand-open-source/share-accounting-ext — SV2 Share Accounting Extension]] — the miner-side payout-verification wire protocol

## See also

- [[pplns]]
- [[tides]]
- [[sv2-share-accounting-ext|SV2 Share Accounting Extension]] — the wire protocol that makes this scheme's payout verifiable
- [[../topics/sv2-jd-and-payout-decoupling|SV2 Job Declaration ↔ Payout Decoupling]]
