---
title: "Lowfat XML schema (biblicalhumanities Nestle1904 README)"
url: https://github.com/biblicalhumanities/greek-new-testament/tree/master/syntax-trees/nestle1904-lowfat
retrieved: 2026-06-02
type: spec
---

# Lowfat XML schema

The lowfat format is XML using `<sentence>`, `<cite>`, `<wg>` (word group), `<w>` (word), `<milestone>`, and `<pu>` (punctuation). It is "lowfat" because it has roughly half the elements and a third of the attributes of the older GBI tree format, making it cheap to query with XPath or to flatten into relational rows. `<wg>` carries `nodeId`, `class` (np, cl, pp, vp, adjp, advp, nump, adv, conj), `role` (s, v, vc, o, p, io, o2, adv — clause-level grammatical role), and boolean flags `articular`/`det`/`head`. `<w>` carries `lemma`, `osisId`, `class` (noun/verb/det/conj/pron/prep/adj/adv/ptcl/num/int), full Greek morphology (`person`, `number`, `gender`, `case`, `tense`, `voice`, `mood`, `degree`), `head`, and `discontinuous`. The Clear-Bible MACULA Greek lowfat extends this with `strong`, `gloss`, Louw-Nida `domain`/`ln`, `morph` (Sandborg-Petersen code), `frame` (semantic argument structure like `A0:nodeid A1:nodeid`), `subjref` (subject coreference), and `rule` (the construction rule that produced the wg, e.g. `S-V`, `PrepNp`, `DetAdj`).
