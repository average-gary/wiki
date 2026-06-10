---
title: CLINK Debits Specification (clink-debits.md)
source: https://raw.githubusercontent.com/shocknet/clink/main/specs/clink-debits.md
type: article
ingested: 2026-06-09
path: security
quality: 5
credibility: high
tags: [clink, security, threat-model, nostr, debits, ndebit, nip-44, replay-protection, authorization, custody]
---

## Source overview

`clink-debits.md` is the canonical specification for the CLINK Debits primitive — `ndebit1...` authorization pointers that let an application pull a payment (single, recurring, or unrestricted/persistent) from a user's wallet/node service. It is the CLINK doc with the most explicit "Security Considerations" section, and it is the primitive where the threat surface is largest because Debits is fundamentally a *delegated spend* primitive. Event kind is `21002`. Encrypted under NIP-44 only.

## Key findings

- **NIP-44 is mandatory; NIP-04 is not mentioned anywhere.** "All `content` payloads MUST use NIP-44 encryption between the requestor and node service." This decisively closes the question for Debits — CLINK does not run on the deprecated NIP-04 channel.
- **Replay protection is enforced two ways: a 30-second `created_at` delta + single-use session identifier (`k1`).** "Code 3 (Expired Request)... Request timestamp too old, e.g., >30s delta." And: "The node service SHOULD treat each `k1` as single-use within the scope of the target `pointer`." Note both are SHOULD/recommended, not MUST.
- **Three authorization shapes exist, with very different blast radii**: (a) one-shot bolt11 invoice, (b) budget with frequency `{number, unit ∈ day|week|month}`, (c) "request with no `bolt11`, no `amount_sats`, and no `frequency` is implicitly a request for unrestricted access." The last is a persistent/static authorization meant for "subscriptions, pre-approved debits."
- **No revocation primitive is defined in the spec.** The authorization model assumes the node service enforces budgets atomically and tracks per-app pubkeys, but there is no on-Nostr "revoke this pointer" event. Revocation is implicit/out-of-band: the user must instruct their node service directly.
- **Custody is undefined in spec but architecturally fixed**: the node service holds funds and processes payments. The spec calls it "the backend identified by TLV `0`. Receives kind `21002` events and processes debits per its policy." Whether it is user-operated, third-party-custodial, or hybrid is policy, not protocol.
- **Malicious-service mitigation: payer must verify invoice amount.** "node service MAY require `amount_sats` even for direct payments to process rules without decoding... MUST verify the invoice amount upon payment." This blocks amount-inflation by a service that crafts a different bolt11 than the user expected.
- **Race conditions are explicitly called out**: "Node services should ensure payment processing and budget deduction are atomic to prevent race conditions or overspending." This is unusual to see in a spec body and reflects awareness that budget pointers are exactly the place double-spend bugs land.

## Threat model components

| Asset | Threat | Mitigation in spec |
|---|---|---|
| User funds (custodied at node service) | Malicious app exhausts budget via concurrent debits | Atomic payment+deduction (SHOULD) |
| Authorization pointer (`ndebit1`) | Replay of an expired authorization | `created_at` delta ≤30s + single-use `k1` |
| Bolt11 amount integrity | Service pads invoice with extra sats | `MUST verify the invoice amount upon payment` |
| Per-app authorization scope | App A acts as App B | "Permissions should be granular (per-app pubkey, per-pointer ID if used)" |
| Spam / DoS on listening relay | Attacker floods kind 21002 | GFY code 4 (Rate Limited); NIP-56 reputation suggested |
| User comprehension of persistent auth | User grants unrestricted access without realizing | "User Education: Users must understand the implications of granting permissions, especially for automatic approvals or recurring budgets" |

## Direct quotes

1. "All `content` payloads MUST use NIP-44 encryption between the requestor and node service."
2. "The node service SHOULD treat each `k1` as single-use within the scope of the target `pointer`. While a session is pending approval or payout, the node service SHOULD reject a duplicate `k1` with a GFY response."
3. "request with no `bolt11`, no `amount_sats`, and no `frequency` is implicitly a request for unrestricted access."
4. "Node services MUST implement strong authorization logic. Permissions should be granular (per-app pubkey, per-pointer ID if used) and constrained by user-approved budgets/rules."
5. "Node services should ensure payment processing and budget deduction are atomic to prevent race conditions or overspending."

## Open questions

- **Revocation has no on-protocol expression.** If a user's app key is exfiltrated, the only remedy is to instruct the node service out-of-band to delist that app pubkey. There is no `kind 21003 "revoke"` event or equivalent. How does this scale to e.g. an app subscribed across many node services?
- **The 30-second window is a SHOULD, not a MUST.** Implementations diverging on the delta create interop holes a malicious app could probe.
- **Persistent/unrestricted-access pointers are the highest-risk authorization shape and have the lightest spec text.** No required UX warnings, no required expiry, no required spend-velocity caps beyond what the node service implements.
- **Node service compromise is the single point of failure.** The spec doesn't analyze what happens if the node service is breached — all authorizations under that service become spendable by the attacker until the user revokes (out-of-band).
- **Cross-app collusion is not modeled.** Two apps the user has authorized could coordinate timing to drain a shared budget if budgets aren't scoped per-app pubkey (which is only a SHOULD).

## Why this matters

Debits is where CLINK's attack surface is widest because it is the only primitive that *moves money on a delegated basis*. The spec gets the foundational crypto right (NIP-44, signed events, replay deltas, single-use k1) but leaves three load-bearing decisions to implementers: revocation, persistence-policy on unrestricted access, and node-service compromise response. These are exactly the places a security thesis on CLINK will land.
