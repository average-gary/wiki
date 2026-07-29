---
title: "Report: is blinded share credit strictly harder than blinded payout?"
type: output
format: report
created: 2026-07-29
updated: 2026-07-29
status: current
round: "2026-07-29 thesis round (--mode thesis --deep, 8 lenses, single round)"
verdict: mixed
confidence: high
sources:
  - wiki/theses/blinded-share-credit-commitment.md
  - raw/papers/2026-07-29-stateful-vs-oneshot-credentials-no-separation.md
  - raw/papers/2026-07-29-blinded-accumulation-cost-at-real-share-rates.md
  - raw/papers/2026-07-29-bba-plus-black-box-wallets.md
  - raw/papers/2026-07-29-bedrock-primary-read-cookie-construction.md
  - raw/papers/2026-07-29-recabarren-carbunar-hardening-stratum.md
  - wiki/concepts/nullifier-vs-pseudonym.md
  - wiki/concepts/blind-share-accounting.md
tags: [thesis, verdict, blind-signatures, bba-plus, nullifier, share-accounting, privacy, correction, report]
summary: "Verdict and corrections from the 2026-07-29 thesis round. MIXED: aggregation genuinely needs a pool-side pseudonym or a miner-carried accumulator, but duplicate arbitration does not — a keyed share-derived nullifier is a third mechanism, already deployed three times over. The round's larger finding is that every cryptographic barrier this topic held against blinded accumulation was wrong, and that the surviving difficulty is interactivity plus a hashrate side channel that batching converts rather than removes."
---

# Is blinded share credit strictly harder than blinded payout?

**Verdict: MIXED, high confidence.** The claim under test was the inverted framing recorded in
[[../wiki/theses/blinded-share-credit-commitment|the thesis stub]]:

> Blinding a PoW-committed mining cookie preserves re-labeling resistance but **cannot** preserve
> share-weight aggregation or duplicate arbitration without either a pool-side persistent pseudonym or
> a miner-carried accumulator, making blinded share credit strictly harder than blinded payout.

It is joined by *or*, and **it holds for the first disjunct and fails for the second**. The conclusion
is right; two of the three reasons this topic held for it were wrong, and the reason that survives is
not the one the claim gives.

## The verdict table

| # | Sub-claim | Verdict | Confidence |
|---|---|---|---|
| A | Re-labeling resistance survives blinding | **Unestablished, but likely** — holds by Bedrock's own §7.1 work-equivalence argument, at a lower bar than assumed; no literature binds a blinded value into a PoW preimage | medium |
| B | Weight aggregation survives without a pool-side persistent ID | **Thesis SUPPORTED** — the dichotomy holds, with explicit necessity arguments in *Anonymous Counting Tokens* (Asiacrypt 2023) §1 and `draft-ietf-privacypass-rate-limit-tokens-06` | high |
| C | Duplicate arbitration survives | **Thesis FALSIFIED** — a keyed share-derived nullifier is a third mechanism, confirmed in three independent deployed implementations that carry no identity term | high |
| D | Enrollment gating survives | **SUPPORTED** — KVAC (CMZ, CCS 2014) / RFC 9497; ACL now proven concurrently secure | high |
| E | Blinded credit strictly harder than blinded payout | **SUPPORTED on interactivity, NOT on cost** — the arithmetic gap is ~4× smaller than this topic claimed | high |

## What falsified C

The thesis stub named its own escape hatch: *"the claim asserts exactly two escapes. Exhibit a **third**
mechanism."* One exists, and the strongest evidence for it is not cryptographic.

A **keyed share-derived nullifier** — `nf = PRF_{sk_M}(header_hash)` — is pool-side state that is
neither a pseudonym nor an accumulator. It is single-use, unlinkable across shares, and carries no
identity term. The pool keeps a set, rejects members, and inserts non-members. Nothing about that set
supports aggregation, which is exactly why it is not a pseudonym.

Three independently written Bitcoin pool implementations already do duplicate rejection this way, with
**no identity term in the key**:

| Implementation | Dedup key | Notable |
|---|---|---|
| SRI (Stratum Reference Implementation) | `seen_shares: HashSet<Hash>` | header hash only |
| Ocean / DATUM | `datum_stratum_dupes.h`, header fields | **checked *before* attribution** |
| p2pool-v2 | `HashSet<&BlockHash>` | share-chain context, still identity-free |

Ocean's ordering is the load-bearing detail: dedup runs *upstream* of crediting, so it cannot be
depending on identity. Cross-domain confirmation is broad — Cashu NUT-07 (`Y = hash_to_curve(secret)`),
Zcash nullifier sets (§3.2.3, §3.9), Tor proposal 327, Privacy Pass.

See [[../wiki/concepts/nullifier-vs-pseudonym|Nullifier vs Pseudonym]], which also carries a
*"Where nullifiers genuinely don't help"* section — the point is narrow and worth not overselling.

**Bedrock supplies no baseline for C to lose in the first place.** `verifyJob` is stateless, does not
consume `job_id`, and writes nothing back; *duplicate*, *replay* and *serial* never appear in that
sense in the paper. So C cannot be falsified against Bedrock at all and had to be argued against
deployed practice. Note also that the paper's own BiteCoin run **suppressed** the victim's share
(*"sends to the pool a mangled copy of the victim's original share submission, to ensure that it is
rejected"*) rather than racing it — which hints the attacker could not rely on winning a duplicate
race.

## Why B survives

Weight aggregation genuinely does need one of the two named escapes, and the round found better
anchoring for that than this topic previously had:

- ***Anonymous Counting Tokens*** (Benhamouda, Raykova, Seth; Asiacrypt 2023) §1 argues directly that
  per-user registered state is required to bound issuance per identity.
- **Rate-Limited Privacy Pass** (`draft-ietf-privacypass-rate-limit-tokens-06`) states it in normative
  RFC language and **ships route (a)** — a pool-side persistent handle — with explicit anti-rotation
  locks. A standards-track document that had to choose is stronger evidence than a paper that merely
  observes.
- **Compact E-Cash** (CHL, Eurocrypt 2005) and **WabiSabi** (eprint 2021/206) each collapse into one
  horn or the other rather than escaping.

The horns are not symmetric in difficulty, though, and that asymmetry is where this topic was wrong.

## Five corrections, four load-bearing

Every *cryptographic* barrier this topic was carrying against the miner-carried-accumulator horn
dissolved on contact with primary sources. Four of the five had already propagated into two `output/`
artifacts before this round caught them.

### 1. Canard–Gouget was inverted, not merely misattributed

This topic carried the Canard–Gouget impossibility as blocker #1, *"fatal for a single-operator pool."*
The BBA literature cites it for the **opposite** proposition. Faller et al., *Black-Box Accumulation
Based on Lattices* (IMACC 2021, eprint 2021/1303), verbatim:

> A BBA issuer and an accumulator **can** collude without breaking privacy. This is necessary due to an
> impossibility result, cf. [12]

It is the reason the roles **must** merge into one operator — which is the pool. Corroborating:

- **BBA+ p.1933** proves unlinkability against *"a collusion of I, AC, and V."*
- **Black-Box Wallets Def. 4.1** shares `sk_I` across issuer, accumulator and verifier, and **p.171
  removes the TTP trapdoor entirely**. The single-operator case is the case BBW *proves secure*.
- The impossible notion is **Perfect Anonymity** (`PA ⇒ FA ⇒ SA ⇒ WA`), one level *above* the full
  unlinkability this topic had invoked, and its predicate is *recognizing a coin you previously owned
  once it returns to you* — coin transfer between **users**. A pool that increments weight itself never
  satisfies the antecedent.

Found independently by two agents. The irony worth recording: this topic's own BBA+ ingest **already
contained the disproof two lines below the claim**.

**Caveat.** ACNS 2008 is paywalled and unread; the finding rests on four independent restatements
(Faller et al.; BBW p.3; P4TC, PoPETs 2020(4); a USP MSc thesis) plus Gouget's own 2008 invited-talk
abstract, which attributes coin-growth to **Chaum–Pedersen** rather than to herself. Tracked at
[[../inventory/candidates/canard-gouget-primary-text|canard-gouget-primary-text]] as **p3** — the
direction is settled, only the numbering is open. Until it closes, cite it as *"the BBA literature's
characterization of Canard–Gouget,"* never as a standalone result.

### 2. Crediting was costed with the spending row

BBW Table 1 (p.179) has separate rows for `Add` and `Sub`. This topic's recorded
**122 ms / 182 ms / ~4 kB** is `Sub16,lin` — **redemption**. The credit operation is:

| Operation | User | System | Bytes | What it is |
|---|---|---|---|---|
| `Issue` | — | 52 ms | — | enrollment |
| **`Add`** | **62 ms** | **45 ms** | **1,745 B** | **crediting a share batch** |
| `Sub16,lin` | 122 ms | 182 ms | ~4 kB | spending / redemption |

A **4.04× overstatement** of pool-side cost. Re-derived throughput at the correct figure:

| Scenario | Per-share | Batched at `share_batch_size = 10` |
|---|---|---|
| F2Pool, 16,000 miners | 72 cores | **7.2 cores** |
| solo.ckpool, measured `SPS1m: 5832.5` across 39,592 workers | 262 cores | **17.8 cores** |
| Foundry scale | ~5,084 cores | infeasible |

These are upper bounds: both papers decline to measure the (faster) server side.

### 3. The 16-bit range limit was a category error

It binds **redemption only**. BBW Fig. 4 p.174 shows `Proof P2 (Add)` carries **no range proof**; only
`Proof P3 (Sub)` adds one. Crediting is bounded by `2|V| < |Z_p|` — **~2²⁵¹ on Curve25519** — against
the ~50 bits an `8 × D` TIDES window needs (`8 × 1.26231507121868e14 = 1,009,852,056,974,944`,
log₂ = 49.84). That is **201 bits of headroom**. BBA+ needs nothing at all (`p ≈ 2²⁵⁰`, no range proof
by design choice). Widening redemption 16 → 64 bits costs **+129 B and +21.8 ms**.

### 4. ROS: ℓ = 9, not ~256 — and the ACL claim was retracted

eprint 2020/945 **§7 p.17 gives ℓ = 9** as the practical breakage threshold for blind Schnorr. The 256
figure on p.4 is a different quantity — the session count for the seconds-long Sage attack. Both
readings are reconciled in the ingest rather than one being deleted.

Separately, **the ROS authors retracted their ACL claim**, and ACL (Baldimtsi–Lysyanskaya, CCS 2013) is
now **proven concurrently secure** in AGM+ROM by Kastner–Loss–Renawi (CCS 2023, eprint 2023/707,
Cor. 4.2). This topic's blocker was stale in both directions — wrong threshold, and wrong about which
schemes it kills.

### 5. `v` is an arbitrary field element at constant cost

BBA+ p.1932: *"a **positive or negative** value v."* p.1931: complexity and token size
*"independent of the number of points to be transferred or stored."*

**This is what separates BBA+ from Cashu's denomination ladder, and this topic never said it.** It is
also why batching is native to the primitive rather than a bolt-on — and SV2 already ships the
plumbing. `SubmitShares.Success` (§5.3.13) exists *"for **multiple SubmitShare messages aggregated
together**"* and carries **`new_shares_sum` U64 — "Sum of difficulty of shares acknowledged within this
batch."** That field *is* the `v` to credit. Reference configs ship `shares_per_minute = 6.0` and
`share_batch_size = 10`.

### And: no theorem exists making accumulation harder than issuance

Searched five independent ways; no lower bound or separation of that form exists.

- Two peer-reviewed constructions measure the update **within a small constant** of issuance: BBW
  `Issue 52 ms` vs **`Add 62 ms`**; UACS (CCS 2019) Table 1 Pixel `Join 76 ms` vs **`Earn 110 ms`**.
- **Coull–Green–Hohenberger** (ACM TISSEC 14(1)) achieve hidden state transitions in **constant** time.
- The one-show/multi-show gap is a **technique** tradeoff, not a bound — Kastner–Loss–Renawi p.5:
  single-show credentials *"bypass heavy tools such as zero-knowledge."*
- The blind-signature impossibility line (Lindell; Fischlin–Schröder; Pass) is entirely about **round
  complexity**; none of its conditions mention attributes, state, or updates.
- **The result people usually reach for** when they say "e-cash can't do this" is **Chaum–Pedersen,
  *"Transferred Cash Grows in Size,"* EUROCRYPT '92, LNCS 658 pp.390–407** — which has real theorems
  (4.2, 5.1) with entropy lower bounds, and which also scopes to **transferability**. BBA tokens stay
  constant-size precisely because the operator co-signs each increment.

## What actually survives

Two things, neither cryptographic. This is the honest form of the argument if one is wanted.

### Interactivity — the axis on which "strictly harder" is defensible

| | Blinded **payout** | Blinded **credit** |
|---|---|---|
| Shape | offline, **non-interactive** BIP32 `CKDpub` | **online 2-party** protocol |
| Cost | one HMAC-SHA512 + one point add, tens of µs | ~45 ms pool-side |
| Round trips | 0 | **4–5 / ≈9 messages** |
| Bytes | 43 B amortized on-chain | 1,745 B per event |
| Parallelism | embarrassingly parallel | **serial per token** |

The serialization is not incidental: two in-flight `Add`s reuse serial `s` and **self-incriminate**
through `IdentDS` (the double-spend tag `t := sk_U·u2 + u1 mod p` recovers
`sk_U = (t−t')·(u2−u2')⁻¹`). Roughly **≈900× in compute and ≈41× in bytes**.

Decisively, **the interaction cannot be Fiat–Shamir'd away.** BBW p.166 relies on *"interactive proof
systems, where standard rewinding techniques replace the trapdoor"* — so removing interaction
reinstates the TTP the design just spent p.171 deleting.

### The hashrate side channel — batching converts it, does not remove it

Batching is what buys the affordability in §2 above, and the batch boundary is a timing signal:

```
inter-credit interval = batch_size / share_rate
```

A fixed `b` turns a per-share leak into a **lower-sampled leak of the same quantity**, and the sampling
rate needed for affordability scales *against* privacy: 16,000 miners on a single core needs `b ≥ 72`,
i.e. one credit per ~12 min per miner — fewer samples, each a cleaner estimate of a longer averaging
window.

Recabarren & Carbunar make this concrete: their ISP-Log attack reaches **0.53–34.4 % payout-prediction
error from the inter-packet timestamps of the first 50 packets alone**, with no payload access. So any
**count-triggered** boundary is a direct hashrate readout and is self-defeating; boundaries have to be
**Poisson-randomized**, at a round-trip cost nobody has measured.

**Unquantified in any paper.** BBA+ and BBW measure compute and bytes and never timing privacy; R&C
measure the leak for *unbatched* Stratum; nobody has connected them. This is now the topic's most
valuable open question — [[../inventory/candidates/batched-credit-timing-leak|batched-credit-timing-leak]],
p1.

## Two obstacles upstream of the thesis entirely

Both new to this topic, and both bite before crediting is even reached.

1. **Bedrock keys the vardiff target on identity.** `store(M.uname, K_M, R_M, target)` puts the
   per-miner `target` in the *same identity-keyed row* as the cookie seed, and `verifyJob` fetches it
   via `getMParams(M.uname)`. A pool therefore cannot evaluate `H²(nonce||F) < target` for an anonymous
   submitter at all. Blinding breaks share **validation**, one layer before crediting; any blinded
   design must carry difficulty in the credential or in the share itself.
2. **Bedrock is a weaker starting point than the thesis assumed.** It names **no hardness assumption**
   and proves nothing — §7.1 is a work-equivalence argument (*"If the attacker was able to quickly find
   such partial collisions, it would be much easier to simply compute the shares"*). Its cookie rotates
   **only on block-find — ~7.44 years for an S7**, which the paper computes itself — so it never
   delivered a per-session unlinkable value. And placing the cookie in the prevout hash is
   **consensus-invalid for the share that is a block**: §8.3 considers the scriptSig by name and
   declines it because pools already use that space. Relocating the cookie is **our repair, not a
   resolution of the paper's ambiguity** — attribute it that way.

## The recommended reformulation

> Blinding a PoW-committed mining cookie preserves re-labeling resistance and **admits duplicate
> arbitration via a keyed share-derived nullifier**, but cannot preserve share-weight aggregation
> without either a pool-side persistent pseudonym or a miner-carried accumulator. Blinded share credit
> is strictly harder than blinded payout **because crediting is an online interactive protocol while
> payout is an offline non-interactive derivation** — not because of cost, range, or any impossibility
> result.

As the Historical lens put it of the original: *as stated it hands a reviewer an easy counterexample.*

One caveat that cuts the other way, and is worth keeping: **C's pessimism is defensible on enforcement
economics rather than cryptography.** BBA+/BBW catch double-spend only via a serial-number database
scanned after the fact, and the punishment identifies a *user* to penalize. Against anonymous hashrate
with nothing seizable, that model has no teeth. A real gap — just not the one the thesis claimed.

## Process findings

- **WebFetch silently fails on image-based PDFs and returns confident "ABSENT" verdicts.** It reported
  all four Recabarren & Carbunar claims absent when all four are present in the paper. This is almost
  certainly the mechanism behind the fabricated BBA+ title, the fabricated performance table, and the
  fabricated author names ("Kaidel", two "Koch"s) that this round removed from two files. Correct
  attributions: BBA+ is **Hartung, Hoffmann, Nagel, Rupp** (CCS 2017, pp.1925–1940); Black-Box Wallets
  is **Hoffmann, Klooß, Raiber, Rupp** (PoPETs 2020(1):165–194, article 0010). **Download and
  `pdftotext -layout`. Never trust a fetch summarizer on a PDF.**
- **WebSearch was unavailable again**, as the stub predicted. Discovery ran through DuckDuckGo/Brave
  HTML endpoints, DBLP and OpenAlex for venue confirmation. IACR eprint and Cloudflare returned 403s,
  worked around via `web.archive.org/.../id_/` raw captures and the Stanford author mirror for
  Bulletproofs — flagged for provenance in every ingest.
- **A negative result held up.** delvingbitcoin returns zero topics for blinded share accounting, and
  there is still no BIP, no SV2 extension and no ZK/MPC design for it anywhere. Treat that silence as a
  real finding, not a search failure.
- **Still unread**: Canard–Gouget ACNS 2008 and LatInc (TDSC 2026), both paywalled. Ocean's TIDES
  `8 × D` window figures rest on a single unreplicated fetch (`docs.ocean.xyz` now DNS-fails) — medium
  confidence. No published µs/op figure for BIP32 derivation exists upstream, so the ≈900× ratio uses a
  constructed estimate.
- **Only 2 sources were ingested, which understates the round.** The yield was in *corrections to
  existing articles*, four of which invalidated load-bearing claims that had already propagated into two
  output artifacts. A round that changes what the topic believes is worth more than one that adds to it.

## Related

- [[../wiki/theses/blinded-share-credit-commitment|Thesis: blinded share-credit commitment]] — the full decomposition and evidence tables
- [[../wiki/concepts/nullifier-vs-pseudonym|Nullifier vs Pseudonym]] — the mechanism that falsified C
- [[../wiki/concepts/blind-share-accounting|Blind Share Accounting]] — the primitive survey, corrected
- [[../wiki/topics/self-blinding-pool-design-space|Self-Blinding Pool Design Space]] — the parent synthesis
- [[playbook-self-blinding-pool-attribution-2026-07-29|Playbook: self-blinding pool attribution]] — the round that derived this thesis
- [[../inventory/candidates/batched-credit-timing-leak|batched-credit-timing-leak]] (p1), [[../inventory/candidates/canard-gouget-primary-text|canard-gouget-primary-text]] (p3)
