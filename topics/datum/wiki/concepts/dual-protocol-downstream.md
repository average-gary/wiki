---
title: "Dual-protocol downstream — SV1 + SV2 in one binary"
category: concept
sources:
  - raw/articles/2026-06-01-dropinq4-dual-protocol-port-design.md
  - raw/articles/2026-06-01-dropinq4-failover-and-version-compat.md
  - raw/articles/2026-06-01-dropinq4-keypair-and-state-persistence.md
  - raw/articles/2026-06-01-dropinq4-miner-base-composition.md
  - raw/articles/2026-06-01-dropinq4-switch-day-runbook-and-risk-matrix.md
created: 2026-06-01
updated: 2026-06-01
tags: [dual-protocol, sv1, sv2, drop-in, miner-firmware, risk]
confidence: high
---

# Dual-protocol downstream — SV1 + SV2 in one binary

The drop-in must serve **both** SV1 and SV2 to ASICs because a literal SV2-only replacement would brick OCEAN miners running SV1-only firmware. From [[../../raw/articles/2026-06-01-dropinq4-miner-base-composition|Q4 miner base]], [[../../raw/articles/2026-06-01-dropinq4-dual-protocol-port-design|Q4 port design]], [[../../raw/articles/2026-06-01-dropinq4-failover-and-version-compat|Q4 failover]].

## OCEAN miner-base composition (low-medium confidence)

No direct OCEAN telemetry. Inferred from public signals:

- **~75-90% SV1-only** (stock Antminer firmware; LuxOS; vendor-specific).
- **~10-25% SV2-capable** (mainly BraiinsOS+ on Antminer S19/S21).
- **~0% SV2-only**.

**Strongest revealed-preference signal**: OCEAN themselves ship an SV1-only gateway and have publicly stated *"SV2 wouldn't be a viable solution in the near term"* ([[ocean-sv2-stance-and-prior-art]]). Their existing miner base is overwhelmingly SV1.

**Verdict**: SV1 support is mandatory. SV2-only would brick the fleet. The drop-in must speak both downstream.

## Recommended design — dual-port, configured statically

| Port | Default | Protocol | Status |
|---|---|---|---|
| 23334 | enabled | SV1 (preserves existing miner configs) | mandatory |
| 23335 | disabled | SV2 (operator opt-in) | additive |

Operators get binary-swap compatibility on day one (no miner config changes). SV2 enablement is one config flag (`stratum_v2.enabled = true`) and one firewall hole.

### Why not single-port sniffing?

Single-port protocol sniffing IS technically trivial:

- SV1 first byte is `{` (0x7b, JSON `mining.subscribe`).
- SV2 first frame is **64 bytes of binary ElligatorSwift random** (per `sv2-spec/04-Protocol-Security.md`).
- Probability of false-detection: ~1/256.

But: complicates debugging, log lines, and load-balancer configurations. Keep sniffing as opt-in (`stratum.protocol_sniff = true`) for operators who want a single-port deployment.

### SV1 implementation — SRI's stratum_translation crate

SRI's `stratum_translation` crate v0.3.0 (in `stratum-core/stratum-translation`) is the right SV1↔SV2 adapter. Description: *"Stratum V1 ↔ Stratum V2 translation utilities for reuse across proxies, apps, and firmware."* Coordinated with [[../../sv1-upstream-reverse-translator/_index|sv1-upstream-reverse-translator]] research; this is the same crate.

The SV1 path can either:

1. **Direct serve**: parse SV1 messages natively; build SV1 `mining.notify` from internally-constructed templates.
2. **Translate to SV2 internally**: SV1 frontend → translate to SV2 → unified pipeline → translate to SV1 outbound. Cleaner if the proxy is fundamentally SV2-shaped.

Q4 recommends **direct serve** for the drop-in to minimize complexity and stay parity-compatible with the C gateway's SV1 path.

## Per-channel isolation

Both protocols share the same upstream DATUM client. Risk: SV1 path stuck behind SV2 channel state, or vice versa. Mitigation:

- Single source-of-truth for OCEAN coinbase outputs (the V2 coinbaser blob).
- Each downstream connection (SV1 or SV2 channel) builds its own job from the shared template.
- SV2 hierarchical extranonce_prefix doesn't conflict with SV1 extranonce1 — they coexist (different connections, different extranonce regimes).

**Hazard**: coinbase output divergence between SV1 `coinb1/coinb2` and SV2 `NewExtendedMiningJob.coinbase_tx_outputs`. **Catastrophic if it diverges** — operator could pay self instead of OCEAN. Mitigation: single source-of-truth array + golden-vector tests against C gateway output.

## Risk matrix

| Risk | Likelihood | Severity | Mitigation |
|---|---|---|---|
| SV1-only operator population larger than expected | already realized | already mitigated | dual-protocol downstream |
| OCEAN DATUM Prime wire-protocol break | Med | High | mock pool + live integration tests; coordinate with OCEAN engineering |
| TIDES attribution discontinuity on switch | **eliminated** | — | TIDES keys on Bitcoin payout address (Q1+Q4); drop-in inherits same window |
| Keypair rollback statefile incompatibility | **eliminated** | — | gateway keypair is ephemeral; no on-disk state (Q1+Q4) |
| Coinbase divergence SV1↔SV2 | Low | **Catastrophic** | single source-of-truth array + golden vectors |
| Disconnect-all-on-outage cascade | Low | High | replicate C behavior for both SV1 and SV2 (SV2 needs explicit `CloseChannel` + TCP close) |
| OCEAN production version drift | Med | Med | configurable version string; literal `"v0.4.1-beta"` for v1.0; fall-back if rejected |
| Single-port sniff misclassification | Low | Med | dual-port default; sniffing opt-in only |

## Daemon supervision compatibility

Per [[drop-in-surface-inventory|surface inventory]]:

- No PID file, no systemd-notify in C gateway today.
- Foreground process; signal handlers only for SIGUSR1 (template notify) and SIGPIPE (ignored).
- `Type=simple` systemd unit. The Rust drop-in keeps this.

## Failover behavior

The C gateway disconnects all stratum clients when DATUM upstream is unreachable. README rationale: lets miners' built-in failover swap to backup endpoints rather than mining stale work.

The Rust drop-in must replicate this for **both** protocols:

- SV1: TCP close.
- SV2: explicit `CloseChannel` (per spec) + TCP close.

## See also

- [[drop-in-surface-inventory]] — broader operator-surface inventory
- [[switch-day-runbook]] — what an operator does to flip protocols on
- [[sv2-downstream-architecture]] — the SV2 server-side design (refactored for in-process drop-in)
- [[../../sv1-upstream-reverse-translator/_index|sv1-upstream-reverse-translator]] — SRI's `stratum_translation` crate context
