---
title: "Balena Supervisor API — Device Identity"
source_url: https://docs.balena.io/reference/supervisor/supervisor-api/
type: docs
ingested: 2026-06-01
quality: 4
confidence: high
tags: [balena, device-uuid, supervisor, target-state, prior-art]
relevance: [single-slot-identity]
---

# Balena Supervisor API & Device Identity

Managed-device-platform model: immutable UUID slot + rotatable per-device API keys + target-state reconciliation loop.

## Identity primitive

- `BALENA_DEVICE_UUID` — immutable for container lifetime
- `BALENA_SUPERVISOR_API_KEY` — rotatable

## Target state model

- Per-device JSON returned from balenaCloud
- Fields: `local.name`, `local.config` (HOST_CONFIG_*, SUPERVISOR_*), `local.apps` (services/volumes/networks)
- Supervisor reconciles device state to it

## Server vs device

- **Server-side**: device names, tags, target-state authoritative in balenaCloud API; device polls
- **Device-side**: supervisor persists local target state across restarts; `/v1/regenerate-api-key` rotates the API key (containers restart on next update cycle to pick up new env var)

## Remote control

`POST /supervisor/<url>` with a `uuid` parameter routes commands by UUID through the cloud proxy.

## Production scale (per Data agent)

- Standard production plans cap at **100-110 devices**
- Largest reference deployment: **200,000 LoRaWAN devices in 1 year** (balenaCloud)

## See also

- [[2026-06-01-balena-provisioning-flow]]
- [[2026-06-01-mender-device-auth]]
- [[2026-06-01-k8s-statefulset]]
