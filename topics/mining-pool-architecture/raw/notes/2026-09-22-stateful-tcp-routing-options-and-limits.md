---
title: "Routing stateful long-lived TCP: the options, their failure modes, and the thing nobody solved"
source: "https://docs.aws.amazon.com/global-accelerator/latest/dg/introduction-how-it-works.html"
related_sources:
  - "https://www.haproxy.com/documentation/haproxy-configuration-manual/latest/"
  - "https://www.haproxy.org/download/2.4/doc/management.txt"
  - "https://docs.nginx.com/nginx/admin-guide/load-balancer/tcp-udp-load-balancer/"
  - "https://www.kernel.org/doc/Documentation/networking/ipvs-sysctl.txt"
  - "https://www.rfc-editor.org/rfc/rfc7871.html"
  - "https://aws.amazon.com/route53/faqs/"
type: notes
ingested: 2026-09-22
tags: [stateful-tcp, anycast, tcp-proxy, global-accelerator, haproxy, nginx-stream, ipvs, consistent-hashing, stick-tables, so-reuseport, connection-draining, geodns, edns-client-subnet, route53-lbr, connection-migration]
summary: "The general-systems half of the regional-routing question, and its honest conclusion: seamless migration of an established TCP connection between servers is UNSOLVED without application-layer session resumption, which Stratum does not have. Every option therefore ends in 'the miner reconnects'; they differ only in how fast and how many are affected. Key mechanisms recorded: AWS Global Accelerator does NOT do transparent anycast — it terminates TCP at the edge and opens a second connection to the origin, with 5-tuple flow stickiness and a 340 s TCP idle timeout, and notably 'continues to direct traffic for established connections to an endpoint until the idle timeout is met, even if the endpoint is marked as unhealthy'. HAProxy/NGINX/IPVS all offer consistent-hashing source affinity (`balance source hash-type consistent`, `hash $remote_addr consistent`, `ipvsadm -s sh -p 604800`), which limits blast radius to the fraction of clients hashed to a failed backend. HAProxy's SO_REUSEPORT plus `-x` socket-FD inheritance gives hitless reloads of the LB layer — but explicitly cannot migrate a connection between processes, so a backend restart still breaks sessions. Route 53 latency-based routing gives 30–90 s health-check detection plus TTL, so 1–5 minutes of real failover."
credibility: high
credibility_score: 5
credibility_rationale: "Official vendor and kernel documentation plus an IETF RFC. Mechanisms and configuration directives are authoritative. The quantitative gaps the agent itself flagged (anycast reset rates, real-world TTL compliance, drain performance at scale) are genuinely absent from public sources, not merely unfound."
confidence: high
confidence_rationale: "High on mechanisms and on the negative conclusion about connection migration. The agent's own closing RECOMMENDATION (GeoDNS as 'proven at scale by every major mining pool') is CONTRADICTED by measurement — see the conflict note."
research_round: 2
research_agent: A1
conflicts_with: "This agent concluded GeoDNS latency-based routing is best practice and 'proven at scale by every major mining pool'. Agent A2 then resolved the actual DNS for eight major pools and found Cloudflare anycast, with identical IPs returned from 1.1.1.1 and 8.8.8.8 — which rules out DNS-based geo-routing. RESOLUTION: prefer A2's measurement. A1 was reasoning from general web practice without the mining-specific DNS data; its mechanism detail stands, its conclusion about what pools actually do does not. See raw/articles/2026-09-22-pool-multi-region-anycast-and-failover.md."
extraction_note: "Subagent report condensed. Configuration snippets are the agent's constructions from the referenced documentation, not copied from the vendor docs — treat them as illustrative and validate before use."
---

# Routing stateful long-lived TCP

The general half of the problem. The mining-specific answer is in the
[anycast/failover note](../articles/2026-09-22-pool-multi-region-anycast-and-failover.md); read that
first for what pools actually do.

## The conclusion, stated up front

**Nobody has solved seamless migration of an established TCP connection between servers.** Every
mechanism below ends the same way — the connection breaks and the client reconnects. They differ only
in *how quickly* that is detected and *what fraction* of clients it hits.

The agent's own summary of the gap it was sent to close: *"All approaches in the research result in
connection loss and miner reconnection when a backend fails. The research found no public documentation
of systems that migrate established TCP connections across servers without protocol-level support
(which Stratum V2 does not have)."*

That reframes the design question. Not "how do I avoid reconnects?" but **"how do I make reconnects
cheap, bounded, and non-synchronised?"** — which is a question about vardiff ramp-up cost, reconnect
storms, and whether session state can be rebuilt quickly.

## Anycast is not what it looks like

**AWS Global Accelerator** uses anycast static IPs at edge locations, but: *"Global Accelerator
terminates TCP connections from clients at AWS edge locations and, almost concurrently, establishes a
new TCP connection with your endpoints."* It is a **TCP proxy**, not transparent routing. This is the
same shape as Cloudflare's product, and it is why pools using a CDN are not exposed to raw anycast
instability — the session terminates at the edge.

Properties worth knowing:

- **Flow stickiness** on the 5-tuple hash: a flow stays pinned to its edge location and backend until
  idle timeout.
- **340 s TCP idle timeout** (30 s UDP). Fine for mining, where a share arrives every few seconds at
  typical difficulty — but note that a *high*-difficulty rental connection could plausibly idle near
  that boundary.
- **A real failure mode, stated in the docs**: *"Global Accelerator continues to direct traffic for
  established connections to an endpoint until the idle timeout is met, even if the endpoint is marked
  as unhealthy."* So a dead backend keeps receiving traffic for up to 340 s. Health checking the edge
  does not protect an established session.
- Backend selection at the edge uses location, health and weights — but weights are **overridden** when
  client-IP preservation is on, "to avoid connection collisions".
- Cost, as reported: ~$220/month plus $0.012/GB for Global Accelerator; Cloudflare Spectrum ~$200/month
  minimum. Backends must live in the vendor's network.

## L4 load balancers: consistent hashing bounds the blast radius

All three do essentially the same thing.

**HAProxy** — `balance source` with `hash-type consistent` (ketama). Consistent hashing is the point: if
one of three backends dies, only ~⅓ of clients remap rather than all of them. For Stratum the timeouts
need to be enormous:

```
defaults
    mode tcp
    timeout client 168h     # 7 days
    timeout server 168h
    timeout connect 5s
backend stratum_pool
    balance source
    hash-type consistent
    server us-west-1 10.0.1.10:3333 check
```

Also: `timeout tunnel` governs persistent bidirectional connections and defaults to
`timeout client + timeout server`; `slowstart 60000` ramps a returning server over 60 s to avoid a
thundering herd; `hard-stop-after` bounds graceful shutdown.

**Stick tables** offer affinity on application-layer data rather than source IP —
`stick-table type binary len 32 size 30k expire 30m`, with `stick on`/`stick store-response` learning in
both directions. Advantage: survives a client IP change. For Stratum you would key on something in the
handshake (the `mining.subscribe`/`mining.authorize` username), needing `expire 7d` rather than 30m, and
`tcp-request inspect-delay` to buffer the first packet. **Limitation that matters: stick tables are
per-instance.** HA requires a `peers` block (open source) or Enterprise sync — otherwise the LB is a
single point of failure.

**NGINX stream** — `hash $remote_addr consistent;` plus `max_fails=3 fail_timeout=10s`, and
`proxy_timeout` must be raised far above its default (the agent suggests 30m; for stratum with high
difficulty, higher). Simpler syntax; **no application-layer stick tables in open source** (`sticky` is
NGINX Plus).

**IPVS** — kernel-space, lowest overhead, used by kube-proxy in IPVS mode:

```
ipvsadm -A -t 203.0.113.10:3333 -s sh -p 604800   # source hash, 7-day persistence
```

Its **persistent templates** are affinity records that outlive individual connections. Two sysctls are
directly relevant: `expire_quiescent_template=1` lets sessions drain when a server's weight is set to 0
(without it, persistent connections keep reaching a downed server), and `expire_nodest_conn=1` sends RST
immediately when a destination is removed rather than silently dropping — the difference between a fast
client reconnect and a client hanging until timeout. Costs: no application-layer visibility, and HA needs
keepalived/VRRP.

## SO_REUSEPORT gives hitless LB reloads — and nothing more

During a HAProxy reload both old and new processes bind the same port with `SO_REUSEPORT`; the kernel
hashes new SYNs across both; the old process then unbinds and drains its established connections. The
`-x /var/run/haproxy.sock` option with `expose-fd listeners` instead passes the listening socket FDs
directly to the new process, giving no overlap window at all. If binding fails, SIGTTOU/SIGTTIN pause and
resume the old process so something is always listening.

**The hard limit, stated in the docs**: *"a given connection is served by a single thread"* and the kernel
**cannot migrate established connections between processes**. `SO_REUSEPORT` distributes *new* connections
only, and only across processes on one machine.

So: the LB layer can be upgraded without dropping miners. The **pool backend** cannot — unless the
application can rebuild session state elsewhere. This is exactly what ckpool's own socket handover (`-H`)
achieves for ckpool itself, and it is the only pool-side instance of the technique found in either round.

## DNS-based routing, and its two leaks

**Route 53 latency-based routing** returns the lowest-latency region's record based on *historical
aggregated* measurements from the client's **resolver**. Health checks probe at 30 s (standard) or 10 s
(fast), with a **three-consecutive-failure** default → **90 s detection**, or 30 s with fast checks.
Recommended TTL ≤ 60 s for failover. Realistic total failover: **1–5 minutes**, and longer where clients
ignore TTL.

Explicitly acknowledged limitation: *"Route 53 does not make routing decisions based on the load or
available traffic capacity of your endpoints."* DNS acts once, pre-connection; for a session that then
lasts weeks, DNS has no further visibility or control.

**EDNS Client Subnet (RFC 7871)** patches the resolver-location-vs-client-location leak by carrying a
truncated client prefix (recommended /24 IPv4, /56 IPv6) in the query, cached per-subnet with
longest-prefix match. Costs: resolver cache fragmentation (one entry per subnet, not per domain), a
cache-pollution vector, inconsistent DNSSEC handling, and the RFC's own advice that it *"SHOULD be
disabled in all default configurations"*. Not all resolvers send it.

## Ranked options for a pool

| Option | Failover time | Blast radius on backend failure | Cost / complexity |
|---|---|---|---|
| **CDN anycast + TCP proxy** (what major pools actually do) | new flows immediate; established flows up to the idle timeout even to an unhealthy backend | one edge POP's clients if the POP fails | ~$200+/mo, vendor lock-in, third party in the share path |
| **GeoDNS latency-based + long TTL** | 1–5 min (health check + TTL, worse with non-compliant resolvers) | all clients holding the failed region's IP | low; no stateful infra |
| **L4 LB with consistent hashing per region** | 10–60 s (health check + reconnect) | only the fraction hashed to the failed backend | LB needs HA pair; stick-table sync if application-layer affinity |
| **Client-side endpoint selection** | 1–30 s, client-dependent | per-client, no synchronisation | needs miner-software support, which mostly does not exist; thundering-herd risk |
| **Anycast + stateless backends** | BGP reconvergence | route flaps reset sessions | **impractical**: requires externalising per-connection difficulty/extranonce/vardiff state to Redis and a lookup on every share |

The last row deserves its dismissal recorded, because it is the option people reach for first: making
pool backends stateless would put a datastore round trip on the share-submit hot path, and it buys little,
since BGP route changes reset the TCP connection anyway.

## What the public record does not contain

The agent flagged these as genuinely absent rather than merely unfound, and they are the numbers that
would decide between the options:

1. **How often BGP reconvergence actually resets established TCP sessions.** Everyone avoids raw anycast
   for stateful TCP; nobody published the failure rate. If resets are rare, direct anycast becomes viable.
2. **Real-world TTL compliance** — what fraction of resolvers/clients honour a 60 s TTL, and the
   distribution of stale-DNS duration (p50/p95/p99). This is the difference between GeoDNS failover being
   1–2 minutes and being unreliable.
3. **Connection-draining cost at scale** — time, memory and success rate for draining 10k / 100k / 1M
   long-lived connections.
4. **Stick-table / IPVS state synchronisation** for LB high availability: configuration, replication lag,
   failure modes.
5. **Client-side selection patterns from comparable protocols** (game servers, QUIC racing) — what the
   endpoint list contains and how clients probe. Relevant because this is the only option that scales
   without pool-side state, and it is the one with no documented precedent for mining.
