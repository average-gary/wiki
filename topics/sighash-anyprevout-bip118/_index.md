---
title: SIGHASH_ANYPREVOUT (BIP-118) — Wiki
type: wiki-root
created: 2026-07-16
updated: 2026-07-16
scope: hub-topic
summary: "SIGHASH_ANYPREVOUT / SIGHASH_ANYPREVOUTANYSCRIPT (BIP-118, aka APO/APOAS) — a proposed Taproot sighash flag that lets a signature not commit to the input being spent (the prevout). Status (draft, unactivated), semantics vs BIP-341, the Eltoo/LN-Symmetry motivation, and its effect on presigning transactions that must commit to an as-yet-unmined coinbase outpoint (mining-payout / share-accounting relevance)."
---

# SIGHASH_ANYPREVOUT (BIP-118) — Wiki

Topic wiki for **BIP-118: SIGHASH_ANYPREVOUT for Taproot Scripts** — the proposed
signature-hash flags `SIGHASH_ANYPREVOUT` (APO) and `SIGHASH_ANYPREVOUTANYSCRIPT`
(APOAS). These flags let a Taproot-script signature *omit the previous output
(prevout) from the message it commits to*, so a pre-signed transaction can be
rebound to a different outpoint after signing.

The driving framing for this wiki: **presigning transactions that must commit to
an as-yet-unmined coinbase outpoint.** A coinbase transaction's txid is not known
until the block is mined, so any transaction spending it cannot normally be
signed in advance. APO/APOAS is the covenant-adjacent primitive most often
proposed to break that dependency, and the question of whether it (or an
alternative) actually solves the mining-payout / share-accounting presigning
problem is the anchor question here.

## Layout

- `wiki/concepts/` — atomic concept articles (sighash semantics, key variants, txid malleability)
- `wiki/topics/` — synthesizing topic articles (status, motivation, coinbase-presigning analysis)
- `wiki/references/` — pointers to the BIP, implementations, related proposals
- `wiki/theses/` — testable claims
- `raw/` — ingested source material with provenance
- `output/` — generated artifacts

## Quick Navigation

- [All Sources](raw/_index.md)
- [Concepts](wiki/concepts/_index.md)
- [Topics](wiki/topics/_index.md)
- [References](wiki/references/_index.md)
- [Theses](wiki/theses/_index.md)
- [Outputs](output/_index.md)

## Start here

**Read first (the anchor question):**
- [[wiki/topics/coinbase-outpoint-presigning|Presigning a spend of an as-yet-unmined coinbase outpoint]] — the synthesis answer

**Semantics & concepts:**
- [[wiki/concepts/anyprevout-sighash-semantics|ANYPREVOUT sighash semantics (APO vs APOAS)]] — exact omissions, flag bytes, 0x01 prefix
- [[wiki/concepts/rebindable-signatures|Rebindable (floating) signatures]] — the core capability
- [[wiki/concepts/coinbase-maturity-and-unknown-txid|Coinbase outpoint: unknown txid & maturity]] — why the problem exists
- [[wiki/concepts/eltoo-ln-symmetry|eltoo / LN-Symmetry]] — APO's flagship motivation
- [[wiki/concepts/signature-replay-and-chaperone-signatures|Signature replay & chaperone signatures]] — the central risk

**Status & comparison:**
- [[wiki/topics/anyprevout-status-and-activation|BIP-118 status & activation]] — Draft, signet-only, CTV+CSFS competition
- [[wiki/references/covenant-primitives-comparison|Covenant primitives comparison]] — APO vs CTV vs ANYONECANPAY vs CSFS

## TL;DR

- **Status**: BIP-118 (Decker, A. Towns) is a **Draft** consensus soft fork — **not on
  mainnet**, no standalone activation attempt; live only on the **Bitcoin Inquisition
  signet** (since 2022-09-06). Momentum has shifted to **CTV+CSFS (LNHANCE)**, argued to
  emulate APO — an equivalence APO's co-author disputes.
- **Semantics**: **APO (0x40)** omits *only* the `outpoint`; it still commits to the
  input's amount + scriptPubKey. **APOAS (0xc0)** also omits amount, scriptPubKey, and
  tapleaf. Tapscript-only, opt-in via a `0x01` pubkey prefix.
- **Coinbase presigning**: **Yes**, APO lets you presign a spend of an unmined coinbase
  outpoint (prevout omission), demonstrated on-chain. **But** plain APO's amount
  commitment collides with the coinbase's variable value → you need **APOAS** or must fix
  the value structurally. **CTV** (output-side commitment) is the cleaner alternative for
  a pure payout fanout. The **100-block maturity** rule is a separate inclusion
  constraint.

## Statistics

- Sources: 19 raw documents (1 paper, 18 articles)
- Articles: 8 compiled wiki articles (2 topics, 5 concepts, 1 reference)
- Last compiled: 2026-07-16
- Last lint: —

## Recent Changes

- 2026-07-16: research + compile — 19 sources ingested via a 6-agent swarm (spec/semantics, status, motivation, coinbase-presigning, alternatives, limitations); 8 articles compiled. Progress score 96/100.
- 2026-07-16: init — topic wiki created (`--new-topic` via `/wiki:research`).

## Adjacent wikis

- [[../bitcoin-mining-payout-schemas/_index.md|bitcoin-mining-payout-schemas]] — payout/accounting schemas; the coinbase-presigning problem lives here operationally
- [[../sv2-coinbase-identity/_index.md|sv2-coinbase-identity]] — SV2 coinbase construction / per-miner tagging; same coinbase-outpoint surface
- [[../datum/_index.md|datum]] — decentralized template construction; coinbase ownership
- [[../sv2-p2pool-integration/_index.md|sv2-p2pool-integration]] — share-chain accounting where presigned payouts would apply
