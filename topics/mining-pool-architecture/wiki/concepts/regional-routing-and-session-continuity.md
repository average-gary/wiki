---
title: "Regional Routing and Session Continuity"
category: concept
sources:
  - raw/articles/2026-09-22-pool-multi-region-anycast-and-failover.md
  - raw/notes/2026-09-22-stateful-tcp-routing-options-and-limits.md
  - raw/articles/2026-09-21-solo-ckpool-production-operations.md
  - raw/repos/2026-09-21-ckpool-architecture.md
created: 2026-09-22
updated: 2026-09-22
tags: [anycast, cloudflare, tcp-proxy, geodns, consistent-hashing, connection-migration, failover, cgminer, client-reconnect, reconnect-storm, socket-handover, session-continuity]
aliases: ["multi-region pool", "stratum routing", "pool failover"]
confidence: high
volatility: warm
summary: "Closes round 1's largest gap with a two-part answer. What pools do: the majority outsource it — DNS resolution shows AntPool, F2Pool, ViaBTC, Foundry, Braiins, Poolin and SpiderPool all behind Cloudflare anycast, where the edge terminates TCP so session state never has to move. What nobody does: migrate an established connection between servers. That is unsolved for stateful TCP without application-layer session resumption, which Stratum lacks — so every design ends in the miner reconnecting, and the real engineering question is how to make reconnects cheap, bounded, and unsynchronised."
---

# Regional Routing and Session Continuity

> Round 1 called this the largest hole in the operational picture: how does anyone route a *stateful*
> long-lived TCP protocol across regions, when a Stratum connection carries per-connection difficulty,
> extranonce assignment and job history and lasts for days? The answer has two halves, and the second is
> a negative result.

## What pools actually do: buy a CDN

DNS resolution across the major pools:

| Pool | Resolves into | |
|---|---|---|
| AntPool, F2Pool, ViaBTC, Foundry USA, Braiins/Slush, Poolin, SpiderPool | **Cloudflare** ranges (172.65.x.x, 104.18.x.x) | whois-confirmed |
| Luxor | 35.244.212.109 | Google Cloud |
| Ocean | no A/AAAA returned | — |

**The test that settles it**: `stratum.braiins.com` queried through 1.1.1.1 and 8.8.8.8 returns the
**same IP**. Under DNS-based geo-routing the answers would differ by resolver geography. One globally
announced address plus a CDN range means **BGP anycast**, not GeoDNS. (`stratum.braiins.com` and
`stratum.slushpool.com` also resolve to the same address — 172.65.65.63.)

### Why that defuses the stateful-TCP objection

Anycast is normally hazardous for long-lived TCP: a route change can re-path packets to a different
datacentre that knows nothing about the connection. But managed anycast products are **TCP proxies**, not
transparent routers. AWS Global Accelerator documents it plainly: it *"terminates TCP connections from
clients at AWS edge locations and, almost concurrently, establishes a new TCP connection with your
endpoints."* Cloudflare's equivalent works the same way.

So the session lives at a specific edge location once established, and the pool origin sees one
long-lived connection per edge. The pool gets proximity without operating regional pool servers, and
never has to solve session migration.

Three costs worth naming:

- **A third party is now in the path of every share.** That sits oddly beside SV2's own threat model —
  the peer-reviewed StraTap/BiteCoin attacks are precisely about a party in the network path inferring
  hashrate and re-attributing shares. End-to-end Noise defeats an edge observer only if the CDN is passing
  bytes rather than terminating the protocol.
- **Edge health checks do not protect established sessions.** Global Accelerator: *"continues to direct
  traffic for established connections to an endpoint until the idle timeout is met, even if the endpoint
  is marked as unhealthy"* — up to **340 s** for TCP.
- **An edge POP failure drops every session at that POP simultaneously** — a synchronised reconnect event,
  which is the reconnect-storm scenario.

### ckpool takes the other path, and it is still unexplained

solo.ckpool.org publishes five real regional hostnames — `uwsolo` (US West), `uesolo` (US East),
`eusolo` (Germany), `sgsolo` (Singapore), `ausolo` (Australia) — for manual selection, noting that
choosing one **gives up the main endpoint's automatic failover**. But `solo.ckpool.org` resolves to a
**single IP** (15.204.102.129, OVH), not a CDN anycast address, so its advertised "automatic lowest
latency connection" is not explained by anything visible in DNS. Candidates: client-side probing, or a
redirect after connect.

Related: ckpool's `-R` **redirector** mode is *not* latency-based. It waits for a first accepted share,
then redirects to one of the configured `redirecturl` entries, cycling through them while trying to keep
clients from the same IP on the same pool. Round-robin with IP affinity. Two notes: redirect-after-first-share
is a neat load-shedding trick — unproductive connections never reach the real pool — and IP affinity is
the same property that makes a large farm behind one NAT address pin to one backend.

## What nobody does: migrate a live connection

**Seamless migration of an established TCP connection between servers is unsolved** without
application-layer session resumption, and Stratum has none. Confirmed across the whole L4 landscape:

- **`SO_REUSEPORT`** distributes *new* connections only. The kernel **cannot** migrate established
  connections between processes — a given connection is served by one thread in one process, forever.
- **HAProxy's hitless reload** (`SO_REUSEPORT` plus `-x` socket-FD inheritance with `expose-fd listeners`)
  therefore upgrades the *load balancer* without dropping miners, while a **backend** restart still breaks
  every session on it.
- **Consistent hashing** (`balance source hash-type consistent`, `hash $remote_addr consistent`,
  `ipvsadm -s sh -p 604800`) does not preserve sessions either — it *bounds the blast radius*, so losing
  one of three backends remaps ~⅓ of clients rather than all of them.
- **DNS** acts once, pre-connection. Route 53's own documentation: it *"does not make routing decisions
  based on the load or available traffic capacity of your endpoints."*

So the design question is not "how do I avoid reconnects?" It is **"how do I make reconnects cheap,
bounded, and unsynchronised?"** Which reframes several things elsewhere in this topic:

- **Vardiff ramp-up is a reconnect cost.** A reconnecting miner restarts difficulty discovery, and per
  Optech #423 recovery from a wrong difficulty can be slow. See
  [[vardiff-as-control-loop|Vardiff as a Control Loop]] ([Vardiff as a Control Loop](vardiff-as-control-loop.md)).
- **ckpool's socket handover (`-H`)** is the only pool-side instance of the technique anyone has: the new
  process inherits the listening socket from the exiting one, so an upgrade does not drop connections. It
  is the single best answer to the storm problem in any pool codebase found.
- **A proxy can swap the upstream under a live downstream, and the one that can still chooses not to.**
  Blitzpool's rental proxy keeps the miner's TCP connection open and re-points it to a different pool.
  On SV1 it uses `mining.set_extranonce`; on SV2 it uses `SetExtranoncePrefix` with channel IDs remapped
  (`src/proto/relay.rs:244-305`, `sv2/relay.rs:889-1041`). But that path is `#[cfg(test)]`-only, and
  production order switches go through `force_reconnect` (`src/control.rs:75-91`). SV2 failover reconnects
  even after a successful swap, with the authors citing ~200 rejects/min in prod. Only SV1 failover
  re-points in place, and only for miners that subscribed to extranonce changes. The swap cannot change
  the extranonce size, and in-flight shares are lost. It is also not session migration: the new upstream
  sees a fresh connection. So this is the closest thing to a counterexample found, and its own authors
  judged a clean reconnect safer.
- **Synchronised reconnects are the danger, not reconnects.** An edge POP failure, a DNS TTL expiry, or a
  pool restart all hit every client at once.

## Failover timing, and an asymmetry worth copying

**cgminer** — the ancestor of most ASIC firmware behaviour — treats pools as a priority list
(`POOL_FAILOVER`), and:

- Returns to a higher-priority pool **only after it has been stable for `opt_pool_fallback = 120`
  seconds** (`now.tv_sec - pool->tv_idle.tv_sec > opt_pool_fallback`); a source comment adds that pools
  must be alive >5 minutes "to prevent intermittently failing pools from being used".
- Diverts *some* work to backups when the primary is merely **lagging**; `--failover-only` disables that.

**Leaving is fast, returning is slow and hysteretic.** That damping is the right shape, and it is the
mirror image of the vardiff defect — failover has the timer that vardiff lacks.

**Undocumented anywhere**: the *initial* failover trigger. No timeout, failed-request count, or
share-rejection threshold was found in cgminer or any firmware. An operationally critical parameter that
remains black-box.

**`client.reconnect(hostname, port, waittime)`** exists in the V1 spec, with an explicit escape hatch:
*"for security purposes, clients may ignore such requests if the destination is not the same or
similar."* Sensible — in an unauthenticated plaintext protocol, a redirect primitive *is* a hijacking
primitive. Round 1 carried a claim that "many newer stratum clients do not respect the reconnect field at
all"; **that was not substantiated and is downgraded to unverified.** Nobody has measured compliance.

## Practical shape

| Layer | Choice | Failover | Blast radius |
|---|---|---|---|
| Global | CDN anycast + TCP proxy | new flows immediate; established up to idle timeout | one POP |
| Global (alternative) | GeoDNS latency-based, TTL ≤ 60 s, ECS enabled | 1–5 min (30–90 s health check + TTL) | all clients on that record |
| Regional | L4 LB, consistent hashing, `timeout client/server` in **hours** | 10–60 s | the hashed fraction |
| Process | `SO_REUSEPORT` + socket handover | zero for LB reloads | none |
| Client | multiple pool URLs, priority list | 1–30 s | per-client, unsynchronised |

Also publish per-region hostnames alongside the auto-select one — degradation should be
*suboptimal routing*, never *broken routing*, and an operator needs a manual override when auto-selection
guesses wrong.

## The assumption underneath all of it

**No evidence was found that geographic distribution measurably improves revenue.** The chain — lower
latency → faster block-change notification → lower stale rate → higher effective hashrate — is assumed
everywhere. No pool publishes stale rate by region; no latency-to-revenue measurement was accessible.

The direction is certain and now partly quantified: benchmark data shows job latency of 142 ms (SV1) vs
7.33 ms (SV2) and a 1.34% SV1 stale rate, so latency clearly drives stale shares. What is unquantified is
the *regional* component — how much of that latency is geography, and what a region is worth. It belongs
in the same category as the SV2 marketing figures: structurally sound, quantitatively unestablished, and
it is the justification for putting a CDN in the share path.

## See Also

- [[connection-layer-scaling|Connection Layer Scaling]] ([Connection Layer Scaling](connection-layer-scaling.md)) — the within-box half of the same problem.
- [[vardiff-as-control-loop|Vardiff as a Control Loop]] ([Vardiff as a Control Loop](vardiff-as-control-loop.md)) — why a reconnect is not free.
- [[the-two-hot-paths|The Two Hot Paths]] ([The Two Hot Paths](the-two-hot-paths.md))
- [[optimal-pool-architecture|Optimal Pool Architecture]] ([Optimal Pool Architecture](../topics/optimal-pool-architecture.md))
