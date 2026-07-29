---
title: Self-Blinding Pool Design Space
category: topic
created: 2026-07-29
confidence: high
tags: [self-blinding, attribution, xpub, tides, pplns-jd, ohttp, bba-plus, synthesis, open-problem]
volatility: warm
updated: 2026-07-29
summary: "Synthesis: can a TIDES/PPLNS-JD pool take a miner-supplied xpub and then structurally avoid retaining attribution? The xpub half is buildable; the blindness half is bounded by the fact that a pool's knowledge comes from validating shares, not from paying them."
verified: 2026-07-29
sources:
  - "raw/repos/2026-07-29-pool-identity-vs-payout-script-conflation-code-read.md"
  - "raw/repos/2026-07-29-bip352-silent-payments-coinbase-incompatibility.md"
  - "raw/papers/2026-07-29-recabarren-carbunar-hardening-stratum.md"
  - "raw/papers/2026-07-29-romiti-2019-mining-pool-payout-deanonymization.md"
  - "raw/papers/2026-07-29-bba-plus-black-box-wallets.md"
  - "raw/papers/2026-07-29-maurer-2017-knapsack-coinjoin-arbitrary-values.md"
  - "raw/papers/2026-07-29-withholding-detection-does-not-need-attribution.md"
  - "raw/notes/2026-07-29-self-blinding-system-architectures.md"
  - "raw/notes/2026-07-29-fincen-td10000-regulatory-attribution-posture.md"
  - "raw/repos/2026-07-29-mining-privacy-prior-art-survey.md"
---

# Self-Blinding Pool Design Space

The question: *do TIDES/PPLNS-JD but the miner supplies an xpub — and since payout amounts and
shares would still be attributable by the operator, how could a service prevent storing that
attribution, or blind itself to it?*

**The premise is correct and sharper than stated.** The reason is not the payout amounts:

> **A pool's attribution knowledge derives from share *validation*, not from *payment*.** By the
> time any satoshi moves, the pool has already recomputed every share header, assigned every
> target, timestamped every arrival, and can infer hashrate to within a few percent. Blinding the
> payout rail — a derived address, a BOLT12 offer, an ecash token — defends against **third-party
> chain observers**, not against the operator.

So the question splits into two problems of very different difficulty:

| | Problem | Status |
|---|---|---|
| **A** | Unlink miner identity from the payout output | **Tractable and mostly unbuilt.** Wildcard descriptors work today; the blockers are field widths and ledger keys, not cryptography. |
| **B** | Prevent the operator from learning per-unit work volume | **No known solution, but the reason changed 2026-07-29.** The impossibility result formerly cited against single operators is a misattribution (see below); the surviving obstacles are quantitative — range-proof width, per-share round-trips, and the hashrate side channel, which no cryptography fixes. |

## Part A — the xpub half

Buildable. See [[../concepts/xpub-payout-identity|xpub Payout Identity]] for the mechanics. The
short version:

- **BIP 32 xpubs and BIP 380 wildcard descriptors work.** **BIP 352 silent payments cannot** — a
  coinbase has `vin.size() == 1` with a null prevout by consensus, so there is no input private key
  `a`, so no ECDH shared secret. Zero occurrences of "coinbase" in BIP 352's 524 lines; no proposal
  anywhere for a coinbase-specific tweak substitute. This is structural, not unimplemented.
- **PPLNS-JD is the natural host.** Its ledger key is `(slice, share_index)` — positional, with
  **zero identity fields**. Identity lives only in SV2 `user_identity`. TIDES is harder: the
  coinbase is precomputed at *work-issue* time, so a derivation is needed per miner per template.
  ckpool is hardest — `username[128]` is both the hash key and the source of `txnbin[48]`, so the
  username literally *is* the scriptPubKey.
- **The real work is a two-way split of identity**: a stable ledger key (descriptor, or its
  fingerprint) and a rotating derived script for the coinbase. Any balance table doing
  `ON CONFLICT (address)` silently breaks credit carry-forward the moment addresses rotate.
- **The unresolved question is the rotation trigger**, and it is unresolved *upstream*. SV2 #697:
  "The tricky part here is to decide when to rotate." Greg Maxwell's blockheight-as-index is
  self-synchronizing but collides with BIP 44's gap limit of **20**.
- **Ceilings are firmware, not consensus**: DATUM caps at ~380–530 coinbase outputs; Avalon
  truncates usernames at 63 chars and **Whatsminer buffer-overflows past 127**.
- **Confirmed negative result**: no pool anywhere accepts an xpub, descriptor, or payment code as a
  miner's payout identity — verified against ckpool, public-pool, DATUM, the SV2 reference apps, and
  Ocean's docs.

**What Part A buys**: it defeats the attack that actually works. Romiti et al. identified **92 % of
BTC.com miners, 75 % of ViaBTC, 30 % of AntPool** from public chain data with no pool cooperation,
and the driver was payout-address reuse (median 20 / 5 / 2 respectively). **What it does not buy**:
any reduction in operator knowledge. Worse, the pool now holds the descriptor that links all of a
miner's rotated addresses together.

## Part B — the blinding half

### What amounts actually leak

The sum constraint the question raises is **near-vacuous against the pool and sharp against a chain
observer**. The pool computed the sum; it knows every addend already. But for a chain observer,
`aᵢ / Σaⱼ` is miner *i*'s **exact** relative share weight, and `N` bounds the anonymity set. A
blinded scheme can hide *who* but not the **distribution shape** — which is what Romiti et al.'s
Gini coefficients of 0.938–0.945 are.

And the coinbase is the **worst** case: determining the input→output mapping "is equal to solving
the subset sum problem," except a coinbase has one input of publicly known value, **no input
shuffling** (half the CoinJoin ambiguity budget is structurally absent), and **no ability to pad**
— the output sum is consensus-bounded by subsidy + fees, so every decoy satoshi comes out of a real
miner. Output splitting works but "requires knowledge of all sub-transactions," and in a pool **the
splitter is the pool** — it cannot blind the operator to itself. Denomination ladders bound the leak
to bucket resolution rather than removing it. See
[[../concepts/coinbase-amount-linkability|Coinbase Amount Linkability]].

### The primitive that fits, and why it's blocked

PPLNS credit is a **running weighted sum over a sliding window**; every deployed Bitcoin privacy
primitive is a **one-shot denominated bearer object**. Cashu-style ecash cannot express continuous
share weight without either rounding to a power-of-two ladder or — as vnprc put it — linking tokens
to shares and "in the process… destroy[ing] the privacy properties of ecash."

**BBA+ / Black-Box Wallets** is the only primitive designed for this shape: an unlinkable token
carrying a quantitative balance that a third party increments homomorphically. The user never
performs the addition, so inflation is impossible; token size is independent of points accumulated;
rollback is punished by extracting `sk_U = (t−t')·(u2−u2')⁻¹`. Its blockers, in order of severity:

1. **Range — now the top blocker.** The Black-Box Wallets prototype carries a **16-bit** balance; a
   TIDES window spans `8 × network_difficulty` in diff-1 shares (~10¹⁵ today, ~50 bits).
   Bulletproofs close this in principle; nobody has built it.
2. **secp256k1 blind Schnorr is unusable** — the ROS attack breaks it (and blind FROST/MuSig). Not
   at ~256 concurrent sessions as recorded here previously but at **ℓ = 9** by the paper's own §7,
   and a pool has far more. Use RSA blind signatures, BDHKE, or KVAC.
3. **Per-accumulation round-trips** at real share rates — weight must be credited in windows or
   batches, not per share.
4. **No mining-specific construction exists.** Confirmed: no literature on ZK proofs of accumulated
   mining-share contribution; no BIP; no SV2 extension.
5. **~~The Canard–Gouget impossibility~~ → RETRACTED 2026-07-29**, and it was previously #1 on this
   list with the prescription **backwards**. This section said "Role separation across non-colluding
   parties is not an optimization here — it is the requirement." The BBA literature says the reverse:
   Faller et al. (IMACC 2021) cite Canard–Gouget as the reason *"**A BBA issuer and an accumulator can
   collude without breaking privacy. This is necessary due to an impossibility result**"*, and refer to
   the merged roles as "**the operator**". BBA+ p.1933 proves unlinkability against *"a collusion of
   I, AC, and V"*; BBW shares `sk_I` across all three and removes the TTP trapdoor entirely (p.171:
   *"there is no trapdoor anymore, it is possible to set up our scheme **without a trusted third
   party**"*). The impossible notion is **Perfect** Anonymity, one level above full unlinkability, and
   scopes to **coin transfer between users** — never satisfied by a pool that increments weight
   itself. The ACNS 2008 paper is paywalled and unread; four independent restatements agree on scope.
   **Role separation is defense-in-depth, not a cryptographic requirement**, which materially changes
   Part B's difficulty: the obstacles are all quantitative. Relatedly, no theorem anywhere makes
   stateful accumulation harder than one-shot issuance — two measured constructions put an update at
   ~1.2–1.4× an issuance.

See [[../concepts/blind-share-accounting|Blind Share Accounting]].

### The architectures that do transfer

From [[../concepts/self-blinding-architectures|Self-Blinding Architectures]], ranked:

1. **Split-trust relay for share submission** (RFC 9458 OHTTP; iCloud Private Relay) — pool sees the
   share and the payout script, never the submitting IP. Requires relay and pool to be
   non-colluding and not co-owned. **Caveat that bites hardest here**: OHTTP "removes linkage at the
   transport layer, which is only useful for an application that does not carry state between
   requests" — and **a payout address is persistent state.**
2. **Blind-signature admission credentials** — prove "enrolled, paid-up, non-abusive miner" without
   learning which one. Private Relay's production shape: one-time RSA blind-sig tokens, daily
   rotation, asynchronous double-spend detection, per-day rate limits.
3. **Multi-vendor TEE trust splitting** (SVR3: t=2 of n=3 across SGX/Azure, SEV-SNP/GCP,
   Nitro/AWS, at $0.0025/user/year) — for holding an attribution table. But SVR3 itself states it
   "does not hide the identity of clients or the timing of… requests," so it layers *under* #1/#2,
   never instead.
4. **Client-enforced transparency** — the highest-leverage item on the list and the cheapest:
   PCC's rule that the device "wraps request payload key **only to PCC nodes whose attested
   measurements match logged releases**," and Private Relay's raw-public-key pinning against a
   separately distributed config rather than the web PKI. **Worth more to a blind pool than the
   enclave it protects.**
5. **Not private aggregation.** Prio/DAP hide individual inputs and reveal a population total; a
   pool needs the opposite axis — exact per-recipient totals with only the link hidden. Prio also
   has privacy with 1-of-s honest but **robustness only if all servers are honest**, and imports
   selective-DoS and intersection attacks that bite hardest on a system publishing exact numbers
   every block. Keep DP away from balances entirely: money must be exact.

Note that attestation is weaker than advertised — SGAxe extracted Intel's production attestation
key while the victim enclave was **idle**; ÆPIC Leak did it "within a few seconds" without a side
channel; and the CVM SoK finds that "**all major cloud providers retain control over critical parts
of the trusted software stack**… This directly contradicts their claims." Nitro Enclaves is excluded
from that analysis entirely because AWS is both hardware vendor and cloud provider.

## The three objections that survive

Most reflexive objections to a blind pool don't hold. These three do.

### 1. Share-credit theft — the cryptographic crux

Recabarren & Carbunar's **BiteCoin** attack hijacks the miner↔pool TCP connection and steals shares.
Their defense, a mining cookie `C_M = H²(R_M, M.uname)`, works **precisely because the username is
an input to the PoW**: an attacker substituting their own username produces a hash that no longer
meets target. **Whether this defense survives being rebuilt on a blinded commitment instead of a
plaintext username is unanalyzed by anyone.** This is the single most important open technical
question in this design space — and note it is about *theft*, not withholding.

Filed as [[../theses/blinded-share-credit-commitment|Thesis: a blinded share-credit commitment can
preserve Bedrock's share-theft resistance]], which decomposes it into four sub-claims and expects a
split verdict: re-labeling resistance and enrollment gating likely survive blinding; **share-weight
aggregation and duplicate/replay arbitration likely do not**. It is also live *now* in a way it
wasn't in 2017 — Bedrock needs the cookie in the coinbase, and under SV2 JD and DATUM the miner
declares the template, so the party that would insert a blinded commitment already controls the
field. Tracked as [[../../inventory/candidates/blinded-mining-cookie-security|inventory p1]].

### 2. Dust → accrual → custody → money transmitter

Ocean's own TIDES documentation concedes that satoshi-precision rewards produce uneconomic dust and
that pools therefore accrue "until the sum exceeds a minimum threshold." **Accrual to a threshold is
a hosted balance**, which is exactly FinCEN §5.4's trigger: pool distributions are exempt as
"integral to the provision of services" *unless* the operator combines them with "hosting CVC
wallets," which is "account-based money transmission." So the exemption erodes for exactly the small
miners a blind pool most wants to serve — and coinbase output-count limits bound how many can be
paid directly per block anyway.

Compounding it, §4.5.1(a) makes an **"anonymizing services provider"** a money transmitter
*expressly ineligible* for the integral exemption, and §4.5.1(b) makes blinding *per se* a Travel
Rule violation if you are a transmitter. **Custody and blinding are individually survivable and
jointly fatal.** See [[../decisions/attribution-retention-tradeoffs|Attribution Retention Tradeoffs]].

### 3. Compulsion blocks the promise, not the architecture

**Lavabit** is dispositive: the government obtained a warrant for TLS keys covering all 400,000
customers, Levison offered targeted code instead, and the court **rejected it**. The EFF answers
"have warrant canaries been tested?" with "**Not yet**… EFF *believes* they are legal" — belief, not
holding. Therefore:

> **Any blindness claim must be scoped to the past tense.** What is durable is (a) data never
> collected, which cannot be produced retroactively, and (b) client-verifiable behavior — a design
> where *starting* to collect requires a client-visible, log-visible change that clients refuse to
> encrypt to.

## Objections that do not survive

**"You need attribution to detect block withholding."** Refuted by the withholding literature
itself. Eyal 2015: a pool "might not be able to detect which of its **registered** miners are the
perpetrators" — identity assumed and still insufficient, because a threshold catching attackers
"would reject the majority of its honest miners." Rosenfeld conceded in 2011 that PPLNS sabotage is
"difficult to detect" with identity fully available. APoW ranks PPLNS/score-based as **Strong**
against withholding versus FPPS **Very weak**, because under PPLNS withholding costs the attacker
its own revenue — **incentive alignment does the work attribution can't.**

**The one surviving exception is narrow and is specifically about rotation**: Eligius 2014 caught its
attacker only because they "used **two payout addresses**," letting the operator cluster many
individually insignificant signals into one significant one. Fresh-address-per-payout defeats the
only withholding detection that has ever worked in production. That is a real cost of Part A, not of
Part B. See [[../concepts/block-withholding#Does detection actually need attribution?|Block Withholding]].

## Where the prior art stands

Nothing is blind. From [[../concepts/payout-attribution-privacy|the survey]]:

- **[[../concepts/ehash|eHash / hashpool]]** — weakest share→miner link of any design, and still not
  zero: the mint sees per-share `header_hash` (required for duplicate rejection), exact difficulty
  via `amount = 2^(diff − keyset_min_diff)`, timestamps, and the whole swap graph. Its own docs
  concede consolidation is "**trivially linkable to the same wallet regardless of timing
  strategy**," and `SETTLEMENT_DESIGN.md` restores full attribution via a cleartext `payout_address`.
  The Cashu mining-share NUT (PR #293) was **closed 2026-03-09**; there is no accepted spec.
- **[[../concepts/braidpool|Braidpool]]** — commits `payout_address` **and miner IP** into the PoW,
  gossiped forever. Zero occurrences of "privacy" in the spec.
- **[[../concepts/p2poolv2-accounting|p2poolv2]]** — `ShareCommitment.miner_bitcoin_address` in the
  coinbase plus a `UserIndex`; publishing all shares makes attribution available to *everyone*,
  strictly worse than a centralized pool on this axis, in exchange for removing custody.
- **[[../concepts/radpool|Radpool]]** — attribution *multiplied*: "Verifiable Share Ownership"
  requires broadcasting username + sequence_no syndicate-wide.
- **SV2** — the only attribution-related extension, `0x0002`, **increases** attribution, though its
  §4.2 is the ecosystem's clearest statement that per-worker data "could reveal operational
  insights." Extended channels aggregating a whole farm behind a proxy is the one existing lever,
  and it operates *below* the pool.

**Confirmed gap**: no BIP, no SV2 extension, no ZK or MPC design for share accounting;
delvingbitcoin searches for `pool+cannot+link`, `xpub+payout+mining`, `MPC+mining+pool` return
**zero topics**.

## The honest answer

A pool can reach: **"we never learned which IP submitted which share, we never stored a persistent
miner identifier, we paid to fresh scripts derived from descriptors you gave us, and the code that
could have logged otherwise is in a public transparency log you check before encrypting to us."**

A pool cannot reach: **"we don't know how much work each payout script did."** That is the payout
computation. The workable target is therefore not *blindness* but **minimum-viable attribution**:
per-descriptor work volume and nothing else — no IP, no persistent name, no device fingerprint, no
cross-window linkage — with the pool structurally unable to reacquire the rest.

## Sources

- [[../../raw/repos/2026-07-29-pool-identity-vs-payout-script-conflation-code-read|Identity-vs-payout-script code read]]
- [[../../raw/repos/2026-07-29-bip352-silent-payments-coinbase-incompatibility|BIP 352 coinbase incompatibility]]
- [[../../raw/papers/2026-07-29-recabarren-carbunar-hardening-stratum|Hardening Stratum (PETS 2017)]]
- [[../../raw/papers/2026-07-29-romiti-2019-mining-pool-payout-deanonymization|Romiti et al. (WEIS 2019)]]
- [[../../raw/papers/2026-07-29-bba-plus-black-box-wallets|BBA+ / Black-Box Wallets]]
- [[../../raw/papers/2026-07-29-maurer-2017-knapsack-coinjoin-arbitrary-values|Maurer et al. (TrustCom 2017)]]
- [[../../raw/papers/2026-07-29-withholding-detection-does-not-need-attribution|Withholding detection vs. attribution]]
- [[../../raw/notes/2026-07-29-self-blinding-system-architectures|Self-blinding system architectures]]
- [[../../raw/notes/2026-07-29-fincen-td10000-regulatory-attribution-posture|Regulatory posture]]
- [[../../raw/repos/2026-07-29-mining-privacy-prior-art-survey|Mining privacy prior-art survey]]

## See also

- [[../concepts/payout-attribution-privacy|Payout Attribution Privacy]]
- [[../concepts/xpub-payout-identity|xpub Payout Identity]]
- [[../concepts/coinbase-amount-linkability|Coinbase Amount Linkability]]
- [[../concepts/blind-share-accounting|Blind Share Accounting]]
- [[../concepts/self-blinding-architectures|Self-Blinding Architectures]]
- [[../concepts/hashrate-inference-side-channels|Hashrate Inference Side Channels]]
- [[../decisions/attribution-retention-tradeoffs|Attribution Retention Tradeoffs]]
- [[payout-design-space|Payout Design Space]]
- [[sv2-jd-and-payout-decoupling|SV2 JD and Payout Decoupling]]
- [[../../output/playbook-self-blinding-pool-attribution-2026-07-29|Playbook — designing a self-blinding pool]]
- [[../concepts/braidpool|Braidpool]]
- [[../concepts/coinbase-address-rotation|Coinbase Address Rotation]]
- [[../decisions/custody-tradeoffs|Custody Tradeoffs across Payout Schemes]]
- [[../concepts/ehash|eHash / Hashpool — Cashu ecash share tokens]]
- [[../concepts/pplns-jd|PPLNS-JD / SLICE]]
- [[../concepts/tides|TIDES (Transparent Index of Distinct Extended Shares)]]
- [[../theses/blinded-share-credit-commitment|Thesis: blinded share-credit commitment]] — the 2026-07-29 verdict round

