---
title: "CLINK PR #8 'revise debit k1' — diff and impact analysis"
source: https://github.com/shocknet/CLINK/pull/8
type: repo
ingested: 2026-06-10
path: gap-pr8
quality: 5
credibility: high
tags: [clink, debits, k1, pr-8, breaking-change, interop]
---

# CLINK PR #8 "revise debit k1" — diff and impact analysis

## Source overview

- PR: https://github.com/shocknet/CLINK/pull/8
- Author: shocknet-justin (Justin Rezvani)
- Reviewer: PatMulligan (commented, not formally approving — but drove a Q&A that produced the second commit)
- Branch: `k1` -> `main`
- File touched: `specs/clink-debits.md` (only file changed, +106 / -35)
- Commits in PR (2):
  - `2df23d56` — "revise debut k1" — 2026-06-02 18:11:58Z (initial spec rewrite)
  - `c7ac5abc` — "k1 consumption" — 2026-06-08 19:49:46Z (added consumption semantics, replay rules, GFY example)
- Merged: **2026-06-09 15:14:35Z** (squash/merge SHA `c7ac5abc...`)
- Pre-PR-8 spec head on `main`: `8e47a843` ("QR standard", 2026-06-01 19:35:52Z)
- Post-PR-8 main HEAD as of 2026-06-10: `09e0f925` ("add takemysats" readme commit, 2026-06-09 21:28:34Z) — only readme commits since merge.

## What PR #8 actually does

PR #8 retroactively justifies and formalizes a CLINK Debits use-case that was implemented in Lightning.Pub before the spec language existed: **session ndebits** for LNURL-withdraw-like flows (e.g., ATM cash-in). Before PR #8, `k1` was a single sentence: "Optional: unique identifier for debit request, requests will fail if an identifier is reused". After PR #8, `k1` is a fully-specified session-correlation primitive with a TLV slot in the bech32 pointer, generation rules, single-use semantics, consumption rules, and a documented retry path.

The PR also performs a sweeping terminology rename from **"wallet service"** to **"node service"** throughout the spec, and from **"application pubkey"** to **"requestor pubkey"** in event payloads. This was driven by the realization (made explicit in PatMulligan's Q&A on 2026-06-06) that in session flows, the entity receiving the kind `21002` event is _not_ the customer's wallet — it is the application operator's backend (e.g., the ATM operator's Lightning.Pub instance). The customer's wallet is the **requestor**, not the receiver.

## Diff summary

| Area | Before | After |
|---|---|---|
| Service name | "wallet service" | "node service" (rename throughout) |
| Requestor name | "application pubkey" / "application/service" | "requestor pubkey" / "requestor wallet" |
| `ndebit` TLV items | 0, 1, 2 only | adds **TLV 3** = 32-byte session identifier (`k1`) |
| `k1` JSON payload field | "Optional: unique identifier for debit request, requests will fail if an identifier is reused" | "Optional: 64-char lowercase hex; only when debiting from a session ndebit; MUST mirror TLV 3" |
| QR encoding | undocumented | new "Display and QR Encoding" section: MUST be plain `ndebit1...`, MUST NOT be wrapped in `ndebit:`, BIP-21, LNURL, HTTP(S), etc. |
| Static vs session pointers | not distinguished | new explicit dichotomy: static (TLV 0–2) vs session (adds TLV 3) |
| Roles in session flows | not enumerated | three-party model: Application / Requestor wallet / Node service |
| `k1` consumption rules | absent | new "Session Identifiers (`k1`)" section: SHOULD be single-use per pointer; consumed only on accept-for-approval; structural/payload validation failures MUST NOT consume; duplicates while pending → GFY code 6 |
| GFY code 6 | "Invalid Request" | unchanged code, but now has new example: `"K1 already processed"` |
| Process Flow | one flow ("Process Flow Summary") | split into "Authorization flow" and "Session flow" |
| Wallet Client MUST | one bullet | adds: "When initiating a debit from a decoded session ndebit, include `k1`…"; "Listen for kind 21002 responses to session ndebit requests…" |
| Application section | single MUST list | split into "MUST (authorization flows)" and "MUST (session flows)" — session flows MUST mint a fresh 32-byte session identifier per QR |
| Reference Implementations | "Wallet Node: Lightning.Pub" | "Node service: Lightning.Pub" |
| Security Considerations | 5 items | adds item 6: "Session Identifiers" — node services SHOULD treat `k1` as single-use per pointer; ATM-like correlation MUST NOT rely on amount alone |
| Response addressing | "to the application pubkey" | "MUST be addressed to the pubkey that signed the original request" — explicit |

## Direct quotes — old vs new

### `k1` field semantics (Direct Payment Request payload)

Before (`8e47a843:specs/clink-debits.md`):
```
"k1": "<k1_string_identifier>" // Optional: unique identifier for debit request, requests will fail if an identifier is reused
```

After (`c7ac5abc:specs/clink-debits.md`):
```
"k1": "<64-char lowercase hex>" // Optional: session identifier; see Session Identifiers (k1) below
```

### Wallet construction rule (new in PR #8)

> "Requestor wallets MUST recognize a scanned or pasted string that matches the bech32 `ndebit` HRP (i.e. starts with `ndebit1`) as a CLINK Debit pointer and decode it per this specification. **If TLV `3` is present, the wallet MUST include a `k1` field in the kind `21002` request payload set to the lowercase hexadecimal encoding of those 32 bytes (64 characters). If TLV `3` is absent, the wallet MUST NOT invent a `k1` value.**"

### `k1` consumption rule (new in PR #8)

> "A `k1` is **consumed** when the node service accepts a valid request for approval or payout processing. Structural failures (e.g., cannot decrypt, malformed event) and payload validation failures (e.g., invalid amount, un-decodable BOLT11) MUST NOT consume `k1`; the requestor MAY retry the same `k1` with a corrected request."

### Static vs session ndebit (new in PR #8)

> "A **static pointer** contains TLV items `0`–`2` only. It MAY be published in NIP-05, kind `0` metadata, or other long-lived contexts."
>
> "A **session ndebit** is a static pointer plus a **session identifier** in TLV `3` (`k1`). It is minted per interaction (e.g., one QR per withdrawal) and **MUST NOT be published as a user's primary `clink_debit`**."

### QR encoding (new in PR #8)

> "**QR codes:** The QR payload MUST be that string encoded as plain text (e.g. `ndebit1qvq...`). Implementations MUST NOT prepend `ndebit:`, append query parameters, use BIP-21 URIs, LNURL strings, HTTP(S) URLs, or encode TLV fields without the bech32 wrapper."

## Classification

Per-change classification:

| Change | Class |
|---|---|
| Terminology rename ("wallet service" → "node service", "application pubkey" → "requestor pubkey") | **Clarification** — semantically identical wire format. No implementation needs code changes; only docs/comments. |
| Static-vs-session dichotomy and three-party role model | **Clarification + extension** — names a flow that already existed in Lightning.Pub practice, no breaking change for existing wallets. |
| TLV `3` (session identifier) added to `ndebit` bech32 | **Backwards-compatible extension** — old decoders that look up TLV 0/1/2 keep working; TLV 3 is ignored if not understood. New senders MUST NOT publish session ndebits in long-lived NIP-05 / kind 0 contexts, so wallets reading static pointers there are unaffected. |
| `k1` JSON field MUST be 64-char lowercase hex | **Tightening (potentially breaking)** — pre-PR-8 wording was "k1_string_identifier" with no format requirement. A pre-PR-8 implementation that sent k1 as e.g. arbitrary base64 or uppercase hex would now be non-conforming and likely rejected by an updated node service that expects 64 lowercase hex chars. In practice, since `k1` was barely used, the only known implementations are post-PR-8 and conform. |
| `k1` MUST be omitted when no TLV 3 (no session) | **Tightening** — before, `k1` was just "Optional"; a wallet could in principle have sent any session-ish identifier with a static pointer. After, sending `k1` without a TLV 3 is non-conforming. This rules out "wallet invents a session ID for a static pointer" patterns. |
| `k1` consumption rules (single-use per pointer; not consumed on validation failure; duplicate while pending → GFY 6) | **Behavioral specification** — formalizes Lightning.Pub's actual behavior post-2026-06-08; older Lightning.Pub builds that consumed `k1` on every receive (before invoice validation) are now spec-non-compliant and must be patched. This was explicitly flagged by shocknet-justin: "we have to push a change to make this entirely accurate, moving the k1 burn to after invoice validation, in progress" (2026-06-08). |
| GFY error code 6 (`"K1 already processed"`) example | **Clarification** — code 6 already existed; this is just a worked example. |
| QR encoding rules (MUST be plain `ndebit1...`, no `ndebit:` prefix, no BIP-21, no LNURL wrapping) | **Tightening** — pre-PR-8 spec had no QR rules at all, so any wrapping was technically allowed by silence. Implementations using QR wrappers would now be non-conforming. No known implementation does this — Stacker News and ShockWallet pass the raw bech32. |
| Response event addressing (MUST go to requestor pubkey, not "application pubkey") | **Clarification** — wire-equivalent. The pre-PR-8 spec said "to the application pubkey" because pre-PR-8 it implicitly assumed a 2-party model where application == requestor. In the new 3-party model, the addressing rule is now stated as "to the pubkey that signed the request", which is the same pubkey in all flows. |

**Overall verdict: backwards-compatible clarification with one latent breaking edge.**

The only realistic break is for any implementation that:
1. Sent `k1` in a non-64-char-lowercase-hex format, OR
2. Sent `k1` alongside a static pointer (no TLV 3), OR
3. Burned `k1` before invoice validation (server-side; affects retry semantics).

Items 1 and 2 require an updated node service to enforce; current Lightning.Pub (post-PR #949) does not yet enforce hex formatting strictly per code review (the proto type is just `string`). Item 3 is the only known pre-existing non-conformance, lives only in Lightning.Pub, and shocknet-justin has it queued to fix.

## Affected implementations — adoption timeline

### Adopted (have integrated PR #8 semantics)

- **ClinkSDK 1.5.5** — adopted **partially**, **2026-06-01** (PR #16 merged 2026-06-01 17:02:58Z). Added `k1?: string` field to `NdebitData` type. **Gap:** `decodeBech32` still does NOT decode TLV `3`. `DebitPointer` type is still `{ pubkey, relay, pointer? }`. Helper functions `newNdebitPaymentRequest`, `newNdebitFullAccessRequest`, `newNdebitBudgetRequest` do not accept/produce `k1`. Wallets using ClinkSDK to scan a session ndebit cannot currently extract the embedded `k1` via the SDK and must roll their own bech32 + TLV parsing.

- **Lightning.Pub** — adopted **partially**, **2026-06-02** (PR #949 merged 2026-06-02 15:26:16Z). Bumped `@shocknet/clink-sdk` to `^1.5.5`. Added `k1?: string` to `LiveDebitRequest` proto (field 20, optional, regenerated TS/Go types). Server accepts `k1` from kind `21002` payloads, stores it in a `K1Debouncer` with a 5-minute window, forwards on the live-debit-requests stream to the application backend, and returns GFY code 6 on duplicate. **Gap:** `K1Debouncer.addK1` is called early in the receive path (records `k1` before invoice validation), which violates the new "MUST NOT consume on payload validation failure" rule. shocknet-justin explicitly flagged this in the PR #8 thread on 2026-06-08: _"we have to push a change to make this entirely accurate, moving the k1 burn to after invoice validation, in progress"_. No follow-up commit on Lightning.Pub `main` since 2026-06-02 as of 2026-06-10.

### Not yet adopted (but compatible)

- **ShockWallet (shocknet/wallet2)** — **NOT adopted** for session flows; **structurally compatible** for authorization flows. Repo has zero references to session-ndebit scanning, TLV 3, or session-`k1` generation. Wallet generates and stores static `ndebit` pointers only. Latest CLINK-related commit is `fa37ab66` ("update clink / noffer", 2026-06-06, PR #615) which is a wholesale dep refresh, not session-ndebit support. Existing static-pointer authorization flows continue working. Interop hole: cannot scan session ndebit QRs from ATMs / dispensers until ClinkSDK exposes TLV 3 and ShockWallet wires through the QR scanner path.

- **Stacker News (stackernews/stacker.news)** — **NOT adopted** for session flows; **structurally compatible** for the only flow they use (subscription-style budget against a static pointer). Their `wallets/client/protocols/clink.js` uses `newNdebitPaymentRequest(bolt11, undefined, pointer)` from ClinkSDK — never sets `k1`, never decodes TLV 3. Last touched 2025-09-23 (PR #2531, "CLINK debits"). No commits since PR #8 merged. Stacker News users add a static `ndebit1...` from ShockWallet to their SN wallet config; this remains valid under the new spec. They do not need to do anything.

- **CLINK demo client (clinkme.dev)** — not directly checked in this gap-fill (no public commit feed surfaced); referenced in spec as `https://clinkme.dev/`.

### Wallets pinned to pre-PR-8 spec

If a wallet implementation is pinned to ClinkSDK <= 1.5.4 or to a manual implementation of the pre-PR-8 spec (`8e47a843` or earlier), here is the impact:

- **Sending static-pointer authorization requests:** still works. No payload field change.
- **Sending direct-payment requests with `k1`:** still works against a tolerant node service (Lightning.Pub takes any string). Will start failing when a strict node service rejects non-64-char-hex `k1` values; **no such strict implementation exists today** but is now permitted by spec.
- **Receiving responses:** unchanged wire format.
- **Scanning session ndebits:** never worked pre-PR-8 because the concept did not exist in spec. Pinned wallets can ignore this until they want to support ATM-like flows.

The practical answer: **no pinned wallet needs an emergency update to keep existing flows working.** PR #8 is best understood as a spec catch-up and an extension hook for session-correlated payouts, not a breaking change to the existing direct-debit / budget-debit interfaces.

## Why this matters

1. **Resolves a "spec lags implementation" problem.** Lightning.Pub had been growing session-correlation semantics ahead of the public spec (`livedebitreq` already plumbed `k1` through `RespondToDebit` before PR #8 even opened). Pre-PR-8 third-party readers of `clink-debits.md` would not have known how `k1` was supposed to behave; PatMulligan's review thread is essentially a third-party integrator (an ATM team) discovering exactly that gap. Post-PR-8, the spec is implementable from the document alone.
2. **Unblocks ATM-style use cases on CLINK.** Session ndebits are the missing primitive that puts CLINK on parity with LNURL-withdraw (LUD-03). The spec now explicitly frames this — see new paragraph: _"Session ndebits address the same class of use cases as LNURL-withdraw"_. Anyone planning to ship a Lightning ATM with CLINK as the wire protocol now has spec text to point at.
3. **Names the three-party model.** The Application / Requestor wallet / Node service split is the most important conceptual clarification in the diff. Pre-PR-8 the spec conflated "application" with both "thing minting QRs" and "thing sending kind 21002 events", which is wrong in session flows. Implementers reading the old spec would have built two-party assumptions into their code and hit interop bugs at the first ATM integration.
4. **Gives a forward path for `k1` enforcement without breaking existing wallets.** The "MUST be 64-char lowercase hex" rule is enforceable by node services going forward, but because static-pointer flows MUST NOT send `k1` at all, ShockWallet and Stacker News (which never send it) are unaffected.
5. **Documents the "consumed vs not consumed" boundary, which is the actual hard part.** The PR #8 thread between PatMulligan and shocknet-justin on 2026-06-06–2026-06-08 worked through the recovery flow when an ATM has approved a `k1` and then the LN payment fails post-approval. The spec language now reflects that boundary and gives a way to retry with a corrected request without burning a session.
6. **Flags one outstanding Lightning.Pub bug.** The reference node service is currently spec-non-compliant on `k1` burn ordering. Anyone building against Lightning.Pub today will see retries blocked even on payload validation failures. Watch for a Lightning.Pub follow-up PR moving the `K1Debouncer.addK1` call after invoice/amount validation.

## Cross-references in this wiki

- Pre-PR-8 spec analysis: `2026-06-09-implementations-shocknet-clink.md`, `2026-06-09-spec-primitives-clink-repo-overview.md`
- Lightning.Pub deep-dive (covers `liveDebitRequest` and `RespondToDebit` RPCs): `2026-06-09-implementations-lightning-pub.md`
- ShockWallet deep-dive (covers static ndebit minting and storage): `2026-06-09-implementations-shockwallet.md`
- Stacker News integration deep-dive: `2026-06-09-implementations-stackernews-clink.md`
- ClinkSDK / bridgelet deep-dive: `2026-06-09-implementations-bridgelet-and-sdk.md`
- Comparison vs LNURL-withdraw (LUD-03) — relevant since PR #8 explicitly draws this analogy: not yet covered; gap candidate.

## Provenance

- Spec diff fetched via `gh pr diff 8 --repo shocknet/CLINK` on 2026-06-10.
- Pre-PR-8 spec content fetched via `gh api repos/shocknet/CLINK/contents/specs/clink-debits.md?ref=8e47a843` on 2026-06-10.
- PR review thread fetched via `gh api repos/shocknet/CLINK/pulls/8/comments` on 2026-06-10.
- Downstream commit history fetched via `gh api repos/{shocknet/wallet2,shocknet/ClinkSDK,shocknet/Lightning.Pub,stackernews/stacker.news}/commits` and `gh search code` on 2026-06-10.
- Lightning.Pub PR #949 diff and ClinkSDK PR #16 diff fetched via `gh pr diff` on 2026-06-10.
