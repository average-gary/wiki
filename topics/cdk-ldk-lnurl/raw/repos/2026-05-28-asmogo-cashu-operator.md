---
title: "asmogo/cashu-operator — Kubernetes operator for cdk-mintd"
type: repo
source: https://github.com/asmogo/cashu-operator
fetched: 2026-05-28
confidence: high
tags: [kubernetes, cdk-mintd, deployment, operator-pattern, ldk-node]
summary: CRD-driven K8s operator that deploys cdk-mintd with an LN backend (LND, CLN, LNbits, LDK Node sidecar, Spark/Breez). Storage is SQLite/redb/Postgres with S3 backup; ingress + cert-manager TLS; Prometheus PodMonitor. Explicitly excludes LNURL — that workload is left to the operator.
---

# asmogo/cashu-operator

Source: [github.com/asmogo/cashu-operator](https://github.com/asmogo/cashu-operator) · Docs: [asmogo.github.io/cashu-operator](https://asmogo.github.io/cashu-operator/)

## What it does

Reconciles a `CashuMint` Custom Resource into:

- **Deployment** running `cdk-mintd`
- **ConfigMap** with TOML config
- **Service** + **Ingress** (cert-manager TLS)
- **PVC** for storage (SQLite or redb), or auto-provisioned **Postgres**
- **CronJob** for S3-style backups
- **PodMonitor** for Prometheus

## LN backend matrix (sample manifests)

The operator ships sample manifests for every CDK-supported lightning backend:

- **LND**
- **CLN** (Core Lightning)
- **LNbits**
- **LDK Node sidecar** ← relevant here
- **Spark / Breez** (via cdk-payment-processor)
- **Stripe** processor sidecar (fiat path; non-LN)

The LDK Node case uses a **sidecar pod pattern** rather than the in-process `cdk-ldk-node` crate — this is a deployment choice for the K8s context (separate restart cycle, separate volume mount for LDK persistence).

Secrets (LDK Node mnemonic, LND macaroon, processor creds) are referenced by name from K8s Secrets, never embedded in the CR.

## What it does NOT do

**No LNURL or lightning-address resources are managed by the operator.** The operator's concern stops at the mint's NUT API + ingress. LNURL is left to a separate workload — operators choosing the "user@my-mint.com" UX must add their own `Deployment` (e.g., `npubcash-server`) and `Ingress` rule for `.well-known/lnurlp/`.

## Why ingest

Most concrete production deployment topology for cdk-mintd publicly available. Confirms two key narrative points:

1. **CDK + LDK Node is deployable in production K8s** (the operator ships an LDK sample manifest), but the recommended pattern is sidecar, not embedded.
2. **LNURL is universally treated as a separate workload** even by the most thorough K8s tooling for Cashu mints.

## Suggested adoption pattern for CDK + LDK + LNURL

Based on this operator's design:

- `Deployment`: cdk-mintd + cdk-ldk-node (or LDK sidecar)
- `Deployment`: npubcash-server (or equivalent LNURL bridge)
- `Ingress`: routes `/v1/*` to mint; `/.well-known/lnurlp/*` and `/.well-known/nostr.json` to bridge
- `Secret`: LDK mnemonic, NIP-98 server keypair
- `PVC`: shared, separate for mint state and LDK Node state
