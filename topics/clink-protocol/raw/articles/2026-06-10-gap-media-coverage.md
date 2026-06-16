---
title: "CLINK media coverage sweep — conferences, podcasts, newsletters"
source: (multiple)
type: article
ingested: 2026-06-10
path: gap-media
quality: 3
credibility: high
tags: [clink, media-coverage, conferences, podcasts, optech]
---

# CLINK media coverage sweep — conferences, podcasts, newsletters

Date of sweep: 2026-06-10. Goal: identify any conference talk, podcast appearance, or
newsletter that engaged substantively with CLINK / ShockNet / Justin Shocknet. Absence
of coverage is itself reported below.

## Verdict (TL;DR)

CLINK has, as of 2026-06-10:

- **0** Bitcoin Optech newsletter mentions (CLINK / ShockNet / noffer / ndebit).
- **0** Citadel Dispatch episodes.
- **0** Stephan Livera Podcast episodes.
- **0** What Bitcoin Did episodes.
- **0** Bitcoin Magazine articles.
- **0** confirmed Nostrasia, BTC++, BTC Prague conference talks.
- **1** newsletter with a substantive section: **Latest Strikes Week 21, 2026** (Fanis
  Michalakis, May 27, 2026) — "CLINK In Zeus."
- **1** independent press recap: **bitcoinnews.com** PlebLab Mérida Startup Day Yucatán
  2025 recap (Oct 22, 2025) — single-sentence acknowledgement of the demo.
- **1** developer-conference demo (community event, not a major Bitcoin conference):
  **PlebLab Mérida 2025** — Justin Shocknet demoing ShockWallet + Lightning.Pub
  featuring CLINK (Oct 19, 2025 announcement on Stacker News).
- **2** podcast appearances by Justin Shocknet, neither focused on CLINK:
  - Thriller Bitcoin "Lightning talk with Justin Shocknet" (Feb 9, 2024) — predates the
    CLINK brand; covers ShockWallet, Lightning.Pub, Lightning.Video, Nostr generally.
  - Rugpull Radio Ep. 146 with GMoney (Feb 20, 2026) — political/philosophical L2
    framing; CLINK not named in title or visible description.
- **1** YouTube discussion ("BOLT12 Onion Messages vs. CLINK Nostr Offers") hosted by
  @fanis (Fanis Michalakis) where Justin "chimed in"; surfaced via Stacker News post,
  July 8, 2025. The exact YouTube URL was not recovered in this sweep, but the
  conversation is corroborated by Justin and Fanis on Stacker News.
- **6+** Stacker News posts where CLINK was discussed substantively (community
  channel, not press).

Net: CLINK is essentially absent from the canonical Bitcoin tech-press circuit
(Optech / Citadel Dispatch / SLP / WBD / Bitcoin Magazine). Coverage that does exist
clusters in (a) Fanis Michalakis's *Latest Strikes* Lightning newsletter, (b) the
PlebLab Bitcoin-builder community in Mérida, and (c) Stacker News. This pattern is
consistent with a developer-led protocol that is being adopted by other devs (notably
Evan Kaloudis / Zeus) before tech-journalist coverage catches up.

---

## Per-venue findings

### Bitcoin Optech newsletter — NULL

- Source checked: bitcoinops.org (newsletter archive, podcast page, topic index of
  157 topics).
- Site-restricted searches via Mojeek for `site:bitcoinops.org CLINK`,
  `site:bitcoinops.org shocknet`, and `noffer optech` returned zero matches.
- Optech does index "Onion messages," "LNURL," and "Offers/BOLT12" but has not added
  CLINK as a topic.
- Optech podcast episode listing 2022-07 → 2026-06 has no episode mentioning CLINK,
  ShockNet, noffer, or Justin Shocknet.
- **Significance:** Optech is the de facto Bitcoin-engineer newsletter of record. Zero
  coverage means the Optech editors (Bastien Teinturier, Mike Schmidt, et al.) have
  not yet flagged CLINK as ecosystem-relevant. This is the most notable absence.

### Citadel Dispatch (Matt Odell) — NULL

- citadeldispatch.com episode listings could not be exhaustively scraped, but
  site-restricted Mojeek search `site:citadeldispatch.com shocknet OR CLINK` returned
  zero matches. Bing/Brave site-search returned no episode hits.
- **Significance:** Citadel Dispatch frequently hosts Lightning/Nostr builders
  (zaps, NWC, Cashu have been covered). No Justin Shocknet or CLINK episode found.

### Stephan Livera Podcast — NULL

- stephanlivera.com on-site search for "shocknet" returned: "It seems we can't find
  what you're looking for."
- Site-restricted Mojeek search for shocknet OR CLINK returned zero matches.
- **Significance:** SLP has covered BOLT12, LNURL, and Lightning UX extensively. No
  CLINK coverage.

### What Bitcoin Did (Peter McCormack) — NULL

- `site:whatbitcoindid.com shocknet OR CLINK` returned zero matches on Mojeek.

### Bitcoin Magazine — NULL

- Bitcoin Magazine on-site search for CLINK and shocknet returned no matching
  articles. No author has covered the protocol.

### Nostrasia (2023, 2024) — NO CONFIRMED COVERAGE

- No Nostrasia talk, playlist video, or schedule entry mentioning CLINK, ShockNet, or
  Lightning.Pub was recovered. Nostrasia 2023 predates the CLINK rebrand; Nostrasia
  2024 (if held) does not appear in indexed results.

### BTC++ conferences — NO CONFIRMED COVERAGE

- BTC++ (Lightning, Mining, Mempool, Earth editions, 2023-2026) — searches for
  shocknet / CLINK / Lightning.Pub in BTC++ contexts returned no matches.

### BTC Prague — NO CONFIRMED COVERAGE

- BTC Prague 2023, 2024, 2025 — no matches.

### Bitcoin Park (Nashville) — NO CONFIRMED COVERAGE

- Bitcoin Park hosts builder demos and recordings; no CLINK / ShockWallet / shocknet
  match found.

---

## Substantive coverage that DOES exist

### 1. Latest Strikes — Week 21 of 2026 (NEWSLETTER) — primary external write-up

- **Date:** 2026-05-27 (covers May 18-24, 2026).
- **Venue / format:** *Latest Strikes* — weekly Lightning-Network newsletter by
  Fanis Michalakis (developer at LN Markets), CC BY-SA 4.0. Independent of vendor
  marketing.
- **URL:** https://lateststrikes.com/s/2026-21
- **Section heading:** "CLINK In Zeus"
- **Substance — direct quote:**

  > "Evan Kaloudis is working on an integration of CLINK Nostr-native offers into
  > Zeus. Proposed by Justin (shocknet), CLINK is an alternative to LNURL or Bolt12
  > when it comes to coordinating Lightning payments."

  Newsletter further explains that CLINK uses static `noffer1...` payment codes
  communicated over "encrypted Nostr direct messages" rather than web servers, DNS,
  or onion messages, leveraging Nostr relays for transport and npubs for identity.
- **Why this matters:** This is the first time CLINK has been described in a
  Lightning-Network-engineer-facing publication that is *not* operated by ShockNet.
  The framing is neutral-positive and credits Zeus (Kaloudis) as the implementing
  party. It explicitly contrasts CLINK with BOLT12 and LNURL, validating that
  outside engineers see it as a peer to those protocols, not a niche add-on.

### 2. bitcoinnews.com — PlebLab Mérida recap (PRESS, single-sentence)

- **Date:** 2025-10-22.
- **Title:** "Builders Converge in Mérida Startup Day Yucatán 2025 Recap."
- **URL:** https://bitcoinnews.com/p/pleblab-merida-bitcoin-startup-day
- **Author:** Bitcoin News editorial.
- **Substance — direct quote:**

  > "Shockwallet introduced CLINK, a Nostr-native standard for secure, self-custodial
  > Lightning interactions with no web servers."

- **Note:** Single-sentence mention in a multi-project recap. Validates that CLINK
  was publicly demoed on stage at PlebLab Mérida and that the press present
  understood the pitch: "Nostr-native, self-custodial, no web servers."

### 3. PlebLab Mérida Bitcoin Startup Day Yucatán 2025 (CONFERENCE DEMO)

- **Date:** Mid-October 2025; recapped on Stacker News 2025-10-19 by
  @justin_shocknet ("My demo from PlebLab Mexico: ShockWallet and Lightning.Pub
  featuring CLINK," 4,210 sats, 70 comments).
- **URL:** https://stacker.news/items/1259711
- **Format:** Live demo at a Bitcoin builder convening (PlebLab is a Bitcoin
  developer cohort/space, not a major conference like Bitcoin Prague or BTC++).
- **Substance:** Demoed ShockWallet + Lightning.Pub with CLINK noffer/ndebit flows.
  Specifics of the live talk are not captured in the SN post body (paywall/length),
  but the bitcoinnews.com recap (above) confirms the message delivered.
- **Why this matters:** This is the only known *live in-person presentation* of
  CLINK as of the sweep date, and it was at a community builder event in Mexico,
  not a marquee conference. This explains why mainstream Bitcoin-press circuits
  have not picked it up.

### 4. "BOLT12 Onion Messages vs. CLINK Nostr Offers" — YouTube discussion w/ @fanis

- **Date:** 2025-07-08 (Stacker News post date).
- **Format:** YouTube discussion where Fanis Michalakis (developer at LN Markets,
  author of *Latest Strikes*) "invited [Justin] to talk about CLINK for a bit, our
  nostr-based protocol to address the shortcomings of things like LNURL and BOLT12."
- **URL referencing it:** https://stacker.news/items/1028926 (1,054 sats, 99 % zap
  forwarded to @fanis).
- **Substance — direct quote from Justin's SN post:**

  > "@fanis invited me to talk about CLINK for a bit, our nostr-based protocol to
  > address the shortcomings of things like LNURL and BOLT12."

- **Note:** The exact YouTube URL was not recovered in this sweep — Fanis's channel
  appears to be small enough that the video does not surface in indexed search
  results. However, the existence of the discussion is corroborated by both Justin
  (post author) and Fanis (commenting on the same SN thread).
- **Why this matters:** Fanis Michalakis later wrote the May 2026 *Latest Strikes*
  CLINK piece. Plausibly this 2025 YouTube exchange is what put CLINK on his radar.

### 5. Thriller Bitcoin — "Lightning talk with Justin Shocknet" (PODCAST)

- **Date:** 2024-02-09.
- **Host:** "Car" (Thriller Bitcoin, Austin Bitcoin zine).
- **Guest:** Justin Shocknet.
- **URL:** https://www.thrillerbitcoin.com/lightning-talk-with-justin-shocknet/
- **Substance:** Predates the CLINK *brand*. Covers ShockWallet self-custody,
  Lightning.Pub node middleware, Lightning.Video, Nostr integration, and Justin's
  "no-regret approach to committing to Lightning" amid scaling debates. Direct
  quotes from the writeup:

  > "pioneering infrastructure for lightning nodes, which empowers users with
  > self-custody, fostering a more equitable ecosystem"

  > "Lightning Video and the integration of Nostr, exploring the potential of PoW"

- **Why this matters:** This is the only known Bitcoin-podcast appearance by Justin
  *as a guest*, and it predates CLINK by ~18 months. The intellectual through-line
  (Lightning + Nostr + self-custody, no servers) is consistent with what CLINK later
  formalized.

### 6. Rugpull Radio Ep. 146 — GMoney + Justin Shocknet (PODCAST)

- **Date:** 2026-02-20.
- **Host:** GMoney (Badlands Media / Rugpull Radio).
- **Guest:** Justin Shocknet.
- **URLs:**
  - https://www.podbean.com/media/share/pb-ppwk5-1a4f028
  - https://www.listennotes.com/podcasts/badlands-media/rugpull-radio-ep146-special-1CSAjG8Hn_D/
- **Episode title:** "Rugpull Radio Ep.146: Special Guest Justin Shocknet — Satoshi's
  True Vision: L2's like Lightning as Peer-to-Peer Electronic Cash + the
  COunterINsurgency connection!"
- **Substance:** Frames Lightning as fulfilling Satoshi's P2P-cash vision via
  scalability and microtransactions. Description does NOT name CLINK / ShockWallet /
  Lightning.Pub / noffer in the visible promo text. The episode is more political /
  philosophical than technical.
- **Why this matters:** Confirms Justin is doing podcast outreach in 2026 (not
  hiding from the press), but the venue is Badlands Media — a politics-leaning
  Bitcoin-adjacent show, not a Bitcoin technical podcast. Reach into the
  Optech/SLP/WBD audience is therefore minimal.

### 7. Bitcoin Boomer (Gary Leland) — interview (PODCAST)

- **URL:** https://www.youtube.com/watch?v=oxRX24kQirg
- **Host:** Gary Leland ("The Bitcoin Boomer").
- **Guest:** Justin (Shocknet, ShockWallet, Lightning.Video).
- **Snippet from Brave search index:** "Gary Leland talks to Justin, Founder of
  Shocknet, Shockwallet, & Lightning Video about bitcoin market volatility."
- **Note:** YouTube page metadata could not be extracted in this sweep; date and
  full description unknown. Topic per snippet is market volatility, not CLINK
  specifically.

### 8. "Are Spark and Ark Real Bitcoin L2s?" — YouTube (TALK)

- **URL:** https://www.youtube.com/watch?v=0dFQb3uN89U
- **Snippet from Brave index:** "Justin shares his view that projects like Spark
  and Ark present themselves as Bitcoin Layer 2 solutions while relying on trusted,
  centralized [systems]."
- **Note:** Topic is Spark/Ark critique, not CLINK. Date/channel not recovered.

### 9. Medium / Fulgur Ventures — "Shocknet — a shock to video monetization" (BLOG)

- **Date:** 2023-06-23.
- **Author / interviewer:** Michele Anastasio, Fulgur Ventures.
- **URL:** https://medium.com/@fulgur.ventures/shocknet-a-shock-to-video-monetization-models-and-more-cdba1c875161
- **Substance:** Profile of the broader Shocknet thesis: Lightning-driven video
  micropayments, Lightning.Pub described as "our node middleware, which uses nostr
  to connect WebApps to nodes." CLINK / noffer not named (predates the brand).
- **Quote:**

  > "Lightning gives us a new heuristic in discovering high-signal content too,
  > value-linked engagements are a private vote on whether something is worth the
  > time to watch it."

### 10. Stacker News — community discussion (NOT PRESS, but high-substance)

Top SN posts about CLINK (sats / comments where known):

- 1,054 sats — "BOLT12 Onion Messages vs. CLINK Nostr Offers" by @justin_shocknet
  (2025-07-08).
- 4,210 sats / 70 comments — "My demo from PlebLab Mexico: ShockWallet and
  Lightning.Pub featuring CLINK" by @justin_shocknet (2025-10-19).
- 520 sats / 8 comments — "CLINK - 𝚗𝚘𝚏𝚏𝚎𝚛 & 𝚗𝚍𝚎𝚋𝚒𝚝 as Nostr-Native Lightning
  Interactions" by @supratic (2025-06-29).
- 413 sats / 10 comments — "Implementing CLINK Static Offers" by
  @thebullishbitcoiner (2025-11-28) — third-party developer integrating CLINK,
  Justin responds with SDK fixes.
- "Zeus experimenting with CLINK offers" by @Scoresby (2026-05-18) — ahead of the
  *Latest Strikes* writeup, citing @evankaloudis directly.
- "First real Nostr Zap via CLINK noffer between Zeus and ShockWallet" by
  @justin_shocknet (2026-06-01, 3,649 sats).

### 11. NPM / GitHub indirect "press" (developer surface)

- @shocknet/clink-sdk on npm (v1.5.5, 2026-06-01) — "A TypeScript/JavaScript SDK
  enabling developers to work with Nostr-native static Lightning payment offers and
  debits."
- LinkedIn post by William K. Santiago (ShockNet engineer): "The Common Lightning
  Interface for Nostr Keys (CLINK) enables lightning-related communication over the
  Nostr protocol."

---

## Why this matters

1. **Optech absence is a real signal.** Optech editors track LNURL, BOLT12, Onion
   Messages, and Lightning Address developments closely. CLINK has been live with a
   public spec since mid-2025 and demoed at PlebLab in Oct 2025; it has now been
   integrated by Zeus (May 2026). For Optech to remain silent in June 2026 means
   either (a) the Optech editors have not yet judged the protocol significant, or
   (b) ShockNet has not engaged the LN-engineer mailing-list / dev-call circuit
   where Optech sources its briefs. Either way, this is the single largest legitimacy
   gap.

2. **The one substantive newsletter mention came via the Zeus integration**, not via
   ShockNet outreach. The framing in *Latest Strikes* is "Evan is integrating Justin's
   thing." Adoption-driven, not announcement-driven, coverage — which is healthier
   for protocol legitimacy but slower than a Bitcoin-Magazine launch piece would be.

3. **No marquee conference talk**. PlebLab Mérida is a builder-cohort event, not a
   stage equivalent to BTC++ Lightning, BTC Prague, or Nostrasia. For a protocol
   pitching itself as a peer/successor to BOLT12 and LNURL, the absence of a 30-min
   BTC++ Lightning talk by Justin (or Evan, post-integration) is notable. A BTC++
   Lightning talk would likely be the single most legitimacy-elevating event possible.

4. **Justin's podcast footprint is non-technical.** His 2026 podcast appearance was
   on Rugpull Radio (politics/philosophy) rather than SLP/CD/WBD. The 2024 Thriller
   Bitcoin episode predates CLINK. A targeted SLP or Citadel Dispatch booking around
   the Zeus integration would be the highest-leverage PR move available.

5. **Stacker News is doing the heavy lifting.** Substance of the public CLINK
   conversation lives there — multiple dev-on-dev exchanges, Justin actively
   responding to integrators. This is consistent with the *kind* of protocol CLINK
   is (developer-facing primitive) and the *kind* of community ShockNet is part of
   (Stacker News-native, builder-led). It also means the project's reputation
   travels primarily through Nostr/Stacker News word-of-mouth rather than
   journalist-curated channels.

## Sources consulted (URLs)

- https://bitcoinops.org/en/newsletters/
- https://bitcoinops.org/en/podcast/
- https://bitcoinops.org/en/topics/
- https://lateststrikes.com/
- https://lateststrikes.com/s/2026-21
- https://lateststrikes.com/s/2026-22
- https://stephanlivera.com/?s=shocknet
- https://citadeldispatch.com/
- https://bitcoinmagazine.com/?s=CLINK
- https://bitcoinmagazine.com/?s=shocknet
- https://bitcoinnews.com/p/pleblab-merida-bitcoin-startup-day
- https://www.thrillerbitcoin.com/lightning-talk-with-justin-shocknet/
- https://www.podbean.com/media/share/pb-ppwk5-1a4f028
- https://www.listennotes.com/podcasts/badlands-media/rugpull-radio-ep146-special-1CSAjG8Hn_D/
- https://medium.com/@fulgur.ventures/shocknet-a-shock-to-video-monetization-models-and-more-cdba1c875161
- https://stacker.news/items/1018586
- https://stacker.news/items/1028926
- https://stacker.news/items/1248472
- https://stacker.news/items/1259711
- https://stacker.news/items/1295128
- https://stacker.news/items/1492370
- https://stacker.news/items/1500651
- https://stacker.news/justin_shocknet
- https://stacker.news/fanis
- https://www.youtube.com/watch?v=0dFQb3uN89U
- https://www.youtube.com/watch?v=oxRX24kQirg
- https://www.npmjs.com/package/@shocknet/clink-sdk

## Methodology notes / caveats

- WebSearch was unavailable; sweep relied on WebFetch against Bing, Brave (rate-
  limited), Mojeek, DuckDuckGo HTML (frequently CAPTCHA-blocked), and direct site
  fetches.
- YouTube video metadata could not be extracted via WebFetch (page returned only
  footer markup). Channel-level enumeration (e.g., the Fanis YouTube channel) was
  therefore unsuccessful; references to YouTube videos here come from search-engine
  indices and Stacker News cross-links rather than direct YouTube scrapes.
- For three pages (the Spark/Ark YouTube video, the Bitcoin Boomer interview, and
  Fanis's BOLT12-vs-CLINK YouTube discussion) we have indexed snippets confirming
  existence but no recovered upload date or full description. These items are
  reported as "exists, details partial."
- "Null" findings for Optech / Citadel Dispatch / SLP / WBD / Bitcoin Magazine /
  Nostrasia / BTC++ / BTC Prague / Bitcoin Park were each verified by at least one
  site-restricted query OR an on-site search; in some cases both. The probability of
  a missed substantive mention is non-zero but low.
