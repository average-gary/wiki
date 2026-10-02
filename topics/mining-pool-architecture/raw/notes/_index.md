# notes Index

> Raw notes sources for mining-pool-architecture.

Last updated: 2026-09-22

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [2026-09-21-adjacent-systems-design-transfer.md](2026-09-21-adjacent-systems-design-transfer.md) | Nine general-systems sources aggregated, each annotated with how it maps onto a pool. Load-bearing measurements: `SO_REUSEPORT` took Cloudflare from 650k to 1.15M pps by removing accept-path contention (1.4M with NUMA alignment; 4× penalty for crossing nodes); MigratoryData held **12M connections at ~3 KB kernel memory each**; Thompson's single-writer figures put two-thread locking at **393×** single-thread cost; Tokio work-stealing gave +34% throughput; InfluxDB batches 5–10k points per fsync; and a Cloudflare postmortem traced 1 s tail latencies to `tcp_collapse` on oversized buffers, fixed by cutting `tcp_rmem` max from 32 MB to 2–4 MB. Transfers graded high / medium / speculative. | c10k, so-reuseport, numa, tokio, work-stealing, batched-writes, single-writer-principle, tail-latency, tcp-collapse, connection-memory | 2026-09-21 |
| [2026-09-21-pool-failure-modes-aggregate.md](2026-09-21-pool-failure-modes-aggregate.md) | Five failure stories ranked by evidence quality. Best: the 2015-07-04 SPV-mining fork (F2Pool, AntPool, BTC Nuggets named; >$50,000 lost) — a latency optimisation with systemic consequences, and the operational counterpart to the measured empty-block finding. Then p2pool's variance death spiral, documented by its own fork maintainer (blocks every ~108 days on mainnet in Feb 2018). Then slush0's own `stratum-mining`, archived 2023, whose job-ID and ntime bugs recur verbatim in class in SV2 fourteen years later. Weaker: NOMP/MPOS abandonment, where the "Node.js is unsuitable" diagnosis is the agent's inference and is partly contradicted by the share-rate arithmetic. | failure-modes, spv-mining, 2015-fork, nomp, abandonment, p2pool-variance, dust-spam, postmortem | 2026-09-21 |
| [2026-09-21-protocol-lineage-secondary-sources.md](2026-09-21-protocol-lineage-secondary-sources.md) | Secondary and vendor sources for the lineage — community wiki pages plus Braiins on SV2 and Ocean on DATUM. `getwork`'s extension list (`longpoll`, `rollntime`, `noncerange`) read as a diagnosis: each buys more local iteration per round trip. Slush Pool 2010-11-27, whose first architectural change was an anti-hopping *accounting* fix. p2pool 2011-06-17 with its 30 s share chain and 8,640-share retention. The Stratum wiki's process criticism: no BIP, developed "behind closed doors". Vendor claims labelled — including DATUM's demonstrably loose "first decentralized protocol since 2017". | getwork, slush-pool, p2pool, stratum-history, informal-standardisation, sv2-origin, datum-origin, protocol-lineage | 2026-09-21 |
| [2026-09-22-stateful-tcp-routing-options-and-limits.md](2026-09-22-stateful-tcp-routing-options-and-limits.md) | The general half of the routing question, with a **negative result**: migrating an established TCP connection between servers is **unsolved** without application-layer session resumption, which Stratum lacks — so every option ends in the miner reconnecting. AWS Global Accelerator **terminates TCP at the edge** (not transparent anycast), with 5-tuple stickiness, a 340 s idle timeout, and the documented hazard that it keeps sending to an endpoint *even when marked unhealthy* until that timeout. HAProxy/NGINX/IPVS consistent hashing bounds blast radius; `SO_REUSEPORT` + `-x` FD inheritance gives hitless **LB** reloads but cannot move a connection between processes. | stateful-tcp, anycast, tcp-proxy, haproxy, nginx-stream, ipvs, consistent-hashing, so-reuseport, connection-migration, geodns | 2026-09-22 |

## Categories

- **cross-domain-transfer**: adjacent-systems-design-transfer
- **failure-evidence**: pool-failure-modes-aggregate
- **history**: protocol-lineage-secondary-sources

## Recent Changes

- 2026-09-22: Research round 2 additions (see rows dated 2026-09-22).

- 2026-09-21: Three aggregate notes written in research round 1. Each bundles several thin or secondary sources rather than creating one file per source; per-item URLs and grades are inside.
