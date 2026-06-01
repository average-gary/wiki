---
title: "256foundation/hydrapool issue #41 — SV2 as additional listener"
source: https://github.com/256foundation/hydrapool/issues/41
type: articles
tags: [hydrapool, 256foundation, dual-port, additive-sv2]
summary: "Issue proposes adding SV2 as an additional listener alongside SV1 (forward, additive, dual-port). Share-normalization architecture precedent — pools that want to support both protocols simultaneously add a second listener rather than translating between them."
confidence: medium
ingested: 2026-05-28
ingested_by: path2
quality_score: 3
---

# Hydrapool SV2 issue #41

## Pattern proposed

Pool runs two listeners — SV1 on one port, SV2 on another — and normalizes shares into a single internal representation. This is a *dual-port* approach, not translation.

## Distinction from a reverse translator

- Hydrapool *is* the pool. It owns block templates, coinbase, payouts.
- A reverse translator sits in front of someone else's pool and *cannot* own those things.
- The dual-port pattern works for new pools building SV2 support natively; it does not help operators mining to existing SV1-only pools.

## Architectural precedent worth noting

The internal share-normalization pattern (one validator, two protocol entry points) is what the reverse translator does *in miniature* per upstream connection: many SV2 channels normalize into one SV1 connection's submit stream.

## See also

- [[2026-05-28-path2-sri-translator-role]]
- [[2026-05-28-path4-channels-sv2-reuse]]
