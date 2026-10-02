---
title: "Template Sourcing and Control"
category: concept
sources:
  - raw/articles/2026-09-21-bitcoin-core-mining-ipc-and-template-interfaces.md
  - raw/papers/2026-09-21-bip22-bip23-getblocktemplate.md
  - raw/articles/2026-09-21-dmnd-datum-decentralised-template-deployments.md
  - raw/articles/2026-09-21-solo-ckpool-production-operations.md
  - raw/repos/2026-09-21-sv2-apps-pool-role-architecture.md
  - raw/papers/2026-09-21-measurement-bitcoin-networks-from-mining-pools.md
created: 2026-09-21
updated: 2026-09-21
tags: [template-sourcing, getblocktemplate, mining-ipc, push-vs-poll, template-provider, job-declaration, datum, transaction-selection, feerate-cliff, decentralisation, incentives]
aliases: ["template provider", "block template", "who builds the block"]
confidence: high
volatility: warm
summary: "Where a pool's block template comes from, and who chooses its contents — two questions that were the same question for a decade and are now separate. The sourcing interface moved from polling getblocktemplate to a push-based Cap'n Proto IPC Mining interface in official Bitcoin Core binaries; the control question now has four distinct answers running in production, differing not in protocol capability but in who pays the operational cost."
---

# Template Sourcing and Control

> Two questions. **Sourcing**: how does the pool obtain a candidate block from a node? **Control**: who
> decides what goes in it? From 2012 to 2024 the answer to the second was "the pool", as a side effect
> of the answer to the first. They have now come apart.

## Sourcing: the interface, and its 2024–26 rewrite

### The baseline — `getblocktemplate` (BIP 22/23, 2012)

The node returns a **full candidate block**: `previousblockhash`, the `transactions` array (hex, txid,
`depends` as 1-based indices, `fee`, `weight`), `coinbasevalue`, `target`/`bits`, `height`, `curtime`,
`weightlimit`, `sigoplimit`, `mutable` (which elements the client may change), `noncerange`, and
`longpollid` for change notification. Submission via `submitblock`.

BIP 22's stated motivation is the architecturally load-bearing one: bitcoind's JSON-RPC server could no
longer generate the work required to mine productively, so **work generation had to live outside the
validating node.** That separation is why a pool is a separate program from a node at all, and why
"template source" is a component with its own failover requirements.

**Two numbers**: a mainnet template reaches **~10 MB of JSON** (ckpool sizes 64 MB socket buffers for
it), and the `getwork` it replaced had a documented ceiling around **4 GH/s**.

### Notification: long-poll, then ZMQ

ZMQ offers `hashblock`, `rawblock`, `hashtx`, `rawtx` and a `sequence` topic (`C` connected,
`D` disconnected, `R` removed, `A` added). The property to design around: **every notification carries
an up-counting sequence number so listeners can detect loss** — the only loss-detection primitive in
the interface. Connections self-heal after an outage, which means a pool can silently miss events
during the gap, so the sequence number is not optional. The docs warn explicitly that received data
"may be out of date, incomplete or even invalid."

### The rewrite: Core's Mining interface over IPC

**What was rejected first matters.** The original 2023 plan embedded a Template Provider speaking SV2
inside Core (PR #23049); **PR #29432 was closed**. The stated objections: no new network ports in Core,
and no protocol-specific mining code in the consensus codebase. **Core declined to know what Stratum
is.**

What replaced it (tracking issue #31098, Sjors Provoost): a **general-purpose Mining interface over
Cap'n Proto IPC** via `libmultiprocess`, consumable from outside by anything.

- **PR #31802** (merged **2025-08-20**, shipping in v30) put `bitcoin-node` and `bitcoin-gui` with
  `ENABLE_IPC` on by default into **official release binaries**, runnable as
  `bitcoin-node -m node -ipcbind=unix`. This removed the requirement to run a **forked bitcoind from a
  contributor's personal repository**, which the PR documents as the stated blocker for SV2 adoption.
- **PR #31981**: `checkBlock()` — full validation **without** PoW computation and without mutating
  mempool state. This is what makes validating a miner-declared template affordable.
- **PR #34020** (merged **2026-07-07**): `getTransactionsById()` and `getTransactionsByWitnessID()` —
  batched, **IPC-only**, and **not requiring `-txindex`**. SV2 job declaration identifies transactions
  by **wtxid**, which `getrawtransaction` cannot look up at all. Two driving uses: template approval
  (the pool needs contents to check fees and policy) and **redundant block broadcast** (the pool relays
  the found block *in addition to* the miner, which needs full transactions).
- **PR #35675** (open): `BlockTemplateManager`, centralising template state currently "scattered across
  NodeContext, miner.cpp, RPC, and tests."

**Push replaces poll.** The interface **pushes** a fresh template when a fee-rate threshold is crossed.
sv2-apps exposes the same control loop as configuration — `fee_threshold` (how much fee movement
justifies a new template) and `min_interval` (a floor on update rate) — where ckpool hard-codes a
100 ms `blockpoll` and a 30 s `update_interval`. Every pool has this loop; the question is whether it
is tunable and who owns it.

### Redundancy

The template source is a full node with a mempool and cannot be a pruned or light node. ckpool takes a
**`btcd` failover array** plus a choice of notification mechanism (RPC poll / `-blocknotify` / ZMQ /
Cap'n Proto IPC); sv2-apps takes one of two `template_provider_type` adapters. Adversarial mempool load
makes template construction slower and larger exactly when fee revenue is highest — the 2015 dust-spam
storms crashed over 10% of reachable nodes — so this component wants dedicated, resourced hardware.

## Control: four positions, all in production

The measured baseline first. Wang/Chu/Yang found transaction selection at top pools is
**feerate-dominated with a sharp cliff**: ~90% inclusion if a transaction's feerate ranks inside the
top X (X = transactions in the next block), **below 5% outside the top 2X**. Top pools run a near-pure
feerate-greedy selector. That is what any alternative is deviating from.

| Position | Who builds | Who validates | Cost to miner | Example |
|---|---|---|---|---|
| **Pool-chosen, opaque** | Pool | n/a | none | most pools |
| **Pool-chosen, published** | Pool, default Core policy, no filtering | anyone, from the published list | none | solo.ckpool at `/pool.txns` |
| **Miner-declared, pool-validated** | Miner (JDC) | Pool (JDS) via `checkBlock()` + wtxid lookup | run a JDC + template provider | SV2 Job Declaration / DMND |
| **Miner-sovereign, pool coordinates** | Miner's own node via GBT | Pool, after submission (during beta) | **full node per operation** | Ocean DATUM |

The second row deserves more attention than it gets: **pool-chosen but publicly auditable** obtains
most of the censorship-resistance argument at none of the operational cost — no miner node, no
template negotiation — while leaving the pool in control. It is the cheap option the decentralisation
debate usually skips.

DATUM is notable for a different reason: it reaches decentralised templates **while speaking Stratum V1
to the ASICs**. Template decentralisation and the V1→V2 migration are **separable problems**, and DATUM
separates them.

## Incentives are the binding constraint, not capability

**BIP 23 specified miner template auditing in 2012**, with the explicit goal of countering mining
centralisation — block proposal, a defined mutation set (`coinbase/append`, `time/increment`,
transaction addition, version switching), and two conformance levels. Nobody used it. Stratum V1
arrived six months later with no such mechanism and won on deployability.

So the accurate claim about template decentralisation is **not** that the capability is new — it is
that it is newly *adopted*, and that what changed was cost and payment:

- **Cost fell**: `checkBlock()` and batched wtxid lookup make validation affordable; official
  multiprocess binaries removed the forked-node requirement.
- **Someone started paying**: DMND's **SLICE** splits PPLNS for the subsidy from **job-declaration
  scoring for the fees** — allocating fee revenue according to whose template was used. Ocean offers a
  **50% fee discount** to DATUM users.

SLICE has an architectural consequence worth noting: attributing fee revenue per template means the
share pipeline must retain **template provenance per share**. Paying for template contribution changes
what the accounting layer has to remember.

**Diffusion time**: the first Bitcoin block mined using SV2 Job Declaration was **2026-06-26 at height
955,318** — seven years after the SV2 specification. Whatever else is true about this class of change,
it moves in years.

## See Also

- [[the-two-hot-paths|The Two Hot Paths]] ([The Two Hot Paths](the-two-hot-paths.md)) — template change is what triggers the job-push path.
- [[pool-protocol-timeline|Pool Protocol Timeline]] ([Pool Protocol Timeline](../references/pool-protocol-timeline.md)) — the getwork → GBT → Stratum → SV2 → IPC lineage.
- [[share-accounting-and-durability|Share Accounting and Durability]] ([Share Accounting and Durability](share-accounting-and-durability.md)) — what template provenance costs the pipeline.
- [[optimal-pool-architecture|Optimal Pool Architecture]] ([Optimal Pool Architecture](../topics/optimal-pool-architecture.md))
- Neighbouring hub topics: `datum` (DATUM internals), `sv2-p2pool-integration`, `stratum-sri` (SV2 crate internals).
