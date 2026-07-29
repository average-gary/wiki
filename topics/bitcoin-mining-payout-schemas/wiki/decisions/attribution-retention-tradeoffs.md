---
title: Attribution Retention Tradeoffs
type: decision
created: 2026-07-29
confidence: high
tags: [attribution, retention, fincen, td-10000, money-transmitter, ofac, compulsion, warrant-canary, decision, regulatory]
volatility: warm
updated: 2026-07-29
summary: "What a pool gives up by not retaining miner attribution, per axis, and the regulatory coupling that makes custody and blinding individually survivable but jointly fatal."
verified: 2026-07-29
sources:
  - "raw/notes/2026-07-29-fincen-td10000-regulatory-attribution-posture.md"
  - "raw/papers/2026-07-29-withholding-detection-does-not-need-attribution.md"
  - "raw/papers/2026-07-29-recabarren-carbunar-hardening-stratum.md"
  - "raw/notes/2026-07-29-self-blinding-system-architectures.md"
---

# Attribution Retention Tradeoffs

A pool deciding *how little to retain* is not making one decision. It is making six, and they have
very different costs. This article separates the ones that cost something real from the ones that
only feel like they do.

## Per-axis cost of not retaining

| Axis | Cost of blinding | Verdict |
|---|---|---|
| **Block-withholding detection** | Near-zero. Eyal 2015: a pool "might not be able to detect which of its **registered** miners are the perpetrators"; a catching threshold "would reject the majority of its honest miners." APoW ranks PPLNS/score-based **Strong** vs FPPS **Very weak** — under PPLNS, withholding costs the attacker its own revenue. | **Not a real cost** under PPLNS/TIDES/SLICE. Is a real cost under PPS/FPPS. |
| **Withholding detection via payout-address clustering** | **Real and specific.** Eligius 2014 is the only production success, and it worked only because the attacker "used **two payout addresses**." Per-payout rotation removes exactly that lever. | **Genuine cost of address rotation**, distinct from attribution generally. |
| **Share-credit theft** | **Real, and the cryptographic crux.** Bedrock's mining cookie `C_M = H²(R_M, M.uname)` defeats BiteCoin hijacking *because the username is a PoW input*. Whether a blinded commitment preserves that is **unanalyzed by anyone**. | **Must be reconstructed**, not waived. |
| **Pool hopping** | Zero. PPLNS is structurally hopping-immune; score-based systems exist to catch hoppers, and PPLNS doesn't need them. | **Not a cost.** |
| **Dispute resolution / support** | Real but operational. "You owe me more than you paid me" is unanswerable without a per-miner history. Client-held receipts shift the burden to the miner. | **Capability traded for functionality** — the honest framing. |
| **Regulatory reporting** | Depends entirely on custody. See below. | **The decisive axis.** |

## The regulatory coupling

**FinCEN FIN-2019-G001 §5.4 addresses mining pools by name and is favorable — conditionally.** Pool
distributions "**do[] not qualify as money transmission** under the BSA, as these transfers are
**integral to the provision of services**." But:

> "However, if the leader … combine their managing and renting services with the service of
> **hosting CVC wallets** on behalf of the pool members … [they] will fall under FinCEN's definition
> of money transmitter for engaging in **account-based money transmission**."

**A pool that buffers balances is a money transmitter. A coinbase-direct pool is not.** §4.2's
four-factor control test is explicitly technology-neutral, and §4.2.2 adds that status holds
"regardless of the label the person applies to itself" — **labels don't help; architecture does.**

Then the counter-blade. §4.5.1(a): an **"anonymizing services provider"** who retransmits value "in
a way designed to mask the identity of the transmittor" **is** a money transmitter and is **expressly
ineligible for the integral exemption**. §4.5.1(b): institutions replacing a transmittor's identity
"with a pseudonym or reference that may not be decoded by the receiving financial institution … are
**not complying**" with the Travel Rule.

> **Custody and blinding are individually survivable and jointly fatal.** A non-custodial blind pool
> has a coherent §5.4 story. A custodial blind pool is a transmitter whose blinding is *per se* a
> Travel Rule violation.

**This is where the dust problem becomes a legal problem.** Ocean's own TIDES documentation concedes
satoshi-precision rewards produce uneconomic dust and that pools accrue "until the sum exceeds a
minimum threshold." **Accrual to a threshold is a hosted balance** — the §5.4 trigger. So the
exemption erodes for exactly the small miners a blind pool most wants to serve, and coinbase
output-count limits (~380–530, firmware-bounded) cap how many can be paid directly per block anyway.
The chain is: **dust → accrual → custody → money transmitter.** *(This coupling is an inference
across sources, not a claim made in any one of them.)*

Note the alignment: **FinCEN's custody trigger and APoW's withholding-vulnerability ranking select
the same set of pools.** PPS/FPPS are simultaneously custodial *and* withholding-vulnerable;
PPLNS coinbase-direct is neither. *(Also this wiki's inference.)*

## Treasury Decision 10000 — helpful, and narrower than it looks

Final §1.6045-1(b)(2)(ix): a person "**solely engaged in the business of validating distributed
ledger transactions, through proof-of-work, proof-of-stake, or any other similar consensus
mechanism, without providing other functions or services**" is **not a broker**.

Two cautions. **"Mining pool" appears zero times in all 365 pages** — the carve-out is for
*validation*, and the load-bearing qualifier is "without providing other functions or services."
And Treasury expressly declined to finalize the non-custodial rules: "the proposed new digital asset
middleman rules that apply to non-custodial industry participants are **not being finalized**," with
stated intent to issue separate final regulations. **Non-custodial status is unfinished business, not
settled law.** (TD 10021's CRA repeal removed a *broker* rule; it did not enact any *protection*.)

## OFAC — the largest genuinely open exposure

April 2022: BitRiver AG plus 10 Russian subsidiaries designated under E.O. 14024 — "**the first time
Treasury has designated a virtual currency mining company**." But the theory was sectoral
("mining companies rely on imported computer equipment and fiat payments, which makes them
vulnerable to sanctions"), not transactional.

OFAC has **no scienter requirement**, so paying an SDN-controlled address violates regardless of
knowledge, and blinding is arguably willful blindness rather than a defense. **However: no OFAC
guidance requiring pools to screen participant payout addresses was found.** Least authority in
either direction; largest open risk.

## Compulsion: scope the claim to the past tense

**Lavabit is dispositive as to promises.** The government obtained a warrant for the TLS private
keys, which "would allow the government to access communications by all 400,000 customers." Levison
offered to write targeted code instead; **the court rejected it.** $5,000/day, shutdown Aug 2013,
contempt April 2014.

**EFF's warrant-canary FAQ**, on whether canaries have been tested: "**Not yet.** EFF believes that
warrant canaries are legal, and the government should not be able to compel a lie." *Belief, not
holding* — and EFF advises a provider whose canary triggers to get counsel and go to court rather
than rely on self-execution.

Therefore the only durable forms of blindness are:

1. **Data never collected**, which cannot be produced retroactively.
2. **Client-verifiable behavior** — a design where starting to collect requires a client-visible,
   log-visible change that clients refuse to encrypt to (the Apple PCC pattern; see
   [[../concepts/self-blinding-architectures|Self-Blinding Architectures]]).

Note the residual: PCC's own transparency-log publication window is **within 90 days**, so detection
is *delayed*, not immediate. And **verifiable deletion is an open problem, not an available
primitive** — no deployed system gives the *user* a proof that deletion occurred. A retention policy
is therefore a promise, while non-collection is a property.

One borrowable deployment argument, from Prio: **jurisdictional diversity** — "If law enforcement
agents seize the Prio servers in one country, they cannot deanonymize the organization's Prio users."

## Decision matrix

| If you are… | Retain | Because |
|---|---|---|
| **Non-custodial PPLNS/TIDES, coinbase-direct** | Per-descriptor work volume only. No IP, no persistent name, no device fingerprint. | §5.4 exemption intact; incentive alignment covers withholding; nothing else earns its retention. |
| **Non-custodial but accruing to a payout threshold** | The above, and get counsel. | Accrual is a hosted balance; the exemption is eroding and §4.5.1(a) is pointed the other way. |
| **FPPS/PPS with an internal ledger** | Full attribution. | Already a money transmitter under §5.4; already Very weak against withholding per APoW. Blinding buys little and costs Travel Rule compliance. |
| **Any design** | Share-theft resistance, in whatever form survives blinding. | The Bedrock property is not optional and its blinded variant is unanalyzed. |

## Gaps in the regulatory picture

Flagged rather than glossed:

- **EU TFR (Reg. 2023/1113) text could not be retrieved** (EUR-Lex returned HTTP 202 on four URL
  forms). MiCA/TFR treatment is **unverified** and should not be relied on from this article.
- **DOJ's §1960 non-custodial theory (Samourai Wallet) was not retrieved** (403/404). This is the
  **single most important remaining gap**: DOJ has charged non-custodial operators that FinCEN
  guidance appears to exempt, so it is the mechanism by which the favorable §5.4 analysis could be
  bypassed by a criminal rather than regulatory theory.
- **FinCEN has never addressed a blinded pool.** The inference that coinbase-direct payment escapes
  §4.5.1(a) because the pool never "accepts" value follows from §4.2's four factors but is
  **inference, not a FinCEN holding**.
- **No source found treating legal compulsion of enclave operators rigorously.**

*Not legal advice. Primary-text reading recorded for design purposes.*

## Sources

- [[../../raw/notes/2026-07-29-fincen-td10000-regulatory-attribution-posture|FinCEN FIN-2019-G001, TD 10000, OFAC, Lavabit]]
- [[../../raw/papers/2026-07-29-withholding-detection-does-not-need-attribution|Withholding detection vs. attribution]]
- [[../../raw/papers/2026-07-29-recabarren-carbunar-hardening-stratum|Hardening Stratum — BiteCoin / Bedrock]]
- [[../../raw/notes/2026-07-29-self-blinding-system-architectures|Self-blinding system architectures]]

## See also

- [[custody-tradeoffs|Custody Tradeoffs]] — the custody axis this one couples to
- [[../topics/self-blinding-pool-design-space|Self-Blinding Pool Design Space]]
- [[../concepts/payout-attribution-privacy|Payout Attribution Privacy]]
- [[../concepts/block-withholding|Block Withholding]]
- [[../concepts/self-blinding-architectures|Self-Blinding Architectures]]
- [[../topics/payout-design-space|The Payout Design Space (synthesis)]]

