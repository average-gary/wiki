---
title: "Tor Onion v3 Client Authorization — pubkey-as-cookie pattern"
source: https://community.torproject.org/onion-services/advanced/client-auth/
type: article
tags: [tor, onion-v3, client-auth, x25519, allowlist, simple-pattern]
date: 2026-06-01
quality: 4
confidence: high
agent: applied
summary: "Token = x25519 keypair, 32 bytes each, base32-encoded. Service-side: one file per authorized client at <HiddenServiceDir>/authorized_clients/<name>.auth containing literally `descriptor:x25519:<base32-pubkey>`. Client-side: one file at <ClientOnionAuthDir>/<onion>.auth_private containing `<56-char-onion>:descriptor:x25519:<base32-privkey>` — the private key IS the bearer cookie on disk; access control is filesystem perms. Rotation: drop the file on the service side; client is locked out at next descriptor publish (~1 hr cadence)."
---

# Tor v3 client auth — minimum viable allowlist

Simplest possible "private-key-as-bearer-token" model. Worth lifting wholesale for the iroh app token wrapper.

## Server-side

One file per authorized client:

```
/var/lib/tor/myservice/authorized_clients/alice.auth
  → contents: descriptor:x25519:<base32-pubkey>
```

Tor reads the directory at startup + on reload. Restart = rescan.

## Client-side

One file per service:

```
~/.tor/onion-services-auth/abc123def456.onion.auth_private
  → contents: <56-char-onion>:descriptor:x25519:<base32-privkey>
```

**Access control is filesystem perms**: chmod 600.

## Wire flow

1. Client connects to onion service
2. Tor includes the per-service x25519 pubkey in the descriptor lookup
3. Server validates: is this pubkey in `authorized_clients/`?
4. If yes → connect; if no → reject

## Rotation = delete file

```bash
# revoke alice:
rm /var/lib/tor/myservice/authorized_clients/alice.auth
service tor reload
# Alice is locked out at next descriptor publish (~1 hour)
```

→ **No CRL, no expiry, no flags. Allowlist file is the truth.**

## Direct lift for the iroh app token

```rust
struct IrohSshAuth {
    allowed: PathBuf,  // /etc/farm-ai/allowed_endpoint_ids
}

impl IrohSshAuth {
    fn validate(&self, id: &EndpointId) -> bool {
        let path = self.allowed.join(format!("{}.auth", id.to_base32()));
        path.exists()
    }
}

// Plug into AccessLimit:
let auth = IrohSshAuth { allowed: "/etc/farm-ai/allowed".into() };
let gated = AccessLimit::new(handler, move |id| auth.validate(&id));

// Add a friend:
echo "" > /etc/farm-ai/allowed/<endpoint_id>.auth

// Revoke:
rm /etc/farm-ai/allowed/<endpoint_id>.auth
```

## Why this is the right floor for the wiki

For a homelab GTX 1060 server with 5-10 friends, this is **plausibly the entire auth layer needed**. No PASETO, no Biscuit, no token format. Just a directory of allowed pubkeys.

When you need more (single-use guest tokens, ephemeral sessions, capability scoping), **then** layer in the token format.

→ **Rule of thumb**: start with file-based allowlist; add tokens when you need a feature the allowlist can't express.

## Cadence

Tor's natural revocation cadence is ~1 hour (descriptor republish). For iroh, the cadence is **immediate** (next connection attempt re-checks the file). Better than Tor for revocation.

## See also

- [[2026-06-01-iroh-router-protocolhandler-docs]] — AccessLimit primitive
- [[2026-06-01-fly-api-tokens-survey]] — the "boring opaque tokens" argument
