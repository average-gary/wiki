---
title: Ark for Mining Payouts
category: concept
created: 2026-05-26
confidence: medium
tags: [ark, vtxo, second-tech, ark-labs, mining-payouts, hypothetical-payout-layer]
volatility: warm
updated: 2026-07-17
verified: 2026-07-17
sources:
  - "raw/articles/2026-05-26-ark-burak-original-proposal-2023.md"
  - "raw/articles/2026-05-26-ark-erik-de-smedt-ctv-csfs-delving.md"
  - "raw/articles/2026-05-26-ark-labs-tether-funding.md"
  - "raw/articles/2026-05-26-ark-pickhardt-channel-factory-delving.md"
  - "raw/articles/2026-05-26-bitcoinmag-second-bark-mining-payouts.md"
  - "raw/articles/2026-05-26-carvalho-credible-exit-blockspace.md"
  - "raw/articles/2026-05-26-second-tech-ark-intro.md"
  - "raw/articles/2026-05-26-vnprc-ctv-coinbase-delving.md"
  - "raw/papers/2026-05-26-keer-maffei-ark-formal-arxiv.md"
  - "raw/repos/2026-07-17-coinbase-playground-readme.md"
---

# Ark for Mining Payouts

**TL;DR**: Ark is a Bitcoin off-chain transaction-batching protocol with two competing implementations and a fresh formal academic spine ([[../../raw/papers/2026-05-26-keer-maffei-ark-formal-arxiv|Keer-Maffei-Avarikioti arXiv 2026]]). The "Ark for mining payouts" application is **a Second.tech marketing thesis named exactly once in public** (Bitcoin Magazine, April 2026) — no pool operator has endorsed it, no working spec exists, and structural critiques (capital lockup, expiry sweep, exit-cost asymmetry, receiver-presence requirement) suggest it does not cleanly fit the mining-pool payout cadence.

## Background

The wiki's [[ehash|eHash]], [[parasite-pool|Parasite Pool]], [[tides|TIDES]], and [[p2pool-share-chain|p2poolv2]] entries cover Cashu mints, Lightning channels, and direct on-chain coinbase fanout as payout layers. Ark would be a fourth layer.

The mining-payout angle for Ark surfaced via [[../../raw/articles/2026-05-26-vnprc-ctv-coinbase-delving|vnprc's CTV-coinbase Delving thread]] (June 2025), where:

- **AntoineP** argued "Ark with VTXOs is the actual scalability answer; CTV-coinbase is congestion control, not scaling."
- **ErikDeSmedt** (Second.tech CTO) proposed a hybrid: CTV in the coinbase pays into a transaction tree of VTXOs; miners hold VTXOs off-chain until they accumulate ~0.01 BTC, then settle one UTXO on-chain.

## Two-camp landscape

| | **Second / Bark** | **Ark Labs / Arkade** |
|---|---|---|
| Founders | Steven Roose (CEO), Erik De Smedt (CTO) — both ex-Blockstream | Burak Keceli (`brqgoo`) |
| Funding | $5.1M private (Apr 2026) | $7.7M cumulative; **Tether-led $5.2M** Mar 2026 |
| Pitch | Payments / payroll / **mining payouts** / Lightning | Stablecoins / programmable finance |
| Repo | `gitlab.com/ark-bitcoin/bark` | `github.com/arkade-os` |
| Mainnet | "Soon" Apr 2026; signet only | Arkade live since Oct 2025 |
| Variant | clArk (covenantless) + hArk (hash-locked, CTV+CSFS) | Arkade variants |
| Mining payouts | Named once (BitMag Apr 2026) | Not mentioned |

## Variants

| Variant | Activation gate | Receiver presence | Issuer |
|---|---|---|---|
| **clArk** | None — works today | **Required** (presence-of-eventual-owner) | Second's bark |
| **hArk** | CTV + CSFS | Async (delegated refresh) | Second (Feb 2026) |
| **Erk** | CTV + CSFS | Async, single-input/output | Second (proposal) |
| **Arkade** | Covenant-conditional | Mixed | Ark Labs |

For mining payouts, **clArk is fatal**: a pool cannot issue VTXOs to miners who are offline, which is the entire problem you'd want Ark to solve.

## Quantitative claims (from formal model)

Per [[../../raw/papers/2026-05-26-keer-maffei-ark-formal-arxiv|Keer-Maffei-Avarikioti 2026]]:

- **Constant-sized onchain commitment**: ~200 vB per round regardless of how many VTXOs are batched.
- **Cooperative exit**: 1 output per user.
- **Unilateral exit**: O(log n) txs of ~150 vB per VTXO.
- **No all-user interaction per round** — only signatures from users involved in a transaction + the operator.

Per `arkd` defaults:

- **Round capacity**: 128 participants per round.
- **Session duration**: 30 seconds.
- **VTXO tree expiry**: ~7 days (`arkd`) or ~4 weeks (`bark`/Second docs).
- **Unilateral exit delay**: 24 hours.

## Critiques specific to mining payouts

### 1. Receiver-presence requirement (clArk only)
[[../../raw/articles/2026-05-26-ark-erik-de-smedt-ctv-csfs-delving|De Smedt + Roose admit]] clArk requires "the presence of the eventual owner" to issue a VTXO. Pools cannot push payouts to absent miners. **Gates the entire use case on CTV+CSFS activation.**

### 2. VTXO expiration vs intermittent miner UX
- arkd default 7-day expiry; Second's bark spec 4-week expiry.
- Bitcoin Magazine quote (Apr 2026): "Wallets need to come online at least once a month."
- A Bitaxe-class miner that wakes once a quarter to mine for a day **loses VTXOs to expiration sweep** unless the pool runs delegated-refresh (hArk-style watchtower) — which itself reintroduces operator trust.
- Per [[../../raw/articles/2026-05-26-ark-pickhardt-channel-factory-delving|Pickhardt]]: VTXOs release liquidity only after timeout, binding the ASP's capital for the entire expiry window.

### 3. Asymmetric exit cost (roasbeef)
"Cost for a user to attempt a malicious exit is low, while the cost for the server to retaliate is high." For a mining pool acting as ASP, many small malicious miners can DoS the tree-unrolling defense.

### 4. Capital lockup (Pickhardt)
ASP must front capital proportional to **in-flight VTXO value × expiry window**. A pool acting as ASP carries the full liquidity burden when miners go offline. Output multiplication forces ASP to front substantially more capital than transaction volume.

### 5. Settlement cadence misalignment
Round cadence (minutes-to-hours, operator-set) is misaligned with block cadence (~10 min) for share-payout granularity. A pool would have to choose: settle every block (defeats the point), every N blocks, or only on miner-initiated exits.

### 6. Conservation of blockspace (Carvalho)
Per [[../../raw/articles/2026-05-26-carvalho-credible-exit-blockspace|Credible Exit & Conservation of Blockspace]]: there is a hard cap on how many users a layer can support trust-minimized given finite L1 blockspace for forced exits. With thousands of small miners and per-exit weight ~hundreds of vBytes, only a fraction can credibly exit in any reasonable window. **The unilateral-exit guarantee Ark advertises does not survive contact with mining-pool-scale population sizes.**

### 7. Out-of-round payment trust
Per [[../../raw/articles/2026-05-26-ark-erik-de-smedt-ctv-csfs-delving|roasbeef]]: out-of-round / "arkoor" payments require "trust server and prior owner to not collude." Payment chains between rounds inherit double-spend risk.

## Proxy-held VTXO keys (session analysis, 2026-07-18)

A recurring design instinct is to have an **always-online mining proxy hold the VTXO keys** and issue/refresh VTXOs on miners' behalf. Lessons from analyzing this against the wiki (see [[../../raw/notes/2026-07-18-ll-proxy-held-vtxo-ark-sv2-extension|lessons note]]):

- **It neutralizes both structural blockers at once and unlocks clArk without a soft fork.** An always-online proxy is the "present receiver" at issuance (killing the receiver-presence blocker) and runs the delegated refresh (killing expiry-sweep). Because presence is solved *without* covenants, covenantless **clArk becomes viable for mining today** — removing the CTV/CSFS activation dependency that gates the coinbase→VTXO-tree route.
- **But it is a custody reshuffle, not trust-minimization.** If the proxy holds keys, the miner trusts the proxy (exit-scam, cosign-refusal, seizure). Per [[../decisions/custody-tradeoffs|custody tradeoffs]] this lands between Lightning-custody (Parasite) and mint-custody (eHash) — *not* the no-custody coinbase tier (TIDES/SLICE). The sharp question becomes "what does proxy-held Ark buy over Lightning-custody or a Cashu mint?" — both more mature, same trust profile.
- **The custody topology is a forced binary.** Either proxy-sole-holder (fully custodial, no miner unilateral exit) *or* proxy-co-signer with miner co-key (non-custodial, but miner-presence returns for exit/refresh). "Proxy handles everything offline" AND "miner trustlessly in control" are mutually exclusive.

## Counter to "Ark > CTV" framing

The combined critiques show: **covenant-free Ark can't issue to absent receivers and is DoS-prone**, so the "Ark instead of CTV" framing only holds if you assume covenant-using Ark, which has the same activation dependency as CTV-coinbase. The "Ark > CTV" claim collapses into "Ark + CTV > CTV alone" — which is much weaker and not obviously true for mining payouts where the receiver-presence and round-cadence problems dominate.

## Comparison: Ark vs Lightning vs Cashu as mining payout layer

| Dimension | Ark | LN custody (Parasite) | Cashu mint (eHash) |
|---|---|---|---|
| Custody during dormancy | ASP-held in shared UTXO; presigned exit | Pool LN hot wallet | Mint holds backing BTC; bearer tokens at user |
| Liveness assumption | ASP must cooperate for refresh + cheap exit | LN counterparty must be online | Mint must be online to mint/melt; tokens transfer offline |
| Round cadence | Periodic batch-swaps (operator-set) | Continuous push | Continuous |
| Exit cost & timing | Coop: cheap. Unilateral: tree + 24h timelock + fees. Refresh: charges interest | Channel close + 1–2 wk CSV | Melt to LN (cheap, instant) iff mint cooperates; no unilateral on-chain exit |
| Soft-fork dependency | clArk: none. hArk/Erk: CTV+CSFS | None | None |
| Production maturity | Alpha-to-beta (signet/mainnet demos 2024–2026) | Mature (~7 yrs) | Production (Nutshell, Cashu.me live) |
| Bearer-token property | Weak (V-PACK adds verifiable backup but no anonymous transfer) | None | **Strong** (blind-signed Chaumian ecash) |
| Best-fit for mining pool | Mid-frequency, mid-size payouts to active miners with Ark wallets | Small/frequent payouts to LN-online miners | Smallest/most-frequent micropayouts |

## Position in the wiki taxonomy

Ark joins the **on-chain payout-fanout primitives** axis alongside CTV-coinbase fanout — it's an *alternative* layer for distributing the coinbase to many miners, orthogonal to the share-accounting scheme (PPLNS / TIDES / SLICE / etc.).

| Axis | Ark for mining payouts |
|---|---|
| Variance to | Miner |
| Custody | ASP (operator) — covenant-locked unilateral exit |
| Hop-resistant | N/A (orthogonal to share scheme) |
| Operator reserve req | High (capital × expiry window) |
| Auditable on-chain | Partial (V-PACK; path-exclusivity unverified) |
| Activation gate | clArk: none. hArk/Erk (efficient variants): **CTV + CSFS** |
| Production status | Alpha (Second signet) / live (Arkade) |
| Pool endorsement | None |

## What the formal academic paper does NOT say

Per [[../../raw/papers/2026-05-26-keer-maffei-ark-formal-arxiv|Keer-Maffei-Avarikioti 2026]] (the canonical formal Ark paper, posted six days before this research round): "**Mining payouts are NOT discussed.**" Mining appears only as background. The mining-payout pitch has **no academic spine** — it lives in one Bitcoin Magazine sentence.

## Status (May 2026)

- No mining pool has announced an Ark integration.
- No conference talk applies Ark to mining payouts.
- No BIP exists for Ark.
- ErikDeSmedt's CTV-coinbase → VTXO hybrid is a 1-paragraph forum suggestion; no spec, no code beyond [[../../raw/repos/2026-05-26-vnprc-coinbase-playground-github|vnprc/coinbase-playground]] regtest prototype. As of the 2026-07-17 collection snapshot that prototype implements a flat CTV coinbase tree (~319-output TRUC ceiling, 330-sat anchor, 1 sat/vB) and a layered/nested tree, and its stated endgame — an **n-of-n MuSig locking script at each tree node** with leaf owners trading outputs off-chain to consolidate subtrees — is structurally the same shared-output transaction tree Ark uses for VTXOs. *See [[ctv-coinbase-payout-tree|CTV Coinbase Payout Tree]] ([CTV Coinbase Payout Tree](../concepts/ctv-coinbase-payout-tree.md)).*

## Sources

- [[../../raw/papers/2026-05-26-keer-maffei-ark-formal-arxiv|Keer-Maffei-Avarikioti 2026 — formal model (arXiv)]]
- [[../../raw/articles/2026-05-26-ark-burak-original-proposal-2023|Burak Keceli bitcoin-dev 2023]] — original proposal
- [[../../raw/articles/2026-05-26-second-tech-ark-intro|Second.tech intro/spec]]
- [[../../raw/articles/2026-05-26-bitcoinmag-second-bark-mining-payouts|Bitcoin Magazine Apr 2026]] — the only news mention
- [[../../raw/articles/2026-05-26-ark-labs-tether-funding|Ark Labs Tether-led raise]]
- [[../../raw/articles/2026-05-26-ark-erik-de-smedt-ctv-csfs-delving|De Smedt + Roose + roasbeef Delving thread]]
- [[../../raw/articles/2026-05-26-ark-pickhardt-channel-factory-delving|Pickhardt + instagibbs capital-lockup thread]]
- [[../../raw/articles/2026-05-26-carvalho-credible-exit-blockspace|Carvalho exit-cost bound]]
- [[../../raw/articles/2026-05-26-vnprc-ctv-coinbase-delving|vnprc CTV-coinbase Delving thread]] (already in wiki)

## See also

- [[parasite-pool|Parasite Pool]] — current LN-custody payout pattern (different layer)
- [[ehash|eHash]] — Cashu-mint payout layer (different layer)
- [[braidpool|Braidpool]] — McElrath's covenant-based UHPO alternative
- [[ctv-coinbase-payout-tree|CTV Coinbase Payout Tree]] ([CTV Coinbase Payout Tree](../concepts/ctv-coinbase-payout-tree.md)) — the CTV-coinbase fanout the De Smedt hybrid builds on; its MuSig-node endgame mirrors Ark's shared-output tree
- [[payout-schema-taxonomy|Payout Schema Taxonomy]] — full design space
