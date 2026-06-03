---
title: "Keyhive notebook — design overview (capabilities, BeeKEM, Beelay)"
url: https://www.inkandswitch.com/keyhive/notebook/
retrieved: 2026-06-02
type: article
---

Index page for Ink & Switch's Keyhive design notebook. Three pillars: (1) Convergent Capabilities — a model between object- and certificate-capabilities allowing "stateless self-certification with a cryptographic proof"; documents delegate control to public keys for users / groups / devices, and groups are themselves a thin abstraction over delegation chains. (2) End-to-end encryption with causal keys — data encrypted at rest using the Automerge binary format; rather than encrypting individual ops, ranges of changes are compressed and then encrypted, with keys managed across document history. (3) BeeKEM — a Continuous Group Key Agreement protocol providing forward secrecy + post-compromise security with logarithmic typical performance. Sync ("Beelay") layers RIBLT for membership-graph reconciliation, the same trick for document-collection state, then BeeKEM ops + sedimentree chunk compression per-document; common-case sync completes in ~2 round trips.
