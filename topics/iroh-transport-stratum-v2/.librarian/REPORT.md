# Librarian Report — 2026-05-23

> Scanned 14 articles in `iroh-transport-stratum-v2`. First scan. Passes: staleness, quality.

## Headline finding

**All 14 articles flagged stale — same structural cause as the sv2-p2pool wiki: missing `verified:` and `volatility:` frontmatter.** The verification-recency dimension contributes 0/25, capping every article at ~49/100 even though all were compiled 3 days ago. Content quality is excellent (avg 91/100) — this is a metadata fix, not a content fix.

The body of work here is the most complete of all four scanned wikis (14 articles, including the load-bearing `sv2-iroh-transport-playbook` which scores 100/100 on quality). Worth investing the small fix to get accurate staleness reads going forward.

## Summary

| Metric | Value |
|--------|-------|
| Articles scanned | 14 |
| Below staleness threshold (70) | 14 (structural — see above) |
| Low quality (< 50) | 0 |
| Average staleness | 47/100 (capped) |
| Average quality | 91/100 |

## Stale Articles

| Article | Score | Top Factor | Recommendation |
|---|---|---|---|
| [sv2-noise-nx](../wiki/concepts/sv2-noise-nx.md) | 49/100 | unverified | structural-fix |
| [sv2-framing](../wiki/concepts/sv2-framing.md) | 49/100 | unverified, single-source | structural-fix |
| [nat-traversal-baseline](../wiki/concepts/nat-traversal-baseline.md) | 49/100 | unverified | structural-fix |
| [iroh-custom-transports](../wiki/concepts/iroh-custom-transports.md) | 49/100 | unverified, thin | structural-fix + expand |
| [erosion-attack](../wiki/concepts/erosion-attack.md) | 49/100 | unverified, single-source | structural-fix |
| [fedimint-as-reference](../wiki/concepts/fedimint-as-reference.md) | 49/100 | unverified, single-source | structural-fix |
| [quic-performance-ceiling](../wiki/concepts/quic-performance-ceiling.md) | 49/100 | unverified | structural-fix |
| [iroh-relays](../wiki/concepts/iroh-relays.md) | 49/100 | unverified | structural-fix |
| [iroh-endpoint-and-alpn](../wiki/concepts/iroh-endpoint-and-alpn.md) | 49/100 | unverified | structural-fix |
| [integration-pattern-iroh-blobs](../wiki/concepts/integration-pattern-iroh-blobs.md) | 49/100 | unverified | structural-fix |
| [risks-and-tradeoffs](../wiki/topics/risks-and-tradeoffs.md) | 49/100 | unverified | structural-fix |
| [why-iroh-for-sv2](../wiki/topics/why-iroh-for-sv2.md) | 49/100 | unverified | structural-fix |
| [sv2-iroh-transport-playbook](../wiki/topics/sv2-iroh-transport-playbook.md) | 49/100 | unverified | structural-fix |
| [reference/specs-and-crates](../wiki/reference/specs-and-crates.md) | 24/100 | no `sources:`, unverified | structural-fix (or accept type=reference exemption) |

## Low Quality Articles (quality < 50)

None.

## Notable quality flags

| Article | Quality | Flags |
|---|---|---|
| reference/specs-and-crates | 75/100 | unverified, no-sources (expected for type: reference) |
| iroh-custom-transports | 80/100 | unverified, thin-coverage |
| sv2-framing | 90/100 | unverified, single-source |
| erosion-attack | 90/100 | unverified, single-source |
| fedimint-as-reference | 95/100 | unverified, single-source (the Fedimint repo dump is rich enough that single-source is acceptable here) |

## All Articles (sorted by quality desc)

| Article | Staleness | Quality | Flags |
|---|---|---|---|
| sv2-iroh-transport-playbook | 49 | 100 | unverified |
| sv2-noise-nx | 49 | 95 | unverified |
| nat-traversal-baseline | 49 | 95 | unverified |
| fedimint-as-reference | 49 | 95 | unverified, single-source |
| quic-performance-ceiling | 49 | 95 | unverified |
| iroh-relays | 49 | 95 | unverified |
| risks-and-tradeoffs | 49 | 95 | unverified |
| why-iroh-for-sv2 | 49 | 95 | unverified |
| sv2-framing | 49 | 90 | unverified, single-source |
| erosion-attack | 49 | 90 | unverified, single-source |
| iroh-endpoint-and-alpn | 49 | 90 | unverified |
| integration-pattern-iroh-blobs | 49 | 90 | unverified |
| iroh-custom-transports | 49 | 80 | unverified, thin-coverage |
| reference/specs-and-crates | 24 | 75 | unverified, no-sources |

## Recommended follow-ups

1. **Wiki-wide structural fix** — add `verified:` and `volatility:` to all 14 articles. Suggested volatility tiers:
   - **hot**: `iroh-custom-transports` (post-1.0 unstable surface), `sv2-iroh-transport-playbook` (living implementation guide)
   - **warm** (default): all the iroh API and protocol concept articles
   - **cold**: `erosion-attack` (peer-reviewed paper, won't change), `nat-traversal-baseline` (empirical baseline from published measurement studies)
2. **`iroh-custom-transports` is thin** (3 sources, mostly enumeration of Tor/Nym/BLE without depth). If this is meant to be a placeholder, mark `status: stub`. Otherwise expand with at least the `noq` API surface.
3. **`reference/specs-and-crates` is link-dump shaped** (no sources, no ingested-from-raw chain). Either fold individual link sets into the articles that use them and delete this file, or amend the librarian protocol to exempt `type: reference`.
4. **Single-source articles** (`erosion-attack`, `fedimint-as-reference`, `sv2-framing`) — each is grounded in one canonical source (the paper, the repo, the spec) and adding speculative secondary sources would weaken them. Mark intentionally if the protocol supports it, or accept the flag.
5. **Inventory candidate**: track the integration branch (`feat/iroh-transport`) — this wiki is essentially the design-doc layer for that branch. As the implementation lands, add a `verified_against:` field to the playbook.
