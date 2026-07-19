---
title: "Collection: vnprc/coinbase-playground (CTV+CSFS coinbase payout playground)"
source: "https://github.com/vnprc/coinbase-playground"
type: repos
ingested: 2026-07-17
quality: 4
credibility: medium
confidence: high
tags: [collection, collection-manifest, git, ctv, csfs, coinbase, non-custodial-pool, payout-tree, regtest]
summary: "Manifest for a git collection ingest of vnprc/coinbase-playground @ 0ac7ed25: a devenv/Nix regtest environment for experimenting with OP_CHECKTEMPLATEVERIFY (BIP-119) + OP_CHECKSIGFROMSTACK (BIP-348) coinbase payout trees for non-custodial mining pools. 5 children (README + 4 Rust scripts). No LICENSE file (license unknown)."
collection: "coinbase-playground"
adapter: git
revision: "0ac7ed25a21806a0c9ba96fe50c34b9ce2c2cce6"
canonical_url: "https://github.com/vnprc/coinbase-playground"
license: "unknown (no LICENSE file at HEAD)"
---

# Collection: vnprc/coinbase-playground

`github.com/vnprc/coinbase-playground` @ HEAD **0ac7ed25** (cloned shallow 2026-07-17). A "CTV + CSFS Coinbase Playground" — a regtest environment for experimenting with covenant-based **coinbase payout trees** that enable **non-custodial mining pools**. Author: vnprc.

## Why this is in bitcoin-mining-payout-schemas

The repo's thesis is a payout-schema argument: **CTV coinbase transactions enable non-custodial pool payouts at scale** by committing to a large payout tree in a tiny on-chain footprint, breaking the Bitmain-firmware coinbase-size limit that (per the author) killed P2Pool. This is directly adjacent to the topic's existing coverage of OCEAN/DATUM non-custodial payouts and p2pool. Ties to the `datum` and `garrys-mod` wikis (see cross-refs).

## Environment (from README + devenv.nix)

- **Node**: [bitcoin-garrys-mod](https://github.com/average-gary/bitcoin-garrys-mod) — a Bitcoin Core fork with CTV+CSFS enabled (pulled via `builtins.getFlake "github:vnprc/bitcoin-garrys-mod"`, package `gmodBitcoind`). Has its own repo-local wiki.
- **Indexer/UI**: blockstream/electrs (`new-index`) + esplora frontend at `localhost:5000`.
- **Runner**: `devenv up --impure` (Nix); `just` recipes drive the scripts.
- Note: electrs [doesn't build on mac](https://github.com/vnprc/coinbase-playground/issues/1).

## Scope decision (repo + scripts)

This is a small code repo, not a bounded doc corpus (only `readme.md` is a real doc; the other text hits are a vendored font README and `robots.txt`). Per user direction, the substantive **code** is ingested as children despite the git-adapter default of excluding source.

**INGESTED (5 children in raw/repos/):**
1. [[2026-07-17-coinbase-playground-readme.md]] — README: the full non-custodial-pool argument + flat/layered trees + endgame
2. [[2026-07-17-coinbase-playground-mine-ctv-coinbase.md]] — flat CTV payout tree script
3. [[2026-07-17-coinbase-playground-mine-layered-ctv-coinbase.md]] — 2-level binary CTV tree script
4. [[2026-07-17-coinbase-playground-parse-witness.md]] — witness/CTV-script parser script
5. [[2026-07-17-coinbase-playground-mine-and-send.md]] — regtest bootstrap script

**EXCLUDED:** Nix/build/config (`devenv.nix`, `flake.nix`, `Cargo.*`, `electrs.toml`, `config/bitcoin.conf`, `justfile` — quoted inline where relevant), the entire `esplora-frontend/` vendored UI (images/fonts/CSS/JS), and `robots.txt`.

## Key claims (README, author = vnprc; treat as advocacy + working demo, medium credibility)

- "CTV enables noncustodial mining pools." Every pool except **OCEAN** is custodial ("trust me bro" payout model).
- **Bitmain firmware limits coinbase tx size** to stifle decentralized alternatives; contributed to **P2Pool's decline**. OCEAN works around it via hardware fingerprinting + multiple work templates + loose block validation (cites Jason Hughes talk).
- CTV commits to the whole payout structure in a small footprint → three wins: (1) break Bitmain's coinbase stranglehold, (2) non-custodial pools at any scale, (3) maximize per-block fee revenue.
- Two downsides: (1) users must get extra txs mined to claim rewards; (2) someone must make the **unroll transaction data** available.
- **Flat tree**: broadcast immediately at 1 sat/vB from the coinbase reward; **330-sat anchor** output for CPFP (crowd-fundable via `SIGHASH_ANYONECANPAY`); sits in mempool up to 100 blocks; **upper limit ~319 payout outputs** before hitting **TRUC** tx-size policy.
- **Layered tree**: 2-level binary (4 leaves), fixed 500-sat fee per tx; "strictly worse" than flat but a stepping stone.
- **Endgame**: n-of-n MuSig locking script at each tree node; leaf owners trade outputs off-chain in the 100 blocks after confirmation to collapse subtrees into fewer/larger on-chain payouts — fits the **P2Pool reboot** (cites Kulpreet/opdup blog).

## Relationship to prior snapshot

A lighter single-item metadata snapshot of this repo already exists: [[2026-05-26-vnprc-coinbase-playground-github.md]] (ingested 2026-05-26; repo stars/last-push/status, recipe overview, README citations). This collection **complements, does not replace** it — it adds the full README argument and per-script code capture pinned to commit `0ac7ed25`. Both are retained (raw sources are immutable). The prior snapshot notes a "179-byte / 319-output" claim; this collection confirms the ~319-output TRUC ceiling from the README (the 179-byte figure is not in the current README/code and is not re-verified here).

## Provenance caveat

No LICENSE file → `license: unknown`; code excerpts captured for research/documentation. README is author advocacy + a working regtest demo (screenshots, real regtest txids), not peer-reviewed — credibility **medium**; the covenant/TRUC mechanics are verifiable from the code.
