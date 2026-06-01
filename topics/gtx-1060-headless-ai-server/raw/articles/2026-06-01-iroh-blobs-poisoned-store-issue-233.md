---
title: "iroh-blobs #233 — fs store: 'poisoned storage should not be used' panic"
source: https://github.com/n0-computer/iroh-blobs/issues/233
type: article
tags: [iroh-blobs, bug, panic, fs-store, contrarian, partial-upload]
date: 2026-06-01
quality: 5
confidence: high
agent: 5
summary: "Production-reproducible panic in iroh-blobs v0.100.0 (and main). BaoFileStorage::take() swaps state to Poisoned unconditionally; the early-return path leaves Complete handles permanently poisoned. Separately, HashContext::load() treats any IO error as fatal poisoning. Once poisoned, the entire blob store is unusable until process restart — i.e. a partial-upload + crash scenario can brick the store. PR #214 only softens the panic symptomatically; the upstream poisoning paths remain unfixed at filing time."
---

# iroh-blobs poisoned-storage panic

Direct evidence that iroh-blobs has unresolved data-availability footguns on the exact "crash mid-transfer" scenario.

## The bug

`BaoFileStorage::take()` swaps state to `Poisoned` unconditionally before doing work. If the work has an early return path, the storage handle is left permanently poisoned.

```
state.take() -> Poisoned   ← always
work()
if early_return { return; }  ← state never restored
state.put(restored_state)    ← never reached
```

Once poisoned, the entire blob store is unusable until process restart.

## Second root cause

`HashContext::load()` treats *any* IO error (including a recoverable missing-but-rebuildable external cache file) as fatal poisoning.

## Affected versions

- v0.100.0
- main branch

## Mitigation status

- PR #214 softens the panic symptomatically (panic → error)
- Underlying poisoning paths remain unfixed at issue-filing time
- No date for the actual root-cause fix

## Implication for an Iroh AI server

A partial-upload + crash workflow (homelab box loses power mid-blob-fetch) can leave the iroh-blobs Store unusable. Mitigations the operator can apply:

1. **Run iroh-blobs in a supervised systemd unit** with restart on failure
2. **Periodic store integrity check** before declaring readiness
3. **Use `mem` store for ephemeral things** (loses data on restart but never poisons)
4. **Track this issue** for actual fix availability
5. **Wait for 1.0** before treating iroh-blobs as production-grade for write-heavy workloads

The repo README itself says "not yet production-quality" — this issue gives that warning a concrete face.

## See also

- [[2026-06-01-iroh-blobs-1-0-rc]]
- [[2026-06-01-iroh-memory-leak-issues]]
