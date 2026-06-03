---
title: "Keyhive notebook — Introduction & threat model"
url: https://www.inkandswitch.com/keyhive/notebook/01/
retrieved: 2026-06-02
type: article
---

First entry in Ink & Switch's public design notebook for Keyhive. Frames Keyhive as a local-first access-control system: "For local-first software to be successful in many production contexts, it needs to provide similar features without relying on a central authorization server." Threat model addresses operations that causally depend on later-discovered malicious content, concurrent revocation by multiple admins, and back-dated operations by malicious actors — all without requiring consensus, preserving partition tolerance ("the same consistency level as Automerge"). Stated targets: small-group coordination (surprise parties, meeting notes), publishing platforms with restricted editing, corporate legal docs, high-risk journalism. Scale goal: "tens-of-thousands of documents, millions of readers, thousands of writers, hundreds of admins/superusers" per system — but the small-group case is treated as the primary design driver.
