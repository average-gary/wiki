---
title: "Fedimint AmountUnit / Amounts / TransactionItemAmounts — source walk (master @ c39f9c8)"
type: raw
source_type: repos
source_url: https://github.com/fedimint/fedimint
source: "fedimint/fedimint @ c39f9c8"
local_path: /Users/garykrause/repos/fedimint
ingested: 2026-06-15
fetched: 2026-06-15
verified: 2026-06-15
revision: c39f9c83255fb88adb2381848ed3423c1e6d5c64
volatility: hot
quality: 5
confidence: high
tags: [fedimint-core, AmountUnit, Amounts, TransactionItemAmounts, FundingVerifier, multi-currency, source-walkthrough]
summary: Source-level walk of the multi-currency primitives in `fedimint-core` — `AmountUnit(u64)`, `Amounts(BTreeMap<AmountUnit, Amount>)`, `TransactionItemAmounts { amounts, fees }` — plus the per-unit consensus balance check (`FundingVerifier::verify_funding` in `fedimint-server`). Resolves "what changed for module authors in PR #7734" against the actual code in master @ c39f9c8.
---

# AmountUnit / Amounts / FundingVerifier — source walk (snapshot 2026-06-15)

PR #7734 "chore: multi-currency support" (dpc, merged 2025-10-19) replaced the scalar `Amount` accounting on the module trait surface with a multi-unit `Amounts` map. PR #8460 (joschisan, merged 2026-04-08) wired the new `amount_unit` config field through `mintv2`. This source walk pins down the concrete shapes a module author has to know.

## 1. `AmountUnit` — `fedimint-core/src/module/mod.rs:61-96`

```rust
/// Unit of account for a given amount.
#[derive(Debug, Clone, Copy, Eq, PartialEq, Hash, PartialOrd, Ord,
    Deserialize, Serialize, Encodable, Decodable, Default)]
pub struct AmountUnit(u64);

impl AmountUnit {
    /// [`AmountUnit`] with id `0` is reserved for the native Bitcoin currency.
    /// So e.g. for a mainnet Federation it's a real Bitcoin (msats), for a
    /// signet one it's a Signet msats, etc.
    pub const BITCOIN: Self = Self(0);

    pub fn is_bitcoin(self) -> bool { self == Self::BITCOIN }
    pub fn new_custom(unit: u64) -> Self { Self(unit) }
    pub const fn bitcoin() -> Self { Self::BITCOIN }
}
```

**Important property:** `AmountUnit` is an **opaque `u64` newtype**. There is no registry, no name table, no string mapping. Two federations choosing `AmountUnit::new_custom(1)` could each mean different things. `AmountUnit(0)` is the only reserved value. (See [Cashu NUT-01/02 comparison](#cashu-comparison) below — Cashu uses ISO 4217 strings.)

## 2. `Amounts` — `fedimint-core/src/module/mod.rs:104-211`

```rust
/// Multi-unit amount.
///
/// Note: implementation must be careful not to add zero-amount
/// entries, as these could mess up equality comparisons, etc.
#[derive(Debug, Clone, Eq, PartialEq, Hash)]
pub struct Amounts(BTreeMap<AmountUnit, Amount>);

impl ops::Deref for Amounts {
    type Target = BTreeMap<AmountUnit, Amount>;
    fn deref(&self) -> &Self::Target { &self.0 }
}
// Note: no `impl ops::DerefMut` as it could easily accidentally break the invariant.

impl Amounts {
    pub const ZERO: Self = Self(BTreeMap::new());

    pub fn new_bitcoin(amount: Amount) -> Self {
        if amount == Amount::ZERO { Self(BTreeMap::from([])) }
        else { Self(BTreeMap::from([(AmountUnit::BITCOIN, amount)])) }
    }
    pub fn new_bitcoin_msats(msats: u64) -> Self {
        Self::new_bitcoin(Amount::from_msats(msats))
    }
    pub fn new_custom(unit: AmountUnit, amount: Amount) -> Self {
        if amount == Amount::ZERO { Self(BTreeMap::from([])) }
        else { Self(BTreeMap::from([(unit, amount)])) }
    }

    pub fn checked_add(mut self, rhs: &Self) -> Option<Self> {
        self.checked_add_mut(rhs)?; Some(self)
    }
    pub fn checked_add_mut(&mut self, rhs: &Self) -> Option<&mut Self> {
        for (unit, amount) in &rhs.0 {
            debug_assert!(*amount != Amount::ZERO,
                "`Amounts` must not add (/remove) zero-amount entries");
            let prev = self.0.entry(*unit).or_default();
            *prev = prev.checked_add(*amount)?;
        }
        Some(self)
    }

    pub fn get_bitcoin(&self) -> Amount {
        self.get(&AmountUnit::BITCOIN).copied().unwrap_or_default()
    }
    pub fn expect_only_bitcoin(&self) -> Amount {
        match self.get(&AmountUnit::BITCOIN) {
            Some(amount) => {
                assert!(self.len() == 1,
                    "Amounts expected to contain only bitcoin and no other currencies");
                *amount
            }
            None => Amount::ZERO,
        }
    }

    pub fn iter_units(&self) -> impl Iterator<Item = AmountUnit> { self.0.keys().copied() }
    pub fn units(&self) -> BTreeSet<AmountUnit> { self.0.keys().copied().collect() }
}
```

Constructors filter zero amounts out — preserving the "no zero-amount entries" invariant. Read-only deref to `BTreeMap`; no `DerefMut` to prevent accidental invariant breakage.

`expect_only_bitcoin()` is the **temporary back-compat helper** for code paths that have not yet been generalized.

## 3. `TransactionItemAmounts` — `fedimint-server-core/src/lib.rs:56-232`

```rust
#[derive(Debug, PartialEq, Eq)]
pub struct InputMeta {
    pub amount: TransactionItemAmounts,
    pub pub_key: secp256k1::PublicKey,
}

/// Information about the amount represented by an input or output.
///
/// * For **inputs** the amount is funding the transaction while the fee is consuming funding
/// * For **outputs** the amount and the fee consume funding
#[derive(Debug, Clone, Eq, PartialEq, Hash)]
pub struct TransactionItemAmounts {
    pub amounts: Amounts,
    pub fees: Amounts,
}

impl TransactionItemAmounts {
    pub const ZERO: Self = Self { amounts: Amounts::ZERO, fees: Amounts::ZERO };
    pub fn checked_add(self, rhs: &Self) -> Option<Self> {
        Some(Self {
            amounts: self.amounts.checked_add(&rhs.amounts)?,
            fees:    self.fees.checked_add(&rhs.fees)?,
        })
    }
}
```

This is the return type of `ServerModule::process_output` and the inner `amount` field of `InputMeta`.

## 4. Per-unit consensus balance check — `fedimint-server/src/consensus/transaction.rs:121-197`

```rust
#[derive(Clone, Debug)]
pub struct FundingVerifier {
    inputs: Amounts,
    outputs: Amounts,
    fees: Amounts,
}

impl FundingVerifier {
    pub fn add_input(&mut self, input: TransactionItemAmounts)
        -> Result<&mut Self, TransactionError> { ... }
    pub fn add_output(&mut self, output_amounts: TransactionItemAmounts)
        -> Result<&mut Self, TransactionError> { ... }

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
}
```

**Per-unit independence:** the loop iterates `for (out_unit, out_amount) in outputs_and_fees` and balances each unit against the matching key in `self.inputs`. There is no cross-unit settlement — `{btc: 10, usd: 5}` inputs cannot fund `{btc: 5, usd: 10}` outputs even if a price oracle would value them equally.

**Versioning:** at `CoreConsensusVersion(2,1)` and later, **overpay is allowed** (`input_amount > out_amount` permitted, leftover input ignored as overpay-fees-to-the-federation). At earlier versions, exact balance is enforced including: any remaining input units after the loop are an error.

## 5. Tests — `fedimint-server/src/consensus/transaction/tests.rs:7-62`

```rust
#[test]
fn sanity_test_funding_verifier() {
    for amount_other in [0, 10] {
        let mut v = super::FundingVerifier::default();
        // Add a non-bitcoin amount (balanced) to both sides
        v.add_input(TransactionItemAmounts {
            amounts: Amounts::new_custom(AmountUnit::new_custom(1), Amount::from_msats(amount_other)),
            fees: Amounts::ZERO,
        }).unwrap()
         .add_output(TransactionItemAmounts {
            amounts: Amounts::new_custom(AmountUnit::new_custom(1), Amount::from_msats(amount_other)),
            fees: Amounts::ZERO,
        }).unwrap();

        v.add_input(TransactionItemAmounts {
            amounts: Amounts::new_bitcoin_msats(3),
            fees: Amounts::new_bitcoin_msats(1),
        }).unwrap()
         .add_output(TransactionItemAmounts {
            amounts: Amounts::new_bitcoin_msats(1),
            fees: Amounts::new_bitcoin_msats(1),
        }).unwrap();

        assert!(v.clone().verify_funding(VERIFIER_OLD).is_ok());
        assert!(v.clone().verify_funding(VERIFIER_NEW).is_ok());
    }
}
```

Confirms unit `0` (BITCOIN) and unit `1` (custom) balance independently in the same transaction.

## 6. Migration shape pre/post #7734

| Before #7734 | After #7734 |
|---|---|
| `process_input(...) -> Result<InputMeta { amount: Amount, pub_key }, _>` | `process_input(...) -> Result<InputMeta { amount: TransactionItemAmounts { amounts: Amounts, fees: Amounts }, pub_key }, _>` |
| `process_output(...) -> Result<Amount, _>` | `process_output(...) -> Result<TransactionItemAmounts, _>` |
| `input_fee(input) -> Amount` | `input_fee(amount: &Amounts, input) -> Option<Amounts>` |
| `output_fee(output) -> Amount` | `output_fee(amount: &Amounts, output) -> Option<Amounts>` |
| `get_balance() -> Amount` | `get_balance(dbtx, unit: AmountUnit) -> Amount` plus `get_balances(dbtx) -> Amounts` |
| Manual `primary_module: ModuleInstanceId` setting on the client | `supports_being_primary() -> PrimaryModuleSupport` per-unit, automatically resolved by the client |

**Minimal migration for a BTC-only module:** wrap your single `Amount` with `Amounts::new_bitcoin(amount)` and `Amounts::ZERO` for fees. The dummy module shows the exact pattern (`modules/fedimint-dummy-server/src/lib.rs:207-238`).

## 7. Client transaction builder — `fedimint-client-module/src/transaction/builder.rs:28-247`

```rust
pub struct ClientInput<I = DynInput> {
    pub input: I,
    pub keys: Vec<Keypair>,
    pub amounts: Amounts,         // <-- per-input multi-unit amounts
}

pub struct ClientOutput<O = DynOutput> {
    pub output: O,
    pub amounts: Amounts,
}
```

Balance accumulator (`fedimint-client/src/client.rs:560-590`):

```rust
fn transaction_builder_get_balance(&self, builder: &TransactionBuilder) -> (Amounts, Amounts) {
    let mut in_amounts = Amounts::ZERO;
    let mut out_amounts = Amounts::ZERO;
    let mut fee_amounts = Amounts::ZERO;

    for input in builder.inputs() {
        let module = self.get_module(input.input.module_instance_id());
        let item_fees = module.input_fee(&input.amounts, &input.input)
            .expect("supported version");
        in_amounts.checked_add_mut(&input.amounts);
        fee_amounts.checked_add_mut(&item_fees);
    }
    for output in builder.outputs() {
        let module = self.get_module(output.output.module_instance_id());
        let item_fees = module.output_fee(&output.amounts, &output.output)
            .expect("supported version");
        out_amounts.checked_add_mut(&output.amounts);
        fee_amounts.checked_add_mut(&item_fees);
    }
    out_amounts.checked_add_mut(&fee_amounts);
    (in_amounts, out_amounts)
}
```

Each module's `input_fee` / `output_fee` is called per-item; results accumulate per-unit into one `Amounts`. The transaction is balanced if and only if `in_amounts == out_amounts` per-unit (or `in_amounts >= out_amounts` per-unit at `CoreConsensusVersion(2,1)` and later).

## 8. Recent overflow fix — `fix(core): reject amount addition overflow`

PR #8686 (merged 2026-06-12, SHA `25ef880c3af`) made `Amount::checked_add` overflow-safe. `Amounts::checked_add_mut` propagates `None` on overflow. Modules summing per-unit `Amount`s must handle the overflow case rather than panic.

## Cashu comparison

For a contemporary higher-level multi-unit API see Cashu NUT-01 ("A mint may support any currency unit(s) … `btc`, `sat`, `msat`, ISO 4217 codes (`usd`, `eur`), and stablecoin tickers all explicitly named") and NUT-02 ("the `unit` string is incorporated into keyset-ID derivation"). Cashu mints carry the unit as an open string and ISO Minor Unit semantics; Fedimint carries it as an opaque `u64` configured per module instance and leaves human-readable mapping to client code.

## See also

- [[2026-06-15-fedimint-server-module-trait-surface|ServerModule / ClientModule trait surface]] — the methods that consume/return these types
- [[2026-06-15-fedimint-mintv2-amount-unit-wiring|mintv2 amount_unit wiring]] — concrete in-tree consumer
- [[2026-05-28-fedimint-pr-7734-multi-currency-support|PR #7734]] — the merged change
- [[../../wiki/concepts/amount-units-and-amounts|AmountUnits and Amounts (concept)]]
