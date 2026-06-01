---
title: "Balena Device Provisioning Flow"
source_url: https://docs.balena.io/learn/introduction/primer.md
type: docs
ingested: 2026-06-01
quality: 4
confidence: high
tags: [balena, provisioning, fleet-key, device-key, two-tier-secret]
relevance: [single-slot-identity]
---

# Balena Device Provisioning — Two-Tier Secret

Textbook pattern for "burned-in fleet key + first-boot exchange for per-device key."

## Boot flow

1. Device boots
2. Calls provisioning API with the **fleet-scoped provisioning key** embedded in the balenaOS image
3. Backend creates device entry
4. Mints a **per-device API key**
5. Provisioning key is **deleted from disk** after success

## Where identity comes from

Identity is injected at flash time, not generated at runtime: `uuid` and `deviceApiKey` are pre-embedded in `config.json` via `balena os configure` / `balena config inject`.

## On-disk paths

- `/mnt/boot/config.json` on the mounted boot partition
- The read-only `/resin-boot/config.json` is the original snapshot

## config.json fields

`uuid`, `deviceApiKey`, `deviceApiKeys`, `deviceId`, `applicationId`, `userId`, `apiEndpoint`

## Two-tier secret pattern

| Tier | Key | Lifetime | Scope |
|---|---|---|---|
| 1 | fleet provisioning key | one-shot | mints device keys |
| 2 | per-device API key | persisted, rotatable | this device only |

Direct analogue to:
- Tailscale: auth-key → NodeKey
- Mender: preauth-pubkey → device key
- Sigstore: OIDC token → Fulcio short-lived cert

## Why it matters

Documents the textbook "burned-in fleet key + first-boot exchange for per-device key" pattern with concrete on-disk paths and JSON schema.

## Failure mode (per contrarian-3)

If the boot partition is **cloned** (golden image, disaster recovery, RMA), both devices share the keypair → server treats them as one device → remote-management session bleed. Single-slot identity assumes the slot is non-cloneable. Without TPM-binding, this is operationally false.

## See also

- [[2026-06-01-balena-supervisor-api]]
- [[2026-06-01-mender-preauthorization]]
- [[2026-06-01-mender-cloned-sd-card]]
