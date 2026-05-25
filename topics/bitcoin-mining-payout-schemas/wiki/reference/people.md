---
title: People — eHash / hashpool / decentralized-pool ecosystem
type: reference
created: 2026-05-24
confidence: high
tags: [people, EthnTuttle, vnprc, Calle, Hughes, McElrath, pool2win]
---

# People

Key contributors to the eHash / hashpool / decentralized-pool ecosystem. Cross-referenced from concept articles.

## Originators / implementers

### EthnTuttle (Ethan Tuttle)

- **Role**: Originator of the eHash concept (May 2024)
- **GitHub**: https://github.com/EthnTuttle (143 repos)
- **Company**: Virginia Freedom Tech LLC (https://virginiafreedom.tech)
- **Nostr**: `npub1tmycvul7aj4fxhypg5qkjgsjtx30zvnrfeufrgx9xlwtv0hne7cs67el78`
- **Key contributions**:
  - Authored [delvingbitcoin.org/t/870](https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870) (May 2024) — *"Ecash TIDES using Cashu and Stratum v2"* — original eHash proposal
  - Cashu NUT-01 PR #85 (merged March 2024)
  - Filed 9+ design issues on `vnprc/hashpool` (#2-#6, #19, #23, #24, #33) — co-architect via issue-driven design
  - Authored SRI Iroh transport RFC (Discussion #1935, Oct 2025)
  - Owns `pplns-jd` (placeholder, Feb 2026), `ha-sv2-addons`, `whatsminer-HA`, `ocean-srrrvey`
- **Profile**: [[../../raw/articles/2026-05-24-ethntuttle-profile|full profile]]

### vnprc (Evan)

- **Role**: Implementer of hashpool (Nov 2024+)
- **GitHub**: https://github.com/vnprc (created 2014-10-28)
- **Self-hosted code**: forge.anarch.diy/vnprc/
- **Nostr**: `npub16vzjeglr...zumhgd` (display name: *"E is for eHash"*)
- **Affiliation**: Triangle BitDevs (Raleigh-Durham, NC)
- **Key contributions**:
  - `vnprc/hashpool` — 3,511 commits, primary committer, 76 stars
  - `cdk-ehash` plugin (CDK MintPayment trait implementation)
  - btc++ Berlin 2024, Austin 2025, Durham 2025 talks
  - Stephan Livera Podcast Ep 681 (Aug 2025)
- **Profile**: [[../../raw/articles/2026-05-24-vnprc-profile|full profile]]

## Cashu ecosystem

### Calle (Cashu creator)

- Endorsed EthnTuttle's eHash proposal in delvingbitcoin/t/870: *"your approach is more simple and doesn't require the mint operator to store outstanding blind messages."*
- No public talk specifically on Cashu mining application identified.

### David Caseria (davidcaseria)

- Cashu contributor; pushed for clarity on multi-redemption mechanics in delvingbitcoin/t/870.

## OCEAN / TIDES

### Jason Hughes

- Author of OCEAN's TIDES payout scheme (Feb 2024).
- Spoke "DATUM Deep Dive" at btc++ Austin 2025: https://www.youtube.com/watch?v=FJ0Hye52Ib8

### Luke Dashjr

- OCEAN pool relaunch lead.

## DMND / SLICE

### Alejandro De La Torre

- DMND CEO (ex-VP Poolin).

### Filippo Merli (Fi3)

- DMND CTO; long-time SRI contributor; SLICE design lead. Active on delvingbitcoin.org "PPLNS with job declaration" thread.

## p2poolv2 / Hydrapool

### pool2win (Jungly)

- p2poolv2 lead maintainer + Hydrapool lead engineer (256 Foundation grant). Same person.
- Also maintains Braidpool implementation.
- Distributed-systems researcher with PhD.

### econoalchemist

- Hydrapool project manager.

## Braidpool

### Bob McElrath

- Braidpool spec lead — DAG-based decentralized pool design with covenants/UHPO.
- Active critic of share-chain (vs. DAG) approaches: in delvingbitcoin "PPLNS with job declaration" and other threads, argues p2poolv2 inherits forrestv's dust problem.

## Stratum V2 community

### Pavel Moravec, Jan Čapek (Braiins)

- Co-proposed Stratum V2 with Matt Corallo in 2019.

### Matt Corallo

- Bitcoin Core contributor; proposed BetterHash (precursor to SV2 Job Declaration). Participated in delvingbitcoin/t/870.

### plebhash

- Vinteum / Stratum V2 contributor. Spoke btc++ Austin 2024 — *"SV2 explained: a step towards mining decentralization"*.

### gitgab19

- SRI core contributor.

### Antoine Poinsot (AntoineP)

- Bitcoin Core contributor; lead voice on the *"Scaling Noncustodial Mining Payouts with CTV"* delvingbitcoin thread (#1753) — pivotal critique that hits all decentralized-pool designs.

### AJ Towns (ajtowns)

- Bitcoin Core maintainer; latency-adversarial-share-chain critique in delvingbitcoin "Fastest-possible PoW via Simple DAG" #1331.

## SChernykh (Monero p2pool)

- Author of XMRig and SChernykh/p2pool (Monero, 2021+). Reference implementation that informed p2poolv2's uncle and auto-window design.

## Researchers

### Akira Sakurai, Kazuyuki Shudo

- FiberPool 2025 (arXiv 2501.15459) — formal-properties baseline for decentralized pool reward schemes.

### Meni Rosenfeld

- *"Analysis of Bitcoin Pooled Mining Reward Systems"* (2011). Originated PPLNS, geometric, DGM. Foundational reference for every modern scheme.

### Other academic contributors

- Schrijvers/Bonneau/Boneh/Roughgarden (FC'16) — incentive compatibility
- Eyal (IEEE S&P'15) — Miner's Dilemma / BWH game theory
- Eyal/Sirer (FC'14) — selfish mining
- Kwon et al. (CCS'17) — FAW
- Chatzigiannis et al. (J. Cybersecurity 2022) — diversification

## See also

- [[../concepts/ehash|eHash concept]]
- [[../concepts/tides|TIDES]]
- [[../concepts/p2poolv2-accounting|p2poolv2 accounting]]
- [[../concepts/hydrapool|Hydrapool]]
