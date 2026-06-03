---
title: "bible-nkjv-embedding — pre-embedded NKJV Qdrant snapshot"
url: https://github.com/anada10/bible-nkjv-embedding
retrieved: 2026-06-02
type: repo
---

Pre-computed NKJV Bible embeddings published as a Qdrant snapshot (vectors generated with OpenAI `text-embedding-3-small`) plus the source text in Apache Avro and JSON formats. MIT license. Intended for plug-and-play RAG chatbots: drop the snapshot into a Qdrant instance and you have a queryable verse index. Caveat for OSS: NKJV is copyrighted (Thomas Nelson) — redistributing embeddings of a copyrighted text is a legally murky area. christ-is-lord should ship pre-built indexes only over public-domain (KJV, ASV, WEB) and permissively-licensed (BSB, etc.) translations to stay on safe ground. The pattern itself — distribute pre-computed embeddings with the wiki/library so users skip the index-build step — is exactly the right shape for an Iroh-blobs-distributed plugin payload.
