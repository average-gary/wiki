---
title: "Bedrock primary read — mining-cookie construction, field placement, and the absent security proof"
authors: [Ruben Recabarren, Bogdan Carbunar]
year: 2017
venue: "PoPETs 2017(3):57–74 / arXiv 1703.06545v1"
source: https://petsymposium.org/popets/2017/popets-2017-0028.pdf
supporting_sources:
  - https://arxiv.org/pdf/1703.06545
type: papers
ingested: 2026-07-29
quality: 5
credibility: high
confidence: high
tags: [bedrock, mining-cookie, bitecoin, share-theft, stratum, primary, verbatim-verified, correction, consensus-validity, vardiff, thesis-evidence]
summary: "Targeted re-read of Bedrock against both the arXiv and PoPETs PDFs to resolve three questions the derived wiki articles had left open or gotten wrong: where the cookie actually lives, whether there is a security proof, and whether the pool needs identity to validate as distinct from to credit."
---

# Bedrock primary read (verbatim-verified)

Both the arXiv v1 (18 pp.) and the published PoPETs version were retrieved and cross-checked;
wording is identical in every load-bearing passage. The published article number is confirmed:
the header reads *"Proceedings on Privacy Enhancing Technologies ; 2017 (3):57–74"*. Figures 1, 2
and 8 were read as rendered images rather than through text extraction.

This read exists because [[2026-07-29-recabarren-carbunar-hardening-stratum|the first ingest]]
left an open field question, and because the derived thesis file inherited two claims that the
paper does not support.

## 1. The cookie field — resolved, and it is literally the prevout hash

Three independent passages, and §8.3 explicitly **rejects the scriptSig**:

> "Thus, instead of designing the cookie to be an external field, we seek to leverage unused
> fields of the coinbase transaction. An obvious candidate for the cookie placement is the input
> script where the extranonce1 and extranonce2 reside. However, most pools have already started
> using this space for their own internal procedures, e.g., in F2Pool, to store the miner's name.
> Instead, Bedrock uses the yet unused, 32 byte (256 bit) long "previous input address" field of
> the coinbase transaction, see Figure 2." — §8.3, p.68

> "To minimally modify Bitcoin, Bedrock stores the cookie as part of the coinbase transaction
> (see Figure 2), in the place of its unused *previous hash* field. This field is unused since the
> coinbase transaction does not have a need for a meaningful input address hash." — §6.2.1, p.65

Figure 2's caption confirms the placement is inside `coinbase1`:

> "Bedrock (see § 6) introduces the mining cookie concept, whose value will overwrite the
> currently unused "previous hash" field within coinbase1."

And the paper affirmatively requires the cookie to survive into the published block:

> "The published block needs to include all the fields that defined the puzzle (see § 2.3),
> including the miner's cookie, to be publicly verified." — §6.2.1 "Cookie refresh", p.65

### The correction this forces

The wiki's hedge — "or 'previous-input-hash field' means the scriptSig" — is **wrong**. The paper
considered the scriptSig, named it, and declined it for a 2017 reason (pool-side scriptSig
contention). It means the 32-byte prevout hash.

Which makes the scheme **consensus-invalid for the ~1-in-N share that is a block**: a coinbase
needs `hash.IsNull() && n == 0xFFFFFFFF` for `IsCoinBase()`. The paper never addresses this. The
words *consensus*, *fork*, and *invalid block* appear nowhere near the design; there is no
separate block-candidate path; and the "unused" claim is justified **only empirically, by
surveying what pools put there** (F2Pool, GHash.io, SlushPool) — never by checking what full
nodes require. `"To minimally modify Bitcoin"` is as close as the paper comes to noticing it is
changing Bitcoin.

So relocating the cookie is **our repair to Bedrock, not a resolution of Bedrock's ambiguity**,
and should be attributed that way. The irony worth recording: under SV2 JD / DATUM the natural
home is the scriptSig or a coinbase `OP_RETURN` — precisely what §8.3 declined, for a reason that
no longer binds once the miner declares the template.

## 2. The construction — confirmed exactly, and it is a 7.44-year pseudonym

Algorithm 1, p.65, pool side:

```
3.  R_M := getRandom(256);
4.  C_M := H²(R_M, M.uname);
5.  K_M := M.key;
6.  store(M.uname, K_M, R_M, target);
7.  sendEncrypted(M, E_{K_M}(R_M));
```

`R_M` is a 256-bit seed **the pool generates**, stores, and sends to the miner encrypted under a
pre-shared symmetric `K_M` established during first authorization *"e.g., using authenticated
Diffie-Hellman"* (§6.2, p.64). `H²` is double SHA-256.

**There is no per-share or per-session component.** The cookie rotates on exactly one event:

> "Bedrock changes the mining cookie of the miner once the miner mines the current block. This is
> an infrequent event: for an AntMiner S7 … the expected time to mine a block is 7.44 years."
> — §6.2.1, p.65

By the paper's own arithmetic the cookie is a **static per-miner value with a ~7.44-year rotation
period** — a long-lived pool-side pseudonym in all but name. The gap between Bedrock and any
blinded design is therefore wider than "swap the preimage."

### Two internal inconsistencies in the paper

- **The puzzle predicate is stated two incompatible ways.** §2.3 (Eq. 1) and Algorithm 1 lines 12
  and 25 use `H²(nonce||F) < target` with `C_M` entering *inside* `F` via
  `computeF(C_M, extranonce2)` → coinbase → merkle root. Figure 8's diagram agrees. But "Cookie
  refresh" writes `H²(nonce||F||C_M)`, concatenating `C_M` *outside* `F`. The `||C_M` form appears
  once and contradicts both the algorithm and the figure.
- **`computeF` is never defined**, and `extranonce1` is not among its arguments anywhere in
  Algorithm 1, despite §2.4 making `extranonce1` part of the coinbase.

## 3. There is no security proof, and no named hardness assumption

Grepped for `theorem`, `lemma`, `proof`, `reduction`, `collision resistan`, `preimage`, `PRF`,
`pseudorandom function`, `assumption`. **No theorem or lemma environments exist.** "proof" occurs
only in *"reports a proof of a unit of solved work"* and in the section title *"9.3 BiteCoin:
Proof of Concept"*. The only "we assume" statements are adversary-model and key-setup
assumptions.

The entire anti-theft argument is §7.1 "Resilience to cryptographic failure," pp.66–67 — and note
it is framed as a **fallback for when the crypto is already broken**:

> "if the attacker hijacks a miner's share submission, the pool would use the attacker's username
> instead of the victim's username to construct the cookie, the coinbase transaction and
> eventually the header block. The share will only validate if the attacker managed to find a
> username that produced a double hash that was still smaller than the target corresponding to
> the difficulty set by the pool. However, the attacker will need to find such usernames for each
> hijacked share. **If the attacker was able to quickly find such partial collisions, it would be
> much easier to simply compute the shares without doing any interception and hijacking.**"

And against a hash-breaking adversary:

> "Such an attacker can recover a miner's R_M value, then find a username that produces a
> collision with the miner's cookie C_M. We observe however that such an attacker could then be
> able to also mine blocks quickly."

**The argument's structure is work-equivalence / rational-adversary, not a hardness reduction:**
*if you could break this, you could just mine instead.* "Partial collisions" appears
descriptively, never as an invoked assumption.

### The correction this forces

The thesis file's falsification clause — *"give a reduction from blinded theft resistance to **the
same hardness assumption** Bedrock relies on"* — is **unsatisfiable as written, because the paper
names no assumption.** The bar for a blinded variant is therefore *lower* than the wiki assumed:
matching Bedrock means reproducing an informal work-equivalence argument. A blinded construction
offering an actual reduction would be **strictly more rigorous than Bedrock**.

## 4. The pool needs identity to *validate*, not merely to *credit*

The miner volunteers its username in cleartext with every share, and the pool uses it as a
database key. It never guesses. Algorithm 1, p.65:

```
8.  verifyJob(Miner M, nonce, extranonce2){
9.      (K_M, R_M, target) := getMParams(M.uname);
10.     C_M := H²(R_M, M.uname);
11.     F := computeF(C_M, extranonce2);
12.     if (H²(nonce||F) < target)
...
26.     sendToPool(uname, nonce, extranonce2);
```

> "the pool retrieves the miner's key K_M, random seed R_M and target values (line 9). It uses R_M
> to reconstruct the cookie (line 10) and uses target, and the reported nonce and extranonce2
> values, to reconstruct and verify the puzzle" — §6.2.1, p.65

**The finding that matters, and which is new to this wiki:** `store(M.uname, K_M, R_M, target)`
puts the **per-miner vardiff `target` in the same identity-keyed row as `R_M`**. So even setting
aggregation entirely aside, a pool cannot evaluate `H²(nonce||F) < target` for an anonymous
submitter — the target itself is keyed on identity. That is an obstacle **upstream** of
share-weight aggregation, and it bites at validation.

Bedrock also does not encrypt `mining.submit`; the username stays in the clear.

Crediting is what submission is *for*, per the base protocol:

> "it sends a share submission message to the pool **for verification and credit**" — §2.4, p.61

> "The pool will reward the miner according to the number of shares submitted and accepted."
> — §2.1, p.59

## 5. Aggregation and duplicates — the paper is silent, twice

**No accounting algorithm exists in the paper.** The words *aggregate*, *accumulate*, *tally*, and
*sum* never appear in relation to shares. Bedrock says only that submission is "for verification
and credit."

**No duplicate or replay handling exists either.** Grepped `duplicate`, `replay`, `serial`,
`already submitted`, `retain`. `replay` appears three times, none about share replay: twice
describing the adversary's generic capability in Figure 1 (*"Inject, replay, modify"*), once as
methodology (*"a replay of a 24 hour subset of our Stratum traffic dataset"*). The only rejection
reason named is staleness (§2.4). `verifyJob` is **stateless with respect to prior submissions** —
it does not even take `job_id`, though the real `mining.submit` carries one, and it writes nothing
back.

**Consequence for the thesis:** Bedrock provides *no duplicate-arbitration baseline*, so
sub-claim C cannot be falsified against Bedrock. It inherits whatever F2Pool already did and never
specifies or analyzes it. The thesis file's assertion that "with plaintext identity the pool sees
a duplicate from a known party and credits once" is an **inference about pool practice, not
something Bedrock does or claims**, and must be relabeled.

The paper's own BiteCoin results cut against that framing anyway. §9.3: 72 shares hijacked, of
which *"23 shares … were accepted by the pool, i.e., as if they were mined by the attacker and not
by the victim. 49 shares were rejected"* — and the attack deliberately *"sends to the pool a
mangled copy of the victim's original share submission, to ensure that it is rejected."* The
attacker **suppresses the original rather than racing it**, which suggests it could not rely on
winning a duplicate race.

## 6. Cost figures — all verified

§9.4 + Figure 14, p.71:

> "Bedrock imposes a 0.002s decryption overhead per day on an AntMiner S7, while on a pool using
> the above server to handle 16,000 miners, it imposes an encryption overhead of 12.03 seconds per
> day. In contrast, a solution that encrypts each Stratum packet imposes an overhead of 0.13
> seconds per day on the AntMiner, and an unacceptable 1.36 hours per day on the pool server."

> "the daily computation overhead imposed by TLS on the pool, through the traffic of 16,000
> miners, is 1.01 hours … at least 4.3%." — §9.4.1

> "TLS imposes a 58% overhead on the miner-to-pool bandwidth, for a total of 4.05GB daily overhead
> on the pool from 16,000 miners." — §9.4.1

Additions the earlier ingest omitted: TLS also costs *"a 5% overhead on the pool-to-miner
bandwidth, for a total of 3.13GB daily"*; Bedrock's *"percentage bandwidth overhead … is only
0.04%"*. **Important measurement caveat**: *"Stratum generates an average of 31.63 set difficulty
messages per day"* — the 12.03 s figure is the cost of encrypting only those ~31.63
messages/day/miner, **not share traffic**. Benchmarks: AES-256-CBC on a 40-core Xeon E5-2660 v2,
and the TLS numbers used a laptop standing in for the miner (*"AntMiner does not support TLS"*).

Inference accuracy re-verified: StraTap *"a prediction error of between 1.75% and 6.5%, with a
mean square error (MSE) of 0.062 and mean percentage error (MPE) of -3.46%"* (§9.1); ISP Log
*"an error that ranges between 0.53% and 34.4%, with an MSE of 2.02 and MPE of -9.49%"* (§9.2).
Both match the earlier ingest. Nit: Figure 11's caption gives MPE unsigned as "3.46%" while the
§9.1 prose gives "-3.46%"; cite the prose.

## 7. The pool is not merely trusted — it is the root of trust

> "We consider adversaries that can launch both passive and active attacks against the Bitcoin
> network, see Figure 1. **We assume that the pool and the miner are honest.**" — §3, p.61

> "Our work is orthogonal to previous work on Bitcoin anonymity … our concern is for the privacy
> and security of the miners, **as they generate coins**." — §10, p.72

"Anonymity" appears only in the related-work discussion of transaction/client anonymity
(Biryukov, Koshy, ZeroCoin, Zerocash, Mixcoin). Every §7.1 privacy claim is of the form *"a secret
known only by the miner and the pool."* The pool generates `R_M`, holds `K_M`, stores
`(M.uname, K_M, R_M, target)`, and recomputes `C_M` on every share.

The earlier ingest's "zero privacy from the pool" is supported and if anything **understated**:
the pool is the sole issuer of the cookie secret.

## Bearing on the thesis, per sub-claim

- **A (re-labeling resistance survives blinding) — SUPPORTED.** §7.1's argument turns on exactly
  one property: that the value hashed alongside `R_M` differs between victim and attacker. Nothing
  in it uses the *semantics* of `M.uname` — not readability, not registry, not uniqueness, not the
  pool's ability to interpret it. The failure mode described is a property of the hash. A blinded
  commitment preserves it, at a *lower* bar than the wiki assumed (see §3).
- **B (aggregation without a pool-side ID) — the paper CONFIRMS a persistent identity-keyed table
  is load-bearing, but supplies no aggregation mechanism to argue about.** `getMParams(M.uname)` is
  a persistent per-miner lookup; `target` lives in that row. B must be settled on the
  ecash/BBA+ side, not here. The wiki must **not** claim Bedrock says aggregation needs identity.
- **C (duplicate arbitration) — NOT TESTABLE against Bedrock.** No baseline exists.

## See also

- [[2026-07-29-recabarren-carbunar-hardening-stratum|First ingest of the same paper]] — everything
  else in it verified correct against the PDF
- [[../../wiki/theses/blinded-share-credit-commitment|Thesis: blinded share-credit commitment]]
- [[../../wiki/concepts/hashrate-inference-side-channels|Hashrate Inference Side Channels]]
