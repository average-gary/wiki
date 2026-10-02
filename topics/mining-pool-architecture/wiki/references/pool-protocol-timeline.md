---
title: "Pool Protocol Timeline"
category: reference
sources:
  - raw/articles/2026-09-21-stratum-v1-original-announcement-slush.md
  - raw/papers/2026-09-21-bip22-bip23-getblocktemplate.md
  - raw/notes/2026-09-21-protocol-lineage-secondary-sources.md
  - raw/articles/2026-09-21-bitcoin-core-mining-ipc-and-template-interfaces.md
  - raw/repos/2026-09-21-sri-and-sv2-apps-hardening-releases-2026.md
  - raw/articles/2026-09-21-dmnd-datum-decentralised-template-deployments.md
  - raw/papers/2026-09-21-bip310-stratum-extensions.md
created: 2026-09-21
updated: 2026-09-21
tags: [timeline, getwork, getblocktemplate, stratum-v1, stratum-v2, bip310, datum, mining-ipc, forcing-functions, protocol-history]
aliases: ["pool history", "stratum history", "protocol lineage"]
confidence: medium
volatility: cold
summary: "Dated lineage of pool work-distribution protocols with the forcing function behind each transition, and an explicit note on which dates rest on primary sources versus secondary ones. The recurring pattern: the option that is better on the axis nobody is currently paying for loses to the option that solves the operator's present problem — GBT specified miner template control in February 2012 and lost to Stratum six months later on deployability."
---

# Pool Protocol Timeline

> **Date provenance.** ✅ = confirmed from a primary document. ⚠️ = secondary source only. ❌ = could not
> be verified in this research round.

| Date | Event | Architectural consequence |
|---|---|---|
| pre-2012 | **`getwork`** — JSON-RPC over HTTP, 60 s long-poll work lifetime, fresh request on nonce exhaustion, client-side byte-swapping and SHA-2 padding removal ⚠️ | Work generation coupled to validation; server request rate scales with hashrate. Documented ~4 GH/s ceiling. |
| — | Extensions: `longpoll`, `rollntime`, `noncerange`, `hostlist`/`switchto` ⚠️ | Each buys **more local iteration per server round trip** — the whole diagnosis is legible in the extension list. `rollntime` → BIP 310 version rolling is a direct line. |
| **2010-11-27** | **Slush Pool** announced on BitcoinTalk as "a cooperative mining server" — first publicly known pool ⚠️ | Establishes the centralised model: one coordinator distributes work, constructs blocks, distributes rewards. |
| (shortly after) | Initial "artificially low difficulty" accounting was **pool-hopped**; replaced by a **score-based scheme** weighting recent shares more ⚠️ | **The first architectural change in pool history was an anti-gaming accounting fix, not a performance one.** The pattern holds throughout. |
| **2011-06-17** | **p2pool** announced (Forrest Voight); mainnet testing mid-July, review 2011-07-26 ⚠️ | Share chain at a 30 s target, nodes retaining the last 8,640 shares (~3 days), 99.5% to recent contributors / 0.5% to the announcer. Requires a full node per miner. |
| **2012-02-28** | **BIP 22 + BIP 23 — `getblocktemplate`** (Luke Dashjr), status Deployed ✅ | Node returns the **full candidate block**; work generation moves outside the validating node — the separation every pool is built on. BIP 23 adds pooled-mining extensions whose stated purpose is to **counteract mining centralisation**: block proposal, expiry, custom target, a mutation set (`coinbase/append`, `time/increment`, transaction addition, version switching), submission abbreviation, two conformance levels. |
| **2012-09-11 03:07** | **Stratum V1 announced** by Marek Palatinus (slush0) on BitcoinTalk ✅ | Stated goals: server-driven load management for **10k+ connections** at minimal CPU, reduced bandwidth and latency vs getwork, **ASIC readiness**. Explicitly rejects BIP 22/23 as too complex for rapid deployment, arguing a "complete stack and step-by-step algorithm" mattered more than payload definitions. |
| same thread | BTC Guild's operator withdraws a near-identical competing proposal to avoid a **"VHS vs Betamax"** split; requests **graceful restart notifications with a wait timer** ✅ | Stratum becomes the de facto standard. **Work push replaces work pull**, which is what makes 10k+ idle-but-latency-sensitive connections viable and makes every later pool a fan-out problem. Also: the first feature request on day one is about connection lifecycle under operator-initiated disruption. |
| late 2012 | Stratum adopted by major pools and miner software ⚠️ | **Pool-constructed templates become the norm for the next 7+ years** — transaction selection lands with operators as a *side effect* of a scalability decision. No BIP; developed "behind closed doors". |
| **~2014** | **ckpool** released (Con Kolivas) ❌ *date unverified — README carries none* | ASIC-era response: multi-process + multi-threaded, `epoll`, Unix-socket IPC, in-memory accounting, passthrough trees, socket handover. |
| — | **BIP 310** — Stratum extensions (Moravec, Čapek) ⚠️ *no date captured* | `mining.configure` as the **first** message, before `mining.subscribe`; namespaced parameters with a server result map. **`version-rolling`** (mask invariant `version_bits & ~last_mask == 0`) and **`minimum-difficulty`**. Recorded hazard: "many server implementations close connections upon receiving unknown messages" — which is *why* negotiation had to be a pre-subscribe handshake. |
| **2019** | **Stratum V2** development begins — Pavel Moravec, Jan Čapek, with Matt Corallo ⚠️ | Motivations: V1 MITM exposure enabling undetected hashrate hijacking; loss of miner template control; hashrate growth ~10 TH/s → ~600 EH/s. |
| **2019-11-13** | **SV2 specification published** ⚠️ | Binary framing, encryption/authentication, optional miner-declared templates. |
| **2023** | Original plan to embed a Template Provider **inside** Bitcoin Core (PR #23049); **PR #29432 closed** ✅ | Rejected on the grounds of no new network ports in Core and no protocol-specific mining code in the consensus codebase. **Core declined to know what Stratum is.** |
| **2024-03** | **SRI v1.0** released ⚠️ | First production-intended SV2 reference implementation. |
| **2024-09-29** | **Ocean DATUM** documentation published ⚠️ | Miner's own node builds the template via GBT; pool coordinates rewards. Speaks **Stratum V1 + version rolling** to the hardware — template decentralisation *without* SV2. (Its "first decentralized protocol since 2017" claim is marketing: p2pool had mainnet blocks in Feb 2018.) |
| **2024-10-16** | Core tracking issue **#31098** — Stratum V2 via **IPC Mining interface** (Sjors Provoost) ✅ | The pivot: a **general-purpose Mining interface over Cap'n Proto IPC**, consumable by anything, instead of embedding a protocol. |
| **2025-06** | Core **PR #31981** merged — `checkBlock()` ✅ | Full block validation **without** PoW and without mutating mempool state. Makes validating a miner-declared template affordable. |
| **2025-08-20** | Core **PR #31802** merged — `bitcoin-node`/`bitcoin-gui` with `ENABLE_IPC` on by default in **official release binaries**, shipping in v30 ✅ *(merge date; v30's release date is NOT established here)* | **Removes the forked-bitcoind requirement**, documented in the PR as the stated blocker for SV2 adoption. Templates are now **pushed** when a fee threshold is crossed rather than polled. |
| **2026-06-26** | **First Bitcoin block mined with SV2 Job Declaration** — DMND, height **955,318** ⚠️ *(height consistent with the date)* | Real adoption of miner-declared templates, **seven years after the specification**. |
| **2026-07-07** | Core **PR #34020** merged — `getTransactionsById()` / `getTransactionsByWitnessID()`, batched, IPC-only, no `-txindex` ✅ | **wtxid** lookup is what makes validating custom templates affordable; SV2 job declaration identifies transactions by wtxid, which `getrawtransaction` cannot do. Also serves redundant block broadcast by the pool. |
| 2026-07 | Core **PR #35675** opened (still open) ✅ | `BlockTemplateManager` to centralise template state "scattered across NodeContext, miner.cpp, RPC, and tests". |
| **2026-09-17** | **SRI v1.12.0** and **sv2-apps v0.8.0** ⚠️ *(agent's timeline double-listed the release series under 2025 and 2026; 2026 taken as correct)* | Hardening: BIP323, `nTime` upper bounds, consensus-invalid coinbase fixes with a 100-byte scriptSig budget check, **job storage bounded on every axis**, AES-256-GCM removed, share-replay fixes, `ExtranoncePrefix` use-after-free. sv2-apps implements **third-party Loupe audit** findings. |
| **2026-09-18** | **Optech #423** — Eric Price's vardiff non-arrival finding ✅ | Arrival-triggered vardiff cannot detect a slowing miner; needs a timer, and must live at **"the last hop that still sees each miner's shares."** |

## The four forcing functions

1. **`getwork` → Stratum/GBT (2012).** Request rate scaling with hashrate, nonce exhaustion, the 60 s
   work lifetime.
2. **GBT vs Stratum (2012).** *Deployability beat decentralisation.* Stratum claimed 10k+ connections at
   minimal CPU; GBT offered template auditing nobody was paying for. **This is the most instructive data
   point in the topic:** architecture that is better on the axis nobody currently pays for loses to
   architecture that solves the operator's present problem.
3. **V1 → V2 (2019).** Industrial scale, MITM exposure (given a working attack by Recabarren & Carbunar
   at PETS 2017), and the recognition that pool-side templates had become a governance problem.
4. **Centralised → decentralised templates (2024–26).** Concentration risk (top 3 ≈ 60% as of 2026-09)
   plus — finally — tooling that made it affordable: `checkBlock()`, batched wtxid lookup, official
   multiprocess binaries, and someone paying for it (DMND's SLICE fee scoring, Ocean's 50% fee discount).

**The capability was never the constraint.** BIP 23 specified miner template auditing in 2012 and it
went unused for twelve years. What changed was cost and payment, not possibility.

## Recurring bugs as a lineage of their own

| Bug class | 2012–13 (slush0 `stratum-mining`) | 2026 (SRI) |
|---|---|---|
| Job identity | "Job id 'c3a6' not found" (#20) | `JobStore::add_future_job` drops a colliding job |
| Submitted time | "ntime out of range" (#11) | `nTime` **upper** bounds were missing |
| Per-connection difficulty | request for multi-port difficulty tiers (#21) | BIP 310 `minimum-difficulty`, then SV2 channels |

Fourteen years apart, different languages, different authors, the protocol's inventor on one end.
**Job identity is a small shared namespace with independent client lifetimes; submitted time is
attacker-controlled input.** Both are intrinsically hard, not carelessly implemented.

## Unverified in this round

- **ckpool's release date** (README has none; needs commit history or a release announcement).
- Dates for the **pushpool / eloipool / python-stratum-mining / MPOS / NOMP** generation.
- **BIP 310's** assignment date.
- **Bitcoin Core v30's release date** (as distinct from PR #31802's merge date).

## See Also

- [[template-sourcing-and-control|Template Sourcing and Control]] ([Template Sourcing and Control](../concepts/template-sourcing-and-control.md))
- [[optimal-pool-architecture|Optimal Pool Architecture]] ([Optimal Pool Architecture](../topics/optimal-pool-architecture.md))
- [[pool-implementation-survey|Pool Implementation Survey]] ([Pool Implementation Survey](../topics/pool-implementation-survey.md))
- [[vardiff-as-control-loop|Vardiff as a Control Loop]] ([Vardiff as a Control Loop](../concepts/vardiff-as-control-loop.md))
