---
title: CLINK discovery — NIP-05, HTTPS, NymRank
type: concept
created: 2026-06-09
updated: 2026-06-09
confidence: high
sources:
  - raw/articles/2026-06-09-spec-primitives-clink-issue-6-namecoin.md
  - raw/articles/2026-06-09-security-clink-offers-spec.md
  - raw/repos/2026-06-09-origin-shocknet-ecosystem-history.md
---

# CLINK discovery — NIP-05, HTTPS, and the bootstrap-trust caveat

CLINK markets itself as "operating entirely over Nostr," but the **default human-readable discovery hop still depends on HTTPS + DNS**. This page makes that dependency explicit and tracks the in-flight alternatives.

## How discovery works today

To go from a human-readable name (e.g. `bob@example.com`) to a `noffer1...` payment pointer, a CLINK client typically follows NIP-05:

1. Split `bob@example.com` → `(name="bob", host="example.com")`
2. **Fetch `https://example.com/.well-known/nostr.json?name=bob`** ← HTTPS + DNS dependency
3. Read the `clink_offer` field, which can be:
   - **Object map** (multiple offers): `"clink_offer": {"bob": "noffer1...", "tips": "noffer1..."}`
   - **Single string** (in kind 0 metadata `content.clink_offer`): `"noffer1..."`
4. Decode the noffer TLV → extract relay URL → subscribe → exchange kind 21001 events

Step 2 is the only hop that touches HTTPS/DNS/CAs. After that, everything is Nostr-native.

## Why this matters

- ShockNet's marketing pitch: "no web server needed, no pre-shared secrets, fully Nostr-native."
- Reality: the **bootstrap step** for human-readable identifiers still flows through HTTPS to the user's chosen domain — same trust root LNURL relies on. A CA compromise or DNS takeover spoofs CLINK addresses just as easily as LN-Addresses.
- Raw `noffer1...` strings (QR, copy/paste) bypass this — they carry a Nostr pubkey + relay directly. The HTTPS dependency only applies to the human-friendly `name@host` form.

## In-flight alternatives

### Issue #6 — Namecoin / ElectrumX (community proposal)

Opened 2026-05-18 by external contributor `mstrofnone`. Argues that **the right-hand side of a NIP-05 identifier can be resolved via Namecoin name + ElectrumX query** instead of HTTPS, with **zero spec changes** because CLINK reuses NIP-05's JSON shape. Claims 9+ clients already support this Namecoin pattern in production.

> "the right-hand side of a NIP-05 identifier is resolved by reading a Namecoin name via ElectrumX instead of by fetching `https://<host>/.well-known/nostr.json`"

Status: open, no maintainer response, no labels/milestone.

### NymRank — ShockNet's in-house answer (more likely)

ShockNet's own repo [NymRank](https://github.com/shocknet/NymRank) (seeded 2025-10-18) is described as "Namespace for nostr based on social consensus." It addresses the same problem (NIP-05 without HTTPS) but via Nostr Web-of-Trust rather than via a separate blockchain.

The two repos are not cross-linked, but the timing and shared-author signal strongly suggest **CLINK over NymRank** is the planned ShockNet answer, and issue #6 is unlikely to be merged as-is. Expect NymRank-style discovery to land before Namecoin support.

## Threat-model implications

| Asset | Threat in HTTPS-NIP-05 model | Mitigation |
|-------|------------------------------|------------|
| `name@host` resolution | DNS takeover | None at protocol layer; only CT logs |
| `name@host` resolution | CA compromise | None at protocol layer |
| `name@host` resolution | Web server compromise | None |
| Raw `noffer1...` | Off-band tampering | User vigilance; QR codes printed at trusted source |
| Raw `noffer1...` | Recipient key rotation | **Not addressed** — printed QRs can become dangling |

CLINK Offers' "ephemeral payer keys" recommendation reduces *payer*-side linkability but doesn't fix the recipient-side bootstrap dependency.

## What the spec says

The Offers spec acknowledges discovery indirectly:

> "Receiving services should be mindful of potential rate-limiting or abuse vectors on their listening relay."

The README and clinkme.dev marketing emphasize Nostr-native flow. Neither spec text nor README explicitly highlights the HTTPS bootstrap caveat — issue #6 is the first place it surfaces in writing.

## Open questions

- Will ShockNet adopt NymRank or Namecoin (or both) as standardized CLINK discovery transports?
- How would a wallet decide which transport to attempt for a given identifier (suffix sniff? user config? both attempted?)
- Will spec language be amended to acknowledge the HTTPS bootstrap caveat?
- Is `clink_offer` the only NIP-05 field CLINK relies on, or does Manage also need a discovery surface?
- Should `nmanage1...` and `ndebit1...` pointers also be discoverable through NIP-05? Spec is silent.

## See also

- [[clink-overview.md]]
- [[clink-offers.md]]
- [[clink-wire-format.md]]
- [[../topics/clink-security-and-trust.md]]
- [[../topics/clink-roadmap-signals.md]] — NymRank as roadmap signal
