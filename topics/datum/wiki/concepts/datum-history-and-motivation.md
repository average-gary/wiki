---
title: "DATUM — history and motivation"
category: concept
sources:
  - raw/articles/2026-05-28-ocean-origins-of-datum.md
  - raw/articles/2026-05-28-ocean-alternate-templates.md
  - raw/articles/2026-05-28-ocean-docs-index.md
created: 2026-05-28
updated: 2026-05-28
tags: [datum, ocean, mining-decentralization, eligius, slush, jason-hughes, history, censorship-resistance]
aliases: ["Origins of DATUM", "DATUM motivation", "DATUM acronym"]
confidence: high
volatility: cold
verified: 2026-05-28
summary: "Jason Hughes' framing of DATUM as the first fully decentralized mining protocol since Eligius closed in 2017. Acronym backronym, the pool-template-centralization thesis, and the OCEAN-side incentive structure (50% fee discount + non-custodial coinbase payouts) that make it economically rational for miners to opt in."
---

# DATUM — history and motivation

> The technical articles in this wiki cover *what* DATUM does. This article covers *why it exists* and *what it's trying to undo* — synthesized from Jason Hughes' "Origins of DATUM" essay and the now-decommissioned "Alternate Templates" page that preceded it. Useful as the context an operator wants once before reading the rest of the wiki.

## What DATUM stands for

> **D**ecentralized **A**lternative **T**emplates for **U**niversal **M**ining.

The "Alternative" word does work: it's positioned against pool-supplied templates, which is the historical default in Stratum v1 mining.

## The thesis

Hughes' essay frames the problem in terms of a historical drift, not an immediate crisis:

| Era | Who builds the template? |
|---|---|
| Bitcoin's earliest days | The miner — node and hashing were the same machine |
| Slush, Eligius, and successor pools | The pool — miner just hashes |
| Today | The pool, with very few exceptions |

The framing is that miners became *"mere sellers of hash power"* — the ledger-keeping role separated from the work-doing role. Hughes' specific concern is censorship: if a small number of pools control >51% of hashrate and choose templates, *they* choose which transactions get into the next block. The chain remains technically decentralized; transaction selection has become centralized in the pool layer.

This is the same problem [[datum-protocol|DATUM Protocol]] ([DATUM Protocol](datum-protocol.md)) is engineered to solve. The protocol's defining negative property — *no template flows from pool to miner* — is the architectural answer to "the pool decides what goes in the block."

## Eligius as the historical anchor

Hughes positions DATUM as *"the first fully decentralized mining protocol since Eligius closed in 2017."* Eligius was Luke Dashjr's pool; it ran a model that gave miners more control over template construction than Slush-style pools did. When it shut down, that model effectively disappeared from public Bitcoin mining infrastructure for ~7 years until DATUM revived it.

(Note that Hughes co-leads OCEAN with Luke Dashjr, who is named in the DATUM Setup Guide as a support contact (`@LukeDashjr`). The Eligius lineage isn't accidental.)

## Two-component architecture, restated

The essay collapses DATUM's miner-side surface to two pieces:

1. **DATUM Gateway** — speaks Stratum to mining hardware on one side, DATUM Protocol to the pool on the other.
2. **Bitcoin full node** — peers with the network, builds templates via [[gateway-data-flow|GBT]] ([Gateway data flow](gateway-data-flow.md)), broadcasts found blocks.

Everything else this wiki documents — username modifiers, the four node-policy variants, blocknotify mechanics — is plumbing around those two components.

## OCEAN-side incentives

The essay names two incentives that move DATUM from "ideologically appealing" to "economically rational" for OCEAN miners specifically:

- **50% pool-fee discount** for DATUM users (vs miners on the legacy non-DATUM endpoints).
- **Non-custodial coinbase payouts** — rewards land directly in the generation transaction via [[tides-payout|TIDES]] ([TIDES payout](tides-payout.md)) without OCEAN ever holding miner funds.

Combined, these mean a DATUM miner pays half the fee *and* removes pool-custody risk. That's a meaningful change in the operator economics of Bitcoin mining.

## The pre-DATUM lineage at OCEAN

Before DATUM was operational, OCEAN ran a menu of four "alternate template" stratum endpoints — miners could opt into a different template policy by connecting to a different stratum URL. The menu was: OCEAN Recommended, Core+Antispam, Core, and Data-Free.

Those endpoints were **decommissioned on December 21, 2025**. The four template policies still exist as documentation, captured here in [[node-policy-variants|Node policy variants]] ([Node policy variants](../references/node-policy-variants.md)) — they're now reference material for DATUM Gateway operators who want to reproduce one of the legacy templates against their own node.

The decommission is the cleanest historical marker for "DATUM is the way forward" at OCEAN: there's no longer a pool-built alternative.

## What this article is *not* claiming

A few honesty notes on the source:

- The "first fully decentralized mining protocol since Eligius (2017)" claim is OCEAN's framing. P2Pool and successors (e.g. p2poolv2) and Stratum V2's Job Declaration Protocol are also miner-controls-template designs and were active during this window. DATUM is distinct in its protocol mechanics, but "first since Eligius" should be read as a marketing-flavored claim, not an academic one.
- The 50% fee discount is OCEAN-specific, not DATUM-protocol-specific. Other DATUM-supporting pools (if/when they exist) can set their fees however they like.
- Hughes' essay frames censorship as an existing problem at *"a dangerous peak."* Whether that framing matches your read of the current Bitcoin mining-pool landscape is a judgment call; this wiki notes it without endorsing it.

## See Also

- [[datum-gateway-overview|DATUM Gateway — overview]] ([DATUM Gateway — overview](../topics/datum-gateway-overview.md)) — what's described historically here, in technical detail
- [[datum-protocol|DATUM Protocol]] ([DATUM Protocol](datum-protocol.md)) — the wire-level expression of the thesis
- [[tides-payout|TIDES payout]] ([TIDES payout](tides-payout.md)) — the non-custodial payout mechanism mentioned as an OCEAN incentive
- [[node-policy-variants|Node policy variants]] ([Node policy variants](../references/node-policy-variants.md)) — the four legacy templates that DATUM made obsolete
- [[lightning-payouts|Lightning payouts]] ([Lightning payouts](lightning-payouts.md)) — alternative payout rail named on the OCEAN side; not part of DATUM's core incentive set

## Sources

- [The Origins of DATUM](../../raw/articles/2026-05-28-ocean-origins-of-datum.md) — Jason Hughes' framing essay
- [Alternate Templates](../../raw/articles/2026-05-28-ocean-alternate-templates.md) — the December 2025 decommissioning
- [OCEAN Documentation Index](../../raw/articles/2026-05-28-ocean-docs-index.md) — publication dates of the OCEAN docs corpus
