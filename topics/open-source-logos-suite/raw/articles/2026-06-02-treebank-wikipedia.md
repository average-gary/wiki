---
title: "Treebank (Wikipedia) — query language landscape"
url: https://en.wikipedia.org/wiki/Treebank
retrieved: 2026-06-02
type: article
---

# Treebank query landscape

Wikipedia's treebank article frames the field but is thin on query specifics; useful only as a map of the territory. The corollary, drawn from primary sources fetched alongside, is that the live tree-query options in 2026 are: (1) Tregex/Semgrex (Stanford, GPL, slow but maintained), (2) ad-hoc XPath / XQuery directly against XML treebanks (universal but verbose and slow on large corpora because no native indexes), (3) TGrep2 (Rohde, GPL, unmaintained since the mid-2000s), (4) TIGERSearch (Stuttgart, defunct, replaced by lightly-used ICARUS), (5) custom DSLs compiled to SQL or Datalog over a flattened tokens-with-parent table. For a small, well-bounded corpus like the Hebrew + Greek Bible (about 800k tokens combined) option (5) — compile a Cascadia-flavoured DSL down to SQL self-joins on a SQLite tree-encoded tokens table — is the only plan that is both open-license-friendly and fast enough on mobile to meet the "<2s" interactive query target.
