---
title: "FinCEN FIN-2019-G001 §5.4 / §4.5.1 + Treasury Decision 10000 — the regulatory posture on pool attribution"
source: https://www.fincen.gov/sites/default/files/2019-05/FinCEN%20Guidance%20CVC%20FINAL%20508.pdf
supporting_sources:
  - https://www.federalregister.gov/documents/2024/07/09/2024-14004/
  - https://home.treasury.gov/news/press-releases/jy0731
  - https://www.eff.org/deeplinks/2014/04/warrant-canary-faq
type: notes
ingested: 2026-07-29
quality: 5
credibility: high
confidence: high
tags: [fincen, money-transmitter, td-10000, broker-reporting, ofac, custody, non-custodial, lavabit, compulsion, warrant-canary, regulatory, primary]
summary: "Regulatory primary text bearing on \"can a pool decline to retain miner attribution?\" The headline finding is a coupling: **the payout schemes that most need attribution are the same schemes that are money transmitters**, and custody plus blinding are individually survivable but jointly fatal."
---

# Regulatory posture on pool attribution — FinCEN, Treasury, OFAC, compulsion

Regulatory primary text bearing on "can a pool decline to retain miner attribution?" The
headline finding is a coupling: **the payout schemes that most need attribution are the same
schemes that are money transmitters**, and custody plus blinding are individually survivable
but jointly fatal.

## FinCEN FIN-2019-G001 §5.4 — mining pools addressed by name

The single most load-bearing regulatory fact. Verbatim:

> "When the leader of the pool, the cloud miner, or the unincorporated organization or
> software agency … transfer CVC to the pool members … this distribution **does not qualify as
> money transmission** under the BSA, as these transfers are **integral to the provision of
> services** (the authentication of blocks of transactions through the combined efforts of a
> group of providers…)."

**But the exemption is conditioned on non-custody:**

> "However, if the leader … combine their managing and renting services with the service of
> **hosting CVC wallets** on behalf of the pool members … [they] will fall under FinCEN's
> definition of money transmitter for engaging in **account-based money transmission**."

A pool that buffers balances — i.e. every FPPS/PPS pool with an internal ledger and a minimum
payout threshold — is a money transmitter. A coinbase-direct pool is not.

**§4.2 four-factor control test** ((a) who owns the value, (b) where stored, (c) whether the
owner interacts directly with the payment system, (d) whether the intermediary has "total
independent control") is technology-neutral: "The regulatory interpretation … is not
technology-dependent." §4.2.2 confirms direction of travel — an entity that co-signs but
lacks "total independent control" is not a transmitter, "regardless of the label the person
applies to itself or its activities." **Labels don't help; architecture does.**

## FinCEN §4.5.1(a) — the counter-blade against marketing blindness

An **"anonymizing services provider"** who accepts value and retransmits it "in a way designed
to mask the identity of the transmittor" **is** a money transmitter and is **expressly
ineligible for the integral exemption**. FinCEN's reasoning (citing FIN-2008-R007) is that
privacy protection is not an activity separate from transmission: "the need to protect the
consumers' personal and financial information only arose in connection with the transmission
of funds."

**§4.5.1(b) Travel Rule landmine**: institutions replacing a transmittor's identity "with a
pseudonym or reference that may not be decoded by the receiving financial institution … are
**not complying** with their obligations under the Funds Travel Rule." If a blind pool is ever
deemed a transmitter, its blinding is *per se* a Travel Rule violation, not a neutral design
choice.

## Treasury Decision 10000 (89 FR, July 9 2024) — the validator carve-out

Final §1.6045-1(b)(2)(ix), verbatim: a person "**solely engaged in the business of validating
distributed ledger transactions, through proof-of-work, proof-of-stake, or any other similar
consensus mechanism, without providing other functions or services**" is **not a broker**.
Preamble confirms intent, and Treasury "retain[ed] the examples in final §1.6045-1(b)(2)(ix)
and (x)" specifically so this conclusion would stand.

**Negative result worth flagging**: the phrase "mining pool" appears **zero times** in all 365
pages. The carve-out is for *validation*, and the load-bearing qualifier is "**without
providing other functions or services**."

**Live risk**: Treasury expressly declined to finalize non-custodial rules — "the proposed new
digital asset middleman rules that apply to non-custodial industry participants are **not
being finalized** with these final regulations" — and stated intent to "expeditiously issue
separate final regulations." Non-custodial status is unfinished business, not settled law.
(The separate DeFi front-end rule, TD 10021, was repealed by CRA in 2025; that repeal removed
a *broker* rule, it did not enact any *protection* for non-custodial actors.)

The preamble records industry's own admission that non-custodial participants "have not
collected customer information under AML programs, and therefore do not have systems in place
to comply" — the absence of KYC infrastructure was argued to Treasury as grounds for
exclusion, and Treasury partly accepted it.

## OFAC — mining is in scope, but the theory used was sectoral

April 20 2022, BitRiver AG (Swiss holding co.) + 10 Russian subsidiaries designated under
E.O. 14024. Treasury's own subtitle: "**This is the first time Treasury has designated a
virtual currency mining company.**" Rationale: "By operating vast server farms that sell
virtual currency mining capacity internationally, these companies help Russia monetize its
natural resources … mining companies **rely on imported computer equipment and fiat payments,
which makes them vulnerable to sanctions**."

OFAC has no scienter requirement, so paying an SDN-controlled address is a violation
regardless of knowledge, and blinding is arguably willful blindness rather than a defense.
**However: no OFAC guidance requiring mining pools to screen participant payout addresses was
found**, and the BitRiver theory was corporate/sectoral rather than transactional. This is the
largest genuinely open legal exposure, and the one with least authority in either direction.

## The dust → accrual → custody → money-transmitter chain

The most underrated objection, and it is a coupling of sources rather than a claim in any one
of them. Ocean's own TIDES doc concedes that satoshi-precision rewards produce uneconomic dust
and that pools therefore accrue "until the sum exceeds a minimum threshold." **Accrual to a
threshold is a hosted balance** — precisely the §5.4 trigger. So the exemption erodes for
exactly the small miners a blind pool most wants to serve, and coinbase output-count/block-
weight limits bound how many miners can be paid directly per block.

## Compulsion — hard blocker on the promise, not on the architecture

**Lavabit** is dispositive as to promises. The government obtained a warrant for Lavabit's TLS
private keys, which "would allow the government to access communications by all 400,000
customers." Levison offered to write targeted code instead; **the court rejected it.** Fine of
$5,000/day; shutdown Aug 8 2013; contempt April 2014 for producing keys in 4-point type.

**EFF Warrant Canary FAQ** on whether canaries have been tested: "**Not yet.** EFF believes
that warrant canaries are legal, and the government should not be able to compel a lie."
Belief, not holding — no case has upheld one. EFF advises a provider whose canary triggers to
"obtain legal counsel and go to a court" rather than rely on self-execution.

Therefore: **no forward-looking blindness claim is durable.** What *is* durable is (a) not
having historical data to produce — data never collected cannot be compelled retroactively —
and (b) client-verifiable behavior. **The claim must be scoped to the past tense.**

## Explicit gaps in this ingest

- **EU TFR (Reg. 2023/1113) text could not be retrieved** — EUR-Lex returned HTTP 202 on four
  URL forms. MiCA/TFR treatment is **unverified** and should not be relied on from this note.
- **Samourai Wallet / 18 U.S.C. §1960 non-custodial enforcement theory: not retrieved** (DOJ
  URLs 403/404, search engines rate-limited). This matters because DOJ's §1960 theory is in
  tension with FinCEN's §4.2.2 and §4.5.1(b) positions — DOJ has charged non-custodial
  operators that FinCEN guidance appears to exempt. **The single most important remaining
  gap**, since it is the mechanism by which the favorable §5.4 analysis could be bypassed by a
  criminal rather than regulatory theory.
- FinCEN has never addressed a *blinded* pool. The inference that coinbase-direct payment
  escapes §4.5.1(a) because the pool never "accepts" value follows from §4.2's four factors
  but is **inference, not a FinCEN holding**.
