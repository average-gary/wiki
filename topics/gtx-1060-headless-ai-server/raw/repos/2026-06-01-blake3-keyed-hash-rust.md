---
title: "blake3 crate — keyed_hash and derive_key for Wesh-style seed rotation"
source: https://docs.rs/blake3
type: repo
tags: [blake3, keyed-hash, derive-key, kdf, mac, seed-rotation]
date: 2026-06-01
publication_date: 2026
quality: 5
confidence: high
agent: technical
summary: "blake3 1.8.5. blake3::keyed_hash(key: &[u8; 32], input: &[u8]) -> Hash and Hasher::new_keyed(&[u8; 32]) — exactly 32-byte key, enforced at the type level. Hash is 32 bytes with constant-time eq; derive_key() is the third primitive (KDF flavor). Features: rayon, mmap, zeroize, serde; SIMD on NEON/WASM. Licensing: CC0-1.0 OR Apache-2.0 OR Apache-2.0 WITH LLVM-exception."
---

# blake3 crate — keyed_hash for the seed-rotation rendezvous

The keyed-MAC primitive for Wesh-style seed rotation / per-epoch token derivation.

## Three primitives

```rust
// 1. Plain hash
blake3::hash(b"input") -> Hash;

// 2. Keyed hash (MAC)
blake3::keyed_hash(&[u8; 32] /*key*/, b"input") -> Hash;

// 3. Key derivation function
blake3::derive_key("myapp 2026-Q2 epoch", &master_key) -> [u8; 32];
```

The 32-byte key is **enforced at the type level** — no key-too-short footgun.

## For the iroh app token rendezvous tag

```rust
fn rendezvous_tag(seed: &[u8; 32], endpoint_id: &EndpointId, bucket: u64) -> blake3::Hash {
    let mut hasher = blake3::Hasher::new_keyed(seed);
    hasher.update(endpoint_id.as_bytes());
    hasher.update(&bucket.to_le_bytes());
    hasher.finalize()
}
```

## For per-epoch derived keys

```rust
fn epoch_key(master: &[u8; 32], epoch: u64) -> [u8; 32] {
    let context = format!("farm-ai app-token epoch {}", epoch);
    blake3::derive_key(&context, master)
}
```

→ Each epoch gets a distinct key derived from the master. Rotating the epoch invalidates all tokens issued under the old key without rotating the master.

## Per-app subkey derivation (BIP32-like)

For multi-app scenarios:

```rust
fn app_token_key(master: &[u8; 32], app_name: &str) -> [u8; 32] {
    blake3::derive_key(
        &format!("farm-ai app-token v1 {}", app_name),
        master,
    )
}
```

Each app gets a distinct token-validation key derived from one master. Reduces blast radius if one app's key is logged.

## Constant-time equality

`blake3::Hash` implements `PartialEq` with constant-time comparison — safe to compare claimed tag against expected tag without timing-channel leak.

```rust
let claimed = parse_tag(&request)?;
let expected = rendezvous_tag(&seed, &endpoint_id, current_bucket);
if claimed == expected {  // constant-time
    // accept
}
```

## Cargo features

- `rayon` — multi-threaded hashing (overkill for 32-byte tags)
- `mmap` — memory-mapped large-file hashing (irrelevant for tokens)
- `zeroize` — secure key erasure on drop (**recommended on**)
- `serde` — serializable Hash (handy for logging)
- SIMD on NEON, WASM, x86 (auto)

## Licensing

CC0-1.0 OR Apache-2.0 OR Apache-2.0 WITH LLVM-exception. Triple license; permissive across all use cases.

## Relevance to the GTX 1060 host

i7-7700HQ has AVX2; expected single-thread BLAKE3: ~3-4 GiB/s for hashing 32-byte tags. **Tag computation is essentially free** — orders of magnitude under network latency.

## See also

- [[2026-06-01-rfc-6238-totp]] — algorithmic parallel
- [[2026-06-01-wesh-berty-rendezvous]] — the iroh-app application
- [[2026-06-01-blake3-bench-data]] — full benchmark data
