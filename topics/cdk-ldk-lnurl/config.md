---
title: cdk-ldk-lnurl — config
type: topic-config
created: 2026-05-28
---

# cdk-ldk-lnurl — config

## Scope

**In scope**:
- Cashu Dev Kit (`cashubtc/cdk`) — repo structure, `cdk-mintd` binary, lightning-backend feature flags
- LDK Node embedding inside CDK (`cdk-ldk-node`, `cdk-lnd`, `cdk-cln`, `cdk-fake-wallet` backends)
- LNURL spec family (LUD-01 .. LUD-21) with focus on LUD-06 (pay), LUD-03 (withdraw), LUD-16 (Lightning Address), LUD-21 (verify)
- Deployment topology: process model, persistence, channel management, liquidity sources
- Integration patterns: CDK mint → LDK Node → bitcoind / Esplora; LNURL server in front of CDK
- Comparison vs CLN/LND-backed CDK deployments

**Out of scope**:
- General Cashu protocol theory (NUTs) beyond what touches LN flows
- LDK Server daemon (separate `ldk-server` topic wiki)
- Wallet-side LNURL (sender side) — focus is mint/receive side
- BOLT12 / offers (note as future direction; don't deep-dive)

## Sensitivity

Public. Hub-publishable. No company-proprietary content.

## Source preferences

- **Primary**: cashubtc/cdk repo, cashubtc/cdk-mintd README, lightningdevkit/ldk-node repo, LNURL LUDs (lnurl/luds GitHub)
- **Secondary**: cashu.space documentation, callebtc blog posts, LDK blog
- **Tertiary**: practitioner blogs deploying ecash mints
