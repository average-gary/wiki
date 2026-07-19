---
title: "Second's Ark/clArk docs (second.tech/docs) — the bark reference impl"
source_url: https://second.tech/docs
type: article
publisher: Second
ingested: 2026-07-16
research_path: implementations
credibility: high
confidence: high
quality_score: 5
status: superseded
superseded_by: 2026-07-17-second-tech-docs-learn-manifest.md
tags: [ark, bark, clark, rounds, forfeit, hashlock, connector, boarding, arkoor, sweep, second, rust, superseded]
summary: "[SUPERSEDED 2026-07-17 by the second.tech/docs Learn-section collection ingest.] Official docs of the original clArk reference implementation (Second's bark, Rust). Five-phase round lifecycle, two-path VTXO exit script (CSV), and the KEY divergence from arkd — bark uses hash-lock/preimage atomicity for ROUND forfeits, connectors only for on-chain payments."
---

> **⚠ Superseded (2026-07-17)** — This single-file summary is replaced by the granular collection ingest at [[2026-07-17-second-tech-docs-learn-manifest.md]] (14 per-page raw children). Retained for provenance. The collection adds detail this file lacked (quad-tree radix, exact CLTV/CSV scripts, liquidity cost formula) and corrects the hArk framing: **hArk went live in January 2026** (this file predates that finding).

# Second's Ark/clArk docs (second.tech/docs)

Fetched 2026-07-16. Index at `/llms.txt` (formerly docs.second.tech). `bark` = original clArk Rust reference impl. Uses classic "round / round transaction" terminology.

## Round lifecycle — five phases (`/learn/rounds`)
1. **Submit intent** — "Wallet app comes online during round and submits VTXOs to refresh"
2. **Tree construction** — "Server constructs transaction tree; wallet app signs exit branches"
3. **Funding** — "Server broadcasts round transaction on-chain"
4. **Forfeit** — "Wallet app signs forfeit to complete refresh"
5. **Claim** — "New VTXO immediately accessible"
- Users + server "together create a transaction tree and broadcast its root on-chain—the round transaction." Rounds run periodically, interval "in the region of an hour, but it's configurable."

## VTXO exit script — two paths (`/learn/forfeits`)
1. **2-of-2 multisig** user+server, **no timelock** (collaborative/server-claim path)
2. **user-only** with "a relative timelock of `{{ ark.vtxo_exit_delta }}` blocks... implemented using OP_CHECKSEQUENCEVERIFY (CSV)" (unilateral exit)

## Two atomicity mechanisms for forfeits (`/learn/forfeits`) — KEY DIVERGENCE FROM arkd
- **(a) Rounds use hash-locks** — "The server generates a preimage for each VTXO, sharing only its hash"; both VTXO and forfeit carry hash-lock conditions so "neither can be used on-chain without providing the preimage."
- **(b) On-chain payments use connectors** — "Because the user's forfeit requires the connector output to exist, the forfeit cannot be used unless the corresponding payment transaction is confirmed first."
- NOTE: this differs from arkd, which uses **connectors for the round forfeits** (not hash-locks).

## Emergency/unilateral exit (`/learn/exit`)
- User broadcasts tree txs in sequence "from the root of the transaction tree... broadcasting each branch transaction and waiting for confirmation, until reaching the leaf"; funds on-chain only once the leaf exit tx confirms.

## VTXO lifetime & sweep (`/learn/lifetime`, `/learn/intro`)
- "VTXO lifetime is expected to be in the region of 30 days" — differs from arkd's ~7-day default.
- Enables "the Ark server to claim all forfeited bitcoin in an expired round using a single on-chain transaction."
- "When a VTXO reaches its expiry height, the server gains the ability to sweep any remaining bitcoin to its own wallet through the timelock spend paths."

## VTXO types
- **board VTXOs** and **spend VTXOs (a.k.a. "arkoor")**; each tree leaf "is controlled by a single user and corresponds to a single VTXO."
- Rounds are how users "refresh their VTXOs—forfeit old VTXOs for new ones."

## Boarding flow (`/learn/board`)
- User cooperatively builds "a funding transaction and an exit transaction" with the server; both pre-sign the exit tx (spends the funding output) so the user can always exit unilaterally.
- Board VTXO "becomes active and spendable" after **six confirmations** of the funding tx.
- Boarding happens "outside of the server's normal round schedule." Atomic: "either both the on-chain funding and VTXO creation succeed together, or both fail together."

## Repo / module structure (GitHub README)
- Crates: `bark`, `bark-cli`, `bark-rest`, `bark-rest-client`, `bark-json`, `captaind` (server), `server`, `server-rpc`, `server-log`, `bip321`, `bitcoin-ext`, `cln-rpc`, `lib`, `fuzz`, `testing`, `nix`. ~95% Rust.
- Repo mirror at github.com/ark-bitcoin/bark; primary on GitLab (gitlab.com/ark-bitcoin/bark).
- "Multiple users share control of a single bitcoin UTXO through a tree of pre-signed, off-chain transactions."
