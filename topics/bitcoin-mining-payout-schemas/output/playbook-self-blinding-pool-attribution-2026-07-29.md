---
title: "Playbook — TIDES/PPLNS-JD with a miner-supplied xpub, and how far a pool can blind itself to attribution"
type: playbook
created: 2026-07-29
updated: 2026-07-29
confidence: high
question: "How do TIDES/PPLNS-JD but the user provides an xpub or similar? Even if there were some blinding schema, payout amounts/shares would still be attributable by the service provider. How could a service prevent storing this attribution, or blind themselves to it?"
tags: [xpub, attribution, privacy, tides, pplns-jd, self-blinding, ohttp, bba-plus, fincen, playbook]
sources: 10
---

# Playbook — self-blinding pool attribution

**The question**: do TIDES/PPLNS-JD but the miner supplies an xpub; since payout amounts and shares
remain attributable by the operator, how could a service prevent storing that attribution or blind
itself to it?

**The answer in one paragraph.** The premise is correct, and sharper than stated. A pool's
attribution knowledge comes from **share validation, not from payment** — by the time any satoshi
moves, the pool has already recomputed every share header, assigned every target, timestamped every
arrival, and can infer hashrate to within a few percent. So blinding the payout rail defends against
**chain observers**, not against the operator. The xpub half of the question is buildable today and
mostly unbuilt; the blinding half is bounded by an impossibility result and reduces, in practice, to
**minimum-viable attribution plus non-collusion plus client-enforced transparency** rather than
blindness. This playbook gives the build path, the ceilings, and the three objections that actually
survive scrutiny.

Compiled from 10 primary sources ingested 2026-07-29. Synthesis article:
[[../wiki/topics/self-blinding-pool-design-space|Self-Blinding Pool Design Space]].

## The finding that reorders the problem

> **The pool's knowledge derives from validating shares, not from paying them.**

Everything else follows. Split the question into two problems with very different difficulty:

| | Problem | Status |
|---|---|---|
| **A** | Unlink miner identity from the payout output | **Tractable, mostly unbuilt.** Blockers are field widths and ledger keys, not cryptography. |
| **B** | Prevent the operator learning per-unit work volume | **No known solution.** The fitting primitive has an impossibility result against single operators. |

What a pool **structurally cannot avoid** learning: the exact content of every accepted share
(validation *is* observation); which work-unit each belongs to; exact per-unit share count and
timing; assigned difficulty; hashrate to within a few percent; the transport peer; session structure
over time; and nTime/version-rolling behaviour.

What is **merely conventional** and can go: persistent usernames, worker names, SV2's
`SetupConnection` `vendor`/`hardware_version`/`firmware`/`device_id` fingerprints (SV2 is *worse*
than V1 here — `device_id` is by definition a stable unique hardware identifier),
`nominal_hash_rate` self-declaration, cross-session identifier persistence, payout-address
stability, and coinbase tags.

## Part A — the xpub build path

### Step 1: pick the right host scheme

The engineering cost varies by an order of magnitude:

| Scheme | Coupling | Work |
|---|---|---|
| **PPLNS-JD / share-accounting-ext** | Ledger key is `(slice, share_index)` — positional, **zero identity fields** | **Identity layer only.** Start here. |
| **TIDES** | Coinbase precomputed at **work-issue** time for all miners | A derivation per miner **per template refresh** |
| **ckpool** | `username[128]` is the hash key **and** becomes `txnbin[48]` via `address_to_txn()` | The username *is* the scriptPubKey — maximum coupling |
| **public-pool** | `address varchar(62)` is part of a composite **PRIMARY KEY** | A PK schema migration |

### Step 2: use descriptors, not payment codes

**BIP 32 xpubs and BIP 380 wildcard descriptors work. BIP 352 silent payments cannot** — this is
structural, not a missing implementation. BIP 352 requires `a = a_1 + … + a_n` (sum of input private
keys) and fails if `a = 0`; the receiver skips the transaction if `A` is the point at infinity. A
coinbase is defined by consensus as `vin.size() == 1 && vin[0].prevout.IsNull()`, so no input
private key exists. Zero occurrences of "coinbase" in BIP 352's 524 lines, and no proposal anywhere
for a coinbase-specific tweak substitute.

### Step 3: split identity in two

Persist `identity → descriptor` **plus a monotonic derivation index** that survives restart. The
ledger keys on the stable descriptor (or its fingerprint); the coinbase uses the derived script.
Skipping this is the failure mode: a balance table doing `ON CONFLICT (address) DO UPDATE` keys
balances on address *globally*, so a rotating miner writes a new row every block and pending-credit
carry-forward silently stops working.

### Step 4: decide the rotation trigger — and know it's unresolved upstream

SV2 issue #697, verbatim: *"The tricky part here is to decide when to rotate. Doing it for every
`SetNewPrevHash` would generate too many addresses, which is difficult for wallet software to keep
track of."* Greg Maxwell's alternative (#1652) is **blockheight-as-index** — self-synchronizing, so
no persistence is needed at all — but apoelstra notes it "might confuse wallets that don't have an
800000+ gap limit." BIP 44's stated gap limit is **20**.

PR #1720 (merged 2025-07-09) shipped `coinbase_output_descriptors` with BIP 385 `addr()`/`raw()`,
but **wildcards remain rejected in merged code** ("no wildcards allowed (at least for now; gmax
thinks it would be cool if we would instantiate it with the blockheight or something, but need to
work out UX)"), as are hardened steps, multipath `<0;1>`, and xprv. Scope is the pool's own single
output — **not per-miner**.

### Step 5: validate at registration, and budget for the ceilings

- **Reject wildcard-less descriptors at registration.** `tr(<xpub>)` parses fine and then returns
  the same address forever; the operator only notices weeks later on chain. Both known
  implementations guard with miniscript's `has_wildcard()`. At per-miner granularity there are
  hundreds of opportunities to miss it.
- **Field widths break everywhere.** A wildcard descriptor is ~150 chars. ckpool: 127 usable, and it
  splits usernames on `._` — both collide with descriptor syntax `()[],'/*#`. public-pool:
  `varchar(62)`, plus an `IsBitcoinAddress` validator that rejects descriptors outright. DATUM: 191
  chars, but **Avalon truncates at 63 and Whatsminer buffer-overflows past 127** ("which may damage
  your miner"). Some firmware percent-encodes non-alphanumerics.
- **Output count is firmware-bounded, not consensus-bounded**: ~**380–530** coinbase outputs
  (nicehash ≈500 B, antminer ≈730 B, antminer2 2250 B, whatsminer 6500 B).
- **Derivation cost**: sv2-apps' `XpubDerivator` re-parses the descriptor string on every derivation
  (miniscript's `Descriptor<DescriptorPublicKey>` holds a `RefCell` and isn't `Send + Sync`). Fine
  once per block; a parse storm once per miner per template.

### What Part A buys and doesn't

**Buys**: it defeats the attack that demonstrably works. Romiti et al. (WEIS 2019) identified **92 %
of BTC.com miners, 75 % of ViaBTC, 30 % of AntPool** from public chain data with **no pool
cooperation**, driven by payout-address reuse (median 20 / 5 / 2). The inverse correlation between
reuse and identification is the whole empirical case for rotation.

**Doesn't buy**: any reduction in operator knowledge. Worse, the pool now holds the descriptor
linking all of a miner's rotated addresses together. **An xpub username is an on-chain privacy
upgrade and a pool-side privacy no-op.**

**Confirmed negative result**: no pool anywhere accepts an xpub, descriptor, or payment code as a
miner's payout identity — verified against ckpool, public-pool, DATUM, the SV2 reference apps, and
Ocean's docs.

## Part B — what the amounts actually leak

State the sum constraint precisely, because the loose version is misleading in both directions.

**Against the pool: zero incremental leak.** The pool *computed* the sum; it knows every addend
already. There is no scenario in which a pool learns share weights *from* the payout total.

**Against a chain observer: sharp — and normalization does the damage, not the total.** For payout
outputs `{a₁…a_N}`, `aᵢ / Σaⱼ` is miner *i*'s **exact** relative share weight, requiring no knowledge
of pool difficulty, window length, or absolute hashrate — the sum normalizes them away. And `N`
bounds the anonymity set; AntPool's fixed 101-output structure was the very *filter* Romiti et al.
used to find payout transactions. So a blinded scheme can hide **who** but not the **distribution
shape** — which is what those Gini coefficients of 0.938–0.945 are.

### Why a coinbase is the worst case

Determining the input→output mapping in a transaction with arbitrary values "**is equal to solving
the subset sum problem**" (Maurer, Neudecker & Florian, TrustCom 2017) — and for naive unequal-amount
CoinJoins "there is generally only **one** non-derived mapping," i.e. no privacy benefit at all. A
coinbase is a **strictly easier** instance than any CoinJoin:

1. **One input, of publicly known value** — subsidy + fees is computable by anyone. No input-side
   ambiguity exists.
2. **No input shuffling.** CoinJoin privacy needs ambiguity in *both* directions; a coinbase has one
   null-prevout input by consensus, so half the ambiguity budget is structurally absent.
3. **No padding.** A CoinJoin coordinator adds decoy inputs and outputs; a pool **cannot inflate the
   total** — it's consensus-bounded by subsidy + fees, so every decoy satoshi comes out of a real
   miner.

Amplifiers to avoid: **round numbers accelerate the attack** (CoinJoin Sudoku broke SharedCoin,
recovering 69 % of inputs and 53 % of outputs in 30.75 core-hours), and address reuse across rounds
is fatal. A pool paying `share_fraction × reward` produces high-entropy non-round amounts — good.

**The ceiling, stated by WabiSabi's own authors**: "cleartext amounts appearing in the final
transaction might still link individual inputs and outputs"; anonymity is only "apart from what is
already deducible given the public amounts visible on the Bitcoin blockchain." That clause applies to
a blinded pool too.

**Two mitigations and their limits.** *Output splitting* works but "requires knowledge of all
sub-transactions" — the splitter must know the truth, and in a pool **the splitter is the pool**, so
it cannot blind the operator to itself. *Denomination ladders* (Wasabi's approach; also Cashu's
`amount = 2^(diff − keyset_min_diff)`) convert exact-amount leakage into bucket-level leakage — they
bound the channel rather than removing it, and force rounding losses somewhere.

## Part B — the primitive problem

PPLNS credit is a **running weighted sum over a sliding window**. Every deployed Bitcoin privacy
primitive is a **one-shot denominated bearer object**. That mismatch is the crux:

| PPLNS/TIDES needs | Cashu-style ecash provides |
|---|---|
| Continuous accumulation of weight | Discrete tokens from a fixed ladder |
| Arbitrary-valued per-share difficulty | Power-of-two buckets |
| Window-relative decay | Timeless bearer objects |
| Exact final total | Rounding to the ladder |
| Operator must not learn per-miner totals | Mint sees every issuance and redemption amount |

vnprc — author of both hashpool and the Cashu mining-share NUT — stated the tension directly:
"You can do multiple redemptions by linking the tokens to the mining share, but **in the process you
destroy the privacy properties of ecash.**"

### BBA+ / Black-Box Wallets — the only primitive that fits

An unlinkable token carrying a quantitative balance that a third party increments homomorphically
(CCS 2017; PoPETs 2020 **article 0010** — note popets-2020-0007 is an unrelated DP paper). Four
properties map almost too well: **the user never performs the addition** (so inflation is
impossible); **token size is independent of points accumulated**; **rollback is punished** by
extracting `sk_U = (t−t')·(u2−u2')⁻¹` from a reused double-spending tag; and it has formal proofs.

Blockers, in severity order — **revised 2026-07-29 by the thesis round; the original #1 was
retracted**:

1. **Range.** The Black-Box Wallets prototype carries a **16-bit** balance; a TIDES window spans
   `8 × network_difficulty` in diff-1 shares (~10¹⁵ today, ~50 bits). Bulletproofs close this in
   principle; nobody has built it. **This is now the top blocker** and the honest basis for any
   infeasibility argument.
2. **secp256k1 blind Schnorr is unusable.** The **ROS attack** breaks blind Schnorr (and blind
   FROST/MuSig). ~~at ~256 concurrent sessions~~ — that is the threshold for the *seconds-long*
   attack; the paper's §7 gives **ℓ = 9** parallel sessions as practical today. Use RSA blind
   signatures, BDHKE, or KVAC/algebraic MACs.
3. **Per-accumulation round-trips** at real share rates; weight must be credited in windows, not per
   share.
4. **No mining-specific construction exists.** No literature on ZK proofs of accumulated
   mining-share contribution; no BIP; no SV2 extension.
5. **~~The Canard–Gouget impossibility~~ → RETRACTED.** This was #1 in the original playbook and it
   was wrong. The claim traced to one sentence in Black-Box Wallets p.3 invoking Canard–Gouget while
   **rejecting transferable e-cash** as an alternative; the cited paper (ACNS 2008) is paywalled and
   its theorem unverified. **BBW's Definition 4.1 shares `sk_I` across issuer, accumulator and
   verifier and still proves privacy** — the single-operator case is the one BBW proves secure, via
   simulation-linkability needing no TTP. **Role separation is defense-in-depth, not a cryptographic
   requirement.** Nor is there any theorem making stateful accumulation harder than one-shot
   issuance: BBW measures `Add` at 62 ms against `Issue` at 52 ms. See
   [[../raw/papers/2026-07-29-stateful-vs-oneshot-credentials-no-separation|the correcting read]].

**Adjacent primitives**: Privacy Pass/VOPRF (RFC 9497) is mature and *stateless one-shot* — perfect
for the admission decision, useless for accumulation. **KVAC** is the most plausible substrate for an
arbitrary-valued share credential (it's what WabiSabi uses) and nobody has applied it to shares.
ACL suits per-slice receipts.

**The nearest prior art shows the ceiling.** Biryukov & Pustogarov's Tor PoW micropayments (FC 2015)
gave clients blind-signed tickets for mined shares — full unlinkability of the ticket — and the
authors still concede a relay "can learn the **hash rate** of a client, thus it may recognize
repeated connections," advising clients to *randomize their hash rate*. **Cryptography can unlink the
token from the payout; it cannot unlink work volume from the connection that submitted it.**

## Part B — the architecture that does transfer

Ranked by transferability, with the trust each substitutes in — because nothing is free:

| # | Architecture | Transferability | Trust substituted |
|---|---|---|---|
| 1 | **Split-trust relay for share submission** (RFC 9458 OHTTP; iCloud Private Relay) | **High** — pool sees shares + payout script, never the submitting IP | Relay and pool **must not collude or be co-owned** (§6.8); no forward secrecy within a key epoch; ≥2 round trips |
| 2 | **Blind-signature admission credentials** | **High** — proves "enrolled, paid-up, non-abusive" without learning which miner | Issuer must not collude with redeemer; rebuild the anti-abuse layer; rate limiting shrinks the anonymity set |
| 3 | **Multi-vendor TEE trust splitting** (SVR3: t=2 of n=3, $0.0025/user/year) | **Medium-high** for an attribution table; **low** for metadata | "No attacker compromises >2 of 3 stacks *simultaneously*"; 3× cloud spend |
| 4 | **Client-enforced transparency + reproducible build** | **Medium, and highest leverage per dollar** | The vendor who signs attestation — **AWS attests AWS** — plus your build pipeline, plus someone auditing the log |
| 5 | **Client-held keys / write-only running totals** | **High per unit of effort, most honest** | Substitutes **capability for functionality**: no dispute forensics |
| 6 | **Private aggregation** (Prio/DAP) | **Not for the ledger** | Wrong axis (see below); robustness needs *all* servers honest |
| 7 | **Differential privacy on balances** | **Near-zero** | Money must be exact — the one trade a payout system can't make |

**The framing correction worth internalizing**: Prio/DAP hide *individual inputs* and reveal a
*population total*. A pool needs the **opposite axis** — exact per-recipient totals with only the
*link* hidden. So the primary tool is unlinkable submission, not private aggregation.

**The OHTTP caveat that bites hardest here**, RFC 9458 §2.1.2: OHTTP "removes linkage at the
transport layer, which is only useful for an application that does not carry state between requests."
**A payout address is persistent state.** Any credential or address re-links the user, so the relay
buys IP-unlinkability and nothing more unless the credential layer is also unlinkable.

### The two mechanisms worth copying above all others

Both are client-side enforcement, and both are cheaper than the cryptography they guard:

1. **Apple PCC's key-wrapping rule** — the device "wraps request payload key **only to PCC nodes
   whose attested measurements match logged releases**." The server cannot decrypt unless its
   measurement already appears in an append-only public log. This converts "trust our promise" into
   "clients refuse to encrypt to unlogged code."
2. **iCloud Private Relay's raw-public-key pinning** — proxy auth uses raw public keys in the TLS 1.3
   handshake compared against a separately distributed authenticated config, *not* the web PKI. Plus:
   one-time-use RSA blind-sig tokens minted after attestation, **rotated daily**, with asynchronous
   double-spend prevention and per-day rate limits.

> That client-side enforcement step is **worth more to a blind pool than the enclave it protects.**

**Do not over-trust attestation.** SGAxe extracted Intel's production attestation key via CacheOut
while the victim enclave was **completely idle** ("we can build a malicious SGX simulator that passes
Intel's entire remote attestation process"); ÆPIC Leak did it "within a few seconds" *without a side
channel*, concluding one should "not rely on SGX." The 2025 CVM SoK is blunter: "**all major cloud
providers retain control over critical parts of the trusted software stack and, in some cases,
intervene in the standard remote attestation process. This directly contradicts their claims.**" AWS
Nitro Enclaves is excluded from that analysis entirely because Amazon is both hardware vendor and
cloud provider. RFC 9334 is explicit that attestation evidence describes *what* code is running,
never whether it behaves correctly.

## The three objections that survive

Most objections to a blind pool don't hold. These do.

### 1. Share-credit theft — the cryptographic crux

**BiteCoin** hijacks the miner↔pool TCP connection and steals shares. The defense, a mining cookie
`C_M = H²(R_M, M.uname)` in the coinbase's unused previous-input-hash field, works **precisely
because the username is an input to the PoW**: an attacker substituting their own username produces a
hash that no longer meets target.

**Whether that survives being rebuilt on a blinded commitment instead of a plaintext username is
unanalyzed by anyone.** This is the single most important open technical question in the space — and
note it is about *theft*, not withholding. Also note Bedrock provides **zero privacy from the pool**;
every defense in that paper treats the pool as a trusted endpoint.

### 2. Dust → accrual → custody → money transmitter

FinCEN §5.4 exempts pool distributions as "**integral to the provision of services**" — *unless* the
operator combines them with "**hosting CVC wallets**," which is "account-based money transmission."
Ocean's own TIDES docs concede satoshi-precision rewards produce uneconomic dust and that pools
accrue "until the sum exceeds a minimum threshold." **Accrual to a threshold is a hosted balance** —
exactly the trigger. The exemption therefore erodes for precisely the small miners a blind pool most
wants to serve.

Compounding it: §4.5.1(a) makes an **"anonymizing services provider"** a money transmitter
**expressly ineligible** for the integral exemption, and §4.5.1(b) makes decodability failures a
Travel Rule violation. **Custody and blinding are individually survivable and jointly fatal.**

TD 10000's validator carve-out helps but is narrower than it looks — the phrase "mining pool" appears
**zero times** in 365 pages, the qualifier is "**without providing other functions or services**,"
and Treasury expressly declined to finalize non-custodial rules. On OFAC: BitRiver was the first
mining designation but under a *sectoral* theory, and **no guidance requiring pools to screen
participant payout addresses was found** — least authority in either direction, largest open risk.

### 3. Compulsion blocks the promise, not the architecture

**Lavabit** is dispositive as to promises: the government obtained a warrant for TLS keys covering all
400,000 customers, Levison offered targeted code instead, and **the court rejected it** — $5,000/day,
shutdown, contempt. The EFF answers "have warrant canaries been tested?" with "**Not yet**… EFF
*believes* warrant canaries are legal" — belief, not holding.

> **Scope every blindness claim to the past tense.** What is durable: (a) data never collected, which
> cannot be produced retroactively; (b) client-verifiable behavior where *starting* to collect
> requires a client-visible, log-visible change clients refuse to encrypt to.

Two residuals: PCC's own transparency-log publication window is **within 90 days**, so detection is
*delayed*, and **verifiable deletion is an open problem, not an available primitive** — no deployed
system gives the user a proof deletion occurred. A retention policy is a promise; non-collection is a
property. One borrowable argument, from Prio: **jurisdictional diversity** — "If law enforcement
agents seize the Prio servers in one country, they cannot deanonymize the… users."

## The objection that does not survive

**"You need attribution to detect block withholding."** The withholding literature refutes this in
its strong form.

Eyal 2015 — note "**registered**": a pool "might not be able to detect which of its **registered**
miners are the perpetrators." The reason is variance, not anonymity: a small miner's expected
full-PoW frequency is so low that the pool "**cannot obtain statistically significant results**," and
a threshold that catches attackers "would **reject the majority of its honest miners**." §VIII-D: a
pool "**cannot detect which of its miners is the attacker.**" Registration is defeated anyway by
Sybil churn — "An attacker can use multiple small block withholding miners and **replace them
frequently**."

Rosenfeld conceded the same in 2011 with identity fully available: PPLNS sabotage is "**difficult to
detect**." APoW (arXiv 2601.02496, *unrefereed*) ranks **PPLNS/score-based Strong** vs **PPS Weak**
vs **FPPS Very weak**, because under PPLNS withholding costs the attacker its own revenue —
**incentive alignment does the work attribution can't** — and estimates 25–35 % of hashrate sits in
the susceptible schemes. It also demolishes both textbook countermeasures: pop quizzes are detectable
by the miner, and audits cost the pool more than they save.

**The one surviving exception is narrow and is specifically about rotation.** Eligius 2014 caught its
attacker only because they "used **two payout addresses**," letting the operator cluster many
individually insignificant signals into one significant one. **Fresh-address-per-payout defeats the
only withholding detection that has ever worked in production** — a real cost of Part A, not of
Part B.

## Where the prior art stands

Nothing is blind. The one design that claims to be says otherwise in its own docs.

| System | Share→miner link visible to operator? | Privacy claimed? |
|---|---|---|
| **hashpool / eHash** | **Weakest link of any design — but not zero** | Yes, explicitly |
| **Ecash TIDES** (dbtc #870) | Yes, deliberately — shares + blinded sigs *published* at block-found | Yes (goal #3) |
| **Braidpool** | Yes, maximally — `payout_address` **and miner IP** committed in the PoW, gossiped forever | **None.** Zero occurrences of "privacy" in the spec |
| **p2pool / p2poolv2** | Yes, maximally — `ShareCommitment.miner_bitcoin_address` + a `UserIndex` | None; transparency is the design |
| **Radpool** | Yes, and **fanned out to N operators** | None |
| **BMAX / p2share** | Yes, by construction — deterministic winner selection needs a public share register | None |

**hashpool's own numbers matter most**, because it's the closest thing to an answer that exists. Its
`poisson-proof-consolidation-plan.md`: Cashu's blinding "does **not** prevent temporal correlation or
batch fingerprinting by the mint. Since the hashpool mint issues all proofs, it knows when every proof
was created and can observe when they are consumed." The mint sees `header_hash` (required — it "MUST
treat `header_hash` values as unique payment identifiers"), exact difficulty via
`amount = 2^(diff − keyset_min_diff)`, timestamps, and the whole swap graph. And the decisive
admission: "all consolidation operations are **trivially linkable to the same wallet regardless of
timing strategy**." Worse, `SETTLEMENT_DESIGN.md`'s on-chain path requires a **cleartext
`payout_address`**, restoring attribution fully. The Cashu mining-share NUT (PR #293) was **closed
2026-03-09**; there is no accepted spec.

**SV2's only attribution-related extension moves the wrong way.** Ext `0x0002` adds a `user_identity`
TLV that MUST accompany every `SubmitSharesExtended` so "pools can track worker-specific hashrate."
Its §4.2 is nonetheless the ecosystem's clearest statement of the cost — "sharing per-worker data with
pools could reveal operational insights" — which is why it's opt-in. The one existing lever is that
base SV2 **extended channels** aggregate work and carry no `user_identity`, so a proxy can front a
whole farm as one channel — and that operates *below* the pool, not against it.

**Confirmed gap**: no BIP, no SV2 extension, no ZK or MPC design for share accounting. delvingbitcoin
searches for `pool+cannot+link`, `xpub+payout+mining`, `MPC+mining+pool`, `p2pool+privacy` return
**zero topics**.

## The recommended target: minimum-viable attribution

Blindness is the wrong goal because it isn't reachable. The reachable goal:

**Retain**: per-descriptor work volume. Nothing else.

**Never collect**: source IP (terminate submissions through a non-colluding OHTTP-style relay);
persistent usernames (per-session blinded admission credential instead); SV2 `SetupConnection`
`vendor`/`hardware_version`/`firmware`/`device_id`; worker-name substructure; cross-window linkage.

**Make verifiable**: publish reproducible builds, put measurements in an append-only log, and have the
client wrap its payload key **only** to measurements in that log. This is the part that converts a
policy into a property.

**Pay**: coinbase-direct to scripts derived from miner-supplied wildcard descriptors, at whatever
rotation cadence you've chosen — never accruing to a threshold if you can avoid it, because accrual is
custody and custody plus blinding is the fatal combination.

**Say**: "we never learned which IP submitted which share, we never stored a persistent miner
identifier, we paid to fresh scripts derived from descriptors you gave us, and the code that could
have logged otherwise is in a public log you check before encrypting to us." In the **past tense**.

**Don't say**: "we don't know how much work each payout script did." That *is* the payout computation.

## Derived theses (for `--mode thesis` follow-up)

Three claims sharp enough to be tested:

1. **"A blinded share-credit commitment can preserve Bedrock's share-theft resistance."** Recabarren &
   Carbunar's mining cookie `C_M = H²(R_M, M.uname)` resists BiteCoin hijacking because the username
   is a PoW input. The thesis is that substituting a per-session blinded commitment for the plaintext
   username retains the property. Falsifiable by exhibiting an attack against the blinded variant, or
   by a proof reduction. **Currently unanalyzed by anyone** — the highest-value open question here.
2. **"A non-custodial coinbase-direct pool that retains only per-descriptor work volume is not a money
   transmitter under FinCEN FIN-2019-G001."** §5.4's exemption plus §4.2's four factors support it;
   §4.5.1(a)'s anonymizing-services-provider rule cuts against it; DOJ's §1960 theory in the Samourai
   prosecution is the untested bypass. Falsifiable against the §1960 case law this round could not
   retrieve.
3. **"Per-payout address rotation strictly increases a pool's block-withholding exposure."** Eligius
   2014 is the only production detection success and it depended on address clustering; APoW argues
   PPLNS's incentive structure makes detection unnecessary. The thesis pits these against each other
   and is falsifiable by quantifying residual detection power under rotation — no paper has.

## Remaining gaps

1. **DOJ §1960 / Samourai non-custodial enforcement theory** — DOJ URLs returned 403/404. The most
   important gap: it's the mechanism by which the favorable §5.4 analysis could be bypassed by a
   criminal rather than regulatory theory.
2. **EU TFR (Reg. 2023/1113) and MiCA treatment** — EUR-Lex returned HTTP 202 on four URL forms.
   Unverified; do not rely on this playbook for EU posture.
3. **Blinded mining-cookie security** — thesis 1 above.
4. **Connection-level Sybil re-correlation** — a pool re-correlates split identities via source IP,
   reconnect co-timing, and hashrate signature, but **no paper measures this**. Unquantified rather
   than disproven.
5. **Subset-sum analysis against coinbase outputs specifically** — the CoinJoin literature transfers by
   argument; nobody has run the attack on real coinbase payout sets.
6. **PPLNS-JD primary paper** — `dmnd.work/pplns-with-job-declaration/…pdf` returns **HTTP 404**; all
   PPLNS-JD detail here comes from `extension.md` in the spec repo.

## Sources

Ten primary sources, ingested 2026-07-29:

- [[../raw/repos/2026-07-29-pool-identity-vs-payout-script-conflation-code-read|Identity-vs-payout-script code read]] — ckpool, public-pool, DATUM, TIDES, share-accounting-ext, SV2 #697/#1652/#1720
- [[../raw/repos/2026-07-29-bip352-silent-payments-coinbase-incompatibility|BIP 352 coinbase incompatibility]] — plus BIP 380 wildcards, BIP 44 gap limit
- [[../raw/repos/2026-07-29-mining-privacy-prior-art-survey|Mining privacy prior-art survey]] — hashpool, Braidpool, Radpool, p2poolv2, SV2 ext 0x0002, NUT #293
- [[../raw/repos/2026-07-29-sv2-apps-xpub-coinbase-rotation-code-read|sv2-apps xpub coinbase rotation]]
- [[../raw/papers/2026-07-29-recabarren-carbunar-hardening-stratum|Hardening Stratum (PETS 2017)]]
- [[../raw/papers/2026-07-29-romiti-2019-mining-pool-payout-deanonymization|Romiti et al. (WEIS 2019)]]
- [[../raw/papers/2026-07-29-bba-plus-black-box-wallets|BBA+ / Black-Box Wallets, ROS, Tor PoW micropayments]]
- [[../raw/papers/2026-07-29-maurer-2017-knapsack-coinjoin-arbitrary-values|Maurer et al. (TrustCom 2017), WabiSabi, CoinJoin Sudoku]]
- [[../raw/papers/2026-07-29-withholding-detection-does-not-need-attribution|Withholding detection vs. attribution]]
- [[../raw/notes/2026-07-29-self-blinding-system-architectures|Self-blinding system architectures]]
- [[../raw/notes/2026-07-29-fincen-td10000-regulatory-attribution-posture|Regulatory posture]]

*Search caveat: WebSearch was unavailable throughout this round. Discovery used DuckDuckGo HTML/lite,
Brave, delvingbitcoin `search.json`, IACR search, and the GitHub API, with CAPTCHA throttling. One
agent's fetch summarizer fabricated a paper title and performance table for BBA+; the agent caught it
and replaced the content with direct PDF reads. An unverified claim about Mimblewimble-style privacy
in delvingbitcoin #2093 is flagged in the prior-art ingest.*

## Wiki articles

- [[../wiki/topics/self-blinding-pool-design-space|Self-Blinding Pool Design Space]] — the synthesis
- [[../wiki/concepts/payout-attribution-privacy|Payout Attribution Privacy]]
- [[../wiki/concepts/xpub-payout-identity|xpub Payout Identity]]
- [[../wiki/concepts/coinbase-amount-linkability|Coinbase Amount Linkability]]
- [[../wiki/concepts/blind-share-accounting|Blind Share Accounting]]
- [[../wiki/concepts/self-blinding-architectures|Self-Blinding Architectures]]
- [[../wiki/concepts/hashrate-inference-side-channels|Hashrate Inference Side Channels]]
- [[../wiki/decisions/attribution-retention-tradeoffs|Attribution Retention Tradeoffs]]
