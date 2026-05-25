---
title: "EthnTuttle ↔ Fi3/DMND collaboration verdict + extended timeline"
publication: github + delvingbitcoin
type: article
ingested: 2026-05-24
quality: 4
credibility: high
confidence: high
tags: [EthnTuttle, Fi3, SLICE, DMND, pplns-jd, collaboration, timeline]
---

# EthnTuttle ↔ Fi3/DMND Collaboration: Light Tracking, Not Active Co-Development

## Verdict

**Closer to (b) "EthnTuttle independently tracking SLICE without contribution" than (a) "active collaboration".** Light asynchronous engagement with one polite drive-by PR.

## Evidence FOR engagement

1. **EthnTuttle authored PR #2 on `dmnd-pool/share-accounting-ext`** ("refactor: messages module", Nov 5, 2024). Fi3 reviewed positively on Feb 5, 2025 (*"yep any improvement on the module organization is well accepted ty"*). Remains **unmerged** as of fetch — only direct two-way interaction found.
2. **EthnTuttle maintains a fork** of `dmnd-pool/share-accounting-ext` (1 of ~7 total).
3. **EthnTuttle/pplns-jd Issue #7** ("design: no validation hook for declared job fees", Feb 18, 2026) cites Delving Bitcoin posts #41 (sjors) and #45 (Fi3) and Bitcoin Core PR #31564, references concrete API names (`SliceManager::submit_share`, `declare_job`). Reading the design closely.

## Evidence AGAINST collaboration

1. **`EthnTuttle/pplns-jd` is empty** — `size: 0 bytes`, no branches, created and pushed in the same second on 2026-02-18. Description ("SLICE (PPLNS+JD) accounting library for Stratum V2 mining pools") + Issue #7's API references = **planned reimplementation, not a shared one**.
2. **No EthnTuttle posts in delvingbitcoin/t/1099.** Across ~3 pages spanning Aug 2024 – Jan 2025, only Fi3, lorbax, plebhash, marathon-gary, sjors. EthnTuttle (or aliases) never posts.
3. **No EthnTuttle commits** to `lorbax/pplns-with-job-declaration` (the SLICE paper repo).
4. **PR #2 has been open ~18 months** without merge despite Fi3's positive comment — low coordination cadence.
5. **lorbax is not Fi3.** Self-describes as "group theorist and developer" — separate identity, both DMND-affiliated.
6. **No `pplns-jd` workspace member or dependency referenced from `vnprc/hashpool`'s Cargo.toml**.
7. **Fi3's GitHub activity is private**, blocking the cleanest cross-reference check.

## EthnTuttle's full extended timeline (2023-2026)

This contribution catalog updates the wiki's earlier `EthnTuttle profile` with new findings:

| Date | Repo | # | Title | Status |
|---|---|---|---|---|
| 2023-05 to 2023-10 | `fedimint/fedimint` | ~30 PRs/issues | Heavy Fedimint contributor — devimint, mprocs, UI, docker, docs | Mostly merged or closed |
| **2023-09-29** | **delvingbitcoin** | **t/110** | **"Fedimint Overview and Fedipool Theorizing"** — proposes "Poolimint" Fedimint module | Posted (forum) |
| 2024-02 to 2024-03 | `fedimint/fedimint` | several issues+PRs | Continued Fedimint work, Nostrmint cli draft, module flowchart | Closed/draft |
| **2024-03-19** | `cashubtc/nuts` | **PR #85** | **NUT-01 spec edit** | **Merged** |
| **2024-05-01** | `cashubtc/cdk` | **PR #96** | feat: use bip32 DerivationPath for mint keyset | Closed (substantive) |
| **2024-05-15** | **delvingbitcoin** | **t/870** | **"Ecash TIDES using Cashu and Stratum v2"** — eHash origin proposal | **Posted (20+ replies, Calle endorsed)** |
| **2024-11-05** | **dmnd-pool/share-accounting-ext** | **PR #2** | refactor: messages module | **Open, Fi3 acknowledged Feb 2025** |
| 2025-02 to 2025-09 | `vnprc/hashpool` | 9+ design issues (#2-#6, #19, #23, #24, #33) | hashpool architect via issues | Various |
| **2025-10-03** | **stratum-mining/stratum** | **discussion #1935** | **RFC: Iroh [Noise] Connection** | **Open** |
| **2025-10-23** | — | — | **PioneerHash GitHub org created** (12 repos, eHash integration vehicle) | — |
| **2026-02-18** | `EthnTuttle/pplns-jd` | Issue #7 | placeholder repo + design issue citing Fi3/sjors delvingbitcoin posts | Open |

## Key new finding: delvingbitcoin/t/110 (Sept 2023) — earliest precursor

[t/110 — "Fedimint Overview and Fedipool Theorizing"](https://delvingbitcoin.org/t/110) — September 2023, EthnTuttle.

Proposes a **"Poolimint"** Fedimint module that validates shares and pays out via ecash. **This predates t/870 by 8 months** and is the **earliest known articulation** of the federated-mint-as-mining-pool concept that later became hashpool's design.

So the eHash conceptual lineage is:
1. **t/110 Sept 2023** — Fedipool/Poolimint via Fedimint (federated)
2. **t/870 May 2024** — Ecash TIDES via Cashu (single-mint)
3. **vnprc/hashpool** Nov 2024 — implementation begins
4. **PioneerHash org** Oct 2025 — EthnTuttle's own integration vehicle

## Pattern interpretation

EthnTuttle's contribution mode is **strategic protocol commentary + parallel reimplementation**, not upstream PR-driven collaboration. Pattern across ecosystems:

- Fedimint: heavy hands-on dev infra contributor (2023-2024) → moves on
- Cashu: single NUT-01 spec edit + one substantive PR closed
- Stratum V2 SRI: zero PRs, but high-impact RFCs (Iroh #1935)
- DMND/SLICE: one polite PR + private design tracking via own pplns-jd repo
- 256 Foundation Hydrapool: zero PRs, but forks `mujina` and `hydrapool-startos` under PioneerHash

He **publishes thesis posts on delvingbitcoin (t/110, t/870), authors RFCs, and runs his own integration vehicle (PioneerHash)** — but does not heavily upstream into other people's repos. His own `pplns-jd` repo as of Feb 2026 is a stake-claim placeholder for a Rust crate he plans to write, **not a co-authored work with Fi3**.

## Sources

- https://github.com/EthnTuttle/pplns-jd (empty, size 0)
- https://github.com/EthnTuttle/pplns-jd/issues/7
- https://github.com/dmnd-pool/share-accounting-ext/pulls/2 (Nov 2024, open)
- https://delvingbitcoin.org/t/pplns-with-job-declaration/1099 (no EthnTuttle posts)
- https://delvingbitcoin.org/t/110 (Sept 2023 Fedipool precursor — newly surfaced)
- https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870
- https://github.com/lorbax/pplns-with-job-declaration (no EthnTuttle contributions)

## See also

- [[2026-05-24-ethntuttle-profile|EthnTuttle profile]] — original
- [[2026-05-24-pioneerhash-org|PioneerHash org]]
- [[../../wiki/concepts/pplns-jd|SLICE / PPLNS-JD concept]]
