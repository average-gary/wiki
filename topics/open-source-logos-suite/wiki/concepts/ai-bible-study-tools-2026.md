---
title: "AI Bible-study tools 2026: RAG, citation-grounding, hallucination guards"
type: concept
created: 2026-06-02
updated: 2026-06-02
verified: 2026-06-02
volatility: hot
confidence: medium
tags: [ai, llm, rag, plugins, competitive-landscape, hallucination, citation, ollama]
sources:
  - raw/articles/2026-06-02-logos-ai-product-page.md
  - raw/articles/2026-06-02-pulpit-ai-homepage.md
  - raw/articles/2026-06-02-pulpit-ai-pricing.md
  - raw/articles/2026-06-02-magisterium-ai-blocked.md
  - raw/articles/2026-06-02-youversion-no-ai-disclosure.md
  - raw/articles/2026-06-02-github-bible-rag-search.md
  - raw/articles/2026-06-02-brace-bible-retrieval-augmented.md
  - raw/articles/2026-06-02-bible-ai-assistant-ttimms.md
  - raw/articles/2026-06-02-self-reflective-rag-bible.md
  - raw/articles/2026-06-02-bible-rag-evaluation-jurjani.md
  - raw/articles/2026-06-02-nkjv-embedding-anada10.md
  - raw/articles/2026-06-02-bible-chats-isherous.md
---

# AI Bible-study tools 2026: RAG, citation-grounding, hallucination guards

## TL;DR

The 2026 AI Bible-study market is bifurcated: paid SaaS incumbents (Logos AI at $8.33–$16.67/mo, Pulpit AI at $39–$129/mo, Magisterium AI for Catholic users) with closed, undocumented architectures; and a long tail of small OSS RAG repos (BRACE, bible-ai-assistant, Self-Reflective-RAG, BibleRAG) that demonstrate every architectural pattern christ-is-lord needs but lack distribution, integration, and a real product. **No incumbent owns the open-source, locally-runnable, citation-grounded niche** — the field is wide open. christ-is-lord's plugin SDK should ship a first-party "AI Study" plugin that defaults to citation-required generation, refuses on no-source-found, and runs against either local Ollama or a user-chosen cloud LLM via capability-manifested network access.

## Evidence

### The paid SaaS incumbents do not disclose architecture

Logos AI ([[../../raw/articles/2026-06-02-logos-ai-product-page.md|Logos AI page]]) advertises "AI-powered search and summarization" across all three tiers — Premium $8.33/mo, Pro $12.50/mo, Max $16.67/mo (annual pricing) — plus "AI translation" on Max. The marketing surface confirms the product exists and is monetized, but **publishes nothing** about retrieval scope, model choice, citation format, or hallucination guards. From the customer's perspective the answer just appears, presumably grounded in the user's licensed library, but there is no contract that says so.

Pulpit AI ([[../../raw/articles/2026-06-02-pulpit-ai-homepage.md|homepage]], [[../../raw/articles/2026-06-02-pulpit-ai-pricing.md|pricing]]) is a different niche — sermon repurposing, not Bible study — but illustrates the same pattern at higher prices: Basic $39/mo, Standard $59/mo, Pro $129/mo, scaling by upload count. The corpus is implicitly the pastor's own transcripts, but again, no architecture is published. Pulpit's price point (≈4–10× Logos AI) reflects the church-budget buyer; it is not a direct christ-is-lord competitor but it confirms that closed-source AI tools for Christian workflows can charge premium SaaS prices without any technical transparency.

Magisterium AI ([[../../raw/articles/2026-06-02-magisterium-ai-blocked.md|Magisterium homepage — blocked 429]]) returned HTTP 429 on three URLs during this scan; the assess document had flagged this risk. Public reporting from its 2024 launch describes it as a Longbeard-built RAG over the Catholic magisterial corpus — encyclicals, conciliar documents, the Catechism, canon law — with citation-required output as the marketing differentiator vs. generic ChatGPT. We are flagging this rather than fabricating quotes from an inaccessible site, but the pattern is well-attested elsewhere: **a curated corpus + a citation-required output template is the only credible way to ship a religious AI assistant that serious users will trust.**

YouVersion ([[../../raw/articles/2026-06-02-youversion-no-ai-disclosure.md|YouVersion no-AI scan]]) — by far the largest installed Bible app — has no public AI marketing surface as of 2026-06-02. Predictable URLs (`/bible-chat/`, `/blog/...ai...`, `news.youversion.com`) all 404. Either YouVersion is keeping AI work internal or has not yet committed to the category. Either way, **the Bible app with the largest user base has not staked the citation-grounded AI Bible-study niche.**

### The OSS prior art is real but fragmented

GitHub search for `bible rag llm` ([[../../raw/articles/2026-06-02-github-bible-rag-search.md|search results]]) returns ~9 visible repositories, all 0–6 stars, most updated within the last year. Notable patterns:

- **BRACE** ([[../../raw/articles/2026-06-02-brace-bible-retrieval-augmented.md|BRACE]]) — Catholic-edition RAG over RSVCE using "Corrective RAG"; permissively-licensed self-hosted models; explicit hallucination disclaimer ("the underlying AI can misinterpret text — verify all references").
- **bible-ai-assistant** ([[../../raw/articles/2026-06-02-bible-ai-assistant-ttimms.md|t-timms]]) — fine-tuned Qwen3.5-4B with bf16 LoRA SFT and ORPO alignment; hybrid dense (Chroma + nomic-embed) + sparse (BM25Okapi) retrieval; Reciprocal Rank Fusion; bge-reranker-v2-m3 cross-encoder; constitutional-AI guardrails; fully Docker-Composable on Ollama; 183 unit tests; MIT code, Qwen weights, public-domain WEB/KJV. **The closest thing to a reference design.**
- **Self-Reflective-RAG** ([[../../raw/articles/2026-06-02-self-reflective-rag-bible.md|Immanuel2004]]) — FAISS + LangGraph "self-reflective" loop (retrieve → generate → critique → re-retrieve), Streamlit UI, MIT.
- **BibleRAG** ([[../../raw/articles/2026-06-02-bible-rag-evaluation-jurjani.md|al-Jurjani]]) — empirical benchmark of chunk sizes (256/512/1024), retrievers (BM25/semantic/MMR/RRF), and embeddings (bge-small-en, sentence-transformers) on KJV with Qwen2.5. Best config: 3B + MMR + 256-char chunks + bge-small-en. Verse-scale chunks beat paragraph-scale chunks.
- **bible-nkjv-embedding** ([[../../raw/articles/2026-06-02-nkjv-embedding-anada10.md|anada10]]) — pre-computed Qdrant snapshot, MIT. Pattern is right; NKJV licensing is wrong (Thomas Nelson copyright).
- **bible_chats** ([[../../raw/articles/2026-06-02-bible-chats-isherous.md|isherous]]) — Flutter + Gemini + Pinecone + Firebase. The default SaaS shape christ-is-lord should *not* adopt.

None of these has more than single-digit stars. The patterns are public; the product is missing.

### Citation-grounding and hallucination-guard patterns visible in OSS

Surveying the repos above, four reusable patterns emerge:

1. **Retrieve-then-generate with citation slots** — BibleRAG, bible-ai-assistant. The prompt template forces the model to emit a `[[ref]]` for every claim; if it can't, the answer is rejected upstream.
2. **Self-reflective / corrective RAG** — Self-Reflective-RAG, BRACE. After generation the system re-checks whether each claim is supported by retrieved context; unsupported claims trigger re-retrieval or refusal.
3. **Hybrid dense + sparse retrieval with reranking** — bible-ai-assistant, BibleRAG (the empirically best). Verse-level chunks, BM25 + semantic, RRF fusion, cross-encoder rerank. This minimizes "retrieval miss" hallucinations where the model invents a citation because none was in context.
4. **Constitutional / refusal-mode guardrails** — bible-ai-assistant uses ORPO alignment + counseling-pattern detection to route off-topic / harmful queries to safety responses rather than confabulating answers.

What no OSS project has: **strict refusal on no-source-found as the default mode**, where the system simply says "no canonical source supports an answer here" rather than degrading to ungrounded generation. Magisterium AI's marketing implies it; nobody has shipped it cleanly in OSS.

## Implications for christ-is-lord

- **The unfilled niche is real.** Logos AI, Pulpit AI, Magisterium AI, and YouVersion either lock you into proprietary libraries, target sermon ops, target Catholic users only, or have not entered the category. The OSS repos are 0–6-star hobby projects. **No incumbent owns "OSS, locally-runnable, citation-grounded AI Bible study with no SaaS lock-in" as of 2026-06.** This is exactly the niche the v1.0.0 stack — file-over-app, capability-manifest plugins, Iroh-blobs distribution — was built to fill.

- **Ship a first-party "AI Study" plugin in the SDK.** Concrete capability-manifest shape: `library.read` (the user's compiled library + Macula/STEPBible/etc.), `index.query` (FTS5 + Tantivy + a new vector index over verse-chunks), and either `network.host:api.openai.com` / `network.host:api.anthropic.com` (cloud-LLM users with their own API key) or a new `local-llm` capability that pipes to a user-running Ollama/llama.cpp endpoint. Out-of-process Node host already isolates the plugin from the core; this is the right boundary for an LLM call.

- **Citation-required as the default, refusal as the fallback.** Borrow the [[study-tool-ux-gap.md|study-tool UX]] discipline: every assistant answer must point at one or more citation chips that resolve to a Bible verse, lexicon entry, commentary paragraph, or cross-reference in the user's library. If retrieval returns nothing above a confidence threshold, the assistant says "no source in your library supports an answer to this — try expanding your library or rephrasing." This is the differentiator vs. paywalled-library competitors who hide the architecture and silently confabulate.

- **Ship pre-computed embeddings as Iroh-blobs payloads.** Following the [[decentralized-text-distribution.md|decentralized text distribution]] pattern, distribute verse-level vector indexes (over public-domain WEB/KJV/ASV plus Macula tagged Greek/Hebrew) as signed Iroh-blobs hashseqs. Users skip the index-build step on first run; the plugin verifies the manifest signature; the same blob mirrors over R2. The `bible-nkjv-embedding` repo proves the pattern works — but ship only over open-licensed translations.

- **Architecturally, copy bible-ai-assistant.** Hybrid dense + sparse + RRF + cross-encoder rerank, verse-scale chunks (BibleRAG showed 256-char beats 1024-char on theological queries), Ollama-served quantized model for local-only users, optional cloud route for users who already pay for an LLM. Wrap the generation in a self-reflective loop that re-checks each claim against the retrieved context before returning.

- **Reject ungrounded generation as a product principle.** The category is small enough that the trust position — "we will literally refuse to answer rather than make something up" — is both ethically correct (we are dealing with Scripture) and a marketable differentiator. Logos AI cannot publicly commit to this without exposing the cases where their current product fails it. christ-is-lord can.

## See Also

- [[study-tool-ux-gap|Study-Tool UX Gap]] — the integrated-study UX that an AI plugin should plug into (Sermon Builder, Factbook, Passage Guide)
- [[../decisions/plugin-trust-model|Plugin Trust Model]] — capability-manifest schema the AI plugin must declare against (`library.read`, `index.query`, `network.host:<llm>` or `local-llm`)
- [[walled-translation-api-revocation-history|Walled translation API revocation history]] — why the AI plugin should index over open-licensed translations, not paywalled ones
- [[search-and-indexing|Search and Indexing]] — the FTS5 + vector-index hybrid retrieval surface
- [[decentralized-text-distribution|Decentralized text distribution]] — Iroh-blobs distribution path for pre-computed embedding indexes
- [[../topics/engineering-playbook|Engineering Playbook]]
