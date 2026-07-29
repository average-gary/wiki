---
title: "Blinded accumulation cost at real share rates — the Add/Sub mix-up, and why batching makes the accumulator viable"
authors: [Gunnar Hartung, Max Hoffmann, Matthias Nagel, Andy Rupp, Michael Klooß, Markus Raiber, Benedikt Bünz, Jonathan Bootle, Dan Boneh, Andrew Poelstra, Pieter Wuille, Greg Maxwell]
year: 2018
venue: "Multi-source: ACM CCS 2017 pp.1925–1940; PoPETs 2020(1):165–194; IEEE S&P 2018"
source: https://acmccs.github.io/papers/p1925-hartungA.pdf
supporting_sources:
  - https://petsymposium.org/popets/2020/popets-2020-0010.pdf
  - https://web.stanford.edu/~buenz/pubs/bulletproofs.pdf
  - https://solo.ckpool.org/pool/pool.status
type: papers
ingested: 2026-07-29
quality: 5
credibility: high
confidence: high
tags: [bba-plus, black-box-wallets, bulletproofs, range-proof, correction, quantitative, sv2-batching, share-rates, vardiff, thesis-evidence, verbatim-verified]
summary: "Re-derivation of accumulation cost from the primary tables. The wiki's headline BBA+/BBW figures (122ms/182ms/~4kB) are the Sub16,lin SPENDING row, not the Add crediting row — overstating pool-side cost 4.04x. The 16-bit balance limit applies only to redemption, because Add carries no range proof. With SV2's shipped share_batch_size=10 the accumulator needs 7.2 cores at F2Pool scale."
---

# Accumulation cost at real share rates

All figures below extracted with `pdftotext -layout` from PDFs read directly. **Process warning
that explains the earlier fabrication in this wiki:** WebFetch silently fails on image-based PDFs
and returns confident "ABSENT" verdicts — it reported all four Recabarren & Carbunar claims absent
when all four are present. Download and extract; never trust a fetch summarizer on a PDF.

## ★ The core error: the wiki costed crediting with the spending row

This wiki recorded *"Measured at 16-bit balances: **122 ms** user, **182 ms** system, **~4 kB**
communication"* and concluded *"One interactive round trip per credit event (122 ms + 182 ms, ~4 kB).
**At real share rates this is fatal.**"*

**122 / 182 / 3921 B is the `Sub16,lin` row — that is spending (redemption).** The credit operation
is **`Add`: 62 ms user / 45 ms system / 1745 B**. Pool-side cost was overstated **4.04×** and bytes
**2.25×**.

Black-Box Wallets Table 1, **p.179**, verbatim (partial):

| Algorithm | User BBW | User BBA+ | System BBW | System BBA+ | Combined BBW | Combined BBA+ |
|---|---|---|---|---|---|---|
| Issue | 52 | 102 | 20 | 70 | 1005 | 1024 |
| **Add** | **62** | 284 | **45** | 262 | **1745** | 4208 |
| Sub16,lin | 122 | 707 | 182 | 605 | 3921 | 14368 |
| Sub16,log | 475 | – | 234 | – | 3502 | – |
| Sub32,lin | 170 | – | 302 | – | 5039 | – |
| Sub32,log | 870 | – | 389 | – | 3607 | – |

Hardware, §7.1 p.178: *"**Snapdragon 845** (4 × 2.8 GHz & 4 × 1.77 GHz) and running **Android 9**"*,
C++17, RELIC v0.5.0, **Curve25519**. §7.2: *"performed utilizing a **single CPU core** and results are
**averaged over 1000 individual executions**."*

The 122/182/~4 kB numbers *do* appear in BBW's intro (p.166) — *"For 16 bit balances, we estimate a
run-time of 122 ms on the user side… For the system side, we measure a run-time of 182 ms… The total
communication is about 4 kB"* — but that is the paper's headline summary of the **range-proof-bearing
Sub protocol**, which is exactly why it carries the qualifier "for 16 bit balances."

### Why Add is cheaper: it has no range proof

BBW **Fig. 4, p.174**. `Proof P2 (for the Add protocol)` contains only commitment-opening,
signature-opening, and `sk_U·u2 + u1 = t`. **No range proof.** Only `Proof P3 (for the Sub protocol)`
adds *"a **range proof that w − v ∈ V** (using C_RP)."*

**Consequence: the 16-bit balance limit does not bind the accumulation path at all.** It binds
redemption, which happens ~once per payout rather than per share.

## Balance range — the wiki had this backwards

**BBA+ has an effectively unbounded balance and deliberately ships no range proof.** §7.1 p.1939:
*"**p is in the order of 2²⁵⁰**… a user needs to spent about **$10⁷⁵** before a wraparound occurs."*
§8.1: *"we deliberately did not include one in our basic scheme, as even recent range proofs are
still computationally expensive."*

**BBW's real bound is also huge.** p.173: the range proof shows `w − v ∈ V`, *"which is equivalent to
w ≥ v **as long as |Zp| > 2|V|**."* On Curve25519 (p ≈ 2²⁵²), **|V| may be ~2²⁵¹**.

**The 16-bit choice was application-driven, not a technical ceiling.** p.167: *"we note that **16 bit
are already enough for many applications**. For example, the **EU limited anonymous payments to 150
EUR**."*

**Window width, recomputed.** Difficulty verified 2026-07-29 (`blockchain.info/q/getdifficulty` →
`1.26231507121868E14`; mempool.space `currentDifficulty: 126231507121868.2`, hashrate ≈ **872 EH/s**):

```
8 × D = 1,009,852,056,974,944   →  log2 = 49.84  →  50 bits  (Bulletproofs pads to 64)
```

The wiki's `1,009,852,056,974,945` is **off by exactly 1**; "~10¹⁵" and the 50-bit implication are
right. Closing 50→64 bits at redemption costs, per Bulletproofs Table 2 (p.32, secp256k1 via
libsecp256k1, i7-6820HQ throttled to 2.00 GHz, single thread): proof size **546 → 675 B** (+129 B,
1.24×), prove **7.2 → 29 ms** (4.03×), verify **1.4 → 3.9 ms** (2.79×). Size is logarithmic
(`2 log₂(n) + log₂(m) + 4` G elements + 5 Zp), time linear in `n`. Reference point from the same
table: *"verifying an ECDSA signature takes 86 µs on the same system."* At 50 bits vs Curve25519's
~2²⁵² there are **201 bits of headroom** on the `2|V| < |Zp|` condition.

**Width is a solved problem in these papers. It is not the obstacle this wiki presented.**

## Real share rates — one number is measured, not modelled

`solo.ckpool.org/pool/pool.status`, fetched 2026-07-29:

```
Users: 23737, Workers: 39592     hashrate1m: 112P
SPS1m: 5832.5   SPS5m: 5833.7   SPS15m: 5835.1
```

**5,832.5 shares/sec across 39,592 workers = 0.147 sh/s/worker = 8.84 shares/min/worker.** SPS is
raw, not difficulty-weighted (`stratifier.c:8820`).

Vardiff targets, from source: **ckpool** `stratifier.c:6049-6087` — *"Optimal rate product is 0.3"*,
`if (drr > 0.15 && drr < 0.4) return;`, `optimal = lround(dsps * 3.33)` → **0.3 sh/s = 18/min**.
**public-pool** `StratumV1ClientStatistics.ts:5` `TARGET_SUBMISSION_PER_SECOND = 10` (misnamed — it is
seconds-per-share) → **6/min**. **SV2 reference config**: `shares_per_minute = 6.0`.

### Throughput ceiling at the correct `Add` cost (45 ms pool-side ⇒ 22.2 credits/s/core)

| Scenario | shares/s | cores (Add, 45 ms) | cores if using Sub16 (182 ms) |
|---|---|---|---|
| 1 EH/s of S21s @ 6/min | 500 | **22.5** | 91.0 |
| 1 EH/s @ 18/min (ckpool) | 1,500 | **67.5** | 273.0 |
| F2Pool 16,000 miners @ 6/min | 1,600 | **72.0** | 291.2 |
| solo.ckpool **measured** | 5,832.5 | **262.5** | 1,061.5 |
| Foundry-scale 226 EH/s @ 6/min | 112,974 | **5,084** | 20,561 |

Bandwidth is a non-issue: 1,745 B × 5,832.5/s = **10.2 MB/s = 0.081 Gbit/s**.

**Per-miner latency is also a non-issue, and the wiki never checked it.** One token is a serial state
machine — two in-flight `Add`s reuse serial `s` and self-incriminate via `IdentDS` — so a single
miner's ceiling is `1/(62+45+RTT)`: at 50 ms RTT, **382 credits/min** against the 6–18 needed. **The
binding constraint is aggregate pool CPU, not latency and not bytes.**

BBA+ measures no pool-side cost at all. §6 p.1938: *"**The issuer's, accumulator's or verifier's
performance is not measured**, as we expect their hardware to be much more powerful."* BBW says the
same, so a **3–10× server-core speedup** applies to every figure above.

## SV2 batching changes the answer — and the plumbing already exists

**Batched accumulation is natively supported by both papers.** `v` is an arbitrary field element and
cost is independent of its magnitude. BBA+ p.1932: *"To add a (**positive or negative**) **value v**
to the current balance w of a token, the user and the accumulator interact in the scope of the Accum
protocol."* BBA+ p.1931: *"the computational complexity of all operations as well as the token size is
**independent of the number of points to be transferred or stored**."* BBW Fig. 6 p.174: AC *"adds his
share s″ to the new serial number as well as **the amount of points collected v** to the balance in
C′ (again using the homomorphic property of PC)"* — one commitment, one BlindSign, regardless of the
magnitude of `v`.

**Neither paper restricts `v` to 1 or to a denomination.** This wiki never stated that, and it is the
single most important fact for the thesis: it is what separates BBA+ from Cashu's denomination ladder.

**SV2 already batches at exactly the right granularity.** `sv2-spec`
`05-Mining-Protocol.md` §5.3.13 `SubmitShares.Success`: *"Because it is a common case that shares
submission is successful, this response can be provided for **multiple SubmitShare messages
aggregated together**"*, with `last_sequence_number`, `new_submits_accepted_count`, and
**`new_shares_sum` U64 — "Sum of difficulty of shares acknowledged within this batch"**. Reference
configs (`sv2-apps`, unanimous): `shares_per_minute = 6.0`, `share_batch_size = 10`.

**`new_shares_sum` *is* the `v` to credit; the batch boundary *is* the `Add` invocation point.**

| Miners | credits/s | cores (Add) | GB/day |
|---|---|---|---|
| 1,000 | 10.0 | **0.45** | 1.51 |
| 16,000 (F2Pool) | 160.0 | **7.2** | 24.1 |
| 39,592 (solo.ckpool) | 395.9 | **17.8** | 59.7 |
| 100,000 | 1,000.0 | **45.0** | 150.8 |

Batching by 10 buys exactly 10×. Required batch size for a CPU budget of `C` cores:
`b ≥ miners × spm × 0.045 / (60C)`. For **16,000 miners on 1 core, b ≥ 72** (one credit per
12 min/miner). Foundry-scale on 4 cores needs `b ≥ 1,271`.

**Batching is not privacy-free.** The inter-credit interval leaks hashrate
(`interval = b / share_rate`), so a fixed `b` converts a per-share leak into a lower-sampled leak of
the same quantity. Since Recabarren & Carbunar recover 0.53–34.4 % payout-prediction error from **the
timestamps of the first 50 packets alone**, batch boundaries must be **Poisson/randomized, not
threshold-triggered**. See [[../../wiki/concepts/hashrate-inference-side-channels|Hashrate Inference
Side Channels]].

## Sub-claim E: the blinded-payout baseline, quantified

Output sizes verified against BIP141, BIP341, BIP16 and Optech's calc-size: **P2WPKH 31 B, P2SH 32 B,
P2PKH 34 B, P2TR/P2WSH 43 B** per output (8 value + 1 len + script); each byte = 4 WU. BIP32
`CKDpub` = *"**HMAC-SHA512**(Key = c_par, Data = ser_P(K_par) ‖ ser32(i))"* then
*"point(parse_256(I_L)) + K_par"* — one HMAC plus one point addition.

| | blinded **PAYOUT** | blinded **CREDIT** |
|---|---|---|
| Compute | ~15 µs (1 BIP32 derivation) | 45 ms pool-side (BBW `Add`) |
| Interaction | **none** — offline, non-interactive | 4–5 round trips, online 2-party |
| Data | 43 B on-chain, amortized into one tx | 1,745 B off-chain per event |
| Concurrency | unlimited, embarrassingly parallel | **serial per token** |

**≈900× in compute, ≈41× in bytes, and — decisively — non-interactive vs interactive.** Observed
real cost: OCEAN's 72-output coinbase = 9,792 WU ≈ **0.22 % of a block**, against Foundry's 2-output
796 WU. **Sub-claim E is quantitatively supported, but the dominant term is *interactivity*, not
arithmetic.**

**DATUM's ~380–530 output cap — verified verbatim in source**, `datum_stratum.h:155`:
`// 4 = "huge" --- max 16kB --- this is probably the most we should reasonably attempt to do in the
coinbase... something like 380 to 530 outputs, depending on the type of output`, with
`available_coinbase_outputs[512]` at `:145`. Independently confirmed: 16,384 ÷ 43 (P2TR) = 381;
16,384 ÷ 31 (P2WPKH) = 528 — **the real constraint is a byte budget, not a count**. Vendor budgets
enforced in `datum_coinbaser.c:700-726`: 500 / 755 / 2250 / 6500 / 16000 B.

## Other corrections this read forces

- **BBA+ has 4 authors, not 7.** *BBA+: Improving the Security and Applicability of
  Privacy-Preserving Point Collection* — **Gunnar Hartung, Max Hoffmann, Matthias Nagel, Andy Rupp**,
  ACM CCS 2017 pp.1925–1940. This wiki listed "Hartung, Kaidel, Koch, Koch & Rupp" — **"Kaidel" and
  the two "Koch"s do not appear on the paper.** Another instance of the same fabrication hazard.
- **"One interactive round trip per credit event" understates it.** Counting BBW Fig. 6 (Add) +
  Fig. 4 (P2 Σ-protocol) + Fig. 8 (BlindSign, 3 messages): **≈9 application-layer messages ≈ 4–5
  round trips.**
- **Interactivity cannot be Fiat–Shamir'd away.** BBW p.166 removes BBA+'s trapdoor *"by relying on
  **interactive proof systems, where standard rewinding techniques replace the trapdoor**."* Dropping
  interactivity reinstates the TTP trapdoor — the very thing that made BBA+ unsuitable for a pool.
- **BBA+ forbids concurrent oracle calls per user**, p.1936: *"for each user **no oracle can be called
  concurrently**, i.e. for any arbitrary but fixed pk_U another oracle can only be invoked if no
  previous oracle call for the same pk_U is still pending."*
- **"<400 ms on 254-bit Barreto–Naehrig" — verified**, §6.2 p.1939, with BBA+ Table 1 p.1938 giving
  `Issue 115.27 / Acc 385.61 / Vrfy 375.73` ms user-side on a **OnePlus 3 / Snapdragon 820**.
- **BBW's own claimed "5.6×" does not reproduce from its Table 1** (Add gives 4.58× user, 5.82×
  system, 5.10× combined). Paper-internal imprecision; flag if cited.

## Verdict for the thesis

**Feasible only batched — but the batching threshold is ~4× lower than this wiki implied, and even
per-share credit is not the impossibility it was called.**

Per-share at the correct cost: 22.5 cores for 1 EH/s, 72 cores at F2Pool's 16,000 miners, 262 cores at
solo.ckpool's measured rate. Expensive and absurd next to a hash comparison (~µs), but **a few racks
— not "fatal."** With a server-core speedup, F2Pool scale is ~7–24 cores. Only at Foundry scale
(5,084 cores) does it become genuinely infeasible. Batched at SV2's shipped `share_batch_size = 10`:
**0.45 cores for 1,000 miners, 7.2 for 16,000, 17.8 for 39,592.** Comfortable.

**The miner-carried-accumulator horn is practically viable in batched form**, and far less exotic than
framed: the batch boundary is an existing SV2 message, the credited value is an existing SV2 field,
and both papers support arbitrary-magnitude `v` at constant cost. The thesis's *structural* claim
survives — you still need a pool-side pseudonym or a miner-carried accumulator, and the accumulator
remains an interactive online 2-party protocol against a non-interactive offline derivation, so
**"strictly harder than blinded payout" holds on the interactivity axis.** But two of the three
quantitative arguments this wiki used to make it *hard* are wrong. **What remains is a privacy
problem, not a throughput one:** batch boundaries leak hashrate, and R&C show timing alone suffices.

## Not verified

- **eprint.iacr.org is Cloudflare-gated**; Bulletproofs read from the **Stanford author mirror**
  (verified by title/author page, not a Wayback capture).
- **No published µs/op figure for BIP32/secp256k1 derivation exists** upstream — libsecp256k1
  benchmarks aren't committed. The ~15 µs is a **local, unpublished measurement**; do not cite it.
- **Ocean TIDES docs unreachable** (`docs.ocean.xyz` DNS failure). The `8 × D` window, "99.9665 %" and
  "~8 reward events" figures rest on **a single unreplicated fetch** — medium confidence.
- **DATUM vendor byte limits are the authors' own empirical claims** (*"tested"* / *"appear to
  support"*), not vendor documentation; the comments also disagree with the code (730/750 vs enforced
  755).
- **Worker counts for any large commercial pool** — mempool.space reports blocks and hashrate only.
  The Foundry-scale figure is **derived from block share** (261/1008 blocks = 25.9 % × 872 EH/s), not
  a reported worker count.

## See also

- [[2026-07-29-bba-plus-black-box-wallets|BBA+ / Black-Box Wallets ingest]] — the file carrying the
  Add/Sub mix-up and the author-list error
- [[2026-07-29-stateful-vs-oneshot-credentials-no-separation|No separation, and two retracted
  blockers]] — the companion correction
- [[../../wiki/concepts/blind-share-accounting|Blind Share Accounting]]
- [[../../wiki/theses/blinded-share-credit-commitment|Thesis: blinded share-credit commitment]]
