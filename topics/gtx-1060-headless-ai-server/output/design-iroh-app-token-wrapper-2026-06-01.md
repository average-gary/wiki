---
title: "Design: Iroh app token wrapper — Tailscale flag schema + Wesh seed rotation in Rust"
type: design
generated: 2026-06-01
sources:
  - wiki/concepts/iroh-app-token-design.md
  - wiki/concepts/iroh-app-token-seed-rotation.md
  - wiki/concepts/iroh-app-token-integration.md
  - wiki/concepts/iroh-tickets-and-qr-pairing.md
  - wiki/concepts/multi-alpn-router-pattern.md
  - wiki/topics/iroh-application-patterns-2026-synthesis.md
---

# Design: Iroh app token wrapper

A small Rust crate (~500-800 LOC) that wraps iroh's `EndpointTicket` with the auth/expiry/revocation features iroh deliberately leaves out: Tailscale-style flag schema, Wesh-style seed-rotation revocation, and integration with the merged `AccessLimit<P>` + `auth-hook.rs` patterns.

## Why this exists

Per [[iroh-tickets-security-model]] and the maintainer-confirmed Discussion #3168:

> "iroh tickets don't inherently provide client authentication."
> "Once leaked, the ticket is live forever."

The iroh team's stance: tickets are addressing primitives, not credentials. **Auth is the application's job.** This design provides it.

Per the **correction** in [[iroh-app-token-integration]]: PR #3157 was merged 2025-03-14 and introduced `AccessLimit<P>` itself — it is **not** a generic auth-wrapper layer. The `Fn(EndpointId) -> bool` predicate is too narrow to validate token payloads. The wrapper bridges that gap.

The crates.io slot for `iroh-auth` / `iroh-token` / `iroh-ticket-auth` is **empty** as of 2026-06-01. Multiple ad-hoc impls exist in production iroh apps (per [[awesome-iroh]] roster) but none is a published reusable crate.

## Crate proposal

```
iroh-app-token v0.1.0
├── src/
│   ├── lib.rs          // public API
│   ├── ticket.rs       // AppTicket bech32 ticket
│   ├── token.rs        // AppToken format trait + impls
│   │   ├── opaque.rs   // random 32B + redb (default)
│   │   └── paseto.rs   // PASETO v4.local (feature `paseto`)
│   ├── flags.rs        // AuthKeyFlags (Tailscale-style)
│   ├── capability.rs   // Capability enum
│   ├── seed.rs         // SeedManager (Wesh-style rotation)
│   ├── store.rs        // TokenStore trait + redb impl
│   ├── allowlist.rs    // FileAllowlist (Tor v3-style)
│   ├── auth_hook.rs    // iroh::Endpoint hook + auth ALPN ProtocolHandler
│   └── relay.rs        // iroh-relay AccessConfig glue (feature `relay-auth`)
└── examples/
    ├── pair_qr.rs      // server: print QR with embedded ticket+token
    ├── consume_qr.rs   // client: scan QR, present token, get added to allowlist
    └── rotate_seed.rs  // ops CLI for seed rotation

[features]
default = ["fs-store", "opaque-token"]
fs-store = ["dep:redb"]
opaque-token = []
paseto = ["dep:rusty-paseto"]
biscuit = ["dep:biscuit-auth"]
relay-auth = []
```

## Public API

```rust
pub use iroh_tickets::endpoint::EndpointTicket;

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct AppTicket {
    pub endpoint: EndpointTicket,    // re-export of iroh's
    pub app_token: Option<Vec<u8>>,  // format-agnostic bag-of-bytes
}

impl AppTicket {
    pub fn to_bech32(&self) -> Result<String> { ... }
    pub fn from_bech32(s: &str) -> Result<Self> { ... }
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub enum Capability {
    DocRead { namespace_id: NamespaceId },
    DocWrite { namespace_secret: NamespaceSecret },
    Alpn { alpn: Vec<u8>, args: serde_json::Value },
    Multiple(Vec<Capability>),
}

#[derive(Serialize, Deserialize, Clone, Debug, Default)]
pub struct AuthKeyFlags {
    pub single_use: bool,
    pub reusable: bool,
    pub ephemeral: bool,
    pub pre_approved: bool,
    pub tag: Option<Role>,
}

#[derive(Serialize, Deserialize, Clone, Copy, Debug)]
pub enum Role { Read, Write, Admin }

pub trait TokenStore: Send + Sync + 'static {
    async fn validate(&self, token: &[u8], peer: &EndpointId) -> Result<TokenMeta>;
    async fn mark_consumed(&self, token: &[u8]) -> Result<()>;
    async fn issue(&self, cap: Capability, flags: AuthKeyFlags, ttl: Duration) -> Result<Vec<u8>>;
}

pub struct TokenMeta {
    pub cap: Capability,
    pub flags: AuthKeyFlags,
    pub expiry: SystemTime,
    pub jti: [u8; 16],
}

// auth-hook integration:
pub fn incoming<S: TokenStore>(store: Arc<S>) -> (AuthHook, AuthProtocolHandler<S>);
pub fn outgoing(token: Vec<u8>) -> (AuthHook, AuthClientTask);

// seed rotation:
pub struct SeedManager { /* ... */ }
impl SeedManager {
    pub fn current_seed(&self) -> Result<[u8; 32]>;
    pub fn rotate(&self) -> Result<[u8; 32]>;
    pub fn validate_with_drift(&self, peer: &EndpointId, claimed: &Hash, claimed_bucket: u64) -> Result<bool>;
}

// file allowlist:
pub struct FileAllowlist { dir: PathBuf }
impl FileAllowlist {
    pub fn validate(&self, id: &EndpointId) -> bool;
    pub fn add(&self, id: &EndpointId) -> Result<()>;
    pub fn remove(&self, id: &EndpointId) -> Result<()>;
}
```

## Server-side end-to-end recipe

```rust
use iroh::{Endpoint, protocol::{Router, AccessLimit}};
use iroh_app_token::{TokenStore, OpaqueTokenStore, FileAllowlist, AuthKeyFlags, Capability, Role};

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // 1. Identity
    let secret = load_or_create_secret("/etc/farm-ai/iroh-secret")?;

    // 2. Token store (default: opaque + redb)
    let token_store = Arc::new(OpaqueTokenStore::open("/var/lib/farm-ai/tokens.redb")?);

    // 3. File-based allowlist for paired peers
    let file_allow = FileAllowlist::new("/etc/farm-ai/allowed");

    // 4. Auth handshake protocol
    let (auth_hook, auth_proto) = iroh_app_token::incoming(token_store.clone());

    // 5. Endpoint
    let endpoint = Endpoint::builder()
        .secret_key(secret)
        .alpns(vec![
            iroh_app_token::AUTH_ALPN.to_vec(),
            b"farm-ai/transcribe/1".to_vec(),
            b"farm-ai/detect/1".to_vec(),
            b"DUMBPIPEV0".to_vec(),
        ])
        .hooks(auth_hook.clone())
        .bind()
        .await?;

    println!("Endpoint: {}", endpoint.endpoint_id());

    // 6. Combined allowlist: auth_hook OR file allowlist
    let combined = move |id: EndpointId| {
        auth_hook.is_allowed(&id) || file_allow.validate(&id)
    };

    // 7. Router with per-ALPN handlers + AccessLimit
    let router = Router::builder(endpoint)
        .accept(iroh_app_token::AUTH_ALPN, auth_proto)
        .accept(b"farm-ai/transcribe/1",
            AccessLimit::new(TranscribeHandler::new(whisper.clone()), combined.clone()))
        .accept(b"farm-ai/detect/1",
            AccessLimit::new(DetectHandler::new(yolo.clone()), combined.clone()))
        .accept(b"DUMBPIPEV0",
            AccessLimit::new(SshTunnel::new("localhost:22"), combined.clone()))
        .spawn();

    // 8. Issue a single-use guest token (out-of-band: print as QR)
    let guest_token = token_store.issue(
        Capability::Alpn { alpn: b"farm-ai/transcribe/1".to_vec(), args: json!({}) },
        AuthKeyFlags { single_use: true, tag: Some(Role::Read), ..Default::default() },
        Duration::from_secs(24 * 3600),
    ).await?;
    let ticket = AppTicket {
        endpoint: endpoint.endpoint_addr_ticket().await?,
        app_token: Some(guest_token),
    };
    println!("Guest QR: {}", ticket.to_bech32()?);

    tokio::signal::ctrl_c().await?;
    router.shutdown().await;
    Ok(())
}
```

## Client-side (phone / friend laptop)

```rust
use iroh_app_token::AppTicket;

// 1. User scans QR; QR text is the bech32 ticket
let ticket = AppTicket::from_bech32(scanned_text)?;

// 2. Build Endpoint
let (auth_hook, auth_task) = iroh_app_token::outgoing(
    ticket.app_token.ok_or("no token in ticket")?
);

let endpoint = Endpoint::builder()
    .alpns(vec![iroh_app_token::AUTH_ALPN.to_vec(), b"farm-ai/transcribe/1".to_vec()])
    .hooks(auth_hook)
    .bind()
    .await?;

// 3. Connect to server's auth ALPN; auth_task runs the token presentation
let auth_conn = endpoint.connect(&ticket.endpoint, iroh_app_token::AUTH_ALPN).await?;
auth_task.run(auth_conn).await?;

// 4. Now connect to the actual protected protocol
let conn = endpoint.connect(&ticket.endpoint, b"farm-ai/transcribe/1").await?;
let (mut send, mut recv) = conn.open_bi().await?;
send.write_all(audio_bytes).await?;
send.finish().await?;
let mut transcript = String::new();
recv.read_to_string(&mut transcript).await?;
println!("{}", transcript);
```

## Seed rotation operational schedule

```bash
# Crontab: rotate weekly Sunday 03:00
0 3 * * 0 farm-ai admin rotate-seed --reason "scheduled weekly"

# Manual: rotate immediately on suspected leak
farm-ai admin rotate-seed --reason "shared QR on slack accidentally"
```

`rotate-seed` saves the current seed as `previous` and generates a new `current`. Tokens issued under `previous` continue working for 1 bucket (1 week) — grace window for in-flight pairings.

## Design choices and rationales

### Why default to opaque+redb (not PASETO/Biscuit)

Per [[fly-api-tokens-survey]] (tptacek): "boring, trustworthy random tokens" are underrated. Most homelab servers don't face database scaling problems that justify cryptographic complexity. **Random 32 bytes + redb lookup is the simplest correct implementation.**

### Why PASETO v4 as the upgrade path (not JWT)

Per [[paragon-jwt-bad-standard]] / [[rfc-8725-jwt-bcp]]: JWT's algorithm agility is the footgun, not a feature. PASETO v4 fixes this by version-locking the cipher suite. Footer carries the seed-rotation epoch; implicit assertion binds the token to the iroh NodeID without transmitting it.

### Why Biscuit only for offline attenuation

Per [[fly-api-tokens-survey]]: Biscuit's Datalog policy embedding is overkill for small servers. Reach for it only when friends-attenuating-tokens-before-sharing-with-family is a real workflow.

### Why BLAKE3 keyed_hash for seed rotation

Per [[blake3-keyed-hash-rust]]: 32-byte key enforced at the type level (no key-too-short footgun); fast on i7-7700HQ AVX2 (~3-4 GiB/s single-thread); type-level constant-time hash equality. Direct algorithmic parallel to RFC 6238 TOTP construction.

### Why week-sized buckets for rotation

Per [[wesh-berty-rendezvous]] + [[rfc-6238-totp]]: bucket size trades off rotation latency vs replay window. Week-sized is coarse enough that clock-skew tolerance is irrelevant (no need for ±1 step) and slow enough that paired devices don't churn. Drop to day or hour for paranoid setups.

### Why short TTL + reissue, no revocation list

Per [[langley-no-revcheck]]: revocation checking soft-fails by definition; any attacker who can MITM can also block the revocation oracle. **Short TTL + cheap reissue beats revocation lists every time.** Industry has converged on this (Let's Encrypt 90d, ACME, OAuth refresh rotation, Signal Sealed Sender). The iroh app token follows the same pattern.

### Why three layers of defense

1. **EndpointID file allowlist** (per [[tor-onion-v3-client-auth]]) — gates connections at all
2. **Consumed-set in redb** — gates single-use tokens
3. **Seed rotation** (per [[wesh-berty-rendezvous]]) — invalidates outstanding QRs

Each addresses a different revocation case:
- Friend goes rogue → remove from file allowlist
- Single-use QR was double-spent → consumed-set rejects
- QR shared accidentally on Slack → rotate seed

## What's NOT in this crate

- **JWT support** — never. Per [[howmanydays-jwt-alg-none]], alg=none recurs in production code in 2026.
- **CRL / OCSP / Bitstring Status List** — explicitly skipped per [[w3c-bitstring-status-list]] / [[langley-no-revcheck]] reasoning.
- **Distributed consumed-set / CRDT** — single-server only. For multi-server, use PASETO v4.public (Ed25519) + a shared revocation seed.
- **Selective Disclosure (SD-JWT)** — wrong tool; tokens have no rich claim set to hide.

## Crate matrix as of 2026-06-01

| Dependency | Version | Use |
|------------|---------|-----|
| `iroh`         | 1.0.0-rc.1 | Required (Endpoint, Router, AccessLimit, hooks) |
| `iroh-tickets` | 1.0.0-rc.1 | Required (EndpointTicket re-export) |
| `redb`         | 4.1+       | Default token store + consumed-set |
| `blake3`       | 1.8+       | keyed_hash for seed rotation |
| `bech32`       | 0.11+      | AppTicket Display/FromStr |
| `serde` / `bincode` | latest | Token meta serialization |
| `rand`         | 0.9+       | Random opaque tokens, jti, seed |
| `rusty-paseto` | 0.10       | Optional `paseto` feature |
| `biscuit-auth` | 6.0+       | Optional `biscuit` feature |

## Test plan

1. Round-trip AppTicket bech32 encode/decode
2. Issue → validate → consume cycle (single-use)
3. Reusable token: validate twice, second succeeds
4. Expired token: validate after TTL → rejected
5. Wrong NodeID (PASETO implicit assertion): validate fails
6. Seed rotation: validate token issued under previous seed → succeeds within grace window, fails after
7. File allowlist: add/remove file → validate respects state
8. Auth hook: client presents valid token → endpoint becomes "allowed"; protected ALPN connection succeeds
9. AccessLimit + combined predicate: peer in file_allow but not auth_hook → still allowed
10. Stale-bucket detection: `bucket=t-3` triggers seed rotation

## Open questions

1. Should the wrapper crate expose iroh-docs `NamespaceSecret` as a Capability, or keep that as an app-side concern?
2. Does the bech32 HRP need to be coordinated with iroh upstream (avoid collision with `nodea` prefix)?
3. Should the auth ALPN string be stable (`/iroh-app-token/0`) vs configurable per-deployment?
4. For multi-server federations, should the seed be rotated per-server or shared via a CRDT?

## See also

- [[iroh-app-token-design]]
- [[iroh-app-token-seed-rotation]]
- [[iroh-app-token-integration]]
- [[iroh-tickets-and-qr-pairing]]
- [[iroh-application-patterns-2026-synthesis]]
