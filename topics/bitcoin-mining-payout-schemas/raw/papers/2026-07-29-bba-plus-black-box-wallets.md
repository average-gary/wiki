---
title: "BBA+ / Black-Box Wallets — privacy-preserving accumulation of a quantitative balance"
authors: [Gunnar Hartung, Max Hoffmann, Matthias Nagel, Andy Rupp, Michael Klooß, Markus Raiber]
year: 2017-2020
venue: "ACM CCS 2017 (BBA+) / PoPETs 2020(1):165–194 (Black-Box Wallets)"
source: https://acmccs.github.io/papers/p1925-hartungA.pdf
supporting_sources:
  - https://petsymposium.org/popets/2020/popets-2020-0010.pdf
  - https://cs.brown.edu/people/fbaldimt/papers/CCS13.pdf
  - https://eprint.iacr.org/2020/945
  - https://eprint.iacr.org/2013/516
type: papers
ingested: 2026-07-29
quality: 5
credibility: high
confidence: high
tags: [BBA+, black-box-accumulation, anonymous-credentials, acl, kvac, ros-attack, blind-schnorr, double-spend-tag, share-weight, primary]
summary: "Searched result: of all the blind-credential families, **only Black-Box Accumulation natively supports \"credit a running quantity to an anonymous party, prevent inflation, without per-user records.\"** Cashu and Privacy Pass are one-shot and denominated; KVAC, ACL, and BBS+ carry attributes but have **no increment operation**."
---

# Black-Box Accumulation (BBA+ / BBW) — the only primitive that natively accumulates weight

Searched result: of all the blind-credential families, **only Black-Box Accumulation natively
supports "credit a running quantity to an anonymous party, prevent inflation, without
per-user records."** Cashu and Privacy Pass are one-shot and denominated; KVAC, ACL, and
BBS+ carry attributes but have **no increment operation**. This is the closest cryptographic
match to accumulating share difficulty.

Note on provenance: BBA+ / BBW / ACL / Tor-micropayment claims below were verified against
the primary PDFs, not a fetch summarizer (an initial automated summary of BBA+ fabricated a
paper title and a table of round performance numbers, and was discarded).

> **Correction notice, 2026-07-29.** A re-read against the primary tables found **four further
> errors in this file**, two of them load-bearing: the performance figures below described the
> **spending** protocol while being presented as the cost of **crediting** (4.04× overstatement of
> pool-side cost), the range-proof limitation was attributed to the wrong protocol path, and the
> author list carried **fabricated names** — the same hazard this note warns about, one level deeper.
> Corrections are inline. See
> [[2026-07-29-blinded-accumulation-cost-at-real-share-rates|the quantitative re-read]] and
> [[2026-07-29-stateful-vs-oneshot-credentials-no-separation|the separations read]].
>
> **Mechanism identified:** WebFetch silently fails on image-based PDFs and returns confident
> "ABSENT" verdicts. Always download and `pdftotext -layout`.

## The mechanism — a cryptographic piggy bank

A token is a **multi-commitment `c` to (sk_U, version `s`, balance `w`, randomness `u1`) plus
an issuer signature `σ` on `c`.**

To credit weight `v`:

1. User sends a **fresh commitment `c'`** carrying the same `sk_U`, the same `w`, a **new**
   version `s'`, new randomness, and a ZK proof that `c'` is a correctly re-randomized
   version of his signed `c`.
2. The **accumulator applies `+v` homomorphically** to `c'` and signs the result.

The user never performs the addition, so **inflation is impossible by construction**. The
only available cheat is **rollback** — replaying an older, higher-balance state.

Rollback is caught by a **double-spending tag** `t := sk_U·u2 + u1 mod p` with a
verifier-chosen challenge `u2`. Two uses of the same version `s` under different challenges
yield `t, t'` and `u2, u2'`, from which `sk_U = (t−t')·(u2−u2')⁻¹ mod p` — extracting the
cheater's identity. `VerifyGuilt` checks `g₁^Π = pk_U`.

**The property that makes share-weight accumulation viable at all** — BBA+ p.1931, verbatim: "the
computational complexity of all operations as well as the token size is **independent of the number of
points to be transferred or stored**." (This file previously gave a close paraphrase as a quote.)

**And the corollary this file omitted, which is the most important fact for the thesis:** `v` is an
**arbitrary field element**, positive or negative, at constant cost — BBA+ p.1932: "To add a
(**positive or negative**) **value v** to the current balance w of a token…". Neither paper restricts
`v` to 1 or to a denomination ladder. **That is precisely what separates BBA+ from Cashu**, and it
means batched crediting is native, not a workaround.

## Instantiations and cost

**BBA+** (CCS 2017, pp.1925–1940 — **4 authors: Hartung, Hoffmann, Nagel, Rupp**; this file
previously listed 7, including the fabricated "Kaidel" and two "Koch"s): bilinear group under SXDH;
Groth–Sahai F-extractable NIZKs; equivocal F'-binding homomorphic commitment over `Z_p⁴`;
structure-preserving EUF-CMA signature over `G₂`; IND-CPA ElGamal hidden user ID. All protocols
**<400 ms** client-side on 254-bit Barreto–Naehrig curves (Table 1, p.1938, OnePlus 3 / Snapdragon
820: `Issue 115.27 / Acc 385.61 / Vrfy 375.73` ms). Adds over BBA: offline operation (no permanent
serial-number DB), enforced negative points, balance-binding, and forward/backward privacy even with
all secret keys leaked.

**BBA+ measures no pool-side cost at all** — §6, p.1938: "**The issuer's, accumulator's or verifier's
performance is not measured**, as we expect their hardware to be much more powerful." And it
**forbids concurrency per user** (p.1936): "for each user **no oracle can be called concurrently**."

**BBA+ has an effectively unbounded balance and ships no range proof by choice.** §7.1 p.1939: "**p is
in the order of 2²⁵⁰**… a user needs to spent about **$10⁷⁵** before a wraparound occurs." §8.1: "we
deliberately did not include one in our basic scheme, as even recent range proofs are still
computationally expensive."

**Black-Box Wallets** (PoPETs 2020, article **0010** — note popets-2020-0007 is a *different*
DP paper): switches from "commit-sign-prove" to **"commit-then-blind-sign"** with modified
Baldimtsi–Lysyanskaya (ACL) blind signatures, **drops pairing groups entirely**, and adds
**Bulletproofs range proofs**.

~~Measured at 16-bit balances: **122 ms** user, **182 ms** system, **~4 kB** communication.~~
**CORRECTED 2026-07-29 — those are the `Sub16,lin` (spending) figures, presented here as the cost of
crediting.** Table 1, p.179, Snapdragon 845 / Curve25519 / single core / 1000-run average:

| Algorithm | User | System | Combined bytes |
|---|---|---|---|
| Issue | 52 ms | 20 ms | 1005 |
| **Add** (crediting) | **62 ms** | **45 ms** | **1745** |
| Sub16,lin (spending) | 122 ms | 182 ms | 3921 |

**Pool-side crediting is 45 ms, not 182 ms** — a 4.04× overstatement, and 2.25× on bytes. The
122/182/4 kB numbers do appear in BBW's intro p.166, but as the paper's headline summary of the
**range-proof-bearing Sub protocol**, which is why they carry "for 16 bit balances."

Collection 5.6× faster than BBA+ with half the data; spending 6× faster — quoted correctly from
p.166, though **5.6× does not reproduce from BBW's own Table 1** (4.58× user / 5.82× system / 5.10×
combined). Paper-internal imprecision; flag if cited.

## Failure modes that bear directly on a mining pool

1. **~~One interactive round trip per credit event (122 ms + 182 ms, ~4 kB). At real share rates this
   is fatal.~~ → CORRECTED, twice over.** (a) The cost is `Add`: **62 ms user / 45 ms system /
   1745 B**, not the Sub row. (b) It is **not one round trip** — counting Fig. 6 (Add) + Fig. 4 (P2
   Σ-protocol) + Fig. 8 (BlindSign, 3 messages) gives **≈9 messages ≈ 4–5 round trips**. (c) "Fatal"
   is unsupported: at 45 ms pool-side (22.2 credits/s/core) per-share crediting needs **72 cores at
   F2Pool's 16,000 miners** and 262 cores at solo.ckpool's *measured* 5,832.5 shares/s — expensive,
   but a few racks, and both papers note the server side is expected to be far faster than the
   measured phone. It is genuinely infeasible only at Foundry scale (~5,084 cores). **Batched at
   SV2's shipped `share_batch_size = 10`: 7.2 cores at F2Pool scale.** Weight should still be credited
   in windows/batches — the conclusion survives, the arithmetic behind it did not.
   Note also that interactivity **cannot be Fiat–Shamir'd away**: BBW p.166 removes BBA+'s trapdoor
   "by relying on **interactive proof systems, where standard rewinding techniques replace the
   trapdoor**," so a non-interactive variant reinstates the TTP.
2. **BBA+ reveals `w` in cleartext at redemption**, which BBW calls out as a tracking vector.
   ~~BBW fixes it with range proofs, but its prototype is **16-bit balances**… Cumulative share
   difficulty needs far wider range.~~ **CORRECTED: the 16-bit limit does not touch the accumulation
   path.** BBW Fig. 4, p.174: `Proof P2 (for the Add protocol)` contains **no range proof** — only
   `Proof P3 (for Sub)` adds "a **range proof that w − v ∈ V**". So the width constraint binds
   *redemption*, which happens ~once per payout, not per share. The real bound is `2|V| < |Zp|`
   (p.173), i.e. **|V| up to ~2²⁵¹** on Curve25519 — against ~50 bits needed for an `8 × D` window,
   leaving 201 bits of headroom. And 16-bit was an *application* choice, not a ceiling (p.167: "**16
   bit are already enough for many applications**… the **EU limited anonymous payments to 150 EUR**").
   Closing 50→64 bits costs **+129 B and +21.8 ms of proving** by Bulletproofs' own Table 2.
3. **Double-spend defence is punitive, not preventive** — it identifies the cheater
   afterwards, which presumes something seizable. Against an anonymous hashrate seller there
   may be nothing. Also needs a spent-serial DB; BBW bounds it with expiry attributes so old
   records can be deleted.
4. **~~The Canard–Gouget impossibility is the structural killer~~ → RETRACTED 2026-07-29, and the
   sign was backwards. This entry propagated across eight files.** Note the irony: **this very file
   already contained the disproof two lines down** (BBW removes the trapdoor) and the round shipped
   the claim anyway.
   The invocation is a *single sentence* on BBW p.3, inside a paragraph **rejecting transferable
   e-cash** as an alternative construction — *"Using transferable e-cash such as [4] … However, an
   impossibility result by Canard and Gouget [12] implies, that if the issuer, accumulator, and
   verifier collude, transactions can be linked."* That is BBW's reason for **not** taking that route.
   **The BBA line's actual position is the opposite of "structural killer":** Faller et al. (IMACC
   2021, eprint 2021/1303) cite the same result as the reason *"**A BBA issuer and an accumulator can
   collude without breaking privacy. This is necessary due to an impossibility result**, cf. [12]"*,
   and merge the roles into "**the operator**" (§2.1). BBA+ p.1933 proves unlinkability against *"a
   collusion of I, AC, and V"*. BBW's Def 4.1 shares `sk_I` across all three and proves Def 3.4
   against `MalIssue/MalAcc/MalVer` oracles.
   Scope: the impossible notion is **Perfect Anonymity** (*"PA cannot be achieved if the bank is
   itself a possible adversary"*), one level *above* full unlinkability, and its predicate is
   recognizing a coin you previously owned once it returns — **transfer between users**, which a pool
   never does. Ref [12] (*"Anonymity in Transferable E-Cash,"* ACNS 2008 pp.207–223) is **paywalled
   and unread**; four independent restatements agree on scope. Simulation-linkability (Thm 5.2) needs
   **no** TTP — p.171: *"there is no trapdoor anymore… **without a trusted third party**."* The
   "coins must grow" result is **Chaum–Pedersen, EUROCRYPT '92**, and also scopes to transferability.
   See [[2026-07-29-stateful-vs-oneshot-credentials-no-separation|the correcting read]].
5. **~~ACL as published is only sequentially secure~~ → STALE.** The sentence quoted from ACL's own
   paper is accurate, but the open problem has since been **closed by others**:
   Kastner–Loss–Renawi (CCS 2023, eprint 2023/707) prove ACL **concurrently secure** in AGM+ROM
   (Cor. 4.2). The ROS authors also **retracted** their claimed attack on ACL (2020/945 p.4: *"our
   claimed attack on [BL13] relied on an incorrect verification equation and do not apply to
   [BL13]"*). BBW's modified signature remains sound; it is simply no longer the only route.

## Adjacent primitives, and why they don't fit

- **KVAC (CMZ13, eprint 2013/516)**: issuer == verifier, which matches a pool exactly and is
  where the efficiency comes from (algebraic MACs instead of public-key signatures; MAC_GGM
  in the generic group model, MAC_DDH under DDH; "many times faster than Idemix"). But there
  is **no increment operation** — updating a balance means re-issuance, and each re-issuance
  is a fresh linkage point unless separately blinded.
- **ACL (CCS 2013)**: blind signatures with attributes; **explicitly single-use** — "Alice
  can be traced if she tries to get two free movies using the same single-use credential more
  than once." 576-bit signatures at 128-bit security vs 3072-bit CL keys.
- **Blind Schnorr on secp256k1 — do not.** The ROS paper (eprint 2020/945) gives a
  polynomial-time attack "for `l > log p` dimensions," breaking "Schnorr and Okamoto–Schnorr
  blind signatures, threshold signatures such as GJKR and the original version of FROST,
  multisignatures such as CoSI and the two-round version of MuSig, partially blind signatures
  such as **Abe-Okamoto**." ~~For a 256-bit group that is on the order of **~256 concurrent
  sessions**.~~ **Corrected 2026-07-29:** 256 is the threshold for the *seconds-long* Sage attack.
  The paper's §7 (p.17) gives the practical figure as **ℓ = 9** parallel open sessions today
  (ℓ = 16 → ~2⁵⁵ work; ℓ = 128 → ~2³²). **Nine, not 256** — the conclusion is unchanged and the
  margin is ~28× worse than recorded here.
- **Privacy Pass / VOPRF (RFC 9497)**: tokens are unweighted and one-shot, so weight N means
  N tokens and **the count itself is the leak**. RFC 9497 states there is no unlinkability
  across multiple evaluations of the same input; static-DH attacks cost `log₂(Q)/2` bits.

## Closest existing mining-adjacent prior art

Biryukov & Pustogarov, *Proof-of-Work as Anonymous Micropayment: Rewarding a Tor Relay*
(FC 2015, eprint 2014/1011): Tor clients mine PoW shares, submit them to a relay over an
anonymous circuit, and receive **relay-specific priority tickets** blind-signed over
`{H(x), d}` with day-granularity `d` so "all clients that got tickets on the same day
[are] undistinguishable." Difficulty is the metering knob — the relay "may regulate how many
tickets are issued to different clients, **proportional to their mining power**."

One-shot and denominated, not accumulating. Double-spend prevention via a spent-ticket
history bounded by 48-hour expiry.

**Its stated privacy limitation is the one no cryptographic primitive fixes**: "A curious
relay can however learn the **hash rate** of a client, thus it may recognize repeated
connections from the same client. In order to mitigate such an attack a client is advised to
**randomize its hash rate**." Submitted work volume is itself a fingerprint.

## Negative result

**No literature exists on ZK proofs of accumulated mining-share contribution**, no
ZK-friendly accumulator for PoW-share aggregation, and no privacy-preserving PPLNS research.
Searches returned only SEO spam. Genuinely unexplored territory; the Tor ticket scheme is the
nearest prior art and it does not accumulate.
