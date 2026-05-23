---
title: Integration paths — p2poolv2 ↔ sv2-apps
type: topic
created: 2026-05-22
updated: 2026-05-22
verified: 2026-05-22
volatility: hot
confidence: high
sources:
  - "[[raw/repos/2026-05-22-p2poolv2-module-map|p2poolv2 module map]]"
  - "[[raw/repos/2026-05-22-sv2-apps-repo|sv2-apps repo]]"
  - "[[raw/papers/2026-05-22-sv2-spec-job-declaration-protocol|SV2 spec: JDP]]"
  - "[[raw/articles/2026-05-22-p2poolv2-wiki-using-stratum-v2|p2poolv2 wiki: Using Stratum v2]]"
  - "[[raw/articles/2026-05-22-p2poolv2-wiki-comparison-datum-sv2|p2poolv2 wiki: Comparison with DATUM and SV2]]"
---

# Integration paths — p2poolv2 ↔ sv2-apps

The synthesized answer to "how would we integrate p2pool into sv2-apps?"

## Where the two stacks meet

```
                                      ┌────────────────────────────────────┐
                                      │  p2poolv2_lib                      │
   sv2-apps                           │                                    │
   ┌──────────────────────────┐       │   shares::handle_stratum_share     │
   │ pool/PoolSv2             │       │             ▲                      │
   │   ChannelManager         │       │             │  (single entry)      │
   │   downstream server      │       │             │                      │
   │                          │       │   stratum/server.rs (V1)           │
   │ jd-server/JDS            │       │   stratum/zmq_listener.rs (Core)   │
   │   ┌────────────────────┐ │       │                                    │
   │   │ JobValidationEngine│◀┼───────┼─── P2poolV2Engine impl             │
   │   │  (trait)           │ │       │             │                      │
   │   └────────────────────┘ │       │             ▼                      │
   │                          │       │   shares::validation               │
   │ stratum-apps             │       │   shares::chain (libp2p gossip)    │
   │   TemplateProviderType   │       │   accounting (top-N + swap)        │
   └──────────────────────────┘       └────────────────────────────────────┘
```

Three plug-points exist (see [[../concepts/sv2-integration-surface]] for trait-level detail). They yield four candidate integration paths.

## Path A — p2poolv2 as JDS backend (`JobValidationEngine` impl)

**Lowest friction, highest leverage.**

p2poolv2 implements sv2-apps's `JobValidationEngine` trait. A standard sv2-apps JDS hosts the SV2 wire protocol; p2poolv2 backs it with share-chain validation.

### What p2poolv2 builds
- New crate `p2poolv2_jds_engine` with one struct implementing `JobValidationEngine`
- Adapter that maps:
  - `DeclareMiningJob` → `shares::validation::validate_block_template`
  - `PushSolution` → `shares::handle_stratum_share` + Bitcoin block submission via `bitcoindrpc`
  - `SetCustomMiningJob` → analog for SV2 mining-protocol channel
- Token allocation (`JdToken`) keyed on share-chain miner identity (libp2p PeerId or coinbase script)

### What sv2-apps does
Nothing. Trait is already pluggable. `pool-apps/pool/src/lib/mod.rs` already accepts a `dyn JobValidationEngine` (see PoolSv2's embedded JDS path).

### Pros
- Zero changes to sv2-apps
- p2poolv2 keeps its share-chain consensus authority
- SV2 miners (any JDC) can point at a p2poolv2 deployment unchanged
- Cleanest separation of concerns

### Cons
- p2poolv2 doesn't get to manage SV2 mining channels itself — JDS sits in front
- Token-allocation semantics need design work (how does the share chain authenticate JDC identity?)
- Doesn't address [[../concepts/p2poolv2#differentiation-from-sv2--datum|p2poolv2's complaint]] that SV2 keeps share accounting centralized — *unless* every p2poolv2 node runs its own JDS, in which case it does

### Verdict
**Strongly recommended starting point.** Smallest delta, biggest reuse, and aligns with [[../concepts/p2poolv2|p2poolv2]]'s own "Using Stratum v2 — remote scenario" wiki page.

## Path B — p2poolv2 terminates SV2 mining channels itself

Add a sibling `stratum_v2/` module to `p2poolv2_lib` that mirrors the existing V1 `stratum/` module: terminates SV2 mining-protocol channels, runs Noise handshake, manages extranonce, and funnels valid shares into the same `shares::handle_stratum_share` entry point.

### What p2poolv2 builds
- Add deps on stratum-core's protocol crates (`binary_sv2`, `roles_logic_sv2`, etc.)
- New `stratum_v2/server.rs`, `stratum_v2/session.rs`, `stratum_v2/work/`
- Optionally: own JDS implementation embedded (bypass sv2-apps's JDS entirely)

### What sv2-apps does
Nothing required. p2poolv2 becomes a peer SV2 stack.

### Pros
- p2poolv2 owns the full miner-facing surface
- Matches the [[../concepts/p2poolv2|p2poolv2 wiki "local scenario"]] (ASICs connect directly via SV2 channels, replacing nginx proxies)
- Maximum control over the share-flow

### Cons
- Significant SV2 surface to implement
- Duplicates sv2-apps's pool-apps work
- Higher maintenance burden — protocol changes hit two places
- Loses the "use any SV2 miner unchanged" property of Path A

### Verdict
**Phase 2 only.** Don't do this before Path A is shipped and stable.

## Path C — p2poolv2 as upstream Template Provider

p2poolv2 publishes templates to sv2-apps's TP socket. sv2-apps's `TemplateProviderType::Sv2Tp` already handles this case.

### What p2poolv2 builds
- TDP server — `NewTemplate`/`SetNewPrevHash` emission on share-chain tip changes
- Solution-receiving handler

### What sv2-apps does
Nothing. `Sv2Tp` variant is already supported in `pool-apps/pool/src/lib/mod.rs`.

### Pros
- p2poolv2 controls template content and tx-selection policy
- Easy to A/B against bitcoin-core-sv2

### Cons
- **Wrong shape.** TDP gives templates to a pool; it doesn't give a pool a share-chain. The decentralized-share-accounting story isn't told here.
- Confuses roles — p2poolv2 is *not* a template provider; it's a pool-with-a-share-chain.

### Verdict
**Not recommended as the integration story.** Possibly useful as a *secondary* feature for testing.

## Path D — wholly new SV2 role

Define a new SV2 role (e.g., "Decentralized Share Accountant") and propose it as a sv2-spec extension under doc 09 (Extensions framework).

### Pros
- Honest about the architectural difference
- Documents the integration as a first-class protocol concept

### Cons
- Long timeline (spec process)
- Needs ecosystem buy-in
- Path A already gives 90% of the value with zero spec work

### Verdict
**Long-term followup.** Worth proposing once Path A is live and a working reference exists.

## Recommended sequence

1. **Phase 1** — Path A: implement `JobValidationEngine` for p2poolv2. Ship a `p2poolv2_jds_engine` crate that passes sv2-apps integration tests.
2. **Phase 2** — Each p2poolv2 node optionally embeds its own JDS using the engine, matching the project's "every miner has full visibility on share accounting" thesis.
3. **Phase 3** — Path B for performance/local-deployment scenarios (no proxy, ASICs-direct via SV2).
4. **Phase 4** — Optional Path D: codify the architecture as a sv2-spec extension once production-validated.

## Open design questions

1. **Share accounting reconciliation.** SV2's `SubmitSharesExtended` produces flat per-channel share counts. p2poolv2's chain-with-uncles has uncle-weighted accounting. The mapping is non-trivial and not formally specified anywhere yet — likely the highest-value formal-methods work. (See [[../theses/share-accounting-isomorphism]] — TBD.)
2. **JDC identity → coinbase output.** SV2's authority key vs p2poolv2's payout-script. How does a JDC announce "pay my shares to this script" in a way the share-chain validates?
3. **Token revocation under share-chain reorg.** If a JDS issues `AllocateMiningJobToken` and the share-chain reorgs the underlying tip, what happens to in-flight tokens?
4. **Coinbase output negotiation.** SV2's `CoinbaseOutputDataSize` interacts with p2poolv2's `share_commitment.rs` and `coinbaseaux_flags.rs` — how is the available coinbase budget split between p2pool's payouts (top-N + commitments) and SV2 metadata?
5. **Top-N cutoff under SV2 channel mix.** Direct-coinbase to top-N miners is straightforward when miners = p2poolv2-native peers. With SV2 miners arriving via a JDC, how is the top-N set determined when a single JDS may front many channels?

## Risks (from [[why-decentralized-pools-struggle|the contrarian thread]])

- Variance economics still dominate: SV2 + p2poolv2 doesn't change the math that keeps miners on FPPS pools.
- Bandwidth ceiling: ajtowns argues 6-second share intervals + full tx data don't scale at pool size.
- Adoption ceiling: even Ocean (well-funded, mainstream-press-covered) is stagnating.
- Policy alignment: at >30% hashrate, decentralized pools force Bitcoin Core relay-policy alignment — a centralization vector.

## See also

- [[../concepts/p2poolv2]]
- [[../concepts/sv2-integration-surface]]
- [[../concepts/braidpool]]
- [[../concepts/ocean-datum]]
- [[why-decentralized-pools-struggle|Why decentralized pools struggle]]
