---
title: "sv2-apps — SV2 pool role architecture, template-provider plug points, payout identity parsing"
source: "https://github.com/stratum-mining/sv2-apps"
type: repos
ingested: 2026-09-21
tags: [stratum-v2, sri, sv2-apps, pool-role, jds, jdc, translator-proxy, template-provider, bitcoin-core-ipc, capnproto, noise, config-precedence, user-identity, payout-parsing, bip385]
summary: "The SRI application layer: four independent role binaries (pool, jd-server, jd-client, translator) rather than one pool daemon, so trust boundaries can be split across operators — the miner can run a JDC to declare its own template while the pool runs a JDS to coordinate. Rust, MSRV 1.88.0, alpha. Two notable architectural features: (1) a pluggable template source selected by config — either a TCP (optionally Noise-encrypted) connection to an SV2 Template Provider, or a Unix-socket Cap'n Proto IPC connection to Bitcoin Core v30.2+ via the bitcoin-core-sv2 crate, which translates Core's IPC into the SV2 Template Distribution Protocol; (2) payout identity computed at runtime from the OpenMiningChannel user_identity string, with sri/donate, sri/solo/<addr>, and sri/donate/<pct>/<addr> forms and BIP-385 addr-descriptor validation. Config is dual-source: TOML overridden by POOL__-prefixed environment variables with double-underscore nesting, so a deployment can be entirely env-driven. Certificate validation is time-sensitive — a few seconds of clock drift produces InvalidCertificate, making NTP a hard dependency."
license: "MIT/Apache-2.0 (SRI project)"
repo_state: "Alpha as of 2026-09; MSRV 1.88.0"
credibility: high
credibility_score: 5
credibility_rationale: "Official reference implementation with configuration documentation; primary source. Alpha status means details are moving targets."
confidence: medium
confidence_rationale: "Config surface and role split are well documented and were consistently reported. Internals not covered by docs (async runtime, share persistence) were explicitly NOT verified — see open items."
research_round: 1
research_agent: technical
scope_note: "Deliberately limited to the APPLICATION layer. SV2 crate internals (codec, framing, noise, channels) belong to the stratum-sri topic and are not re-documented here."
extraction_note: "Subagent extraction from repo README and pool-config examples. Struct-level internals were not read. The claim that the async runtime is tokio was flagged by the agent as inference, not fact."
---

# sv2-apps — SV2 pool role architecture

**Stratum Reference Implementation (SRI)** — Rust, MSRV **1.88.0**, **alpha** —
https://github.com/stratum-mining/sv2-apps

## Roles as separate binaries

The single most consequential design decision: SV2's application layer is **four independent
binaries**, not one pool daemon with flags.

| Binary | Role |
|---|---|
| `pool/` | SV2 pool server; talks to downstream roles and to a template source |
| `jd-server/` (JDS) | Job Declarator Server — coordinates job declaration, maintains a synchronised mempool |
| `jd-client/` (JDC) | Job Declarator Client — lets a *miner* declare its own template |
| `translator/` | Translator Proxy — bridges SV1 miners to an SV2 pool |

**Why it matters.** Splitting JDS from JDC puts the trust boundary in the protocol rather than inside
one program: the miner runs the component that builds templates, the pool runs the component that
validates and accounts for them. This is the structural difference from every pool in the ckpool
lineage, where template construction is necessarily pool-side code. The cost is operational — four
processes, four configs, four upgrade paths.

## Pluggable template source

Selected by config, and this is the seam where Bitcoin Core's new mining interface enters pool
architecture:

**1. SV2 Template Provider** — `[template_provider_type.Sv2Tp]` with `address` and optional
`public_key`. TCP, optionally Noise-encrypted; the `public_key` is used to verify the connection.
Provider may be remote or local.

**2. Bitcoin Core IPC** — `[template_provider_type.BitcoinCoreIpc]` with `version` (30 or 31),
`network` (mainnet / testnet4 / signet / regtest), optional `data_dir`, **`fee_threshold`** (how much
fee change justifies a new template) and **`min_interval`** (floor on template update rate).
Connects over a **Unix socket** to **Bitcoin Core v30.2+** running locally. The `bitcoin-core-sv2/`
library crate translates Core's IPC into the **SV2 Template Distribution Protocol**. Requires the
`capnproto` system library.

Note what `fee_threshold` and `min_interval` are: the template-refresh control loop, exposed as
configuration. Every pool has this loop; most hard-code it (compare ckpool's 100 ms `blockpoll` and
30 s `update_interval`).

## Configuration precedence

Dual-source, which is worth recording because it shapes deployment:

- TOML files (`pool-config-*.toml`) supply the baseline.
- **Environment variables override TOML**, prefixed `POOL__`, with **double underscores for nesting**
  — e.g. `POOL__TEMPLATE_PROVIDER_TYPE__BITCOINCOREIPC__VERSION=31`.
- The pool **exits with an error if a mandatory parameter is absent from both sources** (fail fast,
  not fail silently with a default).
- Net effect: a fully environment-driven deployment is possible with no config file at all.

## Key parameters

- `authority_public_key` / `authority_secret_key` — the pool's Noise keys.
- `listen_address` — downstream endpoint (e.g. `0.0.0.0:3333`).
- `coinbase_reward_script` — descriptor for the pool's payout.
- `pool_signature` — coinbase signature string.
- Optional `[jds]` section to run an embedded Job Declaration Server with its own `listen_address`.
- `supported_extensions`, `required_extensions` — SV2 extension negotiation, comma-separated in env
  form.

## Payout identity from `user_identity`

Computed at runtime from the `user_identity` field of `OpenStandardMiningChannel` /
`OpenExtendedMiningChannel`, using a shared `stratum-apps` payout helper:

| `user_identity` pattern | Result |
|---|---|
| `sri/donate/[worker_name]` | **FullDonation** — 100% to pool |
| `sri/solo/<payout_addr>/[worker_name]` or `<payout_addr>[.worker_name]` | **Solo** — 100% to miner |
| `sri/donate/<percentage>/<payout_addr>/[worker_name]` | **Donate** — `percentage` (1–99) to pool, remainder to miner |
| Anything unrecognised | continue with pool payout |
| Malformed `sri/` prefix | `OpenMiningChannelError` |

Payout addresses are validated as **BIP-385 `addr()` descriptors**.

Architecturally this is a *string-encoded control channel* riding on an identity field — the same
pattern as V1's `account.worker` username convention, and the reason the neighbouring
`sv2-coinbase-identity` topic exists. Note it fails **open** (unrecognised → pool payout) except for
a malformed `sri/` prefix, which fails closed with an explicit error.

## Security and operations

- **NTP is a hard dependency.** Certificate validation is time-sensitive: "a few seconds" of drift
  triggers `InvalidCertificate`. A pool whose clock drifts loses the ability to authenticate its
  template provider — a failure mode with no analogue in the plaintext-V1 world.
- Noise encryption with `public_key` verification on template-provider connections.
- Shared `stratum-apps` utilities: TOML/coinbase config helpers, connection utilities (Noise, plain
  TCP, SV1), RPC client, key management, synchronisation primitives, payout verification.

## Open items — explicitly not established

- **Async runtime**: tokio is the obvious inference for a Rust async network service, but this was
  **not confirmed** in the documentation.
- **Share persistence**: no persistence layer is documented. Whether share accounting is in-memory,
  file-based, or database-backed is **unknown**. For a reference implementation this is a
  consequential gap — it is the single biggest architectural question about the SV2 pool role.
- **Connection scaling**: no documented connection limits or benchmarks.
- No measured comparison against ckpool or any other implementation.
