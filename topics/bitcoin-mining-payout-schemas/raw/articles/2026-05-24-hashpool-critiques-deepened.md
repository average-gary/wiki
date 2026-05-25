---
title: "hashpool/eHash critiques (deepened) — variance hedging, DLEQ limits, mint-as-counterparty"
publication: hashpool.dev + Cashu docs + Stacker News + NUTs
type: article
ingested: 2026-05-24
quality: 4
credibility: medium
confidence: high
tags: [hashpool, eHash, critiques, custodial, DLEQ, variance, mint-as-counterparty]
---

# hashpool / eHash Critiques (Deepened)

The wiki's existing `eHash` concept article notes custodial mint, no proof-of-liabilities, mint can rugpull. This article deepens the critique surface based on primary-source pushback.

## 1. Variance-hedging story is empirically unbuilt (HIGH severity)

The core hashpool pitch: miners hold ehash to maturity for upside, **or sell early for guaranteed payout** — making variance a tradeable asset.

**The secondary market that justifies this pitch does not exist.** From Stacker News (item 796526), the project founder himself walked back the claim:

> *"It's not possible to sell Ecash tokens. I think only swaps for LN."*

So the "PPLNS-killer" early-sale feature reduces to **"the mint will buy it back at whatever price it wants"** — captive-counterparty pricing.

**Severity HIGH**: the design's variance-smoothing pitch is vaporware as of 2026-05.

## 2. DLEQ does not prevent per-user equivocation (HIGH severity)

NUT-12 DLEQ proofs are correctly described in the wiki as preventing the mint from later denying it issued a particular eHash. **But DLEQ does not prevent the mint from running a different keyset for each miner cohort**:

- The proof binds *one* signature to *one* published pubkey.
- Nothing cryptographically asserts "every miner sees the same key."
- A malicious operator can selectively under-sign shares for one segment of the userbase undetectably.
- Cross-user accountability requires out-of-band gossip; in mining, miners don't typically gossip raw tokens with each other.

**Severity HIGH**: the wiki should not assume Cashu's crypto inherently prevents the mint from running parallel ledgers.

## 3. Mint-as-counterparty captures price discovery (MEDIUM-HIGH)

From Stacker News (item 904596):

> "How does price discovery work when they (the mint) are the market?"

Without a real secondary market, the mint sets the implicit redemption price for partially-matured eHash. **Captive-counterparty hazard absent from PPS/FPPS.**

Critics also observe the eHash design **inherently creates a speculative instrument**, attracting non-miner participants whose flows can dominate price formation and harm small miners' actual hedging needs — classic reflexivity hazard.

## 4. Custodial-by-design with maximum dwell-time (HIGH)

Project's own admission: *"An ecash mint is the best kind of custodian: a private accountless custodian."* Then warns: *"DO NOT store your life savings in an ecash mint."*

But unlike a PPS pool that pays out within hours, **eHash is held by design until block reward maturity** — *maximizing* dwell-time exposure. The advice "treat it like physical cash" is incoherent when the protocol forces miners to accumulate it across an entire block-finding interval.

## 5. eHash value is variable (MEDIUM)

Authors admit eHash *"is not a fixed-value asset."* Even if the mint is honest, miners bear:

- Pool-luck variance, plus
- Token-pricing risk, plus
- Time-value-of-money cost while waiting for maturation

**PPLNS/FPPS at least give a deterministic accounting unit.**

## 6. No proof-of-liabilities in the protocol (HIGH)

- Cashu has **no NUT for PoR or PoL**.
- Mining mints handle **larger and longer-dwelling balances** than chat mints, yet inherit the weakest accountability profile.
- Exchanges have at least Merkle-sum trees; hashpool has nothing equivalent in spec.

The settlement-design solvency invariant (`Σ redemptions = reserve increase`) is a property of the *coinbase tx*, but the **mint can still issue unbacked tokens** to phantom miners between blocks. Detection requires PoL, which Cashu doesn't specify and hashpool doesn't implement.

## 7. Operator-side KYC/AML pressure (MEDIUM)

- Cashu FAQ is silent on operator-side regulatory pressure.
- A mining-mint operator concentrating block rewards across thousands of miners is an **MTL/MSB-tier flow** — much juicier target than a $20-tab Lightning mint.
- Cashu's protocol provides **no plausible-deniability story for the mint operator** (only for users).
- Operator shutdown risk is independent of miner trust.

## 8. Liveness coupling to LN backend (MEDIUM)

- Redemption requires the mint's LN backend to be solvent and unblocked.
- A hashpool whose LN node is force-closed or sanctioned **cannot redeem, even if its bitcoin reserves are intact**.
- Liveness failure mode unique to LN-mediated mints.

(Note: hashpool's `roles/mint/Cargo.toml` has **no LN deps yet** — issue #56 closed Not Planned in Sep 2025. So the LN bridge is itself a future component.)

## 9. Mint can refuse redemptions (HIGH)

- NUT-00/07 double-spend prevention relies on the mint's own spent-set.
- The mint can selectively claim "already spent" to refuse legitimate redemptions.
- **Censorship-as-default with no audit trail.**

## 10. Bearer-asset wipe risk (MEDIUM)

- Cashu FAQ: *"Should the storage be wiped, funds will be lost."*
- Miners running headless rigs with crashy SD cards are unusually exposed to local-storage loss compared to typical Cashu wallet users on phones.

## 11. Home-mintability problem — recreates centralization (HIGH)

From Stacker News pushback:

> "Ordinary miners cannot run their own mint."

A hashpool mint operator must aggregate hashrate to earn variance smoothing → **the entire user base is locked to a small set of operators** → recreating the centralization Stratum V2 was meant to dilute.

## 12. Project's own "alpha" disclaimer (HIGH)

CDK README: *"Funds might be lost forever due to bugs in the software or the protocol."* Pairing alpha-stage custody software with concentrated mining payouts is the **worst-fit risk surface in the Cashu ecosystem**.

## Cross-cutting severities the wiki should flag

| # | Critique | Severity |
|---|---|---|
| 1 | Variance-hedging story unbuilt; founder walked back early-sale claim | **HIGH** |
| 2 | DLEQ doesn't prevent per-user key equivocation | **HIGH** |
| 3 | Mint-as-counterparty captures price discovery | **MEDIUM-HIGH** |
| 4 | Custodial-by-design, maximum dwell-time | **HIGH** |
| 5 | eHash is variable-value, not a fixed unit | MEDIUM |
| 6 | No proof-of-liabilities | **HIGH** |
| 7 | Operator-side KYC/AML pressure | MEDIUM |
| 8 | Liveness coupling to LN backend | MEDIUM |
| 9 | Mint can refuse redemptions undetectably | **HIGH** |
| 10 | Bearer-asset storage wipe risk | MEDIUM |
| 11 | Home-mintability problem recreates centralization | **HIGH** |
| 12 | Project's own alpha disclaimer | **HIGH** |

## See also

- [[../../wiki/concepts/ehash|eHash concept]]
- [[2026-05-24-hashpool-architecture-deep|Architecture]]
- [[../../wiki/decisions/custody-tradeoffs|Custody Tradeoffs]]
