---
title: "OCEAN's SV2 stance and prior art for a DATUM ↔ SV2 bridge"
category: concept
sources:
  - raw/articles/2026-06-01-path1-issue-146-sv2-support.md
  - raw/articles/2026-06-01-path1-ocean-org-survey.md
  - raw/articles/2026-06-01-path4-bitcoin-core-rfc-31002-datum-mining-interface.md
  - raw/articles/2026-06-01-path4-ocean-docs-sv2-rejection.md
  - raw/articles/2026-06-01-path4-electricalgrade-sv2-c-library.md
  - raw/articles/2026-06-01-path4-blockspace-media-datum-vs-sv2.md
  - raw/articles/2026-06-01-path4-atlas21-datum-launch-luke-dashjr-quotes.md
  - raw/articles/2026-06-01-path4-prior-art-enumeration-and-notable-absences.md
created: 2026-06-01
updated: 2026-06-01
tags: [ocean, sv2, prior-art, datum, luke-dashjr, electricalgrade, sri-engagement-gap]
confidence: high
---

# OCEAN's SV2 stance and prior art for a DATUM ↔ SV2 bridge

Negative-finding territory. The headline: **OCEAN has explicitly rejected SV2 in print, no working third-party bridge exists, and SRI has zero documented engagement with DATUM.** The market signal for an SV2-DATUM bridge is weak.

## OCEAN's stance — quoted

OCEAN's official docs (`ocean.xyz/docs/datum`):

> "Initially, we considered Stratum V2 (Sv2)... technical challenges convinced us that a new framework was necessary."

> DATUM was "built from scratch with decentralized template construction in mind"; SV2's "decentralized elements are bolted onto the original centralized design."

Luke Dashjr (founder, Atlas21 launch coverage 2024-10-02):

> "The launch of DATUM is a pivotal moment for the Bitcoin mining community. We're moving block creation back to the individual miners, just as it was intended."

Luke Dashjr (developer, on `bitcoin/bitcoin#31002`, 2024-10-05):

> "Bitcoin Core has been working toward trying to centrally dictate mining policy, so should really not be used for mining. OCEAN/DATUM's goal is to decentralise mining, not merely switch the central dictator from Bitmain/Foundry to Bitcoin Core. That being said, there is already a generic/standard mining interface: getblocktemplate. **It has worked for years and nothing additional is needed for DATUM.**"

Bitcoin Mechanic (OCEAN, on Blockspace Media 2024-12-22):

> "DATUM is just an extra layer on top of legacy SV1 to build blocks by miners."

This last quote is **structurally inconsistent** with OCEAN's docs framing (which positions DATUM as a from-scratch alternative). The discrepancy reflects the ad-hoc evolution of OCEAN's messaging between launch and steady-state. Don't read either as a definitive policy statement; read both as evidence that OCEAN is not interested in adopting SV2.

**See**: [[../../raw/articles/2026-06-01-path4-ocean-docs-sv2-rejection]], [[../../raw/articles/2026-06-01-path4-bitcoin-core-rfc-31002-datum-mining-interface]], [[../../raw/articles/2026-06-01-path4-atlas21-datum-launch-luke-dashjr-quotes]], [[../../raw/articles/2026-06-01-path4-blockspace-media-datum-vs-sv2]].

## Prior-art enumeration

| Question | Answer | Evidence |
|---|---|---|
| SV2-front DATUM gateway built? | **No** | All 56 forks of `OCEAN-xyz/datum_gateway` checked; zero have SV2 code |
| Public proposal for one? | **Yes — open issue** | [`OCEAN-xyz/datum_gateway#146`](https://github.com/OCEAN-xyz/datum_gateway/issues/146) opened by `electricalgrade` 2025-08-23. Scopes native SV2 `OpenExtendedMiningChannel` / `SetNewPrevHash` / `NewExtendedMiningJob` / `SubmitSharesExtended` inside the gateway. luke-jr (maintainer) responded preferring a pkg-config shared library; **no formal Concept ACK after 9 months**. |
| Working SV2-DATUM C/Rust library? | **Partial / stalled** | [`electricalgrade/sv2`](https://github.com/electricalgrade/sv2): Noise + SetupConnection only, no DATUM bridge, no license, last push 2025-09-21. |
| SRI repo engagement with DATUM? | **No** | Zero substantive issues/PRs/discussions in `stratum-mining/{stratum, sv2-spec, sv2-apps}` mentioning DATUM, OCEAN, or TIDES |
| Braidpool / hashpool / p2pool DATUM-aware? | **No** | Zero matches in any of those repos |
| Bitcoin Optech editorial on DATUM-SV2? | **No** | Newsletters mention SV2 and DATUM separately, never together |
| OCEAN blog post about SV2? | **No blog at all** | `ocean.xyz/blog` returns 404 |
| Conference talks bridging the two? | **No** | TABConf 6/7 and Baltic Honeybadger 2025 (Halliburton/Sazmining) cite both as background, don't bridge |

**See**: [[../../raw/articles/2026-06-01-path4-electricalgrade-sv2-c-library]], [[../../raw/articles/2026-06-01-path4-prior-art-enumeration-and-notable-absences]].

## Issue #146 — the canonical reference

`OCEAN-xyz/datum_gateway#146` is the only public, named, sourced SV2-DATUM bridge proposal. Submitter is `electricalgrade` (whose stalled `sv2` repo is the only existing prior-art code). The proposal's stated scope:

- Native SV2 in the gateway (in-process, not external proxy).
- `OpenExtendedMiningChannel`, `SetNewPrevHash`, `NewExtendedMiningJob`, `SubmitSharesExtended`.
- **TDP and JDP explicitly out of scope** — "unnecessary in DATUM" — confirming the architectural pattern that any SV2-DATUM bridge skips Job Declaration and operates as a plain SV2 pool front (see [[sv2-downstream-architecture#recommended-model-plain-sv2-pool-front-no-jds-no-jdc|model (a)]]).

luke-jr's response prefers a **pkg-config shared library** approach over an in-tree integration — soft pushback toward "go build it as an external project." After 9 months no Concept ACK.

**See**: [[../../raw/articles/2026-06-01-path1-issue-146-sv2-support]].

## Notable absences

1. **No SRI-side DATUM consideration** — the obvious bridge vehicle has zero documented engagement. The most striking finding.
2. **No OCEAN blog** — `ocean.xyz/blog` returns 404. OCEAN's only public technical surface is the docs page, X/Twitter, and the gateway repo.
3. **No working third-party proxy** — out of 56 forks of `datum_gateway` and the entire SRI ecosystem, nobody has shipped or even started a working SV2-DATUM bridge. `electricalgrade/sv2` is the closest and is stalled.
4. **No demand evidence** — no Bitcoin Optech editorializing, no operator-side issue spam asking for SV2, no commercial product. Market signal is weak.
5. **No Braidpool DATUM mention** despite Braidpool being the most aligned-in-spirit project (decentralized pool research).
6. **Block Inc. hedge** — funds both OCEAN/DATUM (via Luke Dashjr) and Proto Fleet/SV2; neither bridges to the other.

## Implications for an implementer

- **Spec ground**: weak. There is no canonical "DATUM ↔ SV2 bridge" specification. Issue #146 is the closest thing.
- **Code ground**: greenfield. No prior art to merge into; no naming or repo conflicts.
- **Political ground**: cool to negative. OCEAN founder is on record dismissing SV2 as needed; SRI has not engaged with DATUM.
- **Path of least resistance**: build it as an external Rust binary (matches luke-jr's pkg-config-library framing); cite issue #146 in any PR or design doc; expect to operate solo until adoption forces engagement.

## See also

- [[datum-protocol]] — the upstream half (closed-source on the pool side)
- [[sv2-downstream-architecture]] — the recommended bridge architecture
- [[operator-value-and-threat-model]] — who would deploy this anyway
- [[../../sv1-upstream-reverse-translator/_index|sv1-upstream-reverse-translator]] — the generic version of this problem (any SV1 pool, not just OCEAN)
