---
title: "Plan: Bump iroh to 1.0.0-rc.1"
type: plan
format: roadmap
sources:
  - raw/articles/2026-05-20-iroh-1-0-0-rc-0.md
  - wiki/concepts/iroh-endpoint-and-alpn.md
  - wiki/concepts/iroh-relays.md
  - wiki/topics/sv2-iroh-transport-playbook.md
  - wiki/topics/risks-and-tradeoffs.md
  - https://github.com/n0-computer/iroh/blob/main/CHANGELOG.md (gap-fill)
  - https://www.iroh.computer/blog/iroh-1-0-0-rc-1 (gap-fill)
generated: 2026-05-27
target_repo: average-gary/sv2-apps-iroh-transport
target_branch: feat/iroh-transport
status: draft
---

# Plan: Bump iroh to 1.0.0-rc.1

> Generated from [iroh-transport-stratum-v2](~/wiki/topics/iroh-transport-stratum-v2/_index.md) wiki (5 articles consulted) plus 2 gap-fill sources for rc.1 release notes.

## Executive Summary

Bump `iroh` and `iroh-base` from `1.0.0-rc.0` to `1.0.0-rc.1` across the three
Cargo.toml files that depend on them, run the full test surface (build + unit +
iroh-feature integration tests), and fold the new release notes into the wiki.
Based on the rc.0→rc.1 changelog, the breaking-change surface (Path API
`FourTuple` refactor, `iroh-relay` `AccessControl` trait, `CustomSender`
signature change, `Incoming::local_ip` → `Incoming::local_addr`,
`IncomingLocalAddr` → `LocalTransportAddr`, more `#[non_exhaustive]` markers)
**does not intersect** any code we touch — verified by `grep -rE
"PathEvent|FourTuple|local_ip|CustomSender|AccessConfig|AccessControl"` returning
empty across the repo. The `tls-ring` feature name and the
`Endpoint`/`EndpointId`/`EndpointAddr`/`RelayUrl`/`RelayMode`/`SecretKey`/`endpoint::SendStream`/`endpoint::RecvStream`/`presets::N0`
surface we use are unchanged. **Expected diff**: three Cargo.toml line edits +
`Cargo.lock` regeneration + wiki refresh. Risk that rc.1 reveals a transitive
breakage we didn't predict from the changelog is real but small; we budget for
it as a separate phase rather than assuming the bump compiles on first try.

## Architecture Decisions

### Decision 1: Track rc.1 in lock-step across all three Cargo.toml files

**Context**: [iroh 1.0.0-rc.0 release notes](~/wiki/topics/iroh-transport-stratum-v2/raw/articles/2026-05-20-iroh-1-0-0-rc-0.md)
calls out that pre-1.0 reexports were eliminated and the API surface is now
expected to be near-stable. rc.1 (2026-05-27) is the "the last one" before 1.0,
per the n0 blog post. Our three iroh consumers (`stratum-apps`,
`integration-tests`, `miner-apps/jd-client`) all currently pin
`version = "1.0.0-rc.0"` exact-match. Mismatched rc versions inside one
workspace will produce two parallel `iroh` copies in the dep tree, and our
`stratum-apps`-defined types (`PeerIdentity { iroh_node_id: Option<iroh::EndpointId> }`)
won't be assignable from values produced by the other crates' `iroh`.

**Options considered**:
- A — Bump all three to `1.0.0-rc.1` in the same commit.
- B — Bump `stratum-apps` first, then bump consumers in follow-up commits
  after CI confirms rc.1 builds.
- C — Use `^1.0.0-rc` to let cargo pick the latest rc automatically.

**Decision**: **Option A**. Cargo's pre-release version resolution requires
exact-string match for `1.0.0-rc.X` even with caret — `^1.0.0-rc.0` does **not**
match `1.0.0-rc.1` per cargo's pre-release rules. So Option C is wrong. Option
B leaves the workspace half-mismatched and would force two separate
`Cargo.lock` regenerations. One coordinated bump is the right granularity.

**Consequences**:
- One commit titled `chore(iroh): bump iroh from 1.0.0-rc.0 to 1.0.0-rc.1`.
- `Cargo.lock` regenerates in the same commit.
- If rc.1 introduces an unexpected breakage, the bump commit is reverted as a
  unit, not piecemeal.

### Decision 2: Verify the breakage surface empirically before changing code

**Context**: The rc.0→rc.1 changelog enumerates 6 `[**breaking**]` entries:
(1) configurable path selection (#4232), (2) `FourTuple` for selected path
(#4273), (3) `FourTuple` in send paths (#4281), (4) `noq@1.0.0-rc.1` upgrade
(#4287), (5) `iroh-relay` `AccessControl` trait replacing `AccessConfig`
(#4276), (6) several non-exhaustive markers. Our code consumes the
`Endpoint`/`EndpointAddr`/`EndpointId`/`SendStream`/`RecvStream`/`RelayUrl`/`RelayMode`/`SecretKey`/`presets::N0`
surface only. None of those types appear in the rc.1 breakage list. But the
"latest noq" upgrade ripples through the whole QUIC stack, so a recompile could
expose subtle changes we missed.

**Options considered**:
- A — Bump first, run `cargo build --features iroh-transport`, fix whatever
  breaks. Optimistic.
- B — Audit the rc.1 changelog issue-by-issue against our code first, then
  bump. Pessimistic.
- C — Hybrid: a quick grep audit of suspected hot symbols (already done in
  this plan's exec summary), then bump, then a focused fix-up phase budgeted
  for breakage we missed.

**Decision**: **Option C**. The grep audit already confirms zero matches on
the obvious breakage symbols (`PathEvent`, `FourTuple`, `local_ip`,
`CustomSender`, `AccessConfig`, `AccessControl`). Phase 2's `cargo build` is
the actual verification; Phase 3 is the budgeted "if something we didn't
predict breaks" buffer. Don't audit issue-by-issue — the changelog is short
enough that the grep already covers the surface.

**Consequences**:
- Phase 2 build either succeeds (most likely) or reveals one specific compile
  error we didn't predict.
- Phase 3 exists as a contingency; if Phase 2 is clean, Phase 3 is skipped.

### Decision 3: Aggressive port if breakage surfaces, per user interview

**Context**: User interview Q2: **"Port aggressively, refactor as needed"** if
the new rc breaks our API. The [risks-and-tradeoffs](~/wiki/topics/iroh-transport-stratum-v2/wiki/topics/risks-and-tradeoffs.md)
article lists "iroh API churn" as an acknowledged risk, but doesn't prescribe
a remediation policy. User has already decided.

**Options considered**:
- A — Mechanical port; if a shape change is required, document the deferral
  and pin to rc.0.
- B — Port aggressively; refactor `transport.rs`/`iroh/*` modules to match
  the new shape.
- C — Decide per-change at review time.

**Decision**: **Option B** per user interview. Implication: any rc.1 breakage
gets fixed in this same plan/PR rather than deferred. We're treating the rc
series as a moving target up until 1.0 stable, and there's no business case
for staying behind.

**Consequences**:
- Phase 3's effort estimate is "0–4 hours" depending on whether breakage
  surfaces and how deep it goes.
- If a breakage requires touching the wiki's documented API patterns
  (e.g. the rc.0 `Endpoint::builder(presets::N0).alpns(...).bind()` shape from
  [iroh-endpoint-and-alpn](~/wiki/topics/iroh-transport-stratum-v2/wiki/concepts/iroh-endpoint-and-alpn.md)),
  Phase 5's wiki refresh updates that article, not just the release-notes
  ingestion.

### Decision 4: Wiki refresh runs in the same plan, not as a follow-up session

**Context**: User interview Q3: **"Yes — refresh + new release-notes article"**.
The wiki currently has an `iroh-1-0-0-rc-0.md` article documenting rc.0; rc.1
is a different release with its own changelog. Without a refresh, future
`/wiki:plan` invocations against this same wiki will plan from stale rc.0
assumptions.

**Options considered**:
- A — Ingest a new `2026-05-27-iroh-1-0-0-rc-1.md` raw article alongside the
  existing rc.0 article (both stay), then refresh `iroh-endpoint-and-alpn.md`
  and `iroh-relays.md` only if rc.1 changed those surfaces.
- B — Replace the rc.0 article with a single "iroh 1.0.x release notes"
  article that covers both.
- C — `/wiki:refresh` only — no new ingest, just re-fetch existing sources.

**Decision**: **Option A**. The release-notes-as-historical-record pattern is
healthy: rc.0 and rc.1 are both real points in iroh's history that the wiki
should be able to recall. New rc → new raw source. Concept articles (the
"this is the API today" articles) update only if the API actually changed.

**Consequences**:
- Phase 5 has two sub-tasks: (a) ingest rc.1 release notes as a new raw
  article, (b) re-verify `iroh-endpoint-and-alpn.md` and `iroh-relays.md`
  against rc.1 docs.rs (no-op expected per the changelog audit, but verify).
- The wiki's `_index.md` Stats section bumps "Sources ingested: 20 → 21".

### Decision 5: Full integration tests in scope

**Context**: User interview Q4: **"Full integration tests"** — run
`pool_integration_iroh.rs`, `jd_integration_iroh.rs`,
`translator_integration_iroh.rs`, and `fallback_iroh_to_tcp.rs` end-to-end on
rc.1.

**Options considered**:
- A — Full integration tests (Phase 4 runs them all).
- B — Unit + cargo build only.
- C — Cargo build only.

**Decision**: **Option A** per user. The rc.0→rc.1 noq upgrade is a transport
internals change; the integration tests are our actual validation that QUIC
behavior is preserved across rc bumps. Since the iroh integration tests run
locally with embedded relays (the fallback test is the only one that exercises
the dual-transport composite), running all four is cheap.

**Consequences**:
- Phase 4 budget: 30 minutes for the full integration test suite, more if
  any test reveals a runtime behavior change.
- If `fallback_iroh_to_tcp.rs` or any `*_iroh.rs` integration test fails on
  rc.1, that's a real signal — not a flaky-test issue — and triggers
  Phase 3's contingency.

## Implementation Phases

### Phase 1: Snapshot baseline + create branch (effort: 15 min)

**Goal**: Confirm the rc.0 baseline is green before bumping, so any rc.1
breakage is unambiguously the bump's fault.

**Tasks**:
- [ ] `git checkout feat/iroh-transport && git pull --ff-only` to make sure
      we're at `2b711e7e` or later.
- [ ] `git checkout -b chore/iroh-rc-1` off the current tip.
- [ ] `cargo build --features iroh-transport --workspace` — should succeed
      on rc.0. Note baseline build time and compile-warning count for delta
      comparison after the bump.
- [ ] `cargo test --lib --features iroh-transport --workspace` — capture pass
      count.
- [ ] `cargo test --test pool_integration_iroh --features iroh-transport` — should pass.
- [ ] `cargo test --test jd_integration_iroh --features iroh-transport` — should pass.
- [ ] `cargo test --test translator_integration_iroh --features iroh-transport` — should pass.
- [ ] `cargo test --test fallback_iroh_to_tcp --features iroh-transport` — should pass.
- [ ] `cargo clippy --features iroh-transport --workspace -- -D warnings` — clean.

**Dependencies**: None.

**Validation**: All commands green on rc.0; baseline numbers recorded.

**Wiki grounding**: User interview Q4 "Full integration tests" determines this
exact test set. Files: `integration-tests/tests/pool_integration_iroh.rs`,
`jd_integration_iroh.rs`, `translator_integration_iroh.rs`,
`fallback_iroh_to_tcp.rs`.

### Phase 2: Bump iroh + iroh-base to rc.1 (effort: 15 min)

**Goal**: Apply the version bump to all three Cargo.toml files and regenerate
`Cargo.lock`.

**Tasks**:
- [ ] `stratum-apps/Cargo.toml`: change
      `iroh = { version = "1.0.0-rc.0", default-features = false, features = ["tls-ring"], optional = true }`
      to `iroh = { version = "1.0.0-rc.1", default-features = false, features = ["tls-ring"], optional = true }`.
- [ ] `stratum-apps/Cargo.toml`: change
      `iroh-base = { version = "1.0.0-rc.0", default-features = false, optional = true }`
      to `iroh-base = { version = "1.0.0-rc.1", default-features = false, optional = true }`.
- [ ] `integration-tests/Cargo.toml`: change `iroh = { version = "1.0.0-rc.0", ... }`
      to `iroh = { version = "1.0.0-rc.1", ... }`.
- [ ] `miner-apps/jd-client/Cargo.toml`: change `iroh = { version = "1.0.0-rc.0", ... }`
      to `iroh = { version = "1.0.0-rc.1", ... }`.
- [ ] `cargo update -p iroh -p iroh-base` (regenerates Cargo.lock with the
      new exact rc).
- [ ] `cargo build --features iroh-transport --workspace`.
- [ ] If build is clean: proceed to Phase 4 (skip Phase 3).
- [ ] If build fails: proceed to Phase 3.

**Dependencies**: Phase 1.

**Validation**: `cargo build --features iroh-transport --workspace` is the
gate. Either it's clean (most likely outcome per the changelog audit) or
Phase 3 absorbs the fix.

**Wiki grounding**: Three Cargo.toml files identified by `grep -rE "iroh.*=.*\"" --include=Cargo.toml`.
The `tls-ring` feature is preserved (per docs.rs gap-fill: rc.1 still
exposes `tls-ring` as the default TLS backend; `tls-aws-lc-rs` exists as the
opt-in alternative). No feature-flag rename needed.

### Phase 3: Fix any rc.1 breakage (effort: 0–4 hours, contingent)

**Goal**: If Phase 2's build failed, identify the breaking change and apply
the minimum diff to compile clean again. Per Decision 3, port aggressively.

**Most likely failure modes** (ordered by probability based on the rc.0→rc.1
changelog):
- (a) **noq upgrade ripple** (#4287, #4283, #4248): If our
      `noise_iroh_stream.rs` / `noise_generic_stream.rs` ever called any
      QUIC-stream method whose signature changed in noq@1.0.0-rc.1, fix the
      call site. Most likely small (1–3 line changes).
- (b) **`#[non_exhaustive]` markers added** (#4226 from rc.0, more in rc.1):
      If we constructed a struct with all fields, switch to `..Default::default()`
      or builder pattern. Mostly affects test fixtures.
- (c) **`presets::N0` semantics change**: rc.0 said `presets::N0` no longer
      pulls in DHT/mDNS discovery transparently. rc.1 didn't list a
      preset-API change in the changelog, but if the preset shape changed,
      our `Endpoint::builder(presets::N0)` calls in `iroh/endpoint.rs`
      would fail. Fix: switch to the new preset constructor.
- (d) **iroh-base error type change** (#4285 exposes `SignatureParsingError`):
      We don't currently match on iroh-base errors structurally, but if we did,
      update the match arms.
- (e) **Anything truly unexpected**: Read the compile error, look up the
      affected symbol on https://docs.rs/iroh/1.0.0-rc.1/iroh/, port to the
      new shape.

**Tasks** (each conditional on the failure mode that surfaces):
- [ ] Read the first compile error from `cargo build --features iroh-transport --workspace 2>&1 | head -40`.
- [ ] Cross-reference with [the iroh CHANGELOG](https://github.com/n0-computer/iroh/blob/main/CHANGELOG.md)
      and [docs.rs/iroh/1.0.0-rc.1](https://docs.rs/iroh/1.0.0-rc.1/iroh/).
- [ ] Apply the smallest diff that compiles. **No surrounding cleanup.**
- [ ] `cargo build --features iroh-transport --workspace` — should pass.
- [ ] `cargo clippy --features iroh-transport --workspace -- -D warnings` — should pass.
- [ ] Repeat for any subsequent compile errors.

**Dependencies**: Phase 2 (only runs if Phase 2 build failed).

**Validation**: Same as Phase 2's build gate, applied iteratively.

**Wiki grounding**: [Risks and tradeoffs](~/wiki/topics/iroh-transport-stratum-v2/wiki/topics/risks-and-tradeoffs.md)
flags iroh API churn as an acknowledged ongoing cost; this phase is the
operational expression of that acknowledgment.

### Phase 4: Run the full test surface (effort: 30 min)

**Goal**: Match Phase 1's baseline 1-for-1 on rc.1.

**Tasks**:
- [ ] `cargo test --lib --features iroh-transport --workspace` — pass count
      ≥ Phase 1 baseline.
- [ ] `cargo test --test pool_integration_iroh --features iroh-transport` — pass.
- [ ] `cargo test --test jd_integration_iroh --features iroh-transport` — pass.
- [ ] `cargo test --test translator_integration_iroh --features iroh-transport` — pass.
- [ ] `cargo test --test fallback_iroh_to_tcp --features iroh-transport` — pass.
- [ ] `cargo clippy --features iroh-transport --workspace -- -D warnings` — clean.
- [ ] `cargo test --workspace` (no iroh feature) — should still pass; ensures
      we didn't accidentally introduce an iroh-only regression on the TCP path.
- [ ] If any integration test fails: bisect (rc.0 vs rc.1) to confirm rc.1
      caused it; capture log output; either fix in Phase 3 (re-enter the
      contingency loop) or, if blocked on an upstream iroh bug, file an
      issue at n0-computer/iroh and pin to rc.0 with a comment.

**Dependencies**: Phase 2 (or Phase 3 if it ran).

**Validation**: All tests pass with the same outcome as Phase 1.

**Wiki grounding**: User interview Q4 "Full integration tests" mandates this
phase. The 4 iroh-specific integration tests are listed in the
[integration playbook](~/wiki/topics/iroh-transport-stratum-v2/wiki/topics/sv2-iroh-transport-playbook.md)
§"Phase 5 — Integration tests".

### Phase 5: Wiki refresh (effort: 45 min)

**Goal**: Update the wiki to reflect rc.1 as the current target. Ingest the
new release-notes article; verify concept articles still describe the
current API surface.

**Tasks**:
- [ ] Ingest https://www.iroh.computer/blog/iroh-1-0-0-rc-1 as
      `~/wiki/topics/iroh-transport-stratum-v2/raw/articles/2026-05-27-iroh-1-0-0-rc-1.md`
      with frontmatter mirroring the rc.0 article: `type: release-notes`,
      `quality: 5`, `relevance: direct`, `tags: [iroh, release, 1.0, rc.1]`,
      `ingested: 2026-05-27`.
- [ ] Body should distill: (a) the noq@1.0.0-rc.1 upgrade, (b) the Path API
      `FourTuple` refactor (note: doesn't affect SV2 transport since we don't
      consume Path<'_> events), (c) iroh-relay `AccessControl` trait (note:
      doesn't affect SV2 since we run as iroh clients, not relay operators),
      (d) `IncomingLocalAddr` → `LocalTransportAddr` rename (note: doesn't
      affect SV2). Conclude with **"For SV2: pure version bump; no API churn
      in the surfaces SV2 uses."**
- [ ] Refresh [iroh-endpoint-and-alpn.md](~/wiki/topics/iroh-transport-stratum-v2/wiki/concepts/iroh-endpoint-and-alpn.md):
      verify the `Endpoint::builder(presets::N0).alpns(...).secret_key(...).bind().await?`
      example still compiles against rc.1 (cross-check docs.rs/iroh/1.0.0-rc.1/iroh/).
      If unchanged: bump `verified: 2026-05-27` in the frontmatter, leave
      content as-is. If changed: rewrite the snippet, note the rc.1 delta in a
      "rc.0 → rc.1 changes" note section.
- [ ] Refresh [iroh-relays.md](~/wiki/topics/iroh-transport-stratum-v2/wiki/concepts/iroh-relays.md):
      verify `RelayMode` and `RelayUrl::from_str` still describe rc.1 shape.
      Same bump-or-rewrite logic.
- [ ] Update `~/wiki/topics/iroh-transport-stratum-v2/_index.md` Stats:
      `Sources ingested: 20 → 21` and add an entry under "Last research session"
      noting the 2026-05-27 rc.1 refresh.
- [ ] Append to `~/wiki/topics/iroh-transport-stratum-v2/log.md`:
      `## [2026-05-27] gap-close | iroh 1.0.0-rc.1 release notes ingested; rc.0→rc.1 has zero impact on SV2 transport surface (verified via grep + integration test pass)`.

**Dependencies**: Phase 4 (only update the wiki after we've empirically
verified rc.1 works for our use case).

**Validation**: `~/wiki/topics/iroh-transport-stratum-v2/raw/articles/`
contains both rc.0 and rc.1 release-notes articles. Concept articles either
have refreshed `verified:` dates (no API change) or have updated bodies
(API change).

**Wiki grounding**: User interview Q3 "Yes — refresh + new release-notes
article" mandates this exact shape. Decision 4 chose Option A
(release-as-historical-record, not collapse into one article).

### Phase 6: Commit + ready for upstream sync (effort: 15 min)

**Goal**: Land a clean commit on `chore/iroh-rc-1`; either merge to
`feat/iroh-transport` or open a PR depending on user preference.

**Tasks**:
- [ ] `git add stratum-apps/Cargo.toml integration-tests/Cargo.toml miner-apps/jd-client/Cargo.toml Cargo.lock`.
- [ ] If Phase 3 ran, add the affected source files.
- [ ] Commit message follows the style of `2b711e7e` (the rc.0 port commit):
      ```
      chore(iroh): bump iroh from 1.0.0-rc.0 to 1.0.0-rc.1

      rc.1 ships the noq@1.0.0-rc.1 upgrade and a Path-API FourTuple
      refactor; neither surface is consumed by SV2 transport code. The
      tls-ring feature name and the
      Endpoint/EndpointId/EndpointAddr/RelayUrl/RelayMode/SecretKey/SendStream/RecvStream/presets::N0
      API surface we use is unchanged. Verified by full integration test
      suite (pool_integration_iroh, jd_integration_iroh,
      translator_integration_iroh, fallback_iroh_to_tcp).

      [If Phase 3 ran, append: "Phase-3 fix: <one-line description of the
      breakage and the fix>." ]
      ```
- [ ] Decide with user whether to: (i) merge to `feat/iroh-transport` directly
      (single-developer branch, low ceremony), or (ii) open a PR for review.
      Wiki grounding: this branch is the user's working branch, not yet upstream;
      lightweight merge is the default. Don't open an upstream PR for the bump
      yet — the upstream `feat/transport-abstraction` PR (per
      [the abstraction plan](~/wiki/topics/iroh-transport-stratum-v2/output/plan-sv2-transport-abstraction-pr-2026-05-26.md))
      is the work that goes upstream first.

**Dependencies**: Phases 2 + 4 + 5 all green.

**Validation**: `git log --oneline -5` shows the new commit on top of
`2b711e7e`.

**Wiki grounding**: Existing repo convention. The previous rc.0 port commit
(2b711e7e, "chore(iroh): port from iroh 0.91 to iroh 1.0.0-rc.0") is the
reference for commit-message style.

## Risks & Mitigations

| Risk | Source | Mitigation |
|------|--------|------------|
| rc.1 introduces a breakage we missed in the changelog audit | [Risks and tradeoffs §"iroh API churn"](~/wiki/topics/iroh-transport-stratum-v2/wiki/topics/risks-and-tradeoffs.md) | Phase 3 is the budgeted fix-up phase. If breakage is deeper than 4 hours, escalate to user before continuing — the bump may not be worth the cost this week. |
| `cargo update -p iroh -p iroh-base` pulls in non-iroh transitive bumps that break our build | rc.0 article: "exact-version deps for prereleased crates" suggests iroh pins exact-versions internally | If transitive bumps break: pin specific transitive deps in the workspace `Cargo.lock` via `cargo update -p <transitive> --precise <known-good-version>`. Note: don't add new top-level deps in `Cargo.toml` to fight transitive bumps; that's a code smell. |
| Integration tests pass against `pool_integration_iroh` etc. but real-world miner connections fail (the iroh integration tests use embedded relays + localhost; production uses public n0 relays) | [iroh-relays](~/wiki/topics/iroh-transport-stratum-v2/wiki/concepts/iroh-relays.md) docs the embedded vs public relay distinction | Out of scope for this bump — the rc.0→rc.1 changelog doesn't list any relay-protocol breakage. If a future production deployment fails on rc.1 specifically, treat that as a separate bug requiring a real-network smoke test. |
| Custom-transports gating changes (per rc.0 release notes, custom transports moved behind `unstable-custom-transports` feature) | rc.0 article §"Custom transports gated" | We don't enable `unstable-custom-transports` today; not affected. If we add Tor/Nym/BLE later (per [iroh-custom-transports](~/wiki/topics/iroh-transport-stratum-v2/wiki/concepts/iroh-custom-transports.md)), revisit. |
| Wiki refresh introduces stale concept articles silently if rc.1 docs.rs disagrees with rc.0 article body | Decision 4 mandates concept-article verification | Phase 5's "verify against docs.rs/iroh/1.0.0-rc.1" sub-tasks explicitly compare rc.0 article body against rc.1 docs. If anything is stale, rewrite — don't just bump the verified date. |
| Phase 1's baseline integration tests are flaky on rc.0 | Untested assumption | If a Phase 1 test fails on rc.0, that's a pre-existing bug; pause this plan, fix the rc.0 bug first, then resume the bump. |

## Open Questions

- **Should we set up a CI job to test against `iroh = "1.0.0-rc.X"` for the
  next-rc-not-yet-released?** Out of scope for this bump. Open a separate
  inventory record if the user wants to track this.
- **Does iroh ship 1.0.0 stable before our upstream PR
  ([feat/transport-abstraction](~/wiki/topics/iroh-transport-stratum-v2/output/plan-sv2-transport-abstraction-pr-2026-05-26.md))
  lands?** If yes, the iroh follow-up PR (per that plan) targets stable 1.0
  directly, skipping rc.1 in upstream history. The rc.1 work in this plan is
  for *our* branch only.
- **Should the wiki article body for the rc.1 release notes call out the
  "for SV2: zero impact" framing prominently, or stay neutral?** Decision 4
  Phase 5 chose prominent — the wiki is project-local to SV2, so framing
  matters. If the wiki ever gets re-promoted to a non-SV2 hub, that framing
  will need to be neutralized.

## Suggested Inventory Records

After this bump lands, propose adding to the wiki's inventory:

| Type | Title | Status | Notes |
|------|-------|--------|-------|
| watch | iroh 1.0.0 stable release | open | When stable ships, plan a follow-up bump (likely smaller than rc.0→rc.1; APIs are committed at 1.0). |
| candidate | CI job: build against next iroh rc | deferred | Out of scope for this bump; revisit if rc.2 is announced. |

These should be inserted via `/wiki:inventory` once the user reviews.

## Sources Consulted

- [iroh 1.0.0-rc.0 release notes](~/wiki/topics/iroh-transport-stratum-v2/raw/articles/2026-05-20-iroh-1-0-0-rc-0.md)
  — established rc.0 baseline; documents the API surface we currently target.
- [iroh: Endpoint and ALPN](~/wiki/topics/iroh-transport-stratum-v2/wiki/concepts/iroh-endpoint-and-alpn.md)
  — verified our `Endpoint`/`EndpointId`/`presets::N0`/ALPN consumption patterns.
- [iroh: Relays](~/wiki/topics/iroh-transport-stratum-v2/wiki/concepts/iroh-relays.md)
  — verified our `RelayMode`/`RelayUrl` consumption patterns.
- [Integration playbook](~/wiki/topics/iroh-transport-stratum-v2/wiki/topics/sv2-iroh-transport-playbook.md)
  §"Phase 5 — Integration tests" — defines the iroh-specific test fixtures
  Phase 4 runs.
- [Risks and tradeoffs](~/wiki/topics/iroh-transport-stratum-v2/wiki/topics/risks-and-tradeoffs.md)
  §"iroh API churn" — acknowledged risk; this plan operationalizes the
  mitigation.
- (gap-fill) [iroh CHANGELOG.md](https://github.com/n0-computer/iroh/blob/main/CHANGELOG.md)
  — rc.0→rc.1 breaking-change inventory; cross-checked against `grep` audit.
- (gap-fill) [iroh 1.0.0-rc.1 — The last one (n0 blog)](https://www.iroh.computer/blog/iroh-1-0-0-rc-1)
  — confirms rc.1 is the final rc before 1.0 stable.

## Estimated Total Effort

- **Optimistic** (Phase 3 not needed): ~2 hours wall-clock.
- **Pessimistic** (Phase 3 surfaces breakage): ~6 hours wall-clock.
- Spread over **a single working session** today.
