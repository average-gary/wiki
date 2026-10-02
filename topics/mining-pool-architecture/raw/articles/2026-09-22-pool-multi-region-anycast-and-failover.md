---
title: "How pools actually distribute stratum endpoints: Cloudflare anycast, and miner-side failover timers"
source: "https://solo.ckpool.org/"
related_sources:
  - "https://github.com/ckolivas/cgminer"
  - "https://github.com/ckolivas/ckpool"
  - "https://en.bitcoin.it/wiki/Stratum_mining_protocol"
  - "https://github.com/btccom/btcpool"
type: articles
ingested: 2026-09-22
tags: [multi-region, anycast, cloudflare, geodns, stratum-endpoints, failover, cgminer, pool-fallback, client-reconnect, redirector, ip-affinity, btcagent, latency-assumption]
summary: "Closes most of round 1's largest gap. Direct DNS resolution shows the dominant answer is CLOUDFLARE ANYCAST, not GeoDNS: AntPool (ss.svp.usa.antpool.com.cdn.cloudflare.net), F2Pool, ViaBTC, Foundry USA (104.18.12.119/104.18.13.119), Braiins/Slush (172.65.65.63 — same IP for both hostnames), Poolin and SpiderPool all resolve into Cloudflare ranges (172.65.x.x, 104.18.x.x, whois-confirmed). Querying stratum.braiins.com from 1.1.1.1 and 8.8.8.8 returns the SAME IP, which rules out DNS-based geo-routing and indicates BGP anycast. Luxor is the exception (35.244.212.109, Google Cloud). So most pools do not solve the stateful-TCP-routing problem themselves — they outsource it to a CDN that terminates TCP at the edge. ckpool takes the other path: five real regional hostnames (uwsolo/uesolo/eusolo/sgsolo/ausolo.ckpool.org) for manual selection, while solo.ckpool.org resolves to a SINGLE IP (15.204.102.129), so its advertised 'automatic lowest latency connection' is still unexplained. Miner-side: cgminer's failover is a priority list with asymmetric timers — opt_pool_fallback = 120 s of stability required before returning to a higher-priority pool, with the INITIAL failover trigger undocumented. And the whole justification for geographic distribution — latency to revenue — is assumed everywhere and evidenced nowhere."
credibility: medium
credibility_score: 4
credibility_rationale: "The DNS findings are direct infrastructure observation performed during research (dig from multiple resolvers plus whois), which is primary evidence. cgminer figures are read from source and docs. The negative findings (no latency→revenue data, no reconnect-compliance data) are absence-of-evidence and are marked as such."
confidence: medium
confidence_rationale: "High on the anycast finding — it is independently checkable in seconds. Medium on interpretation: whether pools use Cloudflare Spectrum specifically, and how they load-balance behind the edge, was not established."
research_round: 2
research_agent: A2
closes_gap: "Round 1 open question 1 — 'how does any pool route stateful stratum TCP across regions?' Substantially answered for the major pools (CDN anycast with edge TCP termination); still open for ckpool's own main endpoint."
extraction_note: "Subagent report. The DNS resolutions were performed by the agent on 2026-09-22 and are trivially re-checkable; re-run dig before citing a specific IP, since CDN addresses rotate."
---

# How pools actually distribute stratum endpoints

Round 1 recorded that no source explained how anyone routes a *stateful* long-lived TCP protocol across
regions, and called it the largest hole in the operational picture. Direct DNS observation mostly closes
it, and the answer is faintly anticlimactic: **the big pools don't solve it — they buy a CDN.**

## The anycast finding

DNS resolution performed 2026-09-22, with whois confirmation of the address ranges:

| Pool | Resolves to | Infrastructure |
|---|---|---|
| `stratum.antpool.com` | → `ss.svp.usa.antpool.com.cdn.cloudflare.net` → 172.65.230.171 | **Cloudflare** |
| `ss.antpool.com` | → `ap-na.apvipabc.com.cdn.cloudflare.net` → 172.65.195.40 | **Cloudflare** |
| `stratum.f2pool.com` | → `stratum.f2pool.com.cdn.cloudflare.net` → 172.65.228.175 | **Cloudflare** |
| `btc.viabtc.com` | → 172.65.233.152 | **Cloudflare** |
| `foundryusapool.com` | → 104.18.12.119, 104.18.13.119 | **Cloudflare** (dual A) |
| `spiderpool.com` | → 104.18.9.38, 104.18.8.38 | **Cloudflare** |
| `btc.ss.poolin.me` | → 172.65.221.224 | **Cloudflare** |
| `stratum.braiins.com` / `stratum.slushpool.com` | → **172.65.65.63 (same IP)** | **Cloudflare** |
| `btc.luxor.tech` | → 35.244.212.109 | Google Cloud |
| `stratum.ocean.xyz` | no A/AAAA returned | — |

**The test that distinguishes anycast from GeoDNS**: `stratum.braiins.com` queried via Cloudflare DNS
(1.1.1.1) and Google DNS (8.8.8.8) returned the **same IP**. Under DNS-based geo-routing the answers
would differ by resolver geography. Same answer everywhere plus a Cloudflare range means **one globally
announced address, with BGP deciding which edge datacenter you reach.**

### Why this resolves the stateful-TCP objection

Round 1's worry was that anycast breaks long-lived TCP when routes reconverge, and that stratum sessions
(days to weeks, carrying difficulty and extranonce state) cannot survive being re-pathed.

The architecture sidesteps it: a CDN edge **terminates** the miner's TCP connection and maintains its own
connection to the pool origin. The anycast instability applies to reaching the edge, not to the session
state, which lives at a specific datacenter once established. So:

- The pool gets geographic proximity without operating regional pool servers.
- Session state stays in one place — the origin — and the edge holds the miner socket.
- Route reconvergence can still kill an established connection, but that is a reconnect, and miners
  reconnect routinely anyway.
- **The pool has also inserted a third party into the path of every share.** That is the cost, and it sits
  oddly beside SV2's threat model: the peer-reviewed BiteCoin/StraTap attacks are about someone in the
  network path inferring hashrate and hijacking shares. Cloudflare is, by construction, in the path. SV2's
  end-to-end Noise encryption would defeat an edge-level observer — but only if the CDN is passing bytes
  rather than terminating the protocol.

*Not established*: whether these pools use Cloudflare Spectrum (its generic TCP proxy product) or
something else, and how they load-balance behind the edge. Whether any of them run true multi-region pool
clusters is unknown.

## ckpool takes the other path

solo.ckpool.org publishes **real regional hostnames** for manual selection:

| Region | Hostname |
|---|---|
| US West | `uwsolo.ckpool.org` |
| US East | `uesolo.ckpool.org` |
| Germany | `eusolo.ckpool.org` |
| Singapore | `sgsolo.ckpool.org` |
| Australia | `ausolo.ckpool.org` |

Main endpoint `stratum.ckpool.org:3333` advertises "automatic lowest latency connection" with failover.
**But `solo.ckpool.org` resolves to a single IP, 15.204.102.129** (an OVH range), not a CDN anycast
address — so the auto-selection mechanism remains unexplained. Candidates: client-side probing, a
redirect after connect (see redirector below), or upstream routing not visible in DNS.

Note also the documented trade-off: choosing a regional hostname manually **gives up the automatic
failover** of the main endpoint.

**Port map** (fuller than round 1's): 3333 SV1, **3337 SV2 job declaration**, 3336 SV2, 4334 SV1
high-difficulty rentals, 4336 SV2 rentals.

### ckpool's redirector is not latency-based

The `-R` redirector mode is "designed to be a front end to filter out users that never contribute any
shares": once an accepted share is seen, it issues a redirect to one of the configured `redirecturl`
entries (`parse_redirecturls()` populating `ckpool.redirecturl` / `ckpool.redirectport` arrays). It
**cycles through the configured URLs and tries to keep clients from the same IP going to the same pool**
— round-robin with IP affinity. Not geographic, not latency-aware.

Two things worth noting. First, redirect-after-first-share is a neat load-shedding trick: unproductive
connections never reach the real pool. Second, **IP affinity is the same mechanism the NIC-hash
hot-spotting hazard exploits** — a large farm behind one NAT address is deliberately pinned to one
backend here, which is correct for session consistency and wrong for load distribution.

## Miner-side failover

**cgminer** (the ancestor of most ASIC firmware behaviour):

- Default strategy is **`POOL_FAILOVER`** — a priority list, moving 1st → 2nd → 3rd on failure.
- **Returns to a higher-priority pool automatically**, but only after it has been stable:
  **`opt_pool_fallback = 120` seconds**, checked as
  `now.tv_sec - pool->tv_idle.tv_sec > opt_pool_fallback`.
- A source comment notes pools must be "alive for more than 5 minutes to prevent intermittently failing
  pools from being used."
- **Lag handling**: cgminer "checks for conditions where the primary pool is lagging and will pass some
  work to the backup servers under those conditions" — partial work diversion, not a full switch.
  `--failover-only` suppresses this so a merely-slow primary does not leak work.
- Other strategies: round robin, rotate (N-minute), load balance (quota), balance (diff-1 share ratio).

**The asymmetry is the design**: leaving a bad pool should be fast, returning should be slow and
hysteretic. This is the same control-theory shape as the vardiff finding — and note it has the *opposite*
defect profile: vardiff lacks a timer where it needs one, while failover has a timer specifically to
damp oscillation.

**Undocumented**: the *initial* failover trigger. No timeout value, failed-request count, missed-notify
count, or share-rejection threshold was found. An operationally critical parameter that is black-box.

## `client.reconnect`

Signature `client.reconnect("hostname", port, waittime)`; the client "should disconnect, wait *waittime*
seconds (if provided), then connect to the given host/port (which defaults to the current server)."

With an explicit escape hatch: **"for security purposes, clients may ignore such requests if the
destination is not the same or similar."** Sensible — an unauthenticated plaintext protocol that can
redirect your hashrate anywhere is a hijacking primitive, which is precisely the BiteCoin attack class.

**Round 1 carried a claim that "many newer stratum clients do not respect the reconnect field at all."
That was NOT substantiated.** No firmware teardown, field report, or operator statement was found either
way. Downgrade it to unverified: the spec permits ignoring, and nobody has measured who does.

## Farm-scale aggregation

- **BTCAgent** (btccom/btcpool, now abandoned): "a kind of stratum proxy which use customize protocol to
  communicate with the pool… very efficient and designed for huge mining farm." Docs mention a
  "100,000 miners online Benchmark", marked outdated.
- **ckpool proxy mode** (`-p`): "appears to be a local pool handling clients as separate entities while
  presenting shares as a single user to the upstream pool", and needs the upstream to also be ckpool for
  large hashrate.

**Unanswered**: what happens to a farm proxy's downstream miners when its upstream fails — does the proxy
switch upstream and hold the miner sockets, or do all miners reconnect? This is the reconnect-storm
question, still with no published answer.

## The assumption nobody has tested

**No evidence was found that geographic distribution measurably improves revenue.** The reasoning chain —
lower latency → faster block-change notification → lower stale rate → higher effective hashrate — is
universally assumed. But no pool publishes stale rate by region, and no measurement of
latency-to-revenue was accessible.

This matters because geographic distribution is expensive and it is the justification for inserting a CDN
into the share path. The direction of the effect is certain; the magnitude is unknown. It belongs in the
same category as the SV2 performance claims: structurally sound, quantitatively unestablished.

## What remains open

1. **ckpool's main-endpoint auto-selection mechanism** — single IP, so not anycast. Unknown.
2. **Cloudflare Spectrum or not**, and how pools balance behind the edge.
3. **Initial failover trigger** in cgminer and in ASIC firmware.
4. **`client.reconnect` compliance** across Bitmain / MicroBT / Canaan firmware.
5. **Farm-proxy behaviour on upstream failover** (reconnect storm).
6. **Latency → revenue magnitude.**
7. **SV2's `Reconnect` message** (spec §3.6.5 referenced; the document 404'd).
