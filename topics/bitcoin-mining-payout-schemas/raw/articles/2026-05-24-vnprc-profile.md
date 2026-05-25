---
title: "vnprc (Evan) — hashpool implementer profile"
publication: github.com/vnprc + hashpool.dev + njump.me
url: https://github.com/vnprc
url2: https://hashpool.dev
type: article
ingested: 2026-05-24
quality: 5
credibility: high
confidence: high
tags: [vnprc, Evan, hashpool, eHash, implementer, btc++]
---

# vnprc

Implementer of hashpool.dev — the working SV2-fork-with-Cashu-mint pool. Implements the **eHash concept originally proposed by EthnTuttle** in May 2024. btc++ speaker (3 talks 2024-2025). Triangle BitDevs co-runner.

## Identity

- **First name**: Evan (disclosed by Stephan Livera in SLP681, Aug 2025: *"Guest: Evan (VNPRC), creator of HashPool."*)
- Last name: not disclosed (pseudonymity preserved)
- **GitHub**: https://github.com/vnprc — created **2014-10-28** (12-year-old Bitcoin handle, ID 9425366)
- Profile fields deliberately empty; only the bio holds content: **GPG fingerprint `AD88 A262 F8DB 52E6 AC3F 8C70 BE70 1B68 2FF4 862A`**
- **0 followers / 0 following / activity private** — strong pseudonymity posture
- **Nostr**: `npub16vzjeglr653mrmyqvu0trwaq29az753wr9th3hyrm5p63kz2zu8qzumhgd`. Display name: *"E is for eHash"*. NIP-05 verified at hashpool.dev.
- **Self-hosts code at `forge.anarch.diy/vnprc/`** (a Forgejo instance with cypherpunk/agorist branding) in addition to GitHub
- **Likely Research Triangle, NC** based — affiliation with Triangle BitDevs (Raleigh-Durham); never explicitly stated

## Repos (originals only)

| Repo | Notes |
|---|---|
| `hashpool` | **Flagship**. Rust, 76 stars, 3,511 commits, created 2024-11-01. Fork of SRI replacing share accounting with Cashu mint. |
| `cdk-ehash` | CDK payment processor for ehash (hosted at `forge.anarch.diy`, mirrored to GitHub). Implements `MintPayment` trait. |
| `hashpool-website` | Source for hashpool.dev |
| `coinbase-playground` | CTV/CSFS coinbase-tree experiments for non-custodial pools. Custom Bitcoin Core fork with CTV enabled. |
| `bitcoin-nostr-relay` | Censorship-resistant tx propagation over Nostr. 52 tests, "production-grade aspirations." |
| `tx-relay-playground` | Tx relay experiments |
| `sri-devenv` | Stratum Reference Implementation dev environment |

## Forks (technical universe tracked)

- `stratum-mining/stratum`, `sv2-spec`, `sv2-apps` — Stratum V2 stack
- `cashubtc/cdk`, `cashu`, `cashu.me`, `nuts` — Cashu ecosystem
- `electrs`
- `TriangleBitDevs.github.io` — co-runs the meetup

## btc++ talks (3 confirmed)

1. **Berlin Oct 2024 (e-cash edition)** — *"Hashpools — A New Kind of Mining Pool Powered by Ecash"* (project debut). https://www.youtube.com/watch?v=SeydWRNjH_Y
2. **Austin May 2025 (mempool edition, Poolin' Stage Day 2)** — *"Proxy Pools — Harness the Free Market to Decentralize Bitcoin Mining"*. Inside livestream https://www.youtube.com/watch?v=F2p_V0svDTo at ~3h15m30s.
3. **Durham Nov 15, 2025 (local edition)** — *"Hashpools — One Year Development Update"*. Listed on hashpool.dev/media/.

## Stephan Livera Podcast

**Ep. 681** — *"eCash & e-Hash: the HashPool Solution with Evan"* (Aug 5, 2025). https://www.stephanlivera.com/episode/681/

Topics: SV2 block-template construction, ecash/Chaumian mints, ehash trading and proof-of-liabilities, CTV-based non-custodial payouts, sustainability for small miners.

## Ideological positioning

Cypherpunk-aligned:
- anarch.diy hosting
- GPG-only bio
- Anti-Ledger / opsec advocacy
- Posts supporting imprisoned developers
- CTV/CSFS softfork advocate
- Anti-Bitmain-coinbase-restriction
- Pro-Stratum-V2, pro-Cashu, pro-Nostr-as-infra

Self-described identity (Nostr): three words — *"CTV+CSFS, Hashpool, Triangle BitDevs."*

`coinbase-playground` README explicitly names motivations: *"break Bitmain's stranglehold on the coinbase"* and *"enable pool competition beyond Ocean Mining."* Situates him in the **anti-Bitmain, pro-Ocean / pro-decentralized-pool camp**.

## Solo developer (no team / no funding disclosed)

- `hashpool` repo: 3,511 commits, primarily Rust (94.9%), dual-licensed Apache-2.0/MIT, 10 forks, 25 open issues. **vnprc shown as primary committer**.
- No co-author or acknowledgements naming Ethan Tuttle (EthnTuttle) inside the repo.
- Personal Nostr asides about family/work suggest a separate day job — hashpool appears passion-project / unfunded.
- **No grant/sponsor publicly named** (Spiral, OpenSats, HRF, Brink, btcStartLab — none).

## Distinction from EthnTuttle (the originator)

| | EthnTuttle | vnprc |
|---|---|---|
| Role | Idea originator | Implementer |
| eHash proposal | Authored delvingbitcoin/t/870 (May 2024) | Built hashpool starting Nov 2024 |
| hashpool repo | Filed 9+ design issues, 0 PRs | Primary committer (3,511 commits) |
| Public mode | Nostr + GitHub issues | Nostr + GitHub commits + btc++ talks |
| Identity | Real name "Ethan Tuttle" + LLC | Pseudonymous "Evan" |

## See also

- [[2026-05-24-ethntuttle-profile|EthnTuttle profile]] — eHash originator
- [[../../wiki/concepts/ehash|eHash concept article]]
- [[2026-05-23-hashpool-vnprc|hashpool repo notes]]
- [[2026-05-24-hashpool-architecture-deep|hashpool architecture deep-dive]]
