# Wiki Articles Index

Last updated: 2026-07-16

## Categories

- [Concepts](concepts/_index.md) — 7 articles
- [Topics](topics/_index.md) — 1 article
- [References](references/_index.md) — 1 article
- [Theses](theses/_index.md) — 0 articles

## Article map

```
                    MuSig2 Interactive Signing Ceremonies  (topic / umbrella)
                                     │
   ┌───────────────┬────────────────┼─────────────────┬──────────────────┐
   │               │                │                 │                  │
 MuSig2         Nonce Commit/   Session Framing    Dropout, Abort     MuSig2 vs
 Protocol       Reveal Rounds   and State          & Robustness       FROST/ROAST
   │               │                │                 │
   │          (why 2 rounds,   (PSBT / LN-TLV /   (non-robust,
   │           not 3)           LND session_id)    fresh-nonce retry)
   │                                │
 Nonce-Reuse ◄── Deterministic vs   └── Interactive Tx Wire Protocol
 Catastrophe     Random Nonces          (Lightning framing exemplar)

 Reference: Implementations & Specs (BIP-327/373, RFC 9591, libsecp256k1, LND)
```

## Recent Changes

- 2026-07-16: Founding compile — 9 articles from 15 sources (7 concepts, 1 topic, 1 reference).
