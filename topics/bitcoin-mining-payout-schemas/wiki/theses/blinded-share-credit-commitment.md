---
title: "Thesis: a blinded share-credit commitment can preserve Bedrock's share-theft resistance"
type: thesis
status: completed
created: 2026-07-29
updated: 2026-07-29
verdict: mixed
confidence: high
verdict_detail: "MIXED. B (aggregation) SUPPORTED and D (enrollment gating) SUPPORTED; C (duplicate arbitration) FALSIFIED by a keyed share-derived nullifier, confirmed in three independent deployed implementations that carry no identity term; E SUPPORTED on the interactivity axis only, not on cost; A unestablished but likely. The thesis's or-conjunction fails."
volatility: warm
core_claim: "Bedrock's theft resistance derives from any unforgeable miner-bound value being in the PoW preimage, not from that value being a plaintext identifier — so substituting a blinded credential for `M.uname` in the mining cookie retains resistance to share re-labeling, replay, and credit diversion without the pool retaining a persistent miner identifier."
key_variables: [pow-preimage-commitment, share-weight-aggregation, duplicate-replay-arbitration, credential-issuance-gating, coinbase-field-control]
falsification: "Exhibit a concrete re-labeling, replay, or credit-diversion attack that Bedrock blocks and the blinded variant admits; OR give a reduction from blinded theft resistance to the same hardness assumption. Falsified in practice if share-weight aggregation provably requires a pool-side persistent identifier."
tags: [thesis, attribution, privacy, share-theft, bitecoin, bedrock, mining-cookie, blind-signature, bba-plus, kvac, sv2-job-declaration]
summary: "Whether the anti-theft property of welding miner identity into the proof-of-work survives replacing the plaintext username with a blinded credential. Verdicted 2026-07-29: it splits, but not where the derivation expected. Aggregation and enrollment gating survive; duplicate arbitration is FALSIFIED by a keyed share-derived nullifier that is neither pseudonym nor accumulator. Every cryptographic barrier the wiki was leaning on dissolved — what remains is interactivity and the hashrate side channel."
sources:
  - "raw/papers/2026-07-29-recabarren-carbunar-hardening-stratum.md"
  - "raw/papers/2026-07-29-bedrock-primary-read-cookie-construction.md"
  - "raw/papers/2026-07-29-bba-plus-black-box-wallets.md"
  - "raw/papers/2026-07-29-stateful-vs-oneshot-credentials-no-separation.md"
  - "raw/papers/2026-07-29-blinded-accumulation-cost-at-real-share-rates.md"
  - "raw/repos/2026-07-29-mining-privacy-prior-art-survey.md"
---

# Thesis: blinded share-credit commitment vs Bedrock share-theft resistance

Derived from the 2026-07-29 attribution-privacy round as its **highest-value open question**
— objection #1 of the three that survive in
[[../topics/self-blinding-pool-design-space|Self-Blinding Pool Design Space]]. Recorded here
so the claim is tracked whether or not the thesis round runs.

**Status: verdicted 2026-07-29 — MIXED.** Jump to [[#Verdict]] for the per-sub-claim table. The
sections above it are the original decomposition, preserved with in-place corrections so the priors
can be compared against what the round actually found; Evidence For / Against / Nuances hold the
findings.

**Headline:** the thesis's or-conjunction fails. Aggregation survives, **duplicate arbitration does
not** — a keyed share-derived nullifier is a third mechanism, and three deployed implementations
already do dedup with **no identity term at all**. Separately, every *cryptographic* barrier this wiki
had been carrying against the miner-carried-accumulator horn dissolved on contact with the primary
sources, including one whose prescription this wiki had **backwards**.

## Core Claim

Bedrock (Recabarren & Carbunar, PETS'17) defends against **BiteCoin** share hijacking by
binding a per-miner secret into the puzzle: a mining cookie `C_M = H²(R_M, M.uname)` committed
in the coinbase, so the merkle root — and therefore the header — commits to it. It works
*because the username is an input to the hash*: an attacker substituting its own username
produces a double hash that no longer meets target.

The thesis is that the security comes from **any** unforgeable, miner-bound value being in the
preimage, not from that value being an *identifier*. Substituting a blinded credential
`C = Com(sk_M; r)` for `M.uname` therefore retains theft resistance while removing the
persistent pool-side identifier.

## Why This Is Live Now And Wasn't In 2017

Bedrock requires the cookie in the coinbase, and in 2017 the **pool** built the coinbase.
Under SV2 Job Declaration and DATUM the **miner** declares the template — so the party that
would need to insert a self-chosen blinded commitment already controls the field. The
architecture arrived after the defense did and nobody has connected them. See
[[../concepts/pplns-jd|PPLNS-JD]], [[../concepts/datum|DATUM]].

Note Stratum already has a weak version of identity-in-the-PoW: `extranonce1` is pool-assigned
per connection and lands in the coinbase. Bedrock exists because a connection hijacker
*inherits* the victim's `extranonce1` — the property needs a keyed, unguessable value, not
merely a per-session one.

## Key Variables

- **What is committed in the PoW preimage** — plaintext username vs blinded credential.
- **Share-weight aggregation** — can the pool sum a miner's shares into a running weight
  without a persistent per-miner handle?
- **Duplicate / replay arbitration** — who gets credit when the same `C`-bound share is
  presented twice by two anonymous parties?
- **Credential issuance gating** — can the pool verify `C` belongs to *some* authorized miner
  without learning which?
- **Coinbase field control** — who chooses the committed bytes (pool-built vs JD/DATUM
  miner-declared templates).

## Testable Prediction

For `C_M = H²(R_M, C)` with `C = Com(sk_M; r)`: an adversary observing a valid share cannot
cause credit to accrue to itself rather than to the producer, under the same hardness
assumption Bedrock relies on.

## Falsification Criteria

Either direction settles it:

- **Attack** — exhibit a concrete re-labeling, replay, or credit-diversion attack that Bedrock
  blocks and the blinded variant admits.
- **~~Reduction~~ → Argument at least as strong as Bedrock's.** *Corrected 2026-07-29:* the
  original clause said "prove blinded theft resistance from the same hardness assumption." That
  is unsatisfiable — Bedrock names no assumption and proves nothing (see § Open Detail). The
  achievable bar is reproducing its informal work-equivalence argument; a construction with an
  actual reduction would be **strictly more rigorous than Bedrock**.
- **Falsified in practice** — show that share-weight aggregation *provably* requires a
  pool-side persistent identifier, which would make the construction secure but unusable.
- **Dichotomy break** — the claim asserts exactly *two* escapes. Exhibit a **third** mechanism
  that does aggregation or duplicate arbitration while being neither a pool-side pseudonym nor
  a miner-carried accumulator (candidates: a share-derived nullifier set, which is pool-side
  state but not a pseudonym; a bag of one-shot receipts, which is miner-side state but performs
  no accumulation; share-chain consensus arbitration).

## Four Sub-Claims To Verdict Separately

A single verdict would hide the interesting result. Priors below are the derivation's, not
findings:

| # | Sub-claim | Prior |
|---|---|---|
| A | Re-labeling resistance survives blinding | Likely holds — near-definitional; changing the preimage changes the hash |
| B | Weight aggregation survives without a pool-side persistent ID | Likely **fails** without BBA+-class machinery |
| C | Replay/duplicate arbitration survives without retaining `header_hash` | Likely **fails** |
| D | Enrollment gating survives (verify `C` is *some* authorized miner) | Likely holds via KVAC / Privacy Pass |

**B and C are the thesis.** A round that only tests A returns SUPPORTED and means very little.

### Why B is hard

A persistent username is what lets the pool sum shares into a running weight. A per-session
unlinkable commitment cannot be summed by the pool; a commitment persistent enough to be
summed *is* a pseudonym — and is re-linkable anyway via hashrate signature, source IP, and
reconnect co-timing. So the accumulator must be carried **by the miner** and proven correct at
redemption, which lands back in BBA+ / Black-Box Wallets.

**Corrected 2026-07-29 — the second horn is open, not blocked.** This section previously ended
"where Canard–Gouget bites for a single-operator pool." That is a misattribution: the claim traces to
one sentence in Black-Box Wallets p.3 that invokes Canard–Gouget while **rejecting transferable
e-cash** as an alternative design, the cited paper (ACNS 2008) is paywalled with an unverified
theorem, and **BBW's Definition 4.1 shares `sk_I` across issuer, accumulator and verifier and still
proves privacy** — the single-operator case is the case BBW proves secure. There is also **no theorem
making stateful accumulation harder than one-shot issuance**; BBW measures `Add` at 62 ms against
`Issue` at 52 ms, and UACS measures `Earn` at 110 ms against `Join` at 76 ms.

So B's difficulty is **entirely quantitative**, and the argument must be made on those terms:
range-proof width (16-bit prototype vs ~50-bit share weights), per-share protocol round-trips, and
the hashrate side channel — the last of which no cryptography addresses and which is therefore the
*durable* half. See [[../concepts/blind-share-accounting|Blind Share Accounting]] and
[[../../raw/papers/2026-07-29-stateful-vs-oneshot-credentials-no-separation|the correcting read]].
The coupling, not the hash construction, is still what makes the thesis hard — but it is hard the way
engineering is hard, not the way impossibility is.

### Why C is hard

Nobody can re-label a share, but anyone who sees one can **replay** it under the same `C`.
Under blinding, two anonymous parties present the same `C`-bound share and there is no identity
to arbitrate with. Detection requires retaining `header_hash` — which is exactly what hashpool
retains, and which is itself a linkability handle. See
[[../concepts/ehash|eHash § What the mint still learns]].

**Caveat added 2026-07-29:** the framing "with plaintext identity the pool sees a duplicate from
a known party and credits once" is an **inference about pool practice, not a Bedrock property**.
Bedrock specifies *no* duplicate handling: `verifyJob` is stateless, does not consume `job_id`,
and writes nothing back; `duplicate`, `replay`, and `serial` do not appear in that sense
anywhere in the paper. **So C has no Bedrock baseline to lose**, and cannot be falsified against
Bedrock — it has to be argued against deployed practice instead. Note the paper's own BiteCoin
run *suppressed* the victim's share ("sends to the pool a mangled copy of the victim's original
share submission, to ensure that it is rejected") rather than racing it, which hints the
attacker could not rely on winning a duplicate race.

### The obstacle upstream of B: vardiff target is identity-keyed

New from the primary read and not previously anywhere in this wiki. Bedrock's
`store(M.uname, K_M, R_M, target)` puts the **per-miner vardiff `target` in the same
identity-keyed row as the cookie seed**, and `verifyJob` fetches it via `getMParams(M.uname)`.
A pool therefore cannot even evaluate `H²(nonce||F) < target` for an anonymous submitter — the
*target* is keyed on identity. That bites at **validation**, one layer before crediting, and any
blinded design must carry difficulty in the credential or the share itself.

### A fifth consideration: pool-side theft

Under blinding a miner can no longer verify that the *right* party was credited. This argues
for coupling the construction to miner-verifiable accounting
([[../concepts/sv2-share-accounting-ext|SV2 Share Accounting Extension]]) rather than treating
it standalone.

## Scope Boundary (bloat filter)

**Not part of this thesis** — skip sources touching only:

- Block withholding / selfish mining (settled in
  [[../concepts/block-withholding|Block Withholding]]: detection does not need attribution).
- Chain-observer deanonymization or the xpub/descriptor half
  ([[../concepts/xpub-payout-identity|Xpub Payout Identity]]).
- Regulatory / money-transmitter analysis
  ([[../decisions/attribution-retention-tradeoffs|Attribution Retention Tradeoffs]]).
- Hashrate side channels **except** where they defeat pseudonym unlinkability — that case is
  **in scope**, because it is how sub-claim B fails in practice.

## Suggested Agent Angles

- **Supporting** — KVAC / algebraic MACs (Chase–Meiklejohn–Zaverucha), Privacy Pass / VOPRF
  (RFC 9497), blind signatures on committed values, commitment-in-preimage constructions.
- **Opposing** — replay and double-spend in anonymous ecash: Camenisch–Hohenberger–Lysyanskaya
  compact e-cash double-spending tags, Cashu NUT-00 spent-proof handling, WabiSabi credential
  replay. Sub-claim C lives here.
- **Mechanistic** — Bedrock's own security argument in PoPETs 2017(3). **Resolve the field
  question** (see below) from the paper's own text.
- **Meta** — Canard–Gouget and the impossibility results bounding a single issuer; whether
  anything post-2020 relaxes them.
- **Adjacent** — Tor proposal 327 / onion-service PoW and micropayment work; SV2 JD and DATUM
  on whether a *miner*-chosen commitment is expressible in a declared template.
- **Confounders** (`--deep`) — hashrate fingerprinting, source IP, reconnect co-timing as
  pool-side re-linking of any pseudonym long-lived enough to aggregate against. If strong
  enough, B fails for non-cryptographic reasons.

## Open Detail — RESOLVED 2026-07-29 against both PDFs

**It is literally the prevout hash, and the paper is consensus-broken.** §8.3 *considers* the
scriptSig by name and **declines** it — "most pools have already started using this space for
their own internal procedures, e.g., in F2Pool, to store the miner's name" — then selects "the
yet unused, 32 byte (256 bit) long 'previous input address' field." Figure 2's caption puts it
"within coinbase1." And §6.2.1 affirmatively requires it in the published block: "The published
block needs to include all the fields that defined the puzzle … including the miner's cookie."

There is **no separate block-candidate path**, and the paper never mentions consensus validity;
its "unused" claim is justified only by surveying what *pools* write there, never what *nodes*
require. So relocating the cookie is **our repair to Bedrock, not a resolution of its
ambiguity** — attribute it that way. The irony: under SV2 JD / DATUM the natural home is the
scriptSig or a coinbase `OP_RETURN`, exactly what §8.3 declined for a reason that stops binding
once the miner declares the template.

Two further corrections from that read, both of which change this thesis:

- **There is no hardness assumption to reduce to.** No theorem, lemma, proof, or reduction
  exists in the paper; no primitive assumption is named. §7.1's argument is
  **work-equivalence**: "If the attacker was able to quickly find such partial collisions, it
  would be much easier to simply compute the shares without doing any interception and
  hijacking." The falsification clause below is corrected accordingly.
- **Bedrock's cookie is already a ~7.44-year pseudonym.** It rotates on block-find only, and
  the paper computes that interval itself for an S7. Bedrock never delivered a per-session
  unlinkable value, so the distance from Bedrock to a blinded design is wider than "swap the
  preimage."

See [[../../raw/papers/2026-07-29-bedrock-primary-read-cookie-construction|Bedrock primary read]].

## Critical Limitation Already Established

**Bedrock provides zero privacy from the pool.** The pool generates `R_M` and shares `K_M`;
every defense in that paper treats the pool as a trusted endpoint. Bedrock is a defense against
a *network* attacker with the pool as TTP — which is precisely the assumption this thesis is
trying to remove.

## Alternative Framing (if the round should point at the hard part)

The claim as stated is generous to itself, since sub-claim A is near-definitional. The inverted
form is falsifiable in the direction that would change the design:

> Blinding a PoW-committed mining cookie preserves re-labeling resistance but **cannot** preserve
> share-weight aggregation or duplicate arbitration without either a pool-side persistent
> pseudonym or a miner-carried accumulator, making blinded share *credit* strictly harder than
> blinded *payout*.

## Known Dead Ends

Do not re-burn budget. From the 2026-07-29 round: **WebSearch was unavailable** (DuckDuckGo /
Brave / IACR / GitHub API with CAPTCHA throttling); assume the same. delvingbitcoin
`search.json` returns **zero** topics for blinded share accounting — treat that silence as a
real negative result, not a search failure. And an agent's fetch summarizer **fabricated** a
BBA+ title and performance table: **read the PDFs directly** for BBA+, Black-Box Wallets, and
Bedrock.

## Evidence For

Sorted by strength. "For" here means supporting the *inverted* claim under test — that blinded credit
is strictly harder than blinded payout, and that the two named escapes are the only ones.

1. **The dichotomy holds for weight aggregation, with an explicit necessity argument in the
   literature.** *Anonymous Counting Tokens* (Benhamouda, Raykova, Seth; Asiacrypt 2023) §1 argues
   directly that per-user registered state is required to bound issuance per identity.
   **Rate-Limited Privacy Pass** (`draft-ietf-privacypass-rate-limit-tokens-06`) states it in
   normative RFC language and ships route (a) — a pool-side persistent handle — with explicit
   anti-rotation locks. Compact E-Cash (CHL, Eurocrypt 2005) and WabiSabi (eprint 2021/206) both
   collapse into one horn or the other. **Strength: high — convergent, and one source is a
   standards-track document that had to choose.**
2. **Sub-claim E survives on the interactivity axis, quantified.** Blinded payout is a single
   **non-interactive, offline** BIP32 `CKDpub` (one HMAC-SHA512 + one point add, tens of µs,
   embarrassingly parallel, 43 B on-chain amortized). Blinded credit is an **online 2-party
   interactive** protocol: ~45 ms pool-side, **4–5 round trips / ≈9 messages**, 1,745 B per event,
   and **serial per token** (two in-flight `Add`s reuse serial `s` and self-incriminate via
   `IdentDS`). ≈900× in compute, ≈41× in bytes. Decisively, **interactivity cannot be
   Fiat–Shamir'd away** — BBW p.166 relies on "interactive proof systems, where standard rewinding
   techniques replace the trapdoor," so removing interaction reinstates the TTP. **Strength: high —
   this is the axis on which "strictly harder" is defensible.**
3. **The pool needs identity to *validate*, not merely to credit — an obstacle upstream of the whole
   thesis.** Bedrock's `store(M.uname, K_M, R_M, target)` puts the per-miner vardiff `target` in the
   same identity-keyed row as the cookie seed, and `verifyJob` fetches it via `getMParams(M.uname)`.
   A pool cannot evaluate `H²(nonce||F) < target` for an anonymous submitter at all. **Strength:
   high — verbatim from Algorithm 1, and new to this wiki.**
4. **Sub-claim D holds, and is now on firmer ground than when this thesis was written.** Enrollment
   gating works via KVAC (Chase–Meiklejohn–Zaverucha, **CCS 2014**) or Privacy Pass / VOPRF
   (RFC 9497, RFC 9576). ACL is now **proven concurrently secure** in AGM+ROM
   (Kastner–Loss–Renawi, CCS 2023), which matters because a pool runs thousands of parallel sessions.
   **Strength: high.** The ROS attack does rule out the blind-Schnorr family at pool concurrency —
   and by a wider margin than recorded: **ℓ = 9** practical sessions, not 256.
5. **Batching leaks the thing it is meant to protect.** Crediting in batches is what makes the
   accumulator affordable, but the inter-credit interval leaks hashrate (`interval = b / share_rate`),
   converting a per-share leak into a lower-sampled leak of the same quantity. Since Recabarren &
   Carbunar recover 0.53–34.4 % payout-prediction error from **the timestamps of the first 50 packets
   alone**, fixed-threshold batching is self-defeating; boundaries must be Poisson-randomized.
   **Strength: high — and this is where the residual difficulty actually lives.**
6. **Sub-claim A is *not established* by the literature, which cuts against the thesis's own
   generosity to itself.** Nobody binds a blinded value into a PoW preimage. The nearest system
   (Biryukov–Pustogarov, FC 2015) deliberately sends the share and the commitment **separately**.
   A holds by Bedrock's own §7.1 argument — which turns only on the value *differing* between victim
   and attacker, never on the semantics of `M.uname` — but at a **lower bar than assumed**, since
   Bedrock proves nothing. **Strength: medium (argument, not evidence).**

## Evidence Against

1. **Sub-claim C is FALSIFIED — a third mechanism exists, and it is already deployed.** A keyed
   share-derived **nullifier** `nf = PRF_{sk_M}(header_hash)` is pool-side state that is **neither a
   pseudonym nor an accumulator**: it is single-use, unlinkable across shares, and carries no
   identity. Three independent code-level confirmations that deployed duplicate rejection carries
   **no identity term at all**: SRI's `seen_shares: HashSet<Hash>`; Ocean's
   `datum_stratum_dupes.h`, which keys on header fields only and is **checked before attribution**;
   and p2pool-v2's `HashSet<&BlockHash>`. Corroborated cross-domain by Cashu NUT-07
   (`Y = hash_to_curve(secret)`), Zcash nullifier sets (§3.2.3/§3.9), Tor proposal 327, and Privacy
   Pass. **Strength: high — deployed code, three independent implementations.** The thesis's
   "cannot preserve … duplicate arbitration without either" is false.
2. **The miner-carried-accumulator horn is *open*, not closed — and this wiki's reason for thinking
   otherwise was inverted.** The Canard–Gouget "impossibility" was the load-bearing reason to treat
   that horn as blocked. It is cited in the BBA literature for the **opposite** proposition: Faller
   et al. (IMACC 2021) invoke it to explain why *"**A BBA issuer and an accumulator can collude
   without breaking privacy. This is necessary due to an impossibility result**"*, merging the roles
   into "the operator." BBA+ p.1933 proves unlinkability against *"a collusion of I, AC, and V"*;
   BBW shares `sk_I` across all three (Def 4.1) and **removes the TTP trapdoor entirely** (p.171).
   The impossible notion is **Perfect Anonymity**, one level above full unlinkability, scoped to
   **coin transfer between users** — an antecedent a pool never satisfies. **Strength: high, with one
   caveat: the ACNS 2008 primary text is paywalled and unread; the finding rests on four independent
   restatements** (Faller et al., BBW, P4TC, a USP thesis) plus Gouget's own 2008 invited-talk
   abstract, which attributes coin-growth to Chaum–Pedersen rather than to herself.
3. **There is no theorem making stateful accumulation harder than one-shot issuance.** Searched five
   independent ways; no lower bound or separation of that form exists. Two peer-reviewed
   constructions measure the update *within a small constant factor* of issuance — BBW Table 1 p.14:
   `Issue 52 ms` vs **`Add 62 ms`**; UACS Table 1 p.23 (Pixel): `Join 76 ms` vs **`Earn 110 ms`** —
   and Coull–Green–Hohenberger (ACM TISSEC 2011) achieve hidden state transitions in **constant**
   time. The one-show/multi-show gap is a *technique* tradeoff (Kastner–Loss–Renawi, CCS 2023 p.5:
   single-show credentials "bypass heavy tools such as zero-knowledge"), and the blind-signature
   impossibility line (Lindell; Fischlin–Schröder; Pass) is entirely about **round complexity** —
   none of its conditions mention attributes, state, or updates. **Strength: high.**
4. **The quantitative case for "fatal" was wrong by ~4×, because this wiki costed crediting with the
   spending row.** The recorded 122 ms / 182 ms / ~4 kB is BBW's **`Sub16,lin`** (redemption); the
   credit operation is **`Add`: 62 ms user / 45 ms system / 1,745 B**. At the correct figure,
   per-share crediting needs **72 cores at F2Pool's 16,000 miners** and 262 at solo.ckpool's
   *measured* `SPS1m: 5832.5` across 39,592 workers — expensive, but a few racks, and both papers
   decline to measure the (faster) server side. **Batched at SV2's shipped `share_batch_size = 10`:
   7.2 cores at F2Pool scale, 17.8 at solo.ckpool's.** Infeasible only at Foundry scale (~5,084
   cores). **Strength: high — primary tables plus a live measured share rate.**
5. **The range-width blocker was a category error.** The 16-bit balance constrains **redemption
   only**: BBW Fig. 4 p.174 shows `Proof P2 (Add)` carries **no range proof**; only `Proof P3 (Sub)`
   adds one. Crediting is bounded by `2|V| < |Zp|` — **~2²⁵¹ on Curve25519** against the ~50 bits an
   `8 × D` window needs (`8 × 1.2623e14 = 1,009,852,056,974,944`, log₂ = 49.84), i.e. 201 bits of
   headroom. BBA+ needs nothing at all (`p ≈ 2²⁵⁰`, no range proof by choice). Widening redemption
   16→64 bits costs **+129 B and +21.8 ms**. **Strength: high.**
6. **Batched crediting is native to the primitive and already expressible in SV2.** `v` is an
   **arbitrary field element at constant cost** — BBA+ p.1932 ("a **positive or negative** value v"),
   p.1931 (complexity and token size "independent of the number of points to be transferred or
   stored"). **This is what separates BBA+ from Cashu's denomination ladder**, and this wiki never
   said it. SV2's `SubmitShares.Success` already exists "for **multiple SubmitShare messages
   aggregated together**" and carries **`new_shares_sum` U64 — "Sum of difficulty of shares
   acknowledged within this batch."** That field *is* the `v` to credit. **Strength: high — spec text
   plus shipped reference configs.**
7. **One genuine third route for aggregation exists, though it pays for it.** hashpool's
   **value-bearing token substitution** — absolute per-share `2^(d−min)` with no running total — is
   real and deployed, and is neither a pseudonym nor an accumulator. But it abandons window-relative
   accounting, and hashpool's own `SETTLEMENT_DESIGN.md` reverts to a cleartext
   `payout_address`-keyed accumulator for cross-epoch settlement. **Strength: medium — it works by
   redefining the accounting rather than satisfying it.**
8. **Bedrock supplies no baseline for C to lose.** `verifyJob` is stateless, does not consume
   `job_id`, and writes nothing back; *duplicate*, *replay*, and *serial* never appear in that sense.
   So C **cannot be falsified against Bedrock** and must be argued against deployed practice. The
   paper's own BiteCoin run *suppressed* the victim's share ("sends to the pool a mangled copy … to
   ensure that it is rejected") rather than racing it. **Strength: high.**

## Nuances & Caveats

- **The verdict splits the thesis's conjunction.** "Cannot preserve share-weight aggregation **or**
  duplicate arbitration" is one claim joined by *or*; it holds for the first and fails for the
  second. As the Opposing lens put it: *partially falsified — it holds for aggregation and fails for
  duplicate arbitration.*
- **The difficulty is real but relocated.** Every *cryptographic* barrier this wiki was leaning on
  dissolved. What survives is (a) **interactivity** — online 2-party vs offline derivation, which is
  the honest basis for "strictly harder" — and (b) **the hashrate side channel**, which no
  cryptography addresses and which defeats any pseudonym long-lived enough to aggregate against.
  Difficulty of the engineering kind, not the impossibility kind.
- **C's pessimism is defensible on *enforcement economics*, not cryptography.** BBA+/BBW catch
  double-spend only via a serial-number database scanned after the fact, and the punishment
  identifies a *user* to penalize. Against anonymous hashrate with nothing seizable, that model has
  no teeth. A real gap — but not the one the thesis claimed.
- **Feasibility narrowed to one host.** The construction is live under **SV2 Job Declaration only**,
  via a JDC-added coinbase `OP_RETURN` — **not** the scriptSig. And **DATUM is a counterexample, not
  supporting evidence.**
- **Bedrock is a weaker starting point than the thesis assumed.** It names no hardness assumption
  and proves nothing (§7.1 is a work-equivalence argument); its cookie rotates only on block-find,
  **~7.44 years for an S7**, so it never delivered a per-session unlinkable value; and placing the
  cookie in the prevout hash is **consensus-invalid for the share that is a block**. Relocating it is
  *our repair*, not a resolution of the paper's ambiguity.
- **Provenance hazard, now measured.** WebFetch **silently fails on image-based PDFs and returns
  confident "ABSENT" verdicts** — it reported all four Recabarren & Carbunar claims absent when all
  four are present. This is almost certainly the mechanism behind the fabricated BBA+ title, the
  fabricated performance table, and the fabricated author names ("Kaidel", two "Koch"s) that this
  round removed. **Download and `pdftotext -layout`; never trust a fetch summarizer on a PDF.**
- **Unresolved.** The Canard–Gouget ACNS 2008 primary text (paywalled) and LatInc (TDSC 2026,
  paywalled) remain unread. Ocean's TIDES `8 × D` window figures rest on a single unreplicated fetch
  (`docs.ocean.xyz` now DNS-fails) — medium confidence. No published µs/op figure for BIP32
  derivation exists upstream.

## Verdict

**Status: MIXED — the conjunction fails, and it fails on the sub-claim the thesis treated as its
strongest.**

| # | Sub-claim | Verdict | Confidence |
|---|---|---|---|
| A | Re-labeling resistance survives blinding | **Unestablished, but likely** — holds by Bedrock's §7.1 argument, at a lower bar than assumed; no literature binds a blinded value into a PoW preimage | medium |
| B | Weight aggregation survives without a pool-side persistent ID | **Thesis SUPPORTED** — the dichotomy holds; explicit necessity arguments in Anonymous Counting Tokens and Rate-Limited Privacy Pass | high |
| C | Duplicate arbitration survives | **Thesis FALSIFIED** — a keyed share-derived nullifier is a third mechanism, confirmed in three independent deployed implementations that carry no identity term | high |
| D | Enrollment gating survives | **SUPPORTED** — KVAC / RFC 9497; ACL now proven concurrently secure | high |
| E | Blinded credit strictly harder than blinded payout | **SUPPORTED on interactivity, NOT on cost** — online 2-party vs offline non-interactive derivation is the defensible axis; the arithmetic gap is ~4× smaller than this wiki claimed | high |

**Overall confidence: high** — on the falsification of C and on the collapse of the cryptographic
barriers, both of which rest on primary text and deployed code. Lower for A, which remains an
argument rather than a finding.

**The recommended reformulation**, narrowing to what survives:

> Blinding a PoW-committed mining cookie preserves re-labeling resistance and admits duplicate
> arbitration via a keyed share-derived nullifier, but **cannot preserve share-weight aggregation**
> without either a pool-side persistent pseudonym or a miner-carried accumulator. Blinded share
> credit is strictly harder than blinded payout **because crediting is an online interactive protocol
> while payout is an offline non-interactive derivation** — not because of cost, range, or any
> impossibility result.

As the Historical lens put it: *as stated it hands a reviewer an easy counterexample.*

**What this round overturned in the wiki itself** — five corrections, four of them load-bearing:
the Canard–Gouget prescription was **inverted**; the ROS threshold is **ℓ = 9, not 256**; the
ROS-breaks-ACL claim was **retracted by its own authors**; the `Add`/`Sub` figures were **swapped**,
overstating pool cost 4.04×; and the 16-bit range limit **does not touch the crediting path**. Plus
fabricated authors removed from two files.

## See also

- [[../topics/self-blinding-pool-design-space|Self-Blinding Pool Design Space]] — the parent synthesis; this is its objection #1
- [[../concepts/blind-share-accounting|Blind Share Accounting]] — BBA+, Canard–Gouget, the primitive mismatch
- [[../concepts/nullifier-vs-pseudonym|Nullifier vs Pseudonym]] — the construction that falsified sub-claim C
- [[../concepts/payout-attribution-privacy|Payout Attribution Privacy]] — what a pool structurally knows
- [[../concepts/hashrate-inference-side-channels|Hashrate Inference Side Channels]] — BiteCoin, Bedrock, and how B fails in practice
- [[../concepts/ehash|eHash]] — the deployed system that retains `header_hash`
- [[../../output/playbook-self-blinding-pool-attribution-2026-07-29|Playbook: self-blinding pool attribution]] — derived thesis #1
