---
title: "Rust DATUM-upstream client implementation outline (2026-06-01)"
source: "synthesis from datum_protocol.[ch], dryoc API, RustCrypto, tokio, byteorder"
type: articles
tags: [datum, rust, implementation, modules, async-io, tokio, dryoc, dropin-q2]
summary: "Module breakdown and type sketch for a Rust DATUM-upstream client. Modules: frame.rs, obfuscation.rs, crypto.rs, handshake.rs, opcodes.rs, client.rs, mock_pool.rs. Tokio async I/O, dryoc for libsodium primitives, byteorder for the 32-bit packed header. Includes the share-submit ack flow under load."
confidence: high
ingested: 2026-06-01
ingested_by: dropin-q2
quality_score: 5
---

# Rust DATUM-upstream client — implementation outline

## Crate layout

```
datum-upstream/
  src/
    lib.rs                  // re-exports + Error types
    frame.rs                // 32-bit packed header, encode/decode
    obfuscation.rs          // MurmurHash3 finalizer XOR-feedback chain
    crypto.rs               // dryoc-backed primitives (trait-isolated)
    handshake.rs            // state 0 -> 3 driver
    opcodes.rs              // proto_cmd + sub-opcode enums
    messages/
      coinbaser.rs          // 0x10 / 0x11
      share.rs              // 0x27 + 0x8F
      job_validation.rs     // 0x50 + 0x10/0x11/0x12
      client_config.rs      // 0x99
      block_notify.rs       // 0xF9
    client.rs               // top-level Tokio client (connect, drive, reconnect)
    mock_pool.rs            // server-side reference impl for tests
  tests/
    handshake_loopback.rs   // client+mock_pool round-trip
    share_submit.rs
    obfuscation_vectors.rs  // byte-exact vectors vs C reference
```

## Type sketches

### frame.rs

```rust
pub struct DatumHeader {
    pub cmd_len: u32,             // 22 bits, max 4 MiB
    pub reserved: u8,             // 2 bits
    pub is_signed: bool,
    pub is_encrypted_pubkey: bool,
    pub is_encrypted_channel: bool,
    pub proto_cmd: u8,            // 5 bits, 0..32
}

impl DatumHeader {
    pub fn pack(&self) -> u32;       // little-endian wire order — verify against C source
    pub fn unpack(word: u32) -> Result<Self, FrameError>;
}
```

**Endianness check needed:** C struct uses bitfield packing; the wire byte order depends on the platform's bitfield convention. **TEST against C reference output before trusting any pack/unpack.** The C is little-endian on x86/ARM but bitfield ordering within a word is implementation-defined. Run a known-byte vector through the C code (one PING send) and match.

### obfuscation.rs

```rust
pub struct HeaderObfuscator {
    state: u32,
}

impl HeaderObfuscator {
    pub fn new(nk_seed: u32) -> Self { Self { state: nk_seed } }

    /// MurmurHash3-32 finalizer with init = 0xb10cfeed (PR #202: replaced by randombytes_buf seed)
    pub fn next(&mut self) -> u32 {
        let mut h: u32 = 0xb10cfeed;
        let mut k: u32 = self.state;
        k = k.wrapping_mul(0xcc9e2d51);
        k = k.rotate_left(15);
        k = k.wrapping_mul(0x1b873593);
        h ^= k;
        h = h.rotate_left(13);
        h = h.wrapping_mul(5).wrapping_add(0xe6546b64);
        h ^= 4;
        h ^= h >> 16; h = h.wrapping_mul(0x85ebca6b);
        h ^= h >> 13; h = h.wrapping_mul(0xc2b2ae35);
        h ^= h >> 16;
        self.state = h;
        h
    }

    pub fn xor_header(&mut self, header_word: u32) -> u32 { header_word ^ self.next() }
}
```

**Crate option:** `murmur3` (existing crate) implements the full MurmurHash3 family but the API is for hashing arbitrary input; DATUM uses just the finalizer-as-RNG pattern, not the actual hash. Easier to inline the finalizer as above. ~15 lines, byte-exact, no dependency.

### crypto.rs

Trait-isolate the libsodium surface (see Q2 crate-survey article for rationale). Default impl uses dryoc:

```rust
pub trait DatumCrypto {
    fn seal(&self, plaintext: &[u8], recipient_pk: &[u8; 32]) -> Vec<u8>;
    fn seal_open(&self, sealed: &[u8], my_kp: &X25519Keypair) -> Result<Vec<u8>>;
    fn beforenm(&self, their_pk: &[u8; 32], my_sk: &[u8; 32]) -> [u8; 32];
    fn box_easy_afternm(&self, pt: &[u8], nonce: &[u8; 24], k: &[u8; 32]) -> Vec<u8>;
    fn box_open_easy_afternm(&self, ct: &[u8], nonce: &[u8; 24], k: &[u8; 32]) -> Result<Vec<u8>>;
    fn sign_detached(&self, msg: &[u8], sk: &[u8; 64]) -> [u8; 64];
    fn sign_verify_detached(&self, sig: &[u8; 64], msg: &[u8], pk: &[u8; 32]) -> bool;
    fn random_bytes(&self, buf: &mut [u8]);
}

pub struct DryocCrypto;
impl DatumCrypto for DryocCrypto { /* dryoc::classic::* calls */ }
```

**`_easy_afternm` shim:** dryoc exposes `_detached_afternm`. Wrapper concatenates `mac (16) || ciphertext` to match libsodium's "easy" wire layout.

**Nonce increment** (verbatim port of C `datum_increment_session_nonce`):

```rust
pub fn increment_nonce_24(n: &mut [u8; 24]) {
    // 6 little-endian u32 counters with carry
    let mut carry: u32 = 1;
    for chunk in n.chunks_exact_mut(4) {
        let mut v = u32::from_le_bytes(chunk.try_into().unwrap());
        let (s, c) = v.overflowing_add(carry);
        v = s;
        carry = c as u32;
        chunk.copy_from_slice(&v.to_le_bytes());
        if carry == 0 { return; }
    }
}
```

Verify the segment width by reading the C source — Path 1 said "24-byte counter loop"; the question is segment size. Almost certainly 4-byte (u32) chunks but **confirm against C and produce a known vector**.

### handshake.rs

```rust
pub struct HandshakeDriver<C: DatumCrypto> {
    crypto: C,
    pool_pk_ed25519: [u8; 32],
    pool_pk_x25519:  [u8; 32],
    long_term_kp:    DatumKeypair,    // ephemeral per-process, regenerated each start
    session_kp:      DatumKeypair,
    state: HandshakeState,
}

pub enum HandshakeState {
    Init,
    HelloSent { nk_seed: u32 },
    SessionEstablished { precomp: [u8; 32], tx_nonce: [u8;24], rx_nonce: [u8;24] },
    Configured { client_config: ClientConfig },  // after 0x99
}
```

Driver returns `Vec<u8>` packets to send and consumes `&[u8]` packets from the wire, advancing state.

### opcodes.rs

```rust
#[repr(u8)]
pub enum ProtoCmd { Ping = 1, HandshakeResp = 2, Mining = 5, Info = 7 /* ... */ }

#[repr(u8)]
pub enum MiningSub {
    CoinbaserReq = 0x10, CoinbaserResp = 0x11,
    ShareSubmit = 0x27,
    JobValidation = 0x50,
    ShareResp = 0x8F,
    ClientConfig = 0x99,
    BlockNotify = 0xF9,
}
```

### client.rs (Tokio top level)

```rust
pub struct DatumClient {
    config: DatumConfig,
    crypto: Box<dyn DatumCrypto + Send + Sync>,
    state: Arc<Mutex<ClientState>>,
}

impl DatumClient {
    pub async fn run(&self) -> Result<()> {
        loop {
            match self.connect_and_drive().await {
                Ok(()) => break,                           // graceful shutdown
                Err(e) => {
                    tracing::warn!("disconnected: {e}");
                    self.notify_downstream_disconnect();   // kick SV2 miners
                    self.backoff().await;                  // exponential, capped at 30s
                }
            }
        }
        Ok(())
    }

    async fn connect_and_drive(&self) -> Result<()> {
        let (mut r, mut w) = TcpStream::connect((host, port)).await?.into_split();
        // 1. handshake (state 0 -> 2)
        // 2. wait for 0x99 client_config (state 2 -> 3)
        // 3. fetch coinbaser blob (0x10 -> 0x11)
        // 4. spawn share-submit task and notification handler
        // 5. select! on inbound frames + outbound queue + timeout watchdog
    }
}
```

## Share-submit ack flow under load

**Path 1 finding:** Issue #209 documents share-queue overflow + non-graceful recovery in production. The C gateway's `pow_queue` is a fixed-size mutex-guarded ring; under burst load the queue fills and shares are dropped before submit.

Rust port design:

- Use `tokio::sync::mpsc::channel(N)` with bounded capacity (mirror C's queue size — read from C source).
- **Backpressure to the SV2 side**: when DATUM is slow to ack, the SV2 downstream should not keep accepting shares unbounded. Either (a) reject shares (SV2 has `SubmitSharesError`) or (b) buffer with bounded ringbuffer that drops oldest-first.
- 30-second ack timeout is hard from the C side. Implement as a `tokio::time::timeout` per share or a watchdog over the oldest-pending-share-timestamp.
- Track pending shares by `(job_id, coinbase_id, nonce)` tuple so ack matching works even if responses arrive out of order. (DATUM appears to be in-order but don't assume.)

```rust
pub struct PendingShare {
    submitted_tsms: Instant,
    job_id: u32,
    coinbase_id: u8,
    extranonce: [u8; 12],
    nonce: u32,
    response_tx: oneshot::Sender<ShareAck>,
}

pub enum ShareAck {
    Accepted,                       // 0x50
    AcceptedTentatively,            // 0x55 — DATUM-unique
    Rejected { code: u8 },          // 0x66 with sub-code 10..30
    Timeout,                        // local 30s watchdog
}
```

The SV2 translator (sibling concern, sv2-downstream-architecture) decides how to map `AcceptedTentatively` to SV2's `SubmitSharesSuccess`. Best policy: report it as success to the miner (so stats don't stall) but keep an internal "tentative" flag for our metrics.

## mock_pool.rs

Server-side reference impl for tests. Only enough to:

- Accept the sealed hello, validate the signature.
- Send a sealed handshake response with mock session keys.
- Run beforenm / afternm.
- Ship a synthetic 0x99 client-config and a synthetic 0x11 coinbaser blob.
- Ack shares with a configurable distribution of `Accepted` / `Tentative` / `Rejected`.
- Inject faults: nonce reuse, MAC corruption, slow ack, version mismatch, queue overflow.

~600-1000 lines. Lives in the same crate (under `#[cfg(any(test, feature = "mock-pool"))]`) so we can also expose it as a CLI binary for integration tests in CI.

## Cargo.toml dependencies (shortlist)

```toml
[dependencies]
tokio = { version = "1", features = ["net", "io-util", "rt-multi-thread", "sync", "time", "macros"] }
dryoc = "0.8"
bytes = "1"
byteorder = "1"
thiserror = "1"
tracing = "0.1"

[dev-dependencies]
proptest = "1"           # nonce increment, header pack/unpack invariants
hex-literal = "0.4"      # known-byte vectors from C reference
```

No need for `serde` (binary protocol) or `bitvec` (the header bitfield is trivial enough to do with shifts and masks).

## Testing strategy

1. **Header pack/unpack vectors** — produced by running a one-shot C harness against `datum_protocol.c`. Capture 5-10 known headers and assert byte-exact match.
2. **MurmurHash3 finalizer vectors** — the `0xb10cfeed` init constant fed N=20 sequential states. Compare to C output.
3. **Nonce-increment vectors** — same. Especially the carry-across-segments case.
4. **Sealed-box round-trip** — generate a known keypair, seal a known plaintext, decrypt with libsodium FFI (libsodium-sys-stable) — assert byte-equal to dryoc output and vice versa.
5. **Full handshake** — client + mock_pool round-trip.
6. **Live smoke test** — release-gate only; connect to `datum-beta1.mine.ocean.xyz:28915` with a real Bitcoin payout address, complete handshake, fetch one coinbaser, disconnect cleanly. Skip in normal CI.

## Sources

- `datum_protocol.c` master HEAD — every primitive used
- `datum_protocol.h` master HEAD — header struct + opcodes
- dryoc 0.8 — primitive coverage
- Tokio 1.x — async I/O model
- Path 1 issue #209 finding — share queue overflow under load
