---
title: "Thesis: An online-while-mining covenantless Ark boarding SV2 extension (n-of-n batch output, cosigning ceremony triggered post-block-found) is viable on Bitcoin today without CTV/CSFS"
type: thesis
status: investigating
created: 2026-07-17
updated: 2026-07-17
status_note: "verdict rendered 2026-07-17 after 5-agent thesis-mode research round (21 sources)"
verdict: "Partially Supported"
confidence: Medium
core_claim: "A Stratum V2 extension can let mining-pool participants board an Ark — receive VTXOs in an n-of-n batch output — using only primitives live on Bitcoin today (Taproot, MuSig2, relative/absolute timelocks), by triggering the n-of-n cosigning ceremony AFTER a block is found (coinbase outpoint known), with no OP_CTV / OP_CSFS / SIGHASH_ANYPREVOUT soft fork."
key_variables: [post-block-found-ceremony-timing, n-of-n-batch-output, presigned-vtxo-tree, ephemeral-key-deletion, online-while-mining-liveness, no-ctv-csfs-covenantlessness, sv2-extension-surface, coinbase-maturity-reorg]
falsification: "Fails if (a) any spending path REQUIRES CTV/CSFS/APO; or (b) post-block-found signing cannot actually avoid the unknown-txid problem; or (c) n-of-n liveness/griefing at pool scale is operationally unusable (not merely awkward); or (d) coinbase maturity/reorg timing breaks the unilateral-exit guarantee."
---

# Thesis: An online-while-mining covenantless Ark boarding SV2 extension is viable on Bitcoin today without CTV/CSFS

## Core Claim

A **Stratum V2 extension** can let mining-pool participants **board an Ark**
(receive VTXOs inside an n-of-n batch/pool output) using only primitives that are
**live on Bitcoin mainnet today** — Taproot (BIP-341/342), MuSig2 (BIP-327),
and relative/absolute timelocks (CSV/CLTV) — with **no `OP_CTV`, `OP_CSFS`, or
`SIGHASH_ANYPREVOUT`**. Feasibility hinges on **deferring the n-of-n cosigning
ceremony until after a block is found**, at which point the coinbase outpoint is
known and ordinary signatures suffice.

## Key Variables

- **Post-block-found ceremony timing** — signing over a *known* coinbase outpoint instead of presigning over an *unknown* one.
- **n-of-n batch output** — the shared Taproot output whose cooperative key-path spend requires all participants; the covenant substitute.
- **Presigned VTXO tree + ephemeral-key deletion** — clArk's pseudo-covenant; security = 1-of-n honest key deletion.
- **Online-while-mining liveness** — miners are already continuously connected; does that neutralize clArk's synchronous-round liveness cost?
- **No CTV/CSFS covenantlessness** — the hard constraint; every spending path must be expressible today.
- **SV2 extension surface** — message flow layered on the mining connection (à la `demand-share-accounting-ext`); activation, orchestration, dropout.
- **Coinbase maturity / reorg** — 100 blocks (~16.7 h) before the batch input is spendable; reorg invalidates the coinbase.

## Testable Prediction

If the thesis holds: (a) no unactivated opcode appears in any spending path;
(b) the ceremony can complete within the coinbase-maturity window; (c) any
honest participant can unilaterally exit via a presigned timeout path; (d) the
design degrades gracefully (atomic abort + retry) when a cosigner drops.

## Falsification Criteria

The thesis is **contradicted** if any of:
- Any required spending path can only be built with CTV / CSFS / APO.
- Post-block-found signing does not actually escape the unknown-txid / variable-value problem.
- n-of-n liveness or griefing at realistic pool scale (hundreds–thousands of miners) is *operationally unusable*, not merely awkward.
- Coinbase maturity or reorg timing breaks the unilateral-exit guarantee.

## Scope Boundary (bloat filter)

**Not part of this thesis**: general Ark UX; non-mining Ark deployments; PPLNS
payout-fairness math; CTV/APO-*based* mining payout designs (except as the
covenant baseline being avoided); generic SV2 internals unrelated to a cosigning
ceremony; covenant soft-fork activation politics beyond "needed here or not."

> Full reasoning: [[../wiki/topics/thesis-analysis-viability|viability analysis]].

## Evidence For

Sorted strongest first (spec/primary → deployment → engineering-writeup).

- **[Strong]** Post-block-found timing mechanically removes the unknown-txid
  problem. BIP-341 sighash commits to the outpoint; a coinbase txid is unknown
  pre-block but frozen at block-found; so ordinary MuSig2 signatures suffice — no
  APO/CTV. Confirmed by BIP-341 + BIP-118 (what APO buys) + the Braidpool thread
  ("standard Schnorr signing … would require waiting for the actual transaction ID
  before signing can occur"). *(BIP-341, BIP-118, Delving #1370)* → [[../wiki/concepts/post-block-found-signing|post-block-found signing]]
- **[Strong]** Every primitive is live with no soft fork: **MuSig2 (BIP-327) status
  "Deployed"**, n-of-n, Taproot-tweakable; **covenantless Ark on mainnet** (bark,
  2026-06-09); clArk docs say it "can be implemented on bitcoin today." *(BIP-327, bark mainnet, ark-protocol.org)*
- **[Strong]** The covenant substitute is expressible today: batch output
  `pk(S+A+B+…) OR (pk(S) AND after(T))` — n-of-n MuSig2 key-path + CSV/CLTV
  timeout script-path; pseudo-covenant via presign + ephemeral-key deletion (1-of-n
  honest). *(Roose #1528, flock, arkd)* → [[../wiki/concepts/covenantless-batch-output-mechanics|batch output mechanics]]
- **[Moderate]** Deliverable on the SV2 extension surface: formal, negotiated,
  backward-compatible extensions; this repo already ships a **`NewBlockFound` (0x03)**
  per-block trigger; Job Declaration permits a miner-chosen coinbase output. *(sv2-spec, demand-share-accounting-ext)* → [[../wiki/concepts/sv2-extension-surface|SV2 extension surface]]
- **[Moderate]** Real unmet need this targets: **OCEAN/DATUM** does non-custodial
  coinbase payout today but is capped at **~100 payouts/coinbase** (ASIC firmware) —
  a batched n-of-n output is the natural fix. *(OCEAN/DATUM)*

## Evidence Against

- **[Strong]** n-of-n does **not** scale to a pool's miner count. Braidpool:
  "signing very large threshold Schnorr outputs is impractical"; signer set capped
  ~50, not thousands. *(Braidpool spec)*
- **[Strong]** Miners are the **pure-receiver** case clArk is weakest at. One
  no-show forces a full re-round ("just one user each round can keep S from making
  progress"); receivers have nothing at stake and can grief for free; clArk is
  "perfectly secure" only where sender=receiver (self-refresh), the opposite of a
  pool paying independent miners. *(Narula, Roose #1528, ark-protocol.org)* → [[../wiki/concepts/pure-receiver-and-liveness|pure-receiver / liveness]]
- **[Strong]** **Revealed preference** points at covenants/custody: hashpool chose
  custodial ecash; Braidpool chose FROST + a covenant wishlist; the CTV+CSFS letter
  files "non-custodial mining" as covenant-gated; Ark's own team wants CTV to
  "fully eliminate all user interactivity during Ark rounds." *(hashpool, Braidpool, CTV+CSFS letter, Roose #1602)*
- **[Moderate]** Coinbase **maturity + reorg**: if the batch IS the fresh coinbase,
  the tree is non-includable for 100 blocks (~16.7 h) and a reorg voids it — forcing
  a matured-proxy-UTXO design. *(Delving #1370)* → [[../wiki/concepts/coinbase-maturity-and-reorg|maturity & reorg]]

## Nuances & Caveats

- **"Viable" is the overloaded word.** The *architecture* is covenant-free and
  buildable today; the *unqualified* claim of viability at pool scale is not.
- **The liveness objection is mitigable, not fatal.** The online party is the
  **proxy/JDC** (not the ASIC), which can hold the cosigning key; **delegated VTXO
  renewal** shrinks the passive-payee burden; and a miner — unlike an anonymous Ark
  receiver — has identity + hashrate stake + is bannable, blunting the free-DoS
  asymmetry. This is the thesis's strongest original argument and is **unquantified
  in any source** (open gap).
- Every mitigation either **shrinks the effective n** (small signer set) or **leans
  on pool/proxy infrastructure** (pool-as-ASP), trading some trustlessness.
- **Verification ≠ custody.** The existing share-accounting extension is payout
  *accounting*, not an Ark custody layer — the thesis proposes a *new* boarding
  extension alongside it. Do not conflate.
- **No exact prior art** — novel, not proven infeasible.

## Verdict

**Status**: **Partially Supported**
**Confidence**: **Medium**

**Summary**: The cryptographic core is sound and confirmed on today's Bitcoin:
deferring the n-of-n cosigning ceremony to *post-block-found* dissolves the
unknown-coinbase-txid problem that APO/CTV exist to solve, so Taproot + MuSig2 +
timelocks suffice with no soft fork — and every primitive (MuSig2 "Deployed",
covenantless Ark on mainnet, SV2 extensions with a `NewBlockFound` trigger) already
ships. But the unqualified claim of *viability* overreaches: n-of-n interactive
signing does not scale to a pool's miner count (Braidpool caps signers ~50), miners
are the pure-receiver/one-dropout-aborts-all case clArk handles worst, and coinbase
maturity/reorg forces boarding a matured proxy UTXO rather than the fresh coinbase.

**Strongest supporting evidence**: BIP-341 outpoint commitment + coinbase txid
frozen at block-found + Braidpool's own statement that covenants are wanted only to
presign *before* the txid exists (post-block-found simply waits); MuSig2 "Deployed"
and clArk live on mainnet.

**Strongest opposing evidence**: Braidpool's "large threshold Schnorr signing is
impractical" (~50-signer cap); Narula's one-no-show-aborts-all + pure-receiver DoS;
the industry revealed preference for covenants/custody for exactly this use case.

**Key caveats**: "viable" holds at *small signer-set / proxy-delegated* scale, not
as a trustless drop-in for thousands of miners; the online party is the proxy, not
the ASIC; board matured funds, not the fresh coinbase.

**What would change this verdict**:
- A working prototype (even signet) of an SV2 post-block-found cosigning ceremony
  at realistic miner counts → toward Supported.
- A quantitative model showing miner stake + bans neutralizes the receiver-DoS
  asymmetry at scale → toward Supported.
- Evidence that proxy-held keys / pool-as-ASP collapse the trust model to
  "trust-me-pool" → toward Contradicted (viable but not meaningfully non-custodial).

**Suggested follow-up theses**:
1. "Miner identity + hashrate stake + bans neutralize clArk's pure-receiver DoS
   asymmetry, making a pool an admissible Ark round despite paying independent
   receivers." (Tests the thesis's core original claim.)
2. "A proxy/JDC-held cosigning key in an SV2 Ark-boarding extension reduces the
   design to pool-as-ASP custody with unilateral exit — equivalent in trust to a
   statechain, not to self-custody."
3. "Boarding a matured proxy UTXO (not the fresh coinbase) makes post-block-found
   timing unnecessary — the ceremony can run anytime after maturity — collapsing
   the thesis's novelty."
4. "For payout fan-out beyond OCEAN/DATUM's ~100-output ASIC limit, a covenantless
   batched Ark output beats custodial ecash (hashpool) on the trust/scale frontier."

