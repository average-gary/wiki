---
title: "Movement System (bark docs/movements.md)"
source: "https://gitlab.com/ark-bitcoin/bark/-/blob/4f1b646ae3c4387bd374d835f76719637a48b846/docs/movements.md"
type: articles
ingested: 2026-07-17
tags: [collection, bark-repo, ark, bark, movements, accounting, wallet, data-model, subsystems, vtxo]
summary: "bark's wallet-level accounting model. A 'movement' records every balance/VTXO change with a common schema (status, subsystem{name,kind}, intended/effective balance, fees, sent_to/received_on, input/output/exited VTXOs). Seven subsystems: arkoor, board, offboard, lightning_send, lightning_receive, round, exit."
collection: "bark-repo"
adapter: git
upstream_id: "docs/movements.md"
upstream_type: git-file
revision: "4f1b646ae3c4387bd374d835f76719637a48b846"
sha: "ac6f2612693d8cea05c347b1f28498eb72d88e0a"
canonical_url: "https://gitlab.com/ark-bitcoin/bark/-/blob/4f1b646ae3c4387bd374d835f76719637a48b846/docs/movements.md"
content_format: markdown
license: "MIT"
fetched: 2026-07-17
---

# Movement System (bark docs/movements.md)

Part of the [[../repos/2026-07-17-collection-bark-repo-manifest.md|bark-repo collection]]. Wallet-level accounting/data-model doc (643 lines upstream; key structure captured here).

## What a "movement" is
"The movement system tracks all balance and VTXO changes within bark. Each movement represents a distinct action that the wallet performs."

## Core schema fields
- `id`, `status` (`pending`/`successful`/`failed`/`canceled`), `subsystem` (`{name, kind}`)
- `intended_balance_sat` / `effective_balance_sat` (i64; negative = outgoing, positive = incoming; effective = after fees)
- `offchain_fee_sat` (u64), plus `metadata.onchain_fee_sat` for Bitcoin network fees
- `sent_to` / `received_on` (arrays of `MovementDestination`)
- `input_vtxos` (consumed) / `output_vtxos` (created) / `exited_vtxos` (marked for emergency exit)
- `time` (`created_at`/`updated_at`/`completed_at?`), `metadata` (subsystem-specific)

## PaymentMethod (tagged union)
`ark` (ark address), `bitcoin` (btc address), `output-script` (hex), `invoice` (BOLT11/12), `offer` (BOLT12), `lightning-address` (email@domain), `custom`.

## Seven subsystems and their movement kinds
| Subsystem | Kind(s) | Description |
|---|---|---|
| `bark.arkoor` | `send`, `receive` | Offchain transfers between ark users |
| `bark.board` | `board` | On-chain → ark |
| `bark.offboard` | `offboard`, `send_onchain` | Ark → on-chain |
| `bark.exit` | `start` | Initiation of emergency exits |
| `bark.lightning_send` | `send` | Send via Lightning |
| `bark.lightning_receive` | `receive` | Receive via Lightning |
| `bark.round` | `refresh` | Round participation methods |

## Why it's useful here
The subsystem taxonomy is a clean enumeration of the wallet-visible operations that map onto the protocol mechanics documented elsewhere in this wiki (arkoor↔[[../../wiki/concepts/out-of-round-payments.md|OOR]], board↔[[../../wiki/concepts/boarding.md|boarding]], round↔[[../../wiki/concepts/clark-round-lifecycle.md|rounds]], exit↔[[../../wiki/concepts/unilateral-exit-and-timeouts.md|unilateral exit]]). Balance semantics (intended vs effective, VTXO consumed/created/exited) are the accounting counterpart to those flows.
