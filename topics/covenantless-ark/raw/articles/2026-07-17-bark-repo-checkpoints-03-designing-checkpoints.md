---
title: "Checkpoint transactions design (bark docs/checkpoints/03)"
source: "https://gitlab.com/ark-bitcoin/bark/-/blob/4f1b646ae3c4387bd374d835f76719637a48b846/docs/checkpoints/03_designing_checkpoints.md"
type: articles
ingested: 2026-07-17
tags: [collection, bark-repo, ark, clark, hark, checkpoint, arkoor, script-policy, exit, sweep]
summary: "Design of checkpoint transactions: each arkoor transaction inserts an extra two-output checkpoint tx (policy A+S or S+T) between the original VTXO and the new VTXOs, isolating a party's exit and bounding the server's defensive response to a single tx (output count should be limited)."
collection: "bark-repo"
adapter: git
upstream_id: "docs/checkpoints/03_designing_checkpoints.md"
upstream_type: git-file
revision: "4f1b646ae3c4387bd374d835f76719637a48b846"
sha: "798d3fa65cca676b03480dcf47f533ce81ec0b7a"
canonical_url: "https://gitlab.com/ark-bitcoin/bark/-/blob/4f1b646ae3c4387bd374d835f76719637a48b846/docs/checkpoints/03_designing_checkpoints.md"
content_format: markdown
license: "MIT"
fetched: 2026-07-17
---

# Checkpoint transactions design (bark docs/checkpoints/03)

The design resolving docs 01 (partial-exit attack) and 02 (neighbour exit). Part of the [[../repos/2026-07-17-collection-bark-repo-manifest.md|bark-repo collection]]. See [[../../wiki/concepts/checkpoint-transactions.md|checkpoint transactions]].

## The construction
"When making an arkoor-transaction we will add an extra checkpoint transaction."

```
(original vtxo)                    (Checkpoint)                (bob's new VTXO)
+-------+--------------------+     +----------------------+    +------+---------------------+
| 2 BTC | A + S or A + delta | --> | 1 BTC | A + S or S + T| -> | 1 BTC | B + S or S + delta |
+----------------------------+     +----------------------+    +------+---------------------+
                                   | 1 BTC | A + S or S + T| -┐  (Alice's new VTXO)
                                   +----------------------+  │ +-------------------------------+
                                                             └>| 1 BTC | A + S or S + delta    |
                                                               +-------+-----------------------+
```

## Why two outputs on the checkpoint
- "the checkpoint transaction has two outputs. This is intentional. If Bob would exit only the checkpoint transaction and his exit transaction goes onchain, **Alice's VTXOs would be unaffected**. Alice can still use her change VTXO and the server can sweep the checkpoint after expiry." → solves doc 02 (neighbour exit).

## Why it bounds the server's cost
- "if Alice would construct a tree of transactions the server can always respond cheaply. The server just has to broadcast **a single exit transaction**." → solves doc 01 (partial-exit attack).
- Caveat: "If the exit transaction is huge this would still be expensive. Therefore, **the server should limit the number of outputs in the checkpoint transaction**."

## Script policies (verbatim)
- Original VTXO: `A + S or A + delta`
- Checkpoint outputs: `A + S or S + T` (note: exit path shifts to **server** after timeout T — "removing the exit script path from the VTXO script leaf, transferring it to the server", matching the Arkade docs' checkpoint description)
- New VTXOs: `B + S or S + delta` / `A + S or S + delta`
