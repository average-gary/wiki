---
title: "No separation exists between stateful accumulation and one-shot issuance — and two of this wiki's blockers do not survive their sources"
authors: [Max Hoffmann, Michael Klooß, Markus Raiber, Andy Rupp, Johannes Blömer, Jan Bobolz, Denis Diemert, Fabian Eidens, Scott E. Coull, Matthew D. Green, Susan Hohenberger, Julia Kastner, Julian Loss, Omar Renawi, Fabrice Benhamouda, Tancrède Lepoint, Michele Orrù, Mariana Raykova]
year: 2025
venue: "Multi-source: PoPETs 2020, ACM CCS 2019, ACM TISSEC 2011, ACM CCS 2023, EUROCRYPT 2021, eprint 2025/161"
source: https://eprint.iacr.org/2019/1199
supporting_sources:
  - https://eprint.iacr.org/2019/169
  - https://eprint.iacr.org/2008/474
  - https://eprint.iacr.org/2023/707
  - https://eprint.iacr.org/2020/945
  - https://eprint.iacr.org/2025/161
  - https://eprint.iacr.org/2021/306
type: papers
ingested: 2026-07-29
quality: 5
credibility: high
confidence: high
tags: [bba-plus, black-box-wallets, updatable-credentials, stateful-credentials, ros-attack, acl, canard-gouget, correction, negative-result, verbatim-verified, thesis-evidence, wayback-provenance]
summary: "Targeted search from five independent directions for a lower bound showing stateful accumulation is harder than one-shot issuance. No such result exists. Two measured constructions show an update costs ~1.2–1.4x an issuance. Separately overturns two blockers this wiki had been carrying: the Canard–Gouget 'impossibility' is a misattribution, and the ROS-breaks-ACL claim was retracted by the ROS authors."
---

# Stateful accumulation vs one-shot issuance — there is no separation

Searched from five independent directions — IACR eprint full-text, OpenAlex keyword and
citation-forward, DBLP, and direct reading of primary PDFs. **No result of the form "updating a
hidden attribute is fundamentally harder than fresh issuance" exists in this literature.** The
belief is an artifact of which primitives happen to be standardized, not a theorem.

**Provenance note:** IACR eprint is Cloudflare-403 from this environment. All eprint PDFs below
were retrieved via `web.archive.org/.../id_/` raw captures. Venue and author attributions were
independently confirmed against DBLP and OpenAlex.

## 1. Update ≈ issuance, measured twice

**Black-Box Wallets: Fast Anonymous Two-Way Payments for Constrained Devices** — Hoffmann, Klooß,
Raiber, Rupp. eprint 2019/1199, PoPETs 2020. Full PDF read (27 pp.).

Table 1, **p.14**, user-side execution time, BBW column: `Issue 52 ms`, `Add 62 ms`,
`Sub16,lin 122 ms`. Prose, **p.13**:

> "While Issue and Add are highly efficient with approximately 50 ms and 60 ms respectively, the
> performance of Sub varies with different parameters and algorithm choices."

`Add` **is** the accumulation operation — the user "outputs an updated token τ∗ (with balance
w + v)". So accumulation costs **~1.2× issuance**. Note the asymmetry runs the *opposite* way from
the folklore: the expensive operation is `Sub` (spending, which needs a range proof), not `Add`.

**Updatable Anonymous Credentials and Applications to Incentive Systems** — Blömer, Bobolz,
Diemert, Eidens. eprint 2019/169, ACM CCS 2019. Full PDF read.

Table 1, **p.23**, Google Pixel row: `Issue 56 | Join 76 | Credit 122 | Earn 110 | Deduct 353 |
Spend 390`. User-side additive update (`Earn` 110 ms) vs user-side issuance (`Join` 76 ms) —
**~1.4×**. Abstract:

> "a user holding a credential certifying some attributes can interact with the corresponding
> issuer to update his attributes. During this, the issuer knows which update function is run, but
> does not learn the user's previous attributes."

**Access Controls for Oblivious and Anonymous Systems** — Coull, Green, Hohenberger. eprint
2008/474; ACM TISSEC 14(1):10:1–10:28, 2011 (DBLP-confirmed). Abstract, **p.1**:

> "Our system is secure in the standard model under basic assumptions, and, after an initial setup
> phase, each transaction requires only **constant time**."

A stateful credential with hidden state transitions at constant per-transaction cost. Blömer et al.
**p.4** relate the two lines:

> "More technically similar to our updatable credential mechanism are stateful anonymous credentials
> [CGH11, GGM14]. A stateful credential contains a state. The user can have his credential state
> updated to some successor state as prescribed by a public state machine model. For this, the user
> does not have to disclose his current credential state. Such a state transition is a special case
> of an update to a state attribute in an updatable credential."

## 2. One-show vs multi-show is a technique tradeoff, not a proven separation

Every primary source frames it as construction efficiency. **No source states or cites a lower
bound.** And the framing points *against* the hardness intuition.

**Concurrent Security of Anonymous Credentials Light, Revisited** — Kastner, Loss, Renawi. eprint
2023/707, ACM CCS 2023. **p.5**:

> "The second type of credential can be shown only a single time. While this comes at the expense of
> some functionality, single-show credentials can often be constructed directly from blind signature
> schemes and can bypass heavy tools such as zero-knowledge. Therefore, single-show credentials are
> usually far more efficient than multi-show credentials."

The causal direction is explicit: single-show is cheaper *because* it avoids ZK. That is a statement
about technique, not about the hardness of the functionality.

**Stronger Security for Blind Signatures with Attributes** — Baldimtsi, Kastner, Loss, Renawi.
eprint 2025/161. Full PDF read (98 pp.). **p.2**:

> "While the literature has been largely dominated by multi-show credential systems […] these
> approaches typically rely on expensive pairings or computationally heavy zero-knowledge proofs
> during credential showing. By contrast, blind signature–based single-show ACs are lightweight."

Their own contribution is a **generic transform** lifting blind signatures into attribute-carrying
credentials — evidence that the boundary is malleable rather than rigid.

## 3. The blind-signature impossibility line is about *round complexity*, not state

**Round-Optimal Blind Signatures in the Plain Model** — Katsumata, Nishimaki, Yamada, Yamakawa.
eprint 2021/306. **p.8, §1.4**:

> "Lindell proved that it is impossible to achieve round-optimal blind signatures in the plain model
> under the simulation-based security definition [Lin08]. […] Fischlin and Schröder [FS10] prove that
> 3-move (and fewer moves) blind signature schemes cannot be secure under non-interactive
> assumptions in the plain model via black-box reductions if they satisfy all the following
> conditions: (1) it is 3-move (or fewer moves), (2) it satisfies computational blindness (3) we can
> efficiently check whether the execution of the scheme yields a valid signature from its transcript,
> (4) we can efficiently verify whether a verification-key has a corresponding signing key, and
> (5) its blindness holds relative to a forgery oracle. […] Pass [Pas11] prove that there is no
> black-box reduction from round-optimal unique blind signatures to non-interactive assumptions."

**Accumulation-relevance: zero.** Every condition concerns move count, blindness, or key
checkability. None mentions attributes, state, or updates. These are real theorems pointed at a
different question. Citing this line for "stateful is harder" cites a result about *rounds* for a
claim about *state*.

Same for the meta-reduction line — **On the Security of One-Witness Blind Signature Schemes**,
Baldimtsi & Lysyanskaya, eprint 2012/197, ASIACRYPT 2013 pp.82–99 (DBLP-confirmed), Theorem 1 **p.8**
— which is about *proof techniques* for blind Schnorr unforgeability, not accumulation.

## 4. Correction: the Canard–Gouget "impossibility" is a misattribution

This wiki asserted it "rules out full unlinkability when issuer, accumulator, verifier and adversary
coincide in one operator," ranked it blocker #1, and called role separation "the requirement."
**The source does not say that.**

The sole citation traces to Black-Box Wallets **p.3**, quoted here in full context:

> "Using transferable e-cash such as [4] where anonymous and unlinkable transfers of coins is
> possible (under certain assumptions), the accumulator could withdraw coins and transfer them to the
> user. However, an impossibility result by Canard and Gouget [12] implies, that if the issuer,
> accumulator, and verifier collude, transactions can be linked."

Three problems, in increasing severity:

1. **It appears in a paragraph rejecting an alternative design.** The subject is **transferable
   e-cash**, which BBW considered and did *not* use. It is a reason BBW went another way — not a
   limitation of BBA+/BBW.
2. **The primary text is unverified.** Ref [12] is Canard & Gouget, *"Anonymity in Transferable
   E-Cash,"* **ACNS 2008, pp.207–223** (confirmed via DBLP and OpenAlex; both confirm it is **not**
   open access). No OA copy was found. **Its actual theorem statement remains UNVERIFIED**, and
   "implies" is BBW's inference about someone else's paper.
3. **Decisively: BBW shares the key across all three roles and still proves privacy.** Definition
   4.1: *"IGen(crs) generates a key pair (PK_I, sk_I) for the issuer, which is also shared with the
   accumulator and verifier."* It then proves Definition 3.4 (Privacy-Preserving) against an
   adversary holding `PK_I` with `MalIssue, MalAcc, MalVer` oracles. **The single-operator case this
   wiki believed was ruled out is the case BBW actually proves secure** — and via *simulation*
   -linkability (Theorem 5.2), which removes the trapdoor and per **p.11** allows setup "without a
   trusted third party."

The third point is inference from definition and theorem numbering as read, not a quoted claim — but
it is grounded in text that was read directly.

### It is worse than a misattribution: the prescription is **inverted**

A second, independent search found the decisive primary text. **"Black-Box Accumulation Based on
Lattices"** — Faller, Baumer, Klooß, Koch, Ottenhues, Raiber, IMACC 2021 (eprint 2021/1303), read via
Wayback. §1, related work, **verbatim**:

> "it is not possible in BBA to separate issuer and accumulator – such as when the issuer is an E-Cash
> bank, and the accumulator a merchant. Issuer and accumulator have the same secret key. On the other
> hand, a merchant and bank must not collude in E-Cash, as this can break privacy. **A BBA issuer and
> an accumulator can collude without breaking privacy. This is necessary due to an impossibility
> result, cf. [12].**"

Its bibliography confirms `[12] S. Canard and A. Gouget. "Anonymity in Transferable E-cash". ACNS 08
… pp. 207–223.`

**Canard–Gouget is cited as the reason BBA *must tolerate* issuer/accumulator collusion** — a design
constraint *satisfied by* the single-key model, not a barrier to it. Same paper, §2.1: *"As these
roles share the same key pair, we do not distinguish them within the paper and refer to them as **the
operator**."* And privacy holds against that operator: *"an adversary is not able to link any
transactions of the user, **even with corrupt operators**."*

BBA+ itself says so, **p.1933**: *"an adversary, **which could be a collusion of I, AC, and V**, may
not be able to link the Accum and Vfy transactions of an honest user."*

So this wiki did not merely overstate a result — it stated the prescription **backwards**. The BBA
literature's position is that the roles share one key *by construction* and privacy is proven against
their collusion.

### The actual impossible notion is *Perfect* Anonymity, in transferable e-cash

And it sits one level *above* the "full unlinkability" this wiki invoked. From the USP MSc thesis
(da Silva 2016, open access, direct fetch), Definition 27 restating Canard–Gouget's hierarchy:

> "**Perfect Anonymity (PA)**: The scheme achieves FA and the adversary cannot decide whether or not
> he/she has owned a coin he/she received. Since it is proved that **PA cannot be achieved if the bank
> is itself a possible adversary**, two other properties can be defined by modifying this last
> property"

with `PA ⇒ FA ⇒ SA ⇒ WA`. Independently corroborated by **P4TC** (PoPETs 2020(4), Rupp group): *"there
also is an impossibility result [21] negating "perfect anonymity""* — the scare quotes around
"perfect" are theirs.

**The predicate is about recognizing a coin you previously owned after it returns to you** — i.e.
transfer between *users*. Share weight is never transferred between miners; it is incremented by the
operator. **The theorem's antecedent is never satisfied by a mining pool.**

*(Secondary restatement, quality 3 — but explicit, attributed, and agreeing with three other
independent restatements.)*

### And the trapdoor escape hatch was removed in 2020

The wiki called a TTP-held trapdoor the mandatory escape. BBW **p.171** removes it outright:

> "since our common reference string is indeed only a common random string, and **there is no trapdoor
> anymore, it is possible to set up our scheme without a trusted third party** by generating the crs
> for example through evaluating a cryptographic hash function"

> "unlike in BBA+, a misbehaving TTP that leaks information on how the crs was generated … to the
> operator **does not impact user privacy**"

**What this changes:** transferable e-cash *between miners* would inherit the Canard–Gouget concern.
A pool that issues and accumulates against its own key does not — that is the case the literature
designs for. The non-collusion requirement this wiki imported from OHTTP is **not** additionally
forced by cryptography here.

### The wrong-target result that *does* exist

**"Transferred Cash Grows in Size"** — Chaum & Pedersen, EUROCRYPT '92, LNCS 658 pp.390–407 (Springer
OA, direct fetch). Genuine theorems (4.2, 5.1) with entropy lower bounds. Abstract: *"it is impossible
to construct an electronic money system providing transferability without the property that the money
grows when transferred."*

Scope is **transferability** — "the payee in one payment transaction can spend the received money in a
later payment to a third person without contacting the bank." **Not applicable** to accumulated
weight: BBA tokens are constant-size *precisely because* the operator co-signs every increment, so the
growth antecedent never triggers. Worth recording that this, not Canard–Gouget, is the paper that
actually owns the "coins must grow" result.

## 5. Correction: the ROS number is off by ~28×, and ROS-breaks-ACL was retracted

The `256` figure is verbatim-correct but describes the wrong threshold. eprint 2020/945, **p.4**:

> "illustrating how to break one-more unforgeability of blind Schnorr signatures over 256-bit
> elliptic curves in a few seconds (when implemented in Sage), provided that the attacker can open
> 256 concurrent sessions."

That is the threshold for the **seconds-long** attack, not for breakage. **p.17, §7 Conclusions**:

> "In practice, the cost of the attack and the number of sessions required are very small: for
> today's security parameters, the attack can be already mounted with **ℓ = 9** parallel open
> sessions. As already pointed out by [FPS20], even just ℓ = 16 open sessions could lead to a forgery
> in time roughly 2^55 […] For ℓ = 128, our attack of Section 4 leads to a forgery in time roughly
> 2^32."

**Nine, not 256.** Theorem 1, p.5: *"If ℓ ≥ λ, then there exists an adversary that runs in
polynomial time and solves the ROS problem relative to Pgen with dimension ℓ."* Authors confirmed:
Benhamouda, Lepoint, Loss, Orrù, Raykova; EUROCRYPT 2021, LNCS 12696 pp.33–53. The practical
conclusion — don't use blind Schnorr at pool concurrency — is unchanged and in fact strengthened.

**And the ACL claim was retracted by the ROS authors.** Same paper, **p.4**:

> "An earlier version of this paper claimed attacks against Anonymous Credentials Light [BL13] and
> restrictive partially-blind signatures from bilinear pairings [CZMS06]. As pointed out by Kastner,
> Loss, and Renawi in [KLR23], our claimed attack on [BL13] relied on an incorrect verification
> equation and do not apply to [BL13]."

Confirmed against the v1 Wayback snapshot (`20200928133857`), whose abstract does not mention ACL.
Kastner–Loss–Renawi (2023/707) prove ACL **concurrently secure** in AGM+ROM (Corollary 4.2, ~p.17).
Since BBW is built on ACL, the concern that "ACL is only sequentially secure" is **stale** — though
the ACL authors' own hedge is correctly quoted (eprint 2012/298 p.3: *"we leave extending it to
concurrent self-composition as an open problem"*).

**Reconciling two readings of ROS.** A second independent read of the same paper reported the wiki's
"~256" as *correct*, citing the p.4 sentence. Both quotes are real and they describe different things:
p.4's 256 is the session count for the **seconds-long Sage** attack on 256-bit curves, while §7 p.17
gives the **practical** figure as ℓ = 9 today. The general threshold is `ℓ > log p`. The p.17 reading
is the operative one for a pool — but note the second read also confirms the paper's *current* version
still names *"Anonymous Credentials Light"* among affected schemes in its list, which is exactly the
claim its own §7 retraction on p.4 withdraws. **Cite the retraction, not the list.**

## Bearing on the thesis

- **Sub-claim B (aggregation) — the *cryptographic* half of the difficulty argument weakens
  substantially.** The dichotomy (pool-side pseudonym or miner-carried accumulator) still stands as
  a structural claim, but "the miner-carried-accumulator horn is blocked by an impossibility result"
  was the reason this wiki treated that horn as closed. It isn't. The horn is **open and measured**:
  ~62 ms per update on constrained hardware.
- **The honest difficulty argument is now narrower and entirely quantitative**: range-proof width
  (16-bit prototype vs ~10¹⁵ share weights), per-share protocol round-trips at pool share rates,
  double-spend database size, and the hashrate side channel — which no cryptography addresses.
- **Sub-claim D (enrollment gating) — strengthened.** ACL is now proven concurrently secure, so the
  cheap single-show route is available rather than caveated.

## Not verified

- **Canard–Gouget, ACNS 2008 primary text** — paywalled (Springer/DOI), no preprint,
  `oa_status: closed`, no OpenAlex abstract. The theorem statement is **UNVERIFIED at source.** The
  scope finding above rests on **four independent restatements** (Faller et al. 2021, BBW, P4TC, the
  USP thesis) plus Gouget's own 2008 invited-talk abstract, which attributes coin-growth to
  **Chaum–Pedersen**, not to herself. All four agree it concerns transferable e-cash. Institutional
  access to that PDF is the one step that would fully close this; it should change theorem numbering,
  not direction. Until then, cite it as *"the BBA literature's characterization of Canard–Gouget."*
- **LatInc** (TDSC 2026) — paywalled; the newest BBA-line work, unread.
- **Fischlin–Schröder 2010 and Pass 2011 at source** — read only as quoted in Katsumata et al.
  p.8. Treat the original wording as second-hand.
- **Anonymous tokens with private metadata bit** (Kreuter, Lepoint, Orrù, Raykova) — whether the
  one-bit limit is proven or merely constructional is **open**. The trend visible in eprint search
  results is toward *more* carried state (rate-limiting, attributes, public+private metadata), which
  cuts against a hardness barrier.

## See also

- [[2026-07-29-bba-plus-black-box-wallets|BBA+ / Black-Box Wallets ingest]] — the file carrying the
  claims corrected here
- [[../../wiki/concepts/blind-share-accounting|Blind Share Accounting]] — blocker list revised
- [[../../wiki/theses/blinded-share-credit-commitment|Thesis: blinded share-credit commitment]]
