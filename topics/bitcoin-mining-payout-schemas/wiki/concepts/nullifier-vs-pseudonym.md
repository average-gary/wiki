---
title: Nullifier vs Pseudonym — why duplicate rejection does not need identity
category: concept
created: 2026-07-29
confidence: high
tags: [nullifier, pseudonym, duplicate-rejection, replay, dedup, cashu, zcash, privacy-pass, tor-327, ocean, sri, p2poolv2, thesis-evidence]
volatility: warm
updated: 2026-07-29
summary: "The distinction that falsifies sub-claim C of the blinded-share-credit thesis: a single-use nullifier is pool-side state that is neither a persistent pseudonym nor an accumulator. Three independently written Bitcoin pool implementations already reject duplicate shares with no identity term in the key."
verified: 2026-07-29
sources:
  - "raw/papers/2026-07-29-bedrock-primary-read-cookie-construction.md"
  - "raw/repos/2026-07-29-mining-privacy-prior-art-survey.md"
---

# Nullifier vs Pseudonym

A recurring error in reasoning about blinded share accounting is treating "the pool must remember
something per share" as equivalent to "the pool must know who the miner is." These are different
kinds of state, and conflating them makes anonymous duplicate rejection look impossible when it is
routine.

| | **Pseudonym** | **Nullifier** |
|---|---|---|
| Lifetime | Persistent across many events | **Single-use** |
| Links events to each other | Yes — that is its function | **No** |
| Supports summing / aggregation | Yes | **No** |
| Answers | "which party is this?" | "have I seen *this object* before?" |
| Cost of retention | Grows with parties, indexed by party | Grows with events, indexed by nothing |

A nullifier is a **membership test on an object**, not a handle on an actor. It is pool-side state,
and it is not a pseudonym. That distinction is what makes anonymous duplicate arbitration possible.

## The construction for shares

```
nf = PRF_{sk_M}(header_hash)
```

Keyed so the pool cannot itself derive `nf` for a share it did not receive; derived per share so two
`nf` values from the same miner are unlinkable; single-use so the check is `nf ∈ Seen`. The pool
learns "this share was already submitted" and nothing about **who** submitted either copy.

Compare the alternative the thesis assumed was necessary — retaining raw `header_hash`, which *is* a
linkability handle across the swap graph (see [[ehash]] § What the mint still learns).

## Deployed Bitcoin pools already do identity-free dedup

The decisive evidence, because it is code rather than argument. Three independently written
implementations, and **none of them puts an identity term in the dedup key**:

- **Stratum Reference Implementation** — `seen_shares: HashSet<Hash>`. Keyed on the share hash alone.
- **Ocean / DATUM** — `datum_stratum_dupes.h` keys on **header fields only**, and the check runs
  **before attribution**. The duplicate decision is structurally upstream of knowing whose share it
  is.
- **p2pool-v2** — `HashSet<&BlockHash>`.

The ordering in Ocean's implementation is the strongest single data point: if dedup had to know the
submitter, it could not be evaluated before attribution.

## The same pattern across four other domains

Convergent design, independently arrived at:

- **Zcash** (§3.2.3, §3.9) — nullifier sets are the canonical case. A note is spent by revealing a
  value that proves *some* note was consumed without revealing which, and the set prevents reuse.
- **Cashu NUT-07** — `Y = hash_to_curve(secret)`; the mint's spent-proof check is a set membership
  test on `Y`, carrying no wallet identity.
- **Tor proposal 327** (onion-service PoW) — replay protection over submitted solutions, deliberately
  without client identity, since the entire point is unlinkable clients.
- **Privacy Pass** (RFC 9497 / 9576) — redemption is one-shot; the server keeps spent tokens, not
  clients.

## Consequence for the thesis

This falsifies **sub-claim C** of
[[../theses/blinded-share-credit-commitment|Thesis: blinded share-credit commitment]]. That thesis
asserted exactly two escapes from losing duplicate arbitration under blinding — a pool-side persistent
pseudonym or a miner-carried accumulator. A nullifier set is a **third**: pool-side state that is
neither.

Note also that Bedrock supplies **no duplicate-handling baseline to lose** — `verifyJob` is stateless,
does not consume `job_id`, and writes nothing back; *duplicate*, *replay* and *serial* never appear in
that sense in the paper. So C could not have been falsified against Bedrock in the first place; it had
to be argued against deployed practice, and deployed practice does it without identity. See
[[../../raw/papers/2026-07-29-bedrock-primary-read-cookie-construction|the Bedrock primary read]].

## Where nullifiers genuinely don't help

Being precise about the limit, because the distinction cuts both ways:

- **They cannot aggregate.** A nullifier answers a yes/no membership question; it carries no
  quantity and supports no sum. Sub-claim B's dichotomy stands untouched — that is exactly why C
  falls and B does not.
- **Set growth is unbounded without expiry.** One entry per share, forever, unless scoped to a window.
  Scoping to the share window is natural here since stale shares are rejected anyway.
- **Enforcement is detection, not prevention.** The set tells you a duplicate arrived; it does not
  tell you which copy was the original. Against an anonymous submitter there may be nothing to
  penalize — a real gap, but an **economic** one rather than a cryptographic one.
- **Timing still leaks.** Identity-free dedup says nothing about hashrate inference from submission
  timing, which no set-membership construction addresses. See
  [[hashrate-inference-side-channels]].

## See also

- [[../theses/blinded-share-credit-commitment|Thesis: blinded share-credit commitment]] — sub-claim C
- [[blind-share-accounting|Blind Share Accounting]] — the aggregation half, which nullifiers cannot do
- [[ehash|eHash]] — the deployed design that retains raw `header_hash` rather than a nullifier
- [[hashrate-inference-side-channels|Hashrate Inference Side Channels]] — the leak that survives
