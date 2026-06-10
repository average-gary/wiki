---
title: Stacker News — production CLINK adopter (third-party, send + recv shipped)
source: https://github.com/stackernews/stacker.news
type: repo
ingested: 2026-06-09
path: implementations
quality: 5
credibility: high
tags: [clink, implementation, stacker-news, third-party, noffer, ndebit, production]
---

# Source overview

Stacker News (`github.com/stackernews/stacker.news`, the "Hacker News for Bitcoin" site at stacker.news) is the highest-signal **third-party** CLINK adopter in production. Code search proves they ship CLINK as a first-class wallet protocol alongside NWC, LNbits, Phoenixd, Blink, WebLN, LN address, LNC, CLN-REST, and LND-gRPC. CLINK support is shipped for both **send** (paying) and **receive** (zapping in).

# Key findings

- CLINK is one of 10 wallet protocols in the Stacker News wallet abstraction. From `wallets/lib/protocols/index.js`:
  > `* @typedef {'NWC'|'LNBITS'|'PHOENIXD'|'BLINK'|'WEBLN'|'LN_ADDR'|'LNC'|'CLN_REST'|'LND_GRPC'|'CLINK'} ProtocolName`
- Migration timeline (Postgres enum additions in `prisma/migrations/`):
  - `20250905014333_clink_recv` — adds `CLINK` to `WalletProtocolName` and `WalletRecvProtocolName` enums (CLINK recv shipped 2025-09-05).
  - `20250914020103_clink_send` — adds `CLINK` to `WalletSendProtocolName` and prepends it to `sendProtocols` (CLINK send shipped 2025-09-14).
- Dependency: `package.json` pins `"@shocknet/clink-sdk": "^1.4.0"`. SDK is consumed in both client and server protocol handlers (`wallets/client/protocols/clink.js`, `wallets/server/protocols/clink.js`).
- SDK API surface used: `decodeBech32`, `generateSecretKey`, `newNdebitPaymentRequest`, `SendNdebitRequest`, `SendNofferRequest`, `SimplePool`, `OfferPriceType`. This corresponds directly to the noffer (recv) and ndebit (send) flows.
- Validation regex (`wallets/lib/validate.js`): `/^(noffer|ndebit)1[02-9ac-hj-np-z]+$/` — bech32-style, strict.
- Recv flow takes a single user-pasted `noffer` string. Send flow takes `ndebit` + a `secretKey` (encrypted at rest).
- Spontaneous-only price guard: `if (type === 'noffer' && data.priceType && data.priceType !== OfferPriceType.Spontaneous)` → SN rejects non-spontaneous offers (i.e. requires the offer to accept a caller-specified amount).
- Recent dep maintenance (commit `a2f653c`, 2026-05-27): "brace-expansion is technically dev-only, but included as a nested dependency due to @shocknet/clink-sdk packaging rimraf poorly (upstream PR opened.)" — active maintenance with upstream fixes flowing back.

# Maturity assessment

**Shipped to production.** Live on stacker.news as a user-facing wallet attachment option for both sending and receiving since Sept 2025. ~9 months of production runtime by 2026-06-09. SN's wallet abstraction puts CLINK on equal footing with NWC and Phoenixd — no "experimental" guard in the code paths reviewed. Test mocks exist (`api/payIn/__tests__/jest.setup.js` mocks `@shocknet/clink-sdk`), indicating CI coverage.

# Direct quotes from code / docs

1. From `wallets/lib/protocols/docs/dev/clink.md`: "Testing CLINK is done with Lightning.Pub and Shockwallet. [...] Run this command to get `nprofile` of the lnpub container: `sndev logs --since 0 lnpub | grep -oE 'nprofile1\\w+'`"
2. From `wallets/lib/protocols/clink.js`: `// CLINK: Common Lightning Interface for Nostr Keys` / `// https://github.com/shocknet/CLINK/`
3. Send protocol field def: `{ name: 'ndebit', label: 'ndebit', type: 'password', placeholder: 'ndebit...', required: true, validate: clinkValidator('ndebit'), encrypt: true, editable: false }`
4. Recv protocol field def: `{ name: 'noffer', label: 'noffer', type: 'password', placeholder: 'noffer...', required: true, validate: clinkValidator('noffer') }`
5. Migration SQL: `ALTER TYPE "WalletProtocolName" ADD VALUE 'CLINK'; COMMIT;` and `SET "sendProtocols" = array_prepend('CLINK', "sendProtocols")`

# Open questions

- Does SN's CLINK send actually get used by users in volume, or is it a niche option? (No on-chain data here.)
- The SN dev doc explicitly couples testing to ShockWallet PWA — is there any non-Lightning.Pub server SN has interop-tested against? (Not yet, per the `clink.md` testing recipe naming only `lnpub` container.)
- SN does not appear to use `@shocknet/clink-sdk`'s Manage (`nmanage`) functionality — confirms Manage is unshipped in the broader ecosystem.

# Why this source matters

Stacker News is the **only confirmed non-ShockNet production deployment** of CLINK send+recv. They embed `@shocknet/clink-sdk` in a serious wallet abstraction layer alongside NWC and bank-grade Lightning protocols. This is the strongest evidence that CLINK is not just a ShockNet stack — there is real third-party adoption with code-level testing, migrations dated, and active dependency upkeep including upstream PRs back to ShockNet's SDK.
