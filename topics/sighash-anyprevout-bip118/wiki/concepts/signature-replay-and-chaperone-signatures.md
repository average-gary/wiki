---
title: "Signature replay & chaperone signatures"
category: concept
sources:
  - raw/articles/2026-07-16-bip-118-anyprevout-spec.md
  - raw/articles/2026-07-16-chaperone-signatures-mailing-list.md
  - raw/articles/2026-07-16-optech-anyprevout-topic.md
  - raw/articles/2026-07-16-cointelegraph-covenants-part3-anyprevout.md
created: 2026-07-16
updated: 2026-07-16
tags: [signature-replay, chaperone-signatures, anyprevout, noinput, apoas, address-reuse, footgun, opt-in]
aliases: [chaperone signatures, signature replay, NOINPUT_UNSAFE, replay footgun]
confidence: high
volatility: cold
verified: 2026-07-16
summary: "The central, designed-in criticism of NOINPUT/APO: because a signature doesn't commit to the prevout, it can be replayed against any output with matching properties (same script+amount for APO; same key for APOAS), risking loss of funds under address/script reuse. Chaperone signatures (a mandatory extra SIGHASH_ALL signature) were proposed then dropped; BIP-118 instead relies on the 0x01 opt-in key + tapscript-only scoping."
---

# Signature replay & chaperone signatures

> Omitting the outpoint is what makes [[rebindable-signatures|signatures rebindable]] ([signatures rebindable](rebindable-signatures.md)) —
> and it is also the primary danger. A valid APO signature can be **replayed** against a
> *different* output that shares the committed fields, potentially moving funds the
> signer never intended to move. The proposal's original name was literally
> `SIGHASH_NOINPUT_UNSAFE`.

## The replay surface

BIP-118 acknowledges this as a designed-in tradeoff: APO/APOAS "introduce additional
potential for signature replay … when compared to `SIGHASH_ALL`." Replay is possible:

- **APO**: against "different UTXOs with the same `scriptPubKey` and the same value."
- **APOAS**: against "any UTXOs that reuse the same BIP 118 public key" (amount and
  script uncommitted — a much wider surface).

Cointelegraph enumerates concrete high-risk scenarios: `ANYPREVOUT | SINGLE` when
outputs can be reordered; two UTXOs with identical script *and* amount; the same
pubkey across compatible scripts under APOAS; and **miners influencing transaction
ordering**. These "require either deliberate misuse or a failure … to account for
replay conditions during protocol design" — the danger is real but manageable with
disciplined protocol design.

## How BIP-118 bounds the blast radius

Rather than a single global fix, the spec scopes the danger three ways:

1. **Explicit opt-in** — only keys carrying the `0x01` prefix can be signed with APO,
   and they stay indistinguishable until spent (see
   [[anyprevout-sighash-semantics|ANYPREVOUT semantics]] ([ANYPREVOUT semantics](anyprevout-sighash-semantics.md))).
2. **Tapscript-only** — APO is forbidden on the taproot key path, so ordinary spends
   can never be replayed.
3. **Protocol responsibility** — implementers "must ensure keys are only reused where
   replay cannot cause fund loss."

## Chaperone signatures (proposed, then dropped)

A **chaperone signature** was a proposed mitigation: a *mandatory additional*
signature (a second key signing with `SIGHASH_ALL`) accompanying every APO signature,
so a third party could not unilaterally replay a floating signature — the APO key signs
with APO, the chaperone signs with ALL.

They were **rejected** because they add ceremony/complexity without meaningfully
closing the hole in the cases that matter: anyone able to construct a replay could
typically also produce the chaperone signature, and legitimate protocols (eltoo) manage
replay at the protocol layer anyway. Result: **no chaperone requirement in the final
BIP** — at most an optional PSBT signing hint. The same threads document the deliberate
decision to exclude APO from the taproot key path (ZmnSCPxj: cooperative closes don't
need APO).

## Relation to covenant/fungibility objections

APO is **not** a recursive covenant and enables no transaction introspection on its
own, so the strongest "recursion / perpetual restriction" fungibility objections aimed
at OP_CAT-style covenants largely **do not apply** to APO. The residual privacy concern
is address-reuse-driven replay and the on-chain distinguishability of APO-spent
outputs. This narrowness cuts both ways — it disarms covenant critics but also makes APO
look "not powerful enough" versus CTV/CAT to justify a soft fork (see
[[anyprevout-status-and-activation|status & activation]] ([status & activation](../topics/anyprevout-status-and-activation.md))).

## See Also

- [[rebindable-signatures|Rebindable signatures]] ([Rebindable signatures](rebindable-signatures.md)) — replay is the flip side of rebinding
- [[anyprevout-sighash-semantics|ANYPREVOUT sighash semantics]] ([ANYPREVOUT sighash semantics](anyprevout-sighash-semantics.md)) — the 0x01 opt-in and tapscript scoping
- [[coinbase-outpoint-presigning|Presigning against an unmined coinbase outpoint]] ([Presigning against an unmined coinbase outpoint](../topics/coinbase-outpoint-presigning.md)) — replay discipline in a pool-payout setting

## Sources

- [BIP-118 normative spec](../../raw/articles/2026-07-16-bip-118-anyprevout-spec.md) — replay-by-design, opt-in mitigations, chaperone dropped
- [Chaperone signatures (mailing-list threads)](../../raw/articles/2026-07-16-chaperone-signatures-mailing-list.md) — chaperone history + key-path exclusion
- [Optech — SIGHASH_ANYPREVOUT](../../raw/articles/2026-07-16-optech-anyprevout-topic.md) — the NOINPUT_UNSAFE naming episode
- [Cointelegraph — Covenants Part 3](../../raw/articles/2026-07-16-cointelegraph-covenants-part3-anyprevout.md) — enumerated high-risk replay scenarios
