---
title: "Miner-side template construction in production: DMND (SV2 Job Declaration) and Ocean DATUM"
source: "https://dmnd.work/"
related_sources:
  - "https://github.com/demand-open-source/demand-cli"
  - "https://github.com/ocean-xyz/datum_gateway"
type: articles
ingested: 2026-09-21
tags: [job-declaration, datum, template-decentralisation, dmnd, ocean, deployment-topology, firewall-ports, sv1-translation, slice-payout, merge-mining, beta-status, miner-sovereignty]
summary: "The two production attempts at moving template construction to the miner, recorded as a comparison. DMND mined what it reports as the first Bitcoin block using SV2 Job Declaration on 2026-06-26 at height 955,318 (height is consistent with that date). Its deployment shape is the useful part: miners connect to a local demand-cli on port 32767 with ordinary stratum+tcp and unchanged firmware, the client speaks SV2+JD outbound to the pool on 20000, and a local Template Provider on 8336 talks to Bitcoin Core v30+ with IPC — so the only firewall requirement is outbound to the pool plus LAN access to 32767. Authentication is a DMND token in the password field. Payout is SLICE: PPLNS for the subsidy, plus job-declaration scoring that allocates FEES according to whose template was used — the first payout design encountered that pays for template contribution rather than only for hashrate. Ocean's DATUM goes further: the miner's own node generates the template via getblocktemplate and the pool coordinates rewards only, with the gateway translating GBT to Stratum V1 with version rolling for the hardware. DATUM remains explicitly public beta after six releases (Jul 2025 - Jan 2026), warns that 'protocol changes may require upgrading with short or even no notice', still has the pool validating blocks after submission during testing, and sizes RAM at ~1 GB plus 1 GB per 1,000 concurrent stratum clients."
published: 2026-06-26
credibility: medium
credibility_score: 2
credibility_rationale: "Pool marketing page plus repository documentation. The block-height claim is checkable and internally consistent, but hashrate, miner counts and network share are all undisclosed for both. DATUM's positioning statements are Ocean's own. Two agents contradicted each other on whether DMND's repo exists (one reported 404, two found demand-cli) — resolved in favour of it existing."
confidence: low
confidence_rationale: "Deployment topology and port layout are concrete and consistent across two agents. Adoption scale is entirely unevidenced for both. The SLICE fee-scoring mechanism is described but not specified."
research_round: 1
research_agent: "news + applied"
scope_note: "DATUM internals belong to the `datum` hub topic and are NOT re-documented here. This file covers only the deployment topology and the architectural comparison."
extraction_note: "Merged from two subagent reports. One agent's gap list claimed 'Demand pool — no repositories or announcements' while the same report cited dmnd.work and another agent extracted demand-cli in detail; the negative claim is disregarded."
---

# Miner-side template construction in production

Two live systems that move block-template construction off the pool. They pick different points on the
same axis, and the difference is instructive.

## DMND — SV2 Job Declaration

**Reported milestone**: the **first Bitcoin block mined using SV2 Job Declaration**, **2026-06-26**, at
**height 955,318**. *(Height plausibility checked: ~52,560 blocks/year from the April 2024 halving at
840,000 puts late June 2026 near 955,600. Consistent.)*

**Deployment topology** — the most reusable detail here:

| Hop | Port | Direction |
|---|---|---|
| Miners → `demand-cli` | **32767** | LAN, plain `stratum+tcp://`, **unchanged firmware** |
| `demand-cli` → pool | **20000** | **outbound only** — SV2 + Job Declaration |
| `demand-cli` → Template Provider / Core | **8336** | local only, Bitcoin Core v30+ with IPC |

Firewall requirement in full: *"only needs to allow outbound connections to the pool, and LAN access
from your miners to port 32767."* No inbound internet exposure at all.

**Why this shape matters.** The hard part of SV2 adoption is not the pool — it is the installed fleet
of SV1-only ASICs. Putting a translating client on the miner's own premises means the fleet needs no
firmware change, the WAN hop carries SV2, and template construction happens locally. This is the same
role the SRI `translator` binary fills, deployed miner-side rather than pool-side, and it is why
translator-proxy correctness (see the sv2-apps v0.8.0 late-share fix) is revenue-critical.

**Authentication**: a DMND token supplied in the **password** field; usernames optional. Note the
contrast with V1, where the password field is ignored entirely, and with ckpool solo, where the
*username* is the payout address.

**Payout — SLICE**, a hybrid:

- **PPLNS for the subsidy.**
- **Job-declaration scoring for the fees** — fees allocated according to whose custom template was
  used.

This is the first payout construction in this round that **pays for template contribution rather than
only for hashrate.** It is the incentive answer to the obvious objection that miners have no reason to
bear the cost of running a node and declaring jobs. *(Mechanism described, not specified — the scoring
function is not published. Payout-schema analysis belongs to
`bitcoin-mining-payout-schemas`; recorded here because it is an architectural consequence: the pool
must now attribute fee revenue per template, which means the share pipeline has to retain
template provenance per share.)*

**Also claimed**: end-to-end encryption making hashrate hijacking "mathematically infeasible — not
just policy, but protocol"; zero hash hijacks since launch (launch date not given); merge-mining
Rootstock (rBTC) without splitting hashrate; SOC 2 Type 2 via Vanta; public API and institutional
dashboard. **Hashrate, miner count and network share: all undisclosed.**

## Ocean DATUM — miner-sovereign templates

**The stronger form of the same idea.** Positional comparison:

| | DATUM | SV2 + Job Declaration |
|---|---|---|
| Template generated by | **Miner's own Bitcoin node** via `getblocktemplate` | Pool or JDS; miner may customise via JD |
| Pool's role | Coordinate reward distribution; validate after submission | Generate base template, validate custom ones, maintain a synchronised mempool |
| Miner requirement | **Full node per mining operation** | None — may use the pool's template infrastructure |
| Hardware protocol | **Stratum V1 + version rolling** (ASICBoost compatible) | SV2, or SV1 via translator |
| Wire protocol to pool | Encrypted, designed to obscure traffic patterns | Standardised, BIP323 encryption |

The gateway sits between the miner's node (GBT) and the mining hardware (SV1). Note that DATUM reaches
decentralised templates **while speaking Stratum V1 to the ASICs** — it does not require SV2 at all.
That is a significant independent data point: template decentralisation and the V1→V2 migration are
*separable* problems, and DATUM separates them.

**Maturity, stated plainly:**

- **Six beta releases, July 2025 – January 2026** (v0.2.5, v0.2.6, v0.3.2, v0.3.3, v0.4.0, v0.4.1),
  with multiple parallel version branches.
- **Still explicitly "public beta"**, warning that *"protocol changes may require upgrading with short
  or even no notice."*
- **The pool still validates blocks after coordination during the testing phase** — i.e. full miner
  sovereignty is the goal, not yet the shipped state.
- Requirements: 64-bit Linux, fully-synced full node (**Bitcoin Knots recommended** for its extra
  template controls), **~1 GB RAM baseline plus 1 GB per 1,000 concurrent stratum clients**.
- v0.4.1beta fixes reported: JSON-RPC parameter typing, Safari auth flow, null-pointer checks in
  `datum_secure_strequals`, strict-aliasing violations removed, split-mapping edge cases in reward
  distribution.
- Adoption signals: 148 stars, 87 forks, 36 open issues, 58 PRs; Ocean offers a **50% fee discount**
  for DATUM users. Hashrate split undisclosed.

**The 1 GB per 1,000 clients figure is worth keeping** — it is the only published per-connection memory
budget for any pool component in this round, and at ~1 MB per connection it is **~300× the ~3 KB
kernel-side figure measured at 12M connections elsewhere**. That gap is application state (and possibly
conservative guidance), and it sets a very different scaling ceiling: 10,000 clients would want 10 GB.

## Architectural reading

1. **Three distinct positions on template control now exist in production**, and they are not
   variations on one design: pool-chosen-and-published (solo.ckpool at `/pool.txns`),
   miner-declared-pool-validated (SV2 JD / DMND), and miner-sovereign-pool-coordinates (DATUM). The
   middle option needs `checkBlock()` and wtxid batch lookup from Core to be affordable; the last needs
   a full node per miner; the first needs nothing new at all.
2. **The gateway/proxy on the miner's premises is the pivotal component in both designs.** It is where
   protocol translation, template construction and — per Optech #423 — per-miner vardiff control all
   have to live, because it is the last hop that sees individual miners. Both DMND and DATUM converge
   on it independently.
3. **Incentive design is the binding constraint, not protocol capability.** BIP23 specified miner
   template auditing in 2012 and nobody used it. DMND's SLICE fee scoring and Ocean's 50% fee discount
   are both attempts to pay miners for the operational cost of sovereignty. Whether that works is the
   open question, and neither party has published the adoption numbers that would answer it.
4. **"First JD block" in mid-2026 dates real adoption**, seven years after the SV2 specification.
   Whatever else is true, the diffusion time for this class of change is measured in years.
