---
title: "Compiled Wiki — SV1-Upstream Reverse Translator"
type: index
updated: 2026-07-27
---

# Compiled Articles

8 articles. Last compiled 2026-07-27.

## Topics

- [[topics/reverse-translator-playbook]] — synthesis: what it is, why it exists, what survives, how to build it, who would deploy it. **Now opens with a read-the-prior-art-first step.**

## Concepts

- [[concepts/prior-art-blitzpool-rental-proxy]] — **the reverse translator already exists.** A deployed AGPL Rust implementation (2026-06-27) that falsified this wiki's "greenfield" conclusion; what it proves, what it doesn't, and the byte-order / bdiff / switching answers worth stealing.
- [[concepts/sv2-sv1-primitive-mapping]] — how SV2 messages map to SV1 JSON-RPC and back; lossy conversions, version rolling, target translation, BIP141 concessions. Difficulty convention (pdiff vs bdiff) now flagged unresolved.
- [[concepts/sv2-features-lost-with-sv1-upstream]] — survival table: 9 lost / 9 partial / 1 replaceable / 4 survive. JDP, censorship resistance, MEV retention all lost. Authority-key loss now shown to be structural.
- [[concepts/architecture-and-state-machine]] — workspace placement (`sv2-apps/roles/reverse-translator`), tokio task graph, reusable primitives from `channels-sv2` / `handlers-sv2` / `sv1_api`, what to write from scratch. Includes the cause-based upstream-switching strategy.
- [[concepts/customer-segments-and-tam]] — honest TAM: developer tool first, production component second. Hashrate-broker segment upgraded to supported-at-small-scale.
- [[concepts/sv2-spec-issue-102-the-canonical-reference]] — the only SRI canonical document naming the concept (sv2-spec issue #102). Spec gap open; code gap closed.

## Reference

- [[reference/sv2-sv1-message-mapping-table]] — quick-lookup translation table for implementers.
