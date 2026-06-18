---
title: "EthnTuttle/kirk — trustless gaming protocol library (Cashu + Nostr, Rust)"
source: https://github.com/EthnTuttle/kirk
type: repo
tags: [nostr, cashu, gaming, protocol, library, rust, p2pk, nut-11, dleq, commit-reveal, mint-as-referee, ecash, cdk, kirk]
fetched: 2026-06-17
confidence: high
summary: |
  Kirk is the protocol/library layer of EthnTuttle's Nostr+ecash gaming trio. Defines five
  custom Nostr event kinds (9259–9263: Challenge / ChallengeAccept / Move / Final / Reward),
  uses Cashu blind-sign C values as deterministic-yet-unpredictable game-piece randomness,
  P2PK-locks reward tokens (NUT-11), and casts the Cashu mint as referee that validates the
  game-event chain and pays out winners. Rust, MIT, depends on CDK + nostr-sdk v0.35. Active.
---

# EthnTuttle/kirk

> **Repository purpose**: Rust library implementing a trustless gaming protocol that fuses
> Cashu ecash tokens (for stake, randomness, and rewards) with Nostr events (for game-state
> coordination). Kirk is the keystone of the trio — nutchain is the spec-side cousin, manastr
> is the reference game built on top.

## Repo Metadata

| Field | Value |
|---|---|
| Owner | EthnTuttle |
| Repo | kirk |
| URL | https://github.com/EthnTuttle/kirk |
| Default branch | `master` |
| Created | 2025-09-13 |
| Last commit | 2026-01-29 (`261ffa0` — "docs: remove dead links to nonexistent docs/ and examples/ directories") |
| Total commits | 23 |
| License | MIT |
| Language | Rust (100 %) |
| Stars / Forks | 0 / 0 |
| Status | Active, experimental |

## Mission / Intent

> "A trustless gaming protocol combining Cashu ecash tokens with Nostr events for
> cryptographically-secured gameplay."

Core innovation: use **C values from Cashu's blind signing** as **deterministic-yet-unpredictable
commitments**. Players hash token data before gameplay, reveal tokens during moves. The Cashu
mint validates move sequences and distributes winnings; cheaters forfeit their tokens to honest
participants.

> "Kirk eliminates the need for trusted game servers or centralized authorities — participants
> need only trust mathematics and cryptography to ensure fair play."

## Protocol surface

### Custom Nostr event kinds (9259–9263)

| Kind | Name | Role |
|---|---|---|
| 9259 | Challenge | Initiates the game; carries game-type id, commitment hashes (64-char hex), JSON game params, optional expiry, optional timeout config |
| 9260 | ChallengeAccept | Symmetric structure to Challenge; references Challenge id; responder publishes their commitment hashes |
| 9261 | Move | Action on the chain; fields: `previous_event_id`, `move_type`, `move_data` (JSON), `revealed_tokens` (optional), `deadline` (optional). Move types: `Move`, `Commit` (no tokens), `Reveal` (tokens MUST be present) |
| 9262 | Final | Concludes gameplay; both players publish; triggers final validation |
| 9263 | Reward | Distributes outcomes OR records validation failures. RewardContent: game-sequence root, winner pubkey, multiple reward tokens (must be `Reward` type), optional unlock instructions. ValidationFailureContent: ref to sequence root, reason, optional ref to failing event |

These are NOT registered as a NIP yet — custom kinds in the addressable / replaceable range
(this is in the 9000-block, distinct from nutchain's 30800-block).

### Token model

- **Game tokens** — staked at challenge time, used in moves. Their C value, once revealed, is
  the source of game-piece randomness.
- **Reward tokens** — issued by the mint to the winner, **NUT-11 P2PK-locked** to the winner's
  pubkey. Two states: `Locked` (P2PK) and `Unlocked` (freely spendable after the winner
  signs).

### C-value game pieces

The first 4 bytes of a Cashu C value seed a deterministic decoder:

- **52-card deck** → rank (2..A) + suit (♣♦♥♠)
- **Dice** → 1..6
- **Coin flip** → boolean
- Extensible via the `Game` trait

Properties: deterministic (same C → same piece), unpredictable (player doesn't know C until
mint blind-signs and the player unblinds), publicly verifiable.

### Commitment methods (multi-token groups)

- `Single` — SHA-256 of one token's JSON
- `Concatenation` — SHA-256 over sorted token hashes concatenated
- `MerkleTreeRadix4` — Merkle tree, branching factor 4, with `MERKLE_NODE:` domain prefix

### Game state machine (5 phases)

```
WaitingForAccept  →  InProgress  →  WaitingForFinal  →  Complete
                                                     ↘   Forfeited
```

`GameSequence` enforces transitions, validates the event chain, tracks players, manages
timeouts, and integrity-checks each step.

## Architecture

```
src/
├── lib.rs
├── config.rs                 # relays (Damus, nos.lol, Primal), timeouts, token ranges
├── error.rs                  # NetworkError / ValidationError / CryptoError / RateLimitError / ConfigError + ErrorContext
├── events/
│   ├── mod.rs                # EventParser, event-kind constants
│   ├── challenge.rs          # Kind 9259, 9260, TimeoutConfig
│   ├── move_event.rs         # Kind 9261 + commit-reveal logic
│   ├── final_event.rs        # Kind 9262
│   └── reward.rs             # Kind 9263 + ValidationFailureContent
├── game/
│   ├── mod.rs
│   ├── traits.rs             # Game trait (assoc types: GamePiece, GameState, MoveData) + CommitmentValidator
│   ├── validation.rs         # GameSequence (5-state machine)
│   ├── card_game.rs          # 2-player simultaneous-reveal reference game
│   ├── pieces.rs             # PlayingCard (Rank, Suit), C→card mapping
│   └── timeout_validation_tests.rs
├── client/
│   ├── mod.rs
│   ├── player.rs             # PlayerClient
│   └── validator.rs          # ValidationClient
└── cashu/
    ├── mod.rs                # GameService / ServiceContext / EventProcessor / SequenceManager / FraudDetector / RewardDistributor / TimeoutManager
    ├── tokens.rs             # GameToken wrapper + Game/Reward typing + P2PK detection
    ├── commitments.rs        # TokenCommitment + verification against C
    ├── mint.rs               # reward issuance + forfeit handling
    └── sequence_processor.rs # event-sequence validation
```

### Layered design

- **Events layer** — Nostr coordination (kinds 9259–9263, parser, validation)
- **Game layer** — trait-based extensibility (`Game`, `CommitmentValidator`); ships a
  `card_game.rs` reference (2-player, simultaneous reveal, higher rank wins, suit tiebreaker
  ♠>♥>♦>♣, grace periods 30 m / 10 m / 5 m)
- **Client layer** — split `PlayerClient` (challenge/accept/move/finalize) vs
  `ValidationClient` (sequence verify, fraud detection, reward distribution)
- **Cashu layer** — token wrappers, commitments, mint operations, sequence processor — exposes
  the high-level service facade

### Mint role

The Cashu mint is **referee**: validates the event chain, verifies that revealed tokens hash
back to the committed values, prevents double-spend, issues P2PK-locked reward tokens to the
winner, confiscates forfeited tokens from cheaters. This eliminates the need for a separate
game server.

## Cashu specifics

- **NUT-11 (P2PK)** — reward tokens locked to winner pubkey
- **DLEQ** proofs — verify token validity without revealing mint secrets
- **C-value extraction** — relies on a `kirk` feature flag in CDK to expose C from the unblind step

## Nostr integration

- All game events published as kinds 9259–9263
- Default relays: Damus, nos.lol, Primal (configurable)
- `EventParser` validates kind, deserializes content JSON, validates structure
- All game state lives in the event `content` field as JSON
- **Not yet a NIP** — custom protocol

## Dependencies

| Group | Crates |
|---|---|
| Async / runtime | `tokio` 1.0 |
| Nostr | `nostr` v0.35, `nostr-sdk` v0.35 |
| Cashu | `cdk` (with `kirk` feature for C extraction), `cashu` — both as **git submodules** |
| Crypto | `sha2` 0.10, `hex` 0.4 |
| Serialize | `serde`, `serde_json`, `toml` 0.8 |
| Util | `chrono` 0.4, `uuid` 1.0, `validator` 0.16, `regex` 1.0, `tokio-util` 0.7 |
| Test | `tokio-test`, `tempfile`, `proptest`, `cdk-sqlite` |

`Cargo.toml` v0.1.0, MIT, includes 3 example binaries (flow / flexibility / usage).

## Game model

- **Type**: turn-based, supports simultaneous decisions via `Commit → Reveal`
- **Players**: 2 (extensible via the `Game` trait)
- **Timeouts**: per-phase grace, default 5 m forfeit window
- **Anti-cheat**: late moves / invalid commitments / double-spend → forfeit tokens to honest party
- **Trait-based extensibility**: any new game implements `Game` with its own `GamePiece`,
  `GameState`, `MoveData`

## Status & quality

| Dimension | Assessment |
|---|---|
| Stage | Experimental, but **production-hardened** in places (rate limiting, structured errors with correlation IDs, ConnectionPool, IndexedSequenceStore, MemoryManager, HealthChecker, MetricsRegistry, RequestTracing) |
| Tests | Property-based tests via `proptest`, integration tests, timeout-validation tests |
| CI | Not visible in the file tree |
| Docs | README only — `docs/` and `examples/` were removed in last commit |
| Examples | 3 example binaries shipped in-tree |
| Issues / Discussions | None |

## Notable design decisions

1. **C values as randomness**. Cashu blind-sign C values are deterministic and unpredictable
   pre-reveal — perfect for game-piece RNG without an oracle.
2. **Commit-reveal**. Hash-then-reveal token pattern blocks prior knowledge of game pieces in
   simultaneous games.
3. **Mint-as-referee**. Mint validates event chains, blocks double-spend, enforces forfeit. No
   separate game server.
4. **P2PK reward locking** (NUT-11). Only the legitimate winner can spend the reward token.
5. **Trait-based extensibility**. New games slot in by implementing `Game` — protocol
   unchanged.
6. **Stateless Nostr coordination**. Relays are dumb; the event chain carries all state.

## Key quotes

> "The mint signs blinded messages without knowing their content, and the player unblinds
> locally."

> "Players commit to their tokens by publishing a hash of the token data before gameplay
> begins, then reveal the actual tokens when making moves."

> "Kirk eliminates the need for trusted game servers or centralized authorities — participants
> need only trust mathematics and cryptography to ensure fair play."

## Wiki extraction notes

- Concept articles: **kirk event kinds 9259–9263**, **C-value game-piece decoding**,
  **commit-reveal token pattern**, **mint-as-referee**, **NUT-11 P2PK reward locking**,
  **GameSequence state machine**, **commitment methods (Single/Concat/MerkleRadix4)**,
  **Game trait**.
- Reference articles: **CDK `kirk` feature**, **Cashu+Nostr dependency stack**.
- Likely topic: **kirk protocol stack** (the synthesis read).
