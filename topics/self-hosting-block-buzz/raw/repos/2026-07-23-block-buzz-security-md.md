---
title: "block/buzz — SECURITY.md (auth, key storage, audit, TLS posture)"
source: https://github.com/block/buzz/blob/main/SECURITY.md
type: repo
tags: [buzz, security, auth, nip-42, key-management, audit-log, agents]
confidence: high
ingested: 2026-07-23
summary: "The load-bearing security doc: channel membership is the ONLY access control; audit log is tamper-evident not tamper-resistant; agent keys via BUZZ_PRIVATE_KEY env var; relay does not enforce TLS."
---

# block/buzz — SECURITY.md

- **Support policy:** only `main` is supported; pre-1.0, no LTS branches. "All security fixes land on `main` first"; previous releases best-effort.
- **Authorization is deliberately minimal:** *"Channel membership is the only access control mechanism. There are no separate ACL lists or capability taxonomies."* Member ⇒ read+write; non-member ⇒ rejected even if authenticated. No RBAC, no least-privilege within a channel. (Issue #2282: capability plumbing exists but nothing consumes it — cosmetic today.)
- **Audit log is tamper-EVIDENT, not tamper-RESISTANT:** keyless SHA-256 hash chain; self-admits *"an attacker with database write access can recompute the entire chain after editing"* — yet positioned for "SOX-grade compliance and eDiscovery."
- **Key storage:** desktop uses OS keyring (Keychain/Credential Manager/Secret Service), falls back to `0o600` file on headless Linux. **`BUZZ_PRIVATE_KEY` env var always overrides both** — this is how agents/CI get identity (agent nsec lives in the process environment).
- **Relay does NOT enforce TLS** ("intentional… behind proxies") — plaintext `ws://` is possible if the operator misconfigures the proxy.
- **Auth mechanisms (sound where enabled):** NIP-42 (WebSocket) + NIP-98 (REST), both Schnorr-signed. SSRF blocklist on workflow webhooks; sandboxed/timeout-bounded `evalexpr`; `#![deny(unsafe_code)]`; `cargo audit` in CI.
- **Implication for VPN deployments:** a VPN is a network control, not an auth control. Keep NIP-42/NIP-98 on, enable closed-relay + membership enforcement, terminate TLS, treat agent keys as least-privilege secrets even inside the tunnel.
