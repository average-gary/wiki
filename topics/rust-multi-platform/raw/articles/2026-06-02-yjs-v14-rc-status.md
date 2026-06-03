---
title: Yjs v14 — still RC after 24+ months
url: https://github.com/yjs/yjs/releases
retrieved: 2026-06-02
type: repo
---

Yjs's GitHub releases page shows **v14.0.0-rc.17 dated 2024-05-26** as the
most recent v14 line — and as of 2026-06-02 there is still no v14.0.0
stable. The latest stable production line is the **v13.6.x series**
(v13.6.31, 2024-05-28). That is the practical posture: production Yjs is
v13, v14 has been an open RC for ~24 months. For christ-is-lord this means
two things. (1) Yjs-on-the-web is fine — v13 is stable and shipping. (2)
Anyone betting the Rust mobile path on yrs picks up v13 wire-format compat,
not v14 — yrs maintains v13 protocol compatibility but is itself pre-1.0
(v0.18 from March 2025). The "yrs is the conservative choice because Yjs
is mature" intuition needs the asterisk: the Yjs JS line that is mature is
v13, and the v14 reset has been stalled for two years.
