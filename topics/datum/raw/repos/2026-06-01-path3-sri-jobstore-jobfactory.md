---
title: "SRI JobStore trait + JobFactory: where DATUM-GBT plugs in"
source: /Users/garykrause/repos/stratum/sv2/channels-sv2/src/server/jobs/{job_store.rs,factory.rs}
source_type: local-code
ingested_by: path3
ingested_at: 2026-06-01
quality: high
relevance: critical
tags: [sri, sv2, jobstore, jobfactory, gbt, coinbase-outputs, ocean, datum-proxy, newtemplate]
---

# SRI JobStore + JobFactory: the GBT-to-NewExtendedMiningJob bridge

These two abstractions in `sv2/channels-sv2/src/server/jobs/` are exactly the
seam where DATUM's GBT-derived templates would be injected into SV2.

## Key findings

- **`JobStore<T: Job>` is a trait, not a struct.** Implementations need:
  `add_future_job`, `add_active_job`, `activate_future_job`, `deactivate_job`,
  `mark_past_jobs_as_stale`, `get_future_job_id_from_template_id`,
  `get_active_job`, `has_future_jobs`, `get_future_job`, `has_past_jobs`,
  `get_past_job`, `has_stale_jobs`, `get_stale_job`. SRI ships `DefaultJobStore<T>`
  using four `HashMap`s (future, active, past, stale) keyed by `job_id` plus a
  `template_id → job_id` map. **A DATUM proxy would use `DefaultJobStore`
  unmodified** — there's no need for a custom JobStore. The interesting work
  happens upstream of the JobStore (in feeding `NewTemplate` to the channel).

- **`JobFactory::new_extended_job(channel_id, chain_tip, extranonce_prefix,
  template: NewTemplate, additional_coinbase_outputs: Vec<TxOut>,
  full_extranonce_size)` is the single function that turns a `NewTemplate` +
  reward-output bundle into a `NewExtendedMiningJob`.** It:
  1. Verifies `sum(additional_coinbase_outputs) == template.coinbase_tx_value_remaining`
     (this is the hard invariant — see point below for OCEAN implications).
  2. Builds a synthetic coinbase `Transaction` with: a scriptSig of
     `template.coinbase_prefix || OP_PUSHBYTES(/pool_tag/miner_tag/) ||
     OP_PUSHBYTES_X || zeros(full_extranonce_size)`, then `additional_outputs ||
     template_outputs` as the output list, plus a 32-byte witness commitment.
  3. Splits the serialized coinbase into `coinbase_tx_prefix` (everything
     before the extranonce zeros) and `coinbase_tx_suffix` (everything after).
  4. Strips BIP141 witness bytes from prefix/suffix to fit the SV2 wire shape.
  5. Computes merkle root from prefix+extranonce+suffix+template.merkle_path.
  6. Stamps a fresh monotonic `job_id`.

- **The `additional_coinbase_outputs: Vec<TxOut>` parameter is exactly the slot
  for OCEAN-mandated outputs.** Under DATUM, OCEAN sends the gateway a list of
  required outputs the miner MUST include. Path: OCEAN → DATUM
  `coinbaser.c`/`datum_protocol.c` → translation layer → `JobFactory` as
  `additional_coinbase_outputs`. The `template.coinbase_tx_outputs` already
  carries the witness commitment for segwit; OCEAN's `pool_address` payouts and
  any subsidy splits go in the additional vec. **Critical caveat:** the SRI
  invariant requires the additional outputs' total sat to equal
  `coinbase_tx_value_remaining` exactly. OCEAN already enforces this, so the
  proxy would just deserialize whatever OCEAN sends and pass it through
  verbatim.

- **`JobFactory` does NOT need to be customized for DATUM** — the
  `pool_tag_string` parameter (passed at construction time) gives us the
  `coinbase_tag_primary` and the `miner_tag_string` (None on the pool path)
  effectively wires up the existing DATUM `coinbase_tag_secondary` semantics.
  The scriptSig format `/pool_tag//` (pool path) leaves a delimited region we
  can configure to mimic DATUM's existing scriptSig presentation.

- **`new_extended_job_from_custom_job(SetCustomMiningJob, ...)` is also
  available** for the rarer model (b) where a downstream JDC declared a custom
  template against this proxy as a JDS. Reusable verbatim if model (b) is
  pursued; not needed for model (a).

## Implication for DATUM proxy: minimal new code

The "GBT → SV2 NewExtendedMiningJob" bridge can be done in ~50 LOC of glue:
synthesize a `NewTemplate` struct (template_id, future_template flag, version,
coinbase_tx_version, coinbase_prefix=BIP34 height, coinbase_tx_input_sequence,
coinbase_tx_value_remaining, coinbase_tx_outputs_count,
coinbase_tx_outputs=witness_commitment_only, coinbase_tx_locktime, merkle_path)
from the gateway's GBT result, plus build the OCEAN `Vec<TxOut>` from the
gateway's coinbaser state. Then `channel.on_new_template(template, outputs)`
does the rest.

## Ingest justification

`JobFactory::new_extended_job` is the precise insertion point for DATUM data.
Documents which inputs we control (template + outputs) and which behavior is
free (coinbase synthesis, prefix/suffix split, BIP141 stripping, merkle, job
id). Establishes that no custom JobStore is needed.
