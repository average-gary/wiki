---
title: "Fedi Blog — ChapSmart Mini App: send Bitcoin, receive Tanzanian Shillings via M-Pesa (2026-05-18)"
type: raw
source_type: articles
source_url: https://www.fedi.xyz/blog/chapsmart-send-bitcoin-and-receive-tanzanian-shillings-over-m-pesa-with-this-new-fedi-mini-app
fetched: 2026-05-28
verified: 2026-05-28
volatility: warm
quality: 4
confidence: high
tags: [fedi, mini-app, chapsmart, m-pesa, tanzania, payments-bridge, off-mint]
summary: Fedi launches a Mini App that sends BTC from a Lightning wallet and settles to a recipient's M-Pesa Tanzanian Shilling account. The bridge runs off-mint — TZS never enters the Fedimint federation, which stays BTC-only.
---

# ChapSmart Mini App — send Bitcoin, receive Tanzanian Shillings via M-Pesa

Fedi blog post, 2026-05-18.

## What it does

ChapSmart is a Bitcoin payment service for Tanzania accessible as a Mini App inside the Fedi wallet. Flow:

1. User enters recipient's M-Pesa number and shilling amount.
2. ChapSmart calculates the satoshi equivalent and shows fees upfront.
3. User pays a Lightning invoice from their Fedi wallet.
4. Recipient receives Tanzanian Shillings via M-Pesa.

Also offers airtime top-ups, satoshi purchases via M-Pesa, and merchant services.

## Architectural detail — what the Fedi blog DOESN'T say

The post does not specify:
- Who operates the BTC↔TZS bridge infrastructure (presumably ChapSmart itself, as a third-party Lightning Service Provider)
- The fee structure
- Any custody handoff inside the Fedimint federation

The omissions are themselves load-bearing — the article describes the user experience but the *mint* remains BTC-only. ChapSmart is a Lightning-receiving service that happens to settle in TZS off-network. **No Tanzanian shillings enter the Fedimint federation.**

## Why this matters for multi-currency

This is the **canonical pattern Fedi has chosen for non-BTC currency UX**: bridge externally via Mini Apps, keep the mint BTC-only.

Comparison:
- **Stability Pool** ([[2026-05-28-bitcoin-manual-fedimint-stability-pool|article]]): BTC stays in mint, value-stability derived synthetically.
- **ChapSmart**: BTC leaves mint via Lightning, third-party converts to TZS off-network, TZS reaches recipient via M-Pesa.
- **Future native multi-currency** (post PR #7734 / #8460): would enable a federation to run a parallel TZS-denominated mint module — but no production federation does this today, and the trust assumptions for "TZS in the federation" would require a real off-chain peg.

The contrast is the most concrete framing of Fedimint's current operational answer: **non-BTC currency is solved at the application/integration layer, not the protocol layer.**

## See also

- [[2026-05-28-bitsacco-cracktheorange-interview|BitSacco interview]] — same pattern with KES (Kenya)
- [[2026-05-28-fedimint-h1-2025-ecosystem-review|Fedimint H1 2025 review]] — official roadmap context
- [[2026-05-28-fedimint-pr-7734-multi-currency-support|PR #7734]] — protocol-level rails for the alternative pattern
