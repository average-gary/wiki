---
title: "Kubernetes StatefulSet — stable identity per slot"
source_url: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/
type: docs
ingested: 2026-06-01
quality: 5
confidence: high
tags: [kubernetes, statefulset, slot-identity, prior-art]
relevance: [single-slot-identity]
---

# Kubernetes StatefulSet

The reference implementation of slot-based identity in cluster orchestration; the ordinal+headless-service+PVC triple is the architectural template to compare every edge-fleet identity pattern against.

## Identity triple

1. **Ordinal index** — exposed as label `apps.kubernetes.io/pod-index`
2. **Stable network ID** (DNS hostname)
3. **Stable storage** (PVC bound by ordinal)

## Naming

- Deterministic: `{statefulset-name}-{ordinal}` (e.g., `web-0`, `web-1`)
- v1.31+ allows custom start ordinal via `.spec.ordinals.start`

## Network identity

- Requires a **headless service** (`clusterIP: None`)
- Each pod gets `pod-N.svc.ns.svc.cluster.local` FQDN
- Survives reschedule

## Storage identity

- PVCs bound by ordinal via `volumeClaimTemplates`
- `www-web-0`, `www-web-1`...
- Rescheduled `web-0` reattaches the same PVC

## Identity preservation

Identity is preserved across pod replacement: same ordinal, same DNS, same PVC — the canonical "slot, not instance" pattern.

Contrast with Deployment (random suffix names like `web-abc123`, no DNS identity, ephemeral).

## What it does NOT solve (per contrarian-4)

Network identity (`pod-N.svc`) ≠ data ownership. The ordinal name is stable but data-segment ownership at the application layer is racy. K8s "going from 5 to 1 instance in seconds" terminates pods before app-level rebalance completes → **data loss**. Edge fleets see the same bug on power-loss or aggressive watchdog reboots.

**Stable identity slot is necessary but not sufficient — handoff semantics matter.**

## See also

- [[2026-06-01-keycloak-statefulset-data-loss]]
- [[2026-06-01-k8s-sa-tokens-2025-2026]]
- [[2026-06-01-balena-supervisor-api]]
- [[2026-06-01-mender-device-auth]]
