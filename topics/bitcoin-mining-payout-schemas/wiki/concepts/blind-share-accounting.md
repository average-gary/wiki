---
title: Blind Share Accounting — cryptographic primitives for weight without identity
category: concept
created: 2026-07-29
confidence: high
tags: [bba-plus, black-box-accumulation, kvac, anonymous-credentials, privacy-pass, voprf, ros-attack, acl, cashu, blind-signature, canard-gouget, negative-result, correction]
volatility: warm
updated: 2026-07-29
summary: "The primitive-selection problem: PPLNS credit is a running weighted sum, but ecash tokens are one-shot denominated bearer objects. BBA+/Black-Box Wallets are the only primitive that natively accumulates weight. Corrected 2026-07-29: the Canard–Gouget 'impossibility' that this article treated as the single-operator blocker is a misattribution, and no theorem makes accumulation harder than issuance — the real blocker is range-proof width."
verified: 2026-07-29
sources:
  - "raw/papers/2026-07-29-bba-plus-black-box-wallets.md"
  - "raw/papers/2026-07-29-stateful-vs-oneshot-credentials-no-separation.md"
  - "raw/repos/2026-07-29-mining-privacy-prior-art-survey.md"
  - "raw/papers/2026-07-29-recabarren-carbunar-hardening-stratum.md"
---

# Blind Share Accounting

Blinding the *payout* is the easy half. The hard half is that PPLNS-style credit is a **running
weighted sum over a sliding window**, while every deployed privacy primitive in Bitcoin is a
**one-shot denominated bearer object**. This article is about that mismatch and the one primitive
family that actually fits.

## The mismatch, stated plainly

| Property PPLNS/TIDES needs | What Cashu-style ecash provides |
|---|---|
| Continuous accumulation of weight | Discrete tokens from a fixed denomination ladder |
| Weight is per-share difficulty, arbitrary-valued | `amount = 2^(diff − keyset_min_diff)` — power-of-two buckets |
| Window-relative decay (shares age out) | Tokens are timeless bearer objects |
| Exact final total | Rounding to the ladder |
| Operator must not learn per-miner totals | Mint learns every issuance and every redemption amount |

vnprc, the author of both hashpool and the closed Cashu mining-share NUT, stated the core tension
in delvingbitcoin #870 post #32:

> "these tokens are inherently unlinkable to the underlying collateral… **You can do multiple
> redemptions by linking the tokens to the mining share, but in the process you destroy the
> privacy properties of ecash.**"

## BBA+ / Black-Box Wallets — the only primitive that accumulates

Black-Box Accumulation (Jager & Rupp, PoPETs 2016; **BBA+**, Hartung, Hoffmann, Nagel & Rupp,
CCS 2017 pp.1925–1940; **Black-Box Wallets**, Hoffmann, Klooß, Raiber & Rupp, PoPETs 2020
**article 0010** — note popets-2020-0007 is an unrelated DP paper) is the only cryptographic object
designed for exactly this shape: an unlinkable token carrying a **quantitative balance** that a third
party increments without learning the balance or the holder.

*(Author-list corrected 2026-07-29 — this article previously credited BBA+ to "Hartung, Kaidel, Koch,
Koch & Rupp." There are four authors and neither "Kaidel" nor "Koch" is among them; the names were
fabricated by a fetch summarizer, the same failure mode already flagged elsewhere in this topic.)*

Four properties that map onto share accounting almost too well:

1. **The user never performs the addition.** The accumulator adds `+v` homomorphically to a
   committed balance. Inflation by the holder is impossible — the crux of why a miner can't
   forge share weight.
2. **Token size is independent of the number of points accumulated.** A million shares costs the
   same bytes as one. (Compare: a bag of per-share ecash proofs grows linearly and must all be
   redeemed.)
3. **Rollback is caught, not prevented — with identity extraction.** Reusing a token exposes
   the holder through a double-spending tag `t := sk_U·u2 + u1 mod p`; two uses with different
   `u2` yield `sk_U = (t − t')·(u2 − u2')⁻¹`. This is the same construction shape as Chaumian
   ecash double-spend punishment, and it is what makes offline accumulation safe.
4. **Formal security proofs** in the CCS/PoPETs line, not folklore.

### The failure modes — revised 2026-07-29, and the list got shorter

**Two of the five blockers previously listed here did not survive contact with their sources.**
The remaining obstacles are all quantitative. See
[[../../raw/papers/2026-07-29-stateful-vs-oneshot-credentials-no-separation|the correcting read]].

1. **~~The Canard–Gouget impossibility~~ → RETRACTED. The prescription here was *inverted*, not
   merely overstated.** This article previously said "**Any** BBA+-based pool design requires role
   separation across non-colluding parties." **The BBA literature's actual position is the opposite:
   the roles share one key by construction, and privacy is proven against their collusion.** Faller
   et al. (IMACC 2021) state it directly: *"A BBA issuer and an accumulator **can collude without
   breaking privacy. This is necessary due to an impossibility result**, cf. [12]"* — where [12] *is*
   Canard–Gouget. Their §2.1: *"As these roles share the same key pair, we do not distinguish them …
   and refer to them as **the operator**."* BBA+ p.1933 agrees: the adversary *"**could be a collusion
   of I, AC, and V**"* and still cannot link. BBW's Definition 4.1 shares `sk_I` across all three
   roles and proves privacy anyway.
   Two further scope facts: the impossible notion is **Perfect Anonymity** — *"PA cannot be achieved
   if the bank is itself a possible adversary"* — which sits one level *above* the "full
   unlinkability" this article invoked, and its predicate is **recognizing a coin you previously
   owned after it returns to you**, i.e. transfer between *users*. Share weight is never transferred
   between miners, so **the theorem's antecedent is never satisfied by a pool.** The cited paper
   (ACNS 2008) remains paywalled and unread; the finding rests on four independent restatements.
   **Role separation is defense-in-depth here, not a cryptographic requirement.** The "coins must
   grow when transferred" result people often have in mind is **Chaum–Pedersen (EUROCRYPT '92)**, and
   it also scopes to transferability — BBA tokens stay constant-size precisely because the operator
   co-signs each increment.
2. **~~Balance range~~ → it binds redemption only, not crediting.** The Black-Box Wallets prototype
   carries a **16-bit** balance, and this article previously treated that as the blocker on
   accumulation. But BBW Fig. 4 (p.174) shows `Proof P2 (for the Add protocol)` carries **no range
   proof** — only `Proof P3 (for Sub)` adds "a range proof that `w − v ∈ V`". Crediting is unbounded
   up to `2|V| < |Zp|`, i.e. **~2²⁵¹ on Curve25519**, against the ~50 bits an `8 × D` window needs
   (`8 × 1.2623e14 = 1,009,852,056,974,944`, log₂ = 49.84). 201 bits of headroom. Widening
   *redemption* from 16→64 bits costs **+129 B and +21.8 ms proving** (Bulletproofs Table 2, p.32,
   secp256k1). BBA+ needs nothing at all — it reveals `w` and has `p ≈ 2²⁵⁰`, deliberately shipping
   no range proof. **Width is a solved problem in these papers.**
3. **Interaction cost per accumulation — the surviving quantitative obstacle, at ~¼ the price this
   article claimed.** Every increment is a protocol round, not a hash comparison, and it is **4–5
   round trips (~9 messages)**, not one. But the cost is `Add` at **45 ms pool-side**, not the 182 ms
   this wiki had — see the table below.
4. **secp256k1 blind Schnorr is off the table — and by a wider margin than stated.** The **ROS
   attack** (Benhamouda et al., EUROCRYPT 2021) breaks blind Schnorr and blind FROST/MuSig. This
   article previously said "roughly 256 concurrent sessions"; that is the threshold for the
   *seconds-long* Sage attack. The paper's own §7 gives **ℓ = 9** parallel sessions as practical
   today (ℓ = 16 → 2⁵⁵ work; ℓ = 128 → 2³²). **Nine, not 256.** Use RSA blind signatures, BDHKE, or
   algebraic-MAC/KVAC. Conclusion unchanged, argument stronger.
5. **~~ACL is only sequentially secure~~ → stale.** The ROS authors **retracted** their claimed
   attack on ACL (2020/945 p.4: *"our claimed attack on [BL13] relied on an incorrect verification
   equation and do not apply to [BL13]"*), and Kastner–Loss–Renawi (CCS 2023) prove ACL
   **concurrently secure** in AGM+ROM. Since BBW is built on ACL, this strengthens rather than
   blocks. The ACL authors' own 2013 hedge — *"we leave extending it to concurrent self-composition
   as an open problem"* — has been closed by others.
6. **No mining-specific construction exists.** Confirmed negative result, and it stands: **no
   literature on zero-knowledge proofs of accumulated mining-share contribution.** Not a BIP, not an
   SV2 extension, not a paper.

### There is no theorem making accumulation harder than issuance

Worth stating flatly, because the intuition is widespread and this wiki was relying on it. A search
from five independent directions found **no lower bound or separation** of the form "updating a
hidden attribute is fundamentally harder than fresh issuance." Two peer-reviewed constructions
measure the opposite — the update is within a small constant factor:

| Construction | Issuance | Additive update | Spend |
|---|---|---|---|
| **Black-Box Wallets** (PoPETs 2020, Table 1 p.14, user-side) | `Issue` 52 ms | `Add` **62 ms** | `Sub16,lin` 122 ms |
| **Updatable Anon. Credentials** (CCS 2019, Table 1 p.23, Pixel) | `Join` 76 ms | `Earn` **110 ms** | `Spend` 390 ms |

And Coull–Green–Hohenberger (ACM TISSEC 2011) achieve hidden state transitions in **constant** time
per transaction. The asymmetry that does exist runs the *other* way: spending is expensive because it
needs a range proof — and spending happens once per payout, not once per share.

**The Add/Sub confusion was this wiki's central quantitative error.** It costed *crediting* using the
*spending* row of BBW's Table 1, then concluded per-share accumulation was "fatal at real share
rates." At the correct `Add` cost of 45 ms pool-side (22.2 credits/s/core):

| Scenario | shares/s | cores needed |
|---|---|---|
| 1 EH/s of S21s @ 6 shares/min | 500 | 22.5 |
| F2Pool-scale, 16,000 miners @ 6/min | 1,600 | 72 |
| solo.ckpool, **measured** `SPS1m: 5832.5` across 39,592 workers | 5,832.5 | 262 |
| Foundry-scale, 226 EH/s @ 6/min | 112,974 | 5,084 |

Expensive next to a hash comparison, but *a few racks* — not an impossibility — and both papers note
the server side is expected to be far faster than the measured Snapdragon. Genuinely infeasible only
at Foundry scale. Bandwidth is a non-issue (10.2 MB/s at solo.ckpool's rate), and per-miner *latency*
is a non-issue too: one token is a serial state machine, but that still permits ~382 credits/min at
50 ms RTT against the 6–18 needed. **The binding constraint is aggregate pool CPU.**

### Batching resolves it, and SV2 already ships the plumbing

`v` is an **arbitrary field element at constant cost** — BBA+ p.1932: "To add a (**positive or
negative**) **value v** to the current balance w"; p.1931: complexity and token size are "**independent
of the number of points to be transferred or stored**." Neither paper restricts `v` to 1 or to a
denomination. **This is the fact that separates BBA+ from Cashu's ladder**, and it makes batched
crediting native rather than a workaround.

SV2 batches at exactly the right granularity. `SubmitShares.Success` (§5.3.13) exists "for **multiple
SubmitShare messages aggregated together**" and carries **`new_shares_sum` U64 — "Sum of difficulty of
shares acknowledged within this batch."** That field *is* the `v` to credit; the batch boundary *is*
the `Add` invocation point. Reference configs ship `shares_per_minute = 6.0`,
`share_batch_size = 10`, which buys exactly 10×: **7.2 cores at F2Pool's 16,000 miners, 17.8 at
solo.ckpool's 39,592.** For 16,000 miners on a single core, `b ≥ 72`.

**But batching is not privacy-free**, and this is where the real difficulty relocates: the
inter-credit interval leaks hashrate (`interval = b / share_rate`), converting a per-share leak into a
lower-sampled leak of the same quantity. Since Recabarren & Carbunar recover payout predictions from
**the timestamps of the first 50 packets alone**, batch boundaries must be **Poisson-randomized, not
threshold-triggered**. See [[hashrate-inference-side-channels]].

The one-show/multi-show distinction is a **technique** tradeoff, not a proven separation. Kastner–
Loss–Renawi, CCS 2023 p.5: single-show credentials "can bypass heavy tools such as zero-knowledge.
Therefore, single-show credentials are usually far more efficient" — an efficiency claim about
construction, with an explicit causal direction. And the blind-signature impossibility line
(Lindell; Fischlin–Schröder; Pass) is entirely about **round complexity**, blindness, and key
checkability — none of its conditions mention attributes, state, or updates. Citing it for "stateful
is harder" cites a result about *rounds* for a claim about *state*.

## Nearest prior art: Tor PoW micropayments

Biryukov & Pustogarov (FC 2015) is the closest anyone has come — clients mine shares over an
anonymous circuit and get blind-signed tickets. It is also where the ceiling shows: the authors
concede a relay "can learn the **hash rate** of a client, thus it may recognize repeated
connections," and advise clients to *randomize their hash rate*. See
[[hashrate-inference-side-channels]]. **Cryptography can unlink the token from the payout; it
cannot unlink work volume from the connection that submitted it.**

## Adjacent primitives and where each lands

- **Privacy Pass / VOPRF (RFC 9497)** — mature, deployed, and *stateless one-shot*. Excellent for
  the admission decision ("this is an enrolled miner") and useless for accumulation. Every token
  is worth exactly one unit.
- **KVAC / algebraic MACs** — what WabiSabi uses for arbitrary-value credentials; the most
  plausible substrate for a share credential with an amount attached, because it supports
  arbitrary values rather than a fixed ladder. Nobody has applied it to shares.
- **Anonymous Credentials Light (ACL)** — cheap single-show credentials with attributes; a
  reasonable fit for per-slice receipts, and **now proven concurrently secure** in AGM+ROM by
  Kastner–Loss–Renawi (CCS 2023), which matters because a pool runs thousands of sessions in
  parallel. Baldimtsi–Kastner–Loss–Renawi (eprint 2025/161) additionally give a *generic transform*
  lifting blind signatures into attribute-carrying credentials.
- **Bulletproofs** — needed to make a committed balance's range provable without revealing it.
- **Cashu BDHKE (NUT-00/01/02/03)** — deployed, simple, but the mint sees each `amount` at
  issuance and each at redemption. See [[ehash]].

## What breaks in the accounting layer

Two things a blinded credential must reconstruct, and one that survives fine:

- **Share-credit theft (must reconstruct).** The Bedrock mining cookie `C_M = H²(R_M, M.uname)`
  defeats share hijacking *precisely because the username is a PoW input*. Whether the same
  defense holds when the username is replaced by a blinded commitment is **unanalyzed by anyone**
  — the single most important open technical question for this design space.
- **Block withholding (survives fine).** The reflexive objection that a pool needs attribution to
  detect withholding is refuted by the withholding literature itself. See
  [[block-withholding]].
- **Duplicate-share rejection (survives, at a cost).** Cashu's proposal already handles it: the
  mint "MUST treat `header_hash` values as unique payment identifiers." But that means **the mint
  necessarily retains a per-share fingerprint** — a real leak, and the reason "the mint is blind"
  is not literally true even in the most privacy-forward existing design.

## Sources

- [[../../raw/papers/2026-07-29-bba-plus-black-box-wallets|BBA+ / Black-Box Wallets, ROS, Tor PoW micropayments]]
- [[../../raw/repos/2026-07-29-mining-privacy-prior-art-survey|Mining privacy prior-art survey — NUT #293, dbtc #870]]
- [[../../raw/papers/2026-07-29-recabarren-carbunar-hardening-stratum|Hardening Stratum — BiteCoin, mining cookie]]

## See also

- [[ehash]] — the deployed blind-token mining design, and its own stated limits
- [[payout-attribution-privacy]] — why the validator learns weight regardless
- [[coinbase-amount-linkability]] — the on-chain half
- [[self-blinding-architectures]] — non-collusion as the substitute for the impossible
- [[block-withholding]] — the objection that doesn't hold
- [[../topics/self-blinding-pool-design-space|Self-Blinding Pool Design Space]]
- [[hashrate-inference-side-channels|Hashrate Inference Side Channels]]
- [[nullifier-vs-pseudonym|Nullifier vs Pseudonym — why duplicate rejection does not need identity]]
- [[../theses/blinded-share-credit-commitment|Thesis: blinded share-credit commitment]] — the 2026-07-29 verdict round

