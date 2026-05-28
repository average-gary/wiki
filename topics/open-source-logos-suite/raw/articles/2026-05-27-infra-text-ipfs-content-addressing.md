---
title: "IPFS Content Addressing — Concepts and Limits"
source_url: "https://docs.ipfs.tech/concepts/content-addressing/"
type: article
path: infra-text
date_ingested: 2026-05-27
date_published: unknown
tags: [decentralized, ipfs, content-distribution, content-addressing]
quality: 4
confidence: high
summary: "Official IPFS docs on CIDs, multihash, DAG layout, and chunking. Establishes the canonical content-addressing model but glosses over browser/HTTP-gateway dependence."
---

# IPFS Content Addressing — Concepts and Limits

## Key findings

- A CID is a hash of the **root block** of a chunked DAG, not of raw file bytes — so identical bytes produce different CIDs depending on chunker, chunk size, codec, and layout (balanced vs trickle DAG). This is a real interop hazard for "just publish the canonical Bible XML".
- Multiformats stack: multihash (hash algo), multicodec (data type), multibase (string encoding). CIDv1 in base32 is what gateways and DNS subdomains expect today.
- DAG shape trade-offs are explicit: balanced DAGs favor random seeking; trickle DAGs favor append/streaming. For a static lexicon, balanced is the right choice (random verse/lemma access).
- Mutable references (IPNS) are flagged but not detailed in this page; in practice IPNS resolution is slow and unreliable, which is why most production IPFS uses immutable CIDs + an out-of-band pointer (DNSLink, GitHub release, app-config).
- The page does not address browser-only consumers explicitly, but the heavy emphasis on subdomain gateways implies that gateway HTTP fallback is the assumed consumption path for most users — which is essentially "fancy CDN with content hashes".

## Notable quotes / specifics

- "A CID is a label used to point to material in IPFS"; the label is "based on cryptographic hashing rather than location".
- "Identical files can produce different CIDs depending on chunk size, DAG layout, and codec selection."
- Default chunker is fixed-size 256 KiB; DAG fan-out is 174. Worth noting because two clients adding the same Bible XML with different defaults will produce non-overlapping CIDs and not dedupe.

## Source notes

Useful as the canonical reference for IPFS content addressing but not honest about real-world limitations. Pair with skeptical sources for a balanced view. Bible-app implication: content addressing is a good fit for static immutable corpora, but you must pin the exact chunker/DAG params or you lose the dedupe benefit across publishers.
