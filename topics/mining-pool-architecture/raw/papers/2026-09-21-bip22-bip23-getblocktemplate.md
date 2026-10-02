---
title: "BIP 22 & BIP 23 — getblocktemplate (Fundamentals; Pooled Mining)"
source: "https://github.com/bitcoin/bips/blob/master/bip-0022.mediawiki"
related_sources: ["https://github.com/bitcoin/bips/blob/master/bip-0023.mediawiki"]
type: papers
ingested: 2026-09-21
tags: [getblocktemplate, bip22, bip23, template-sourcing, miner-autonomy, decentralisation, submitblock, long-polling, block-proposal, coinbase-mutation, protocol-history]
summary: "The two BIPs (Luke Dashjr, assigned 2012-02-28, status Deployed) that replaced getwork with getblocktemplate. BIP22 defines the fundamentals: the node returns a full block structure — previous hash, bits, time, height, the transaction list, coinbase information — plus submitblock, long polling, and sizelimit/sigoplimit parameters, so that work generation can live outside the validating node. BIP23 adds the pooled-mining extensions whose stated purpose is to counteract mining centralisation: work expiry, custom target difficulty, block proposal for pre-validation, a defined mutation set (coinbase/append, time/increment, transactions, version switching), and submission abbreviation to cut bandwidth when the miner did not alter the supplied transactions. Two conformance levels are defined. Technically the stronger decentralisation story; lost de facto adoption to Stratum V1 six months later."
authors: [Luke Dashjr]
published: 2012-02-28
publication_status: "BIP status: Deployed. Type: Standards/Informational specification."
credibility: high
credibility_rationale: "Primary specification documents in the official BIPs repository."
confidence: high
research_round: 1
research_agent: historical
extraction_note: "Structured extraction produced by a research subagent from the live BIP texts; not a verbatim dump of either mediawiki file. Section-level mechanics are reported faithfully but field-by-field detail (exact JSON key names, full mutation strings, level-2 requirements) was NOT captured and must be read from the BIPs directly before implementation work."
---

# BIP 22 & BIP 23 — getblocktemplate

**Luke Dashjr** (`luke+bip22@dashjr.org`) — assigned **2012-02-28** — status **Deployed**

> **Provenance caveat.** This file is a subagent's structured extraction, not the BIP text. It is
> adequate for architectural history and for knowing *what exists*; it is not adequate as an
> implementation reference. Read the two mediawiki files for normative detail.

## BIP 22 — Fundamentals

**Stated motivation.** bitcoind's JSON-RPC server could no longer support the load of generating
the work required to productively mine, so external software specialising in work generation had
become essential. The BIP's job is to define the compatibility boundary between a validating node
and that external software.

**Design goals.**

- Establish a compatibility standard between full nodes and mining software.
- Support independent node implementations (not just bitcoind).
- Enable specialised work-generation systems to be **separate from the validating node** — the
  architectural separation that every pool since has been built on.

**Mechanics.**

- Returns a **complete block structure** rather than a bare header: difficulty bits, timestamp,
  height, previous block hash, the transaction list, and coinbase information. The miner can
  therefore inspect and, within limits, construct the block itself.
- Submission via **`submitblock`** with hex-encoded block data.
- Optional **long polling** for real-time notification of new work.
- Template customisation parameters: **`sigoplimit`**, **`sizelimit`**.

## BIP 23 — Pooled Mining extensions

**Stated purpose.** To "counteract mining centralization by enabling miners to audit and potentially
modify blocks before processing, fostering greater decentralization within pooled mining
operations." Decentralisation is the *design intent*, stated in the specification itself in 2012 —
twelve years before the DATUM / Job-Declaration wave re-made the same argument.

**Extensions.**

- **Expiry**: an explicit validity window for a template.
- **Custom target difficulty**: the pool can set a share target below network difficulty — i.e. the
  share abstraction, specified.
- **Block proposal**: the miner can submit a candidate block for the server to validate *before*
  working on it, which is what makes "audit the template" operationally possible rather than
  theoretical.

**Permitted mutations** (what the miner may change):

- Append data to the coinbase scriptSig (`coinbase/append`).
- Adjust the header time within bounds (`time/increment`).
- Add valid transactions to the block.
- Switch between block versions.

**Submission abbreviation.** A bandwidth reduction: when the miner has not modified the supplied
transactions, it submits hash references instead of full transaction data.

**Conformance levels.**

- **Level 1** — basic pool extensions, the mutation set (coinbase/append, time/increment), and
  submission abbreviation.
- **Level 2** — additionally mandates transaction modification and the block-proposal mechanism.

## Architectural consequences

1. **Work generation is decoupled from validation.** This is the enduring contribution: it is why a
   pool is a separate program from a node at all, and why "template source" is an architectural
   component with its own redundancy and failover concerns.
2. **Miner-side template construction was specified and deployed in 2012, then not used.** The
   capability existed; the incentives and the ergonomics did not carry it. Any claim that template
   decentralisation is a *new* capability is historically wrong — the accurate claim is that it is
   newly *adopted*.
3. **GBT lost the standards race despite being the formal, decentralising option.** Stratum V1 was
   announced 2012-09-11, roughly six months later, and won on deployability. That outcome is the
   single most instructive data point in this topic: architecture that is better on the axis nobody
   is currently paying for loses to architecture that solves the operator's present problem.

## Open items from this source

- Exact JSON field names, the complete mutation string set, and the full Level-2 requirement list
  were not captured and must be read from the BIPs.
- Whether any pool ever shipped full Level-2 conformance (including block proposal) is not
  established here and is worth resolving — it bears directly on whether "GBT was available but
  unused" is true at the implementation level or only at the specification level.
