---
title: "Compiled Wiki — SV1-Upstream Reverse Translator"
type: index
updated: 2026-05-28
---

# Compiled Articles

## Topics

- [[topics/reverse-translator-playbook]] — synthesis: what it is, why it exists, what survives, how to build it, who would deploy it.

## Concepts

- [[concepts/sv2-sv1-primitive-mapping]] — how SV2 messages map to SV1 JSON-RPC and back; lossy conversions, version rolling, target translation, BIP141 concessions.
- [[concepts/sv2-features-lost-with-sv1-upstream]] — survival table: 9 lost / 9 partial / 1 replaceable / 4 survive. JDP, censorship resistance, MEV retention all lost.
- [[concepts/architecture-and-state-machine]] — workspace placement (`sv2-apps/roles/reverse-translator`), tokio task graph, reusable primitives from `channels-sv2` / `handlers-sv2` / `sv1_api`, what to write from scratch.
- [[concepts/customer-segments-and-tam]] — honest TAM: developer tool first, production component second. Customer ranking with verdicts.
- [[concepts/sv2-spec-issue-102-the-canonical-reference]] — the only SRI canonical document naming the concept (sv2-spec issue #102).

## Reference

- [[reference/sv2-sv1-message-mapping-table]] — quick-lookup translation table for implementers.
