---
title: "Bitcoin Core template interfaces: getblocktemplate, ZMQ, and the Mining IPC interface (2024-2026)"
source: "https://github.com/bitcoin/bitcoin/issues/31098"
related_sources:
  - "https://github.com/bitcoin/bitcoin/pull/31802"
  - "https://github.com/bitcoin/bitcoin/pull/34020"
  - "https://github.com/bitcoin/bitcoin/pull/35675"
  - "https://github.com/bitcoin/bitcoin/pull/31981"
  - "https://developer.bitcoin.org/reference/rpc/getblocktemplate.html"
  - "https://github.com/bitcoin/bitcoin/blob/master/doc/zmq.md"
type: articles
ingested: 2026-09-21
tags: [template-sourcing, getblocktemplate, longpoll, zmq, mining-ipc, libmultiprocess, capnproto, template-provider, sv2-tp, push-based-templates, checkblock, wtxid-lookup, sjors-provoost, core-v30]
summary: "The template-source layer of pool architecture and its 2024-2026 rewrite. Baseline: getblocktemplate returns the full candidate block (previousblockhash, transactions with fee/weight/depends, coinbasevalue, bits/target, height, weightlimit, mutable, noncerange) with longpollid for change notification; ZMQ offers hashblock/rawblock/hashtx/rawtx plus a sequence topic (C/D/R/A) with an up-counting number so listeners can detect loss, but subscribers are warned the data 'may be out of date, incomplete or even invalid'. Templates reach ~10 MB of JSON, which is why ckpool sizes socket buffers at 64 MB. The rewrite: after Core rejected embedding Stratum V2 (PR #29432 closed) on the grounds of no new network ports and no protocol-specific code in the consensus codebase, Sjors Provoost's tracking issue #31098 delivered a general Mining interface over Cap'n Proto IPC instead. PR #31802 put bitcoin-node/bitcoin-gui with ENABLE_IPC on by default into official release binaries (merged 2025-08-20, shipping in v30), which removed the forked-bitcoind requirement that had been the stated blocker for SV2 adoption. Subsequent work: checkBlock() for validation without PoW (#31981), getTransactionsById/ByWitnessID for bandwidth-efficient custom-template validation (#34020, merged 2026-07-07), and BlockTemplateManager to centralise template state currently spread across NodeContext, miner.cpp, RPC and tests (#35675, open). Templates are now PUSHED when a fee threshold is crossed rather than polled."
authors: [Sjors Provoost, Bitcoin Core contributors]
published: 2024-10-16
updated: 2026-09
credibility: high
credibility_score: 5
credibility_rationale: "Primary: Core tracking issue, merged PRs with numbers and dates, and official RPC/ZMQ documentation. Two agents independently covered the RPC/ZMQ half and the IPC half."
confidence: high
confidence_rationale: "High for the interface mechanics and the architectural rationale. MEDIUM for the exact v30 release date — see the dating caveat."
research_round: 1
research_agent: "news + applied + technical"
dating_caveat: "An agent reported 'Bitcoin Core v30 released with IPC mining, August 20, 2025'. 2025-08-20 is the MERGE date of PR #31802, not the release date of v30. Do not state a v30 release date from this file without checking the release notes."
extraction_note: "Merged from three subagent reports. PR numbers, titles and merge dates are as reported and should be spot-checked before citation; they were internally consistent across the reports that overlapped."
---

# Bitcoin Core template interfaces

The template source is a first-class architectural component of a pool, and between 2024 and 2026 it
changed shape. This file covers both the long-standing interface and the replacement.

## Baseline: `getblocktemplate` (BIP22/23)

`getblocktemplate ( "template_request" )`. Request object:

- **`mode`** — `"template"` (default) or `"proposal"` (BIP23 validation of a candidate).
- **`capabilities`** — `longpoll`, `coinbasevalue`, `proposal`, `serverlist`, `workid`.
- **`rules`** — declared softfork support, typically `["segwit"]`.

Response fields that matter to a pool: `previousblockhash`, `transactions` (hex, txid,
**`depends` as 1-based indices**, `fee`, `weight`), `coinbasevalue` (subsidy + fees), `target` and
`bits`, `height`, `curtime`, `weightlimit`, `sigoplimit`, `sizelimit`, **`mutable`** (which elements
the client may change — e.g. `time`, `transactions`, `prevblock`), **`noncerange`**, and
**`longpollid`** (opaque token to long-poll on template change).

**The pool-side flow** this implies: request template → select transactions (fee-maximising, within
weight) → build the coinbase (subsidy + fees, BIP34 height in scriptSig, pool signature, payout
outputs; BIP23 allows appending ≤100 bytes) → compute the merkle root by iterated double-SHA256,
usually distributing the **merkle branch** rather than the full transaction list → hand out work with
header fields plus extranonce/nonce space and a share-level target → watch `longpollid` (or ZMQ) →
`submitblock` on a solution.

**Two hard numbers.** The template can reach **~10 MB of JSON** — which is exactly why ckpool sizes
its socket buffers at 64 MB. And GBT replaced `getwork`, which the docs peg at a **~4 GH/s** ceiling.
Unlimited local iteration of nonce/time/extranonce without a server round-trip is the whole point.

**Constraints.** Requires a full node with a mempool; cannot be served by a pruned or light node. The
pool must own and resource a Core instance.

## ZMQ notifications

Topics: **`hashblock`** (32-byte reversed hash on tip change), **`rawblock`** (full serialised block),
**`hashtx`**, **`rawtx`**, and a **`sequence`** topic carrying mempool events — `C` block connected,
`D` block disconnected, `R` tx removed, `A` tx added.

Properties worth designing around:

- **Every notification carries an up-counting sequence number "which allows listeners to detect lost
  notifications."** That is the only loss-detection primitive in the interface; use it.
- PUB/SUB, write-only, no state on the daemon side, **no buffering** — all-at-once delivery.
- Connections **self-heal** after an outage, which means a pool can silently miss the events during
  the gap and then resume — hence the sequence number.
- Explicit warning: "Subscribers should validate the received data since it may be out of date,
  incomplete or even invalid."
- A transaction can be published **multiple times** (on mempool entry, then in each block including
  it) — dedup is the consumer's job.
- **assumeutxo caveat**: no `hashblock` for historical blocks connected to the background validation
  chainstate.
- Security: "expose ZMQ ports only to trusted entities, using other means such as firewalling."

## The rewrite: Mining interface over IPC

**What was rejected first.** The original 2023 plan (PR #23049) embedded a Template Provider in Core
speaking SV2 directly. **PR #29432 was closed.** The stated community objections: no new network
ports in Core, and no protocol-specific mining code in the consensus codebase. This is the
architecturally significant fact — *Core declined to know what Stratum is*.

**What replaced it.** Tracking issue **#31098** (Sjors Provoost, opened 2024-10-16): a
**general-purpose Mining interface exposed over Cap'n Proto IPC** via `libmultiprocess`, which SV2 or
anything else can consume from outside. Landed across roughly seven PRs (#31318, #31283, #31785,
#31346, #31196, #31197, #31288) plus multiprocess release-binary work (#31802, #31741, #31763).

**PR #31802 — the unblocking change** (opened 2025-02-05, **merged 2025-08-20**, shipping in v30):

- `ENABLE_IPC` on by default in depends builds.
- **`bitcoin-node` and `bitcoin-gui` added to official release binaries** (all platforms except
  Windows; Windows tracked in #32387), runnable as `bitcoin-node -m node -ipcbind=unix`.
- CI extended to test `-m` mode in the functional suite; added to `Maintenance.cmake` as release
  artifacts.

The adoption argument in the PR description is the part worth keeping: before v30 a pool wanting SV2
had to **download a forked `bitcoind` from a contributor's personal repository**; after v30 it runs
official Core plus a Template Provider sidecar. Quoted in the PR: *"forked Bitcoin Core remains a
significant barrier to adoption."* Also recorded there as of early 2025: Braiins had SV2 support
(custom firmware + pool infra) years earlier; new hardware was shipping with native SV2 support; DMND
launched SV2-native; and multiple other implementations were **blocked by the fork requirement**.

**Follow-on work:**

- **#31981** (merged 2025-06): **`checkBlock()`** — full block validation **without** PoW
  computation, and without modifying mempool state. Directly enables a pool to validate a
  miner-declared template.
- **#34020** (opened 2025-12-05, **merged 2026-07-07**): **`getTransactionsById(vector<Txid>)`** and
  **`getTransactionsByWitnessID(vector<Wtxid>)`**, batched, **IPC-only** (not exposed via RPC), and
  **not requiring `-txindex`**. Motivation: when a miner declares a custom template, the pool must
  fetch transactions it does not know; `getrawtransaction` per txid needs `-txindex` and cannot look
  up by **wtxid**, which is what SV2 job declaration uses (per BIP141). Two driving use cases: (a)
  template approval — the pool needs contents to check fees and policy; (b) **block broadcast
  redundancy** — the pool relays the found block in addition to the miner, which needs full
  transaction data, not just validation. Links to sv2-spec issue #170 on custom-job bandwidth.
  Rust consumption demonstrated via Cap'n Proto bindings (`2140-dev/bitcoin-capnp-types` PR #11).
  Milestone v32.0.
- **#35675** (opened 2026-07, **still open** as of 2026-09): **`BlockTemplateManager`**, centralising
  template state currently "scattered across NodeContext, miner.cpp, RPC, and tests."

**Push replaces poll.** The Mining interface **pushes** a fresh template when a fee-rate threshold is
crossed, rather than making the pool poll `getblocktemplate`. This is the same control loop that
sv2-apps exposes as `fee_threshold` and `min_interval`, and that ckpool implements as a 100 ms
`blockpoll` — now moved into the node and made event-driven.

**Ecosystem state as reported**: `sv2-tp` (Sjors' C++ Template Provider) at **v1.0.6**, described as
production-ready and compatible with **Core v30.2+**; SRI (Rust) integration underway; Braiins and
DMND adoption in progress.

## Architectural reading

1. **The interface boundary moved, and that is the whole story.** Core now exports *mining
   primitives* (get a template, check a block, fetch transactions by wtxid) and knows nothing about
   Stratum. Every protocol-specific concern lives in a sidecar. A pool's template layer is therefore
   now a *choice of adapter*, which is precisely the shape sv2-apps encodes as
   `template_provider_type`.
2. **Push beats poll, and the threshold is a tunable.** "New template when fees moved enough" is
   strictly better than "ask every 100 ms", but it introduces a policy parameter — how much fee
   change is worth a job churn — that someone now has to choose.
3. **wtxid lookup is what makes miner-declared templates affordable.** Without batched wtxid
   retrieval, validating a custom template means either running `-txindex` or shipping full
   transactions on the wire. This single PR is load-bearing for Job Declaration being practical.
4. **Redundant block broadcast is an explicit design goal.** The pool relays the block *as well as*
   the miner. Worth noting for any architecture that assumes exactly one broadcaster.
5. **The 2012 decentralisation argument won on Core's terms, twelve years later** — but as a neutral
   interface rather than as BIP23's mutation/proposal mechanism. BIP23 specified miner template
   auditing and nobody used it; the IPC interface specifies nothing about mining policy and is being
   adopted.
