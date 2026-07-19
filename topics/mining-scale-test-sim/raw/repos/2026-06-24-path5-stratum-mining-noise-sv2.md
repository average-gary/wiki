---
title: "stratum-mining/stratum :: sv2/noise-sv2 — reusable Rust SV2 Noise primitives"
type: raw-source
source_kind: repo
source_url: https://github.com/stratum-mining/stratum/tree/main/sv2/noise-sv2
fetched: 2026-06-24
path: 5
relevance: high
---

# noise-sv2 — the building block for a custom Rust SV2 load harness

The SRI (Stratum Reference Implementation) ships `noise_sv2 = 1.4.2` as a
standalone crate (Apache/MIT). It's a clean, embeddable Noise_NX (Schnorr-cert
flavored, see SV2 spec) implementation.

## Cargo.toml signature

```toml
[dependencies]
secp256k1 = { workspace = true, features = ["hashes", "alloc", "rand"] }
rand = { workspace = true, default-features = false }
aes-gcm = { workspace = true }
chacha20poly1305 = { workspace = true }

[features]
default = ["std"]
```

No tokio dep, no I/O — pure crypto state machine. That's important: it lets
you wrap any transport (tokio TcpStream, smol, mio, even sync std::net).

## API shape (from `examples/handshake.rs`)

```rust
use noise_sv2::{Initiator, Responder};

let mut initiator = Initiator::new(Some(responder_pubkey));
let first_message  = initiator.step_0()?;           // -> bytes to send
let (second_message, mut responder_state) =
    responder.step_1(first_message)?;                // responder side
let mut initiator_state = initiator.step_2(second_message)?;

initiator_state.encrypt(&mut plaintext)?;
responder_state.decrypt(&mut ciphertext)?;
```

Three-step handshake (`step_0`, `step_1`, `step_2`) per connection, then
the resulting state pair has `encrypt(&mut [u8])` / `decrypt(&mut [u8])`
in-place. Symmetric keys come from ChaCha20-Poly1305 + AES-GCM (negotiated).

## Cost model for connection ramp-up

The crate has both `[[bench]] name = "handshake"` and `[[bench]] name = "roundtrip"`
criterion benches. Each handshake involves:
- secp256k1 keygen (initiator) — `Secp256k1::new()` + `generate_keypair`
- 1 Schnorr signature verification (responder cert)
- 1 ECDH (Diffie-Hellman over secp256k1)
- AEAD setup (ChaCha20-Poly1305 or AES-GCM)

Per-handshake CPU cost is **~1-3 ms on a modern x86 core**, which is the
real bottleneck during a 100k-connection ramp-up storm. (Confirms the
`mining-scale-test-sim` wiki premise that connection-ramp-up CPU saturates
before share-validation CPU.)

## How a Rust SV2 harness uses it

```rust
// thin sketch
use noise_sv2::Initiator;
use framing_sv2::framing::Frame;
use tokio::net::TcpStream;

async fn synthetic_miner(addr: SocketAddr, pool_pubkey: SecpPubKey) -> Result<()> {
    let mut tcp = TcpStream::connect(addr).await?;
    let mut initiator = Initiator::new(Some(pool_pubkey));

    // Noise handshake (3 messages, framed)
    let msg0 = initiator.step_0()?;
    tcp.write_all(&msg0).await?;
    let mut buf = [0u8; 234];   // size from spec
    tcp.read_exact(&mut buf).await?;
    let mut state = initiator.step_2(buf)?;

    // Open standard mining channel
    let mut open = OpenStandardMiningChannel { /* ... */ }.serialize()?;
    state.encrypt(&mut open)?;
    write_framed(&mut tcp, &open).await?;

    // Submit-shares loop, vardiff-paced
    loop {
        tokio::time::sleep(share_interval).await;
        let mut share = SubmitSharesStandard { /* ... */ }.serialize()?;
        state.encrypt(&mut share)?;
        write_framed(&mut tcp, &share).await?;
    }
}

// in main:
for i in 0..100_000 {
    tokio::spawn(synthetic_miner(addr, pubkey));
    if i % 100 == 0 { tokio::time::sleep(Duration::from_millis(10)).await; }
}
```

The companion crates are equally reusable:
- `framing-sv2` — length-prefixed frame parser/serializer
- `codec-sv2` — combines framing + noise into a `StandardSv2Frame` codec
- `parsers-sv2` — typed `OpenStandardMiningChannel`, `NewMiningJob`,
  `SubmitSharesStandard`, etc. with `serde`-style serialize/deserialize.

The bench harnesses themselves (`benches/handshake.rs`, `benches/roundtrip.rs`)
are *single-machine criterion micro-benches*, not connection-scale tools.
But the crates are the right Lego pieces for one.

## Verdict

`noise-sv2` + `framing-sv2` + `codec-sv2` + `parsers-sv2` from SRI are the
**right starting point** for a custom SV2 load harness. Anything that doesn't
already speak Noise_NX has to embed these (or rewrite them — bad idea
because of the Schnorr cert validation).
