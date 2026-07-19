---
title: "Lessons Learned: Proxy-held VTXO keys + SV2 extension for Ark mining payouts"
type: lessons-learned
source: session
date: 2026-07-18
tags: [lessons-learned, ark, vtxo, sv2-extension, mining-proxy, custody, clark, receiver-presence]
lesson_count: 4
category: notes
confidence: high
summary: "A mining proxy that holds VTXO keys neutralizes Ark's receiver-presence and expiry blockers (making clArk viable without CTV/CSFS), but reshuffles custody rather than removing it; an SV2 'claim your hashrate in the Ark' extension only becomes trust-reducing if it carries VTXO leaf/path + leaf-exclusivity proofs, not just the accounting amount."
---

# Lessons Learned: Proxy-held VTXO keys + SV2 extension for Ark mining payouts

> Extracted from session on 2026-07-18. 4 lessons from analyzing a proposed design — a mining proxy holding VTXO keys plus an SV2 protocol extension letting miners "claim" their hashrate share inside an Ark — against the existing wiki. Design-reasoning session (learned by analysis, not implementation). Follows the 2026-07-15 query "How might we design an Sv2 extension enabling miner interactivity for Ark boarding via the coinbase tx?" and the coinbase→VTXO-tree material in [[../../wiki/concepts/ctv-coinbase-payout-tree]] / [[../../wiki/concepts/ark-for-mining-payouts]].

## Lesson 1: An always-online proxy holding VTXO keys neutralizes BOTH Ark blockers — and unlocks clArk without a soft fork

**Category**: discovery
**Context**: Evaluating whether "a mining proxy holds VTXO keys and issues VTXOs to miners" is a coherent way to make Ark fit mining payouts.
**Symptom**: The two structural blockers in [[../../wiki/concepts/ark-for-mining-payouts]] — clArk's *receiver-presence requirement* (a pool cannot issue a VTXO to an offline miner) and *VTXO expiry* (7-day arkd / 4-week bark sweep unless someone refreshes) — appear to kill Ark-for-mining outright.
**Root cause**: Both blockers assume the *miner* must be the present/live party. They dissolve if a different always-online party stands in.
**Fix**: Put an always-online proxy in the receiver/refresh role: it is "present" at issuance and runs the hArk-style delegated refresh that prevents expiry-sweep.
**Rule**: An always-online proxy in the receiver+refresh role collapses Ark's receiver-presence and expiry blockers simultaneously — and because presence is solved without covenants, covenantless **clArk becomes viable for mining today, removing the CTV/CSFS activation dependency** that gates the coinbase→VTXO-tree approach. (The article already named "delegated-refresh watchtower" as the only fix; this makes explicit that the same move also unlocks clArk.)

## Lesson 2: "Proxy holds VTXO keys" is a custody reshuffle, not trust-minimization — judge it against LN and Cashu, not against TIDES

**Category**: correction
**Context**: The design was framed as a path to *non-custodial* Ark mining payouts.
**Symptom**: Framing treats proxy-held-Ark as belonging to the non-custodial coinbase tier alongside TIDES/SLICE.
**Root cause**: If the proxy holds the keys, the miner trusts the proxy — exit-scam, refusal-to-cosign-exit, and seizure risk all return. Per [[../../wiki/decisions/custody-tradeoffs]] this lands between Lightning-custody (Parasite Pool) and mint-custody (eHash), NOT on the no-custody coinbase tier.
**Fix**: Reclassify the design honestly as custodial/semi-custodial and benchmark it against the layers with the same trust profile.
**Rule**: Any "off-chain payout layer where the pool/proxy holds keys" is a custody model, not a custody removal; the sharp question becomes "what does proxy-held Ark buy over Lightning-custody or a Cashu mint (both more mature, same trust profile)?" — and the wiki's answer is only a narrow mid-frequency/mid-size niche.

## Lesson 3: Ark-for-mining custody is a forced binary — you cannot have "proxy handles everything offline" AND "miner trustlessly in control"

**Category**: pattern
**Context**: Deciding the key-holding topology for the proxy design.
**Root cause**: The offline-convenience and self-custody goals are in direct tension in Ark's exit/refresh model.
**Fix**: Choose explicitly between two sub-designs and state which: (a) **proxy sole-holder** → fully custodial, miner cannot unilaterally exit without the proxy; (b) **proxy co-signer, miner co-holds a key** → non-custodial, but the miner must be present to exit/refresh, reintroducing the exact receiver-presence problem the design was meant to dodge.
**Rule**: In proxy-mediated Ark payouts, "proxy handles everything while the miner is offline" and "miner is trustlessly in control" are mutually exclusive — pick one and name it; there is no topology that delivers both.

## Lesson 4: "Claim your hashrate in the Ark" conflates two layers — a trust-reducing SV2 extension must carry VTXO leaf/path + exclusivity proof, not just the amount

**Category**: gotcha
**Context**: Specifying what an SV2 mining-subprotocol extension for Ark-claiming would carry on the wire.
**Symptom**: "Exchange the data for miners to claim their amount of hashrate" reads as a single step but is two.
**Root cause**: Share-accounting (hashrate → BTC *amount*) is already verifiable via the existing extension-type-32 [[../../wiki/concepts/sv2-share-accounting-ext]]. Turning that amount into a *spendable* VTXO additionally requires the miner's leaf, the tree structure, and exit/refresh paths+signatures — plus enough to independently validate the leaf is exclusively theirs. The Ark article flags this exact gap: "path-exclusivity unverified"; V-PACK gives verifiable backup "but no anonymous transfer."
**Fix**: Design the extension to carry VTXO tree/leaf/path data and a leaf-exclusivity proof, mirroring how type-32 makes payout trust-*reducing* (merkle-path spot-checks) rather than trust-relocating.
**Rule**: A "claim your payout in the off-chain layer" protocol has two layers — verify the *amount* (accounting) and verify the *instrument is exclusively spendable by you* (VTXO leaf-exclusivity); an extension that carries only the amount relocates trust to the proxy instead of reducing it, unlike SV2 extension type-32 which proves inclusion cryptographically.
