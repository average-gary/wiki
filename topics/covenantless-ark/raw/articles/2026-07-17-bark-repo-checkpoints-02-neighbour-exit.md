---
title: "Help, my neighbour exited (bark docs/checkpoints/02)"
source: "https://gitlab.com/ark-bitcoin/bark/-/blob/4f1b646ae3c4387bd374d835f76719637a48b846/docs/checkpoints/02_help_my_neighbour_did_an_exit.md"
type: articles
ingested: 2026-07-17
tags: [collection, bark-repo, ark, clark, checkpoint, exit, change-vtxo, shared-tx]
summary: "Second motivating example for checkpoints: because a payment's change VTXO shares a transaction with the recipient's VTXO, one user's unilateral exit can drag an innocent neighbour's change VTXO on-chain, imposing unexpected on-chain costs."
collection: "bark-repo"
adapter: git
upstream_id: "docs/checkpoints/02_help_my_neighbour_did_an_exit.md"
upstream_type: git-file
revision: "4f1b646ae3c4387bd374d835f76719637a48b846"
sha: "3ca82787e8edaac5da1e5c75e46b5a0bb098a080"
canonical_url: "https://gitlab.com/ark-bitcoin/bark/-/blob/4f1b646ae3c4387bd374d835f76719637a48b846/docs/checkpoints/02_help_my_neighbour_did_an_exit.md"
content_format: markdown
license: "MIT"
fetched: 2026-07-17
---

# Help, my neighbour exited (bark docs/checkpoints/02)

Second motivating example for [[../../wiki/concepts/checkpoint-transactions.md|checkpoint transactions]]. Part of the [[../repos/2026-07-17-collection-bark-repo-manifest.md|bark-repo collection]].

## The problem: an exit shouldn't drag your funds on-chain
- "As a user of Ark you want predictability. If your funds hit the chain you will have unexpected costs."
- In an arkoor payment, the sender's **change VTXO** is an output of the **same transaction** as the recipient's VTXO:
  ```
  ⚓funding ─> node ─┬─> leaf ──> vtxo A ─┬─> vtxo B
                                          └─> vtxo A (change)
  ```
- When Bob unilaterally exits, he brings that shared transaction on-chain — dragging **Alice's change VTXO** on-chain too:
  ```
  ⚓funding ─> ⚓node ─┬─> ⚓leaf ──> ⚓vtxo A ─┬─> vtxo B
                                                └─> vtxo A (change)
  ```
- Alice incurs unexpected on-chain cost through no action of her own.

## Takeaway
Checkpoint transactions (doc 03) give each arkoor spend its own two-output checkpoint so that one party's exit does not force a neighbour's change VTXO on-chain.
