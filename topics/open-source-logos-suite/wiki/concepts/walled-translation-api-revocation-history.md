---
title: "Walled translation API revocation history (2024-2026)"
type: concept
created: 2026-06-02
updated: 2026-06-02
verified: 2026-06-02
volatility: warm
confidence: medium
sources:
  - raw/articles/2026-06-02-esv-api-overview-terms.md
  - raw/articles/2026-06-02-esv-api-docs-portal.md
  - raw/articles/2026-06-02-crossway-statement-of-faith.md
  - raw/articles/2026-06-02-andbible-faq-esv-withdrawn.md
  - raw/articles/2026-06-02-crosswire-sword-modules.md
  - raw/articles/2026-06-02-nlt-api-tyndale.md
  - raw/articles/2026-06-02-lockman-nasb-permissions.md
  - raw/articles/2026-06-02-csbible-permissions.md
  - raw/articles/2026-06-02-api-bible-overview.md
  - raw/articles/2026-06-02-youversion-platform-developers.md
  - raw/articles/2026-06-02-olivetree-hub-api.md
---

# Walled translation API revocation history (2024-2026)

## TL;DR

The Crossway ESV API is the only widely-used self-serve walled-translation API in 2026, and its terms still contain (a) the four-doctrine conformity clause and (b) the explicit "we reserve the right to cancel your access to the service at any time for any reason" language — both alive and quotable as of 2026-06-02. We found **no public dataset of named ESV API revocation events** (developer blog posts, news stories, GitHub issues), but we *did* find a documented withdrawal-of-distribution event affecting OSS Bible apps: **Crossway pulled ESV from the CrossWire SWORD platform**, which is what AndBible's FAQ now confirms. The other major translations (NIV, NASB, NLT, CSB) are even more closed — most have no self-serve developer API at all; access is by direct negotiation. The BYO-API-plugin posture in `christ-is-lord` ADR-0000 §6 remains the only sane stance in 2026-06.

## Evidence

### ESV API — terms verbatim, still in force

The current Crossway ESV API terms ([[../../raw/articles/2026-06-02-esv-api-overview-terms.md|esv.org/api]]) include verbatim:

- **Doctrinal-conformity clause**: the service is available only to those using it "in ways consistent with the historic Christian understanding of doctrine," including affirmation that the Bible is God's inspired, inerrant Word; the Trinity; Christ's deity, death, and resurrection; and salvation through grace in Christ alone. The four doctrines align point-for-point with Crossway's full 10-point [[../../raw/articles/2026-06-02-crossway-statement-of-faith.md|Statement of Faith]] (inspiration & inerrancy, Trinity, Christ's deity/atonement/resurrection, grace-alone soteriology).
- **Revocation clause**: "We reserve the right to cancel your access to the service at any time for any reason" — and access keys "may be revoked" if a developer fails to abide by the terms.
- **Cache cap**: cannot locally cache more than 500 verses or half of any book.
- **Rate limits**: 5,000 queries/day, 1,000/hour, 60/minute.
- **Non-commercial only**: no fees, no advertising, no sponsorships at the free tier.

The ESV [[../../raw/articles/2026-06-02-esv-api-docs-portal.md|docs portal]] is unchanged in surface area — same four endpoints, same Authorization-header auth — but does not duplicate the terms-of-use language; a developer reading docs alone can miss the doctrinal clause entirely.

### Public revocation history — uncertain

We searched (DuckDuckGo, GitHub issues, dev-forum-style queries) for named instances of ESV API access being revoked from a specific developer for cause, 2020-2026. **We found none.** This is not the same as "no revocations have occurred" — Crossway is a private publisher under no obligation to disclose, and developers whose keys are revoked have weak incentive to advertise being on the wrong side of a doctrinal-conformity ruling. The honest summary: the public revocation-event record is empty, but the clause is explicit and discretionary, and absence of public events does not mean absence of events.

### Crossway pulled ESV from CrossWire SWORD — documented

[[../../raw/articles/2026-06-02-andbible-faq-esv-withdrawn.md|AndBible's FAQ]] states verbatim: "The publishers of the ESV have unfortunately decided it is no longer in their interest to publish towards the SWORD platform (by Crosswire Bible Society) which AndBible uses." No date is given. The [[../../raw/articles/2026-06-02-crosswire-sword-modules.md|CrossWire module catalog]] confirms: ESV is not in the current public-distribution list (the modern English options are BSB, ISV, LEB, GOD'S WORD, WEB, NHEB and variants). This is the most concrete walled-translation withdrawal event we have evidence of in 2024-2026 — a pre-existing distribution channel was closed, affecting downstream OSS apps including AndBible, Xiphos, BibleTime, and PocketSword.

### Other walled translations — even less developer-accessible

- **NIV (Biblica/Zondervan)**: no self-serve developer API. Access is via [[../../raw/articles/2026-06-02-youversion-platform-developers.md|YouVersion partner program]] (partner-gated, application-required) or [[../../raw/articles/2026-06-02-api-bible-overview.md|api.bible unique-license]] (case-by-case).
- **NASB (Lockman Foundation)**: [[../../raw/articles/2026-06-02-lockman-nasb-permissions.md|permissions page]] documents quote allowances (up to 1,000 verses, no full book, ≤50% of host work) and a 2024-2026 AI-usage clause, but no self-serve API. One developer report: Lockman grants discretionary keys (e.g., to ABS, and to one individual API operator).
- **NLT (Tyndale House)**: [[../../raw/articles/2026-06-02-nlt-api-tyndale.md|api.nlt.to]] still live. Anonymous tier (50 verses/req, 500 req/day) and key tier (500 verses/req, 5,000 req/day). Non-commercial only. No explicit "any reason" revocation clause and no doctrinal-conformity clause comparable to Crossway's, but Tyndale-purpose alignment language exists.
- **CSB (Holman/B&H)**: [[../../raw/articles/2026-06-02-csbible-permissions.md|csbible.com permissions]] page has no API or developer language. Access is by direct Holman negotiation; CSB on api.bible is unique-license-gated.
- **YouVersion / OliveTree**: dominant retail mobile Bible apps. [[../../raw/articles/2026-06-02-youversion-platform-developers.md|YouVersion]] is partner-gated; [[../../raw/articles/2026-06-02-olivetree-hub-api.md|OliveTree]] offers only a deep-link URL scheme + a partner content Hub API, never a scripture-fetch surface for general developers.

### How OSS Bible apps handle this in 2026

CrossWire's SWORD project is the OSS backend powering AndBible, Xiphos, BibleTime, PocketSword, and others. Its current modern-English module list confirms: no ESV, no NIV, no NASB, no NLT, no CSB. AndBible's FAQ also clarifies the apps's licensing model — every shipped document is "either in the public domain or licensed for distribution" via Crosswire / IBT Russia / eBible / STEPBible / AndBible itself. **e-Sword and Bibledit:** we were unable to fetch primary sources for these in this pass (search results blocked by CAPTCHA on every attempt), so we cannot make a 2026-06-02 verbatim claim about either; the pattern across all SWORD-downstream and SWORD-adjacent OSS apps appears to be the same — they don't ship walled modern English translations at all.

## Implications for christ-is-lord

- **The doctrinal clause is alive and explicit.** ADR-0000 §6 and `biblical-data-licensing.md` were correct as of v1.0.0 ship: the ESV API still requires the four-doctrine affirmation and still grants revocation at Crossway's sole discretion. The 2026-06-02 ESV API terms quoted above are the current verbatim text — drop them into the README rationale.

- **The public revocation history is uncertain, not "clean."** Do not write copy that says "Crossway has never revoked an API key" — we could not verify that. Write copy that says "Crossway can revoke at any time, for any reason, in their sole judgment, and there is no public registry of past revocation events." The withdrawal of ESV from CrossWire SWORD distribution is a documented adjacent event that supports the cautious posture.

- **BYO-API plugin is still the right posture in 2026-06.** The market has not opened up — if anything, it has tightened (NIV via partner-only YouVersion, CSB with no API at all, NASB by direct-negotiation only, ESV-from-SWORD withdrawn). `plugins/esv-api/` is the correct shape and should remain the reference BYO plugin pattern. Same pattern should be the official answer for any future NIV/NASB/NLT/CSB plugins, with the caveat that NIV/CSB/NASB do not have self-serve key-issuance — those plugins, if built, would target the partner-tier APIs (api.bible unique-license, YouVersion partner), and christ-is-lord cannot ship them as built-ins because we can't acquire the upstream license on behalf of users either.

- **Cache-eviction must be enforced in `plugins/esv-api/` today.** The 500-verse cache cap is a binding term. Verify that the BYO ESV plugin (a) holds an LRU or FIFO cache bounded at ≤500 unique verses, (b) does not write cached verse text into the SQLite FTS5 corpus or into `~/.christ-is-lord/library/` (which would create a >500-verse persistent store across sessions), and (c) clears cache on plugin disable. If any of those is missing, the plugin is technically out of compliance with Crossway's terms even when the user holds a valid key. This is a code review item against `logos_plugins/samples/esv-api/` for the v1.0.x release.

- **User-facing copy block** (drop into the BYO ESV plugin onboarding screen, README, and docs):

  > ESV access is granted by Crossway under terms that include a doctrinal-conformity clause requiring affirmation of the Bible's inspiration and inerrancy, the Trinity, the deity/death/resurrection of Christ, and salvation by grace alone in Christ. Crossway can revoke access at any time, for any reason, in their sole judgment. christ-is-lord is not party to your agreement with Crossway. If your access is revoked, ESV passages will stop loading; your notes, highlights, and other library content are unaffected. Default open translations (BSB, WEB, LEB) will continue to work.

- **Do not assume self-serve NIV/NASB/CSB plugins will ever be possible.** If a user asks for an NIV plugin, the honest answer in 2026-06 is: there is no self-serve NIV API to plug into; the NIV is reachable only through YouVersion partnership or api.bible unique-license, and christ-is-lord cannot mint either on the user's behalf. NLT has the closest thing to ESV-like self-serve (api.nlt.to with key tier) and is the next-most-tractable BYO target if someone wanted to write a second BYO plugin.

- **Reference implementation as wiki anchor.** The `plugins/esv-api/` directory in the repo is the canonical proof-of-pattern. When future translations open up (e.g., if Crossway changes terms, or if a new translation enters self-serve), copy that directory's structure rather than re-inventing.

## Open follow-ups

- Verify `logos_plugins/samples/esv-api/` cache-cap enforcement against the 500-verse limit. If absent, file as an INV item.
- Re-check ESV API terms quarterly; volatility is "warm" because Crossway has historically changed terms with little notice (per AndBible's SWORD-withdrawal evidence).
- Investigate e-Sword and Bibledit ESV handling next pass — primary sources were blocked by CAPTCHA in this round and the question remains open.

## See Also

- [[biblical-data-licensing|Biblical Data Licensing]] — the open-data-only-at-v1 posture this article reaffirms
- [[../decisions/plugin-trust-model|Plugin Trust Model]] — the capability-manifest model the BYO ESV plugin demonstrates (`network.host:api.esv.org` + `secrets.read:esv_api_key`)
- [[../reference/open-data-corpus|Open Data Corpus]] — what christ-is-lord ships by default in the absence of self-serve walled APIs
- [[ai-bible-study-tools-2026|AI Bible-study tools 2026]] — why an AI plugin should index over open translations, not paywalled ones
- [[credible-exit|Credible Exit Principle]] — BYO API plugin architecture aligns with the credible-exit frame (license travels with user, not project)
- [[../topics/engineering-playbook|Engineering Playbook]]
