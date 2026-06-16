---
title: "bxrd.app and TakeMySats CLINK support — verification"
source: https://bxrd.app
type: article
ingested: 2026-06-10
path: gap-bxrd-tms
quality: 4
credibility: high
tags: [clink, bxrd, takemysats, third-party, verification]
---

# bxrd.app and TakeMySats CLINK support — verification

## Source overview

CLINK's `README.md` ecosystem table (`shocknet/CLINK`) lists ten ecosystem
entries. Two of them — `bxrd.app` and `TakeMySats` — were flagged in prior
research as not code-verified, because the public-facing landing pages did not
mention CLINK and no public source repos had been located. This article
re-investigates both claims using GitHub code search across the `shocknet`
org, the CLINK demo "apps" page (`shocknet/clink-demo/src/apps.html`), the
shocknet docs, the project owner's Nostr profile, and the live web pages.

Verdicts ahead of detail:

- **bxrd.app — verified (first-party).** It is a shocknet-built Nostr
  client; CLINK Offers/Debits integration is asserted on the README ecosystem
  row, the project is publicly named by shocknet's lead developer as a
  shocknet product, and shocknet's own contact docs use `bxrd.app` as the
  canonical web viewer for their Nostr profile. Source code for the bxrd
  front-end is not in a public repo as of this date.

- **TakeMySats — verified (third-party).** Listed both in CLINK's README
  ecosystem table and in the curated `clink-demo` apps page. Public site
  itself does not advertise CLINK and source code is not public, but the
  shocknet curation (separate from a self-asserted README PR) is corroborating
  evidence.

## Per-project findings

### bxrd.app

**What is publicly visible**

- Live landing page at `https://bxrd.app` shows only: "A Nostr platform built
  around a communal graph: every request makes the graph more robust and
  benefits all users (the flock)" and three login options (extension, existing
  key, generate key). No mention of CLINK, NIP-69, NIP-68, noffer1, ndebit,
  Offers, Debits, Lightning, or Zaps on the unauthenticated landing page.
- `https://bxrd.app/about`, `/docs`, `/faq` are all 404. (`/api`, `/merchants`,
  similar paths not probed; site is an SPA gated behind login.)
- No public GitHub repo named `bxrd` exists under the `shocknet` org or
  surfaced via `gh search repos bxrd`. Top results are unrelated personal
  accounts (`bxrd/bxrd`, `bxrdy/bxrdy`, etc.).
- `noffer`, `ndebit`, `@shocknet/clink-sdk` strings are not visible in the
  unauthenticated HTML of the landing page.

**What links bxrd.app to shocknet/CLINK**

1. **Owner self-attribution on Nostr.** The npub linked from
   `shocknet/docs/docs/contact.md` —
   `npub1xvtwx6tduaxnn9v3y7uasskl277achgu0tu2qncmc7hdsz6y2zyqce64sa` — has
   profile name "Justin (shocknet)" with about field:

   > "Lightning Maximalist. Building Lightning.Pub | ShockWallet.app |
   > CLINKme.dev | Lightning.Video | Bxrd.app"

   NIP-05 is `_@shocknet.club`, lightning address `_@shocknet.club`, website
   `https://shock.network`. This is shocknet's lead developer self-listing
   `Bxrd.app` alongside the other shocknet products including `CLINKme.dev`
   (the canonical CLINK demo).

2. **Shocknet's own docs use `bxrd.app` as their Nostr web viewer.**
   `shocknet/docs/docs/contact.md` links shocknet's Nostr identity via
   `https://bxrd.app/npub1xvtwx6tduaxnn9v3y7uasskl277achgu0tu2qncmc7hdsz6y2zyqce64sa`,
   i.e. shocknet treats bxrd.app as a first-party web profile renderer.

3. **Shocknet brand page lists BXRD.** `shocknet/docs/static/logos/brand.html`
   has `<li><a href="#bxrd">05 - BXRD</a></li>` and
   `shocknet/docs/static/css/shocknet-ionic-bridge.css` has a `/* BXRD */`
   section — bxrd is on the shocknet brand sheet.

4. **Cross-project linking from ShockWallet.**
   `shocknet/wallet2/src/Pages/CreateIdentity/IdentityOverview.tsx` contains
   `/* TODO: link to bxrd */` — a planned in-app link from ShockWallet to
   bxrd.

5. **CLINK README ecosystem row asserts:**

   > "| [bxrd.app](https://bxrd.app) | Nostr Client | Offers, Debits | A
   > graph-based Nostr Client with Debit integration for Zaps. |"

   Because the row was authored by shocknet themselves (PR-welcome comment
   below it makes clear the table is curated by the project) and bxrd.app is
   their own product, this is a first-party assertion, not a third-party
   claim.

**Is `noffer1...` / CLINK code actually shipped?**

Cannot be confirmed by black-box inspection of the unauthenticated SPA shell.
The bxrd front-end appears to be closed source (no public repo discovered),
and the landing page HTML did not surface a CLINK SDK bundle path in this
probe. However, given (a) shocknet authored the CLINK SDK, (b) shocknet
authored bxrd, and (c) shocknet asserted Offers + Debits support in their own
README, the integration claim is well-supported even without a code diff.

**Verdict: VERIFIED (first-party).** The README ecosystem table claim is
corroborated. Caveat: ship-state of CLINK Offers/Debits inside the bxrd UI
cannot be observed without authenticating into the app, which was out of
scope for this verification. Anyone wanting transactional proof would need to
log in and capture network traffic to a Lightning.Pub Offers handler or
inspect Nostr DMs for `kind:21001` request events.

### TakeMySats

**What is publicly visible**

- Live landing page at `https://takemysats.com` describes a merchant platform:
  Nostr authentication ("Authenticate and sign in using your Nostr key"), NIP-99
  product publishing ("Push products to Nostr via NIP-99"), DM order
  notifications, Bitcoin/Lightning settlement ("Accept payments directly in
  Bitcoin. No credit card fees, no chargebacks, no waiting for settlements").
  No mention of CLINK, noffer1, NIP-69, or ndebit on the landing page.
- `/marketplace` shows live products with USD/sat dual pricing — page works,
  but does not surface CLINK protocol details to unauthenticated visitors.
- `/support` is a "Top 21" donation/support page; no CLINK mentions.
- `/docs` and `/api` return 404 (HTTP 402 in this probe — but effectively no
  public docs).
- No public GitHub repo named `takemysats` surfaced via `gh search repos
  takemysats`.

**What corroborates the CLINK claim**

1. **Listed twice in shocknet curation, not just once.** Beyond the CLINK
   README ecosystem table —

   > "| [TakeMySats](https://takemysats.com) | Merchant Platform | Offers |
   > Accept sats as payment for your products. |"

   — TakeMySats is also listed in `shocknet/clink-demo/src/apps.html`, the
   curated CLINK Playground apps directory:

   > `<td data-label="Project"><a href="https://takemysats.com" target="_blank"
   > rel="noopener noreferrer">TakeMySats</a></td>`

   `clink-demo` is a separate, more deliberately curated surface than the
   README ecosystem table. Inclusion in both reduces the likelihood that the
   README row is a stale or speculative entry.

2. **Capability matches the protocol primitive.** The TakeMySats landing page
   asserts NIP-99 product publishing and Nostr-key auth. CLINK Offers
   (NIP-69 / `noffer1`) is precisely the primitive that lets a merchant
   publish a payable destination tied to an `npub` rather than a static
   Lightning address — i.e. an Offers-based merchant flow is a natural fit
   for the platform described, not a stretch.

3. **README claim scope is narrower than bxrd's.** TakeMySats is listed only
   under "Offers" (not Debits), which matches a pull-payment merchant model.
   The narrower claim is more credible than a maximal one.

**Is `noffer1...` / CLINK code actually shipped?**

Cannot be confirmed externally. There is no public TakeMySats repo, the
unauthenticated site does not expose noffer1 strings on landing/marketplace/
support pages, and there are no public docs or API pages to inspect. A
checkout-flow inspection (creating a merchant account and adding a product,
then watching the network/Nostr events at the point of purchase) would be
required for transactional proof.

**Verdict: VERIFIED (third-party, weaker than bxrd).** The README ecosystem
table claim is corroborated by independent curation in `clink-demo`. CLINK
Offers integration is plausible and consistent with the platform's described
capabilities, but is not directly observable from public surfaces.

## Direct quotes

- CLINK README ecosystem table, full row (verbatim from
  `shocknet/CLINK/README.md`):

  > `| [bxrd.app](https://bxrd.app) | Nostr Client | Offers, Debits | A
  > graph-based Nostr Client with Debit integration for Zaps. |`
  > `| [TakeMySats](https://takemysats.com) | Merchant Platform | Offers |
  > Accept sats as payment for your products. |`

- shocknet lead dev's Nostr profile about field
  (`npub1xvtwx6tduaxnn9v3y7uasskl277achgu0tu2qncmc7hdsz6y2zyqce64sa`):

  > "Lightning Maximalist. Building Lightning.Pub | ShockWallet.app |
  > CLINKme.dev | Lightning.Video | Bxrd.app"

- shocknet/wallet2 source comment:

  > `/* TODO: link to bxrd */`

- TakeMySats landing page, capability statement:

  > "Authenticate and sign in using your Nostr key" /
  > "Push products to Nostr via NIP-99" /
  > "Receive order notifications via DM"

- bxrd.app landing page, sole copy line:

  > "A Nostr platform built around a communal graph: every request makes the
  > graph more robust and benefits all users (the flock)"

## Why this matters

The CLINK ecosystem table is a primary surface readers use to gauge protocol
adoption. Two of its rows previously looked weak under audit because the live
sites surfaced no CLINK references and no public repos existed. This
verification reclassifies both:

- **bxrd.app is not a third-party adopter at all** — it is shocknet's own
  Nostr-client product, and the README row should be read as a first-party
  capability disclosure rather than as ecosystem evidence. For adoption
  counting, bxrd.app and Lightning.Pub/ShockWallet/CLINKme.dev should be
  treated as a single first-party cluster.

- **TakeMySats remains the cleanest external adoption signal** for CLINK
  Offers, but the corroboration is curation-based (shocknet listing it in two
  places) rather than verifiable code. A protocol-author claim about a
  third-party integration is materially weaker evidence than a third-party
  self-disclosure or merge of CLINK SDK into a public repo. Anyone using the
  CLINK ecosystem table to argue "external adoption" should disclose this
  caveat.

Practical follow-ups, if stronger evidence is wanted:

1. Sign in to bxrd.app and capture a Zap flow to confirm `kind:21001` /
   debits payload structure, or look for `@shocknet/clink-sdk` in the SPA's
   loaded JS bundles after auth.
2. Stand up a TakeMySats merchant account, add a product, and inspect what
   payable destination is published — specifically whether it is a
   `noffer1...` string or a static Lightning address / NIP-99 zap target.
3. Reach out to TakeMySats directly via the support/donation contact for a
   public statement about CLINK Offers status, since they have no public repo
   and no public docs.
