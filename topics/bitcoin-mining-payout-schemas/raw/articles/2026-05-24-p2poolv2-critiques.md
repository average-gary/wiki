---
title: "p2poolv2 accounting critiques (delvingbitcoin 2024-2025)"
publication: delvingbitcoin.org
type: article
ingested: 2026-05-24
quality: 5
credibility: high
confidence: high
tags: [p2poolv2, critique, contrarian, market-maker, censorship, latency]
---

# p2poolv2 Accounting Critiques

Steelman critiques from primary Bitcoin developers (Antoine Poinsot, Bob McElrath, AJ Towns, plebhash, vnprc, VzxPLnHqr). Compiled from delvingbitcoin.org threads.

## 1. Dust problem inherited, not solved

**AntoineP** (Antoine Poinsot, Bitcoin Core contributor), in *"Scaling Noncustodial Mining Payouts with CTV"* (delvingbitcoin.org/t/1753):

> "Using CTV to commit to payouts only defers the time at which the payout transaction hits the chain, at the cost of more block space usage."

By extension, p2poolv2's top-N coinbase + atomic-swap design is **congestion control dressed up as scaling**. Every non-custodial payout still consumes L1 blockspace eventually, competing with fee-paying txs.

**plebhash** (chicken-and-egg critique in same thread): Pools cannot determine non-custodial payout shapes without knowing template revenue, but miners cannot signal revenue requirements without knowing blockspace allocation. p2poolv2's atomic-swap layer assumes this is solved; it isn't.

**vnprc** (firmware reality check): Antminer firmware caps coinbase outputs at "just over a dozen." p2poolv2's top-20-then-500 roadmap is **blocked by closed firmware vendors** regardless of consensus design.

## 2. Window-expiry economic asymmetry (small-miner monopsony risk)

**VzxPLnHqr** in *"P2share: how to turn any network (or testnet!) into a bitcoin miner"* (delvingbitcoin.org/t/2093):

> "If, through your trading actions, you cannot become one of those top 20 before the window closes, then all your hashes/trades affecting that window will [be] irrecoverable losses."

**Steelman**: p2poolv2 collapses two distinct goals — variance reduction (favoring expiry) and incentive compatibility (favoring permanent shares) — and resolves both toward the former, sacrificing fairness.

- Paying 100% of mainchain reward to top-20 share holders creates **no obligation for large miners to buy small miners' shares**.
- Atomic-swap liquidity isn't guaranteed; it's assumed.
- No minimum-takeup guarantee, no fallback if market makers collude or refuse to buy specific addresses' shares.
- The constant-issuance alternative VzxPLnHqr proposes is rejected by p2poolv2 implicitly, not refuted.

## 3. Market-maker censorship vector

**Bob McElrath**, *"Deterministic tx selection for censorship resistance"* (delvingbitcoin.org/t/deterministic-tx-selection-for-censorship-resistance):

> "Tx selection is an all downside and no upside problem. Every jurisdiction has someone they don't like."

By extension, p2poolv2's atomic-swap market makers become a transaction-selection chokepoint:

- Market makers buying virgin coins from small miners can refuse to swap shares from sanctioned/disfavored addresses.
- Reproduces OFAC-style filtering inside a "decentralized" pool.
- p2poolv2 does not commit market makers to a non-discrimination rule, nor to a deterministic share-buying algorithm.

**David Harding's pushback**: even *deterministic* tx selection enables out-of-band fee collection and junk-tx censorship — a generalized critique that hits p2poolv2's transaction engine (issue #6) since it doesn't specify how market makers select which shares to swap.

## 4. Latency-adversarial share-chain

**ajtowns** (AJ Towns, Bitcoin Core maintainer), *"Fastest-possible PoW via Simple DAG"* (delvingbitcoin.org/t/1331):

> "Latency isn't a global constant... this approach could work in an adversarial environment."

**For p2poolv2**: its uncle-block scheme intends to capture orphans that linear p2pool would lose, but inherits ajtowns' concern — **uncle inclusion can be gamed by adversarially-timed propagation**. Miners can artificially delay competing shares/uncles to suppress others' payouts. Timestamp-only defenses are insufficient.

p2poolv2 has **no published latency-adversarial analysis**. McElrath's response in the same thread concedes "graph-structure-only" approaches still need timing measurements, which p2poolv2 has not formalized.

## 5. p2pool's structural drawbacks (Braidpool framing)

**Bob McElrath**, Braidpool spec:

> "In p2pool this UHPO set was placed directly in the coinbase of every block, resulting in a large number of very small payments to hashers... the large coinbase with small outputs competed for block space with fee-paying transactions."

p2poolv2 inherits this. Top-N + atomic swap is a **rationing scheme over the same dust problem, not a structural fix**. Braidpool's UHPO-via-covenants approach is the structural fix — but requires CTV.

**Block-withholding mitigation gap**: Braidpool explicitly proposes re-mining nonce ranges of "lowest-luck" miners and slashing detected withholders. **p2poolv2 has no equivalent** — its share-chain accounting can't distinguish withheld-block attacks from variance.

## Cross-cutting failure-mode synthesis

| # | Failure mode | Severity | Sources |
|---|---|---|---|
| 1 | Dust problem inherited (top-N + atomic swap is queue, not fix) | High | AntoineP, McElrath |
| 2 | Market-maker monopsony / censorship | Medium-high | VzxPLnHqr, McElrath |
| 3 | Latency-adversarial share-chain (uncles ≠ DAG) | High | ajtowns, McElrath |
| 4 | Window-expiry economic asymmetry (small miners forced-sale) | Medium-high | VzxPLnHqr |
| 5 | Firmware-vendor blocker (Antminer coinbase cap) | High (operational) | vnprc |
| 6 | Block-withholding undetectable | Medium | McElrath |

## See also

- [[../repos/2026-05-24-p2poolv2-accounting-modules|p2poolv2 accounting source]]
- [[2026-05-24-p2poolv2-trading-shares-htlc|p2poolv2 atomic-swap design]]
