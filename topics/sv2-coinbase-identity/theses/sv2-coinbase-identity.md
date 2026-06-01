---
title: "Thesis: SV2 user_identity can carry a per-miner unique tag into the Pool-built coinbase"
type: thesis
status: completed
created: 2026-05-28
updated: 2026-05-28
verdict: partially-supported
confidence: high
core_claim: "On Stratum V2, a downstream can supply a unique value in the user_identity field of OpenStandardMiningChannel / OpenExtendedMiningChannel, and the upstream Pool can use that value to construct a coinbase transaction that includes a per-miner marker (a string, NOT a cryptographic signature) alongside the pool's own identifier — without invoking the Job Declaration Protocol."
key_variables: [user_identity, OpenMiningChannel, NewExtendedMiningJob, coinbase_prefix, coinbase_suffix, SetCustomMiningJob, JobDeclarationProtocol]
falsification: "If the SV2 spec or reference implementation explicitly forbids the Pool from writing per-miner data into the coinbase under non-JD operation, defines coinbase_prefix/coinbase_suffix as broadcast-only with no per-channel variation other than extranonce, and provides no architectural seam for per-channel coinbase derivation, then the thesis is contradicted."
---

# Thesis: SV2 user_identity can carry a per-miner unique tag into the Pool-built coinbase

## Core Claim
On Stratum V2 (without Job Declaration), a downstream supplies a unique string in the `user_identity` field of `OpenStandardMiningChannel` / `OpenExtendedMiningChannel`, and the upstream Pool uses that string to construct a coinbase transaction that embeds a per-miner marker (a "tag" — not a cryptographic signature) alongside the pool's own identifier.

User clarification (2026-05-28): "signature" here means *a unique string associated to the miner* — not a cryptographic signature.

## Key Variables
- `user_identity` — `Str0_255` field on `OpenStandardMiningChannel` / `OpenExtendedMiningChannel`. Spec docstring: "Whatever is needed by upstream role to identify/authenticate the downstream, e.g. test.worker1." [[raw/articles/2026-05-28-sv2-spec-mining-protocol]]
- Coinbase construction surface — Pool-built (`NewExtendedMiningJob.coinbase_tx_prefix` + extranonce + `coinbase_tx_suffix`) vs. JDC-built (declarative mode via JDS/JDC + `SetCustomMiningJob`). [[wiki/concepts/coinbase-ownership-pool-vs-jdc]]
- Channel topology — Standard, Extended, Group. Per-channel `extranonce_prefix`. [[wiki/concepts/sv2-coinbase-scriptsig-layout]]
- SRI [[`JobFactory`|wiki/concepts/job-factory-and-coinbase-construction]] — already takes a `miner_tag: Option<String>` parameter.

## Testable Prediction
A Pool implementation in non-JD mode can construct per-channel coinbase scriptSigs of the form `BIP34 / pool_tag / f(user_identity) / OP_PUSHBYTES extranonce` without violating the spec, the Bitcoin consensus 100-byte scriptSig limit, or the SRI reference architecture.

## Falsification Criteria (and check)
- ❌ Spec defines coinbase as broadcast-only with no per-channel variation other than extranonce — **falsified**: `OpenStandardMiningChannelSuccess` returns a per-channel `extranonce_prefix`; `JobFactory` is per-channel; `NewExtendedMiningJob` is emitted per-channel by default in SRI's `on_new_template`. Group-channel broadcast is opt-in.
- ❌ `coinbase_tx_prefix`/`coinbase_tx_suffix` are forbidden from varying per-channel — **falsified**: spec is silent; SRI computes them per-channel from per-channel `extranonce_prefix` and per-channel `JobFactory`.
- ❌ Reference implementations explicitly drop `user_identity` and prevent it from reaching coinbase building — **partially confirmed**: SRI does NOT pass `user_identity` into `JobFactory::new(...)` from `new_for_pool`. **However**, the slot exists, the byte budget reserves space for it, and the JDC constructor passes `miner_tag = Some(...)` into the same factory. The seam is unambiguously present.

## Evidence For
*(Sorted by evidence strength)*

1. **Strong (code) — SRI reference impl already plumbs `miner_tag` through `JobFactory`.** `ExtendedChannel::new_for_job_declaration_client` (extended.rs:167-195) and `StandardChannel::new_for_job_declaration_client` (standard.rs:158-182) both accept `miner_tag_string: String` and pass it to `JobFactory::new(version_rolling_allowed, pool_tag, miner_tag)`. The non-JD `new_for_pool` constructor calls the *same* private `new(...)` with `miner_tag = None`. Wiring `user_identity` (or any function thereof) into that argument is a one-line change. — [[raw/repos/2026-05-28-sri-channels-sv2-job-factory-and-channel-constructors]]

2. **Strong (code) — scriptSig byte budget already reserves `miner_tag` bytes.** Both extended.rs:232-243 and standard.rs:217-227 compute `script_sig_size` as a sum that includes `miner_tag.len()`. The Pool path computes against the budget today; the slot is empty (`miner_tag = None`), but the layout `/pool_tag/miner_tag/` is the canonical SRI scriptSig form regardless. — [[wiki/concepts/sv2-coinbase-scriptsig-layout]]

3. **Strong (spec silence) — Spec does not forbid Pool-side `user_identity` → coinbase.** SV2 spec part 05 defines `user_identity` and coinbase fields without coupling them, but never prohibits a Pool from making coinbase content a function of `user_identity`. The Pool's coinbase prefix/suffix bytes are explicitly Pool-controlled. — [[raw/articles/2026-05-28-sv2-spec-mining-protocol]]

4. **Strong (spec) — Per-channel coinbase variation is the default in SRI.** `ExtendedChannel::on_new_template` emits a per-channel `NewExtendedMiningJob`. Group-channel broadcast (`on_group_channel_job`) is opt-in. Standard channels carry only merkle_root in `NewMiningJob`, and the merkle_root is computed per-channel over per-channel `extranonce_prefix`. — [[wiki/concepts/job-factory-and-coinbase-construction]]

5. **Moderate (precedent) — BIP-22 establishes the scriptSig append-only pattern.** The traditional slot for miner-side coinbase additions is exactly where SRI places `/pool_tag/miner_tag/`. — [[raw/articles/2026-05-28-bip-22-getblocktemplate]]

6. **Moderate (production precedent) — OCEAN's DATUM Gateway ships per-miner coinbase tagging.** Concept exists in production. (DATUM uses miner-side construction, not Pool-side `user_identity` lookup, so this is precedent-for-feasibility, not precedent-for-mechanism.) — [[raw/articles/2026-05-28-ocean-datum-gateway-coinbase-tagging]]

## Evidence Against
*(Sorted by evidence strength)*

1. **Strong (spec semantics) — `user_identity` is normatively scoped to "identify/authenticate," not coinbase tagging.** The spec docstring is explicit. There is no normative coupling between `user_identity` and coinbase content. — [[raw/articles/2026-05-28-sv2-spec-mining-protocol]]

2. **Strong (working group consensus) — The SV2 working group's chosen mechanism for per-worker identity flow is extension 0x0002 on `SubmitSharesExtended`, not coinbase tagging.** PR #113 (merged Jun 2025) adds a TLV with `user_identity` ≤32 bytes for share-attribution. Authors / reviewers (TheBlueMatt, Fi3, GitGab19, jbesraa, jakubtrnka) chose this path; the predecessor PR #110 was abandoned. Nobody proposed coinbase tagging. — [[raw/articles/2026-05-28-sv2-spec-pr-113-worker-specific-hashrate-tracking]]

3. **Strong (architectural intent) — Per-miner coinbase customization is the explicit job of the JD protocol.** Spec part 06 frames non-JD operation as Pools "unilaterally imposing work on miners" and reserves coinbase customization for JDC. Doing pool-side `user_identity` → coinbase tagging gets the wire format but loses the trust property JD was designed for. — [[raw/articles/2026-05-28-sv2-spec-job-declaration-protocol]] [[wiki/concepts/coinbase-ownership-pool-vs-jdc]]

4. **Moderate (impl evidence) — SRI's `new_for_pool` deliberately discards `user_identity` before `JobFactory`.** This is not an oversight: the JDC constructor explicitly takes `miner_tag_string`, and the Pool constructor explicitly does not. The asymmetry is intentional in the current reference. — [[raw/repos/2026-05-28-sri-channels-sv2-job-factory-and-channel-constructors]]

5. **Moderate (size constraint) — 100-byte coinbase scriptSig limit makes long `user_identity` strings non-trivial.** After BIP-34 (5) + delimiters (3) + 2x OP_PUSHBYTES (2) + extranonce (≤32+rollable), only ~58-61 bytes remain for combined pool+miner tags. Long `user_identity` strings (e.g. UUIDs, email addresses) need truncation or hashing. — [[wiki/concepts/sv2-coinbase-scriptsig-layout]]

## Nuances & Caveats

- **"Signature" is wire-format only, not cryptographic.** Under the user's charitable reading, the per-miner string is a pool-asserted tag, not a verifiable signature. The Pool *could* be asked to sign `(user_identity, block_hash)` with a pool-known key and put the signature in a coinbase OP_RETURN output, but that is well outside the thesis as scoped.

- **Trust asymmetry vs JD path.** A Pool-side tag derived from `user_identity` is a trusting attribution. A miner cannot verify the tag without trusting the Pool to actually emit `f(user_identity)` and not `f(other_user_identity)`. JD path delivers the same wire format with verifiable provenance because the miner builds its own coinbase. [[wiki/concepts/coinbase-ownership-pool-vs-jdc]]

- **Channel-open `user_identity` vs per-share TLV.** The thesis as scoped uses the channel-open `user_identity`. On extended channels behind a proxy aggregating multiple workers, a single channel-open `user_identity` cannot disambiguate per-worker coinbase tags — the per-share `user_identity` from extension 0x0002 is needed. On a `NewMiningJob`/`NewExtendedMiningJob` boundary, however, only one coinbase exists per channel per template, so the channel-open identity is sufficient *only* in topologies where each downstream is a single worker (direct miner connections, or one-channel-per-worker proxies). [[wiki/concepts/extension-0x0002-worker-tracking-tlv]]

- **Group-channel broadcast vs per-channel emission.** If a Pool puts many channels in a group channel, the same `NewExtendedMiningJob` is broadcast to all. Per-miner coinbase tags require per-channel emission (the SRI default for `on_new_template`); a Pool that opts into group broadcast for bandwidth gives up per-miner tagging.

- **Scope of "without JD" matters.** The thesis is explicitly about the non-JD pipeline. Charitably, this is "the Pool's free hand on its own coinbase." Strictly, in JD mode, the Pool yields most coinbase agency to the JDC — `user_identity` reaches the Pool via `AllocateMiningJobToken`, but the bytes the Pool can add to a JDC-supplied coinbase are far more constrained.

## Verdict
**Status**: **Partially Supported**
**Confidence**: **High**

**Summary**: The thesis is **mechanically and architecturally feasible** in SV2 — the spec does not forbid it, and the SRI reference implementation already has the `miner_tag` slot, scriptSig byte budget, and `JobFactory` wiring in place; only the non-JD `new_for_pool` constructor's choice to pass `miner_tag = None` stands between the current behavior and the thesis behavior. However, this is **not the spec's intended use of `user_identity`** (which is scoped to authentication / identification), and the SV2 working group has explicitly chosen a different mechanism (extension 0x0002, share-submission TLV) for per-worker identity flow. The thesis is best understood as a *valid Pool-side implementation choice* rather than a *standard SV2 capability* — viable, off-spec but not anti-spec, and with weaker trust properties than the JD path.

**Strongest supporting evidence**:
- SRI `JobFactory::new(version_rolling_allowed, pool_tag, miner_tag)` already exists and the JDC constructor passes `Some(miner_tag_string)` into it. The non-JD asymmetry is a one-argument change away from the thesis.
- scriptSig 100-byte budget already reserves `miner_tag` bytes regardless of whether they're populated.
- `NewExtendedMiningJob` is emitted per-channel by default in `ExtendedChannel::on_new_template`; coinbase prefix/suffix can vary per-miner without leaving the spec.

**Strongest opposing evidence**:
- Spec scopes `user_identity` to identification/auth.
- SV2 working group's chosen mechanism for per-worker identity flow is share-submission TLV (ext 0x0002), not coinbase tagging.
- The proper architectural answer to "miner influences coinbase" is JD; `user_identity` → coinbase is a Pool-asserted attribution, not a verifiable property.

**Key caveats**:
- Trust property is weak: Pool-asserted tag, not miner-verifiable.
- 100-byte scriptSig budget constrains the size of `f(user_identity)` to ~30-40 bytes after pool tag + extranonce.
- Group-channel broadcast incompatibility.

**What would change this verdict**:
- A merged SV2 spec PR (or BIP) that *standardizes* a Pool-side `user_identity` → coinbase mapping → would move to **Supported**.
- An SRI PR that wires `user_identity` into `new_for_pool`'s `miner_tag` slot → would move to **Supported (in reference impl)**.
- A Pool implementation shipping this in production → strong supporting precedent.
- An SV2 spec change adding "MUST NOT use `user_identity` for coinbase content" → would move to **Contradicted**.

**Suggested follow-up theses**:
1. *"A `user_identity`-derived coinbase tag emitted Pool-side is sufficient for downstream-verifiable hashrate attribution"* — would test the trust-property concern.
2. *"sv2-apps Pool can adopt `user_identity` → `miner_tag` wiring without breaking interoperability with existing SV2 miners"* — purely an implementation thesis.
3. *"Per-channel coinbase tag emission in SV2 is bandwidth-acceptable at 100k+ channels vs. group-channel broadcast"* — operational thesis.
