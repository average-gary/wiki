---
title: "SV2 role taxonomy: when does a pool need JDS? — implications for DATUM"
source: https://github.com/stratum-mining/sv2-spec/blob/main/05-Mining-Protocol.md
source_secondary: https://github.com/stratum-mining/sv2-apps
source_type: spec+repo-listing
ingested_by: path3
ingested_at: 2026-06-01
quality: medium-high
relevance: critical
tags: [sv2, pool, jds, jdc, work-selection, custom-mining-job, datum-proxy, model-selection]
---

# SV2 role taxonomy and the DATUM proxy model question

## Key findings

- **Roles in the SRI app layer (from `sv2-apps` repo listing):** Pool, Job
  Declarator Server (JDS), Job Declarator Client (JDC), Translator Proxy,
  Mining Proxy. JDS lives in `pool-apps/jd-server`; JDC lives in
  `miner-apps/jd-client`. They are independent processes/binaries.

- **`REQUIRES_WORK_SELECTION` is the per-connection flag that gates JDS
  involvement.** Per the SV2 mining spec: "When set, the client notifies the
  server it will send `SetCustomMiningJob` on this connection." Without it, the
  downstream node receives only pool-selected work via `NewExtendedMiningJob`.

- **Pools CAN operate without a JDS.** Confirmed quote from the spec
  summary: "The protocol permits pools to distribute work to mining devices
  unilaterally through `NewExtendedMiningJob` without supporting custom jobs
  or JDS integration." This is "model (a)" — proxy is the template authority,
  ships internally-constructed templates as `NewExtendedMiningJob`. **DATUM's
  GBT-from-local-bitcoind paradigm fits model (a) perfectly.**

- **JDS only matters when downstream nodes want to declare their OWN
  templates.** The classic decentralized-mining JDS-JDC-Pool flow is:
  - JDC (miner-side): builds template from its own bitcoind, computes
    `DeclareMiningJob` with a mining job token.
  - JDS (pool-side): authorizes the declared template, hands back a token,
    eventually validates/signs the declared job before the pool accepts shares
    against it.
  - Pool: receives `SetCustomMiningJob` referring to that token, runs share
    validation against the JDC-supplied coinbase + outputs.

- **For DATUM, model (b) — proxy as JDS to downstream JDCs — is overkill and
  semantically wrong:**
  - DATUM gateway operators are typically running for one site (their farm)
    where one local bitcoind feeds many ASICs. Adding a JDS layer would mean
    each ASIC ran a JDC against its own bitcoind, which contradicts DATUM's
    centralized-template-construction model.
  - The DATUM gateway's whole point is to be the local template authority and
    push OCEAN's required outputs into it. Re-decentralizing template
    declaration at the per-miner level inside the gateway makes no sense.
  - Model (b) would also fragment OCEAN's coinbase-output enforcement: each
    JDC's declared template would need its own validation against OCEAN's
    rules, and the gateway would need to act as a JDS-with-OCEAN-policy, which
    is yet more code than just writing a pool front.

- **Model (c) — internal JDC against an internal JDS — is pure plumbing
  with zero external benefit.** It would mean the DATUM gateway runs a JDS
  process, and the SV2 proxy runs a JDC process talking to that JDS.
  All in one binary box, all signing tokens to itself. Adds two protocol
  hops, two more state machines, zero new functionality. Reject.

- **Conclusion: model (a) is the right architecture.** The DATUM SV2 proxy is
  a plain SV2 pool front. It implements `HandleMiningMessagesFromClientAsync`,
  uses `ExtendedChannel::new_for_pool`, feeds itself templates from
  gateway-side GBT, and never sees `SetCustomMiningJob`.

## Ingest justification

This is the central design decision the path 3 question asks. Establishes
that DATUM operators don't want federation at the per-miner level; they want
a simple downstream SV2 termination that preserves the gateway's existing
"local bitcoind builds the template, OCEAN supplies required outputs"
contract. Rules out two of three architecture options.
