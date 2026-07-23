---
title: "Bitcoin Optech — Pooled Mining (what pool miners can/can't verify) + Braiins SV2 framing"
source_url: https://bitcoinops.org/en/topics/pooled-mining/
source_url_2: https://braiins.com/stratum-v2
type: article
retrieved: 2026-07-21
credibility: high
corroboration: "trust-model + prior-art agents"
tags: [bitcoin-optech, pooled-mining, block-withholding, transaction-selection, stratum-v2, job-declaration, trust-model, braiins]
summary: "Optech's neutral summary of the pool-miner trust boundary: miners have no direct control/insight over template txs; the coinbase follows a pool template; historical abuse (pools stealing from site operators, accidental consensus violations). Job declaration (not passive verification) is the decentralization lever."
---

# Optech Pooled Mining + Braiins SV2 framing

## Bitcoin Optech — Pooled Mining

- V1 baseline: "pool members have no insight or direct control over what they mine.
  They aren't directly informed about which transactions are included in the template
  block (or excluded from it) and the pool may reject any attempt they make to change
  those transactions." The coinbase "must follow a template provided by the pool."
- SV2 improvement is **optional** tx choice: it "can allow individual pool members to
  choose which transactions to include in their blocks" — *can*, not automatic.
- **Cannot verify:** tx inclusion/exclusion decisions, selection rationale.
  **Can verify:** only share validity/PoW and own contribution math.
- Real stakes: "lack of independent validation has allowed pools in the past to steal
  from website operators and lose money accidentally violating consensus rules."
- Confirms **block withholding** as a live attack class (valid shares submitted,
  actual block withheld) across FPPS/PPLNS/PPS.

## Braiins SV2 overview (vendor / co-author — medium credibility)

- "For most of bitcoin's history … pool operators have been in control of which
  transactions end up in the blocks that get mined."
- Job declaration "shift[s] the power back to the miners" by letting them "construct
  their own block templates" — an opt-in feature, not the passive-verify baseline.
- Frames the compromised-pool-operator as the single point of failure job declaration
  removes; implicitly, a passive coinbase check does not remove it.

## Relevance

Independent, reputable confirmation of the verify/not-verify boundary + documented
history of pool misbehavior. Even SV2's promoters frame *active template construction*
(job declaration), not passive verification, as the trust-minimization mechanism.
