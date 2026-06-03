---
title: "PR #1056 — Key Revocation (Draft, open since 2024)"
url: https://github.com/nostr-protocol/nips/pull/1056
retrieved: 2026-06-02
type: pr
---

Long-running draft PR by vitorpamplona, opened 2024-02-16, still in Draft status as of 2026-06-02. Proposes a *web-of-trust* approach to key migration rather than a cryptographic one: kind:18 events signal key deprecation and migration to a new key, and followers' clients use the existing follow graph as the verification mechanism. Generic kind:16 reposts help propagate the migration signal across relays. Critically, the proposal intentionally avoids cryptographic proof of new-key ownership and instead lets users decide based on social signals.

The discussion thread (33+ comments) repeatedly returns to one objection: an attacker holding a stolen nsec can selectively broadcast false migrations to targeted users on relays the legitimate user doesn't read, and there is no cryptographic tie-breaker. The author has framed it as an *intermediate* solution — better than nothing, but not a permanent standard. Two years later it is still draft, with most of the energy now flowing to PR #2137 instead.
