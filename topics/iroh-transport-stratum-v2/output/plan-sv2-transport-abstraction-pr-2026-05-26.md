---
title: "Plan: SV2 transport abstraction — upstream PR to sv2-apps"
type: plan
format: roadmap
sources:
  - wiki/topics/sv2-iroh-transport-playbook.md
  - wiki/concepts/fedimint-as-reference.md
  - wiki/topics/why-iroh-for-sv2.md
  - wiki/topics/risks-and-tradeoffs.md
  - wiki/concepts/sv2-noise-nx.md
  - wiki/concepts/sv2-framing.md
  - wiki/concepts/erosion-attack.md
generated: 2026-05-26
target_repo: stratum-mining/sv2-apps
target_branch: main
pr_branch: feat/transport-abstraction
status: draft
---

# Plan: SV2 transport abstraction — upstream PR to sv2-apps

> Generated from [iroh-transport-stratum-v2](~/wiki/topics/iroh-transport-stratum-v2/_index.md) wiki (7 articles consulted)

## Executive Summary

Land the **transport-agnostic abstraction layer** from our `feat/iroh-transport`
work as a pure refactor PR upstream to `stratum-mining/sv2-apps:main`. **No iroh,
no new transports, no behavior change** — just a `Sv2Connector` / `Sv2Listener`
trait pair, TCP implementations that wrap existing `connect_with_noise` /
`accept_noise_connection` unchanged, a sibling `NoiseGenericStream<S, M>` over
`AsyncRead + AsyncWrite` (with `noise_stream.rs` left at zero diff), and the
9 listener / 5 dial call-site refactor. The PR's value proposition is **code
health** (single switch point for transport ops, fewer hardcoded
`TcpListener::bind` / `TcpStream::connect` sites, cleaner test seams) — iroh
follows in a separate PR.

## Architecture Decisions

### Decision 1: Pure-refactor scope (no iroh)

**Context**: [Fedimint as reference implementation](~/wiki/topics/iroh-transport-stratum-v2/wiki/concepts/fedimint-as-reference.md) documents that
Fedimint runs `IP2PConnector` with `mod tls; mod iroh;` side-by-side — but the
trait itself **predates** Fedimint's iroh integration and has standalone value
as a transport-swap seam. SRI Discussion [#1935](https://github.com/stratum-mining/stratum/discussions/1935)
was authored 2025-10-03 and remains an open Idea — there's appetite upstream
for the abstraction layer even if iroh itself takes longer to converge.

**Options considered**:
- A — Pure abstraction (TCP only, no iroh). Lowest review friction.
- B — Abstraction + `Sv2Target` enum stub for iroh. Signals intent.
- C — Abstraction + iroh in one PR. Highest review burden.

**Decision**: **Option A**. The abstraction must justify itself on code-health
grounds alone. Once it lands, iroh ships as a follow-up PR that adds an
`Sv2Connector::Iroh` impl as additive code — no churn to the trait shape.

**Consequences**:
- Smaller PR (~12 files, mostly TCP-side wrapping).
- No `PreferTransport` enum, no `CompositeSv2Connector`, no
  `Sv2Target::IrohThenTcp` variant — those land with iroh.
- The `Sv2Target` enum starts as a single-variant `Tcp { addr, authority_pubkey }`.
  This intentionally makes the enum future-extensible (`#[non_exhaustive]`)
  without committing to specific future transports.

### Decision 2: NoiseGenericStream as a sibling file (not in-place generalization)

**Context**: The [integration playbook](~/wiki/topics/iroh-transport-stratum-v2/wiki/topics/sv2-iroh-transport-playbook.md)
§"Architectural approach" — "Rebase posture" subsection — explicitly chose
the sibling-file approach over in-place generalization for rebase-friendliness.
The user re-confirmed during interview ("Trait+sibling generic file with doc
comments").

**Options considered**:
- A — Trait only; leave `noise_stream.rs` and `NoiseTcpStream` alone; TCP impl
  wraps existing API without any stream-layer change.
- B — Add `noise_generic_stream.rs` sibling with `NoiseGenericStream<S, M>` over
  `AsyncRead + AsyncWrite + Unpin + Send`. Existing `noise_stream.rs` zero diff.
- C — Generalize `noise_stream.rs` in place (`NoiseTcpStream<M> = NoiseStream<TcpStream, M>`
  type alias for back-compat). EthnTuttle's [iroh-sv2-2 branch](https://github.com/EthnTuttle/stratum/tree/iroh-sv2-2) did this.

**Decision**: **Option B**. Introduces the generic stream type with
heavy doc comments explaining when to use it (any non-TCP transport whose
streams already implement `AsyncRead + AsyncWrite`). Leaves
`noise_stream.rs` byte-identical so any concurrent upstream PR touching that
file rebases cleanly. The ~150 LOC of duplicated Noise-pump logic is the
explicit cost.

**Consequences**:
- The PR includes the new file but does **not** make any caller use it. It's
  documented as "available for future transport implementations" rather than
  exercised by this PR. This is a slight smell (introduces a feature with no
  concrete consumer in this PR), so the doc comments need to explicitly cite
  Iroh-as-future-consumer to justify inclusion.
- An alternative we considered: ship the trait without the sibling and add the
  sibling in the iroh PR. But that would force the iroh PR to also touch
  `network_helpers/mod.rs`, increasing rebase fragility for the iroh follow-up.
  The trade was made in favor of upfront inclusion.

### Decision 3: ConnPair channel-pair as the trait return type

**Context**: The existing `noise_connection::Connection::new` already produces
a `(Receiver<StandardEitherFrame<M>>, Sender<StandardEitherFrame<M>>)` channel
pair via spawned reader/writer tasks. This is the natural shape for a
transport-agnostic return type — every implementation must produce it, every
consumer already expects it. The playbook's §"Architectural approach" lifts
this exact shape to the trait level.

**Options considered**:
- A — `ConnPair<M>` as a type alias; trait methods return `Result<ConnPair<M>, Error>`.
- B — Return a `NoiseTcpStream<M>` (or generic equivalent); let callers spawn
  tasks themselves. Matches today's `connect_with_noise` shape.

**Decision**: **Option A** — ConnPair. Per-call-site refactor is one-for-one;
the existing app code that consumes the channel pair after `Connection::new`
keeps working unchanged.

**Consequences**:
- The TCP impl internally calls `Connection::new` (unchanged) and returns its
  output. The trait is a thin wrapper.
- A small helper, `spawn_conn_pair_bridge_tasks`, may be needed in app crates
  that consumed `NoiseTcpStream` directly (some pool/JDS/JDC sites do —
  `Downstream::new(NoiseTcpStream)` becomes `Downstream::new(ConnPair)`). This
  was already done on `feat/iroh-transport`; the PR carries it.

### Decision 4: PeerIdentity as Option<Secp256k1PublicKey> (no iroh-specific fields)

**Context**: The current upstream code doesn't expose a structured "peer
identity" type — connections just carry an authority pubkey opaquely. The
playbook adds `PeerIdentity` with optional `iroh_node_id`. For a TCP-only PR,
the `iroh_node_id` field shouldn't appear.

**Options considered**:
- A — `PeerIdentity { authority_pubkey: Option<Secp256k1PublicKey> }`. Single
  field. `#[non_exhaustive]` to allow growth.
- B — Skip `PeerIdentity` entirely; have the trait return only `ConnPair<M>`
  and have the listener separately expose remote-peer info via a getter.

**Decision**: **Option A**. The upgraded shape (with iroh fields) lands in the
iroh PR as a new field. `#[non_exhaustive]` makes that additive.

**Consequences**:
- The TCP impl always returns `PeerIdentity { authority_pubkey: None }`
  because Noise NX is server-only auth; the responder doesn't learn the
  initiator's authority pubkey. Document this clearly.

### Decision 5: Per-role refactor in 4 separate commits within the same PR

**Context**: The playbook's "Phase 3" (server-side) and "Phase 4" (client-side)
each split per role. For an upstream PR, separate **commits per role within
one PR** is the right granularity — the abstraction itself is one logical
change, but each role's refactor is independently reviewable.

**Options considered**:
- A — One commit per role (5 commits in the PR: 1 abstraction + 4 roles).
- B — One commit total (the whole refactor as one big diff).

**Decision**: **Option A**. Reviewers can read commit-by-commit; rebase
conflicts on a single role's file don't block the others; if upstream wants
to land per-role separately, the commits split cleanly.

**Consequences**:
- The PR has 5 commits. The first introduces the abstraction; the next four
  are per-role substitutions. Each per-role commit is small (~30-100 LOC).

## Implementation Phases

### Phase 1: Sync upstream and create the branch (effort: 30 min)

**Goal**: Fresh branch off latest `stratum-mining/sv2-apps:main` so rebase
posture is optimal at PR submission time.

**Tasks**:
- [ ] `git fetch upstream main`
- [ ] `git checkout -B feat/transport-abstraction upstream/main`
- [ ] Confirm `cargo build` and `cargo test` are clean on upstream main before
      adding anything.
- [ ] Confirm MSRV is still 1.85.0 upstream (target unchanged).

**Dependencies**: None.

**Validation**: `cargo build` and `cargo test --lib` clean across all crates
on the empty branch.

**Wiki grounding**: User interview answer: "Go off sv2-apps:main (make sure
it's up to date) and make a net-new feature branch."

### Phase 2: Add the transport abstraction (effort: 4 hours)

**Goal**: Land `Sv2Connector` / `Sv2Listener` traits, `Sv2Target::Tcp` variant,
`PeerIdentity`, `ConnPair<M>`, `TcpSv2Connector`, `TcpSv2Listener`, plus
`NoiseGenericStream<S, M>` sibling — all gated only by existing `network`
feature.

**Tasks**:
- [ ] Cherry-pick `noise_generic_stream.rs` from `feat/iroh-transport` (it's
      already standalone, no iroh deps).
- [ ] Add doc comments to `noise_generic_stream.rs` explaining: "sibling of
      noise_stream.rs that works over any AsyncRead+AsyncWrite, intended for
      future non-TCP transports (e.g., iroh QUIC streams). The duplication
      with noise_stream.rs is intentional for rebase-friendliness — see
      [SRI Discussion #1935](https://github.com/stratum-mining/stratum/discussions/1935)
      and [Fedimint's IP2PConnector pattern](https://github.com/fedimint/fedimint)."
- [ ] Cherry-pick `transport.rs` from `feat/iroh-transport`. **Strip** all
      iroh references: remove `Sv2Target::Iroh`, `IrohThenTcp`, `TcpThenIroh`
      variants; remove `PreferTransport` enum; remove `CompositeSv2Connector`;
      remove the `iroh-transport` cfg-gated `iroh_node_id: Option<NodeId>`
      field on `PeerIdentity` (replace with `#[non_exhaustive]` and document).
- [ ] Strip the `WrongTargetForTransport` error variant; not needed when
      there's only one variant.
- [ ] Confirm `Sv2Target::Tcp { addr, authority_pubkey }` is the **only**
      variant. Mark `Sv2Target` as `#[non_exhaustive]` so the iroh follow-up
      can add variants additively.
- [ ] Add doc comments to the trait explaining: "transport-agnostic abstraction
      over the connect/accept lifecycle. The current implementation only
      provides a TCP variant; the trait is structured to support additional
      transports (iroh, future QUIC variants) as additive
      implementations." Cite the wiki article paths in source comments? **No** —
      keep wiki references in PR description, not in code.
- [ ] Add `network_helpers/mod.rs` declarations for `pub mod transport;` and
      `pub mod noise_generic_stream;`.
- [ ] Add the `BindFailed`, `TcpConnectTimeout`, `TcpConnectFailed` Error
      variants. Don't add iroh-specific variants.
- [ ] Implement `TcpSv2Connector::connect` to wrap existing
      `connect_with_noise` + `Connection::new`.
- [ ] Implement `TcpSv2Listener::bind` + `TcpSv2Listener::accept` to wrap
      existing `accept_noise_connection` + `Connection::new`.
- [ ] Add unit tests in `transport.rs` mirroring those from
      `feat/iroh-transport` minus the iroh-target tests.
- [ ] `cargo test --lib`: should be ≥ baseline + ~3 new tests for
      `TcpSv2Connector`/`TcpSv2Listener` round-trip.
- [ ] `cargo clippy --lib --tests -- -D warnings`: clean.

**Dependencies**: Phase 1.

**Validation**:
- `cargo build` (default features) succeeds.
- `cargo test --lib` ≥ baseline + 3 new.
- `cargo clippy --lib --tests -- -D warnings` clean.
- `git diff stratum-apps/src/network_helpers/noise_stream.rs` is empty.

**Wiki grounding**: [Integration playbook](~/wiki/topics/iroh-transport-stratum-v2/wiki/topics/sv2-iroh-transport-playbook.md)
§"Architectural approach" defines the trait shape; user interview confirmed
the no-iroh, no-fallback scope.

### Phase 3: Refactor pool listener (effort: 1 hour)

**Goal**: Pool's downstream listener uses `Sv2Listener::accept()` instead of
hardcoded `TcpListener::bind` + `accept_noise_connection`.

**Tasks**:
- [ ] Cherry-pick the pool listener changes from commit `1125943c` on
      `feat/iroh-transport`. **Strip**: any reference to `iroh_config`,
      `iroh_role_config`, `IrohSv2Listener`, `DualSv2Listener`. Keep:
      `build_pool_listener` reduced to "just the TCP listener", the
      `Downstream::new(ConnPair)` signature change, and
      `spawn_conn_pair_bridge_tasks`.
- [ ] Confirm pool config has **zero** new fields. The TOML surface is
      unchanged.
- [ ] `cd pool-apps/pool && cargo build && cargo test` clean.
- [ ] `cd pool-apps/pool && cargo clippy --lib --tests -- -D warnings` clean
      on this commit's changes.

**Dependencies**: Phase 2.

**Validation**: Pool starts from an existing config example (no iroh fields)
and accepts a downstream connection — same behavior as before.

**Wiki grounding**: [Playbook §"Phase 3 — Server-side dual transport"](~/wiki/topics/iroh-transport-stratum-v2/wiki/topics/sv2-iroh-transport-playbook.md)
defines this substitution. The "Rebase posture" subsection insists on
one-for-one substitution with no surrounding cleanup, which keeps this commit
small and focused.

### Phase 4: Refactor JDS listener (effort: 45 min)

**Goal**: JDS's downstream listener uses `Sv2Listener::accept()`.

**Tasks**:
- [ ] Cherry-pick from commit `779a76cd`. Strip iroh references in
      `JDSConfig`, `start_downstream_server` signature, etc. Keep
      `dual_listener.rs` removed (TCP-only doesn't need a dual listener).
- [ ] `cd pool-apps/jd-server && cargo build && cargo test` clean.

**Dependencies**: Phase 2.

**Validation**: JDS bootstrap runs unchanged; no JDC behavior change.

### Phase 5: Refactor JDC listener + 3 dials (effort: 2 hours)

**Goal**: JDC uses `Sv2Listener::accept()` for its downstream listener and
`Sv2Connector::connect()` for its three outbound dials (Pool, JDS, TP).

**Tasks**:
- [ ] Cherry-pick from commit `fc6de473`. Strip iroh references in
      `JobDeclaratorClientConfig`, `Upstream`, `JdcConnectors`. Reduce
      `JdcConnectors` to just three `TcpSv2Connector` instances (one per
      role) — or, more cleanly, a single `TcpSv2Connector` shared across all
      three call sites since TCP doesn't care about ALPN.
- [ ] Strip `transport.rs` from JDC; the abstraction lives in stratum-apps now.
      JDC's role-specific code becomes thin wrappers.
- [ ] `cd miner-apps/jd-client && cargo build && cargo test` clean.

**Dependencies**: Phase 2.

**Validation**: JDC bootstrap + share submission flow runs unchanged.

### Phase 6: Refactor translator dial (effort: 45 min)

**Goal**: Translator's outbound pool dial uses `Sv2Connector::connect()`.

**Tasks**:
- [ ] Cherry-pick from commit `763a9d2f`. Strip `[iroh]` config block, iroh
      Upstream fields, iroh endpoint construction.
- [ ] `cd miner-apps/translator && cargo build && cargo test` clean.

**Dependencies**: Phase 2.

**Validation**: Translator-to-pool flow runs unchanged with SV1 minerd.

### Phase 7: Update integration-tests (effort: 1 hour)

**Goal**: Integration tests still pass; no iroh-specific test files.

**Tasks**:
- [ ] **Skip** all iroh-test files from `feat/iroh-transport`
      (`pool_integration_iroh.rs`, `jd_integration_iroh.rs`,
      `translator_integration_iroh.rs`, `fallback_iroh_to_tcp.rs`). Those
      land with iroh.
- [ ] Confirm existing integration tests (`pool_integration.rs`,
      `jd_integration.rs`, `translator_integration.rs`) still pass with the
      `Sv2Listener`/`Sv2Connector`-based bootstrap.
- [ ] If existing tests previously instantiated `noise_connection::Connection`
      directly and now need a `TcpSv2Connector`/`TcpSv2Listener` instead,
      update those test fixtures. Likely a small change.
- [ ] No new iroh fixtures in `integration-tests/lib/` — strip any
      iroh-specific helpers from `utils.rs`, `mining_device/mod.rs`,
      `mock_roles.rs`.

**Dependencies**: Phases 3-6.

**Validation**: `cd integration-tests && cargo test --features iroh-transport`
**N/A** — no `iroh-transport` feature. Just `cargo test` clean.

### Phase 8: Documentation + PR description (effort: 2 hours)

**Goal**: PR is reviewable. Accompanying docs explain the why.

**Tasks**:
- [ ] Add `stratum-apps/src/network_helpers/transport.rs` module-level docs:
      "Transport-agnostic abstraction over the SV2 connect/accept lifecycle.
      Today's only impl is TCP+Noise; the trait shape is designed so additional
      transports (e.g., iroh QUIC) can be added as additive impls without
      changing trait surface or call-site code." Cite SRI Discussion #1935.
- [ ] Add `noise_generic_stream.rs` doc comments as specified in Phase 2.
- [ ] Draft PR description: motivation (single switch point, easier testing,
      future transport flexibility), scope (zero behavior change, zero new
      transports, zero config changes), test plan (existing test suite passes
      unchanged + 3 new unit tests), follow-up (iroh transport will land in a
      separate PR; this PR is independently valuable as code health).
- [ ] Cite SRI Discussion #1935 in the PR description as the design context.
- [ ] **Don't** cite the wiki or our `.wiki/` content in the PR description —
      keep it in the personal hub. The PR stands on its own technical merits.

**Dependencies**: Phases 2-7.

**Validation**: Read the PR description as a stranger; does the case for
landing this PR (with no iroh) hold up?

### Phase 9: Open the PR (effort: 30 min)

**Tasks**:
- [ ] Push `feat/transport-abstraction` to `average-gary/sv2-apps`.
- [ ] Open PR against `stratum-mining/sv2-apps:main`.
- [ ] Tag SRI maintainers familiar with the stratum-apps networking code (look
      at recent committers to `stratum-apps/src/network_helpers/`).
- [ ] Link SRI Discussion #1935 in the PR description.
- [ ] Don't link our `feat/iroh-transport` branch — that's clutter; reviewers
      who want to see "what's this leading to" can ask.

**Validation**: PR opens without CI failures.

## Risks & Mitigations

| Risk | Source | Mitigation |
|------|--------|------------|
| Maintainers see the abstraction as speculative without a second consumer | [Risks and tradeoffs §"What this list does NOT include"](~/wiki/topics/iroh-transport-stratum-v2/wiki/topics/risks-and-tradeoffs.md) doesn't directly cover this; it's a real risk for any pure-refactor PR | PR description explicitly cites SRI Discussion #1935 (the open RFC) and acknowledges "iroh follows in a separate PR." Frames the abstraction as "the rebase-friendly first half of #1935" rather than "trust me, more is coming." |
| `NoiseGenericStream` ships without a concrete consumer, looking dead | Decision 2 consequences | Doc comments on the type explicitly say "intended for future iroh QUIC integration; see #1935." If maintainers push back, drop the file from this PR and add it with the iroh PR — but defending it should be cheap. |
| ConnPair shape change to `Downstream::new` etc. ripples beyond the bootstrap | Phase 3-6 | Each role's commit is one-for-one. If a reviewer wants the bootstrap change without the `Downstream::new` signature change, can refactor to leave `Downstream::new` consuming a `NoiseTcpStream` and drop the channel pair down inside. Smaller diff but couples Downstream to a transport-specific type, which is exactly what the abstraction is trying to avoid. |
| Maintainers prefer in-place generalization of `noise_stream.rs` | EthnTuttle's iroh-sv2-2 chose this path; signal that some upstream contributors lean that way | Be ready to do the refactor on review. If maintainers ask, switch from sibling to in-place; the cherry-picks of the trait + per-role refactors don't change. |
| Existing integration tests pass on `noise_connection::Connection::new(TcpStream)` directly and don't go through the trait | Phase 7 | Either leave them alone (`Connection::new` is unchanged) OR migrate them as a separate commit to demonstrate the trait's testability. Probably leave alone — minimum-diff PR. |

## Open Questions

- **Does upstream have a stated preference on trait-based abstraction vs free
  functions?** Wiki doesn't cover this; check past PRs and CONTRIBUTING.md for
  signals.
- **Should the `dual-listener` machinery move into stratum-apps proper as
  generic `MultiTransportListener<...>` even though there's only one transport
  today?** Recommendation: NO. Wait for the iroh PR; until there's a second
  transport, a multi-listener helper has nothing to multiplex.
- **Should `TcpSv2Listener` expose its bound address (e.g., to support port=0
  test fixtures discovering the actual port)?** Yes — add `bound_addr() ->
  SocketAddr` on `TcpSv2Listener`. This is genuinely useful for tests and
  not iroh-specific.

## Suggested Inventory Records (for the iroh-transport-stratum-v2 wiki)

After this PR opens, propose adding a `watch` inventory record:

| Type | Title | Status | Notes |
|------|-------|--------|-------|
| watch | Upstream review of feat/transport-abstraction PR | open | Reviewer feedback drives whether the iroh follow-up PR ships generic stream as sibling or in-place. |
| candidate | Iroh follow-up PR | blocked | Blocked on the abstraction PR landing or upstream specifying review preferences. |
| open-question | Upstream preference: sibling vs in-place generalization of noise_stream.rs | open | Resolves on review feedback or by reading SRI maintainer past comments. |

These should be inserted into the wiki's inventory once we have a sample to
review.

## Sources Consulted

- [Integration playbook](~/wiki/topics/iroh-transport-stratum-v2/wiki/topics/sv2-iroh-transport-playbook.md)
  — defined the architectural approach and per-role rollout shape; this plan
  is the abstraction-only subset.
- [Fedimint as reference implementation](~/wiki/topics/iroh-transport-stratum-v2/wiki/concepts/fedimint-as-reference.md)
  — proof that the trait-based pattern (IP2PConnector with side-by-side impls)
  is industry-tested.
- [Why Iroh for SV2](~/wiki/topics/iroh-transport-stratum-v2/wiki/topics/why-iroh-for-sv2.md)
  — used negatively: identifies the iroh-specific motivations that this PR
  must NOT carry.
- [Risks and tradeoffs](~/wiki/topics/iroh-transport-stratum-v2/wiki/topics/risks-and-tradeoffs.md)
  — confirms iroh-specific risks don't apply here, simplifying the PR's
  defensive posture.
- [SV2 Noise NX](~/wiki/topics/iroh-transport-stratum-v2/wiki/concepts/sv2-noise-nx.md),
  [SV2 framing](~/wiki/topics/iroh-transport-stratum-v2/wiki/concepts/sv2-framing.md)
  — invariants the abstraction must preserve.
- [Erosion attack](~/wiki/topics/iroh-transport-stratum-v2/wiki/concepts/erosion-attack.md)
  — secondary code-health motivation: makes future transport experiments cheap.
- SRI Discussion [#1935](https://github.com/stratum-mining/stratum/discussions/1935)
  — the open upstream RFC this PR partially answers.

## Estimated Total Effort

~12 hours of focused work, spread over 2-3 days for review buffer.
