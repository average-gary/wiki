---
title: "Mender Client — Identity Script"
source_url: https://docs.mender.io/client-installation/identity
type: docs
ingested: 2026-06-01
quality: 4
confidence: high
tags: [mender, identity-script, immutable-attributes]
relevance: [single-slot-identity]
---

# Mender Identity Script

Defines the identity-attribute contract and where it lives on disk.

## Mechanism

- Path: `/usr/share/mender/identity/mender-device-identity`
- Client execs and parses stdout
- Output format: `key=value\n`
- No literal newlines (must URL-encode)
- Duplicate keys collapse into a list

## Recommended attributes

- NIC MACs
- CPU/device serial
- eMMC CID
- Model number

All chosen because they are **immutable for device lifetime**.

## The contract

"Device identity must remain unchanged throughout the lifetime of the device" — Mender's equivalent of a StatefulSet ordinal.

## Decoupling

Decouples *what the device is* (identity script output, hardware-derived) from *how it proves it* (private key on `/data` partition, rotatable). This is the cleanest separation in the prior-art dataset.

## See also

- [[2026-06-01-mender-device-auth]]
- [[2026-06-01-mender-preauthorization]]
