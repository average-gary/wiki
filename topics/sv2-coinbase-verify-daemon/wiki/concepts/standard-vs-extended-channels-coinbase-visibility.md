---
title: "Standard vs extended channels — coinbase visibility"
type: concept
created: 2026-07-21
updated: 2026-07-21
confidence: high
tags: [stratum-v2, standard-channel, extended-channel, header-only-mining, NewMiningJob, NewExtendedMiningJob, merkle_root]
---

# Standard vs extended channels — coinbase visibility

The single most important design fact for this daemon: **which SV2 channel type you
open determines whether you can see the coinbase at all.**

## Standard channel → no coinbase, ever

Standard channels do **header-only mining (HOM)**. Per the spec: *"Standard Jobs are
restricted to fixed Merkle Roots, where the only modifiable bits are under the
`version`, `nonce`, and `nTime` fields of the block header."* The upstream computes the
merkle root and hands it over in **`NewMiningJob`**, whose only content-bearing field
is **`merkle_root` (U256)** — no `coinbase_tx_prefix`, no `coinbase_tx_suffix`, no
`merkle_path`. The `mining_sv2::NewMiningJob` struct confirms this field-for-field.

A one-way hash discards everything: from a 32-byte merkle root you cannot recover the
payout address, the value, or any scriptSig tag. **A coinbase check is structurally
impossible on a standard channel.** — [[raw/articles/2026-07-21-sv2-spec-mining-protocol-channels-jobs]],
[[raw/repos/2026-07-21-sri-stratum-core-crate-deps-and-handlers]]

HOM is an *intended* SV2 design goal ("not touching the coinbase transaction in as many
situations as possible"), not an accident. — [[raw/articles/2026-07-21-sv2-spec-design-goals-and-security]]

## Extended channel → raw coinbase visible

Extended (and group) channels receive **`NewExtendedMiningJob`**, which carries
`coinbase_tx_prefix` (B0_64K), `coinbase_tx_suffix` (B0_64K), and `merkle_path`
(SEQ0_255[U256]). The client reconstructs the full coinbase, rolls the extranonce, and
computes the merkle root itself. **This is the only place a downstream client sees the
pool's coinbase bytes.**

Extended channels exist "to be used by Proxies for a more efficient distribution of
hashing space" — coinbase visibility is a *side effect* of search-space splitting, not
a payout-audit feature.

## Consequence for the daemon

Open an **`OpenExtendedMiningChannel`**, not standard. Combine `extranonce_prefix` +
`extranonce_size` from `.Success` with the job's prefix/suffix to reconstruct and
inspect the coinbase.

## See also

- [[wiki/concepts/coinbase-reconstruction-and-merkle-fold]]
- [[wiki/concepts/expected-value-checks-taxonomy]]
- [[wiki/concepts/coinbase-verification-trust-model-limits]]
- [[../sv2-coinbase-identity/wiki/concepts/coinbase-ownership-pool-vs-jdc|coinbase ownership: Pool vs JDC (sv2-coinbase-identity)]]
