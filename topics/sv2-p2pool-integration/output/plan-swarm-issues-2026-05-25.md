---
title: "Plan: agentic swarm to close 9 open issues on average-gary/sv2-p2pool"
type: plan
format: roadmap
sources:
  - "[[wiki/topics/share-accounting-mapping|Share-accounting mapping spec]]"
  - "[[wiki/topics/integration-paths|Integration paths]]"
  - "[[wiki/concepts/sv2-integration-surface|SV2 integration surface]]"
  - "[[wiki/concepts/p2poolv2|p2poolv2]]"
  - "[[output/plan-sv2-p2pool-repo-2026-05-22|sv2-p2pool repo spec]]"
  - "GitHub issues #1-#10 at average-gary/sv2-p2pool"
generated: 2026-05-25
status: proposed
---

# Plan: agentic swarm to close the 9 open issues on `average-gary/sv2-p2pool`

> Generated from the [[../_index|sv2-p2pool-integration wiki]] (8 articles + 9 GitHub issues consulted).

## Executive summary

Run a dependency-aware swarm of background agents to close the 9 open issues filed during Phase 0 bootstrap. **Aggressive-autonomous** mode: agents push branches, open PRs, and self-merge on green CI; **only design-question PRs require human review**. **Upstream PRs (#6, #7) prepared locally on submodule branches** — never pushed to the upstream repo without your explicit go-ahead. Design rationale captured as both inline issue comments and `docs/adr/NNNN-*.md` files.

The swarm will produce, in roughly this order:
- **Tier 0** (sequential, fast): #9 (MSRV CI matrix) → unblocks confidence in everything else
- **Tier 1** (parallel, design-heavy): #1, #2, #4, #10 → ADR PRs awaiting your review
- **Tier 2** (parallel, after Tier 1 design decisions): #3, #5 → implementation PRs
- **Tier 3** (after #10 decision): #7 → upstream PR draft on submodule branch
- **Tier 4** (parallel with Tier 1 since it's independent): #6 → upstream PR draft on submodule branch

---

## Dependency DAG

```
                          ┌───────────────────────────────┐
                          │ #9 MSRV / CI matrix (Tier 0)  │
                          └──────────────┬────────────────┘
                                         │ (none of below NEEDS this, but green
                                         │  CI baseline makes other PRs trustworthy)
                                         ▼
       ┌────────────┬─────────────┬──────────────┬───────────────┐
       │ #1 Uncle   │ #2 Token→   │ #4 Coinbase- │ #10 Capnp    │
       │ weighting  │ payout-     │ only mode    │ schema       │  Tier 1
       │ (design)   │ script      │ (design)     │ hosting      │  (parallel)
       │            │ (design)    │              │ (decision)   │
       └─────┬──────┴──────┬──────┴───────┬──────┴──────┬───────┘
             │             │              │             │
             ▼             ▼              ▼             ▼
       ┌─────────────────────────────┐  (impl)   ┌──────────────┐
       │ #3 Token revocation on      │           │ #7 Capnp IPC │  Tier 3
       │ reorg (uses #1, #2 outputs) │           │ schema PR    │  (after #10)
       │                             │           │ to p2poolv2  │
       │ Tier 2 — implementation     │           └──────────────┘
       │ + sv2-apps trait extension  │
       └─────────────────────────────┘
                                         ┌──────────────┐
                                         │ #6 Bitcoind  │  Tier 4 — parallel
                                         │ trait PR to  │  to all of above
                                         │ p2poolv2     │  (independent)
                                         └──────────────┘

       ┌─────────────────────────────────────┐
       │ #5 PushSolution race                │  Tier 2b — independent of #3
       │ (impl + test in sv2-p2pool-engine)  │  parallel to Tier 2/3/4
       └─────────────────────────────────────┘
```

**Independent and parallelizable from the start**: #5, #6, #9 can launch concurrently with Tier 1.
**Critical path**: #10 → #7 (cap'n proto schema work).

---

## Architecture decisions

### Decision 1: Mixed autonomy — auto-merge impl, human-review design

**Context**: Issues #1, #2, #3, #4, #10 are design questions with non-obvious tradeoffs (per `decisions/open-questions.md`). Issues #5, #6, #9 are implementation work where success is compiler-/test-verifiable.

**Decision**: Apply auto-merge-on-green to issues labeled implementation-only; require explicit human approval on issues labeled `design`.

**Consequences**:
- Design PRs accumulate in your review queue; you control merge cadence.
- Implementation PRs flow through CI without bottlenecking on you.
- Risk: if a design decision is wrong, dependent implementation PRs build on bad foundations. Mitigation: Tier 2 (#3) explicitly waits for #1 and #2 design merges.

### Decision 2: Upstream PRs prepared locally, not pushed

**Context**: #6 and #7 require PRs to `p2poolv2/p2poolv2`, an external project. The maintainers haven't been engaged yet — pushing unsolicited PRs would be poor form and the [[concepts/p2poolv2|p2poolv2]] community is small enough that relationship matters.

**Decision**: Swarm prepares PRs on branches in the `vendor/p2poolv2/` submodule (`git checkout -b feat/X` inside the submodule). The branches are committed in sv2-p2pool's submodule pin so the work is durable and reviewable, but they are NOT pushed to the upstream repo.

**Consequences**:
- The work product exists; you submit when ready.
- `git -C vendor/p2poolv2 push <your-fork>` is a one-liner you run after review.
- Submodule pins drift from upstream `main` — track in #9 follow-ups.

### Decision 3: Design rationale captured both ways

**Context**: Issue threads are ephemeral (close + lose context); ADR files are durable but lose discussion.

**Decision**: For each design issue, the agent writes:
1. A long-form analysis as an issue comment (with cited file:line evidence).
2. A `docs/adr/NNNN-<slug>.md` file in its PR, following MADR conventions (status, context, options, decision, consequences).

**Consequences**:
- Repo carries decision history forever.
- Issue threads carry the discussion that led to it.
- Standard pattern from the broader Bitcoin Core / Rust ecosystem.

### Decision 4: Open-ended budget, dependency-aware sequencing

**Context**: User chose "open-ended" budget and "dependency-aware DAG" sequencing.

**Decision**: Independent issues launch in parallel as background agents; dependent issues launch only after their prerequisites' PRs merge (or, for design ADRs awaiting human review, after their ADR file is written even if the PR isn't merged — the implementation can read the ADR draft).

**Consequences**:
- Highest throughput; possibly highest token cost.
- We surface intermediate work as draft PRs frequently — you have visibility.

### Decision 5: Blocker handling

**Context**: Some issues may not be solvable without input (e.g., #10 schema-hosting decision is yours, not the agent's).

**Decision**: When an agent hits a blocker:
1. Apply `needs-input` label to the issue.
2. Post a detailed comment summarizing what was tried, what's blocked, and 2-3 specific questions for you.
3. Move on to other independent issues — never halt the whole swarm.

**Consequences**:
- You triage the `needs-input` queue at the end.
- Productive work doesn't stop on a single blocker.

---

## Implementation phases

### Tier 0: CI baseline (estimated effort: 30 minutes)

**Goal**: Issue #9 done. Repo has a working CI workflow that builds at MSRV 1.88 and runs `cargo check --workspace`. This gives every subsequent PR a green/red signal.

**Tasks**:
- [ ] Add `.github/workflows/ci.yml` with: checkout (recursive submodules), Rust toolchain 1.88, cargo check, cargo test, cargo clippy.
- [ ] Add a 1.85 sv2-apps-only matrix entry (build sv2-apps's own workspace at its declared MSRV).
- [ ] Verify CI passes on a draft PR.
- [ ] Auto-merge #9.

**Validation**: PR check turns green; merged.

**Wiki grounding**: spec §6 (Verification) calls out `cargo check --workspace` + integration-tests. The CI workflow is the durable harness for that.

### Tier 1: Design ADRs (estimated effort: 4 parallel agents × ~1 hour each)

**Goal**: Each of #1, #2, #4, #10 produces:
- A draft PR labeled `awaiting-review` containing `docs/adr/NNNN-<slug>.md`.
- A long-form issue comment summarizing the analysis.

**Per-issue agent prompts will draw from**:
- #1 (uncle weighting): [[wiki/topics/share-accounting-mapping#mapping-table|mapping table]] §"Critical note: uncles", `vendor/sv2-apps/stratum-apps/src/monitoring/snapshot_cache.rs:45-74` for SV2 metric semantics.
- #2 (token→script binding): [[wiki/topics/share-accounting-mapping#data-model|data model §3.1]], `vendor/sv2-apps/pool-apps/jd-server/src/lib/job_declarator/token_management/`.
- #4 (coinbase-only mode): [[wiki/topics/share-accounting-mapping]] §"Open Q 6", `vendor/p2poolv2/p2poolv2_lib/src/shares/validation/`.
- #10 (capnp schema crate hosting): [[output/plan-sv2-p2pool-repo-2026-05-22|spec §4.4]], precedent of `bitcoin-capnp-types`.

**Tasks** (per agent):
- [ ] Read relevant wiki articles and source files.
- [ ] Identify 2-3 candidate solutions; weigh tradeoffs.
- [ ] Write ADR file (`status: proposed`).
- [ ] Open draft PR; comment on issue with link to PR + summary.
- [ ] Apply `awaiting-review` label.

**Validation**: ADR file passes Markdown lint; PR description is complete; issue comment is concise.

**Wiki grounding**: each agent's analysis must cite at least one wiki article and one specific file:line in `vendor/`.

### Tier 2 / 2b: Implementation PRs

#### Tier 2: Issue #3 — Token revocation on reorg (after #1, #2 merge or ADR draft exists)

**Goal**: Implement the proposed `notify_share_chain_reorg(new_tip)` extension in a branch on `vendor/sv2-apps/`, with a corresponding consumer in `crates/sv2-p2pool-engine`.

**Tasks**:
- [ ] On `vendor/sv2-apps/`: create branch `feat/jve-reorg-notify`, add the trait method with default no-op impl, update `BitcoinCoreIPCEngine` impl.
- [ ] On `sv2-p2pool/`: implement the new method in `P2poolV2Engine` (poll-based detection in Phase 1; see #1 ADR for the actual reorg semantics).
- [ ] Tests: simulated reorg invalidates cached `declared_jobs`.
- [ ] Open PR labeled `awaiting-review` (this one needs human review even though it's implementation, because the trait extension is upstream-bound).

**Validation**: tests pass; PR description references the upstream submodule branch.

#### Tier 2b: Issue #5 — PushSolution race (independent, parallel from start)

**Goal**: Implement buffered block-finder tagging.

**Tasks**:
- [ ] Add `RecentSolutions` struct in `sv2-p2pool-engine` keyed by share-hash with TTL (~30s).
- [ ] `handle_push_solution` writes to the buffer; `SubmitSharesExtended` handler (in `ChannelManager` Phase 1 wiring) reads it on share match.
- [ ] Property test: random ordering of solution + share submission credits the finder.
- [ ] Auto-merge on green CI.

**Validation**: property test ≥1k iterations; CI passes.

### Tier 3: Issue #7 — Capnp IPC schema PR (after #10 decision)

**Goal**: Branch on `vendor/p2poolv2/` containing the capnp schema, generated bindings, and a stub IPC server actor. Not pushed upstream.

**Tasks** (depend on #10 ADR landing):
- [ ] On `vendor/p2poolv2/`: create branch `feat/capnp-ipc`, add new crate `p2poolv2_ipc` with capnp schema + capnp-rpc server.
- [ ] Wire into `p2poolv2_node` lifecycle (or whatever the host is, per #10 ADR's hosting decision).
- [ ] Document in p2poolv2 fashion (README addition, capnp file in `proto/`).
- [ ] Open draft PR in our sv2-p2pool repo (NOT in p2poolv2) summarizing the work and referencing the submodule branch sha.
- [ ] Label `upstream-ready`.

**Validation**: `cargo check --manifest-path vendor/p2poolv2/Cargo.toml -p p2poolv2_ipc` passes.

### Tier 4: Issue #6 — `BitcoindRpcClient` trait (parallel from start)

**Goal**: Branch on `vendor/p2poolv2/` introducing a `BitcoindLike` trait. Engine + p2poolv2 internal callers updated. Not pushed upstream.

**Tasks**:
- [ ] On `vendor/p2poolv2/`: create branch `feat/bitcoind-trait`, define `pub trait BitcoindLike` over the methods used (`get_difficulty`, `getblocktemplate`, `submit_block`, `decoderawtransaction`).
- [ ] Concrete `BitcoindRpcClient: BitcoindLike`.
- [ ] All internal call sites switch to the trait.
- [ ] A mock impl (`MockBitcoind`) in test code.
- [ ] Open draft PR in sv2-p2pool labeled `upstream-ready`; reference branch sha.

**Validation**: p2poolv2's own tests pass; new mock is exercised in at least one engine unit test.

---

## Risks & mitigations

| Risk | Source | Mitigation |
|------|--------|------------|
| Aggressive auto-merge ships a regression | user choice | Tier 0 CI baseline; revert PR is the cheap escape |
| Design ADRs land with shallow analysis | LLM tendency to converge on first plausible answer | Each agent must cite ≥1 wiki article + 1 file:line; reviewers can reject for missing citations |
| #10 ADR delayed → #7 blocked indefinitely | dependency on user input | Agent for #7 stages everything except final hosting decision; can land schema work even if hosting choice slips |
| Submodule branches diverge from upstream main | inevitable on long-running branches | Track in #9 follow-up; rebase before opening upstream PR |
| Concurrent PRs to same file cause merge conflicts | parallel impl | Each tier's agents work on distinct files (engine vs vendor submodules); we explicitly serialize within tiers when files overlap |
| Token-payout-script binding ADR conflicts with sv2-apps's evolving JDS | upstream is active | Pin sv2-apps submodule until ADR lands; don't bump during this swarm |
| `needs-input` queue grows large | conservative blocker handling | Set ceiling: if >3 issues hit `needs-input`, halt swarm and report |

---

## Open questions

1. **Should ADRs require user sign-off before implementation depends on them?**
   Tier 2's #3 depends on #1 and #2's ADRs. If you don't formally approve the ADR, the impl proceeds on the agent's recommended option. Acceptable risk, or do we add a checkpoint?

2. **Where does the swarm orchestrator live?**
   This plan is the orchestrator's instruction set, but the actual scheduling is done by me (the parent Claude session) launching subagents. No persistent daemon; if you `/clear`, the run halts. (Intentional — gives you a kill switch.)

3. **CI runner cost.** Each tier-1 PR triggers `cargo check --workspace` which is ~75 seconds. With 9 PRs that's ~12 minutes of CI on free GitHub runners. Within free-tier budget.

4. **What happens to ADR drafts if you reject them?**
   Default: agent comments with revision rationale and updates the same PR. If you want a fresh PR per revision, say so before the swarm starts.

---

## Sources consulted

- [[wiki/topics/share-accounting-mapping]] — used for #1, #2, #3, #4, #5 message-level mapping
- [[wiki/topics/integration-paths]] — confirms tier ordering matches Phase 1 spec
- [[wiki/concepts/sv2-integration-surface]] — `JobValidationEngine` shape; #3 trait extension proposal
- [[wiki/concepts/p2poolv2]] — AGPL constraint, libp2p requirement; #6, #7 upstream PR scope
- [[output/plan-sv2-p2pool-repo-2026-05-22]] — phase definitions, capnp IPC schema sketch
- GitHub issues #1-#10 at `average-gary/sv2-p2pool` — current state of the work

---

## Inventory follow-ups

Suggested durable items for the wiki's inventory:

- **Watch**: each tier's progress board on GitHub (project view of the 9 issues).
- **Open question**: ADR rejection workflow (see Open Questions §4).
- **Candidate corpus**: p2poolv2 maintainer Matrix room — for soft-pinging once #6/#7 PRs are ready locally.
