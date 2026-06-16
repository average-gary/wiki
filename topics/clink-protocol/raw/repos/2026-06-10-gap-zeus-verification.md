---
title: "Zeus Wallet CLINK support — verification"
source: https://github.com/ZeusLN/zeus
type: repo
ingested: 2026-06-10
path: gap-zeus
quality: 4
credibility: high
tags: [clink, zeus, third-party, verification, ecosystem]
---

# Zeus Wallet CLINK support — verification

## Why this gap

The CLINK ecosystem README at `shocknet/clink` lists Zeus Wallet under "Wallets that support CLINK" with the line *"Zeus Wallet — Offers — ZEUS Pay users get an offer by default."* A prior pass over Zeus's own README found zero CLINK terminology, raising the question of whether the entry is real shipping support or aspirational. This file documents direct source-level verification.

## Source overview

- Repo: `ZeusLN/zeus` (React Native, TypeScript). Zeus is a self-custodial Bitcoin / Lightning mobile wallet that connects to user-run nodes (LND, Core Lightning, Eclair, LDK Node embedded) and provides the `@zeuspay.com` Lightning Address service ("ZEUS Pay").
- Verification done against `master` on 2026-06-10 (latest tagged release: `v13.1.0-beta2`, 2026-06-09; latest stable: `v13.0.2`, 2026-05-21).

## Verdict: CONFIRMED

Zeus ships first-party CLINK Offers (`noffer`) **payer-side** support and exposes a `noffer` for every ZEUS Pay account on the **payee side**. The feature is unconditional (no feature flag), shipped in `v13.1.0-beta1`, and authored by Zeus's own maintainer (`@kaloudis`) — not vendored from a ShockNet SDK.

## Key findings

### 1. First-party CLINK implementation (no SDK dependency)

- Zeus does **not** depend on `@shocknet/clink-sdk` or any `shocknet/*` package. `package.json` (zeus@13.1.0-beta2) shows no `clink-sdk`, no `shocknet` packages. Nostr stack is independent: `@nostr-dev-kit/ndk@2.13.0-rc2`, `@nostr/tools` (JSR), `nostr-tools@1.16.0`, plus `@scure/base@1.1.6` for bech32 and `@noble/secp256k1` / `@noble/hashes` for crypto.
- The implementation lives in `utils/ClinkUtils.ts` (559 lines) — a hand-rolled CLINK Offers client with TLV parser, NIP-44 request encryption, kind-21001 publish/subscribe over a relay, response decoding and amount sanity-check. Header comment is unambiguous:

  > `// CLINK Offers — successor to LNURL-pay using Nostr as transport.`
  > `// Spec: https://github.com/shocknet/clink (specs/clink-offers.md)`
  > `// Bech32-encoded `noffer1...` string carrying a TLV payload that points`
  > `// at a Nostr pubkey + relay + offer id, optionally with pricing hints.`

- Constants matching the CLINK spec are exported:
  ```
  const NOFFER_PREFIX = 'noffer';
  export const CLINK_KIND = 21001;
  export const CLINK_VERSION = '1';
  ```
- `decodeNoffer()` parses TLVs 0–5 (pubkey, relay, offer id, price type, price, currency) and applies the spec's pricing-type defaults (currency present → Variable; price-only → Fixed; neither → Spontaneous), with the comment block citing the spec text directly.

### 2. Payer-side: `noffer` URI handling and `ClinkPay` screen

- `utils/AddressUtils.ts` recognizes raw `noffer1...` strings and BIP-21 `?lno=`/`?noffer=` parameters. Comment: `/* CLINK noffer — Nostr Offer (https://github.com/shocknet/clink) */`.
- `utils/handleAnything.ts` routes detected nostr offers to a dedicated screen: `return ['ClinkPay', { noffer: clinkNoffer }];`.
- `views/ClinkPay/ClinkPay.tsx` is a full payment screen: decodes noffer, displays issuer's npub (truncated), enforces amount rules per `NofferPriceType`, encrypts a kind-21001 request to the issuer over the embedded relay, awaits the bolt11, and hands it back through `handleAnything` for payment-source selection.
- Localized error strings cover `NO_RELAYS`, `ONION_NOT_SUPPORTED`, `RELAY_CONNECT_FAILED`, `RELAY_REJECTED_PUBLISH`, `TIMEOUT`, plus the CLINK error-code enum (`InvalidOffer`, `TemporaryFailure`, `ExpiredOrMoved`, `UnsupportedFeature`, `InvalidAmount`).
- Translated into ~15+ locales: `en`, `tr`, `he`, `id`, `ru`, `pt_BR`, `hi_IN`, `ko`, `el`, `bg`, `fi`, `de`, `sv`, etc. Sample English strings (locales/en.json):
  - `"views.ClinkPay.title": "Pay CLINK Offer"`
  - `"views.ClinkPay.invalidOffer": "Invalid CLINK offer"`
  - `"utils.handleAnything.invalidNoffer": "Could not decode CLINK noffer"`
  - `"views.Settings.Noffer": "CLINK noffer"`

### 3. Payee-side: every ZEUS Pay account exposes a `noffer`

- `stores/LightningAddressStore.ts` exposes `@observable public noffer: string | null = null;` and writes it from server responses (lines ~644, 672). Combined with `views/LightningAddress/LightningAddressQR.tsx` accepting `noffer` as a route param and rendering it, the ZEUS Pay backend (`@zeuspay.com`) is hosting a CLINK noffer for each address and the wallet UI surfaces it as a payment method.
- `components/LayerBalances/PaymentMethodList.tsx` registers CLINK as a peer payment layer: `CLINK: 'views.Settings.Noffer'` and `layer: 'CLINK'`.

### 4. Contacts integration

- `models/Contact.ts` has `public noffer: Array<string>;` alongside Lightning addresses, LNURL-pay, and on-chain — i.e. CLINK noffer is a top-level contact identity type.
- `views/Settings/AddContact.tsx` validates noffer entries; `views/ContactDetails.tsx` renders them; `stores/ContactStore.ts` persists them; `views/Settings/Contacts.tsx` navigates to `ClinkPay` on tap.

### 5. Release timeline (commits + tags)

Key commits on `utils/ClinkUtils.ts` and `views/ClinkPay/ClinkPay.tsx`, all by Zeus maintainer `@kaloudis`:

- `67f8f45d` 2026-05-17 — `feat: clink: add noffer decoder and BIP-21 parameter parsing`
- `4a23a2b9` 2026-05-17 — `feat: clink: request bolt11 invoices over Nostr from a noffer`
- `e1161771` 2026-05-17 — `feat: clink: wire noffer routing into handleAnything and and new CLINK Pay screen`
- `a2ab4e00` 2026-05-17 — `feat: clink: sanity-check returned invoice amount against the offer`
- `c3a21e4f` 2026-05-18 — `fix: clink: accept responses missing clink_version tag (Postel interop) + err localization`
- `75e38ea8` 2026-05-18 — `feat: clink: route through ChoosePaymentMethod when ecash is enabled`
- `14bb5ec1` 2026-05-17 — `fix: clink: normalize omitted noffer pricing type per spec defaults`
- `7e3ef867` 2026-05-25 — locale tweak
- `fe7289e6` 2026-06-08 — `fix(clink): route bolt11 through handleAnything to reach payment source screen`
- `71c33319` 2026-06-03 — cleanup

CLINK landed in `v13.1.0-beta1` (2026-06-06). The `v13.1.0-beta2` (2026-06-09) release notes call it out explicitly:

> `## v13.1.0 Highlights:`
> `- feat: pay to CLINK noffers`
> `- feat: ZEUS Pay: CLINK noffers for every account`

The prior stable release `v13.0.2` (2026-05-21) does **not** mention CLINK in its release notes. So as of 2026-06-10, CLINK support is in **beta builds only**; the next stable release (post-beta of v13.1.0) will be the first GA Zeus build with CLINK.

### 6. Scope: Offers only, no `ndebit`

- `gh search code --repo ZeusLN/zeus 'ndebit'` returned zero results.
- A recursive tree listing of the repo shows no files matching `ndebit` (case-insensitive). Zeus implements **CLINK Offers** but not the CLINK Debits half of the protocol. This matches the ecosystem README's "Offers" qualifier.

### 7. Public docs lag the code

- `docs.zeusln.app` (the Docusaurus docs site) does not yet document CLINK / noffer / ZEUS Pay's noffer feature on its landing page or on the v13.0.0 blog post. Disclosure exists only in (a) source code, (b) in-app strings, and (c) the GitHub release notes for `v13.1.0-beta1` / `-beta2`.

## Quotes (verbatim)

From `utils/ClinkUtils.ts`:
- `// CLINK Offers — successor to LNURL-pay using Nostr as transport.`
- `// Spec: https://github.com/shocknet/clink (specs/clink-offers.md)`
- `if (prefix !== NOFFER_PREFIX) { throw new Error(`expected noffer prefix, got ${prefix}`); }`
- `export const CLINK_KIND = 21001;`
- `export const CLINK_VERSION = '1';`

From `utils/AddressUtils.ts`:
- `/* CLINK noffer — Nostr Offer (https://github.com/shocknet/clink) */`

From `locales/en.json`:
- `"views.ClinkPay.title": "Pay CLINK Offer"`
- `"views.ClinkPay.invalidOffer": "Invalid CLINK offer"`
- `"views.Settings.Noffer": "CLINK noffer"`

From `v13.1.0-beta2` release notes:
- `feat: pay to CLINK noffers`
- `feat: ZEUS Pay: CLINK noffers for every account`

## Why this matters

1. **The ecosystem README claim is real.** Zeus is the first major non-ShockNet wallet to ship CLINK Offers in production-track builds, and ZEUS Pay (a hosted Lightning Address service used by tens of thousands of users) is the first production hosting of the payee side outside Lightning.Pub. This converts CLINK from "single-vendor experiment" into "interop-tested protocol" for the payer/payee split.

2. **Independent re-implementation, not vendored SDK.** Zeus rebuilt the noffer decoder, TLV parser, NIP-44 request flow, error mapping, and pricing-type defaults from spec. That is exactly the kind of second implementation the spec needs for credibility, and the inline spec-citation comments suggest the spec text was sufficient (one Postel-style fix was required: `accept responses missing clink_version tag`).

3. **Scope limit is informative.** Zeus implements `noffer` (Offers) but not `ndebit` (Debits). This confirms that the two halves of CLINK are independently adoptable and that wallet vendors are picking up the LNURL-pay-replacement half first; the NWC-replacement / Debit half remains ShockNet-only as of 2026-06-10.

4. **Documentation lag is a citation hazard.** Anyone evaluating Zeus's CLINK support purely from the docs site or the v13 blog post would conclude "no support." Source + release notes + in-app strings tell the real story. Future audits should weight release notes and source over docs sites for newer features.

5. **Time-to-spec.** Spec/origin repo: 2025 (per prior research). Second-party shipping implementation (Zeus): commits 2026-05-17, beta release 2026-06-06. That is on the order of months from spec-stable to second wallet — fast for an LNURL successor.

## Files referenced (Zeus repo paths)

- `utils/ClinkUtils.ts` — core decoder + Nostr request flow
- `utils/ClinkUtils.test.ts` — unit tests
- `utils/AddressUtils.ts` — URI/BIP-21 parsing of noffer
- `utils/handleAnything.ts` — top-level dispatcher routing noffer to ClinkPay
- `views/ClinkPay/ClinkPay.tsx` — payment UI
- `views/LightningAddress/LightningAddressQR.tsx` — payee QR exposing noffer (ZEUS Pay)
- `views/LightningAddress/index.tsx` — ZEUS Pay address screen
- `stores/LightningAddressStore.ts` — payee `noffer` observable
- `stores/ContactStore.ts` — contact noffer persistence
- `models/Contact.ts` — noffer as first-class contact identity
- `components/LayerBalances/PaymentMethodList.tsx` — CLINK payment layer
- `components/LayerBalances/LightningSwipeableRow.tsx` — `clinkNoffer` action
- `views/Settings/AddContact.tsx`, `views/Settings/Contacts.tsx`, `views/ContactDetails.tsx`
- `views/ChoosePaymentMethod.tsx` — multi-method picker including CLINK
- `locales/en.json` (+ tr, he, id, ru, pt_BR, hi_IN, ko, el, bg, fi, de, sv, ...) — `views.ClinkPay.*`, `views.Settings.Noffer`, `utils.handleAnything.invalidNoffer`

## Verification metadata

- Verified against: `master` HEAD as of 2026-06-10
- Latest tagged release: `v13.1.0-beta2` (2026-06-09)
- Latest stable: `v13.0.2` (2026-05-21) — predates CLINK landing
- Verifier: gap-zeus pass; methods: `gh search code`, `gh api repos/.../contents/...`, `gh api .../git/trees`, `gh api .../releases/tags/...`, WebFetch on docs site
