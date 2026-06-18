---
title: "An Empirical Analysis of the Nostr Social Network — Decentralization and Resilience"
source: https://arxiv.org/html/2402.05709v2
secondary_source: https://dl.acm.org/doi/epdf/10.1145/3768994
type: paper
tags: [nostr, peer-reviewed, empirical, relays, availability, ordering, gaming-implications]
fetched: 2026-06-17
confidence: high
credibility: high
quality_score: 5
relevance: direct
direction: opposes
summary: |
  Peer-reviewed (CoNEXT) measurement study of Nostr's relay topology and availability.
  Headline numbers for any system claiming Nostr-as-substrate: 20% of relays are down >40%
  of the time; 132 relays effectively dead; avg post replicated across 34.6 relays with 98.2%
  redundant retrieval (144 TiB of duplicate traffic); 95% of free-to-use relays cannot cover
  operating cost; no native event-ordering primitive. Foundational evidence that "Nostr as a
  game-state bus" has no SLA and no causality guarantee.
---

# Empirical Analysis of Nostr — CoNEXT (peer-reviewed)

## Source

- arXiv: https://arxiv.org/html/2402.05709v2
- ACM CoNEXT 2024: https://dl.acm.org/doi/epdf/10.1145/3768994
- Quality: 5 (peer-reviewed measurement study)

## Findings

- **Relay availability is poor for shared state.** "20% of the relays experience downtime
  for more than 40% of the measurement period." 10% of outages last >100 minutes. 132 relays
  effectively dead.
- **Retrieval is brute-force and wasteful.** Average post is replicated across 34.6 relays;
  "98.2% of these retrievals are redundant" — totaling ~144 TiB of duplicate traffic.
- **Economic fragility.** "95% of the free-to-use relays cannot cover their operational cost."
  Long-run availability of any specific relay is not bankable.
- **No event-ordering analysis** — confirming Nostr provides no causality / total-order
  primitive at the protocol level. Game state requiring ordered moves must build that
  in-application.
- **Real centralization despite the marketing.** Top relays concentrate traffic such that
  "remove the top 30" is a meaningful resilience experiment.

## Why this matters for nostr-ecash gaming

Turn-based games can probably tolerate this. **Real-time or fairness-critical games where
missed events change outcomes (e.g., last-write-wins move resolution) cannot.** The lack of
ordering guarantees is the single biggest architectural objection to a Nostr-only game-state
engine. nutchain's hash-linked event chain is exactly the in-application ordering layer this
paper says you must build yourself.

## Quotes

> "20% of the relays experience downtime for more than 40% of the measurement period."
>
> "98.2% of these retrievals are redundant" — duplicate cross-relay traffic.
>
> "95% of the free-to-use relays cannot cover their operational cost."
