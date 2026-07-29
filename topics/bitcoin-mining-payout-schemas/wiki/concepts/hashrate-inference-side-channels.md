---
title: Hashrate Inference Side Channels
category: concept
created: 2026-07-29
confidence: high
tags: [side-channel, traffic-analysis, vardiff, stratum, hashrate-inference, share-theft, mining-cookie, bitecoin]
volatility: cold
updated: 2026-07-29
summary: "Measured attacks recovering a miner's hashrate and earnings from Stratum traffic — including from packet timestamps alone with no payload access. VarDiff calibration is itself the side channel, which is why encryption does not close it."
verified: 2026-07-29
sources:
  - "raw/papers/2026-07-29-recabarren-carbunar-hardening-stratum.md"
  - "raw/papers/2026-07-29-bba-plus-black-box-wallets.md"
---

# Hashrate Inference Side Channels

Recabarren & Carbunar (PoPETs 2017) is the only paper with **measured** figures showing that a
miner's hashrate and earnings are recoverable from Stratum traffic. It matters here for two
reasons: it bounds what transport encryption can buy, and it supplies the one strong technical
argument that **identity binding currently protects share credit from theft**.

## The inference

```
hashrate = difficulty × 2^32 / time
```

where `difficulty` comes from `mining.set_difficulty` and `time` = (interval between difficulty
changes) / (accepted share count).

| Attack | Access required | Payout prediction error | MSE / MPE |
|---|---|---|---|
| **StraTap** | full packet contents | **1.75 – 6.5 %** | 0.062 / −3.46 % |
| **ISP Log** | *inter-packet timestamps of the first 50 packets only* | **0.53 – 34.4 %** | 2.02 / −9.49 % |

Dataset: 138 MB of live Stratum from an AntMiner S7 — US (May–Jun 2016) and Venezuela
(Mar–Apr 2016), 13 days, frequency swept 100–700 MHz.

The ISP Log figure is the important one. **No payload access at all**, and it still predicts
daily payout. This is why [[payout-attribution-privacy|the pool's]] knowledge is not the only
concern — a passive network observer gets most of the way there.

## VarDiff calibration *is* the channel

F2Pool sets difficulty to 1024 on authorize, then waits for **~50 share submissions** (measured
50–67 packets across 100–650 MHz) before the second `set_difficulty`. Inter-packet time over
those 50 packets decreases monotonically with device frequency.

**The calibration handshake the pool needs in order to set a sane target is the same signal that
leaks hashrate to anyone counting packets.** Every reconnect restarts it, re-leaking. This is a
structural coupling, not an implementation slip: any pool must discover a miner's rate to assign
a workable difficulty, and discovery is observable.

Hence the paper's conclusion on encryption: **"not only undesirable but also ineffective"**
against the inference channel. Measured costs: blanket encryption 1.36 h/day of pool CPU at
16,000 miners; TLS 1.01 h/day plus 58 % more miner→pool bandwidth.

## Corroboration from an unrelated domain

Biryukov & Pustogarov's Tor PoW-micropayment scheme (FC 2015) hit the same wall from the other
direction. Clients mine shares over an anonymous circuit and receive blind-signed tickets — full
cryptographic unlinkability of the *ticket* — and the authors still note:

> "A curious relay can however learn the **hash rate** of a client, thus it may recognize
> repeated connections from the same client. In order to mitigate such an attack a client is
> advised to **randomize its hash rate**."

**Submitted work volume is itself a fingerprint, and no cryptographic primitive removes it.**
Their advice — randomize the rate — is the only known mitigation, and it costs revenue.

## Stratum V1 leak surface

`mining.subscribe` → `extranonce1`, `extranonce2.size`; `mining.authorize` → username and
password **in cleartext** (password "currently ignored by pools"); `mining.set_difficulty`;
`mining.notify` → `job_id`, params, `clean_jobs`; `mining.submit` → username, `job_id`, `time`,
`nonce`, `extranonce2`. F2Pool sets `extranonce1` to a constant rather than per-connection random.

**Target reconstruction attack**: recover `extranonce1` from subscribe, coinbase1/coinbase2 and
Merkle branches from a job, nonce/extranonce2 from a submit → reconstruct the header, count
leading zeros to bound the target — *without ever seeing a difficulty message*.

## BiteCoin and the mining cookie — why identity currently guards share credit

**BiteCoin** TCP-hijacks the miner↔pool connection and **steals shares** and payouts.

The countermeasure, **Bedrock**, binds a per-miner secret into the puzzle: a mining cookie
`C_M = H²(R_M, M.uname)` placed in the coinbase's unused previous-input-hash field. It works
precisely *because the miner's username is an input to the hash*:

> "the pool would use the attacker's username instead of the victim's username to construct the
> cookie … The share will only validate if the attacker managed to find a username that produced
> a double hash that was still smaller than the target."

**This is the strongest technical argument that share-credit integrity currently depends on
identity binding** — and note it is an argument about *theft*, not about block withholding (which
is a separate and much weaker objection, see
[[block-withholding#Does detection actually need attribution?|block withholding]]).

Two things follow:

1. Whether this defense survives being rebuilt on a **blinded** commitment rather than a
   plaintext username is **unanalyzed by anyone**. It is the top open technical question for any
   self-blinding design.
2. **Bedrock provides zero privacy from the pool** — the pool generates `R_M` and shares `K_M`.
   Every defense in the paper treats the pool as a trusted endpoint.

## Sources

- [[../../raw/papers/2026-07-29-recabarren-carbunar-hardening-stratum|Hardening Stratum (Recabarren & Carbunar, PETS 2017)]]
- [[../../raw/papers/2026-07-29-bba-plus-black-box-wallets|BBA+ / Black-Box Wallets + Tor PoW micropayments]]

## See also

- [[payout-attribution-privacy]] — the full threat model
- [[blind-share-accounting]] — what cryptography can and cannot fix here
- [[../topics/self-blinding-pool-design-space|Self-Blinding Pool Design Space]]
- [[nullifier-vs-pseudonym|Nullifier vs Pseudonym — why duplicate rejection does not need identity]]
- [[../theses/blinded-share-credit-commitment|Thesis: blinded share-credit commitment]] — the 2026-07-29 verdict round

