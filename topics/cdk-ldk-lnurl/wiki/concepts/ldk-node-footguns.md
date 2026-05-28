---
title: "LDK Node footguns for a CDK mint operator"
type: concept
created: 2026-05-28
updated: 2026-05-28
confidence: high
tags: [ldk-node, footgun, persistence, tor, lsps2]
---

# LDK Node footguns

The cdk-ldk-node README explicitly positions LDK Node as **"Recommended for Testing"**; production guidance leans on CLN/LND. These are the concrete reasons.

## 1. Panic-on-persistence-failure (open)

Issue [#381](https://github.com/lightningdevkit/ldk-node/issues/381). A transient persistence failure (disk full, VSS network blip, KV store error) can panic the process. Many panic paths live in upstream `rust-lightning` and are blocked on full migration to `KVStore` for `ChannelMonitor` persistence — planned for v0.8.

For a Cashu mint where the LN backend's wallet IS the reserve, a panic mid-state-update could:
1. Crash the mintd process
2. Persist a `ChannelMonitor` at an inconsistent point
3. Cause a defensive force-close on recovery, destroying liquidity

See [[../../raw/articles/2026-05-28-ldk-node-issue-381-persistence-panic.md|raw issue notes]].

**Mitigation**: reliable storage (Postgres via custom DynStore, VSS with high uptime), process health monitoring + auto-restart, on-call procedure for "LDK panicked, what now?". For high-value mints, choose CLN/LND.

## 2. TorConfig HTTP bypass (open)

Issue [#834](https://github.com/lightningdevkit/ldk-node/issues/834). Even with `TorConfig` set, RGS gossip sync, pathfinding scoring, and **LNURL-auth** HTTP calls bypass the SOCKS5 proxy and go over clearnet. `bitreq` dependency lacks SOCKS5; fix is upstream-blocked.

A mint operator who thinks they're privacy-protected by Tor leaks their IP to `rapidsync.lightningdevkit.org` on every gossip cycle. The LNURL-auth piece is particularly notable: LDK's default VSS auth path is LNURL-auth, so VSS over Tor leaks too.

**Mitigation**: run inside a network namespace that forces all egress through Tor (system-level, not LDK-level). This is a deployment-platform problem, not a config flag.

## 3. LSPS2 first HTLC failure on small JIT channels (open)

Issue [#913](https://github.com/lightningdevkit/ldk-node/issues/913). LSPS2 JIT channels accepted via `TrustedChannelFeatures::ZeroConf` use the default 1000-sat reserve, which on small channels eats enough capacity to make the first HTLC fail. Symptom: 4980 sats usable for a 4950 sat HTLC fails.

A fresh CDK mint relying on LSPS2 for inbound liquidity bootstrap may silently fail on the very first deposit.

**Mitigation**: test on Mutinynet. Set `set_liquidity_source_lsps2(...)` only when the LSP supports larger initial channels. Or pre-rent inbound via LSPS1.

## 4. Admin UI has no authentication

The `cdk-ldk-node` web UI on port 8091 (default) has **no authentication**. The README mandates `127.0.0.1` binding. If misconfigured to bind to `0.0.0.0` and exposed on the public internet (or even an internal LAN with hostile devices), anyone can drain funds.

**Mitigation**: bind to `127.0.0.1`. If remote management is needed, tunnel through SSH or a separate authenticated gateway (the `cdk-mint-rpc` gRPC admin on port 8086 is a different, separately managed surface).

## 5. /tmp/ldk_node/ default storage_dir

LDK Node's `Config::default()` sets `storage_dir_path = "/tmp/ldk_node/"`. cdk-mintd's TOML requires `storage_dir_path` so this default doesn't directly leak through, but a custom embedder calling LDK Node Builder must override it. `/tmp` is wiped on reboot on most systems → forced channel close.

**Mitigation**: always set explicit storage_dir; verify in deployment tests.

## 6. No published benchmarks

LDK Node project has not published startup time, channel sync time, or payment latency benchmarks. The closest data point is the [[../../../ldk-server/raw/articles/2026-05-26-fedimint-gateway-ldk-node-case-study.md|Fedimint Gateway case study]] in the adjacent ldk-server wiki — Gateway runs LDK Node embedded for production-grade Fedimint federations and has been stable in deployment.

## 7. Hold invoices not yet supported

LDK Node v0.7 has no first-class hold-invoice API. This affects:
- LNURL-withdraw atomic settlement (mitigated by careful k1 + state machine in the bridge)
- NIP-47 `make_hold_invoice` (NWC servers using LDK Node return "not supported")
- Fedimint Gateway's gateway HTLC flow (worked around with custom-preimage spontaneous payments)

For most LNURL deployments this is fine — LNURL-pay doesn't require hold invoices. LNURL-withdraw and NWC integrations need workarounds.

## When to choose CLN or LND instead

If any of these apply, use `cdk-cln` or `cdk-lnd` instead of `cdk-ldk-node`:

- High custodial value (mint backs >0.1 BTC)
- Strict uptime SLA (>99.9%)
- Need hold invoices (LNURL-withdraw atomicity, NWC, escrow flows)
- Need autopilot / sophisticated rebalancing
- Existing CLN/LND ops practice — don't introduce a third LN implementation

The cdk-fake-wallet path is the right place to learn CDK without LN risk; LDK Node is the right next step for development and small-scale deployments; CLN/LND remain the production default.

## See also

- [[ldk-node-embedding.md|LDK Node embedding]]
- [[lnurl-cdk-design-tensions.md|Design tensions]]
- [[../topics/deployment-playbook.md|Deployment playbook]]
