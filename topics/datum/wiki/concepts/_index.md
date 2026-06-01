---
title: Concepts
type: index
updated: 2026-06-01
---

# Concepts (11)

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [datum-protocol.md](datum-protocol.md) | OCEAN's custom encrypted protocol between gateway and DATUM Prime. Wire format reconstructed 2026-06-01: 32-bit packed header (22-bit length, 5-bit opcode, 3 encryption flags), libsodium ChaCha20-Poly1305 (NOT Noise), 8-job ring, 16-bit unique-identifier. Confidence: high. | datum-protocol, ocean, encryption, libsodium | 2026-06-01 |
| [gateway-data-flow.md](gateway-data-flow.md) | Runtime path: GBT → Stratum v1 → ASIC → DATUM Prime. SIGUSR1/HTTP NOTIFY for stale-work invalidation. Why ASIC and pool share counters disagree. | gbt, blocknotify, sigusr1, share-validation | 2026-05-28 |
| [stratum-usernames-and-modifiers.md](stratum-usernames-and-modifiers.md) | Bitcoin-address-as-username, three pool-passthrough modes, `~modifier-name` per-share revenue split, ASIC length quirks. | stratum, usernames, username-modifiers, asic | 2026-05-28 |
| [deployment-and-node-config.md](deployment-and-node-config.md) | Operator playbook: Knots-vs-Core, blockmaxsize/weight=3985000, build deps, Docker topologies, /NOTIFY caveats. OCEAN 5-step setup. | deployment, bitcoin-knots, docker, blocknotify | 2026-05-28 |
| [datum-history-and-motivation.md](datum-history-and-motivation.md) | Hughes' Origins-of-DATUM essay: Eligius lineage, censorship thesis, OCEAN's incentives, Dec 2025 alternate-template decommissioning. | datum, ocean, history, eligius, censorship-resistance | 2026-05-28 |
| [tides-payout.md](tides-payout.md) | TIDES as it intersects DATUM: 8×network-difficulty share log, generation-transaction payouts, `blockmaxweight=3985000` coinbase budget. | tides, payout, pplns, non-custodial | 2026-05-28 |
| [lightning-payouts.md](lightning-payouts.md) | OCEAN's optional BOLT12 Lightning payout rail. BIP-322 linking, 0.01048576 BTC fallback, Alby Hub v1.21.2+ incompatibility. (volatility: hot) | lightning, bolt12, payouts, bip-322 | 2026-05-28 |
| [gateway-internals-c-architecture.md](gateway-internals-c-architecture.md) | C gateway code-level reading: module map, threading model (epoll+pthread), the **queue seam** between SV1 server and DATUM client (the architectural finding for SV2-downstream rewriteability). | gateway, c-internals, threading, epoll, queue-seam | 2026-06-01 |
| [sv2-downstream-architecture.md](sv2-downstream-architecture.md) | SRI-based architecture for an SV2-downstream proxy: plain SV2 pool front (no JDS/JDC), separate Rust binary, `ExtendedChannel<DefaultJobStore>`, ~1500 LOC new vs ~9600 LOC SRI reuse (6:1 ratio). | sv2-proxy, sri, channels-sv2, handlers-sv2, architecture | 2026-06-01 |
| [ocean-sv2-stance-and-prior-art.md](ocean-sv2-stance-and-prior-art.md) | OCEAN docs explicitly reject SV2; Luke Dashjr "GBT has worked for years" quote on record; issue #146 is the only public SV2-DATUM bridge proposal (open 9 months, no Concept ACK). 56 forks of datum_gateway checked, none have SV2 code. | ocean, sv2, prior-art, luke-dashjr, electricalgrade | 2026-06-01 |
| [operator-value-and-threat-model.md](operator-value-and-threat-model.md) | Honest read: operator value is real but narrow — connectivity bridge for SV2-fleet miners who want OCEAN's TIDES. Per-hypothesis verdicts, threat-model map, what's gained vs regressed. | operator-value, threat-model, ocean, custody, censorship-resistance | 2026-06-01 |

## Categories

- **protocol**: datum-protocol.md
- **runtime**: gateway-data-flow.md
- **stratum**: stratum-usernames-and-modifiers.md
- **operations**: deployment-and-node-config.md, gateway-internals-c-architecture.md
- **history**: datum-history-and-motivation.md
- **payout**: tides-payout.md, lightning-payouts.md
- **sv2-proxy** (new 2026-06-01): sv2-downstream-architecture.md, ocean-sv2-stance-and-prior-art.md, operator-value-and-threat-model.md, gateway-internals-c-architecture.md
