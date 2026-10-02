# articles Index

> Raw articles sources for mining-pool-architecture.

Last updated: 2026-09-22

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [2026-09-21-vardiff-non-arrival-blindness-optech-423.md](2026-09-21-vardiff-non-arrival-blindness-optech-423.md) | Optech #423 (2026-09-18). Eric Price: a vardiff controller that updates only on share *arrival* cannot detect *non-arrival*, so a slowed miner stays stranded at too-high difficulty indefinitely — underpaid, and indistinguishable from disconnected in hashrate estimation. No parameter tuning fixes it; needs a timer. Placement conclusion (agreed by Anthony Towns): control must live at "the last hop that still sees each miner's shares", i.e. the proxy/gateway, not the upstream pool. Shaping proxy released for testing. | vardiff, control-loop, stranded-difficulty, timer-based-reduction, last-hop-principle, eric-price | 2026-09-21 |
| [2026-09-21-bitcoin-core-mining-ipc-and-template-interfaces.md](2026-09-21-bitcoin-core-mining-ipc-and-template-interfaces.md) | The template-source layer and its 2024–26 rewrite. `getblocktemplate` fields and ~10 MB templates; ZMQ topics with the up-counting sequence number as the only loss-detection primitive. Then: Core rejected embedding SV2 (PR #29432 closed — no new ports, no protocol code in consensus), and shipped a general Mining interface over Cap'n Proto IPC instead. PR #31802 (merged 2025-08-20) put IPC-enabled binaries in official releases, removing the forked-bitcoind blocker; #31981 added `checkBlock()`; #34020 added batched wtxid lookup. Templates are now pushed on a fee threshold, not polled. | template-sourcing, getblocktemplate, zmq, mining-ipc, capnproto, checkblock, wtxid-lookup, push-based-templates | 2026-09-21 |
| [2026-09-21-stratum-v1-original-announcement-slush.md](2026-09-21-stratum-v1-original-announcement-slush.md) | Marek Palatinus (slush0), BitcoinTalk, 2012-09-11. Stated goals: server-driven load management for 10k+ connections at minimal CPU, reduced bandwidth vs getwork, ASIC readiness. Explicitly rejects BIP 22/23 as too complex to deploy. BTC Guild's operator withdraws a near-identical proposal to avoid a "VHS vs Betamax" split — the moment Stratum became the de facto standard over the more decentralising getblocktemplate. Pool-side templates followed as a side effect of a scalability decision. | stratum-v1, protocol-history, de-facto-standard, connection-scaling, slush, getblocktemplate | 2026-09-21 |
| [2026-09-21-dmnd-datum-decentralised-template-deployments.md](2026-09-21-dmnd-datum-decentralised-template-deployments.md) | The two production attempts at miner-side templates. DMND: first SV2 Job Declaration block 2026-06-26 at height 955,318; miners connect to a local `demand-cli` on 32767 with unchanged firmware, SV2+JD outbound on 20000, Template Provider on 8336 — outbound-only firewall. SLICE payout splits PPLNS subsidy from job-declaration fee scoring. Ocean DATUM goes further (miner's own node builds via GBT, pool coordinates only) and reaches decentralised templates *over Stratum V1*, but remains explicit public beta and sizes RAM at ~1 GB per 1,000 clients. | job-declaration, datum, dmnd, template-decentralisation, deployment-topology, slice-payout, beta-status | 2026-09-21 |
| [2026-09-21-solo-ckpool-production-operations.md](2026-09-21-solo-ckpool-production-operations.md) | The only real production deployment documented in this round. Endpoints in US west/east, Germany, Singapore, Australia with latency-based auto-selection and failover (mechanism undisclosed — the largest operational gap in the topic). 10,000 difficulty floor for accounting plus a cosmetic client-side floor of 1; separate high-difficulty rental ports 4334/4336. Default Core transaction selection with no filtering, published live at `/pool.txns`. No registration and no operator wallet — which is what permits in-memory-only accounting. | production-operations, geographic-distribution, minimum-difficulty, difficulty-tiers, transaction-selection-transparency, operational-minimalism | 2026-09-21 |
| [2026-09-22-pool-multi-region-anycast-and-failover.md](2026-09-22-pool-multi-region-anycast-and-failover.md) | **Closes round 1's largest gap.** Direct DNS resolution: AntPool, F2Pool, ViaBTC, Foundry, Braiins/Slush, Poolin and SpiderPool all resolve into **Cloudflare** ranges, and `stratum.braiins.com` returns the **same IP from 1.1.1.1 and 8.8.8.8** — ruling out GeoDNS and indicating **BGP anycast with edge TCP termination**, so pools outsource the stateful-routing problem. ckpool instead publishes five real regional hostnames (`uwsolo`/`uesolo`/`eusolo`/`sgsolo`/`ausolo`) while `solo.ckpool.org` resolves to a single IP, leaving its 'auto lowest latency' unexplained. cgminer failover: `opt_pool_fallback = 120 s` stability before returning to primary; **initial trigger undocumented**. Latency→revenue remains assumed everywhere and evidenced nowhere. | multi-region, anycast, cloudflare, geodns, failover, cgminer, client-reconnect, redirector, latency-assumption | 2026-09-22 |

## Categories

- **operational-findings**: vardiff-non-arrival-blindness-optech-423, solo-ckpool-production-operations
- **template-layer**: bitcoin-core-mining-ipc-and-template-interfaces, dmnd-datum-decentralised-template-deployments
- **protocol-history**: stratum-v1-original-announcement-slush

## Recent Changes

- 2026-09-22: Research round 2 additions (see rows dated 2026-09-22).

- 2026-09-21: Five articles ingested in research round 1.
