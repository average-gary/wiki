---
title: "DOJ §1960 / Samourai non-custodial enforcement theory — the bypass around FinCEN §5.4"
kind: question
status: active
priority: p1
created: 2026-07-29
updated: 2026-07-29
last_checked: 2026-07-29
next_action: "Retrieve the Samourai Wallet indictment and DOJ's 18 U.S.C. §1960 theory from a reachable source (CourtListener / RECAP / PACER — justice.gov returned 403/404), and determine whether the theory reaches a non-custodial party that never controls funds. Then reconcile against FinCEN FIN-2019-G001 §5.4 in decisions/attribution-retention-tradeoffs.md."
sources:
  - wiki/decisions/attribution-retention-tradeoffs.md
  - raw/notes/2026-07-29-fincen-td10000-regulatory-attribution-posture.md
  - output/playbook-self-blinding-pool-attribution-2026-07-29.md
tags: [regulatory, fincen, money-transmitter, section-1960, samourai, doj, non-custodial, open-question, blocked-source]
confidence: low
summary: "FinCEN FIN-2019-G001 §5.4 plausibly exempts a non-custodial coinbase-direct pool, but DOJ's §1960 theory in the Samourai prosecution is the mechanism by which that favorable read could be bypassed on a criminal rather than regulatory footing. All DOJ source URLs returned 403/404 in the source round, so the analysis is unverified."
---

# DOJ §1960 / Samourai non-custodial enforcement theory

## Why Track This

[[../../wiki/decisions/attribution-retention-tradeoffs|Attribution Retention Tradeoffs]] builds a
plausibly favorable FinCEN read: §5.4 treats pool distributions as "integral to the provision of
services," and the exemption survives as long as the operator does not also host CVC wallets.

That analysis is **entirely regulatory**. The Samourai prosecution suggests DOJ can proceed on an
18 U.S.C. §1960 unlicensed-money-transmitting-business theory that does not depend on FinCEN's
guidance agreeing. If §1960 reaches a party that never controls funds, the whole §5.4 argument is
a side door rather than a defense — which changes the *architecture*, not just the disclosure
posture, since the dust→accrual→custody chain would then need to be avoided outright rather than
merely bounded.

## Current State

**Unverified.** Every DOJ URL attempted in the 2026-07-29 round returned **403 or 404**, and
WebSearch was unavailable to all agents. The regulatory analysis in this topic is therefore
recorded at **medium-low confidence** with the gap named in-article rather than papered over.

What is established: §4.5.1(a) makes an "anonymizing services provider" a money transmitter
**expressly ineligible** for the integral exemption, and §4.5.1(b) makes decodability failures a
Travel Rule violation. Treasury's TD 10000 validator carve-out is narrower than it looks — "mining
pool" appears **zero times** in 365 pages and the qualifier is "without providing other functions
or services."

## Close-out Condition

The §1960 charging theory is retrieved from a reachable primary source and its reach over
non-custodial parties is characterized, with
[[../../wiki/decisions/attribution-retention-tradeoffs|the decision article]] updated and its
confidence either raised or explicitly held at medium-low with the reason.

## Notes

- Try CourtListener / RECAP rather than justice.gov; the indictment and any motion-to-dismiss
  ruling are the load-bearing documents.
- Adjacent unverified gap in the same article: **EU TFR (Reg. 2023/1113) and MiCA**, where
  EUR-Lex returned HTTP 202 on four URL forms. Worth closing in the same pass; not tracked
  separately because it shares the retrieval problem and the article section.
- This is also candidate thesis #6 in [[../../wiki/theses/_index|the theses index]] if it turns
  out to be worth a full verdict rather than a source retrieval.
- **Not legal advice** — the article carries the disclaimer and so does this record.
