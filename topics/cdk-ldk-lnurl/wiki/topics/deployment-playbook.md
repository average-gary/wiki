---
title: "Deployment playbook: CDK + LDK Node + LNURL on one host"
type: topic
created: 2026-05-28
updated: 2026-05-28
confidence: medium
tags: [deployment, playbook, cdk-mintd, cdk-ldk-node, lnurl]
---

# Deployment playbook — CDK + LDK Node + LNURL

End-to-end recipe for a small mint that wants to expose Lightning Address as the deposit UX. Targets dev/staging on Mutinynet first; production on mainnet later.

## Architecture decision

```
[Caddy / Nginx TLS]
  ├── /v1/*                 → cdk-mintd (port 8085)
  ├── /admin/*              → cdk-ldk-node UI (port 8091, 127.0.0.1 only)
  ├── /.well-known/lnurlp/* → npubcash-server (port 8000)
  └── /.well-known/nostr.json → npubcash-server (NIP-05, optional)

[cdk-mintd]
  ├── HTTP API on :8085
  └── embedded cdk-ldk-node
      ├── LDK Node P2P on :9735
      ├── admin UI on 127.0.0.1:8091
      └── Esplora chain source / RGS gossip

[npubcash-server]
  └── LNURL bridge → calls cdk-mintd /v1/mint/quote/bolt11
```

**Single LN node** (cdk-ldk-node) — works only if the bridge accepts the description_hash workaround (option B in [[../concepts/lnurl-cdk-design-tensions.md|design tensions]]) or if a NUT extension is patched in. For strict LUD-06 compliance, run a second LN node colocated with the bridge — that's the npub.cash production pattern but adds operational complexity.

## Phase 1 — Mutinynet dev mint

**Goal**: end-to-end deposit + withdrawal on signet, no LNURL yet.

1. Build the LDK-enabled mintd: `cargo install cdk-mintd --features ldk-node` (or pull `cdk-mintd-ldk-<version>` release artifact)
2. Create `mintd-config.toml`:
   ```toml
   [info]
   url = "https://mint.signet.example.com"
   listen_host = "127.0.0.1"
   listen_port = 8085
   mnemonic = "twelve word seed for cdk-mintd token signing keyset"

   [database]
   engine = "sqlite"

   [ln]
   ln_backend = "ldknode"

   [ldk_node]
   bitcoin_network = "signet"
   chain_source_type = "esplora"
   esplora_url = "https://mutinynet.com/api"
   gossip_source_type = "rgs"
   rgs_url = "https://rgs.mutinynet.com/snapshot/0"
   storage_dir_path = "/var/lib/cdk-mintd/ldk-node"
   ldk_node_host = "0.0.0.0"
   ldk_node_port = 9735
   ldk_node_mnemonic = "twelve word seed for the LDK Node — DIFFERENT from above"
   webserver_host = "127.0.0.1"
   webserver_port = 8091
   fee_percent = 0.02
   reserve_fee_min = 4
   ```
3. First-run: cdk-mintd creates LDK Node state at `storage_dir_path`. After first run, `ldk_node_mnemonic` can be removed; the seed lives on disk.
4. Open a channel via the admin UI (Mutinynet faucet → admin UI's on-chain receive → outbound channel to a public Mutinynet routing node).
5. Test deposit: from a CDK wallet, `mint quote bolt11` → pay BOLT11 from a Mutinynet wallet → claim tokens.
6. Test withdrawal: `melt quote bolt11` against an external Mutinynet invoice → confirm preimage.

## Phase 2 — Add LNURL bridge

**Goal**: `mint+<npub>@signet.example.com` resolves and works end-to-end.

1. Deploy npubcash-server (Docker compose) pointed at the mint:
   ```yaml
   services:
     npubcash:
       image: ghcr.io/cashubtc/npubcash-server:latest
       env:
         MINT_URL: "https://mint.signet.example.com"
         DOMAIN: "signet.example.com"
         RELAY_URLS: "wss://relay.damus.io,wss://nos.lol"
         SERVER_NSEC: "<32-byte hex>"  # bridge's nostr identity for NIP-98
       ports: ["8000:8000"]
   ```
2. Configure the reverse proxy to route `/.well-known/lnurlp/*` → npubcash-server.
3. Test resolution: `curl https://signet.example.com/.well-known/lnurlp/npub1...test` → should return LUD-06 step-1 JSON.
4. Test deposit-to-address: from any LNURL-capable wallet on Mutinynet, send to `npub1test+test@signet.example.com` → confirm tokens land in the bridge's storage and can be claimed via NIP-98.

## Phase 3 — Production posture (before mainnet)

Run through this checklist before flipping to mainnet:

- [ ] **Persistence**: `storage_dir_path` is on reliable storage (not /tmp, not ephemeral container vol). Backed up off-host.
- [ ] **Entropy**: BIP-39 mnemonic stored in a secret manager (not in TOML committed to git). Rotated nowhere — LDK Node seed is permanent.
- [ ] **Admin UI**: bound to `127.0.0.1`, never `0.0.0.0`. Access via SSH tunnel only.
- [ ] **Reverse proxy**: HSTS enabled, valid TLS cert, DNSSEC on the domain.
- [ ] **CORS**: LNURL endpoints serve `Access-Control-Allow-Origin: *` (npubcash-server does by default; verify).
- [ ] **k1 atomicity** (if LNURL-withdraw): single-use enforcement tested against a replay attack in staging.
- [ ] **`verify` (LUD-21)**: bridge advertises `verify` URLs and returns preimage on settle.
- [ ] **Channel liquidity**: Pre-rented inbound (LSPS1) or LSPS2 client configured with a known-good LSP. **Test the very first deposit** because of [issue #913](https://github.com/lightningdevkit/ldk-node/issues/913).
- [ ] **Health monitoring**: process supervisor (systemd / k8s) restarts cdk-mintd on panic. Alert on restart.
- [ ] **Tor**: if Tor is required for privacy, run cdk-mintd inside a network namespace forcing all egress through Tor (don't rely on LDK's internal `TorConfig` due to [issue #834](https://github.com/lightningdevkit/ldk-node/issues/834)).
- [ ] **Reconciliation**: daily cron compares LDK Node balance to sum of outstanding ecash proofs; alert on drift.
- [ ] **On-call procedure**: documented "LDK panicked, what now?" runbook.
- [ ] **Sensitivity**: domain DNS records have monitoring/alerting on changes (DNS hijack defense).

## Phase 4 — Production options (if scale grows)

When the mint exceeds the operational risk envelope of LDK Node, options:

- **Migrate to CLN or LND backend** — `cdk-cln` / `cdk-lnd` keep the cdk-mintd process and just swap the lightning backend. The bridge layer is unchanged.
- **Move to k8s** with [[../../raw/repos/2026-05-28-asmogo-cashu-operator.md|asmogo/cashu-operator]] — sidecar pattern with separate restart cycles.
- **Add NWC** alongside LNURL for power-user UX (see [[../concepts/nwc-vs-lnurl.md|NWC vs LNURL]]).

## What this playbook does NOT cover

- Channel autopilot / sophisticated rebalancing (LDK Node doesn't have it; out of scope)
- Onchain deposits to the mint (cdk-ldk-node advertises `onchain: None`; would need `cdk-bdk` integration)
- BOLT12 offers as an alternative deposit UX (NUT-25; cdk-ldk-node supports BOLT12 amountless invoices — covered in [[../concepts/ldk-node-embedding.md|LDK Node embedding]])
- Hardware signing of LDK Node funds (LDK supports custom signers; cdk-ldk-node doesn't expose this knob — would require a custom embedder)

## See also

- [[../concepts/cdk-architecture-and-backends.md|CDK architecture]]
- [[../concepts/ldk-node-embedding.md|LDK Node embedding]]
- [[../concepts/lnurl-bridge-pattern.md|Bridge pattern]]
- [[../concepts/ldk-node-footguns.md|LDK Node footguns]]
- [[../concepts/lnurl-cdk-design-tensions.md|Design tensions]]
