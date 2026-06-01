---
title: "Keycloak #44620 — StatefulSet Rapid Scale-Down Data Loss"
source_url: https://github.com/keycloak/keycloak/issues/44620
type: postmortem
ingested: 2026-06-01
quality: 4
confidence: high
tags: [kubernetes, statefulset, data-loss, contrarian, postmortem]
relevance: [single-slot-identity]
---

# Keycloak StatefulSet Rapid Scale-Down Data Loss

Canonical example that "stable identity slot" is necessary but not sufficient — handoff semantics matter and are usually wrong on first try.

## The bug

StatefulSet ordinal identity does **NOT** coordinate with application-level state-handoff. K8s "going from 5 to 1 instance in a matter of seconds" terminates pods before Infinispan rebalance completes → **data loss.**

## Network identity ≠ data ownership

The ordinal name (`pod-N.svc`) is stable but the data-segment ownership is racy.

## What doesn't help

The "graceful leave" mechanism in JGroups runs but doesn't block pod termination — **K8s shutdown hooks have no veto power over StatefulSet operations.**

## Generalizes to edge fleets

Any "stable identity per slot" model where the slot is destroyed faster than the app can hand off invariants is the same bug. Edge fleets see this on:
- Power loss
- Aggressive watchdog reboots
- Crash-on-update
- Network partition triggering forced re-enroll

## Mitigation

Requires **app-level coordination** (block in `CacheManager#stop` until rebalance done) — the platform won't help.

For edge fleets:
- Sequence handoff before identity transfer
- Use append-only audit log to record "slot X handed off to slot Y at epoch N" — survives crash
- Don't rely on graceful shutdown hooks; assume hard kill

## See also

- [[2026-06-01-k8s-statefulset]]
- [[2026-06-01-mender-cloned-sd-card]]
