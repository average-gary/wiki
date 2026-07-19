---
title: "Collection: bark repository design docs (gitlab.com/ark-bitcoin/bark)"
source: "https://gitlab.com/ark-bitcoin/bark"
type: repos
ingested: 2026-07-17
tags: [collection, collection-manifest, git, ark, clark, hark, bark, second]
summary: "Manifest for a git collection ingest of the bark repo's hand-written design docs (9 child sources captured at commit 4f1b646a). bark is Second's Rust implementation of Ark (clArk/hArk); the wallet is bark, the server is captaind. ~180 generated OpenAPI client stubs and dev-tooling docs were excluded (documented below)."
collection: "bark-repo"
adapter: git
revision: "4f1b646ae3c4387bd374d835f76719637a48b846"
canonical_url: "https://gitlab.com/ark-bitcoin/bark"
license: "MIT"
---

# Collection: bark repository design docs

`gitlab.com/ark-bitcoin/bark` — Second's Rust implementation of Ark (clArk/hArk lineage). Wallet = **bark**; server = **captaind**; plus protocol-primitive libraries (`ark-lib`, `bark-bitcoin-ext`, `bip321`, `cln-rpc`, `bark-rest`, `bark-json`, etc.). License **MIT**. Cloned shallow at HEAD **4f1b646a** on 2026-07-17.

## Scope decision (design docs only)

The repo's HEAD tree has 209 text-like `.md` files, but **~180 are auto-generated OpenAPI DTO stubs** under `bark-rest-client/docs/` (`ExitErrorOneOf27.md`, `RoundStatusOneOf5.md`, …). Per the git-adapter rule (exclude generated assets), those are not primary sources.

**INGESTED — 9 hand-written design/overview docs:**
1. [[../articles/2026-07-17-bark-repo-readme.md]] — repo README (project overview, MSRV, security keys)
2. [[../articles/2026-07-17-bark-repo-bark-readme.md]] — bark crate README (Rust API tour)
3. [[../articles/2026-07-17-bark-repo-docs-addresses.md]] — Ark address format (bech32m, BOAT-001, policies, delivery)
4. [[../articles/2026-07-17-bark-repo-docs-mailbox.md]] — Unified Mailbox (planned)
5. [[../articles/2026-07-17-bark-repo-docs-offboard-swaps.md]] — offboard swaps (in-round vs hArk connector swaps)
6. [[../articles/2026-07-17-bark-repo-docs-movements.md]] — wallet movement/accounting data model
7. [[../articles/2026-07-17-bark-repo-checkpoints-01-partial-exit-attack.md]] — the partial-exit attack (motivation)
8. [[../articles/2026-07-17-bark-repo-checkpoints-02-neighbour-exit.md]] — the neighbour-exit problem
9. [[../articles/2026-07-17-bark-repo-checkpoints-03-designing-checkpoints.md]] — checkpoint tx design

**EXCLUDED (documented, not silently dropped):**
- **~180 generated OpenAPI client stubs** — `bark-rest-client/docs/*.md` (DTO/enum/API-method stubs from the REST client generator).
- **Dev / agent-tooling meta** — `CLAUDE.md`, `AGENTS.md`, `contrib/agents/**` (agent skills: review, debug-ci, writing-tests, release-tagging, protocol-encoding, database-schema, corrections, documentation, prompts, running-and-debugging-tests), `contrib/README.md`, `contrib/docker/README.md`, `fuzz/README.md`.
- **Misc crate READMEs** — `bark-rest-client/README.md`, `bark-rest/CLAUDE.md`, `cln-rpc/README.md`.
- **Non-doc** — `CHANGELOG*`, `LICENSE`, `CONTRIBUTING*`, `Cargo.*`, `flake.*`, scripts, `assets/` images, all `.rs` source.

If the REST API surface or per-crate docs are later needed, re-run `/wiki:ingest-collection https://gitlab.com/ark-bitcoin/bark --include 'bark-rest-client/docs/*'`.

## Relationship to existing sources

Complements the [[../articles/2026-07-17-second-tech-docs-learn-manifest.md|second.tech/docs Learn collection]] (the prose docs) with **repo-internal design rationale** — especially the checkpoints trilogy, which gives the concrete **partial-exit attack** that motivates [[../../wiki/concepts/checkpoint-transactions.md|checkpoint transactions]], and `offboard-swaps.md` which explains why hArk changes offboard mechanics (forfeits commit only to a preimage/hash, not the whole funding tx).

## Notable findings

- **hArk offboard change**: "With hArk... forfeits only commit to a single unlock preimage/hash... no longer an automatic commit to the entire funding tx" → in-round offboards need an extra hash-condition; **connector swaps** proposed to deprecate round-based offboards.
- **Partial-exit attack**: an attacker builds a deep arkoor tree (4-ary, e.g. 4⁵ = 1024 VTXOs), refreshes into one VTXO, then partial-exits only the original — forcing the server to either broadcast 1000+ forfeit txs or lose funds. Checkpoint txs bound the server's defense to a single tx.
- **Checkpoint script**: `A + S or A + delta` (original) → checkpoint `A + S or S + T` (two outputs) → new VTXO `B + S or S + delta`. Two-output checkpoint isolates a neighbour's exit so others' change VTXOs stay off-chain.
- **Ark addresses**: bech32m `ark1`/`tark1`, cross-Ark spec **BOAT-001** (github.com/ark-protocol/boats), encodes server-pubkey 4-byte hash + VTXO policy + delivery methods.
- **Security contacts**: Steven Roose + Erik De Smedt PGP keys; `security@second.tech`.
