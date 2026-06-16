---
title: "TransactionItemAmounts and the per-unit balance check"
type: concept
created: 2026-06-15
updated: 2026-06-15
verified: 2026-06-15
volatility: hot
confidence: high
tags: [fedimint, multi-currency, TransactionItemAmounts, FundingVerifier, consensus, balance-check]
---

# TransactionItemAmounts and the per-unit balance check

`TransactionItemAmounts` is the multi-unit return type modules surface to consensus. `FundingVerifier::verify_funding` is the consensus rule that uses it. Together they replace pre-#7734 single-`Amount` accounting.

## The type

[`fedimint-server-core/src/lib.rs:56-232`](../../raw/repos/2026-06-15-fedimint-amount-units-and-amounts-source):

```rust
pub struct InputMeta {
    pub amount:  TransactionItemAmounts,
    pub pub_key: secp256k1::PublicKey,
}

pub struct TransactionItemAmounts {
    pub amounts: Amounts,
    pub fees:    Amounts,
}
```

Returned by `ServerModule::process_input` (wrapped in `InputMeta`) and `ServerModule::process_output` (directly). `Amounts` is `BTreeMap<AmountUnit, Amount>` — see [[amount-units-and-amounts|AmountUnit & Amounts]].

For inputs, `amounts` fund the transaction and `fees` consume funding. For outputs, both consume funding. (Source comment, line 60-62.)

## How modules construct it

**BTC-only module** — wrap your existing `Amount` in `Amounts::new_bitcoin(...)`:

```rust
Ok(InputMeta {
    amount: TransactionItemAmounts {
        amounts: Amounts::new_bitcoin(input.amount),
        fees:    Amounts::ZERO,
    },
    pub_key: input.pub_key,
})
```

(Pattern from `modules/fedimint-dummy-server/src/lib.rs:207-238`.)

**Multi-unit module** — read your configured unit and wrap:

```rust
let unit = self.cfg.consensus.amount_unit;
Ok(InputMeta {
    amount: TransactionItemAmounts {
        amounts: Amounts::new_custom(unit, amount),
        fees:    Amounts::new_custom(unit, fee_consensus.fee(amount)),
    },
    pub_key: input.note.nonce,
})
```

(Pattern from `modules/fedimint-mintv2-server/src/lib.rs:382-439`.)

A module **can** return amounts in multiple units in a single `Amounts` map (e.g. an exchange-style module returning `{btc: 1000, usd-synth: 50}` from one input). Nothing in the type prevents it. Consensus will balance each unit independently.

## FundingVerifier (consensus balance check)

[`fedimint-server/src/consensus/transaction.rs:121-197`](../../raw/repos/2026-06-15-fedimint-amount-units-and-amounts-source#4-per-unit-consensus-balance-check):

```rust
pub fn verify_funding(mut self, version: CoreConsensusVersion)
    -> Result<(), TransactionError>
{
    const OVERPAY_MIN_VERSION: CoreConsensusVersion = CoreConsensusVersion::new(2, 1);

    let outputs_and_fees = self.outputs.clone()
        .checked_add(&self.fees)
        .ok_or(TRANSACTION_OVERFLOW_ERROR)?;

    for (out_unit, out_amount) in outputs_and_fees {
        let input_amount = self.inputs.get(&out_unit).copied().unwrap_or_default();
        if input_amount < out_amount
            || (input_amount != out_amount && version < OVERPAY_MIN_VERSION)
        {
            return Err(TransactionError::UnbalancedTransaction { ... });
        }
        self.inputs.remove(&out_unit);
    }

    if version < OVERPAY_MIN_VERSION
        && let Some((inputs_unit, inputs_amount)) = self.inputs.into_iter().next()
    {
        return Err(TransactionError::UnbalancedTransaction { ... });
    }
    Ok(())
}
```

**Three things to know:**

1. **Per-unit independence.** The loop iterates `outputs_and_fees` and balances each unit against the matching key in `inputs`. There is no cross-unit settlement — `{btc: 10, usd: 5}` inputs cannot fund `{btc: 5, usd: 10}` outputs even if a price oracle would value them equally.
2. **Versioned overpay.** At `CoreConsensusVersion(2,1)+`, `input_amount > out_amount` is allowed (the leftover is implicit overpay-fee to the federation). Earlier versions enforce exact balance and error if any input unit is left over after the loop.
3. **Overflow propagation.** `Amounts::checked_add` returns `Option`; `verify_funding` maps `None` to `TRANSACTION_OVERFLOW_ERROR` (see PR #8686, 2026-06-12).

## Tests confirming per-unit balancing

`fedimint-server/src/consensus/transaction/tests.rs:7-62` — a single tx with one BITCOIN input/output pair *and* one custom-unit input/output pair, both balance independently and the tx passes. Consensus does not interfere across units.

## What this enables

A federation can in principle stand up multiple module instances declaring different `AmountUnit`s and have one transaction settle across all of them — provided each unit balances per-side. mintv2 is the only in-tree consumer wiring this through ([[mintv2-amount-unit-config|see wiring]]); the gateway / lnv2 / walletv2 are still BTC-only.

## See also

- [[amount-units-and-amounts|`AmountUnit` and `Amounts`]] — the underlying types
- [[mintv2-amount-unit-config|mintv2 amount_unit config]] — concrete in-tree consumer
- [[primary-module-support|Primary module support]] — how the client picks a primary module per unit
- [[../../raw/repos/2026-06-15-fedimint-amount-units-and-amounts-source|Full source walk]]
