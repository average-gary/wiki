---
title: Ark Boarding as an SV2 Mining Extension (covenantless, post-block-found) — Wiki
type: wiki-root
created: 2026-07-17
updated: 2026-07-17
scope: hub-topic
summary: "Thesis wiki: is an online-while-mining, covenantless Ark boarding Stratum V2 extension — n-of-n batch output, cosigning ceremony triggered post-block-found — viable on Bitcoin today without CTV/CSFS? Anchored to demand-open-source/demand-share-accounting-ext. Builds on covenantless-ark (clArk n-of-n presigning), sighash-anyprevout-bip118 (the coinbase-presigning wall this routes around), and musig2-signing-ceremonies."
---

# Ark Boarding as an SV2 Mining Extension — Wiki

Topic wiki for a single **thesis**:

> An online-while-mining covenantless Ark boarding SV2 extension (n-of-n batch
> output, cosigning ceremony triggered post-block-found) is viable on Bitcoin
> today without CTV/CSFS.

The interesting move is **timing**: clArk normally presigns a VTXO tree *before*
funds are committed. Here the funding source is a **coinbase**, whose outpoint is
unknowable until a block is mined — the exact wall documented in
[[../sighash-anyprevout-bip118/wiki/topics/coinbase-outpoint-presigning|coinbase-outpoint-presigning]].
The thesis proposes to **defer the n-of-n cosigning ceremony to *after* the block
is found**, when the coinbase outpoint is known, so no rebindable-signature
primitive (APO) or output-committing covenant (CTV) is required.

## Layout

- `wiki/concepts/` — atomic concept articles
- `wiki/topics/` — synthesizing topic articles
- `wiki/reference/` — pointers to specs, repos, related proposals
- `theses/` — the thesis file + verdict (see [[theses/ark-boarding-sv2-mining]])
- `raw/` — ingested source material with provenance
- `output/` — generated artifacts

## Thesis

See [[theses/ark-boarding-sv2-mining]].

**Verdict (2026-07-17): Partially Supported — Medium confidence.** The covenant-free
core is sound and confirmed today (post-block-found timing dissolves the
unknown-coinbase-txid problem; MuSig2 "Deployed", clArk on mainnet, SV2 extensions
with a `NewBlockFound` trigger all ship now). But "viable" overreaches: n-of-n
doesn't scale to a pool's miner count (Braidpool caps ~50), miners are the
pure-receiver/one-dropout-aborts-all case clArk handles worst, and coinbase
maturity/reorg forces boarding a matured proxy UTXO. Viable at small-signer-set /
proxy-delegated scale; not as a trustless drop-in for thousands of miners.

Full reasoning: [[wiki/topics/thesis-analysis-viability]].

## Quick Navigation

- [Thesis](theses/ark-boarding-sv2-mining.md)
- [All Sources](raw/_index.md)
- [Concepts](wiki/concepts/_index.md)
- [Topics](wiki/topics/_index.md)
- [Reference](wiki/reference/_index.md)
- [Outputs](output/_index.md)

## Stats

- Sources ingested: **21** (14 articles, 3 papers/specs, 4 repos)
- Articles compiled: **7** (1 topic synthesis, 5 concepts, 1 reference) + 1 thesis file
- Theses: 1 (verdict rendered) + 4 suggested follow-ups
- Outputs: **2** — [JDC-as-Ark-payer / external-ASP plan](output/plan-jdc-ark-payer-external-asp-2026-07-20.md) + [pool-as-ASP testnet4 trial plan](output/plan-ark-boarding-sv2-testnet4-trial-2026-07-20.md) (2026-07-20)
- Last research session: 2026-07-17 (thesis mode, 5 agents: supporting/opposing/mechanistic/meta/adjacent)
- Last updated: 2026-07-20

## Related wikis

- [[../covenantless-ark/_index|covenantless-ark]] — clArk n-of-n presigning mechanics this thesis reuses.
- [[../sighash-anyprevout-bip118/_index|sighash-anyprevout-bip118]] — the unknown-coinbase-txid presigning wall.
- [[../musig2-signing-ceremonies/_index|musig2-signing-ceremonies]] — the interactive n-of-n ceremony carried over the wire.
- [[../bitcoin-mining-payout-schemas/_index|bitcoin-mining-payout-schemas]] — mining payout/accounting context.
