---
title: Jahns — "Are CRDTs suitable for shared editing?"
url: https://blog.kevinjahns.de/are-crdts-suitable-for-shared-editing/
retrieved: 2026-06-02
type: blog
---

Yjs author Kevin Jahns's defense of CRDTs against the
"too-heavy-for-shared-editing" critique levelled by editor authors like
Marijn Haverbeke (CodeMirror) and the Xi-Editor maintainers. Headline
empirical numbers: a worst-case 1M-insertion document holds at ~112MB;
a real 17-page academic paper with 260k operations parses in 20ms and
uses 19.7MB. Jahns argues that compound representation — collapsing
consecutive insertions into a single CRDT item — is the optimization that
makes CRDT memory tractable in practice; this is exactly what later
algorithms like Eg-walker (which Loro adopts) generalize. The post does
NOT mention Loro. Useful background for the decision because it sets the
"is yrs's algorithmic family good enough?" baseline: yes, for documents
of any plausible sermon-note size.
