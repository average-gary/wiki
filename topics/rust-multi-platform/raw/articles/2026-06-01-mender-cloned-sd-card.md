---
title: "Mender Hub — Identity problem after cloning SD card"
source_url: https://hub.mender.io/t/identity-problem-after-cloning-sd-card/4442
type: postmortem
ingested: 2026-06-01
quality: 4
confidence: high
tags: [mender, identity-collision, cloning, contrarian, postmortem]
relevance: [single-slot-identity]
---

# Mender Identity Collision on Cloned SD Card

Cheap, citable demonstration that the failure mode is real in production fleets, not theoretical.

## What happens

Mender's identity model: "the combination of Identity attributes and public key forms an authentication set."

Clone the SD card → both devices share the keypair → server treats them as one device.

## User-observable symptom

"When I open a remote session to the first board, I am connected to the 2 boards simultaneously" — **remote-management session bleed across machines**.

## Backup/restore = same bug

Any image-level restore re-installs the original key. **Single-slot identity assumes the slot is never duplicated, which is operationally false:**
- Golden images
- Disaster recovery
- RMA / swap-out
- Storage migration

## Workaround

Manual: `dismiss` in UI + reboot. **No automatic detection of split-brain identity.**

## Implication for new designs

Identity must be sealed to something **non-cloneable**:
- TPM-backed
- Fuse-bound (per-device unique fuse-burned ID)
- First-boot derivation from per-device hardware secret (eMMC CID, SoC unique ID, etc.)

NOT: "a file in /var/lib".

## Fits with Mender's identity script

Mender's own `mender-device-identity` script (see [[2026-06-01-mender-identity-script]]) recommends MAC, CPU serial, eMMC CID — exactly the per-device hardware attributes that survive a clone. **The script is right; the failure mode comes from the keypair, not the identity attributes.**

The fix: re-key on first-boot when hardware-derived identity changes. None of the prior-art systems do this automatically.

## See also

- [[2026-06-01-mender-device-auth]]
- [[2026-06-01-balena-provisioning-flow]]
- [[2026-06-01-keycloak-statefulset-data-loss]]
