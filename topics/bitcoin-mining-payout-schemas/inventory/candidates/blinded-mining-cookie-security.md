---
title: "Blinded mining-cookie security — does Bedrock's share-theft resistance survive blinding?"
kind: question
status: ingested
priority: p1
created: 2026-07-29
updated: 2026-07-29
last_checked: 2026-07-29
resolved: 2026-07-29
next_action: "None — closed by the 2026-07-29 thesis round. Two follow-ups spun out as separate records: blinded-credit-interactivity-ceiling and canard-gouget-primary-text."
sources:
  - wiki/theses/blinded-share-credit-commitment.md
  - wiki/topics/self-blinding-pool-design-space.md
  - raw/papers/2026-07-29-recabarren-carbunar-hardening-stratum.md
  - output/playbook-self-blinding-pool-attribution-2026-07-29.md
tags: [attribution, privacy, share-theft, bedrock, mining-cookie, bitecoin, blind-signature, bba-plus, open-question]
confidence: medium
summary: "Bedrock resists BiteCoin share hijacking because the miner's plaintext username is a PoW input. Whether that survives substituting a blinded credential is unanalyzed by anyone — the highest-value open technical question from the 2026-07-29 attribution-privacy round, and objection #1 of the three that survive against a self-blinding pool."
---

# Blinded mining-cookie security

## Why Track This

This is the **cryptographic crux** of the self-blinding pool question. Of the three objections
that survive in [[../../wiki/topics/self-blinding-pool-design-space|Self-Blinding Pool Design
Space]], the other two are regulatory (custody → money transmitter) and legal (compulsion
scoping). This one is the only *technical* blocker, and it gates whether the design space is
buildable at all rather than merely awkward.

It is also **unanalyzed by anyone** — not a hard problem with a known answer, an unattempted
one. The 2026-07-29 round found no BIP, no SV2 extension, and no ZK/MPC design for blinded
share accounting; delvingbitcoin returns zero topics.

## Current State

**RESOLVED 2026-07-29 by the thesis round** — see
[[../../wiki/theses/blinded-share-credit-commitment|the verdicted thesis]] for the per-sub-claim
table. Verdict: **MIXED**, high confidence. B (aggregation) and D (enrollment gating) supported;
**C (duplicate arbitration) falsified**; E supported on the interactivity axis but not on cost;
A unestablished but likely.

**The headline correction is that this record's own framing of the blocker was wrong.** It said
"if sub-claim B fails, the answer routes into BBA+ / Black-Box Wallets, where Canard–Gouget blocks the
single-operator case." The BBA literature cites Canard–Gouget for the **opposite** proposition — it is
why issuer and accumulator *must* share one key. Every cryptographic barrier this topic was carrying
against blinded accumulation dissolved on contact with the primary sources. What survives is
**interactivity** (online 2-party crediting vs offline non-interactive payout derivation) and the
**hashrate side channel**, which no cryptography addresses.

The original state, kept for the record:

**Unknown.** Bedrock (Recabarren & Carbunar, PETS'17) binds a mining cookie
`C_M = H²(R_M, M.uname)` into the coinbase so the header commits to it; an attacker
substituting its own username produces a hash that no longer meets target. Bedrock explicitly
provides **zero privacy from the pool** — the pool generates `R_M` — so it is a defense against
a network attacker with the pool as trusted third party.

Substituting a blinded credential for the plaintext username is untested. The decomposition in
[[../../wiki/theses/blinded-share-credit-commitment|the thesis]] splits it four ways and expects
a split result: re-labeling resistance and enrollment gating likely survive; **weight
aggregation and duplicate/replay arbitration likely do not**.

## Close-out Condition — MET 2026-07-29

Either:

- an exhibited re-labeling, replay, or credit-diversion attack that Bedrock blocks and the
  blinded variant admits; **or**
- ~~a reduction proving blinded theft resistance from the same hardness assumption~~ — **struck as
  unsatisfiable**: Bedrock names no hardness assumption and proves nothing; **or**
- a demonstration that share-weight aggregation provably requires a pool-side persistent
  identifier — which closes the question as *secure but unusable*.

**Closed on the third condition, in the affirmative-but-narrowed form.** Share-weight aggregation
does require either a pool-side persistent pseudonym or a miner-carried accumulator — the dichotomy
holds, with explicit necessity arguments in *Anonymous Counting Tokens* (Asiacrypt 2023) and
Rate-Limited Privacy Pass. But it does **not** close as "secure but unusable," because the
miner-carried-accumulator horn turned out to be **open and affordable**: 45 ms pool-side per credit,
7.2 cores at F2Pool scale when batched at SV2's shipped `share_batch_size = 10`, and SV2's
`new_shares_sum` U64 is already the value to credit.

Separately, **duplicate arbitration was falsified rather than confirmed** — a keyed share-derived
nullifier is a third mechanism, deployed in three independent implementations. So the answer to this
record's headline question ("does Bedrock's share-theft resistance survive blinding?") is: **the
theft resistance survives; the accounting around it splits, and not where this record predicted.**

The caveat about sub-claim A holding — that a verdict on A alone would be a false close — was
honored: A is in fact the *weakest* result of the five, recorded as unestablished-but-likely.

## Notes

- **Why it's live now**: Bedrock needs the cookie in the coinbase, and in 2017 the pool built
  the coinbase. Under SV2 Job Declaration and DATUM the *miner* declares the template, so the
  party that would insert a self-chosen blinded commitment already controls the field. The
  architecture arrived after the defense did.
- **~~Verify before building~~ → RESOLVED 2026-07-29.** The paper means the **literal 32-byte
  prevout hash**; §8.3 considers the scriptSig by name and declines it because pools already use
  that space. There is no separate block-candidate path and no consensus analysis in the paper,
  so the scheme is consensus-invalid for the share that is a block. Relocation is our repair, not
  a disambiguation. Two further corrections: **no hardness assumption is named** anywhere in the
  paper (§7.1 is a work-equivalence argument, so the close-out condition "a reduction … from the
  same hardness assumption" is unsatisfiable as written), and the cookie **rotates only on
  block-find (~7.44 years for an S7)**, making it already a long-lived pseudonym. New obstacle
  found: `store(M.uname, K_M, R_M, target)` keys the **vardiff target on identity**, so blinding
  breaks share *validation* upstream of crediting. See
  [[../../raw/papers/2026-07-29-bedrock-primary-read-cookie-construction|the primary read]].
- **Provenance hazard**: in the source round, an agent's fetch summarizer fabricated a BBA+
  paper title and performance table. Read PDFs directly for Bedrock, BBA+, and Black-Box
  Wallets.
- **~~Coupled record: if sub-claim B fails, the answer routes into BBA+ / Black-Box Wallets, where
  Canard–Gouget blocks the single-operator case.~~ → HALF RIGHT.** B does route into BBA+ /
  Black-Box Wallets, and the routing was correct. **Canard–Gouget does not block it** — the BBA
  literature invokes that result to explain why issuer and accumulator *must* share one key (Faller et
  al., IMACC 2021), BBA+ p.1933 proves unlinkability against "a collusion of I, AC, and V", and BBW
  removes the TTP trapdoor entirely. The impossible notion is *Perfect* Anonymity, scoped to coin
  transfer between users — never satisfied by a pool. See
  [[../../wiki/concepts/blind-share-accounting|Blind Share Accounting]] and
  [[../../raw/papers/2026-07-29-stateful-vs-oneshot-credentials-no-separation|the correcting read]].
- **The non-cryptographic failure mode was the right instinct and is now the main event.** This record
  noted B "may also fail for non-cryptographic reasons (hashrate fingerprinting, source IP, reconnect
  co-timing…), which is unquantified in any paper." That is exactly where the difficulty ended up.
  Batching is what makes the accumulator affordable, but the inter-credit interval leaks hashrate
  (`interval = b / share_rate`) — and Recabarren & Carbunar recover payout predictions from the
  timestamps of the first 50 packets alone. Still unquantified for the batched case; carried forward
  as its own record.
