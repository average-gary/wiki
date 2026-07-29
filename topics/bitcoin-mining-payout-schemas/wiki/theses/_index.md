---
title: Theses
type: section-index
updated: 2026-07-29
---

# Theses

Testable claims emerging from the deep-research rounds. Investigate with `/wiki:research --mode thesis "<claim>" --wiki bitcoin-mining-payout-schemas`.

## Filed theses

| Thesis | Status | Verdict | Round |
|---|---|---|---|
| [[blinded-share-credit-commitment\|A blinded share-credit commitment can preserve Bedrock's share-theft resistance]] | **completed** | **MIXED** (high) — B & D supported, **C falsified**, E supported on interactivity only, A unestablished | 2026-07-29 thesis round (`--deep`, 8 lenses) |

### What the completed round found

The claim tested was the file's own inverted framing: *"Blinding a PoW-committed mining cookie
preserves re-labeling resistance but cannot preserve share-weight aggregation or duplicate arbitration
without either a pool-side persistent pseudonym or a miner-carried accumulator, making blinded share
credit strictly harder than blinded payout."*

**Its or-conjunction splits.** Aggregation genuinely needs one of the two named escapes; **duplicate
arbitration does not** — a keyed share-derived nullifier is a third mechanism, and SRI, Ocean/DATUM and
p2pool-v2 already dedup with **no identity term in the key** (Ocean's check even runs *before*
attribution). See [[../concepts/nullifier-vs-pseudonym|Nullifier vs Pseudonym]].

**Five wiki corrections came out of it**, four load-bearing: the Canard–Gouget prescription was
**inverted** (the BBA line cites it as the reason issuer and accumulator *must* share one key); the ROS
threshold is **ℓ = 9, not 256**; ROS-breaks-ACL was **retracted by its own authors**; the `Add`/`Sub`
performance figures were **swapped**, overstating pool-side credit cost 4.04×; and the 16-bit range
limit **never touched the crediting path**. Plus fabricated author names removed from two files.

## Candidate theses

Unfiled one-liners from the deep-research round (2026-05-23).

1. **Variance, not fee, is the FPPS premium.** The 0.5-1.5% fee gap between FPPS and PPLNS-class pools represents the operator's variance-bearing premium, not pool-quality differential. Falsifiable with multi-pool variance vs. fee regression.

2. **SV2 + JD makes PPLNS-class pools economically dominant by 2030.** The combination of low stale-rate + miner-controlled templates removes both of FPPS's structural advantages (predictability + simplicity). Falsifiable with hashrate market share over time.

3. **The fee-era flips the variance-bearing economics.** Post-subsidy (~2032), block subsidy → 0 and fee variance dominates. FPPS pools must either raise fees materially or cede market share. Falsifiable with FPPS fee schedules over halvings.

4. **eHash secondary markets do not clear at scale.** A Cashu-token-for-unmatured-share market needs deep liquidity; the variance-pricing problem is harder than equivalent options markets. Falsifiable with hashpool or follow-on project's secondary-market data when production-deployed.

5. **p2poolv2's atomic-swap support transactions solve the dust problem.** Where p2pool (2011) failed on dust, the v2 design with market-maker buyers of small shares should achieve sustainable >1 EH/s at small-miner UX parity with FPPS. Falsifiable with deployment data.

From the 2026-07-29 attribution-privacy round — #1 is filed above; these two are not yet written up:

6. **A non-custodial coinbase-direct pool that retains only per-descriptor work volume is not a money transmitter under FinCEN FIN-2019-G001.** §5.4's exemption plus §4.2's four factors support it; §4.5.1(a)'s anonymizing-services-provider rule cuts against it; DOJ's §1960 theory in the Samourai prosecution is the untested bypass. Falsifiable against the §1960 case law that round could not retrieve (403/404). See [[../decisions/attribution-retention-tradeoffs|Attribution Retention Tradeoffs]].

7. **Per-payout address rotation strictly increases a pool's block-withholding exposure.** Eligius 2014 is the only production detection success and it depended on address clustering; APoW argues PPLNS's incentive structure makes detection unnecessary. Falsifiable by quantifying residual detection power under rotation — no paper has. See [[../concepts/coinbase-address-rotation|Coinbase Address Rotation]], [[../concepts/block-withholding|Block Withholding]].
