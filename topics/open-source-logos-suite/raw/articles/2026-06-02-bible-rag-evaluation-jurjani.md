---
title: "BibleRAG — empirical evaluation of RAG configurations"
url: https://github.com/al-Jurjani/BibleRAG
retrieved: 2026-06-02
type: repo
---

A research repo by Zuhair Farhan and Sahil Kumar that benchmarks RAG configurations for KJV Bible Q&A across three metrics: faithfulness (groundedness in retrieved context), relevance, and similarity to expert-curated answers. Variables tested: chunk sizes 256/512/1024, retrievers (BM25, semantic, MMR, hybrid Reciprocal Rank Fusion), embedding models (BAAI/bge-small-en, sentence-transformers), FAISS indexing, and Qwen2.5-1.5B vs Qwen2.5-3B. Best config: 3B + MMR + 256-char chunks + bge-small-en. Smaller chunks generally beat larger ones (verses are short, discourse boundaries matter); MMR/semantic beat BM25 on theological queries; broader topical questions wanted more context. License unclear. Empirical takeaway for christ-is-lord: ship verse-level chunks, semantic+lexical hybrid retrieval, and don't assume bigger context windows are better.
