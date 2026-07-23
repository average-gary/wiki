---
title: "Stratum V2 spec — 06 Job Declaration Protocol (JDC/JDS, miner-declared coinbase)"
source_url: https://github.com/stratum-mining/sv2-spec/blob/main/06-Job-Declaration-Protocol.md
type: article
retrieved: 2026-07-21
credibility: high
corroboration: "Cited by prior-art + trust-model agents"
tags: [stratum-v2, job-declaration, JDC, JDS, coinbase_tx_prefix, coinbase_tx_suffix, AllocateMiningJobToken, DeclareMiningJob, trust-minimization]
summary: "SV2 Job Declaration Protocol — the actual trust-minimization mechanism. JDC (miner side) declares a custom job/coinbase; JDS (pool side) validates. The pool payout is the FIRST coinbase output. This is the mechanism a passive verify-daemon is NOT."
---

# SV2 spec — 06 Job Declaration Protocol

## Purpose

> "The Job Declaration Protocol is used to coordinate the creation of custom work,
> avoiding scenarios where Pools are unilaterally imposing work on miners."

Framed as "a key feature of Stratum V2 that improves Bitcoin decentralization."

## Roles

- **JDC (Job Declarator Client, miner side)** — receives templates from a Template
  Provider, declares custom jobs, manages share/block submission, runs **fallback
  strategies if the server misbehaves**.
- **JDS (Job Declarator Server, pool side)** — allocates job tokens, validates
  declared jobs against its mempool, can request missing txs, publishes found blocks.

## Coinbase mechanics (the checkable fields)

- `AllocateMiningJobToken.Success` returns a coinbase template where the **FIRST
  output is the pool payout output (initially 0 sats)**. The JDC MUST allocate
  template revenue to that output to earn rewards, MAY add/reorder its own outputs.
  Partial allocation → proportionally reduced rewards.
- `DeclareMiningJob` carries **`coinbase_tx_prefix`**, **`coinbase_tx_suffix`** (the
  coinbase bytes around the extranonce) + a `wtxid_list` + `mining_job_token` — the
  exact coinbase the miner will hash is explicitly declared and committed.
- Two modes: **coinbase-only** (pool checks fee revenue by inspecting only the
  coinbase, preserving miner mempool privacy) and **full-template** (JDS sees txids,
  can `ProvideMissingTransactions`).

## Trust model

Trust is enforced **economically, not cryptographically at the miner**: if the pool
"rejects valid shares under a Custom Job that was previously acknowledged," the JDC
can "switch to a new Pool+JDS (or solo mining as a last resort)," which "incentivizes
honesty on Pool side, otherwise it will lose hashrate."

**Contrast with a passive verify-daemon:** with JD the *miner constructs and declares*
the template/coinbase (so there's no "expected value" to trust the pool about — the
miner sets it). Without JD the pool constructs both and the miner merely verifies
what it's told. A JDS's coinbase-value check ≈ what an external verify-daemon would
re-implement against a non-JD pool.
