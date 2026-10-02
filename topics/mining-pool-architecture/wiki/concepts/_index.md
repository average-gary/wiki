# concepts Index

> Compiled concepts articles for mining-pool-architecture.

Last updated: 2026-09-23

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [the-two-hot-paths.md](the-two-hot-paths.md) | The organising principle: a pool has exactly two latency-critical paths — job push (fan-out on template change) and share submit (fan-in). Everything else is off both and may be slow. Most architecture arguments are really arguments about what is allowed to sit on one of them. | hot-path, share-submit, job-push, latency-budget, fan-in, fan-out | 2026-09-21 |
| [vardiff-as-control-loop.md](vardiff-as-control-loop.md) | Vardiff does three jobs at once: it decouples aggregate share rate from network hashrate (`connections / interval`), it sets per-miner variance and feedback latency, and it is a privacy parameter (a fixed starting difficulty is what made metadata hashrate inference cheap). Its structural defect: arrival-triggered controllers cannot see non-arrival, so slowed miners are stranded — and the fix must live at the last hop that sees each miner. | vardiff, control-loop, stranded-difficulty, timer-based-reduction, last-hop-principle, share-rate | 2026-09-21 |
| [connection-layer-scaling.md](connection-layer-scaling.md) | Because vardiff flattens share rate, this is the layer that saturates. Shard the accept path (`SO_REUSEPORT`, worker processes, passthrough trees) rather than growing one loop; sockets are ~3 KB of kernel memory each and threads are not an option. Includes the NIC-hash hot-spotting hazard for farms behind one NAT. The across-regions half moved to `regional-routing-and-session-continuity`; reconnect storms remain undocumented in public, with ckpool's socket handover the only engineered answer. | c10k, epoll, so-reuseport, passthrough, stateful-tcp, load-balancing, reconnect-storm, socket-handover | 2026-09-22 |
| [template-sourcing-and-control.md](template-sourcing-and-control.md) | Two questions that were one question for a decade. Sourcing moved from polling `getblocktemplate` to a push-based Cap'n Proto IPC Mining interface in official Core binaries. Control now has four production answers — pool-opaque, pool-published, miner-declared/pool-validated, miner-sovereign — differing not in protocol capability (BIP 23 specified it in 2012) but in who pays the operational cost and who gets paid for it. | template-sourcing, mining-ipc, push-vs-poll, job-declaration, datum, feerate-cliff, incentives | 2026-09-21 |
| [share-accounting-and-durability.md](share-accounting-and-durability.md) | What a pool must actually remember about shares, and where. ckpool keeps accounting entirely in memory with no SQL schema — enabled by having no accounts at all, and it **disabled its PostgreSQL companion `ckdb` in 2017**. The SRI reference pool persists **nothing**, losing `seen_shares` on restart so replay protection does not survive one. What must persist is driven by adversaries, not payout: replay prevention (in direct conflict with bounding memory) and long-horizon per-worker history for withholding detection — which **no production pool actually retains**. Plus the 393× lock-contention argument for single-writer sharding. | share-accounting, durability, batching, single-writer, deduplication, replay, retention, withholding-detection | 2026-09-22 |
| [regional-routing-and-session-continuity.md](regional-routing-and-session-continuity.md) | Closes round 1's largest gap, in two halves. What pools do: DNS resolution shows the majority behind **Cloudflare anycast**, where the edge terminates TCP so session state never moves. What nobody does: migrate an established connection between servers — unsolved for stateful TCP without application-layer resumption, which Stratum lacks. So every design ends in a reconnect, and the real question is making reconnects cheap, bounded and **unsynchronised**. | anycast, cloudflare, tcp-proxy, geodns, consistent-hashing, connection-migration, failover, reconnect-storm, socket-handover | 2026-09-22 |

## Categories

- **organising-principles**: the-two-hot-paths
- **control-loops**: vardiff-as-control-loop
- **scaling**: connection-layer-scaling, regional-routing-and-session-continuity
- **template-layer**: template-sourcing-and-control
- **accounting**: share-accounting-and-durability

## Recent Changes

- 2026-09-23: Blitzpool notes added to `vardiff-as-control-loop` (silence easing off by default), `regional-routing-and-session-continuity` (live upstream swap exists, production does not use it) and `share-accounting-and-durability` (the nearest thing to long-horizon retention).

- 2026-09-22: Round 2 — added `regional-routing-and-session-continuity`; updated `share-accounting-and-durability` (SRI persists nothing; client-side-only bounding correction; ckdb history) and `connection-layer-scaling` (routing gap closed).

- 2026-09-21: Five concept articles compiled from research round 1.
