---
title: "electricalgrade/sv2 — the actual prior-art SV2 C library targeting DATUM (stalled)"
source: "https://github.com/electricalgrade/sv2"
type: articles
tags: [datum, sv2, prior-art, electricalgrade, c-implementation, noise-protocol, stalled, stratum-v2]
summary: "electricalgrade/sv2 is the in-the-wild implementation behind issue #146 — a C library that performs the SV2 Noise XX/NX handshake and SetupConnection exchange, scaffolds mining_dispatch, and is explicitly stated as targeting DATUM integration ('This will be used for DATUM to support SV2 mining protocol'). Last commit 2025-09-21 (default branch `main`, 79 KB, MIT-unlicensed). Mining channel ops, share submission, and DATUM bridge are all incomplete. Repository contains noise-server/, legacy-src/, pool_server/ (mock OCEAN pool), sv1_to_sv2_bridge/, tests/, doc/. Six stars. The single most concrete prior-art artifact for SV2-DATUM integration that exists publicly. Stalled for 8+ months."
confidence: high
ingested: 2026-06-01
ingested_by: path4
quality_score: 4
canonical_url: "https://github.com/electricalgrade/sv2"
---

# electricalgrade/sv2 — actual prior-art SV2-for-DATUM library

When path1 covered issue #146, the implementation referenced ("Plan is to reuse as much as possible the existing framework... I also wrote a simple translator (in python). I ran a simple cpu miner and was able to connect to this translator.") was held off-repo. This article ingests the actual repository.

## Repository facts

| Field | Value |
|---|---|
| URL | https://github.com/electricalgrade/sv2 |
| Description | (none) |
| Language | C |
| Default branch | `main` |
| Last push | 2025-09-21T15:39:25Z |
| Size | ~79 KB |
| License | NONE (no license file) |
| Topics | (none) |
| Stars | 6 |
| Branches | 1 (`main`) |

**License is missing.** A 2025 release with no LICENSE file is effectively all-rights-reserved by GitHub's TOS — operationally unusable without the author's permission, even though it's public. This matters if anyone wants to fork it for a downstream SV2 proxy.

## Stated DATUM purpose

From the README (verbatim quote captured via WebFetch):

> "This will be used for DATUM to support SV2 mining protocol. The main focus right now is a Noise-based pool server and client."

So the project is explicitly the SV2-for-DATUM scaffolding the wiki topic asks about — but built externally to OCEAN, by a single contributor.

## Repo structure

```
electricalgrade/sv2/
├── noise-server/       # Active work — Noise handshake + SV2 SetupConnection
│   └── src/
│       ├── sv2_pool_server.c     # TCP listener doing Noise + SetupConnection
│       ├── noise_client.c        # Client doing initiator-side Noise + SetupConnection request
│       ├── sv2_noise.{c,h}       # Noise wrapper helpers (XX/NX, encrypt-after-split)
│       ├── mining_dispatch.{c,h} # Post-SetupConnection dispatcher (minimal)
│       ├── sv2_wire.{c,h}        # Length-prefixed frame builder/parser
│       ├── sv2_common.{c,h}      # SetupConnection encode/decode
│       ├── sv2_mining.{c,h}      # Mining message codecs (channel open, jobs, shares)
│       └── Makefile              # Builds against noise-c
├── legacy-src/         # Pre-Noise prototype (archived)
├── pool_server/        # Mock OCEAN pool + testing helpers
├── sv1_to_sv2_bridge/  # SV1 ↔ SV2 translation prototype
├── tests/              # Test harnesses
└── doc/                # Design notes
```

## Implementation status (per noise-server README)

Implemented:

> "perform a **Noise** handshake (default **XX**, optional **NX**), then exchange the **SV2 `SetupConnection` ↔ `SetupConnection.Success`** messages"

NOT implemented:

> "Only the **SV2 SetupConnection** exchange is implemented post-handshake. No channel open / job dispatch yet."

Roadmap (per parent README):

| Status | Item |
|---|---|
| Done | Noise XX/NX handshake working |
| Done | SetupConnection exchange |
| Done | Minimal mining dispatcher integrated (skeleton only) |
| In-progress | Client mining messages (`OpenStandardMiningChannel`, `SubmitSharesStandard`) |
| In-progress | Datum bridge integration (planned) |
| Pending | Vardiff and accounting |
| Pending | Live miner tests |

## Critical gap: no DATUM upstream

There is no `datum_client.c` in this tree, nor any DATUM Protocol opcode handling. The "DATUM bridge" is **planned** but unstarted. The currently-functioning code paths terminate at `sv2_pool_server` (a mock pool). To translate SV2 → DATUM upstream, all of:

- DATUM `0x00` handshake (libsodium key exchange)
- DATUM `0x10`/`0x11` coinbaser exchange
- DATUM `0x20`/`0x21`/`0x22` block-template gossip
- DATUM `0x27` share submission with DATUM extranonce conventions
- DATUM `0x50` job-validation subcommands
- DATUM `0x60` notification opcode

...would need to be added on top of what's there. The Noise/SetupConnection scaffolding is reusable; the DATUM upstream is greenfield.

## Author dependencies

electricalgrade also maintains:

- `electricalgrade/datum_gateway` — fork of OCEAN-xyz's, last push 2025-08-17 (one month before sv2 repo's last push). Single branch (`master`). No SV2 work landed in the fork.
- `electricalgrade/btc_datum` — Docker compose for Bitcoin Knots + datum_gateway (shell scripts). Operator-side glue.
- `electricalgrade/datum_dash` — Flask/Python monitoring dashboard for datum_gateway.
- `electricalgrade/bitcoin` — fork of bitcoinknots/bitcoin.

So electricalgrade is a serious DATUM operator with a full operational stack who tried to add SV2 and stalled. This is a single point of failure for the whole "prior art exists" claim.

## Why this matters for the SV2-downstream-DATUM-proxy

1. **The only existing prior-art is a 79 KB single-author C library that hasn't been touched in 8+ months.** This is *not* a robust competing implementation. The SRI Rust stack (this wiki topic's intended foundation) is multiple orders of magnitude more mature.
2. **The hard part is acknowledged but not done.** Even electricalgrade — who has the SV2 protocol scaffolded and a Python translator working — has not written the SV2↔DATUM mapping. Confirms that the "interesting" engineering is the protocol bridging, not the SV2 wire stuff.
3. **License absence is a forking blocker.** Anyone wanting to reuse this code must contact electricalgrade for a license grant. The SV2 scaffolding code is not a usable foundation.
4. **Direction of travel matches issue #146.** Architecture diagram (`SV2 pool ← SV2 Translator ← SV1 Miner`) suggests the testing path is SV1-hardware-upstream — useful for verification but inverse of the wiki topic's target (`SV2 hardware downstream → DATUM upstream`).
5. **The stall is signal.** Either electricalgrade hit a hard problem (likely), pivoted attention (possible), or got discouraged by lack of OCEAN-side concept ACK (probable). Any new attempt at this work should anticipate the same friction points.

## Notable absences

- No CI, no GitHub Actions config visible.
- No issues filed against the repo (zero issue traffic).
- No PRs (zero PR traffic).
- No release tags.
- No second contributor.
- No mention of this repo on OCEAN side.
- No SRI citations or imports — electricalgrade is rolling SV2 from scratch in C, not using the canonical Rust SRI library.

## Rabbit-hole leads

- electricalgrade's GitHub bio / X handle if discoverable — what's their day job? Are they an OCEAN miner, an independent dev, or pseudonymous?
- Has electricalgrade posted to Delving Bitcoin, bitcoin-dev, or Mining Discord about this work?
- Compare `noise-server/sv2_mining.c` against SRI's `roles-logic-sv2` codec — does electricalgrade's framing match SRI's serialization, or have they diverged?
- The `sv1_to_sv2_bridge/` directory in particular is a prior-art artifact for the *opposite* translation (SV1 miner → SV2 pool). Is the code reusable in either direction?

## Cross-references

- [Issue #146 in datum_gateway](https://github.com/OCEAN-xyz/datum_gateway/issues/146) (path1 article) — the public proposal that this repo backs.
- See path4's `bitcoin-core-rfc-31002` article — confirms OCEAN-side political non-engagement that likely contributed to this stall.

## Source

- API metadata fetched 2026-06-01 via [api.github.com/repos/electricalgrade/sv2](https://api.github.com/repos/electricalgrade/sv2).
- README + structure read via WebFetch on the repo root and `/noise-server/README.md` and `/tree/main/noise-server` paths.
