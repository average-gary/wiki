---
title: "Stratum V2 Specification — 06-Job-Declaration-Protocol.md"
source_url: https://github.com/stratum-mining/sv2-spec/blob/main/06-Job-Declaration-Protocol.md
source_type: specification
ingested: 2026-05-28
credibility: high
confidence: high
tags: [stratum-v2, job-declaration-protocol, JDC, JDS, SetCustomMiningJob, DeclareMiningJob]
---

# 06 — Job Declaration Protocol (canonical SV2 spec)

## Why this matters
Defines who controls coinbase content. The thesis is explicitly the *non-JD* case, so this spec is the authoritative answer to "what does JD do that bare mining does not?"

## Key claims (with quotes)
- Stated purpose: "The Job Declaration Protocol is used to coordinate the creation of custom work, avoiding scenarios where Pools are unilaterally imposing work on miners."
- JDC (Job Declarator Client, downstream) "MAY add more 0 value outputs in addition to the ones established by JDS" and "MAY add more non-0 value outputs" and "MAY arbitrarily reorder the outputs."
- Coinbase finishing under JD: JDC supplies `coinbase_tx_prefix` / `coinbase_tx_suffix` to the Pool via `DeclareMiningJob`, then the Pool uses `SetCustomMiningJob` to publish.
- `AllocateMiningJobToken` carries a `user_identifier`: "Whatever is needed by the pool to identify/authenticate the client, e.g. 'braiinstest'."

## Reading on the thesis
- The architectural answer to "miner influences coinbase" is **JD**, not `user_identity`.
- Outside JD, the spec frames the Pool as "unilaterally imposing work on miners" — meaning the Pool's own template is authoritative and there is **no spec-defined channel** for per-miner coinbase tags.
- However, "unilaterally imposing" cuts both ways: the Pool is free to put whatever it wants in *its* coinbase prefix/suffix, including a function of `user_identity`. That's not the *miner's* tag in any meaningful sense (the miner cannot verify nor influence it from the bare mining protocol's `OpenMiningChannel` request alone), but it is mechanically permitted.
