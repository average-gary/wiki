---
title: "No, don't enable revocation checking (Adam Langley, ImperialViolet)"
source: https://www.imperialviolet.org/2014/04/19/revchecking.html
type: article
tags: [revocation, crl, ocsp, short-lived-certs, langley, contrarian]
date: 2026-06-01
publication_date: 2014-04-19
quality: 5
confidence: high
agent: adjacent
summary: "Soft-fail makes revocation checking 'useless'; the attacker capable of MITM is also capable of blocking OCSP. Concludes the practical fix is short-lived certs ('If they were only valid for days then revocation would take care of itself'). This is the historical receipts on why the industry pivoted from CRL/OCSP to short-TTL + reissuance (Let's Encrypt 90d, ACME, DNSSEC)."
---

# Langley: don't enable revocation checking

Strongest single-citation argument for the design choice: **don't build a revocation list — make tokens short-lived and rotate the seed.**

## The argument

> "If revocation checks fail soft (the only practical mode), then the attacker capable of MITM is also capable of blocking OCSP. The check accomplishes nothing."

## The proposed fix

> "If [certificates] were only valid for days then revocation would take care of itself."

The browser ecosystem absorbed this and pivoted toward:

1. **Let's Encrypt** — 90-day default cert lifetime
2. **ACME** — automated reissuance
3. **CRLite / OneCRL** — push-based revocation lists baked into the browser

But the original insight stands: **for any system where revocation checking would soft-fail, prefer short TTL + cheap reissue.**

## Direct quote-for-quote application to the iroh app token

For an iroh app token, **revocation checking would inevitably soft-fail**:

- Server is offline → no revocation oracle reachable → ?
- Network partition → can't reach the iroh app's revocation endpoint → ?

If we soft-fail, attacker who can DoS the revocation endpoint defeats the system.

→ **Don't build a revocation list.** Make tokens short-lived. Bump the seed.

## Quote for the wiki article

When the wiki's design doc inevitably faces "but where's your revocation list?", the answer is:

> Adam Langley, 2014: "If they were only valid for days then revocation would take care of itself."
>
> The token is valid for hours; the seed rotates weekly. Revocation = wait. Compromise = bump the seed.

## See also

- [[2026-06-01-rfc-6819-oauth-threats]] — the family-revocation pattern that complements short TTL
- [[2026-06-01-rfc-6238-totp]] — short-window stateless tokens
