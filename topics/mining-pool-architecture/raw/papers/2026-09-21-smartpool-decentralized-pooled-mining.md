---
title: "SmartPool: Practical Decentralized Pooled Mining"
source: "https://eprint.iacr.org/2017/019"
type: papers
ingested: 2026-09-21
tags: [decentralised-pooling, probabilistic-verification, augmented-merkle-tree, batched-claims, share-commitment, p2pool-critique, smart-contract-pool, share-theft-prevention, message-overhead]
summary: "Luu, Velner, Teutsch & Saxena (NUS / Hebrew University / TrueBit). Replaces the pool operator with a smart contract that verifies batched share claims by probabilistic sampling. Two architectural ideas transfer regardless of the Ethereum substrate: (1) batching — a miner commits to ~1M shares with one Merkle root in one message, breaking the 'messages scale with shares' ceiling that the paper identifies as P2Pool's core defect; (2) probabilistic verification — sampling k shares from a claim of n where only m are valid detects cheating with probability 1 − (m/n)^k, and paying all-or-nothing makes the cheater's expected payout exactly m, i.e. cheating gains nothing in expectation, so full verification is unnecessary. Adds an augmented Merkle tree (each node carries min, hash, max) with a monotonic counter to prevent duplicate shares within and across claims, and a pre-commitment of the beneficiary address to prevent share theft on a plaintext network. Deployed on Ethereum mainnet: 105 blocks by 18 June 2017, peak 30 GH/s, fees 0.6% of block rewards versus 3% at F2Pool."
authors: [Loi Luu, Yaron Velner, Jason Teutsch, Prateek Saxena]
affiliation: "National University of Singapore; Hebrew University; TrueBit Foundation"
published: 2017
venue: "IACR Cryptology ePrint Archive 2017/019"
credibility: high
credibility_score: 5
credibility_rationale: "Known research group, formal analysis, and — unusually for this literature — a mainnet deployment with reported block counts and fee figures. ePrint version; treat the deployment numbers as author-reported."
confidence: high
research_round: 1
research_agent: academic
relevance_note: "Ethereum-native and altcoin-oriented. Ingested for the two transferable mechanisms (batched commitment, probabilistic verification), NOT as a Bitcoin pool design. The share-chain accounting itself belongs to bitcoin-mining-payout-schemas / sv2-p2pool-integration."
extraction_note: "Subagent extraction from the ePrint PDF. Definitions and the sampling argument are reported faithfully in substance; Table 1 gas figures were not captured. Re-read §3.3-§3.4 and §6.1.1 before using the augmented-Merkle-tree construction."
---

# SmartPool: Practical Decentralized Pooled Mining

**Loi Luu, Yaron Velner, Jason Teutsch, Prateek Saxena** — IACR ePrint 2017/019

## The problem it states

At the time of writing, **~95% of Bitcoin's and ~80% of Ethereum's mining power sat with fewer than
10 and fewer than 6 pools** respectively. Centralised pools require trusting the operator's fairness,
enable transaction censorship, and concentrate 51% risk (GHash.io exceeded 50% on Bitcoin; DwarfPool
on Ethereum).

**Why P2Pool did not fix it** — the paper's diagnosis, which is the part most relevant to pool
architecture generally:

- **Message overhead scales with shares.** The number of messages is a scalar multiple of the number
  of shares. Figure 1 shows the resulting bind: low share difficulty → high message count; high share
  difficulty → high payout variance. There is no setting that is good on both axes.
- **The share chain is weakly secured.** P2Pool held ~0.1% of Bitcoin hashrate, so ~0.1% of hashrate
  suffices to 51%-attack the share chain itself.

## Architecture

The operator is replaced by a **smart contract acting as a trustless bookkeeper**, holding two lists:
`claimList` (submitted, unverified) and `verClaimList` (verified). Miners accumulate shares locally,
submit a **batched claim** (e.g. 1,000,000 shares), the contract verifies by sampling, moves the
claim to `verClaimList`, and disburses. Security rests on the *underlying* chain's consensus, not on
SmartPool's own adoption — the design deliberately piggybacks on an already-large network rather than
bootstrapping a new one. (Contrast with P2Pool, whose share chain must be secured by its own
participants.)

### Batching (challenge C1: message overhead)

Naïvely, 1M shares needs 1M transactions. Instead the miner commits to all of them with a Merkle
root and claims them in a single transaction — messages drop by orders of magnitude relative to
shares.

### Probabilistic verification (challenge C2: fee per share exceeds share value)

Only the root plus the sampled shares are submitted for verification.

**The argument**: if a miner claims `n` shares of which only `m` are valid, sampling `k` shares
detects the cheat with probability `1 − (m/n)^k`. With an all-or-nothing penalty — pay all `n` if no
invalid share is sampled, pay `0` if one is — the cheater's expected payout is `(m/n) × n = m`,
**exactly what honest behaviour would have paid**. Worked example: claiming 1,000 shares with 500
valid → 50% detection → expected payout `0.5 × 1000 + 0.5 × 0 = 500`. So `k = 1` or `2` suffices;
undetected cheating decays exponentially in `k`.

This is the reusable insight: **verification of a high-volume accounting stream can be sampled rather
than exhaustive, provided the penalty function is shaped so that the expected payoff of cheating
equals the honest payoff.** It applies to any share-accounting design with per-share verification
cost, Bitcoin or otherwise.

### Augmented Merkle tree (share ordering and duplicate prevention)

Each node `x` is the triple `(min(x), hash(x), max(x))`, with min/max propagating from children, or
from the leaf's counter `ctr(sᵢ)`. A sorted tree has leaves in **strictly increasing** counter order.
Ethereum uses `(block timestamp, nonce)` as the counter. Monotonicity prevents duplicates *within* a
claim, and the contract additionally stores `last_max` from the previous claim and rejects any new
claim whose `min ≤ last_max` — preventing duplicates *across* claims. Algorithm 1 validates a path by
checking share validity, hash correctness, `min < max`, and `left.max < right.min`. A Merkle proof
for one share is `h` hashes for tree height `h`.

### Share validity checks

The contract samples a random share per claim (index derived from a **future** block hash mod 10⁶ —
so the miner cannot pre-select which share will be checked) and validates: the hash meets the
difficulty criterion; the coinbase/beneficiary is the SmartPool address; the PoW constraints hold
(expensive for Ethereum's 1 GB-dataset PoW, with implementation tricks in §6.1.1).

### Share theft on a plaintext network (challenge C3)

Ethereum transactions are public, so a claim could be copied. The miner must **commit to the
beneficiary address in the block's "extra data" field before mining**, so an observer cannot
re-address the work after the fact. Note the structural similarity to Bedrock's mining cookie: both
bind the work to the payee at construction time rather than at submission time.

### Cross-currency pools (challenge C4)

For a *Bitcoin* pool run on Ethereum: the Bitcoin coinbase pays miners directly (pool's Bitcoin
address in the coinbase), while miners pay Ethereum gas for contract interaction — reported at
**<1% of reward**.

## Deployment results (author-reported)

- Prototypes for both Bitcoin and Ethereum; Ethereum version deployed on mainnet via a crowdfunded
  community project.
- As of **18 June 2017**: **105 blocks** mined across Ethereum and Ethereum Classic; peak handled
  hashrate **30 GH/s**; transaction fees **0.6% of block rewards**, against **3%** at centralised
  F2Pool.
- PPS demonstrated. **PPLNS and anti-block-withholding were left as future work** — worth noting,
  because the withholding problem is exactly what the companion papers show to be severe.

## Security model and its limits

Rational adversary (deviates for profit, not to destroy). Assumes <50% adversarial control of the
*underlying* chain. Fairness guarantee: expected reward proportional to contribution even when others
submit invalid shares, enforced by the penalty function. No claim is made about a pool whose miners
are irrational or externally subsidised to attack.

## What transfers to a Bitcoin pool, and what does not

**Transfers.** Batched commitment to shares; sampled verification with an expectation-neutral penalty;
pre-committing the payee into the work; monotonic counters as a duplicate-prevention primitive
(compare the SRI share-replay bug where `seen_shares` is cleared on `prev_hash` change).

**Does not transfer.** The trustless bookkeeper requires a smart-contract platform. On Bitcoin there
is no equivalent substrate, which is why the same goal is pursued instead through template
decentralisation (Job Declaration, DATUM) rather than through accounting decentralisation.
