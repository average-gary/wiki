---
title: "Iroh app token wrapper — integration with AccessLimit and auth-hook"
type: concept
created: 2026-06-01
updated: 2026-06-01
verified: 2026-06-01
volatility: hot
confidence: high
sources:
  - raw/repos/2026-06-01-iroh-pr-3157-accesslimit.md
  - raw/repos/2026-06-01-iroh-pr-4205-relay-auth-tokens.md
  - raw/repos/2026-06-01-iroh-auth-hook-example.md
  - raw/repos/2026-06-01-iroh-router-protocolhandler-docs.md
  - raw/articles/2026-06-01-iroh-docs-namespace-doctickets.md
  - raw/articles/2026-06-01-fedimint-invite-code.md
  - raw/articles/2026-06-01-tor-onion-v3-client-auth.md
tags: [iroh, accesslimit, auth-hook, router, integration, app-ticket]
---

# Iroh app token wrapper — integration

How to plug the token format and seed rotation into iroh's existing `AccessLimit<P>` + `auth-hook.rs` patterns.

## Critical correction to the prior wiki

The prior session's `iroh-tickets-and-qr-pairing` article said:

> "PR #3157 is the open work-in-progress to wrap protocols with a generic auth layer."

**Wrong.** Per [[2026-06-01-iroh-pr-3157-accesslimit]]:

- PR #3157 was **MERGED 2025-03-14**
- It introduced `AccessLimit<P>` itself — not a generic auth layer
- The closure only sees `EndpointId`, not token payloads
- Upstream considers it a minimal primitive

There is **no upstream "generic auth wrapper"**. The wrapper crate fills that gap.

A second auth surface landed 2026-05-06 in PR #4205 ([[2026-06-01-iroh-pr-4205-relay-auth-tokens]]) — but that's **relay-tier** auth (gating connections to the relay itself), not protocol-tier.

## The two integration points

| Tier | Iroh primitive | What it gates | Hook signature |
|------|----------------|---------------|----------------|
| Protocol | `AccessLimit<P>` (PR #3157) | Connections to a specific ALPN | `Fn(EndpointId) -> bool` |
| Relay   | `AccessConfig::Restricted` (PR #4205) | Connections to the relay | `Fn(EndpointId, &HeaderMap) -> bool` (or async) |

The wrapper crate plugs into both. **Same token format, two integration points.**

## Pattern A — auth-hook (recommended)

Iroh's own `iroh/examples/auth-hook.rs` shows the pattern (per [[2026-06-01-iroh-auth-hook-example]]):

```rust
// At server startup:
let server_state = Arc::new(ServerState::load());
let (auth_hook, auth_proto) = TokenAuth::incoming(server_state.clone());

let endpoint = Endpoint::builder()
    .secret_key(server_secret)
    .hooks(auth_hook)              // gate future-opened streams
    .bind()
    .await?;

let router = Router::builder(endpoint)
    .accept(TOKEN_AUTH_ALPN, auth_proto)         // dedicated auth ALPN
    .accept(b"farm-ai/transcribe/1", TranscribeHandler::new(whisper))
    .accept(b"farm-ai/detect/1", DetectHandler::new(yolo))
    .accept(b"DUMBPIPEV0", SshTunnel::new("localhost:22"))
    .spawn();
```

The `TokenAuth::incoming` function returns:

- A **hook** that `Endpoint` consults to decide which `EndpointID`s are currently allowed
- An **auth ProtocolHandler** registered at `TOKEN_AUTH_ALPN` that accepts an incoming token, validates it, and updates the hook's allow-set

```rust
// The wrapper crate API (illustrative):
pub fn incoming<S: TokenStore>(state: Arc<S>) -> (AuthHook, AuthProtocolHandler<S>) {
    let allowed: Arc<RwLock<HashSet<EndpointId>>> = Arc::new(RwLock::new(HashSet::new()));
    let hook = AuthHook { allowed: allowed.clone() };
    let proto = AuthProtocolHandler { state, allowed };
    (hook, proto)
}

impl<S: TokenStore> ProtocolHandler for AuthProtocolHandler<S> {
    async fn accept(&self, conn: Connection) -> Result<(), AcceptError> {
        let endpoint_id = conn.get_remote_endpoint_id()?;
        let (mut send, mut recv) = conn.accept_bi().await?;

        // Read the token (format-dependent)
        let mut buf = vec![0u8; 4096];
        let n = recv.read(&mut buf).await?;
        let token_bytes = &buf[..n];

        // Validate using the chosen format (PASETO/Biscuit/random+DB)
        let cap = self.state.validate(token_bytes, &endpoint_id).await?;

        // Mark consumed if single-use
        self.state.mark_consumed(token_bytes).await?;

        // Add to allowlist
        self.allowed.write().await.insert(endpoint_id);

        // Echo OK
        send.write_all(b"\x01ok").await?;
        send.finish().await?;

        Ok(())
    }
}
```

## Pattern B — file-based allowlist (for stable peers)

Per [[tor-onion-v3-client-auth]], for **persistent friend-graph allowlist**, file-based is simpler than tokens:

```rust
struct FileAllowlist {
    dir: PathBuf,  // /etc/farm-ai/allowed/
}

impl FileAllowlist {
    fn validate(&self, id: &EndpointId) -> bool {
        self.dir.join(format!("{}.auth", id.to_base32())).exists()
    }
}

let allow = FileAllowlist { dir: "/etc/farm-ai/allowed".into() };
let gated = AccessLimit::new(handler, move |id| allow.validate(&id));
```

Add a friend: `touch /etc/farm-ai/allowed/<endpoint_id>.auth`
Revoke: `rm /etc/farm-ai/allowed/<endpoint_id>.auth`

→ This is **all the auth you need** for a 5-friend homelab. Tokens come in for guest-pairing UX (single-use printed QR), not persistent allowlist.

## The dual-layer recipe

For the GTX 1060 AI server:

```rust
// Layer 1: Token-based pairing (auth-hook pattern)
let (auth_hook, auth_proto) = TokenAuth::incoming(token_store.clone());

// Layer 2: File allowlist for already-paired peers
let file_allow = FileAllowlist::new("/etc/farm-ai/allowed");

// Combined: a peer is allowed if (a) auth_hook says so OR (b) on file allowlist
let combined_allow = move |id: EndpointId| {
    auth_hook.is_allowed(&id) || file_allow.validate(&id)
};

let endpoint = Endpoint::builder()
    .hooks(auth_hook.clone())
    .bind()
    .await?;

let router = Router::builder(endpoint)
    .accept(TOKEN_AUTH_ALPN, auth_proto)
    .accept(b"farm-ai/transcribe/1",
        AccessLimit::new(TranscribeHandler::new(whisper), combined_allow.clone()))
    .accept(b"farm-ai/detect/1",
        AccessLimit::new(DetectHandler::new(yolo), combined_allow.clone()))
    .accept(b"DUMBPIPEV0",
        AccessLimit::new(SshTunnel::new(), combined_allow.clone()))
    .spawn();
```

After a successful token pairing, the auth proto **also** writes the EndpointID to the file allowlist. Then:

- New peer scans QR → token validated → added to in-memory allow-set + file allowlist
- Subsequent connections hit the file allowlist (no token presentation needed)
- Revoke via `rm /etc/farm-ai/allowed/<endpoint_id>.auth`

## The AppTicket — the QR / printed format

Mirror fedimint's InviteCode pattern (per [[fedimint-invite-code]]):

```rust
#[derive(Serialize, Deserialize, Debug)]
pub struct AppTicket {
    pub endpoint_id: EndpointId,
    pub relay_url: Option<RelayUrl>,
    pub direct_addresses: Vec<SocketAddr>,
    pub app_token: Option<Vec<u8>>,  // PASETO/Biscuit/random-opaque bytes
}

impl AppTicket {
    pub fn to_bech32(&self) -> String {
        // HRP "appti", encode self via consensus encoding, bech32m
    }
    pub fn from_bech32(s: &str) -> Result<Self> { ... }
}
```

Print the bech32 string as a QR code. Phone scans → decodes `AppTicket` → connects to `endpoint_id` via `direct_addresses` (or `relay_url` fallback) → presents `app_token` over the auth ALPN.

## Two-tier integration with PR #4205 (relay auth)

For the relay-tier as well:

```rust
// Same token format, used at relay-tier:
let server = ServerConfig::builder()
    .access_control(AccessConfig::Restricted(Box::new(
        |endpoint_id: EndpointId, headers: &HeaderMap| async move {
            let token = ClientRequest::auth_token(headers).ok_or(NoToken)?;
            let token_bytes = token.strip_prefix("Bearer ").ok_or(BadFormat)?.as_bytes();
            validate_token(token_bytes, &endpoint_id).await
        }
    )))
    .spawn().await?;
```

→ One token format, two integration points.

## See also

- [[iroh-app-token-design]] — token format choice
- [[iroh-app-token-seed-rotation]] — revocation algorithm
- [[multi-alpn-router-pattern]] — broader Router context
- [[iroh-tickets-and-qr-pairing]] — what iroh ships today
- [[iroh-application-patterns-2026-synthesis]]
