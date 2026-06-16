---
title: "mintv2 amount_unit wiring — config → genesis → server → client (master @ c39f9c8)"
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
tags: [fedimint, mintv2, amount-unit, primary-module, source-walkthrough, multi-currency]
summary: End-to-end source walk of the mintv2 multi-currency wiring at master @ c39f9c8 — `MintConfigConsensus.amount_unit`, the (currently hardcoded) BITCOIN propagation in `trusted_dealer_gen` / `distributed_gen`, server-side `Amounts::new_custom(unit, amount)` in `process_input`/`process_output`, client-side unit lock in `create_final_inputs_and_outputs`, denomination-as-unit-agnostic `2^d msats`, and the `MintGenParams` operator surface that does NOT yet expose `amount_unit`.
---

# mintv2 amount_unit wiring — source walk (snapshot 2026-06-15)

mintv2 is the canonical in-tree consumer of [[2026-06-15-fedimint-amount-units-and-amounts-source|AmountUnit / Amounts]]. PR #8460 (joschisan, 2026-04-08) added `amount_unit` to its consensus and client config. This walk traces the value end-to-end at master `c39f9c8`. All paths are relative to `/Users/garykrause/repos/fedimint`.

## 1. Config types — `modules/fedimint-mintv2-common/src/config.rs:13-50`

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MintGenParams {
    pub fee_consensus: FeeConsensus,
    // NOTE: no `amount_unit` field in the operator-supplied params.
}

#[derive(Clone, Debug, Serialize, Deserialize, Encodable, Decodable)]
pub struct MintConfigConsensus {
    pub tbs_agg_pks: BTreeMap<Denomination, AggregatePublicKey>,
    pub tbs_pks:     BTreeMap<Denomination, BTreeMap<PeerId, PublicKeyShare>>,
    pub fee_consensus: FeeConsensus,
    pub amount_unit: AmountUnit,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize, Encodable, Decodable, Hash)]
pub struct MintClientConfig {
    pub tbs_agg_pks: BTreeMap<Denomination, AggregatePublicKey>,
    pub tbs_pks:     BTreeMap<Denomination, BTreeMap<PeerId, PublicKeyShare>>,
    pub fee_consensus: FeeConsensus,
    pub amount_unit: AmountUnit,
}
```

`MintConfigConsensus` (server) and `MintClientConfig` (client) both carry `amount_unit`. `MintGenParams` (operator-supplied) does **not** — confirming the gap surfaced in [[../articles/2026-05-28-fedimint-issue-8217-external-modules-broken|Issue #8217]] / dpc's "nowhere near implemented" remark.

## 2. Genesis path (BTC hardcode) — `modules/fedimint-mintv2-server/src/lib.rs:172-272`

### `trusted_dealer_gen`

```rust
fn trusted_dealer_gen(
    &self,
    peers: &[PeerId],
    args: &ConfigGenModuleArgs,
) -> BTreeMap<PeerId, ServerModuleConfig> {
    let fee_consensus = if args.disable_base_fees {
        FeeConsensus::zero()
    } else {
        FeeConsensus::new(0).expect("Relative fee is within range")
    };

    let tbs_agg_pks = consensus_denominations()
        .map(|d| (d, dealer_agg_pk(d.amount())))
        .collect();
    let tbs_pks = consensus_denominations()
        .map(|d| {
            let pks = peers.iter()
                .map(|peer| (*peer, dealer_pk(d.amount(), peers.to_num_peers(), *peer)))
                .collect();
            (d, pks)
        })
        .collect();

    peers.iter().map(|peer| {
        let cfg = MintConfig {
            consensus: MintConfigConsensus {
                tbs_agg_pks: tbs_agg_pks.clone(),
                tbs_pks:     tbs_pks.clone(),
                fee_consensus: fee_consensus.clone(),
                amount_unit: AmountUnit::BITCOIN,   // <-- HARDCODED
            },
            private: MintConfigPrivate {
                tbs_sks: consensus_denominations()
                    .map(|d| (d, dealer_sk(d.amount(), peers.to_num_peers(), *peer)))
                    .collect(),
            },
        };
        (*peer, cfg.to_erased())
    }).collect()
}
```

### `distributed_gen` (DKG)

```rust
async fn distributed_gen(
    &self,
    peers: &(dyn PeerHandleOps + Send + Sync),
    args: &ConfigGenModuleArgs,
) -> anyhow::Result<ServerModuleConfig> {
    let fee_consensus = if args.disable_base_fees {
        FeeConsensus::zero()
    } else {
        FeeConsensus::new(0).expect("Relative fee is within range")
    };

    let mut tbs_sks = BTreeMap::new();
    let mut tbs_agg_pks = BTreeMap::new();
    let mut tbs_pks = BTreeMap::new();

    for denomination in consensus_denominations() {
        let (poly, sk) = peers.run_dkg_g2().await?;
        tbs_sks.insert(denomination, tbs::SecretKeyShare(sk));
        tbs_agg_pks.insert(denomination, AggregatePublicKey(poly[0].to_affine()));
        let pks = peers.num_peers().peer_ids()
            .map(|peer| (peer, PublicKeyShare(eval_poly_g2(&poly, &peer))))
            .collect();
        tbs_pks.insert(denomination, pks);
    }

    let cfg = MintConfig {
        private: MintConfigPrivate { tbs_sks },
        consensus: MintConfigConsensus {
            tbs_agg_pks,
            tbs_pks,
            fee_consensus,
            amount_unit: AmountUnit::BITCOIN,    // <-- HARDCODED
        },
    };
    Ok(cfg.to_erased())
}
```

**Both genesis paths hardcode `AmountUnit::BITCOIN`.** PR #8460 added the storage field and the runtime read, but did not expose the operator surface. The DKG runs unchanged for all 42 denominations (each producing a `2^d msats` keyset); the unit is purely a semantic tag bolted onto the config struct.

## 3. Server-side use — `modules/fedimint-mintv2-server/src/lib.rs:382-494`

```rust
async fn process_input<'a, 'b, 'c>(
    &'a self,
    dbtx: &mut DatabaseTransaction<'c>,
    input: &'b MintInput,
    _in_point: InPoint,
) -> Result<InputMeta, MintInputError> {
    let input = input.ensure_v0_ref()?;
    let pk = self.cfg.consensus.tbs_agg_pks
        .get(&input.note.denomination)
        .ok_or(MintInputError::InvalidDenomination)?;
    if !verify_note(input.note, *pk) { return Err(MintInputError::InvalidSignature); }
    if dbtx.insert_entry(&NonceKey(input.note.nonce), &()).await.is_some() {
        return Err(MintInputError::SpentCoin);
    }
    // ... issuance counter / recovery item bookkeeping ...

    let amount = input.note.amount();
    let unit   = self.cfg.consensus.amount_unit;     // <-- READ FROM CONFIG

    Ok(InputMeta {
        amount: TransactionItemAmounts {
            amounts: Amounts::new_custom(unit, amount),
            fees:    Amounts::new_custom(unit, self.cfg.consensus.fee_consensus.fee(amount)),
        },
        pub_key: input.note.nonce,
    })
}

async fn process_output<'a, 'b>(
    &'a self,
    dbtx: &mut DatabaseTransaction<'b>,
    output: &'a MintOutput,
    outpoint: OutPoint,
) -> Result<TransactionItemAmounts, MintOutputError> {
    let output = output.ensure_v0_ref()?;
    let signature = self.cfg.private.tbs_sks
        .get(&output.denomination)
        .map(|key| tbs::sign_message(output.nonce, *key))
        .ok_or(MintOutputError::InvalidDenomination)?;
    // ... store signature share + recovery item ...

    let amount = output.amount();
    let unit   = self.cfg.consensus.amount_unit;     // <-- READ FROM CONFIG

    Ok(TransactionItemAmounts {
        amounts: Amounts::new_custom(unit, amount),
        fees:    Amounts::new_custom(unit, self.cfg.consensus.fee_consensus.fee(amount)),
    })
}
```

**The pattern:** read `self.cfg.consensus.amount_unit` once, wrap denomination-derived `Amount` (msats from `2^d`) in `Amounts::new_custom(unit, amount)`. **The unit affects only the wrapper key** — the underlying value is still raw msats. A `mintv2(usd-synth)` instance issuing a `2^20` denomination note would hand back `Amounts({usd-synth: 1_048_576 msats})` — the meaning of those msats is for the federation/wallet to decide.

## 4. Client-side use — `modules/fedimint-mintv2-client/src/lib.rs:295-323, 370-419, 626-703`

```rust
async fn init(&self, args: &ClientModuleInitArgs<Self>) -> anyhow::Result<Self::Module> {
    // ... tweak generation thread ...
    Ok(MintClientModule {
        federation_id: *args.federation_id(),
        cfg: args.cfg().clone(),                          // <-- carries amount_unit
        root_secret: args.module_root_secret().clone(),
        notifier: args.notifier().clone(),
        client_ctx: args.context(),
        balance_update_sender: tokio::sync::watch::channel(()).0,
        tweak_receiver,
    })
}

fn input_fee(&self, amounts: &Amounts, _input: &<Self::Common as ModuleCommon>::Input)
    -> Option<Amounts>
{
    let unit = self.cfg.amount_unit;
    let amount = amounts.get(&unit).copied().unwrap_or_default();
    let fee = self.cfg.fee_consensus.fee(amount);
    Some(Amounts::new_custom(unit, fee))
}
fn output_fee(&self, amounts: &Amounts, _output: &<Self::Common as ModuleCommon>::Output)
    -> Option<Amounts>
{
    let unit = self.cfg.amount_unit;
    let amount = amounts.get(&unit).copied().unwrap_or_default();
    let fee = self.cfg.fee_consensus.fee(amount);
    Some(Amounts::new_custom(unit, fee))
}

async fn create_final_inputs_and_outputs(
    &self,
    dbtx: &mut DatabaseTransaction<'_>,
    operation_id: OperationId,
    unit: AmountUnit,
    mut input_amount: Amount,
    mut output_amount: Amount,
) -> anyhow::Result<(
    ClientInputBundle<MintInput, MintClientStateMachines>,
    ClientOutputBundle<MintOutput, MintClientStateMachines>,
)> {
    if unit != self.cfg.amount_unit {
        anyhow::bail!("Module can only handle its configured amount unit");
    }
    // ... select notes and build bundles ...
}
```

**Unit lock-in:** an instance `mintv2(usd-synth)` with `cfg.amount_unit = USD_SYNTH` rejects any primary-module call requesting a different unit. This is the per-unit primary-module mechanism in action — the client orchestrator routes funding for unit `U` to whichever module has `supports_being_primary() = Selected { units: { U }, .. }`.

## 5. Per-tier denominations — `modules/fedimint-mintv2-common/src/lib.rs:44-57` + `config.rs:17-23`

```rust
pub struct Denomination(pub u8);
impl Denomination {
    pub fn amount(self) -> Amount {
        Amount::from_msats(1 << self.0 as usize)
    }
}
impl fmt::Display for Denomination { /* "2^N msats" */ }

pub fn consensus_denominations() -> impl DoubleEndedIterator<Item = Denomination> {
    (0..42).map(Denomination)
}
pub fn client_denominations() -> impl DoubleEndedIterator<Item = Denomination> {
    (9..42).map(Denomination)
}
```

**42 powers-of-two from 1 msat through 2^41 msats.** The denomination scheme is unit-agnostic — same tiers regardless of unit. A `mintv2(usd)` instance still issues 2^d msat-denominated notes; the wallet semantics ("this 2^20-msat note represents $X.YZ") live elsewhere. Note that this means there is **no per-unit dust tier sizing** — a fiat unit with much higher per-msat value would still have a 1-msat smallest denomination consensus tier (consensus uses 0–41; client uses 9–41 by default).

## 6. mintv1 vs mintv2 — `modules/fedimint-mint-common/src/config.rs:22-30`

```rust
#[derive(Clone, Debug, Serialize, Deserialize, Encodable, Decodable)]
pub struct MintConfigConsensus {
    pub peer_tbs_pks: BTreeMap<PeerId, Tiered<PublicKeyShare>>,
    pub fee_consensus: FeeConsensus,
    pub max_notes_per_denomination: u16,
    // NO amount_unit field — mintv1 is BTC-only by construction
}
```

mintv1 uses `Tiered<T>(BTreeMap<Amount, T>)` keyed on `Amount` (msats); no semantic unit marker. mintv2 broke from this by flattening to `BTreeMap<Denomination, _>` (with `Denomination(u8)` indexing power-of-two msats) and adding the explicit `amount_unit` field.

## 7. Tests — no multi-unit coverage

`grep -rn 'AmountUnit\|amount_unit\|new_custom' modules/fedimint-mintv2-tests/` returns **zero hits** in the tests crate. All `fedimint-mintv2-tests` exercises (`tests/tests.rs:109-186`) use `client.get_balance_for_btc()` and `Amount::from_sats(...)`. There is no parametrized harness running the same flow against a non-BITCOIN unit.

## 8. End-to-end summary

```
operator                                 federation
  │  MintGenParams { fee_consensus }       │  trusted_dealer_gen / distributed_gen
  │  (no amount_unit yet)            ──>   │     amount_unit: AmountUnit::BITCOIN  (hardcoded)
  │                                        │  → MintConfigConsensus stored in consensus state

federation server tx processing
  process_input  (cfg.consensus.amount_unit) → InputMeta { amounts: {unit: amount}, fees: {unit: fee} }
  process_output (cfg.consensus.amount_unit) → TransactionItemAmounts { amounts, fees }

federation → client config distribution
  get_client_config(consensus_cfg) → MintClientConfig { ..., amount_unit }

client
  input_fee / output_fee  → look up cfg.amount_unit in &Amounts
  create_final_inputs_and_outputs → reject if unit != cfg.amount_unit
  create_input_bundle / create_output_bundle → wrap notes in Amounts::new_custom(cfg.amount_unit, _)
```

**Gap to multi-asset reality:** `MintGenParams` does not carry `amount_unit`, and there is no `ConfigGenModuleArgs` field for per-instance unit selection. To stand up `mintv2(usd-synth)` today an operator must monkey-patch the genesis path or fork the module. Reintroducing per-module `GenParams` is the elsirion-acknowledged TODO in [[../articles/2026-05-28-fedimint-issue-8217-external-modules-broken|Issue #8217]].

## See also

- [[2026-06-15-fedimint-amount-units-and-amounts-source|AmountUnit/Amounts source]]
- [[2026-06-15-fedimint-server-module-trait-surface|ServerModule/ClientModule trait surface]]
- [[2026-05-28-fedimint-pr-8460-mintv2-amount-unit-config|PR #8460 — feat(mintv2): amount_unit config]]
- [[2026-06-15-fedimint-recent-prs-and-discussions|Recent PRs & discussions]] — #8395 gateway-extensibility, #8680 v2-module status
