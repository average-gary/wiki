---
title: Wiki Hub
type: hub
created: 2026-05-20
updated: 2026-05-28
---

# Wiki Hub

LLM-compiled knowledge base. Topic wikis live under `topics/`.

## Conventions

- **The hub is publishable.** Treat `~/wiki/` as if it could be open-sourced at any time. Anything that can't go public does not belong here.
- **Company-proprietary, employer-confidential, or repo-specific research belongs in a repo-local `.wiki/`**, not in the hub. This includes: assessments of internal repos, deployment plans tied to internal infra, ADR/SPEC commentary that isn't already public, forward-looking gap analyses naming an employer.
- **Pattern:** `<repo>/.wiki/` next to the code it documents. Register it in `wikis.json` under `local_wikis` with a `sensitivity` field if proprietary. Existing examples: [compost-marketplace](#local-topics) (fGw), [pool-v4-infra](#local-topics) (MARA, moved from hub 2026-05-22).
- **When in doubt, default local.** It's easier to promote a local wiki to the hub later than to redact a hub topic after publishing.

## Active Topics

- [gtx-1060-headless-ai-server](topics/gtx-1060-headless-ai-server/_index.md) — MSI GS63VR (Pascal GTX 1060 6GB mobile) as a headless Ubuntu 22.04 box for local audio transcription + diarization + farm vision tasks.
- [rust-multi-platform](topics/rust-multi-platform/_index.md) — Survey of Rust's multi-platform surfaces: mobile FFI, desktop cross-compile, UI frameworks, WASM.
- [sv2-p2pool-integration](topics/sv2-p2pool-integration/_index.md) — How p2poolv2 (decentralized share-chain pool) would integrate with sv2-apps (Stratum V2 reference implementation).
- [bitcoin-mining-payout-schemas](topics/bitcoin-mining-payout-schemas/_index.md) — Mining-pool payout/accounting schemas: PPLNS, FPPS, PPS+, PPLNS-JD, hashpool.dev (Cashu), btc++ tracks, p2pool / p2poolv2.
- [pf2e-worldbuilding-tool](topics/pf2e-worldbuilding-tool/_index.md) — Worldbuilding tool for Pathfinder 2e as a desktop + LLM app: PF2e SRD/ORC, tool landscape (Kanka/World Anvil/Foundry), desktop stacks, LLM integration, world data modeling.
- [pf2e-biblical-reskin](topics/pf2e-biblical-reskin/_index.md) — Christian Biblical worldview reskin of Pathfinder 2e Remaster lore: prior Christian TTRPGs, Remaster fit for monotheism, cosmology/angelology mapping, the magic-vs-miracle problem, class/ancestry reskin.
- [frederick-county-va-crime-stats](topics/frederick-county-va-crime-stats/_index.md) — Neutral compilation of crime statistics for Frederick County, Virginia (Winchester area). FBI UCR/NIBRS, VA State Police, FCSO, Winchester PD, Census. Trends, categories, jurisdictional breakdown.
- [ldk-server](topics/ldk-server/_index.md) — LDK Server: a ready-to-use Lightning Network node binary built on top of LDK Node, exposing a gRPC (Protocol Buffers) API. Architecture, deployment, gRPC surface, comparison vs LND/CLN/Eclair.
- [home-garden-pruning](topics/home-garden-pruning/_index.md) — Pruning playbooks for the user's home garden: Kristin and BlackGold sweet cherries, thornless blackberries, Knock Out shrub roses, raspberries, blueberries.
- [open-source-logos-suite](topics/open-source-logos-suite/_index.md) — Engineering an OSS alternative to Logos Bible Software: feature surface, OSS prior art, open biblical data, client architecture, and decentralized infrastructure (IPFS, libp2p, Iroh, ATProto, Nostr, Hypercore) for text distribution and user-data sync.
- [cdk-ldk-lnurl](topics/cdk-ldk-lnurl/_index.md) — Deploying LNURL endpoints (LNURL-pay, LNURL-withdraw, Lightning Address) using Cashu Dev Kit (`cashubtc/cdk`) with the bundled LDK Node lightning backend. cdk-mintd topology, lightning-backend feature flags, LDK Node embedding, persistence/channel management, LNURL surface design.
- [fedimint](topics/fedimint/_index.md) — Fedimint federated Chaumian e-cash protocol: architecture (consensus/mint/wallet/lightning/custom modules), guardians, threshold custody, Lightning gateways, multi-currency / multi-denomination support research.
- [sv2-coinbase-identity](topics/sv2-coinbase-identity/_index.md) — Thesis: can SV2 `user_identity` be used by the Pool to embed a per-miner unique tag in the coinbase, without Job Declaration? Verdict: partially supported (high). SRI's `JobFactory` already takes a `miner_tag` parameter; the Pool constructor passes `None`. Spec is silent (not anti-spec). Trust-asserted, not verifiable.
- [stratum-sri](topics/stratum-sri/_index.md) — Stratum Reference Implementation (SRI) low-level repo (`stratum-mining/stratum`): the SV2 crate suite (`binary-sv2`/`codec-sv2`/`framing-sv2`/`noise-sv2`/`channels-sv2`/`handlers-sv2`/`parsers-sv2`/`extensions-sv2`/`subprotocols`), the `stratum-core` workspace umbrella, and `stratum-translation` (SV1↔SV2). Workspace layout, MSRV, release flow.
- [sv1-upstream-reverse-translator](topics/sv1-upstream-reverse-translator/_index.md) — Reverse-direction Stratum translator: SV2 stack (miner / proxy / pool-front) talking to a Stratum V1 upstream pool. Inverse of the SRI translator-proxy. SV2↔SV1 primitive mapping, lost SV2 capabilities, prior art (Braiins farm-proxy, P2Pool SV1 frontend), SRI architectural placement (`channels-sv2`/`roles_logic_sv2`), and use cases (pool inertia, gradual migration, hashrate brokers, multi-pool failover).
- [datum](topics/datum/_index.md) — OCEAN's DATUM (Decentralized Alternative Templates for Universal Mining) protocol and gateway, plus the engineering question of an SV2-downstream DATUM-capable proxy. Renamed from `datum-gateway` 2026-06-01 with scope broadened to include SV2-front proxy design (replacing the gateway's SV1-to-ASIC leg with SV2 channels while keeping DATUM upstream to OCEAN).

## Local Topics

- **compost-marketplace** at `/Users/garykrause/repos/fGw/.wiki` — Powder Keg WV chapter Farming God's Way compost marketplace on Nostr. (`fGw` repo)
- **pool-v4-infra** at `/Users/garykrause/repos/pool-v4-infra/.wiki` — MARA Stratum V2 deployment infrastructure. K8s-vs-alternatives research arc, repo assessments, M1 materialize plan, Stack A parallel playbook. *Sensitivity: company-proprietary.* Moved from hub 2026-05-22.
- **garrys-mod** at `/Users/garykrause/repos/implementations/garrys-mod/.wiki` — `average-gary/bitcoin-garrys-mod` Bitcoin Core fork: jamesob CTV/CSFS + Sjors SV2 Template Provider (`sv2-tp-0.1.19`) + testnet4 activation. First plan: rebase onto bitcoin/bitcoin master HEAD (5486ef8cc2).

## Archived Topics

(none)

## Logs

- [log.md](log.md) — hub-level activity log
