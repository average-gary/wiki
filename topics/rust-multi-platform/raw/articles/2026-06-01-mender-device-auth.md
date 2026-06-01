---
title: "Mender Device Authentication"
source_url: https://docs.mender.io/overview/device-authentication
type: docs
ingested: 2026-06-01
quality: 5
confidence: high
tags: [mender, device-authentication, identity-attributes, asymmetric-keys]
relevance: [single-slot-identity]
---

# Mender Device Authentication

Authoritative description of the (stable identity attributes + rotatable keypair) split — the cleanest formal model of single-slot identity in this dataset.

## Authentication set

`(identity attributes, public key, device tier)`

- Multiple attributes per device (MAC, user-defined UID, serial)
- **Only one auth set may be `accepted` at a time** — this is the "single slot" rule, formalized
- Asymmetric crypto: device signs auth requests with its private key, server verifies with the public key it has on file

## Modes

- **Preauthorization** — operator uploads `(identity, public key)` *before* device first contact, accept happens automatically
- **Manual** — device shows up in pending queue; operator accepts/rejects

## Tier change

Tier change (e.g., standard → micro) creates a new auth set requiring re-approval; previous set auto-deauthorized.

## Identity stability rule

Identity must be stable: gathered by `/usr/share/mender/identity/mender-device-identity` script that emits `key=value\n` pairs (mac, cpuid, etc.). Hard rule: "device identity must remain unchanged throughout the lifetime of the device."

## Production scale

- References fleets of **>100,000 devices**
- Cited adopters: Siemens, ZF
- Mender survey (Nov 2025): **84% of OEMs deploy updates ≥ quarterly**

## See also

- [[2026-06-01-mender-identity-script]]
- [[2026-06-01-mender-preauthorization]]
- [[2026-06-01-mender-cloned-sd-card]]
- [[2026-06-01-balena-supervisor-api]]
