---
title: "Stratum mining protocol — Bitcoin Wiki"
source: https://en.bitcoin.it/wiki/Stratum_mining_protocol
type: articles
tags: [sv1, primitives, mining-subscribe, mining-notify, mining-submit, set-difficulty]
summary: "Canonical SV1 spec — mining.subscribe/authorize/notify/submit/set_difficulty parameters and semantics. Foundation for any reverse-translator's upstream side."
confidence: high
ingested: 2026-05-28
ingested_by: path1
quality_score: 5
---

# Stratum mining protocol — Bitcoin Wiki

## Key fields per method

- **mining.subscribe**: returns `[subscriptions, extranonce1, extranonce2_size]`. Pool dictates extranonce1 (per-conn unique) and extranonce2_size (byte count miner controls).
- **mining.notify**: 9 params — `job_id, prev_hash, coinb1, coinb2, merkle_branch[], version, nbits, ntime, clean_jobs`. clean_jobs=true means abandon prior work (analogous to SV2 `SetNewPrevHash`).
- **mining.set_difficulty**: float; pool→miner. Lossy vs SV2's U256 `max_target`. pdiff convention uses `0x00000000FFFFFFFF...` as max.
- **mining.set_extranonce**: extension (not in the original spec) — requires `subscribe-extranonce` capability via `mining.configure`.
- **mining.submit**: 5 params (with version-rolling, 6) — `worker_name, job_id, extranonce2, ntime, nonce[, version_bits]`.
- **mining.authorize**: returns `true`/`false`. Authentication is username + password.

## Reverse-translator implications

- Reverse translator is an SV1 *client*, must consume the subscribe response, set its `extranonce_prefix := extranonce1` for each downstream SV2 Extended channel.
- Job-ID is a string upstream, must be mapped to SV2's `u32` and stored in a per-channel HashMap for `mining.submit` translation back upstream.
- `clean_jobs=true` triggers a synthesized `SetNewPrevHash` to all downstream SV2 channels.
- Pool credentials (user/pass) are held per-translator-instance; reverse translator may multiplex many SV2 channels onto one upstream connection, with mapping channel_id ↔ worker_name.

## See also

- [[2026-05-28-path1-bip-310-version-rolling]] — version-rolling negotiation extension
- [[2026-05-28-path1-sv2-spec-mining-protocol-channels]] — SV2 message tables on the other side of the translation
