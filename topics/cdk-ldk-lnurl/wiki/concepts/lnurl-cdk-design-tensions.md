---
title: "Design tensions: CDK + LDK + LNURL on one host"
type: concept
created: 2026-05-28
updated: 2026-05-28
confidence: medium
tags: [design, lnurl, description-hash, custody]
---

# Design tensions

Three tensions surface when the goal is "single-host deployment of CDK + LDK Node with LNURL endpoints."

## 1. Description-hash binding — purely a CDK-layer gap

> **Update 2026-05-28**: thesis research confirms LDK Node itself **does** accept a caller-supplied 32-byte description_hash via `Bolt11InvoiceDescription::Hash(Sha256)` on every `Bolt11Payment::receive*` method (since ldk-node v0.5.0, May 2025). See [[../../theses/ldk-node-receive-description-hash.md|verdict: Supported, High confidence]]. The blocker is purely in CDK's intermediate layer.

LUD-06 verification mandates `sha256(metadata) == invoice.description_hash`. cdk-mintd's NUT-04 quote endpoint accepts `description: Option<String>` only — no `description_hash` field. cdk-ldk-node currently calls `Bolt11InvoiceDescription::Direct(...)` only.

A bridge therefore cannot pass arbitrary metadata bytes through cdk-mintd to LDK Node today, even though LDK Node would accept them.

**Three resolutions**:

| Option | Topology | Trade-off |
|---|---|---|
| A. Bridge-side LN node | Two LN nodes on the host: cdk-ldk-node (mint reserve) + bridge LN (LNURL-facing) | Bridge is now an LN-custodian itself; reconciliation between bridge LN and mint LN needed. **What npub.cash does today.** |
| B. Skip strict description_hash | Mint-issued BOLT11 with description text only | Some wallets reject; spec violation; works in practice for many wallets but fragile |
| C. CDK PR (NUT extension or `cdk-mintd`-only field) | Add `description_hash: Option<String>` to NUT-04 quote request → cdk-ldk-node passes `Bolt11InvoiceDescription::Hash(Sha256(...))` | ~50 lines of CDK code + maybe a NUT extension. The clean answer. |

**Option C is now known to be small** — the upstream LDK API is already there. See [[../../theses/ldk-node-receive-description-hash.md|the thesis]] for the exact hook point and downstream gap analysis.

## 2. Custody: who holds what

CDK + LDK Node creates a clean custody story: **the LDK Node wallet IS the mint's reserve**. Every sat in a channel backs an outstanding ecash token. Reconciliation: LDK Node balance vs sum of issued proofs.

Adding a bridge breaks this if the bridge holds funds. The bridge should be a **stateless router** wherever possible:
- Receives LN payment, calls mint to claim ecash, hands ecash to user
- Holds nothing except temporary state during a quote's lifetime
- npub.cash adds a "tokens held until user claims" stage, which is custodial, but the funds are held as **mint tokens**, not LN sats — i.e., the bridge's failure mode is "stuck tokens", not "lost reserve"

If the bridge runs its own LN node (option 1A above), it becomes a second custodian. Best practice: keep that LN node lean (route-only, minimal liquidity), reconcile to mint daily.

## 3. LNURL is implementer-trust-heavy

LUD-06 metadata is **not signed**. The trust anchor is TLS+DNS at the bridge. A DNS hijack of `mint.example.com` lets an attacker substitute their own LNURL endpoint and divert deposits — see [[../../raw/papers/2026-05-28-lnurl-lud-06-payrequest.md|LUD-06]] § Security limitations.

Mitigations available today:
- **HSTS + DNSSEC** — reduce DNS hijack surface
- **LUD-18 `payerData.auth`** — repeat depositors pin a linking key
- **BOLT12 offers** — signer pubkey is part of the offer; cdk-ldk-node supports BOLT12, NUT-25 wires it. Offer LN Address as the pasteable UX, but encourage BOLT12 for power users.
- **Out-of-band fingerprint** — publish the bridge's TLS public key fingerprint somewhere off-domain

For LNURL-withdraw, atomic k1 enforcement is the corresponding footgun — see [[../../raw/papers/2026-05-28-lnurl-lud-03-withdraw.md|LUD-03]].

## See also

- [[lnurl-bridge-pattern.md|Bridge pattern]]
- [[ldk-node-footguns.md|LDK Node footguns]]
- [[nwc-vs-lnurl.md|NWC as alternative]]
