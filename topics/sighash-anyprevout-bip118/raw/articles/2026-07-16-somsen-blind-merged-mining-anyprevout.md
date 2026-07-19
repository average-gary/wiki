---
title: "Blind Merged Mining with covenants / ANYPREVOUT (Ruben Somsen gist)"
source: "https://gist.github.com/RubenSomsen/5e4be6d18e5fa526b17d8b34906b16a5"
type: articles
ingested: 2026-07-16
tags: [blind-merged-mining, anyprevout, covenant, presigned-chain, s-equals-1-trick, known-discrete-log, ruben-somsen, prior-art]
summary: "Ruben Somsen's well-known write-up building a long chain of SIGHASH_ANYPREVOUT transactions, each only spendable by the next, with the spending signature placed in the output script (making it a covenant). Because APO omits the outpoint, you can presign a chain of spends over not-yet-existing outpoints. Uses the 's = 1 + e' / G-for-R-and-P trick to make the signatures publicly computable, so private-key security is irrelevant — relevant to non-interactive pool constructions."
---

# Blind Merged Mining with covenants (ANYPREVOUT)

Ruben Somsen gist. Established prior art for presigning spends of not-yet-existing
outpoints with APO.

## Key mechanism

- Builds "a long string of `sighash_anyprevout` transactions, each only spendable by
  the next (the spending signature is placed in the output script, making it a
  **covenant**)."
- "Since the exact signature is committed to ahead of time, **private key security is
  actually irrelevant**" — anyone can "pre-compute all the `sighash_anyprevout`
  signatures with `s = 1 + e`" (the known-discrete-log / `G`-for-both-`R`-and-`P`
  trick).
- Confirms the general APO-covenant pattern: presign a chain of txs whose prevouts
  aren't yet known, because APO omits the outpoint.

## Relevance

The `s=1` publicly-computable-signature trick is directly relevant to non-interactive
pool / mining constructions where no party should need to custody a signing key —
establishing that "APO to presign spends of future outpoints" is an accepted technique
in the covenant/mining literature.
