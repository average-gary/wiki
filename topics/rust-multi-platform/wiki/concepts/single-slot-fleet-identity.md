---
title: "Single-Slot Fleet Identity Patterns"
type: concept
created: 2026-06-01
updated: 2026-06-01
verified: 2026-06-01
status: active
quality: high
volatility: medium
sources:
  - raw/articles/2026-06-01-tailscale-auth-keys.md
  - raw/articles/2026-06-01-tailscale-acl-tags.md
  - raw/articles/2026-06-01-tailscale-oauth-clients.md
  - raw/articles/2026-06-01-tailscale-changelog-2026.md
  - raw/articles/2026-06-01-k8s-statefulset.md
  - raw/articles/2026-06-01-k8s-sa-tokens-2025-2026.md
  - raw/articles/2026-06-01-balena-supervisor-api.md
  - raw/articles/2026-06-01-balena-provisioning-flow.md
  - raw/articles/2026-06-01-mender-device-auth.md
  - raw/articles/2026-06-01-mender-identity-script.md
  - raw/articles/2026-06-01-mender-preauthorization.md
  - raw/articles/2026-06-01-mender-cloned-sd-card.md
  - raw/articles/2026-06-01-specterops-tailscale-keys.md
  - raw/articles/2026-06-01-keycloak-statefulset-data-loss.md
  - raw/guides/2026-06-01-rfc-9334-rats.md
---

# Single-Slot Fleet Identity Patterns

How four mature systems implement "this device occupies exactly one identity slot in the fleet at a time" — and where each falls down.

## The four patterns

| System | Identity primitive | What's persisted on disk | Server-side state | Rotation mechanism |
|---|---|---|---|---|
| **Tailscale** | NodeKey + tag membership | NodeKey + WireGuard private key | tag → node mapping | tag re-advertise mints new NodeKey, IP preserved |
| **K8s StatefulSet** | ordinal index + headless DNS | PVC bound by ordinal | ordinal → pod scheduling | none — slot is recreated on pod replace |
| **Balena** | `BALENA_DEVICE_UUID` + `deviceApiKey` | `/mnt/boot/config.json` | UUID → device record | `/v1/regenerate-api-key` |
| **Mender** | (identity attrs, public key) auth set | `/data/mender/mender-agent.pem` | one accepted auth set per device | new auth set requires re-approval |

## Common shape: two-tier secret + reconciliation loop

All four converge on a two-tier secret pattern:

```
TIER 1 (short-lived, fleet-shared)
  ↓
[bootstrap exchange]
  ↓
TIER 2 (long-lived, per-device)
```

| System | Tier 1 | Tier 2 |
|---|---|---|
| Tailscale | `tskey-auth-...` reusable/one-off | NodeKey (180d default rotation) |
| Balena | fleet provisioning key in image | per-device API key |
| Mender | preauth pubkey upload by operator | device-side ed25519 keypair |
| Sigstore (counter-pattern) | OIDC token | ephemeral cert (10 min) |

## What "single slot" actually means

Three formalizations, in increasing rigor:

1. **Network slot** (StatefulSet): one pod per ordinal, stable DNS. Identity = position in an ordered list.
2. **Server-side reservation** (Mender preauth, Balena provisioning): one accepted auth set / device record. Identity = unique key in a server database.
3. **Verifiable directory** (KeyTrans): one current `(label, version)` pair per slot, append-only history of past versions. Identity = label; rotation = version increment.

The KeyTrans formalization (see [[../../raw/papers/2026-06-01-keytrans-protocol-draft|KeyTrans]]) is the strongest because it makes rotation history cryptographically auditable.

## Identity stability rule

Mender states it explicitly: **"device identity must remain unchanged throughout the lifetime of the device."** This implies:

- Identity attribute = hardware-derived (MAC, eMMC CID, SoC unique ID, fuse-burned serial) — survives storage replacement
- Signing key = software-stored — can rotate without changing identity

The `mender-device-identity` script formalizes this split. It's the cleanest pattern in the dataset.

## Failure modes

### 1. Cloning ([[../../raw/articles/2026-06-01-mender-cloned-sd-card|Mender cloned-SD-card]])

If identity = "file in /var/lib", any image-level clone (golden image, DR, RMA) creates split-brain identity. Server treats two devices as one.

**Fix**: derive identity from non-cloneable hardware. If hardware-derived identity changes between boots (= the SD card moved to a new device), force re-key on first boot.

### 2. Tag-scoping is union, not intersection ([[../../raw/articles/2026-06-01-specterops-tailscale-keys|SpecterOps]])

A Tailscale node tagged `prod` inherits ALL ACLs of `prod`, including subnet routes the operator didn't realize were exposed. Tag boundaries are not least-privilege.

**Fix**: minimize per-tag ACL surface; subnet routes per-tag, not per-fleet; alert on multi-auth-key API bursts.

### 3. Stable name ≠ safe handoff ([[../../raw/articles/2026-06-01-keycloak-statefulset-data-loss|Keycloak/Infinispan]])

K8s StatefulSet ordinal identity is stable, but pod termination races against application-level state handoff. Edge fleets see the same bug on power loss / watchdog reboot / forced re-enroll.

**Fix**: app-level handoff coordination; record "slot X handed off to slot Y at epoch N" in the audit log so post-crash reconciliation has truth.

### 4. Long-lived shared secrets in CI ([[../../raw/articles/2026-06-01-specterops-tailscale-keys|SpecterOps]])

OAuth `client_id+secret` composes into auth keys → leaked CI secret yields unlimited new fleet members. The "convenient" preauth-reusable default is the worst posture.

**Fix**: use [[../../raw/articles/2026-06-01-tailscale-changelog-2026|Tailscale Workload Identity Federation (Feb 2026 GA)]] — eliminates static OAuth secrets in CI. Edge fleets shipping in 2026+ should plan for WIF as the default, with auth keys retained only for offline/air-gapped scenarios.

## RATS framing for new designs ([[../../raw/guides/2026-06-01-rfc-9334-rats|RFC 9334]])

Any single-slot identity scheme makes implicit choices about:

1. **Roles** — who is the Attester, Verifier, Relying Party, Endorser? In Mender: device = Attester, server = Verifier+RP, manufacturer = Endorser (preauth uploader).
2. **Topology** — Passport (device carries attested identity to RPs) vs Background-Check (every RP fetches fresh from Verifier). Edge fleets default to **Passport** for offline tolerance.
3. **Freshness** — timestamps (need synced clock), nonces (per-request state), epoch IDs (shared beacon). Edge fleets typically need **epoch IDs** since TEE-quality clocks are rare.

## Recommendation

For a 2026+ edge fleet design:

1. **Identity attributes**: hardware-derived, immutable, stable across disk/key changes. Use the Mender `mender-device-identity` script pattern.
2. **Signing keypair**: ed25519 (RFC 8032 variant — see [[../../raw/papers/2026-06-01-ed25519-provable-security|Ed25519 provable security]]), stored in TPM/SE if available, else on encrypted persistent partition. Rotatable with append-only version history.
3. **Bootstrap**: two-tier secret (fleet provisioning key → per-device key), provisioning key deleted from disk after success.
4. **Server-side directory**: one `accepted` auth set per identity at any time (Mender pattern); past auth sets retained as version history (KeyTrans pattern).
5. **OIDC/WIF for cloud-side automation**: don't put long-lived OAuth secrets in CI. Use Tailscale WIF or k8s ServiceAccount projected tokens for the fleet-management plane.
6. **Append-only audit** of slot transitions (enrollment, rotation, deauth, RMA) — see [[append-only-audit-logs-edge-rpc|append-only audit logs]].

## See also

- [[signed-identity-envelopes]] — what gets signed by these keys
- [[append-only-audit-logs-edge-rpc]] — how slot transitions are recorded
- [[../topics/edge-fleet-operational-patterns-2026|topic synthesis]]
- [[../../raw/papers/2026-06-01-keytrans-protocol-draft|KeyTrans]] — formal model
- [[../../raw/repos/2026-06-01-uptane-standard|Uptane]] — TUF-derived role separation for OTA
