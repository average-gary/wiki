---
title: "Mender Preauthorizing Devices"
source_url: https://docs.mender.io/server-integration/preauthorizing-devices
type: docs
ingested: 2026-06-01
quality: 4
confidence: high
tags: [mender, preauthorization, factory-provisioning]
relevance: [single-slot-identity]
---

# Mender Preauthorization — Factory-Floor Recipe

Concrete factory-floor recipe for fleet-scale single-slot enrollment, with the exact API endpoint, key path, and identity-matching semantics.

## Five-step factory flow

1. Keygen on secure workstation (`keygen-client`)
2. Fetch identity (MAC, serial, etc.)
3. POST to `/api/management/v2/devauth/devices` with `(identity_data JSON, pubkey)`
4. Install private key at **`/data/mender/mender-agent.pem`** on device
5. First boot auto-accepts

## Canonical paths

- Private key: `/data/mender/mender-agent.pem` — on the persistent data partition that survives OS updates
- Default identity attribute: MAC address (`mac=02:12:61:13:6c:42`)
- Operators can swap to serial number or composite schemes

## Bulk operations

`PREFIX_KEY` env var supports bulk keygen without overwrites — designed for manufacturing-line provisioning.

## Why preauthorized devices matter

Skip the pending queue → arrive at `accepted` automatically. **This is exactly the "single-slot reserved server-side" pattern.** The slot exists in the management database before the device ever boots.

## See also

- [[2026-06-01-mender-device-auth]]
- [[2026-06-01-mender-identity-script]]
- [[2026-06-01-balena-provisioning-flow]]
