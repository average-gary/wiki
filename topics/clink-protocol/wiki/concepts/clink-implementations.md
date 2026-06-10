---
title: CLINK implementations and adoption
type: concept
created: 2026-06-09
updated: 2026-06-09
confidence: high
sources:
  - raw/repos/2026-06-09-implementations-shocknet-clink.md
  - raw/repos/2026-06-09-implementations-stackernews-clink.md
  - raw/repos/2026-06-09-implementations-lightning-pub.md
  - raw/repos/2026-06-09-implementations-shockwallet.md
  - raw/repos/2026-06-09-implementations-bridgelet-and-sdk.md
---

# CLINK implementations and adoption

Snapshot as of 2026-06-09.

## Status summary

CLINK Offers + Debits are **shipped in production** through the ShockNet first-party stack (Lightning.Pub + ShockWallet) and through one confirmed third-party adopter (Stacker News, since Sept 2025). **Manage is the least-shipped primitive** — only ShockWallet has client-side support; no service-side adopter advertises Manage.

Adoption beyond ShockNet + Stacker News is essentially zero among major Nostr clients (Damus, Amethyst, Primal, Coracle) and major Lightning wallets (Alby, Mutiny). Whether this is a recency effect, an architectural disagreement, or NWC entrenchment is not yet clear.

## First-party (ShockNet)

| Repo | Role | Language | Status | CLINK features |
|------|------|----------|--------|----------------|
| [Lightning.Pub](https://github.com/shocknet/Lightning.Pub) | Reference server | TypeScript | Beta-shipped, packaged for Start9/StartOS | Offers + Debits (Manage not confirmed) |
| [wallet2 / ShockWallet](https://github.com/shocknet/wallet2) | Reference wallet | TypeScript | Late-stage beta (`v0.0.28-beta`, 2026-06-06) | Offers + Debits + **Manage** (only known Manage adopter) |
| [ClinkSDK](https://github.com/shocknet/ClinkSDK) | JS client library | TypeScript | npm `@shocknet/clink-sdk` `^1.4.0` | Offers + Debits (Manage not advertised) |
| [bridgelet](https://github.com/shocknet/bridgelet) | LNURL/NIP-05 → CLINK bridge | TypeScript / Bun | Fork-to-customize starter (no releases) | Offers (LNURL-pay translation, NIP-57 zaps with degradation) |
| [clink-demo](https://github.com/shocknet/clink-demo) | Web demo | HTML/JS | Reference UX | Offers |

### Lightning.Pub specifics

- 93 GitHub stars (most-starred in the ShockNet org).
- Wraps LND (no CLN/LDK/Eclair fork as of 2026-06-09).
- Runs Neutrino SPV — no separate Bitcoin node required.
- README hedge: *"While this software has been used in a high-profile production environment for several years, it should still be considered bleeding edge."*
- Recent CLINK-tagged migration `1765497600000-clink_requester.ts` (2025-12-12) adds `clink_requester_pub` and `clink_requester_event_id` columns — schema work continues.

### ShockWallet release timeline (CLINK-relevant)

| Version | Date | CLINK milestone |
|---------|------|-----------------|
| `v0.0.19-beta` | 2025-06-10 | "clink client" (#392) — first CLINK support |
| `v0.0.20-beta` | 2025-08-11 | "clink manage auth and list" (#437) — **first evidence of Manage shipping** |
| `v0.0.21-beta` | 2025-09-20 | "up clink", "bridge types" |
| `v0.0.22-beta` | 2025-10-10 | "Blinded path offers" — BOLT12 interop alongside CLINK |
| `v0.0.28-beta` | 2026-06-06 | "update clink / noffer" (#615) |

iOS distribution is TestFlight only; Apple App Store status unconfirmed.

### ClinkSDK public API (extracted from Stacker News imports)

- `decodeBech32` — TLV unpacker for `noffer` / `ndebit` / `nmanage`
- `generateSecretKey` — payer-side ephemeral-key generation
- `newNdebitPaymentRequest` — builds encrypted kind-21002 events
- `SendNdebitRequest`, `SendNofferRequest` — wire-level send helpers
- `SimplePool` — relay-pool wrapper (likely re-export from `nostr-tools`)
- `OfferPriceType` — enum mirroring TLV-3 pricing types

**No `SendNmanageRequest` or equivalent has been observed in third-party imports** — Manage is not advertised in the SDK README ecosystem entry.

## Third-party adoption

### Stacker News (only confirmed non-ShockNet production adopter)

[github.com/stackernews/stacker.news](https://github.com/stackernews/stacker.news) — the "Hacker News for Bitcoin" site. CLINK is one of 10 wallet protocols in the SN wallet abstraction:

```
@typedef {'NWC'|'LNBITS'|'PHOENIXD'|'BLINK'|'WEBLN'|'LN_ADDR'|'LNC'|'CLN_REST'|'LND_GRPC'|'CLINK'} ProtocolName
```

| Migration | Date | Effect |
|-----------|------|--------|
| `20250905014333_clink_recv` | 2025-09-05 | CLINK added to recv enum |
| `20250914020103_clink_send` | 2025-09-14 | CLINK added to send enum and **prepended** to `sendProtocols` array |

Live in production for ~9 months by 2026-06-09. SDK pinned at `^1.4.0`. Active dep maintenance with upstream PRs (`a2f653c`, 2026-05-27, fixed an `@shocknet/clink-sdk` packaging issue with `rimraf`).

**SN constraint**: spontaneous-only price guard — `if (type === 'noffer' && data.priceType && data.priceType !== OfferPriceType.Spontaneous)` rejects non-spontaneous offers.

**Tested interop**: Stacker News's developer doc (`wallets/lib/protocols/docs/dev/clink.md`) explicitly tests against Lightning.Pub + ShockWallet only:

> "Testing CLINK is done with Lightning.Pub and Shockwallet. [...] Run this command to get `nprofile` of the lnpub container: `sndev logs --since 0 lnpub | grep -oE 'nprofile1\\w+'`"

### Listed in CLINK README ecosystem table — verification status

| Adopter | README claim | Verification |
|---------|-------------|--------------|
| Lightning.Pub | Offers + Debits | ✅ Confirmed |
| ShockWallet | Offers + Debits | ✅ Confirmed (+ Manage client-side) |
| ClinkSDK | Offers + Debits | ✅ Confirmed |
| Stacker News | Offers + Debits | ✅ Confirmed (production code) |
| Zeus Wallet | Offers ("ZEUS Pay default") | ⚠️ Verification gap — Zeus README has zero CLINK terminology. Possibly aspirational or a feature flag |
| TakeMySats | Offers (merchant platform) | ⚠️ Not code-verified |
| bxrd.app | Offers + Debits | ⚠️ Live site has no CLINK reference; production status uncertain |
| Bridgelet | Offers | ✅ Code confirmed |
| clinkme.dev demo | Offers + Debits | ✅ Confirmed |

### Conspicuously absent

Major NWC ecosystem (Alby Hub, Alby Go, Mutiny, Coinos, ZBD): zero CLINK adoption. Major Nostr clients (Damus, Amethyst, Primal, Coracle): zero CLINK adoption. The CLINK pitch — which directly criticizes NWC's pre-shared-secret model — has not yet won over any of those projects.

## Maturity assessment

- **Spec**: beta / actively converging. No git tags, spec lives on `main`. Three primitives drafted, three event kinds reserved. June 2026 churn (k1 revision, README rewrite, ecosystem table) reads like a "1.0 readiness" moment.
- **Reference stack**: production-shipped with caveats. Lightning.Pub claims multi-year prod history; ShockWallet at `v0.0.28-beta`.
- **Third-party adoption**: 1 confirmed (Stacker News) + 3 listed-but-light-verification + several unverified.
- **SDK ceiling**: JS-only. No Rust, Python, Go, Swift, Kotlin SDKs. Real adoption ceiling for non-JS wallets.

## Open questions

- Is anyone shipping `nmanage` server-side? (No evidence outside ShockWallet client-side.)
- Does Zeus actually implement CLINK Offers, or is the README ecosystem-table claim aspirational? Zeus README mentions zero CLINK terminology.
- bxrd.app: README says "Debit integration for Zaps" but the live site landing page makes no CLINK reference. Production status?
- Why no adoption among major Nostr clients (Damus, Amethyst, Primal)? Spec recency, NWC dominance, or strategic skepticism?
- Are there non-JS CLINK SDK efforts in flight? (None visible on github.com/shocknet.)

## See also

- [[clink-overview.md]]
- [[../topics/clink-vs-alternatives.md]]
- [[../topics/clink-roadmap-signals.md]]
- [[../reference/specs-and-repos.md]]
