---
title: "Is a covenantless post-block-found Ark boarding SV2 extension viable today? — analysis"
type: topic
created: 2026-07-17
updated: 2026-07-17
confidence: high
volatility: warm
verified: 2026-07-17
compiled-from: mixed
tags: [ark-boarding, sv2-extension, covenantless, post-block-found, n-of-n, coinbase, musig2, mining-payout, verdict]
sources:
  - raw/papers/2026-07-17-bip-341-taproot.md
  - raw/papers/2026-07-17-bip-118-anyprevout.md
  - raw/papers/2026-07-17-bip-327-musig2.md
  - raw/articles/2026-07-17-ark-protocol-clark.md
  - raw/articles/2026-07-17-roose-ark-case-for-ctv.md
  - raw/articles/2026-07-17-roose-evolving-ark-ctv-csfs.md
  - raw/articles/2026-07-17-braidpool-covenants-delving.md
  - raw/articles/2026-07-17-braidpool-spec.md
  - raw/articles/2026-07-17-narula-ark.md
  - raw/articles/2026-07-17-optech-ark.md
  - raw/articles/2026-07-17-ocean-datum.md
  - raw/articles/2026-07-17-hashpool.md
  - raw/articles/2026-07-17-arklabs-adios-expiry.md
  - raw/articles/2026-07-17-sv2-job-negotiation-proxy.md
  - raw/repos/2026-07-17-sv2-spec-extensions.md
  - raw/repos/2026-07-17-demand-share-accounting-ext.md
summary: "Verdict: PARTIALLY SUPPORTED (medium confidence). The cryptographic core is sound and confirmed today — post-block-found timing dissolves the unknown-coinbase-txid problem that APO/CTV exist to solve, so ordinary Taproot+MuSig2+timelocks suffice with no soft fork, and every primitive (MuSig2 'Deployed', clArk on mainnet, SV2 extensions) ships now. But 'viable' as an unqualified claim overreaches on three axes: n-of-n interactive signing does not scale to a pool's miner count (Braidpool caps signers ~50; 'large threshold Schnorr signing is impractical'); miners are the pure-receiver / one-dropout-aborts-all griefing case clArk is weakest at; and coinbase maturity+reorg forces boarding a matured proxy UTXO rather than the fresh coinbase. Viable in principle and buildable as a niche/small-set or proxy-delegated design; not viable as a drop-in trustless payout for thousands of miners."
---

# Is a covenantless post-block-found Ark boarding SV2 extension viable today?

> **Thesis**: An online-while-mining covenantless Ark boarding SV2 extension —
> n-of-n batch output, cosigning ceremony triggered post-block-found — is viable
> on Bitcoin today without CTV/CSFS.
>
> **Verdict**: **Partially Supported** (medium confidence). The mechanism is real
> and covenant-free; the word doing too much work is **"viable"**.

This article is the synthesis. It separates a claim that the evidence *confirms*
(the cryptographic core) from claims the evidence *contests* (scale, the receiver
trust model, coinbase timing), because the thesis bundles them together.

## 1. What the evidence confirms — the covenant-free core is sound

**Post-block-found timing mechanically dissolves the problem APO/CTV were invented
to solve.** The causal chain is airtight:

1. A default Taproot signature **commits to the outpoint** being spent — BIP-341's
   sighash message includes "`outpoint` (36): the COutPoint of this input", plus
   `sha_amounts` and `sha_scriptpubkeys` ([[../../raw/papers/2026-07-17-bip-341-taproot.md|BIP-341]]).
   So you cannot produce an ordinary signature over a spend until the funding
   **txid is known**.
2. A coinbase's txid is **unknown before the block is found** (it depends on BIP-34
   height, extranonce, miner tags) but **frozen the instant a valid block exists**.
   Rolling the extranonce *is* part of the mining search; when the header meets
   target, `coinbase_txid:0` is pinned.
3. Therefore: the entire reason [[../../raw/papers/2026-07-17-bip-118-anyprevout.md|APO (BIP-118)]]
   and CTV are cited for coinbase presigning is to commit to a spend **before the
   outpoint exists**. Trigger the n-of-n ceremony **after** the block is found and
   the outpoint already exists — so **ordinary MuSig2 signatures suffice**.

The Braidpool discussion states the same thing from the covenant side: APO is
wanted because "the update signature doesn't commit to the previous ... txid, so
you can pre-sign the next state before the current one hits the chain," versus
"standard Schnorr signing, which would require **waiting for the actual transaction
ID before signing can occur**" ([[../../raw/articles/2026-07-17-braidpool-covenants-delving.md|Delving #1370]]).
Post-block-found signing simply *chooses to wait* — and the wall vanishes.

**Every primitive is already live, no soft fork:**
- **MuSig2** (BIP-327) status is **"Deployed"**; it is explicitly *n-of-n*, Taproot-tweakable, and its on-chain footprint is "a single BIP340 public key" ([[../../raw/papers/2026-07-17-bip-327-musig2.md|BIP-327]]).
- **Covenantless Ark** (n-of-n presigned tree + ephemeral-key deletion) runs on **mainnet today** — Second's `bark`, live 2026-06-09 ([[../../raw/articles/2026-07-17-bark-mainnet.md|bark mainnet]]) — and its own docs say it "can ... be implemented on bitcoin today" ([[../../raw/articles/2026-07-17-ark-protocol-clark.md|ark-protocol.org]]).
- The **SV2 extension mechanism** is specified, negotiated (`RequestExtensions`), and backward-compatible, with accounting-adjacent extensions (`0x0002` worker hashrate) already registered ([[../../raw/repos/2026-07-17-sv2-spec-extensions.md|sv2-spec 09-Extensions]]). This repo's extension even ships a **`NewBlockFound` (0x03)** message — a natural ceremony trigger ([[../../raw/repos/2026-07-17-demand-share-accounting-ext.md|demand-share-accounting-ext]]).

So the falsification criterion "any required spending path needs CTV/CSFS/APO" is
**not met**: the batch output is `pk(S+A+B+…) OR (pk(S) AND after(T))` — an n-of-n
MuSig2 key-path plus a CSV/CLTV timeout script-path
([[../../raw/articles/2026-07-17-roose-ark-case-for-ctv.md|Roose #1528]]), all
expressible today. See [[../concepts/post-block-found-signing.md|post-block-found signing]].

## 2. What the evidence contests — why "viable" overreaches

### (a) n-of-n does not scale to a pool's miner count

This is the strongest counter-evidence, and it comes from the people actually
building non-custodial pool payout. Braidpool's spec: "**signing very large
threshold Schnorr outputs is impractical**," and its signer set is deliberately
capped at "around 50 signers" (the winners of the last *S* blocks), min 4 via the
`3f+1` rule ([[../../raw/articles/2026-07-17-braidpool-spec.md|Braidpool spec]]).
A pool has thousands of hashers; batching all of them into one synchronous n-of-n
ceremony is contradicted by the only reference design. Optech frames the same
ceiling for Ark: covenantless works "but would support significantly more users …
if covenant features like OP_CTV were added"
([[../../raw/articles/2026-07-17-optech-ark.md|Optech]]).

### (b) miners are the pure-receiver / griefing case clArk is weakest at

A clArk round is atomic and synchronous: "if even one user doesn't show up to
sign, S has to reconstruct the transaction tree … just one user each round can
keep S from making progress" ([[../../raw/articles/2026-07-17-narula-ark.md|Narula]]).
Worse, a **pure receiver has nothing at stake** and can grief the round for free;
"co-signed (clArk) VTXOs cannot be issued without the presence of the eventual
owner" ([[../../raw/articles/2026-07-17-roose-ark-case-for-ctv.md|Roose #1528]]).
Miners receiving a payout **are** pure receivers. clArk is "perfectly secure"
precisely where sender = receiver (self-refresh)
([[../../raw/articles/2026-07-17-ark-protocol-clark.md|ark-protocol.org]]) — the
opposite of a pool paying independent miners. See
[[../concepts/pure-receiver-and-liveness.md|the pure-receiver / liveness problem]].

The thesis's "online-while-mining" clause is the intended antidote, and it has
real force — but it needs a correction: Ark requires a *synchronous ~seconds
MuSig2 ceremony*, and the continuously-online party in SV2 is a **lightweight
proxy/JDC**, not the hashboard
([[../../raw/articles/2026-07-17-sv2-job-negotiation-proxy.md|SV2 job negotiation]]).
So liveness rests on proxy infrastructure holding the cosigning key, and
**delegated VTXO renewal** ([[../../raw/articles/2026-07-17-arklabs-adios-expiry.md|Ark Labs "Adios Expiry"]])
can shrink the individual-miner burden. This is what moves the verdict from
"contradicted" to "partially supported": the liveness objection is mitigable, but
only by leaning on proxies/delegation that pull the design toward a smaller
effective *n* or a pool-as-ASP trust posture.

### (c) coinbase maturity + reorg breaks the literal "fund the coinbase" reading

If the n-of-n batch output *is* the coinbase output, the VTXO tree cannot be
broadcast or exited for **100 blocks (~16.7 h)**, and a reorg in that window
**voids the entire batch**. Braidpool flags exactly this: coinbase maturity "needs
extra timelock layering" and a solo-mining fallback
([[../../raw/articles/2026-07-17-braidpool-covenants-delving.md|Delving #1370]]).
The workable design boards a **matured proxy UTXO** into the batch rather than the
fresh coinbase — which softens (but does not break) the clean "post-block-found"
story. This is a cost, not a blocker. See
[[../concepts/coinbase-maturity-and-reorg.md|coinbase maturity & reorg]].

## 3. The revealed-preference yellow flag (and the counter to it)

No one has shipped this. The team building covenantless mining payout (**hashpool**)
chose **custodial Cashu ecash**, not Ark
([[../../raw/articles/2026-07-17-hashpool.md|hashpool]]); Braidpool chose a FROST
federation plus a covenant wishlist; the CTV+CSFS support letter files
"non-custodial mining" under *covenant-gated* functionality
([[../../raw/articles/2026-07-17-ctv-csfs-letter.md|CTV+CSFS letter]]). Every
protocol author who touches this reaches for a soft fork to **remove** the
interactivity — "having CTV available allows us to fully eliminate all user
interactivity during Ark rounds" ([[../../raw/articles/2026-07-17-roose-evolving-ark-ctv-csfs.md|Roose #1602]]).

**But** the counter is real: **OCEAN/DATUM** already does non-custodial coinbase
payout today with no covenant — and hits a hard wall of "**roughly 100** payouts
per coinbase due to ASIC firmware limitations"
([[../../raw/articles/2026-07-17-ocean-datum.md|OCEAN/DATUM]]). A single batched
n-of-n Ark output that fans out to many more recipients is the *natural* next step
past that wall. So the thesis is an **incremental extension of a live paradigm**,
not a fantasy — it is novel and untested, not proven infeasible.

## 4. Verdict logic

| Sub-claim | Evidence | Holds? |
|---|---|---|
| No spending path needs CTV/CSFS/APO | BIP-341/118/327, clArk on mainnet | **Yes** |
| Post-block-found removes the unknown-txid problem | BIP-341 outpoint commitment + coinbase txid frozen at block-found + Braidpool | **Yes** |
| Deliverable as an SV2 extension | sv2-spec extensions + this repo's NewBlockFound trigger | **Plausibly** (net-new; nothing forbids it) |
| Unilateral exit for miners | CSV/CLTV script-path + presigned tree | **Yes, with maturity caveat** |
| Viable at pool scale (thousands of miners) | Braidpool ~50-signer cap; "large threshold Schnorr impractical"; one-dropout-aborts-all | **No** |
| Miners (pure receivers) served trustlessly | clArk secure only for sender=receiver; free receiver-DoS | **Contested** (needs proxy/delegation, stake/bans) |
| Fund the *fresh* coinbase directly | 100-block maturity + reorg voids batch | **No — board a matured proxy UTXO** |

**Net**: the *architecture* is viable on today's Bitcoin without CTV/CSFS. The
*unqualified "viable"* is not — it is viable as a **small-set or proxy-delegated,
online-while-mining** construction, and impractical as a trustless drop-in for a
full pool's miner base. The genuinely novel and untested piece — the timing —
works; the genuinely limiting piece — n-of-n liveness at scale — is exactly what a
covenant would fix.

## See Also

- [[../concepts/post-block-found-signing.md|Post-block-found signing dissolves the coinbase-txid wall]]
- [[../concepts/covenantless-batch-output-mechanics.md|Covenantless n-of-n batch output mechanics]]
- [[../concepts/pure-receiver-and-liveness.md|The pure-receiver / liveness problem for miner payees]]
- [[../concepts/coinbase-maturity-and-reorg.md|Coinbase maturity & reorg constraints]]
- [[../concepts/sv2-extension-surface.md|The SV2 extension surface for a cosigning ceremony]]
- [[../reference/alternatives-and-prior-art.md|Alternatives & prior art]]
- [[../../../covenantless-ark/_index|covenantless-ark]] · [[../../../sighash-anyprevout-bip118/wiki/topics/coinbase-outpoint-presigning|coinbase-outpoint-presigning]]

## Sources

See frontmatter `sources:` — BIP-341/118/327, Roose (Delving #1528/#1602), Braidpool (#1370 + spec), Narula, Optech, OCEAN/DATUM, hashpool, Ark Labs, ark-protocol.org, sv2-spec, this repo.
