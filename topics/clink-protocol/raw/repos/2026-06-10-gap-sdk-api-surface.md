---
title: "@shocknet/clink-sdk public API surface (full map)"
source: https://github.com/shocknet/ClinkSDK
type: repo
ingested: 2026-06-10
path: gap-sdk
quality: 5
credibility: high
tags: [clink, sdk, api, manage-support, typescript]
---

# `@shocknet/clink-sdk` — Complete public API surface

Closes the prior `gap-sdk` gap: previous research could not reach `registry.npmjs.org`,
so the SDK surface was triangulated only from third-party imports (Stacker News).
This pass maps the SDK directly from the source-of-truth GitHub repo at the
v1.5.5 head commit.

## Source overview

- Repo: [`shocknet/ClinkSDK`](https://github.com/shocknet/ClinkSDK) (default branch `main`)
- Repo metadata: created `2025-05-26`, last push `2026-06-09T18:37:13Z`, license MIT,
  TypeScript, 1 star, 1 fork.
- Topics: `bitcoin`, `bolt11`, `lightning-network`, `nostr`, `nostr-client`,
  `nostr-protocol`, `wallet`.
- Homepage: `https://clinkme.dev`.
- Description: "Client SDK for the CLINK Protocol".
- Distribution: published to npm as `@shocknet/clink-sdk` via the
  `.github/workflows/npmpublish.yml` workflow on every `main` push (auto-tags
  `v<version>` after a successful publish).
- `package.json` excerpt:

```json
{
  "name": "@shocknet/clink-sdk",
  "version": "1.5.5",
  "main": "build/index.js",
  "type": "module",
  "keywords": [
    "nostr","bitcoin","micropayments","lightning","clink","payments","wallet",
    "sdk","bolt12","nwc","nip47","lnurl","zaps","nip57","offers","noffer",
    "ndebit","nmanage","invoice","nip19","nip44"
  ],
  "dependencies": {
    "@noble/hashes": "^1.8.0",
    "@scure/base": "^1.2.5",
    "nostr-tools": "2.15.1",
    "rimraf": "^6.0.1",
    "typescript": "^5.8.3"
  }
}
```

Notable: keywords advertise both `nmanage` and (oddly) `bolt12` and
`nip47` — but the source has no Bolt 12 or NWC code; those keywords are
SEO/positioning only.

## Repository tree (truncated to source files)

```
src/
  index.ts            (2,201 B)  — barrel + ClinkSDK class
  ndebit.ts           (3,382 B)  — kind 21002 (Debits)
  nmanage.ts          (4,166 B)  — kind 21003 (Manage)  <-- present
  noffer.ts           (1,714 B)  — kind 21001 (Offers)
  sender.ts           (3,584 B)  — generic NIP-44 send/subscribe pipeline
  nip19Extension.ts   (6,081 B)  — bech32 (en|de)code for noffer/ndebit/nmanage
README.md             (7,128 B)
package.json
.github/workflows/npmpublish.yml
```

The library is single-package and there is no `dist/` checked in; types are
emitted from TS source by `tsc` at publish time, so the published surface is
exactly the surface in `src/`.

## Public-API table

Source of truth: `src/index.ts` re-exports everything from `noffer.ts`,
`ndebit.ts`, `nmanage.ts`, and `nip19Extension.ts`, plus a curated re-export
from `nostr-tools`.

### `ClinkSDK` class (`src/index.ts`)

| Symbol | Signature | Primitive | Notes |
|---|---|---|---|
| `ClinkSettings` (type) | `{ privateKey: Uint8Array; relays: string[]; toPubKey: string; defaultTimeoutSeconds?: number }` | core | Constructor settings. |
| `ClinkSDK` (class) | `new ClinkSDK(settings: ClinkSettings, pool?: AbstractSimplePool)` | core | Defaults pool to `new SimplePool()` from nostr-tools. |
| `ClinkSDK#Noffer` | `(data: NofferData, onReceipt?: (r: NofferReceipt) => void, timeoutSeconds?: number) => Promise<NofferResponse>` | Offers (21001) | Accepts a paid-receipt callback. |
| `ClinkSDK#Ndebit` | `(data: NdebitData, timeoutSeconds?: number) => Promise<NdebitResponse>` | Debits (21002) | |
| `ClinkSDK#Nmanage` | `(data: NmanageRequest, timeoutSeconds?: number) => Promise<NmanageResponse>` | Manage (21003) | **Shipped.** |
| `ClinkSDK.decodeBech32` | static, `= decodeBech32` | utility | Convenience static. |
| `ClinkSDK.generateSecretKey` | static, re-exported from `nostr-tools` | utility | |
| `ClinkSDK.newListRequest` | static, `= newListRequest` (Manage) | Manage | |
| `ClinkSDK.newNdebitBudgetRequest` | static, `= newNdebitBudgetRequest` (Debits) | Debits | |

### Offers — `src/noffer.ts` (kind 21001)

| Symbol | Signature | Notes |
|---|---|---|
| `NofferData` (type) | `{ offer: string; amount_sats?: number; zap?: string; payer_data?: any; expires_in_seconds?: number; description?: string }` | Note `payer_data` is `any`, not the typed `string[]` used in Manage. |
| `NofferSuccess` (type) | `{ bolt11: string }` | |
| `NofferError` (type) | `{ code: number; error: string; range?: { min: number; max: number } }` | No `res:` discriminator — bare shape. |
| `NofferResponse` (type) | `NofferSuccess \| NofferError` | |
| `NofferReceipt` (type) | `{ res: 'ok' }` | Paid-receipt payload. |
| `SendNofferRequest` (fn) | `(pool, privateKey, relays, toPubKey, data: NofferData, timeoutSeconds=30, onReceipt?) => Promise<NofferResponse>` | Throws if `description` is > 100 chars. |
| `newNofferEvent` (fn) | `(content, fromPub, toPub) => UnsignedEvent{kind:21001, tags:[['p',toPub],['clink_version','1']]}` | |
| `newNofferFilter` (fn) | `(publicKey, eventId) => Filter` | |

### Debits — `src/ndebit.ts` (kind 21002)

| Symbol | Signature | Notes |
|---|---|---|
| `RecurringDebitTimeUnit` (type) | `'day' \| 'week' \| 'month'` | |
| `BudgetFrequency` (type) | `{ number: number; unit: RecurringDebitTimeUnit }` | |
| `NdebitData` (type) | `{ pointer?: string; amount_sats?: number; bolt11?: string; frequency?: BudgetFrequency; k1?: string }` | `k1` field added in v1.5.5 (PR #16 "ndebit-k1"). |
| `NdebitSuccess` (type) | `{ res: 'ok'; preimage?: string }` | |
| `NdebitFailure` (type) | `{ res: 'GFY'; error: string; code: number }` | "GFY" is the project's response-failure discriminator. |
| `NdebitResponse` (type) | `NdebitSuccess \| NdebitFailure` | |
| `SendNdebitRequest` (fn) | `(pool, privateKey, relays, toPubKey, data: NdebitData, timeoutSeconds?) => Promise<NdebitResponse>` | (An older inline-implementation version is present commented out.) |
| `newNdebitFullAccessRequest` (fn) | `(pointer?: string) => NdebitData` | Whitelist-style request. |
| `newNdebitPaymentRequest` (fn) | `(invoice: string, amount?: number, pointer?: string) => NdebitData` | |
| `newNdebitBudgetRequest` (fn) | `(frequency: BudgetFrequency, amount: number, pointer?: string) => NdebitData` | |
| `newNdebitEvent` (fn) | `(content, fromPub, toPub) => UnsignedEvent{kind:21002, tags:[['p',toPub],['clink_version','1']]}` | |
| `newNdebitFilter` (fn) | `(publicKey, eventId) => Filter` | |

### Manage — `src/nmanage.ts` (kind 21003)  *(verdict: SHIPPED)*

| Symbol | Signature | Notes |
|---|---|---|
| `NmanageSuccess` (type) | `{ res: 'ok'; resource: 'offer'; details?: OfferData \| OfferData[] }` | Currently `resource` is locked to `'offer'`. |
| `NmanageFailure` (type) | `{ res: 'GFY'; error: string; code: number; delta?: { max_delta_ms; actual_delta_ms }; retry_after?: number; field?: string; range?: { min; max } }` | Rich error with rate-limit / range hints. |
| `NmanageResponse` (type) | `NmanageSuccess \| NmanageFailure` | |
| `OfferFields` (type) | `{ label: string; price_sats: number; callback_url: string; payer_data: string[] }` | |
| `OfferData` (type) | `OfferFields & { id: string; noffer: string }` | The `noffer` field is the bech32-encoded pointer the service returns. |
| `NmanageCreateOffer` (type) | `{ resource:'offer'; action:'create'; pointer?: string; offer:{ fields: OfferFields } }` | |
| `NmanageUpdateOffer` (type) | `{ resource:'offer'; action:'update'; offer:{ id; fields: OfferFields } }` | |
| `NmanageDeleteOffer` (type) | `{ resource:'offer'; action:'delete'; offer:{ id } }` | |
| `NmanageGetOffer` (type) | `{ resource:'offer'; action:'get'; offer:{ id } }` | |
| `NmanageListOffers` (type) | `{ resource:'offer'; action:'list'; pointer?: string }` | |
| `NmanageRequest` (type) | union of the five above | |
| `SendNmanageRequest` (fn) | `(pool, privateKey, relays, toPubKey, data: NmanageRequest, timeoutSeconds?) => Promise<NmanageResponse>` | Sends `kind: 21003`. |
| `newNmanageEvent` (fn) | `(content, fromPub, toPub) => UnsignedEvent{kind:21003, tags:[['p',toPub],['clink_version','1']]}` | |
| `newNmanageFilter` (fn) | `(publicKey, eventId) => Filter` | |
| `newCreateRequest` (fn) | `(label: string, data?: { price_sats?; callback_url?; payer_data? }, pointer?) => NmanageCreateOffer` | |
| `newUpdateRequest` (fn) | `(updatedOffer: OfferData) => NmanageUpdateOffer` | |
| `newDeleteRequest` (fn) | `(offerId: string) => NmanageDeleteOffer` | |
| `newGetRequest` (fn) | `(offerId: string) => NmanageGetOffer` | |
| `newListRequest` (fn) | `(pointer?: string) => NmanageListOffers` | |

### Bech32 / NIP-19 extension — `src/nip19Extension.ts`

| Symbol | Signature | Notes |
|---|---|---|
| `utf8Decoder`, `utf8Encoder` (const) | `TextDecoder`, `TextEncoder` | |
| `Noffer`, `Ndebit`, `Nmanage` (types) | template-literal types `\`noffer1${string}\`` etc. | |
| `Bech32MaxSize` (const) | `5000` | |
| `BECH32_REGEX` (const) | RegExp | |
| `OfferPriceType` (enum) | `Fixed = 0`, `Variable = 1`, `Spontaneous = 2` | Only public `enum` in the SDK. |
| `ManagePointer` (type) | `{ pubkey: string; relay: string; pointer?: string }` | |
| `OfferPointer` (type) | `{ pubkey; relay; offer; priceType: OfferPriceType; price? }` | |
| `DebitPointer` (type) | `{ pubkey; relay; pointer? }` | |
| `DecodeResult` (type) | discriminated union over `noffer`/`ndebit`/`nmanage` | |
| `decodeBech32` (fn, overloaded) | `(nip19: \`${Prefix}1${string}\`) => DecodeValue<Prefix>` and `(nip19: string) => DecodeResult` | Throws on missing required TLVs. |
| `nofferEncode` (fn) | `(offer: OfferPointer) => string` | Emits `noffer1...`. |
| `ndebitEncode` (fn) | `(debit: DebitPointer) => string` | Emits `ndebit1...`. |
| `nmanageEncode` (fn) | `(manage: ManagePointer) => string` | Emits `nmanage1...`. |

`parseTLV`, `encodeTLV`, and `integerToUint8Array` are module-private (no
`export`). The commented-out `NostrTypeGuard` block (`isNoffer`, `isNdebit`)
is **not** exported.

### `sender.ts` — internal

| Symbol | Signature | Notes |
|---|---|---|
| `sendRequest` (fn, exported) | `<T>(pool, pair, relays, toPub, e: UnsignedEvent, kindExpected: number, timeoutSeconds?, moreCb?) => Promise<T>` | Re-used by `noffer/ndebit/nmanage`. **Not** re-exported from `index.ts`, so it is technically reachable via `@shocknet/clink-sdk/build/sender.js` but not part of the documented surface. Includes verbose `console.log` instrumentation in v1.5.5. |
| `newFilter` (fn, exported) | `(publicKey, eventId, kindExpected) => Filter` | Same caveat. |

### Re-exports from `nostr-tools` (top of `src/index.ts`)

`SimplePool`, `getPublicKey`, `nip19`, `generateSecretKey` are re-exported by
name. `AbstractSimplePool` and `SubCloser` types appear in signatures but are
not re-exported.

## Manage verdict: **SHIPPED (full CRUD + list + get).**

Direct evidence from `src/nmanage.ts` (full file in source):

```ts
export const SendNmanageRequest = async (pool: AbstractSimplePool, privateKey: Uint8Array, relays: string[], toPubKey: string, data: NmanageRequest, timeoutSeconds?: number): Promise<NmanageResponse> => {
    const publicKey = getPublicKey(privateKey)
    const content = encrypt(JSON.stringify(data), getConversationKey(privateKey, toPubKey))
    const event = newNmanageEvent(content, publicKey, toPubKey)
    return sendRequest(pool, { privateKey, publicKey }, relays, toPubKey, event, 21003, timeoutSeconds)
}

export const newNmanageEvent = (content: string, fromPub: string, toPub: string) => ({
    content,
    created_at: Math.floor(Date.now() / 1000),
    kind: 21003,
    pubkey: fromPub,
    tags: [['p', toPub], ['clink_version', '1']]
})
```

And from `src/index.ts`:

```ts
import { NmanageRequest, SendNmanageRequest, newListRequest } from "./nmanage.js"
...
Nmanage = (data: NmanageRequest, timeoutSeconds?: number) => {
    return SendNmanageRequest(this.pool, this.settings.privateKey, this.settings.relays, this.settings.toPubKey, data, timeoutSeconds || this.settings.defaultTimeoutSeconds)
}
...
export * from './nmanage.js'
```

Concretely, the SDK exposes:

- Top-level: `SendNmanageRequest`, `NmanageRequest`, `NmanageResponse`, plus
  builders `newCreateRequest`, `newUpdateRequest`, `newDeleteRequest`,
  `newGetRequest`, `newListRequest` and event/filter helpers
  `newNmanageEvent` / `newNmanageFilter`.
- Class method: `sdk.Nmanage(data, timeoutSeconds?)`.
- Bech32: `nmanageEncode`, plus `decodeBech32` resolving the `nmanage` arm.

Currently the resource taxonomy in the type union is locked to
`resource: 'offer'` — i.e. the manage primitive ships, but only the *offer*
resource is modeled. There is no `resource: 'debit'`, no `resource:
'pointer'`, no `resource: 'permission'`, etc. The success type does carry a
generic `resource: 'offer'` discriminator that *could* be widened later
without breaking consumers that already type-narrow on `'offer'`.

## Documented vs undocumented surface (README diff)

The README at `4de86559` documents:

- `ClinkSDK` constructor, plus `Noffer`, `Ndebit`, **`Nmanage`** methods (including `Promise<NmanageResponse>` return type).
- `nofferEncode`, `ndebitEncode`, `decodeBech32`.
- Types: `NofferData`, `NofferResponse`, `NofferReceipt`, `NdebitData`,
  `NdebitResponse`, `OfferPointer`, `DebitPointer`, `OfferPriceType`,
  `BudgetFrequency`.

Exported but **not documented** in the README:

- All Manage builder helpers: `newCreateRequest`, `newUpdateRequest`,
  `newDeleteRequest`, `newGetRequest`, `newListRequest`.
- Manage types: `NmanageRequest`, `NmanageResponse`, `NmanageSuccess`,
  `NmanageFailure`, `NmanageCreateOffer`, `NmanageUpdateOffer`,
  `NmanageDeleteOffer`, `NmanageGetOffer`, `NmanageListOffers`,
  `OfferFields`, `OfferData`, `ManagePointer`.
- `nmanageEncode` (the README only mentions noffer/ndebit encoders).
- The `Nmanage` keyword bech32 prefix in general — Manage is in the API
  reference list of methods but completely absent from the prose Features
  section, which still says "noffer1... and ndebit1... on Nostr."
- Direct `SendNofferRequest` / `SendNdebitRequest` / `SendNmanageRequest`
  function exports (only the `ClinkSDK` wrappers are documented).
- `newNoffer/Ndebit/Nmanage` event + filter helpers.
- `OfferPriceType.Spontaneous` (Fixed / Variable / Spontaneous all exist;
  README lists them in the enum but doesn't explain `Spontaneous` semantics).
- `RecurringDebitTimeUnit` type.
- `Ndebit.k1` field added in v1.5.5.
- `payer_data` typing inconsistency: `any` in `NofferData` vs `string[]` in
  `OfferFields` (Manage).

## Version timeline (commit dates of release tags)

| Tag    | Commit date           | Notes |
|--------|-----------------------|-------|
| v1.1.1 | (early)               | First seen tag in repo. |
| v1.1.7 | (early)               | |
| v1.2.0 | 2025-08-01T17:29:40Z  | |
| v1.3.0 | 2025-08-01T20:54:33Z  | |
| v1.3.1 | (post 1.3.0)          | |
| v1.3.2 | (post 1.3.1)          | |
| v1.4.0 | 2025-09-16T18:02:00Z  | |
| v1.5.0 | 2025-10-07T21:20:05Z  | Likely the version that introduced `Nmanage` + nip19 `nmanage` arm based on README/method shape (needs cross-check vs git diff if pinned). |
| v1.5.1 | (between)             | |
| v1.5.3 | (between)             | |
| v1.5.4 | 2025-12-29T19:13:06Z  | "markdown fix" — README polish only. |
| v1.5.5 | 2026-06-01T17:02:58Z  | PR #16 "Ndebit k1" — added optional `k1` field to `NdebitData`. |

Latest commit on `main`: `9ce565d7` at `2026-06-01T17:02:58Z` (the v1.5.5
merge). Repo `pushed_at` is `2026-06-09T18:37:13Z` but only refs/branches
were touched after that — no source change.

## Why this matters for the wiki

1. Manage support is shipped in v1.5+. Earlier wiki notes (compiled
   2026-06-09) had to hedge on this because npm was unreachable; we can now
   state it definitively from source: `kind: 21003` is wired all the way
   from `SendNmanageRequest` → `newNmanageEvent` → `sendRequest` → relay
   publish, with full CRUD + list builders.
2. Manage is **offer-resource-only** at the type level today. Anyone
   building debit-management or pointer-management features against this
   SDK must either fork or contribute upstream — the runtime would accept a
   different `resource` string (it's just JSON), but TypeScript won't.
3. The SDK's `payer_data` typing diverges between Offers (`any`) and Manage
   (`string[]`). For wiki readers comparing CLINK against LNURL/Bolt 12
   payer-data conventions, this is a real wart worth flagging.
4. The `clink_version: '1'` tag is set on every event (`noffer`/`ndebit`/
   `nmanage`); this is the only protocol-version handshake in the wire
   format and lives entirely in tags, not content.
5. Receipts (paid-invoice notifications) are an Offers-only construct
   surfaced via `onReceipt` callback; Debits and Manage have no equivalent.
6. The keywords list advertises `bolt12`, `nip47`, `lnurl`, `zaps`, `nip57`
   — none of those have any code in the SDK. Treat them as positioning,
   not capability.
7. Internal modules `sender.ts` (`sendRequest`, `newFilter`) are exported
   from their own files but **not** re-exported from `index.ts`. They are
   reachable as deep imports but should be treated as private.
8. `package.json` declares `"type": "module"` and `"main":
   "build/index.js"` — pure ESM, no CJS bundle, no `exports` map. Consumers
   on CJS toolchains will need a bundler that handles ESM-only packages.
