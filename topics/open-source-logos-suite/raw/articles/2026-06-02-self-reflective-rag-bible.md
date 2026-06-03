---
title: "Self-Reflective RAG — Bible Q&A app"
url: https://github.com/Immanuel2004/Self-Reflective-RAG
retrieved: 2026-06-02
type: repo
---

A Streamlit Bible Q&A app that "ingests Scripture, retrieves relevant passages, and generates answers with citations." Architecture: data-ingestion module, FAISS vector index of the Bible, a `graph_builder` + `nodes` package indicating LangGraph orchestration (the "self-reflective" loop = retrieve → generate → critique → re-retrieve if needed), and a `tool` retrieval wrapper. MIT license. Python only. Deployed on Streamlit Cloud. Engagement is low (1 star, 0 forks) but the architectural pattern — self-reflective / corrective RAG with explicit citation slots in generation — is exactly the hallucination-guard primitive christ-is-lord should adopt: the model is forced to either cite a retrieved passage or revise its answer.
