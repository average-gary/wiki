---
title: "ESV API developer documentation (api.esv.org/docs)"
url: https://api.esv.org/docs/
retrieved: 2026-06-02
type: spec
---

Crossway's developer-facing docs portal for the ESV API. The portal itself documents only the four endpoints (passage/text, passage/html, passage/search, audio) and the Authorization header format. The terms-of-use language (rate limits, doctrinal clause, revocation clause, cache cap) is not duplicated here — it lives on esv.org/api. The /v3/passage/text/ endpoint exposes formatting controls (verse numbers, footnotes, headings, copyright notice, line wrapping, poetry indentation). API key passed via `Authorization: Token ...` header. As of 2026-06-02 the docs are still live and unchanged in surface area; no deprecation notice. The split between docs (api.esv.org) and terms (esv.org) means a developer reading docs alone can miss the doctrinal clause entirely.
