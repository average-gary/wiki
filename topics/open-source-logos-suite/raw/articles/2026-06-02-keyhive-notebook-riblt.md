---
title: "Keyhive notebook — RIBLT for set reconciliation"
url: https://www.inkandswitch.com/keyhive/notebook/05/
retrieved: 2026-06-02
type: article
---

Notebook entry on how Beelay (the Keyhive sync protocol) uses Rateless Invertible Bloom Lookup Tables to reconcile two peers' sets of membership ops + document metadata. Each peer hashes its set into "symbols" and exchanges them; the receiver decodes symbols to learn which hashes are missing on each side — "the result of decoding is the set of hashes — not the things themselves." Bandwidth scales with the *difference*, not set size: reconciling two billion-item sets that differ in 5 elements takes ~7.5 symbols (~240 bytes). Symbol overhead is "1.7x for small sets down to 1.35x for large sets" of the actual difference. Symbols are fixed-length byte arrays so the wire format is transport-agnostic. References the academic RIBLT paper (Yang, Gilad, Alizadeh, SIGCOMM 2024).
