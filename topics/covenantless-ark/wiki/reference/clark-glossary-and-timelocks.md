---
title: "Reference: clArk glossary, terminology map, and timelock table"
type: reference
created: 2026-07-16
updated: 2026-07-17
confidence: high
volatility: warm
verified: 2026-07-17
sources:
  - raw/articles/2026-07-17-second-docs-learn-glossary.md
  - raw/articles/2026-07-17-second-docs-learn-vtxo.md
  - raw/articles/2026-07-17-second-docs-learn-liquidity.md
  - raw/articles/2026-07-17-second-docs-learn-lifetime.md
  - raw/articles/2026-07-17-second-docs-learn-rounds.md
  - raw/articles/2026-07-17-bark-repo-docs-addresses.md
  - raw/articles/2026-07-17-bark-repo-docs-movements.md
  - raw/articles/2026-07-17-bark-repo-checkpoints-03-designing-checkpoints.md
  - raw/repos/2026-07-16-implementations-arkd-go-source.md
tags: [ark, clark, hark, glossary, terminology, timelocks, reference, arkd, bark, boat-001, quad-tree]
aliases: [glossary, timelock table, terminology map, script policies]
summary: "Terminology map across litepaper / bark / arkd, glossary, script policies (incl. bark's exact CLTV/CSV opcodes and the checkpoint policy), timelock table, structural constants (arkd radix 2 vs bark radix 4), the liquidity-cost formula, and the repo/standards list."
---

# Reference: clArk glossary, terminology map, and timelock table

## Terminology map (same object, different names)

The single biggest source of confusion is that the litepaper, Second (`bark`), and Ark Labs (`arkd`/Arkade) use different words for the same things.

| Concept | Litepaper | Second / `bark` | Ark Labs / `arkd` / Arkade |
|---|---|---|---|
| The on-chain round tx | **commitment transaction** | **round transaction** | **commitment transaction** |
| The pooled on-chain output | **batch** (output) | **pool / round output** | **batch output** |
| The round ceremony | (batch swap) | **round** | **batch swap** |
| Tree of virtual txs | **VTXT** | transaction tree | **VTXO tree** |
| Refresh a VTXO | — | **refresh** | **settle** |
| Instant P2P off-chain payment | — | **OOR / arkoor** | **preconfirmed / offchain Arkade tx** |
| Forfeit atomicity primitive | connector | **hash-lock (rounds)** / connector (payments) | **connector** |
| VTXO tree radix | — | **quad (4)** | **binary (2)** |
| Cooperative withdrawal | — | **offboarding** | **offboarding** |

## Glossary

- **VTXO (Virtual UTXO)** — off-chain unit of value; a leaf of the pre-signed tree. Three types: **board** (from on-chain deposits), **refresh** (from rounds; arkd "settle"), **spend** (from arkoor). [[../concepts/vtxo-and-vtxo-tree.md|→]]
- **ASP / operator / server** — the Ark Service Provider coordinating rounds, co-signing spends, fronting liquidity, and acting as the Lightning gateway. (bark: "Ark server".)
- **Batch / pool output** — the single n-of-n-locked on-chain output rooting the VTXO tree. [[../concepts/n-of-n-batch-output.md|→]]
- **Root / Branch / Leaf** — (bark) the three tx roles in a tree: Root = the only on-chain tx; Branch = off-chain value split; Leaf = a user's individual exit tx.
- **Pseudo-covenant** — n-of-n MuSig2 pre-signing + ephemeral-key deletion, standing in for `OP_CTV`. [[../concepts/tree-presigning-musig2.md|→]]
- **Forfeit transaction** — user relinquishes an old VTXO; bound to the round's confirmation via a connector or hash-lock. [[../concepts/forfeit-and-connectors.md|→]]
- **Connector** — dust anchor output that makes a forfeit valid only if the round/payment tx confirms.
- **Hash-lock (preimage) forfeit** — bark's round-forfeit atomicity: server shares a hash, reveals the preimage to claim the old VTXO, which simultaneously releases the new one. Under live hArk, forfeits commit only to this preimage/hash.
- **Checkpoint transaction** — two-output anti-griefing intermediate state (policy `A+S or S+T`); bounds the server's defensive exit cost to one tx and isolates a neighbour's exit. In both arkd and bark; makes OOR exit two-stage. [[../concepts/checkpoint-transactions.md|→]]
- **Unilateral / emergency exit** — force a VTXO on-chain without the ASP, via the timeout (CSV) leaf. [[../concepts/unilateral-exit-and-timeouts.md|→]]
- **Offboarding** — the standard cooperative single-tx withdrawal to on-chain (preferred over emergency exit). [[../concepts/offboarding-and-onchain-payments.md|→]]
- **Sweep** — the ASP reclaiming expired/un-refreshed (forfeited) funds via the batch output's absolute-timelock path. [[../concepts/vtxo-lifetime-and-expiry.md|→]]
- **Lifetime** — the time limit on a VTXO before the server can sweep it (~28-30 d standard, ~3 d Lightning-receive). [[../concepts/vtxo-lifetime-and-expiry.md|→]]
- **Boarding** — bringing on-chain funds into a board VTXO. [[../concepts/boarding.md|→]]
- **Chain anchor** — (bark) the on-chain tx output a VTXO's validity depends on (e.g. the board tx).
- **OOR / arkoor** — "Ark out-of-round"; instant P2P payment creating spend VTXOs; enables offline receiving. [[../concepts/out-of-round-payments.md|→]]
- **In-round** — (bark) VTXOs included in the tree embedded in the round transaction (vs out-of-round arkoor).
- **Ark address** — bech32m `ark1`/`tark1` string encoding server-pubkey hash + VTXO policy + delivery methods; specified by **BOAT-001**. [[../concepts/ark-addresses-and-delivery.md|→]]
- **BOAT** — a cross-Ark specification (github.com/ark-protocol/boats), analogous to a BIP/BOLT. BOAT-001 defines the address format.
- **Unified Mailbox** — (bark, mostly planned) server-side notification hub for arkoor / BOLT-11/12 / non-interactive hArk-refresh VTXOs. [[../concepts/ark-addresses-and-delivery.md|→]]
- **Lightning gateway** — a Lightning node run by the Ark server, giving users LN reach without channels. [[../concepts/lightning-integration.md|→]]
- **Movement** — (bark) a wallet-level accounting record of a balance/VTXO change; seven subsystems (arkoor, board, offboard, exit, lightning_send, lightning_receive, round).
- **Delegated refresh** — designated co-signers refresh a user's VTXOs on their behalf (for mobile devices).
- **Intent** — (Arkade) a BIP322-signed ownership proof committing to the outputs a user wants.
- **clArk** — covenant-less Ark: recursive multisigs instead of CTV covenants.
- **hArk** — hash-lock Ark. **Live in bark since January 2026** as a covenantless hash-lock enhancement (non-interactive refresh, immediate on-chain broadcast); the fuller CTV-based proposal remains future work. [[../topics/clark-vs-covenant-ark.md|→]]
- **Erk** — proposed CTV+CSFS successor (rebindable signatures → async signup + perpetual offline refresh); needs a soft fork. [[../topics/clark-vs-covenant-ark.md|→]]

## Script policies (Roose, current clArk)

- **Node policy**: `(A + B + C + ... + S) or (S + T_exp)`
- **Leaf policy**: `(A + S) or (S + T_exp)`
- **Exit policy**: `(A + S) or (A + T_exp + Δt)`

(A/B/C = user keys; S = server key; `T_exp` = absolute expiry; `Δt` = relative exit delay.)

### bark exact opcodes (VTXO two-path script)

- **Cooperative path**: branches = n-of-n MuSig2 (all users on that branch + server); leaves = 2-of-2 (user + server).
- **Timelocked recovery path**: roots/branches = **absolute CLTV** `<expiry-height> OP_CHECKLOCKTIMEVERIFY`; user exit = **relative CSV** `<144> OP_CHECKSEQUENCEVERIFY` (~1 day).

### Checkpoint transaction policies (bark checkpoints/03)

- Original VTXO: `A + S or A + delta`
- Checkpoint (two outputs): `A + S or S + T` (exit path shifts to the server after timeout)
- New VTXOs: `B + S or S + delta` / `A + S or S + delta`

## Timelock table

Values are implementation- and deployment-configurable. arkd defaults are **second-based** and must be BIP-68 multiples of 512.

| Parameter | arkd default | ark-protocol.org | bark |
|---|---|---|---|
| VTXO tree / batch expiry (`T_exp`, absolute) | 604672 s (~7 d) | 14 d | ~28-30 d (standard) |
| Lightning-receive VTXO lifetime | — | — | ~3 d |
| Unilateral exit delay (`Δt`, relative CSV) | 86400 s (24 h) | 24 h | `vtxo_exit_delta` blocks (`<144>` ~1 d) |
| Checkpoint exit delay | 86400 s (24 h) | — | — |
| Boarding exit delay | 7776000 s (~90 d) | — | — |
| Board VTXO activation | — | — | 6 confirmations |
| Intent-collection window | ~30 s | — | — |
| Round cadence | (config) | — | ~1-2 h (config) |
| Griefing ban | 300 s | — | — |
| Heartbeat interval | 60 s | — | — |

## Liquidity-cost formula (bark)

```
liquidity_cost = amount x (expiry_delta / 365 days) x opportunity_rate
```

Worked example: 100,000 sat VTXO, 5 days remaining, 5% opportunity rate → **68 sats**. Fresh VTXOs cost more to refresh (capital committed longer); near-expiry ones cost less. See [[../concepts/vtxo-lifetime-and-expiry.md|VTXO lifetime and expiry]].

## Structural constants

- **VTXO tree radix**: arkd = **2** (binary); **bark = 4** (quad tree). arkd connector tree radix = **4** (quaternary).
- Forfeit tx (arkd) = **2 inputs** (VTXO + connector), version **3 / TRUC**, P2A anchor.
- Commitment tx output order (arkd): 0 = VTXO tree root, 1 = connector tree root, 2+ = collaborative exits, last = operator change.
- Basic exit tx ≈ **124 vB**; unilateral exit cost = **O(log t)** in batch size.
- bark VTXO tree structure by type: board = "Root → Leaf" (2 txs); refresh = "Root → Branches → Leaf" (3+ txs).
- bark wallet movement subsystems (7): `arkoor`, `board`, `offboard`, `exit`, `lightning_send`, `lightning_receive`, `round`.

## Implementations & repos

- **Second — `bark`** (Rust): gitlab.com/ark-bitcoin/bark (mirror github.com/ark-bitcoin/bark). Server `captaind`/`barkd`. Docs: second.tech/docs.
- **Ark Labs — `arkd` / Arkade** (Go): github.com/arkade-os/arkd (and ark-network/ark). Docs: docs.arkadeos.com.
- **Canonical protocol docs**: ark-protocol.org.
- **Litepaper**: assets.arklabs.xyz/ark-protocol.pdf.
- **Standards**: V-PACK/MVV `libvpack-rs`, vtxopack.org.

## See also

- [[../concepts/clark-overview.md|clArk overview]]
- [[../topics/clark-round-transaction-mechanics.md|Round transaction mechanics]]
- [[../concepts/vtxo-lifetime-and-expiry.md|VTXO lifetime and expiry]]
- [[../concepts/ark-addresses-and-delivery.md|Ark addresses and VTXO delivery]]
- [[../../raw/_index.md|Raw sources]]

## Sources

- [Ark protocol glossary (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-glossary.md) — verbatim term definitions
- [Ark VTXOs (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-vtxo.md) — quad tree, exact CLTV/CSV opcodes, tree-role names
- [Ark liquidity (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-liquidity.md) — the liquidity-cost formula
- [VTXO lifetime (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-lifetime.md) — lifetime/sweep terms
- [Ark rounds (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-rounds.md) — 1-2h cadence, shared expiry
- [Ark Addresses (bark docs/addresses.md)](../../raw/articles/2026-07-17-bark-repo-docs-addresses.md) — bech32m, BOAT-001, delivery
- [Movement System (bark docs/movements.md)](../../raw/articles/2026-07-17-bark-repo-docs-movements.md) — the seven wallet subsystems
- [Designing checkpoints (bark checkpoints/03)](../../raw/articles/2026-07-17-bark-repo-checkpoints-03-designing-checkpoints.md) — checkpoint script policies
- [arkd Go source](../../raw/repos/2026-07-16-implementations-arkd-go-source.md) — arkd radices, timelock constants, tx structure
