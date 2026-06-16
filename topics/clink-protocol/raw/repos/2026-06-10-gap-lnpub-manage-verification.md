---
title: "Lightning.Pub server-side CLINK Manage support — verification"
source: https://github.com/shocknet/Lightning.Pub
type: repo
ingested: 2026-06-10
path: gap-lnpub-manage
quality: 5
credibility: high
tags: [clink, manage, lightning-pub, server-side, kind-21003]
---

# Lightning.Pub server-side CLINK Manage support — verification

## Verdict

**SHIPPED.** Lightning.Pub has a complete, in-tree server-side handler for CLINK Manage (kind 21003 / `nmanage`). The README ecosystem table being silent on Manage is a docs gap, not a code gap. The handler has been on `master` since mid-2025, with the bulk of the implementation landing on **2025-06-30** ("nmanage backend flow", commit `668a5bbac5`) and authorization plumbing/grant management iterating through July 2025.

Separately confirmed: the `clink_requester` migration (`1765497600000`, 2025-12-12) is **NOT** Manage scaffolding — it backs the Offers (kind 21001) flow, recording the requester's pub/event-id on the resulting invoice so an encrypted CLINK receipt can be sent back when the invoice is paid.

## Source overview

Repo: `shocknet/Lightning.Pub` (master). Investigation tools: `gh search code`, `gh api` (commits + contents), and WebFetch of raw blobs. No clone needed.

The CLINK surface area in Lightning.Pub is implemented as three peer manager classes living under `src/services/main/`:

- `offerManager.ts` — kind 21001 (`noffer`)
- `debitManager.ts` — kind 21002 (`ndebit`)
- `managementManager.ts` — kind 21003 (`nmanage`)

All three are dispatched from `src/nostrMiddleware.ts` based on `event.kind`. The Manage handler additionally relies on a dedicated SQL table (`management_grant`) for authorization grants, an `app_pubkey`-keyed banlist column, and a `awaitingRequests` in-memory map for requests that arrive before the user has authorized the requesting pubkey.

## Code-path findings

### 1. Kind-21003 dispatch — `src/nostrMiddleware.ts`

The middleware is the entry point from the relay subscription. The `nmanage` branch sits next to the `noffer`/`ndebit` branches:

```typescript
} else if (event.kind === 21003) {
    if (event.relayConstraint === 'provider') {
        log("got management request on provider only relay, ignoring")
        return
    }
    const nmanageReq = j as NmanageRequest
    mainHandler.managementManager.handleRequest(nmanageReq, event);
```

`NmanageRequest` is imported from `@shocknet/clink-sdk`, the same SDK that hosts `NofferData` and `NdebitData`. Commit history of this dispatch site (filtered for manage/21003): `2025-06-30 668a5bbac5 "nmanage backend flow"` and `2025-06-14 441f47d50e "external offer management"`.

### 2. Handler — `src/services/main/managementManager.ts`

Full action surface in one switch statement (verbatim from `doNmanage`):

```typescript
private async doNmanage(nmanageReq: NmanageRequest, event: NostrEvent): Promise<Result<NmanageResponse>> {
    const action = nmanageReq.action
    switch (action) {
        case "create":
            const createResult = await this.createOffer(nmanageReq, event.pub)
            return this.getNmanageResponse(event.appId, createResult)
        case "update":
            const updateResult = await this.updateOffer(nmanageReq, event.pub);
            return this.getNmanageResponse(event.appId, updateResult)
        case "delete":
            const deleteResult = await this.deleteOffer(nmanageReq, event.pub);
            return this.getNmanageResponse(event.appId, deleteResult)
        case "get":
            const getResult = await this.getOffer(nmanageReq, event.pub);
            return this.getNmanageResponse(event.appId, getResult)
        case "list":
            const listResult = await this.listOffers(nmanageReq, event.pub);
            return this.getNmanageResponse(event.appId, listResult)
        default:
            return { state: 'error', err: { res: 'GFY', code: 1, error: `Request Denied: Unknown action: ${action}` } }
    }
}
```

All five Manage verbs from the spec (create / update / delete / get / list) are implemented. Imports from `@shocknet/clink-sdk` confirm the typed request/response payloads:

```typescript
import { ..., NmanageRequest, NmanageResponse, NmanageCreateOffer, NmanageUpdateOffer, NmanageDeleteOffer, NmanageGetOffer, NmanageListOffers, OfferData, OfferFields, NmanageFailure } from "@shocknet/clink-sdk";
```

The class also exposes RPC-side methods (`AuthorizeManage`, `GetManageAuthorizations`, `ResetManage`) for the wallet/owner to authorize remote managers, plus an `awaitingRequests` map and a `sendManageAuthorizationRequest` helper that pushes a live-prompt event to the wallet when an unauthorized npub asks to manage:

```typescript
AuthorizeManage = async (ctx: Types.UserContext, req: Types.ManageAuthorizationRequest): Promise<Types.ManageAuthorization> => {
    const grant = await this.storage.managementStorage.addGrant(ctx.app_user_id, req.authorize_npub, req.ban)
    const awaiting = this.awaitingRequests[req.authorize_npub]
    if (awaiting) {
        delete this.awaitingRequests[req.authorize_npub]
        if (!grant.banned) {
            await this.handleRequest(awaiting.request, awaiting.event)
        }
    }
    ...
}
```

Commit history for `managementManager.ts` (18 commits total):
- First: `2025-06-15 6a1cedd718 "move stuff"`
- Substantive flow: `2025-06-30 668a5bbac5 "nmanage backend flow"`
- Authorization: `2025-07-08 df088bf0fe "manage authorization"`
- Latest: `2025-12-17 991f49fe69 "sender helper"`

### 3. `nmanage` bech32 encode — outbound advertisement

Lightning.Pub doesn't just respond to `nmanage` requests, it also **advertises** `nmanage` strings to clients. Two callers in `appUserManager.ts` and `applicationManager.ts`:

```typescript
nmanage: nmanageEncode({ pubkey: app.nostr_public_key!, pointer: appUser.identifier, relay: nostrSettings.relays[0] }),
```

This is also reflected in the protobuf schema (`proto/service/structs.proto`):

```
string nmanage = 12;
```

So the `nmanage` URI is part of the public RPC response shape returned alongside `noffer`/`ndebit`.

### 4. Storage — Manage tables

Two migrations specifically support Manage authorization, predating the December `clink_requester` migration by ~5 months:

- `1751307732346-management_grant.ts` (2025-06-30 commit `136a9ad231 "fixies"` — first appearance) — creates `management_grant` table with columns `serial_id`, `app_user_id`, `app_pubkey`, `expires_at_unix`, `created_at`, `updated_at`. Same migration adds `management_pubkey` to `user_offer`.
- `1751989251513-management_grant_banned.ts` — adds the `banned` column for the ban-list path used by `AuthorizeManage`'s `req.ban`.

Direct quote from the `management_grant` migration:

```sql
CREATE TABLE "management_grant" (
  "serial_id" integer PRIMARY KEY AUTOINCREMENT NOT NULL,
  "app_user_id" varchar NOT NULL,
  "app_pubkey" varchar NOT NULL,
  "expires_at_unix" integer NOT NULL,
  "created_at" datetime NOT NULL DEFAULT (datetime('now')),
  "updated_at" datetime NOT NULL DEFAULT (datetime('now'))
)
```

Entity wrapper at `src/services/storage/entity/ManagementGrant.ts`; storage helper at `src/services/storage/managementStorage.ts` (`addGrant`, `getGrants`, `removeGrant`).

### 5. Supported-kinds list — `src/services/nostr/`

Two corroborating references in the relay layer:

```typescript
// src/services/nostr/handler.ts
/* const supportedKinds = [21000, 21001, 21002, 21003]
```
(commented-out reference; see `nostrPool.ts` for the live list)

```typescript
// src/services/nostr/nostrPool.ts
const actionKinds = [21000, 21001, 21002, 21003]
```

21000 here is the response kind that wraps all three CLINK request kinds; 21003 being in the live `actionKinds` confirms the relay subscriber is actually listening for it.

## What the `clink_requester` migration is actually for

Originally suspected as Manage scaffolding; it isn't. The flow is Offers-only:

1. `nostrMiddleware.ts` receives a kind-21001 event and calls `offerManager.handleClinkOffer(offerReq, event)`.
2. `offerManager.ts` constructs `clinkRequester = { pub: event.pub, eventId: event.id }` from the inbound nostr event.
3. Both `HandleDefaultUserOffer` and `HandleUserOffer` pass that object as the third argument to `applicationManager.AddAppUserInvoice(appId, req, clinkRequester)`:

   ```typescript
   const res = await this.applicationManager.AddAppUserInvoice(appId, {
       http_callback_url: "", payer_identifier: offer, receiver_identifier: offer,
       invoice_req: { amountSats: amount, memo: memo || "Default CLINK Offer", zap: offerReq.zap, expiry },
       offer_string: 'offer'
   }, clinkRequester)
   ```

4. `applicationManager.AddAppUserInvoice` plumbs those into `InboundOptionals`:

   ```typescript
   const opts: InboundOptionals = {
       ...,
       clinkRequesterPub: clinkRequester?.pub,
       clinkRequesterEventId: clinkRequester?.eventId
   }
   ```

5. `paymentStorage.ts` writes them onto the `user_receiving_invoice` row (the columns added by migration `1765497600000-clink_requester.ts`).
6. On payment, `src/services/main/index.ts` checks them and emits an encrypted CLINK receipt back to the requester:

   ```typescript
   try {
       if (paidInvoice.clink_requester_pub && paidInvoice.clink_requester_event_id) {
           await this.createClinkReceipt(log, paidInvoice)
       }
   } catch (err: any) {
       log(ERROR, "cannot create clink receipt", err.message || "")
   }
   ```

Manage (kind 21003) does not allocate invoices in its handler — `managementManager.ts` is purely a CRUD surface over `UserOffer` records and doesn't touch `clink_requester_*`. So the December 2025 migration is **Offers receipt scaffolding, not Manage scaffolding**.

## Why this matters

- **README ecosystem table is out of date.** The CLINK README only credits Lightning.Pub for Offers + Debits, but the implementation has supported Manage on `master` since 2025-06-30. Any wiki article ranking Lightning.Pub's CLINK coverage should reflect Offers + Debits + Manage + receipt-back-to-requester.
- **Lightning.Pub is the de-facto reference Manage server.** No other server in the ecosystem is known to implement kind 21003. This makes Lightning.Pub the canonical implementation to study for Manage semantics: action set (`create|update|delete|get|list`), error codes (`{ res: 'GFY', code, error }`), authorization grant lifecycle (live-prompt + ban list), and the encoded `nmanage` advertisement shape.
- **Spec correlates with implementation.** The `NmanageRequest` / `NmanageResponse` / `OfferFields` types come from `@shocknet/clink-sdk`, so the Manage payload shape is shared with the reference SDK. This is a strong signal that Lightning.Pub is the intended interop target, not a one-off interpretation.
- **Migration date confusion resolved.** The Dec 2025 `clink_requester` migration looked Manage-shaped at first glance (a CLINK requester needs to be tracked for a reply), but it is purely the Offers-flow receipt path. Articles that cite the migration as evidence of Manage activity should be corrected.

## Specific code paths (for citation)

- `src/nostrMiddleware.ts` — kind 21003 dispatch to `managementManager.handleRequest`
- `src/services/main/managementManager.ts` — full handler (5 actions + auth + grant lifecycle)
- `src/services/storage/entity/ManagementGrant.ts` — grant entity
- `src/services/storage/managementStorage.ts` — grant storage helpers
- `src/services/storage/migrations/1751307732346-management_grant.ts` — initial Manage table (2025-06-30)
- `src/services/storage/migrations/1751989251513-management_grant_banned.ts` — ban column (2025-07)
- `src/services/main/applicationManager.ts` and `appUserManager.ts` — `nmanageEncode(...)` advertisement
- `src/services/nostr/nostrPool.ts` — `actionKinds = [21000, 21001, 21002, 21003]`
- `proto/service/structs.proto` — `string nmanage = 12;`

NOT Manage-related (despite the name):
- `src/services/storage/migrations/1765497600000-clink_requester.ts` — Offers (21001) receipt-back wiring
