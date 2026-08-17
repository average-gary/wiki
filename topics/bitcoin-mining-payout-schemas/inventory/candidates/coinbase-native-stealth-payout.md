---
title: "Coinbase-native stealth payout — supply the sender pubkey BIP 352 can't find"
kind: question
status: open
priority: p2
created: 2026-08-14
updated: 2026-08-16
last_checked: 2026-08-16
next_action: "Write the spec diff against BIP 352's Sender/Receiver sections (close-out condition 1) — the executable check now exists, passes, and is published: https://github.com/average-gary/sp-coinbase-vectors (11 cases: 4 positive, 5 negative controls, 2 carriers, all green; bips clone untouched). Settle in the diff: fresh hash tags (SP-Coinbase/Inputs, SP-Coinbase/SharedSecret) vs. BIP0352 tag reuse, and the silent-payments version byte from bip-0352.mediawiki:152-176. Leading variant is the out-of-band A_send list indexed by height (0 on-chain bytes); on-chain carriers are the witness-commitment optional-data field at bip-0141.mediawiki:74 and the scriptSig-as-pool-tag (case 12), the latter no longer demoted for budget contention."
sources:
  - raw/notes/2026-08-14-ll-coinbase-silent-payments-ecdh-nonce.md
  - raw/repos/2026-07-29-bip352-silent-payments-coinbase-incompatibility.md
  - wiki/topics/self-blinding-pool-design-space.md
  - wiki/concepts/coinbase-address-rotation.md
  - wiki/concepts/xpub-payout-identity.md
tags: [bip352, silent-payments, coinbase, bip34, ecdh, stealth-address, forward-secrecy, payout-privacy, open-problem, unbuilt]
confidence: medium
summary: "BIP 352 excludes coinbases because a coinbase input has no public key — not because it lacks a nonce. BIP 34 mandates the block height, which is a better nonce than outpoint_L and is not gap-limit bound. Supply a sender point deliberately and the construction closes. Unbuilt, unspecified, and it resolves the height-as-index blocker this wiki had recorded against Part A."
---

# Coinbase-native stealth payout

## Why Track This

This is the **first Part A mechanism with a forward-secrecy knob**, and it reopens a design
branch [[../../wiki/topics/self-blinding-pool-design-space|Self-Blinding Pool Design Space]] had
closed on a diagnosis that turned out to be half right.

The 2026-07-29 round established, correctly, that BIP 352 v0 cannot be used in a coinbase. The
2026-08-14 round found the *reason* matters: the failure is an **absent sender pubkey `A`**, which a
purpose-built key can supply, not an **absent nonce**, which nothing could. BIP 34 already mandates
the block height in the coinbase scriptSig, and the height beats `outpoint_L` on every axis a nonce
needs — shared, non-circular, consensus-uniquely monotonic, and *dense* rather than merely distinct.

It also **dissolves a blocker recorded three times in this wiki**: BIP 44's gap limit of 20 binds a
BIP 32 child index in a forward-scanned chain, not an ECDH nonce mixed into a shared secret. Greg
Maxwell's block-height-as-index is fatal under BIP 380 wildcards and free under a stealth
construction. That is the same idea with the opposite verdict, and only the first half was recorded.

Two properties make it worth more than the descriptor path it would replace:

- **Erasable key material.** An ephemeral `A` has no spending role, so the pool can destroy it once
  the block is found — § Compulsion's *"data never collected"* applied to receiver privacy. No other
  Part A mechanism has this.
- **No new linkage.** There is no descriptor for the pool to retain, so it avoids the cost the
  design-space article flags against the xpub path: *"the pool now holds the descriptor that links
  all of a miner's rotated addresses together."*

## Current State

**Open — unspecified, but the executable check exists and passes.** The construction closes on
paper and now also in code, published 2026-08-16 at
[average-gary/sp-coinbase-vectors](https://github.com/average-gary/sp-coinbase-vectors)
(local: `~/repos/sp-coinbase-vectors/`, 2026-08-14). It holds JSON test vectors
mirroring `send_and_receive_test_vectors.json`'s schema plus an assert-based runner — baseline
(28 vendored BIP352 vectors, unmodified `reference.py`) green, then 11 cases: the split in an
ordinary tx, the coinbase native case (null prevout, BIP 34 height nonce), the N=5 fan-out with
the drop-output contrast against `:319`, nonce distinctness both directions, five negative
controls that each demonstrate their failure mode (vanilla BIP352's `:193` gate rejecting the
coinbase; constant-null-outpoint nonce colliding across blocks; the `:92` replay transposed when
`input_hash` omits the key or binds a static third key, and killed by binding `A_send`; odd-Y
`A_send` scan miss with negation omitted; the group-linear compressed list `A_H = A_0 +
H(A_0‖H)·G` yielding every epoch secret from `a_0`), and case 11: `A_send` conveyed by the fee
output itself as a bare 1-of-2 multisig (see the table). **The construction was not broken in any way
the note didn't anticipate** — every negative control failed exactly where Lesson 8 said it would.
One small finding the note didn't state: the transposed `:92` attack survives the even-Y rule —
the attacker's scalar must merely be ground to even Y (try the next height), so parity is no
defense; only binding `input_hash` to `A_send` is. Two decisions are flagged, not settled: fresh
hash tags (`SP-Coinbase/Inputs`, `SP-Coinbase/SharedSecret`) were used to domain-separate from
BIP 352 rather than reusing `BIP0352/*`; and bech32m/address versioning was skipped entirely
(raw `(B_scan, B_spend)` hex), since the version byte at `:152-176` is an unresolved question.
`A_send` is modeled x-only on the wire with the `:299` even-Y rule transposed (case 8 pins it).

**Shape**: a one-payer fan-out. `txOut[0]` (the pool's fee output) is the payer of record for
`txOut[1..N]`, each `n` a **distinct paid miner**. One sender point `A`, one nonce (the height),
`N` recipients. Two consequences follow from paying many distinct scan keys once rather than one
scan key many times: every output sits at **`k = 0`** in its own group, so `:319`'s contiguity
footgun and `K_max` both drop out and a dropped output cannot destroy another miner's
discoverability; and `a` becomes a **single key unlocking the whole block's payee set**, so the
forward-secrecy defect below is amplified by `N` rather than being per-payment.

The open design decision is where `A` comes from, and the two variants are not equivalent:

| Variant | Marginal cost | Forward secrecy | Operational cost |
|---|---|---|---|
| **Out-of-band `A_send` list, indexed by height** ← **leading** | **0 bytes on-chain** (33 B/epoch over stratum) | **Yes** — erase each `a_send` at maturity | Pool must serve a pubkey list and hold unused secrets; list is a linkability trust surface |
| Ephemeral key in witness-commitment output, byte 39+ | 33 B / 132 WU, no new output | **Yes** — erase `a_send` at block-found | CSPRNG call only; `bip-0141.mediawiki:74` optional-data field, no scriptSig contention |
| Bare 1-of-2 multisig fee output: `OP_1 <A_send> <A_pool> OP_2 CHECKMULTISIG` | +37 B vs P2TR ≈ 148 WU, no new output | **Yes** — erase `a_send` at block-found (`a_pool` signs 1-of-2 alone; `a_send` never signs) | Fee output leaves the taproot set (standard, ≤3 keys, but rare in coinbases); only the pool's own output is fingerprinted. **Executable: case 11.** |
| Ephemeral key in coinbase scriptSig | 33 B / 132 WU | **Yes** | Was demoted for budget contention — **contention dissolved 2026-08-14: the A_send push IS the pool tag** (scriptSig = height ‖ extranonce ‖ push33(A_send), 46 B total, nothing else). With the list served publicly, "tag == entry H of pool X's list" is unforgeable attribution. Keep clear of rolled extranonce bytes (Lesson 4). **Executable: case 12.** |

**Can the fee output carry `A_send` while `a_pool` (not `a_send`) spends it?** As a *taproot*
output: **no** — a P2TR output exposes exactly one group element and that element's discrete log
is the keypath spending secret, so "scanner can read `A_send` from the output" and "holder of
`a_send` can spend the output" are the same property. The escapes all fail: `A_send` as internal
key with `a_pool` in a script leaf hides `A_send` until the output is *spent* (scanners scan
unspent outputs); committing `A_send` into the tweak is one-way; deriving `A_send` publicly from
`A_pool` is the group-linear case — with the *treasury key* as the seed, worse than case 9. But as
a **bare 1-of-2 multisig** it works, because bare multisig is the one output type that reveals its
keys while `m = 1` lets either holder sign alone: the scanner parses key 0, the pool spends with
`a_pool`, and `a_send` is erasable at block-found. Cost is +37 B over a P2TR fee output (≈148 WU),
16 WU dearer than the witness-commitment slot, which is why that slot stays ranked first among
on-chain carriers. **And yes — the scriptSig works as a carrier too** (the row above): with
`A_send` in *any* data field (scriptSig or witness commitment), the fee output is completely
unconstrained — the pool pays itself to whatever it wants. The one hard rule is Lesson 4's:
`A_send` must sit in the template-fixed portion of the scriptSig, never overlapping the extranonce
bytes miners roll. Naming caution: three keypairs now coexist — pool spend `a_pool`, send-ECDH
`a_send`, miner `b_scan`/`b_spend`; don't let "the spend key" drift between them.
| Pool P2TR fee output at `txOut[0]` | 0 bytes | **No, permanently** — pool must retain `a` to spend its fee | **Contradicts its own defense** — see below |
| Fee output as one-time hot key, swept then erased | 0 bytes | After ~100-block maturity | A sweep tx per block; loses key-only retroactive payout audit |

**The framing that reorders this table: BIP 352 fuses the sender's ECDH key with its signing key,
and a pool can un-fuse them for free.** `:244` uses *the spending key* for ECDH because `:99` requires
the receiver to reconstruct `A` from chain data alone, and the only pubkeys a transaction exposes are
its input pubkeys. Give the sender a dedicated `a_send` used only for ECDH (`ecdh = input_hash·a_send·B_scan`,
with `input_hash` re-bound to `A_send` per the `why_include_A` attack at `:92`) and compromise of the
online key costs **privacy, never money** — the same downgrade the receiver's `b_scan` buys.

It cannot be made free by derivation, and this closes a family of designs rather than one: the
receiver needs `A_send = f(A, public data)` evaluable in the group while the sender needs
`dlog(A_send)`, so in the generic group model either `f` is linear (`A_send = s·A + T` ⇒
`a_send = s·a + t`, unlocked by anyone who ever learns `a` — cosmetic) or it is not (hash-to-curve ⇒
nobody knows the dlog, sender included — unusable). **Key separation always costs transmitted bytes;
the only design freedom is which channel pays.** The receiver's split is free because the silent
payment address carries 66 B of pubkey off-chain. A pool has the same kind of channel — a stratum/SV2
session with every payee — which a general anonymous sender does not, hence row 1.

Session recommendation *before* the sender-split framing was the scriptSig ephemeral, now demoted to
row 3: the objection that reusing the real fee output
leaves no fingerprint doesn't bite, because hasher outputs are indistinguishable taproot keys either
way and the only thing tagged is the pool, which is already public.

**The fee-output variant's defense is self-cancelling, and this is the sharpest argument against it.**
Operator objection, granted on its own terms: *a key that collects the pool's own fees will be well
guarded* — strongest possible incentive, and it does retire the "sloppy key hygiene" worry. But the
guarding practices that make the premise true are the ones the mechanism forbids. Per-block ECDH
needs `a` online in the template path every ~10 minutes; well-guarded at pool scale means cold or
threshold-held. If it *is* threshold-held, `bip-0352.mediawiki:244` turns each block into a
collaborative ECDH ceremony (possibly with a DLEQ proof) and `:38` states there is **no security
proof for the collaborative setting**. So: cold treasury key, or per-block ECDH key — not one key
that is both. Separately, guarding is orthogonal to compulsion (§ Compulsion, Lavabit) and to the
`N`-amplification above, and a well-guarded key is *long-lived* by design, so exposure accumulates
over every block it sat at index 0.

This makes **row 3 the real contender**, not a compromise: a one-time hot key at index 0 keeps the
0-byte cost, needs no cold-key exposure (it was never a treasury key), and becomes erasable at
maturity.

Settled in-session, not open: the **extranonce is ruled out** as the nonce — miners roll it during
PoW search, so deriving outputs from it forces a template rebuild plus EC math per roll. Prev-hash
is template-fixed and remains available as a mix-in for the same-height-reorg case.

## Close-out Condition

Any one of:

- a written spec diff against BIP 352's Sender/Receiver sections with a version byte from the table
  at `bip-0352.mediawiki:152-176`, reviewable by someone who implements silent payments; **or**
- a demonstration that the scanning cost estimate is wrong by enough to kill it — the ~500 B/block
  (~2 MB/month) figure is in-session arithmetic, not measured, against BIP 352's own 7–12 kB/block
  general case (`:468`); **or**
- a determination that the coinbase output-count and dust ceilings this wiki already documents
  (DATUM ~380–530, Avalon 63-char truncation, Whatsminer overflow past 127, 330-sat taproot dust)
  bound the payee set so tightly that per-hasher coinbase payouts aren't the right rail regardless —
  which would close this as *correct but misaimed*, and route the work to a second-stage tx.

## Notes

- **Prior-art status unchanged and worth re-confirming before any writing.** The 2026-07-29 round
  found zero delvingbitcoin topics for "silent payments coinbase" / "coinbase address rotation", no
  mining mention on Optech's silent-payments page, and no proposal anywhere for a coinbase tweak
  substitute. Re-verified 2026-08-14 that `grep -ic coinbase bip-0352.mediawiki` is still **0**
  across 524 lines at v1.1.1. Genuinely unexplored, not explored-and-rejected.
- **Unusually good light-client story, and this is the load-bearing unverified claim.** The coinbase
  is transaction 0, so its merkle branch is short and its position needs no trust: header (80 B) +
  branch (~12 hashes, ~384 B) + `A` (33 B) ≈ 500 B/block, provable against the header. That would
  close BIP 352's own open question at `:466` — *"how Bob can source the 33 bytes per transaction in
  a trustless manner"* — for the coinbase-scoped case. **This is my reasoning, not a cited result.**
  Needs someone to check whether a merkle-branch-only client inherits BIP 158's assumptions cleanly.
- **Threat model, stated so it isn't overclaimed**: the pool computed the payouts and knows who got
  what. This defends against third-party chain observers only — the same boundary as all of Part A,
  and the same reason *"a pool's attribution knowledge derives from share validation, not from
  payment."* It does nothing for Part B.
- **Implementation details already settled**: even-Y negation required, scanners read x-only and
  assume even Y (`bip-0352.mediawiki:299`); index 0 must be P2TR or the fee-output variant silently
  fails; the witness commitment does not contend for index 0 since BIP 141 takes the *highest*-index
  matching output (`bip-0141.mediawiki:78`); `K_max = 2323` caps outputs per scan key, not payees, so
  block weight is the binding limit and firmware ceilings bite far earlier.
- **Interaction with withholding detection.** Fresh-per-block outputs defeat the Eligius 2014
  two-address clustering, the only withholding detection that has worked in production. That cost is
  already recorded against Part A and applies here unchanged — see
  [[../../wiki/concepts/block-withholding|Block Withholding]].
