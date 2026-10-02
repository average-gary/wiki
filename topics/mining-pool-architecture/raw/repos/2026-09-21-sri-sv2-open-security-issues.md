---
title: "Open correctness and accounting issues in the SV2 reference implementation (SRI), 2026"
source: "https://github.com/stratum-mining/stratum/issues"
type: repos
ingested: 2026-09-21
tags: [stratum-v2, sri, share-replay, accounting-bug, job-store, coinbase-witness, extension-negotiation, consensus-budget, implementation-complexity, protocol-attack-surface]
summary: "A set of open issues (#2390, #2395-#2399) on the Stratum V2 reference implementation, reported by a research agent as evidence that SV2's larger surface produces real defects in the protocol authors' own code. The most consequential is share replay: seen_shares is cleared on every prev_hash change, so an already-credited proof becomes creditable again after any block change. Others: BlockFound credits full job difficulty even when the hash misses the job target (accounting saturation with tiny nonzero targets); gaps in coinbase witness handling (multi-input transactions accepted, unattached commitment reservations); JobStore::add_future_job silently drops the job displaced by a colliding job_id, orphaning extranonce prefixes; client-side scriptSig assembly missing the 100-byte coinbase consensus budget check; unknown extension_type frames erroring instead of being discarded. Taken together these are a catalogue of exactly the failure classes a stateful binary protocol introduces — replay, saturation, collision, and forward-incompatibility."
credibility: low
credibility_score: 1
credibility_rationale: "DOWNGRADED. A research agent reported issue numbers, titles and paraphrased contents from the tracker; this session did NOT open the issues to confirm the numbers, current status, severity labels, or whether any are already fixed or were filed by an automated auditor. The failure *classes* are coherent and consistent with the protocol's design; the specific numbered claims are unverified."
confidence: low
research_round: 1
research_agent: contrarian
verification_required: "Before any of these is cited in a compiled article: open each issue, confirm number/title/status, check whether it is fixed in a release, and check whether it affects sv2-apps or only a crate. Issue numbers in the 2390-2399 range appearing as a contiguous block is itself a signal they may come from one batch audit rather than independent discovery."
extraction_note: "Verbatim-ish paraphrase of a subagent's reading of the issue tracker. Nothing here was independently confirmed."
---

# Open correctness/accounting issues in the SRI (as reported, unverified)

> **Read the frontmatter first.** This file is ingested at `confidence: low` on purpose. The value is
> the **taxonomy of failure classes**, not the issue numbers. Do not cite a number without opening it.

## As reported

| # | Claim |
|---|---|
| **#2396** | **Share replay.** `seen_shares` is erased on every `prev_hash` change, so a proof already credited can be credited again after any block change. Reported as affecting all channel types. |
| **#2395** | **Work-accounting saturation.** `BlockFound` credits the full job difficulty even when the hash misses the job target, so a tiny nonzero target overflows accounting. |
| **#2397** | **Coinbase witness gaps.** Multi-input coinbase transactions accepted; unattached commitment reservations. |
| **#2399** | **Job collision.** `JobStore::add_future_job` ignores the job displaced by a colliding `job_id`, orphaning extranonce prefixes and breaking template mappings. |
| **#2398** | **Consensus budget.** Client-side scriptSig assembly lacks the 100-byte coinbase budget check during custom mining, so a miner can build work the network will reject. |
| **#2390** | **Extension handling.** Unknown `extension_type` frames raise an error instead of being discarded — a forward-compatibility failure, not a security one. |

## Why the taxonomy is worth keeping even if the numbers are wrong

Each entry names a failure class that follows structurally from SV2's design choices, and each has an
independent analogue elsewhere in this round's sources:

- **Replay via state reset.** Duplicate-share suppression is *stateful*, and its lifetime is tied to
  `prev_hash`. Compare SmartPool's augmented Merkle tree, which solves the same problem with a
  **monotonic counter and a persisted `last_max` across claims** — deliberately not resettable by a
  chain event. The general rule: duplicate-detection state must not be scoped to something an
  adversary can cause to roll over.
- **Accounting saturation from unvalidated difficulty.** Crediting work without re-deriving it from
  the achieved hash is the same class of error as trusting a miner-reported value. Compare Bedrock,
  where the pool corrects a *miner-reported* hashrate against observed submission rate rather than
  accepting it.
- **Job-ID collision in a stateful job store.** V1 had this too — the original slush0
  `stratum-mining` tracker carried "Job id 'c3a6' not found" template-registry errors. It is the
  oldest recurring bug in pool software, and it recurs because job identity is a small integer
  namespace shared between a pushing server and many clients with independent lifetimes.
- **Consensus-budget checks on the client side.** Once the *miner* assembles coinbase bytes (Job
  Declaration, DATUM), consensus limits that used to be the pool's private invariant become a
  distributed responsibility. Moving template construction to the miner moves this whole class of
  check with it.
- **Unknown extensions must be discardable.** BIP-310 already recorded this hazard for V1: "many
  server implementations close connections upon receiving unknown messages." Repeating it in a binary
  protocol with negotiated extensions is expensive, because extension negotiation is the designed
  upgrade path.

## The contrarian argument this supports (and its limit)

**Supports**: SV2 trades a text protocol with a tiny state machine for a binary protocol with job
stores, channel state, witness commitments, and extension negotiation. That is a strictly larger
surface, and the reference implementation — written by the protocol's own designers — is where you
would most expect it to be handled correctly.

**Limit**: these are *implementation* defects in *alpha* software, found in the open, in a public
tracker. Their existence is not evidence that the protocol is unsound, and an open-issue count is not
comparable across projects with different disclosure cultures. V1's equivalent bugs were found in
production over a decade, mostly unrecorded. The honest version of the claim is: **SV2 has more state
to get wrong, and getting it wrong is an accounting/money bug rather than a crash.**
