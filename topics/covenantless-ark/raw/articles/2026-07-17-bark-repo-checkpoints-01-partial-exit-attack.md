---
title: "Partial exit attack (bark docs/checkpoints/01)"
source: "https://gitlab.com/ark-bitcoin/bark/-/blob/4f1b646ae3c4387bd374d835f76719637a48b846/docs/checkpoints/01_problems_withouth_checkpoints.md"
type: articles
ingested: 2026-07-17
tags: [collection, bark-repo, ark, clark, hark, checkpoint, partial-exit, griefing, attack, exit-delta]
summary: "The motivating attack for checkpoint transactions: an attacker builds a deep 4-ary arkoor tree (e.g. 4^5 = 1024 VTXOs), refreshes into a single VTXO, then partial-exits only the original VTXO — forcing the server to broadcast 1000+ forfeit txs or lose the forfeited funds."
collection: "bark-repo"
adapter: git
upstream_id: "docs/checkpoints/01_problems_withouth_checkpoints.md"
upstream_type: git-file
revision: "4f1b646ae3c4387bd374d835f76719637a48b846"
sha: "0da127d51d4849dacc175f2a06bc60bbd05f18bc"
canonical_url: "https://gitlab.com/ark-bitcoin/bark/-/blob/4f1b646ae3c4387bd374d835f76719637a48b846/docs/checkpoints/01_problems_withouth_checkpoints.md"
content_format: markdown
license: "MIT"
fetched: 2026-07-17
---

# Partial exit attack (bark docs/checkpoints/01)

Motivating example for [[../../wiki/concepts/checkpoint-transactions.md|checkpoint transactions]]. Part of the [[../repos/2026-07-17-collection-bark-repo-manifest.md|bark-repo collection]].

## The attack (Alice tries to steal server funds)

Alice needs a single VTXO. Steps:
1. Construct a tree of out-of-round (arkoor) transactions.
2. Refresh all her VTXOs in a round.
3. Perform a partial exit.
"At the end of the attack the server has to broadcast the forfeits. However... the server cannot economically do this."

## Constructing the tree
- Start: `⚓funding ─> node ─┬─> leaf ──> vtxo A` (⚓ = confirmed on-chain; all other txs off-chain).
- Alice's VTXO = 1 BTC. She spends it out-of-round into a tx with **4 outputs**, then repeats for each output.
- Repeat **5 times → 4·4·4·4·4 = 1024 VTXOs**.

## Participating in a round
- Alice refreshes her 1024 VTXOs and gets a **single** VTXO in return.

## The malicious partial exit
- Alice brings only the **original** VTXO on-chain. All 1024 leaf VTXOs have been forfeited, so the server must respond.
- Alice can claim her on-chain VTXO's funds after **`exit_delta` blocks**.
- The server's dilemma:
  - publish the **full tree (>1000 txs)** and pay the on-chain cost, OR
  - **lose funds** to Alice.
- "Alice can make this attack exponentially more effective by splitting the tree one level more."

## Takeaway
The forfeit-based penalty (see [[../../wiki/concepts/forfeit-and-connectors.md|forfeits and connectors]]) is economically defeatable without checkpoints, because the server's defensive broadcast cost scales with the attacker-chosen tree size. Checkpoints bound that cost to a single tx (see doc 03).
