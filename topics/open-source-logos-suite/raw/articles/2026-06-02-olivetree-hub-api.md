---
title: "OliveTree Hub API & URL scheme"
url: https://github.com/OliveTreeBible/OliveTreeUrlExample
retrieved: 2026-06-02
type: repo
---

OliveTree Bible Software exposes two developer-touch surfaces: (1) a custom URL scheme `olivetree://bible/...` for opening the OliveTree mobile app at a specific passage from another app — pure deep-link, no scripture text returned; and (2) the OliveTree Hub API at api.olivetreehub.com, which is positioned as an integration surface for partner content (study notes, commentaries, plans) rather than a general scripture-fetch API. OliveTree does not offer a self-serve text-of-translation API for ESV/NIV/NASB/CSB/NLT to general developers. OliveTree's role is as a paid retail distributor of those translations within their own app, similar to YouVersion's posture but with stronger paid-content commerce. From an OSS-Logos perspective, OliveTree is closed enough that integration is one-way (deep-link out) and never inbound (no text retrieval).
