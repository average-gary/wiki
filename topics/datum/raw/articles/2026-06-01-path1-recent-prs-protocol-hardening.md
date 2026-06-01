---
title: "Recent DATUM Gateway PRs/issues — protocol hardening signals (May–June 2026)"
source: "https://github.com/OCEAN-xyz/datum_gateway/issues?q=is%3Aopen"
type: articles
tags: [datum, datum-protocol, security, libsodium, queue-overflow, defensive-coding, pull-requests, ocean]
summary: "Cluster of open PRs and issues from luke-jr and others (May 18–June 1, 2026) signal the actual hardening work happening on DATUM Protocol: PR #202 swaps a weaker initial entropy source for libsodium randombytes_buf for the sending_header_key, PR #190 adds length checks on server-provided GBT/coinbaser data, issue #209 (open same day this wiki was created) reports queue overflow + non-graceful recovery in production. Also: version-bump triple v0.2.6/v0.3.3/v0.4.1-beta on 2025-12-17 across three maintenance branches."
confidence: high
ingested: 2026-06-01
ingested_by: path1
quality_score: 4
canonical_url: "https://github.com/OCEAN-xyz/datum_gateway/issues"
---

# Recent DATUM Gateway PRs/issues — what the maintainers are actually fixing

The README claims the protocol is "evolving and will be published elsewhere" but provides no public changelog. The closest thing to a roadmap is the PR/issue list. Recent activity (mostly in the May 18–June 1, 2026 window from luke-jr's defensive-coding pass plus a fresh queue-overflow bug) reveals what's currently weak.

## Version bumps (2025-12-17)

Three concurrent version bumps on the same day across three release branches:

| Commit | Branch | Version |
|---|---|---|
| 690fd4b | 0.2.x | v0.2.6-beta |
| 45d4ee1 | 0.3.x | v0.3.3-beta |
| 052cae9 | 0.4.x | v0.4.1-beta |

The triple-bump indicates **three actively-maintained branches** running in parallel — uncommon for a young project and suggesting OCEAN runs older versions in production while testing newer features. v0.4.1-beta is the version pinned in `datum_protocol.h`'s `DATUM_PROTOCOL_VERSION` constant (`master` HEAD). 0.2.x is presumably what the average OCEAN miner is running today.

## PR #202 — libsodium randombytes_buf for sending_header_key (open 2026-05-20)

Title: *"protocol: Use libsodium randombytes_buf for initial sending_header_key"*

Replaces the existing initial-entropy source for the `sending_header_key` (the seed fed into the MurmurHash3-style XOR-feedback header obfuscator — see `datum_protocol.c` ingest). 1 addition, 4 deletions, 1 file.

**Why it matters**: the `sending_header_key` is the seed for traffic-analysis resistance on the protocol's framing layer. If the seed has weak entropy (e.g. derived from `time()` or a libc PRNG), passive observers can predict the XOR pattern and recover header structure even though payloads are encrypted. The fact that this needed to be fixed suggests the original code used something weaker — typical "I'll fix this later" technical debt that a security-minded maintainer (luke-jr) caught during a sweep.

**Wiki implication**: the existing concept article calls header obfuscation a stated design goal; this PR is evidence the current implementation isn't there yet. The protocol's "obfuscate communications somewhat" claim is partly aspirational at v0.4.1-beta.

## PR #190 — length checks for server-provided data (open 2026-05-18, milestone 0.2.7)

Title: *"Bugfix: Add length checks for server-provided data"*

Author: luke-jr. 32 additions, 24 deletions, 2 files. Adds defensive validation for:

- Transaction IDs and hashes in GetBlockTemplate responses
- Server-provided generation transaction data (i.e. coinbaser blobs)

**Why it matters**: this is direct evidence the gateway was previously **trusting pool-side input lengths**. A malicious or buggy pool could send oversized fields and trigger buffer issues. For a protocol whose whole pitch is "pool can't censor your transactions," accepting unbounded data from that pool was a glaring asymmetry. The PR being targeted at milestone 0.2.7 (not master) suggests it's a backportable fix.

**Wiki implication**: the protocol's threat model wasn't adversarial-pool-by-default until very recently. A proxy translating SV2 ↔ DATUM should not assume DATUM handles malformed upstream cleanly across all currently-deployed versions — defensive parsing is the proxy's job too.

## Issue #209 — Datum queue overflows and does not recover gracefully (open 2026-06-01)

Filed today. Quote: *"Queue overflow! Is there anything consuming this queue? Likely a bug!"* — appears repeatedly in production logs, causing worker offline status. Restart resolves.

**Why it matters**: the protocol's queueing layer (`datum_queue.c`, 7 KB) is the buffer between the network event loop and the share-submission flow. Overflow means the producer-consumer ratio is wrong under some load condition, which suggests either:

- A backpressure missing on inbound shares while DATUM upstream is slow
- A handshake/reconnect path that doesn't drain the queue cleanly
- A leak where queue items aren't freed after dispatch

Whatever it is, **production miners are seeing this on June 1, 2026** — the day this wiki research was launched. A proxy must therefore design its own queues to absorb DATUM-side stalls without propagating "go offline" semantics to the SV2 downstream miners.

## Issue #208 — Rootstock merge-mining support (open 2026-06-01, draft PR)

Filed by luke-jr. Adds Rootstock merge-mining via local Rootstock node websocket. Quote: *"Completely untested. Do not run on mainnet until it's proven to produce valid blocks!"*

**Why it matters tangentially**: it confirms OCEAN's appetite for protocol surface-area expansion on the gateway side. If merge-mining lands inside DATUM, the on-the-wire opcode space (5-bit, 32 max) gets tighter. Worth tracking for any future-version protocol bumps.

## Other open PRs worth flagging

| PR | Title | Why it matters |
|---|---|---|
| #195 | queue & stratum_dupes: Check for overflows, use size_t | Companion to #209 — defensive sizing |
| #200 | protocol: Avoid write locks for atomic booleans | Threading optimization — perf-sensitive on the protocol path |
| #198 | Handle pthread_create failures | Reliability gap |
| #194 | blocktemplates: Make prevhash checks consistent | Hints at a stale-template race |
| #204 | coinbaser: Drop buggy and unused must_free parameter | Dead code in the coinbase path |
| #206 | Bugfix: queue: Add missing pthread.h and stddef.h includes in header | Hygiene |

## Aggregate signal

If you draw a Venn diagram of these PRs, the center is *"the C code is correct on the happy path but had latent defensive-coding gaps that one motivated reviewer (luke-jr) caught in a single May–June pass."* Three implications for a proxy/translator project:

1. **Don't assume DATUM Gateway in the field is the same as DATUM Gateway at master.** v0.2.6-beta is in production and lacks PR #190's length checks. Test against multiple versions.
2. **The protocol's threat model is being formalized in real-time.** Today's "trust the pool input length" might be tomorrow's "all server data is bounded and signed." A proxy that hardcodes assumptions about DATUM behavior risks breaking on the next version bump.
3. **Maintainer attention is on hardening, not protocol evolution.** No PRs in this batch touch opcode definitions or framing. SV2 (issue #146) is dormant, queue overflow (#209) is fresh. Don't expect a major DATUM revision soon.

## Sources

- [Issue #209 — Datum queue overflows](https://github.com/OCEAN-xyz/datum_gateway/issues/209) — opened 2026-06-01
- [PR #202 — Use libsodium randombytes_buf](https://github.com/OCEAN-xyz/datum_gateway/pull/202) — opened 2026-05-20
- [PR #190 — Add length checks for server-provided data](https://github.com/OCEAN-xyz/datum_gateway/pull/190) — opened 2026-05-18
- [Issue #208 — Rootstock merge-mining](https://github.com/OCEAN-xyz/datum_gateway/issues/208) — opened 2026-06-01
- Commits 052cae9, 45d4ee1, 690fd4b — version bumps 2025-12-17
