---
title: "Thesis: I can splice a lightning channel in a coinbase transaction"
type: thesis
status: completed
created: 2026-07-23
updated: 2026-07-23
status_note: "verdict rendered 2026-07-23 after 5-agent thesis-mode research round (12 sources); BOLT #2 coinbase rule verified verbatim against master"
verdict: "Mixed — Contradicted (literal) / Not viable (charitable) / Supported (narrow)"
confidence: High
core_claim: "The on-chain transaction that modifies a Lightning channel's funding output (a splice) can be constructed as, or embedded within, a Bitcoin coinbase transaction."
key_variables: [coinbase-null-prevout-input, coinbase-maturity-100, lightning-splice-spends-funding, funding-output-enforceability, reorg-risk, presigning-unknown-coinbase-outpoint]
falsification: "Fails (Reading A) if a coinbase's mandatory null-prevout single input means it cannot spend the existing funding UTXO, which a splice definitionally must. Fails (Reading B) if coinbase maturity + reorg risk make a coinbase-borne funding output unspendable/unenforceable for 100 blocks, breaking LN safety."
---

# Thesis: I can splice a lightning channel in a coinbase transaction

## Core Claim

The on-chain transaction that modifies a Lightning channel's funding output — a
**splice** — can be constructed as, or embedded within, a Bitcoin **coinbase**
transaction.

The claim is ambiguous, so this thesis tracks **two readings**, one far stronger
than the other:

- **Reading A — literal splice-as-coinbase.** The splice transaction *is* the
  block's coinbase: it spends the existing channel funding UTXO and creates a new
  funding UTXO, while simultaneously being the generation transaction at position
  0 of a block.
- **Reading B — charitable, funding-output-in-coinbase.** A Lightning channel
  *funding output* (a fresh channel open, or the destination of a splice-in) is
  *created as an output* of a coinbase transaction. The "splice" then happens
  later, in an ordinary transaction that spends that (matured) coinbase output.

## Key Variables

- **Coinbase input structure** — a coinbase has exactly one input with a *null
  prevout* (32-byte-zero hash, index `0xFFFFFFFF`); it spends no existing UTXO.
- **`COINBASE_MATURITY = 100`** — coinbase outputs are unspendable until 100
  blocks later (~16.7 h).
- **Reorg risk** — a coinbase is invalidated if its block is reorged out; any
  output it created disappears.
- **Lightning splice semantics** — a splice *spends the current funding output*
  and *creates a new one*; requires cooperative signing over the existing funding.
- **Funding-output enforceability** — LN commitment transactions must be
  broadcastable at any time to enforce channel state.
- **Presigning the unknown coinbase outpoint** — a coinbase txid is unknowable
  until the block is mined (the `sighash-anyprevout-bip118` wall).

## Testable Prediction

If the thesis holds (Reading A): a single Bitcoin transaction can be valid both
as a coinbase (block position 0, null-prevout input) *and* as a BOLT splice
(spends prior funding output, creates a new funding output). If only Reading B
holds: a coinbase output can fund a *working, enforceable* Lightning channel.

## Falsification Criteria

The thesis is **contradicted** (for a given reading) if:
- **(Reading A)** A coinbase's mandatory single null-prevout input means it
  *cannot* spend the existing funding UTXO — which a splice definitionally must.
  (A splice is by definition a transaction that spends the old funding output.)
- **(Reading B)** Coinbase maturity + reorg risk make a coinbase-borne funding
  output unspendable/unenforceable for 100 blocks, breaking the LN safety property
  that a commitment tx can be broadcast at any time.

## Scope Boundary (bloat filter)

**Not part of this thesis**: general LN channel opening from ordinary txs; Ark
boarding as such (cross-link `ark-boarding-sv2-mining`); PPLNS payout-fairness
math; generic SV2 internals unrelated to coinbase output construction; covenant
soft-fork activation politics beyond "needed here or not."

## Evidence For

Which reading each supports is marked. Sorted strongest first.

- **[Strong · Reading B/C]** BOLT #2 `channel_ready` **explicitly anticipates a
  coinbase funding transaction**: "MUST wait for at least 100 blocks if the funding
  transaction is the coinbase transaction." *Verified verbatim against master
  2026-07-23.* The LN spec treats a coinbase-*funded* channel as a named, legal case.
  *(BOLT #2)* → [[../wiki/concepts/lightning-splice-mechanics|splice mechanics]]
- **[Strong · Reading C]** A splice-in accepts **any confirmed UTXO** — `tx_add_input`
  places no ancestry restriction and a matured coinbase output satisfies even
  `require_confirmed_inputs`. CLN `splicein` and Phoenix splice arbitrary confirmed
  wallet UTXOs on mainnet today. *(BOLT #2, ACINQ/Phoenix, CLN docs)* →
  [[../wiki/concepts/three-readings|Reading C]]
- **[Moderate · Reading B]** A coinbase output's scriptPubKey **can** be a 2-of-2
  P2WSH/P2TR funding script (BIP-141 allows arbitrary payout scriptPubKeys); the exact
  question was asked publicly and answered "possible but impractical." *(BIP-141,
  SE #115588 — low-cred, snippet-recovered)*
- **[Moderate · Reading B]** The presigning wall is **removable**: post-block-found
  signing (no soft fork) or BIP-118 APO make a spend of an as-yet-unmined coinbase
  signable. *(BIP-118, sibling ark-boarding-sv2-mining)* →
  [[../wiki/concepts/presigning-unknown-coinbase-outpoint|presigning wall]]

## Evidence Against

- **[Strong · kills Reading A]** A coinbase and a funding-spend are **mutually
  exclusive in consensus code**: `IsCoinBase()` requires one input with a *null*
  prevout (spends nothing); `tx_check.cpp` rejects a non-coinbase with a null input.
  A splice MUST spend the prior funding output (BOLT #2). No tx can be both.
  *(Bitcoin Core `transaction.h`/`tx_check.cpp`, BOLT #2)* →
  [[../wiki/concepts/coinbase-transaction-structure|coinbase structure]]
- **[Strong · kills usable Reading B]** `COINBASE_MATURITY = 100` makes a coinbase
  funding output unspendable for ~16.7 h; the commitment/force-close tx is
  *consensus-invalid* during that window, so the channel is **unenforceable**.
  Reorg voids it. `splice_init` can't fire until `channel_ready` = 100 blocks out.
  *(Bitcoin Core `consensus.h`/`tx_verify.cpp`, BOLT #2)* →
  [[../wiki/concepts/coinbase-maturity-vs-ln-enforceability|maturity vs enforceability]]
- **[Moderate · Reading A/B]** A coinbase **cannot exist as a loose transaction**
  (`validation.cpp` rejects it), so it can never be the negotiated/broadcast tx of an
  interactive splice session. *(Bitcoin Core `validation.cpp`)*
- **[Moderate · Reading B]** Zero-conf does **not** rescue it — the funding output is
  not merely unconfirmed but *unspendable*; zero-conf trust assumes eventual
  confirmation is the normal path. *(Optech zero-conf channels)*
- **[Moderate · revealed preference]** Every deployed mining→LN system routes around
  the claim: OCEAN/NiceHash pay off-chain LN payments; Braidpool uses one-way channels
  settled from *matured* rewards. *(OCEAN, NiceHash, Braidpool)*

## Nuances & Caveats

- **The claim is three claims.** [[../wiki/concepts/three-readings|Reading A]]
  (splice tx *is* the coinbase), [[../wiki/concepts/three-readings|Reading B]]
  (funding output *created by* a coinbase), [[../wiki/concepts/three-readings|Reading C]]
  (splice-in a *matured* coinbase UTXO). They get Contradicted / Not-viable /
  Supported respectively.
- **"in a coinbase" is the load-bearing phrase.** Reading C — the only true one — is
  really "splice coinbase-*descended* funds into a channel." The splice tx is an
  ordinary transaction; the coinbase is just the ancestor of one input. It is not
  a splice *in* a coinbase.
- **Two different walls, often conflated.** The *presigning* wall (unknown coinbase
  txid) is removable via post-block-found signing. The *maturity* wall (100-block
  unspendability → unenforceable channel) is not. Only the second is fatal to
  Lightning specifically.
- **Why the sibling Ark thesis survives what sinks this one.** An n-of-n Ark batch
  output tolerates the 100-block wait (it just isn't unilaterally exitable yet); LN
  requires unilateral force-closability from the instant funds are committed. The
  maturity window Ark shrugs off is exactly what an LN channel cannot accept. The
  natural fix — fund from a matured proxy UTXO — collapses Reading B into Reading C.
- **No exact prior art** funds or splices a channel with a *fresh* coinbase; the
  intersection is a non-topic in the authoritative literature (Optech has no coinbase
  page). Consistent with the verdict.

## Verdict

**Status**: **Mixed** — Contradicted (Reading A) / Not viable (Reading B) / Supported (Reading C)
**Confidence**: **High**

**Summary**: Taken literally, no — a splice transaction cannot *be* a coinbase,
because a splice must spend the existing funding output while a coinbase's sole input
has a null prevout and spends nothing; this is a type-level consensus contradiction.
Taken charitably (a channel funded *by* a coinbase output, spliced later), the BOLT
spec explicitly permits it but coinbase maturity (100 blocks unspendable →
unenforceable channel) plus reorg risk make it non-viable, and the natural fix
collapses it into the narrow reading. Taken narrowly (splice a *matured* coinbase UTXO
into a channel), it is simply true and deployable today via CLN `splicein` / Phoenix —
but that is splicing coinbase-descended *funds* into a channel, not splicing a channel
*in* a coinbase.

**Strongest supporting evidence**: BOLT #2 `channel_ready` naming the coinbase-funding
case (verified verbatim); `tx_add_input`'s no-ancestry-restriction + matured coinbase =
ordinary confirmed UTXO, spliceable by shipping wallets today.

**Strongest opposing evidence**: `IsCoinBase()` (single null-prevout input) vs BOLT #2's
mandatory funding-spend input — mutually exclusive; `COINBASE_MATURITY = 100` +
`bad-txns-premature-spend-of-coinbase` making a fresh-coinbase-funded channel
unenforceable for the maturity window.

**Key caveats**: the true reading (C) is "matured coinbase *funds* → splice-in," not a
splice literally inside a coinbase; the fatal wall is maturity, not the (removable)
presigning wall; LN cannot accept the 100-block unenforceability window that the sibling
Ark construction tolerates.

**What would change this verdict**:
- A consensus change permitting a coinbase to spend an input, or removing coinbase
  maturity → toward Supported for A/B (essentially impossible; foundational rules).
- A soft fork activating covenants/APO **plus** a maturity-independent enforcement
  path (e.g. a delegatable force-close that doesn't spend the immature output) →
  toward viable-B. Not on the horizon.
- Demonstrated wording that treats "in a coinbase transaction" as "from a coinbase
  output" would move the *stated* claim toward Reading C's Supported verdict.

**Suggested follow-up theses**:
1. "A mining pool can non-custodially open Lightning channels to its miners by paying
   coinbase outputs to 2-of-2 funding scripts and waiting out coinbase maturity —
   trading 100-block latency for trustlessness." (Tests viable-B at the latency cost.)
2. "Post-block-found MuSig2 signing lets a pool presign spends of its own coinbase
   into channel funding, but coinbase maturity — not the txid wall — is why this beats
   nothing for Lightning specifically." (Isolates which wall matters.)
3. "Splicing matured coinbase rewards directly into miner channels (Reading C) is a
   strictly better non-custodial payout primitive than OCEAN's BOLT12 off-chain
   payouts for miners who want inbound LN liquidity." (Tests Reading C's usefulness.)

