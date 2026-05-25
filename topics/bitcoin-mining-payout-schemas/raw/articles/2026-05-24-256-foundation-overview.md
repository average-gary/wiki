---
title: "256 Foundation — overview, governance, and relationship to p2poolv2"
publication: 256foundation.org + github.com/256foundation
url: https://256foundation.org
url2: https://github.com/256foundation
type: article
ingested: 2026-05-24
quality: 5
credibility: high
confidence: high
tags: [256-foundation, governance, Hydrapool, mining-decentralization, 501c3]
---

# 256 Foundation

501(c)(3) public charity (**EIN 99-1662333**) focused on dismantling Bitcoin mining centralization across hardware (~90% one Chinese vendor), pools (~90% top-4), and reward custody (~40% one custodian).

## Funding and operations

- **Total raised**: 7.208 BTC
- **Allocated**: ~$584,000 USD
- **Admin cut**: 0% (100% passthrough)
- **Notable grant**: $100,000 from MARA Foundation, awarded April 29, 2026 at Bitcoin 2026 Las Vegas
- 1 block found during Telehash #1 (8-hour livestream)

## Four "Core Pillar" projects

Each addresses one centralization vector:

| Project | Layer | What it is |
|---|---|---|
| **Ember One** | Hardware | Open hashboard |
| **Mujina** | Firmware | Open ASIC firmware |
| **Libre Board** | Hardware | Open control board |
| **Hydrapool** | Pool software | One-click open-source mining pool |

## Plus 6 "Open Grant" ecosystem projects

OSI/OSHWA license required. Funded via rolling Typeform applications.

## Critical relationship: 256 Foundation ↔ p2poolv2

**p2poolv2 is NOT a 256 Foundation pillar.** The pool-software pillar is **Hydrapool**, not p2poolv2. The relationship is:

- **p2poolv2** is led by **`pool2win`** (Jungly, distributed-systems PhD), an independent maintainer.
- pool2win also maintains **Braidpool** — the theoretical DAG sibling project.
- **Hydrapool** is the 256 Foundation's pool product. Hydrapool **uses p2poolv2 as a library**: recent release notes pin `p2poolv2 lib v0.10.14`.
- Hydrapool's lead engineer is **Jungly** (same person as pool2win — 256 Foundation hired the p2poolv2 maintainer to build Hydrapool).
- Hydrapool's project manager is **econoalchemist**.

So the *engineering relationship* is real (same lead dev, library dependency), but **p2poolv2 itself is independent** and is not directly funded as a 256 Foundation pillar. p2poolv2 funding source is not publicly disclosed in the repo metadata; appears to be uncompensated volunteer work or potentially indirect through Hydrapool development overlap.

## Hydrapool details

- Repo: `github.com/256foundation/hydrapool` (Rust, AGPL-3.0).
- 45 stars / 16 forks / 184 commits as of May 2026.
- Latest version: **v2.5.8** (~mid-May 2026).
- Live test instance: `pool.256foundation.org:3333` and `test.hydrapool.org`.
- Modes: **solo + PPLNS**.
- Payouts: **direct from coinbase, no custody**.
- User cap: **~100 per coinbase tx** (vs. p2poolv2 issue #248 targeting 500).
- Public **/pplns_shares API endpoint** lets miners download and validate the share ledger — externally-auditable PPLNS.
- Coinbase tuning: `blockmaxweight=3,930,000` allows ~500 P2PKH outputs ≈ 68,208 wu.

## 256 Foundation board

**Not disclosed on the website.** Need 990 filing via EIN 99-1662333 to identify directors.

## Newsletter / communications

- `news.256foundation.org` — newsletter index (PDF format)
- POD256 podcast (POD256.org)
- Notable issues: "You know, I'm something of a Decentralized Pool Myself" (June 2025), "Bitcoin Mining Will Not Be Decentralized Until It Is Open Sourced" (May 2025), "Rig: Bitcoin Mining Re-Imagined" (Sept 2025), Ep. 70 "Hydrapool is Live" (POD256), Ep. 110 (April 1, 2026) "Open Firmware, Open Pools…"

## Implication for the wiki framing

The user's original prompt — *"accounting used by p2poolv2 under the 256 Foundation"* — needs unpacking into two distinct systems:

1. **p2poolv2 accounting** (work-bounded PPLNS window with uncles, atomic-swap edge) — designed by pool2win independently. Production code in `p2poolv2_lib::accounting`.
2. **Hydrapool accounting** (PPLNS variant, direct-coinbase, ≤100 users/block, public audit API) — built by the same dev for 256 Foundation.

The two systems share the `p2poolv2_lib` library but differ in **deployment philosophy** (Hydrapool is one-click for home miners; p2poolv2 the protocol is decentralized-by-default).

## See also

- [[../repos/2026-05-24-p2poolv2-accounting-modules|p2poolv2 accounting code]]
- [[../articles/2026-05-24-hydrapool-256-foundation|Hydrapool — 256 Foundation pool]]
- [[../articles/2026-05-24-p2poolv2-lineage-and-history|p2poolv2 lineage: forrestv → SChernykh → Braidpool → p2poolv2]]
