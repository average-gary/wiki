---
title: eHash / Hashpool — Cashu ecash share tokens
type: concept
created: 2026-05-23
confidence: medium
tags: [eHash, hashpool, Cashu, blind-signature, accountless, custodial-mint]
---

# eHash / Hashpool

Bitcoin mining pool that **issues a Cashu ecash bearer token (eHash) for each accepted share** instead of maintaining a per-miner share ledger. Most experimental payout-accounting model in the post-2024 wave.

## Origin and authorship

- **Concept originator**: **EthnTuttle (Ethan Tuttle)** — proposed in [delvingbitcoin.org/t/870](https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870), May 2024. Endorsed in-thread by **Calle (Cashu creator)**. Earlier precursor: [t/110 (Sept 2023)](https://delvingbitcoin.org/t/110), "Fedipool Theorizing" (Fedimint flavor).
- **Original implementer**: **vnprc (Evan)** — created `vnprc/hashpool` November 2024, six months after the proposal. Currently at v0.1.1 (March 2026), 3,511 commits, **testnet4-only, ~12-month tag cadence**.
- **Canonical implementer (May 2026)**: **EthnTuttle himself**, via `PioneerHash/e-sharp` (created Jan 7, 2026). 7 crates + 4 fork submodules, **JDC-as-sub-pool** architecture, dual-trigger payout lifecycle (block OR LN), real LDK+LND+CLN integration, formal SV2 extension protocol (5 new messages, type 0x0100), full E2E test suite, working `ehash` CLI. **Daily commits in May 2026.** *See [[../../raw/articles/2026-05-25-pioneerhash-e-sharp-deepdive|e-sharp deep-dive]].*

There are now **two parallel eHash code streams**: vnprc/hashpool (original, slower) and PioneerHash/e-sharp (canonical, faster). The latter has overtaken the former on solo-mode operation, LN integration, orphan handling, test maturity, and CLI surface.

Status of **e-sharp**: active dev, no mainnet timeline disclosed. Status of **vnprc/hashpool**: testnet4 PoC, possibly quasi-maintained.

*See [[../../raw/articles/2026-05-24-ethntuttle-profile|EthnTuttle profile]] and [[../../raw/articles/2026-05-24-vnprc-profile|vnprc profile]] for the full bios. See [[../../raw/articles/2026-05-24-cashu-mining-application|delvingbitcoin/t/870]] for the original proposal.*

## Architectural inversion

| | Traditional pool (FPPS/PPLNS/TIDES) | Hashpool |
|---|---|---|
| Per-miner ledger | Yes | **No** |
| Share is | A row in a database | **A bearer token** |
| Pool sees miner identity | Yes | **No (Cashu blind sig)** |
| Variance bearer | Pool (FPPS) or miner (PPLNS) | **Tradeable** |

> *"Instead of internally accounting for each miner's proof of work shares, hashpool issues an 'ehash' token for each share accepted by the pool."*

## Mechanism (Cashu BDHKE — NUT-00)

1. Wallet (in SV2 translator proxy) picks secret `x`, blinding factor `r`. Computes `B_ = hash_to_curve(x) + rG`.
2. Pool-mint signs: `C_ = kB_`. **Mint never sees `x` at issuance.**
3. Wallet unblinds: `C = C_ - rK = k·hash_to_curve(x)`. Token = `(x, C)`.
4. To redeem: present `(x, C)` to mint. Mint verifies `k·hash_to_curve(x) == C`, marks `x` spent.

`x` is bound to the share submission. **Mint cannot link issuance-time shares to redemption-time payouts** → privacy property no FPPS/PPLNS pool offers.

## Three-component stack

- Pool-side **mint** (issues blinded sigs; CDK).
- Proxy-side **wallet** (bundles blinded messages with shares; stores token pairs).
- Bitcoin Core 30.2 multiprocess + sv2-tp v1.0.6 Template Provider via IPC + SV2 pool + SV2 translator proxy with Cashu wallet.

## Novel payout dynamic: variance as tradeable asset

eHash tokens **accrue BTC value during a maturity period** after issuance. Miner choices:

- **Hold to maturity** → capture block-luck upside.
- **Sell early on a secondary market** → guaranteed payout (variance offloaded to buyer).

This is a **third payout-schema category** beyond FPPS (pool eats variance) and PPLNS (miner eats variance).

## Cashu NUT references used

- NUT-00 (BDHKE) — core crypto.
- NUT-02 (keysets) — denomination buckets ↔ share-difficulty buckets.
- NUT-04/05 (mint/melt) — issuance and BTC redemption.
- NUT-12 (DLEQ) — wallet verifies mint signed with advertised key.
- NUT-11 (P2PK) / NUT-14 (HTLCs) — conditional eHash redeemable only after block-find resolution.

## Trust assumptions (project's own admission)

> *"The most common criticism ecash faces from bitcoiners is that it is a custodial system. This is absolutely true."*

- Mint can in principle exit-scam or refuse all redemptions.
- **Mint inflation** (issuing eHash unbacked by real shares) is **not technically prevented** — Proof of Liabilities is invoked as a future dependency.
- Defensive framing: accountlessness prevents *targeted* censorship, but not global rugpull.
- Mitigation guidance: "don't store life savings here" — in tension with the use case of accumulating between payouts.

## Settlement design (March 2026)

From `docs/SETTLEMENT_DESIGN.md` — the canonical hashpool payout-schema doc.

### Epoch model

> An epoch = the interval between two consecutive blocks the pool finds. Each epoch has its own ehash currency unit (e.g. `HASH_epoch_42`) backed by a unique CDK keyset.

When the pool finds a block: keyset rotates, quotes settle, new epoch begins.

### Two redemption paths

1. **Ecash path** (default): hold tokens, redeem at mint for BTC-backed ecash post-block.
2. **On-chain path**: open an **accumulating melt quote** with a payout BTC address; tokens are burned into the quote during the epoch.

### Quote state machine

```
CREATED → ACCUMULATING → PAID (address landed in coinbase)
                       → FALLBACK → SETTLED (mint issues ecash)
```

> Burning tokens at contribution time eliminates double-spend by construction.

### Solvency invariant

`Σ ehash redemptions = mint reserve increase`. **No surplus, no deficit.** Verified via NUT-XX / BDK third-party-payment verifier in CDK.

### `BlockFound` SV2 message

New mint↔pool message: `BlockFound{block_hash, keyset_id, coinbase_tx}`. Mint scans coinbase outputs vs accumulating quotes; matched → PAID, unmatched → FALLBACK.

*See [[../../raw/articles/2026-05-24-hashpool-architecture-deep|hashpool architecture deep-dive]] for code-level details.*

## Critiques (deepened — 2026-05-24)

The earlier-noted custody/PoL/inflation risks remain. Additional severity-rated critiques from primary-source pushback:

| # | Critique | Severity |
|---|---|---|
| 1 | **Variance-hedging story unbuilt** — founder admitted on Stacker News *"It's not possible to sell Ecash tokens. I think only swaps for LN."* The "PPLNS-killer" early-sale feature reduces to "the mint will buy it back at whatever price it wants." | **HIGH** |
| 2 | **DLEQ doesn't prevent per-user key equivocation** — mint can run different keysets for different miner cohorts undetectably without out-of-band gossip | **HIGH** |
| 3 | **Mint-as-counterparty captures price discovery** — without a real secondary market, mint sets implicit redemption prices | MEDIUM-HIGH |
| 4 | **Custodial-by-design with maximum dwell-time** — eHash is held until block reward maturity, *maximizing* exposure | **HIGH** |
| 5 | eHash is variable-value, not a fixed accounting unit | MEDIUM |
| 6 | **No proof-of-liabilities** in protocol — Cashu has no PoR/PoL NUT | **HIGH** |
| 7 | Operator-side KYC/AML pressure — block-reward aggregation = MTL/MSB-tier flow | MEDIUM |
| 8 | **Mint can refuse redemptions undetectably** — selectively claim "already spent" with no audit trail | **HIGH** |
| 9 | **Home-mintability problem** — ordinary miners can't run own mint → recreates centralization SV2 was meant to dilute | **HIGH** |
| 10 | Project's own alpha disclaimer (CDK: *"Funds might be lost forever due to bugs"*) paired with concentrated mining payouts = worst-fit risk surface in Cashu ecosystem | **HIGH** |

*See [[../../raw/articles/2026-05-24-hashpool-critiques-deepened|deepened critiques article]] for full citations.*

## Federation path (production-grade variant)

Single-mint custody is the project's biggest risk. **Fedimint** generalizes Cashu to threshold custody by N guardians. Maps onto a federated mining-pool mint where rugpull requires t-of-n collusion.

## Sources

- [[../../raw/repos/2026-05-23-hashpool-vnprc|hashpool repo (overview)]]
- [[../../raw/repos/2026-05-23-cashu-nuts|Cashu NUTs spec]]
- [[../../raw/articles/2026-05-24-cashu-mining-application|delvingbitcoin/t/870 — original eHash proposal]]
- [[../../raw/articles/2026-05-24-ethntuttle-profile|EthnTuttle profile]] — originator
- [[../../raw/articles/2026-05-24-vnprc-profile|vnprc profile]] — implementer
- [[../../raw/articles/2026-05-24-hashpool-architecture-deep|hashpool architecture deep-dive]]
- [[../../raw/articles/2026-05-24-hashpool-news-2024-2026|hashpool news/releases 2024-2026]]
- [[../../raw/articles/2026-05-24-hashpool-critiques-deepened|hashpool critiques deepened]]

## See also

- [[payout-schema-taxonomy]]
- [[variance-and-risk-shifting]]
- [[../topics/payout-design-space|Payout Design Space]]
- [[../decisions/custody-tradeoffs|Custody Tradeoffs]]
