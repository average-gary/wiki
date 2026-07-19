---
title: "The Ark case for CTV (Delving Bitcoin #1528)"
source_url: https://delvingbitcoin.org/t/the-ark-case-for-ctv/1528
type: article
authors: [Steven Roose]
publisher: Delving Bitcoin
date: 2025-03-17
ingested: 2026-07-16
research_path: dropout
credibility: high
confidence: high
quality_score: 5
tags: [ark, clark, covenantless, interactivity, receiver-dos, griefing, musig2, node-policy, liveness, ctv]
summary: Steven Roose's articulation of the covenantless interactivity limitation and the receiver-DoS asymmetry — a fresh receiver with no VTXO at stake can stall/abort the cosigning ceremony for free, which is why clArk essentially cannot admit pure receivers into a round.
---

# The Ark case for CTV (Delving Bitcoin #1528)

stevenroose (Ark/Second protocol author), March 17–22 2025. Direct comparison of clArk vs covenant designs, focused on the dropout/DoS surface.

## clArk node construction
- Each intermediate tree node is a MuSig2 pre-signature of the server `S` plus all leaf-owners below that node, giving the policy `pk(S+A+B+C+..) OR (pk(S) AND after(T))` — the cooperative branch (everyone) OR the server-alone-after-timeout branch. This presigned n-of-n replaces the CTV covenant.

## The defining covenantless limitation — interactivity
- "Co-signed (clArk) VTXOs cannot be issued without the presence of the eventual owner." Because every node needs the downstream owners' signatures, a receiver must be online during the round.
- Consequence: clArk effectively restricts round participation to users who "have expiring VTXOs and need them refreshed" — i.e., sending to themselves. Non-interactive send-to-others (which CTV allows by letting anyone issue a VTXO from params `S` and `delta`) is not possible.

## DoS asymmetry (dropout/abort weaponized)
- "receivers are not associated with an existing VTXO. So they can't be penalized and have nothing to lose in performing a DoS attack on the round" — a fresh receiver with no VTXO at stake can repeatedly stall/abort the cosigning ceremony for free.
- This is why clArk essentially cannot admit pure receivers into a round — the core reason for the send-to-self restriction.

## What CTV unlocks that clArk cannot
1. send-to-others in rounds without out-of-round trust;
2. automatic VTXO reissuance by the server for expired positions (no owner online needed);
3. Lightning receive without the user participating (server accepts a hodl HTLC and issues the user's HTLC VTXO in the next round).
