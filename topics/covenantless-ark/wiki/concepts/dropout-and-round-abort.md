---
title: "Dropout, round abort, and the griefing surface"
type: concept
created: 2026-07-16
updated: 2026-07-16
confidence: high
tags: [ark, clark, dropout, round-abort, freeze, griefing, dos, receiver-dos, liveness, interactivity, ban]
---

# Dropout, round abort, and the griefing surface

Because a clArk [[clark-round-lifecycle.md|round]] is a **synchronous n-of-n ceremony**, the behavior when a participant drops out mid-round is a core property — and the source of clArk's defining limitations.

## What happens on dropout

A round is **atomic**: it either completes fully or aborts. "If any participant fails to submit, the round is aborted" ([[../../raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md|DeepWiki]]). An aborted round leaves **no on-chain footprint** — no funds move — and honest users simply retry in a subsequent round. There is no partial settlement.

The fragile step is the [[tree-presigning-musig2.md|MuSig2]] nonce + partial-signature exchange, which requires all cosigners present *simultaneously*. A single non-responder stalls the session until it times out, then the round aborts. The operator can exclude the non-responder and rebuild the round for the remaining participants, but the explicit cost of that rebuild (added latency, the excluded user must retry) is only lightly documented — a noted gap.

## The "freeze" framing

"Freeze" is not a distinct protocol state so much as the *effect* of the atomic-abort rule plus the liveness dependency:

- **User-side**: a user must be online during a round to refresh before their VTXO expires; if they stay offline past expiry the ASP sweeps their funds (see [[unilateral-exit-and-timeouts.md|timeouts]]).
- **Operator-side**: "When the operator goes offline, users cannot initiate new transactions until the operator returns" — funds remain safe (unilateral exit still works) but no *new* activity is possible ([[../../raw/articles/2026-07-16-implementations-arkade-os-docs.md|Arkade docs]]).

## The receiver-DoS asymmetry (the deep problem)

Steven Roose identifies why dropout is *weaponizable* in clArk specifically ([[../../raw/articles/2026-07-16-dropout-roose-delving-ark-case-for-ctv.md|Delving #1528]]):

- A pure **receiver** has no existing VTXO in the round — "receivers are not associated with an existing VTXO. So they can't be penalized and have nothing to lose in performing a DoS attack on the round."
- A malicious receiver can therefore repeatedly join and abort the cosigning ceremony **for free**, griefing every honest participant.
- Consequence: clArk essentially **cannot admit pure receivers** into a round. "Co-signed (clArk) VTXOs cannot be issued without the presence of the eventual owner," so round participation is effectively restricted to users **refreshing their own** VTXOs (sending to themselves).

This is why clArk needs [[out-of-round-payments.md|out-of-round (OOR) payments]] for actually sending value to others, and why CTV variants — which let the server issue a VTXO from parameters without the receiver present — are pitched as the fix.

## Interactivity and griefing are one mechanism

Roose's canonical framing: in clArk "users have to do something synchronously and **the bad actions of certain users will affect all other users**" ([[../../raw/articles/2026-07-16-foundations-roose-delving-clark-policies.md|Delving #1602]]). The liveness burden (everyone must be online) and the griefing surface (anyone can stall the round) are the same property of the all-or-nothing synchronous n-of-n round.

## Anti-griefing responses

- **Bans**: arkd bans misbehaving scripts for a default **300 seconds** ([[../../raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md|DeepWiki]]).
- **Checkpoint transactions** (arkd): let the operator defend against a griefing exit with a single on-chain transaction rather than broadcasting whole offchain chains. See [[checkpoint-transactions.md|checkpoint transactions]].
- **Covenant successors** (Erk/hArk): remove synchronous participation entirely so a dropout cannot stall others. See [[../topics/clark-vs-covenant-ark.md|clArk vs covenant Ark]].

## See also

- [[clark-round-lifecycle.md|Round lifecycle]]
- [[unilateral-exit-and-timeouts.md|Unilateral exit and timeouts]]
- [[out-of-round-payments.md|Out-of-round payments]]
- [[checkpoint-transactions.md|Checkpoint transactions]]
- [[../topics/clark-limitations-and-trust.md|Limitations and trust model]]
