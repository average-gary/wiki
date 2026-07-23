---
title: "SV2 Coinbase-Verification Mining Daemon — Wiki"
type: wiki-root
created: 2026-07-21
updated: 2026-07-21
scope: hub-topic
summary: "Engineering a simple daemon that connects as a miner to a Stratum V2 pool, receives mining jobs, reconstructs the coinbase transaction, and checks it against an expected value (e.g. an expected payout output / scriptPubKey / tagged scriptSig). Covers the SV2 client role and message flow (SetupConnection → OpenMiningChannel → SetNewPrevHash/NewMiningJob), how the coinbase is (or isn't) exposed to a miner across the three SV2 topologies (Pool-only, Job Declaration, Template Distribution), which SRI crates a minimal Rust client uses, coinbase transaction structure and the merkle-root reconstruction a miner already performs, and what 'expected value' checks are feasible vs. impossible for a downstream miner."
---

# SV2 Coinbase-Verification Mining Daemon — Wiki

Topic wiki for a concrete engineering artifact:

> A **simple daemon** that connects to mine to a **Stratum V2 pool**, and does a
> **coinbase transaction check** to determine whether the coinbase matches an
> **expected value**.

The core research questions:

1. **What does the miner actually receive?** In SV2, how much of the coinbase is
   visible to a downstream mining client, and how does that differ across the
   Pool-only, Job-Declaration, and Template-Distribution topologies?
2. **What can a miner verify?** The miner reconstructs the merkle root to hash a
   block header — so it necessarily touches the coinbase (or a coinbase hash /
   merkle path). Which "expected value" checks are actually possible (payout
   scriptPubKey, tagged scriptSig, output amount) vs. which require Job
   Declaration or a Template Provider?
3. **How do you build it?** Minimal Rust client stack (SRI crates), message flow,
   the coinbase reconstruction/parse, and the daemon loop.

## Layout

- `wiki/concepts/` — atomic concept articles (SV2 client role, coinbase structure, merkle reconstruction, message types)
- `wiki/topics/` — synthesizing topic/build articles
- `wiki/references/` — pointers to specs, SRI crates, related tools
- `raw/` — ingested source material with provenance
- `output/` — generated build playbook / design artifacts

## Quick Navigation

- [All Sources](raw/_index.md)
- [Concepts](wiki/concepts/_index.md)
- [Topics](wiki/topics/_index.md)
- [Reference](wiki/references/_index.md)
- [Outputs](output/_index.md) — [Build Playbook](output/playbook-sv2-coinbase-verify-daemon-2026-07-21.md) · [cbcheck plan](output/plan-coinbase-address-check-daemon-2026-07-21.md)

## Stats

- Sources ingested: **18** (8 articles, 3 papers/BIPs, 6 repos, 1 data)
- Articles compiled: **14** (10 concepts, 3 topics, 1 reference)
- Outputs: **2** — [build playbook](output/playbook-sv2-coinbase-verify-daemon-2026-07-21.md) + [cbcheck implementation plan](output/plan-coinbase-address-check-daemon-2026-07-21.md)
- Research sessions: 2026-07-21 R1 (5 agents: client-flow / coinbase-structure / Rust-stack / prior-art / trust-model) + R2 gap-closing (4 paths: reference-impl / stratum-sniffer / expected-value sourcing / deviation-detection)
- Last updated: 2026-07-21

## Key findings

1. **The pivotal design fact:** only an **extended** SV2 channel exposes the coinbase.
   `NewMiningJob` (standard channel) carries only an opaque `merkle_root`; a coinbase
   check is *structurally impossible* there. `NewExtendedMiningJob` carries
   `coinbase_tx_prefix` / `coinbase_tx_suffix` / `merkle_path` — the only place a
   downstream client sees the pool's coinbase bytes. → the daemon must
   `OpenExtendedMiningChannel`.
2. **Don't reimplement the crypto:** SRI's `channels_sv2::client::extended::ExtendedChannel`
   (`validate_share`) and `merkle_root::merkle_root_from_path` already do coinbase
   reconstruction → merkle fold → header hash → target compare. Fork the SRI
   `mining-device` skeleton and swap standard→extended.
3. **"Expected value" is a family of checks** (payout scriptPubKey, output value,
   scriptSig tag / BIP34 height / merged-mining `0xfabe6d6d`, OP_RETURN commitment,
   coinbase↔root integrity) — all require the raw coinbase bytes; none work on a
   standard channel.
4. **Honest scoping:** a passive check is **trust-but-verify**, not trustless. It proves
   only *this job's* coinbase as served to *this miner* — not what's mined/broadcast,
   not what others get, not aggregate payout. Real trust-minimization is **Job
   Declaration** (miner authors the coinbase). No existing tool fills the per-miner-SV2
   coinbase-assertion niche (miningpool.observer ignores the coinbase; stratum.work is
   V1 and non-asserting).

### Round 2 (gap-closing) additions

5. **Source-verified code skeleton.** Crate versions confirmed on crates.io
   (`stratum-core 0.5`, `mining_sv2 11`, `channels_sv2 7`, `codec_sv2 6`, `bitcoin 0.32.5`);
   exact struct/fn signatures + frame idioms captured, with an honest UNVERIFIED list.
   See [[wiki/topics/reference-implementation-skeleton]].
6. **Be your own client, don't sniff.** `stratum-sniffer` is an active MITM (own hardcoded
   keypair, terminates two Noise sessions), not a passive tap — SV2's encryption means a
   direct SV2 client is the only clean path.
7. **Sourcing the expected value** splits into subsidy (from height:
   `5e9 >> (height/210000)` = 3.125 BTC today), fees (need a template Provider), and
   payout target (pool-address for custodial FPPS/PPLNS vs miner-address for SOLO/DATUM/JD).
   See [[wiki/concepts/sourcing-the-expected-value]].
8. **Deviation detection** design: intra-channel job-diff (anchor coinbase changes to
   `SetNewPrevHash`) + on-chain correlation loop; block withholding is provably
   undetectable from share stats (APoW, Optech). See [[wiki/concepts/deviation-detection]].

Deliverable: [[output/playbook-sv2-coinbase-verify-daemon-2026-07-21|Build Playbook]].

## Related wikis

- [[../sv2-coinbase-identity/_index|sv2-coinbase-identity]] — what per-miner identity/tags can be embedded in the coinbase, and where SRI stores them.
- [[../stratum-sri/_index|stratum-sri]] — the SRI SV2 crate suite a client daemon builds on.
- [[../datum/_index|datum]] — OCEAN DATUM: miner-selected block templates / coinbase (a different route to coinbase control).
- [[../sv2-p2pool-integration/_index|sv2-p2pool-integration]] — SV2 client/pool integration surface.
- [[../bitcoin-mining-payout-schemas/_index|bitcoin-mining-payout-schemas]] — payout/accounting context for "expected value".
