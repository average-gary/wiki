---
title: "Bitcoin Covenants Part 3: SIGHASH_ANYPREVOUT (Cointelegraph Research)"
source: "https://cointelegraph.com/research/bitcoin-covenants-part-3-sighash-anyprevout"
type: articles
ingested: 2026-07-16
tags: [anyprevout, apoas, signature-replay, presigning, amount-commitment, value-mismatch, covenants, secondary-source]
summary: "A well-structured secondary explainer of APO's limitations. Enumerates replay high-risk scenarios (ANYPREVOUT|SINGLE with reorderable outputs; identical scriptPubKey+amount; same pubkey under APOAS; miner-influenced ordering). Confirms plain APO commits to amount+scriptPubKey; APOAS drops both. Key presigning footgun: if a presigned tx binds to a LARGER UTXO than signed, 'the excess will be lost to miners unless the original signature included a change output.' APO is not a recursive covenant."
---

# Bitcoin Covenants Part 3: SIGHASH_ANYPREVOUT

Cointelegraph Research (secondary, well-structured). Best single explainer tying
replay + amount-commitment + presigning value-mismatch together.

## Replay high-risk scenarios

1. `ANYPREVOUT | SINGLE` when outputs can be reordered
2. Separate UTXOs with identical scriptPubKey *and* amount
3. Same pubkey across compatible scripts under `ANYPREVOUTANYSCRIPT`
4. **Miners influencing transaction ordering**

Caveat: these "require either deliberate misuse or a failure of the user or developer
to account for replay conditions during protocol design."

## Amount commitment (corroborates the spec)

- Under `ANYPREVOUT`, "the outpoint is excluded from the digest, but the signature
  still commits to the amount and scriptPubKey of the previous output."
- `ANYPREVOUTANYSCRIPT` removes both, making it "less suited to covenant-style
  applications."

## Presigning limitation (directly relevant to mining payouts)

- If a tx is pre-signed to produce 0.5 BTC but is later bound to a *larger* UTXO, "the
  excess will be lost to miners unless the original signature included a change
  output." **Rebinding is only safe when the amount matches what was signed.**

## Not a recursive covenant

- Like CTV, APO "does not by itself enable recursive covenants or transaction
  introspection."
