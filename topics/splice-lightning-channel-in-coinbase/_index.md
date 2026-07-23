---
title: "Splicing a Lightning Channel in a Coinbase Transaction — Wiki"
type: wiki-root
created: 2026-07-23
updated: 2026-07-23
scope: hub-topic
summary: "Thesis wiki: 'I can splice a lightning channel in a coinbase transaction.' Tests whether the on-chain tx that modifies an LN channel's funding output (a splice) can be a coinbase — literally (splice-as-coinbase) or charitably (a funding output created by a coinbase). Turns on coinbase input structure (single null-prevout input, spends no UTXO), COINBASE_MATURITY=100, reorg risk, and LN splice/funding enforceability. Builds on sighash-anyprevout-bip118 (the unknown-coinbase-outpoint presigning wall) and ark-boarding-sv2-mining (the sibling thesis that defers signing to post-block-found)."
---

# Splicing a Lightning Channel in a Coinbase Transaction — Wiki

Topic wiki for a single **thesis**:

> I can splice a lightning channel in a coinbase transaction.

The claim reads two ways, and the research separates them:

- **Reading A (literal):** the splice transaction *is* the block's coinbase.
- **Reading B (charitable):** an LN funding output is *created by* a coinbase, and
  the splice happens later against that (matured) output.

The crux is a collision of two definitions. A **coinbase** has exactly one input
with a **null prevout** — it spends no existing UTXO. A **splice**, by definition,
*spends the existing channel funding UTXO* to create a new one. The interesting
territory is the presigning wall — a coinbase outpoint is unknowable until the
block is mined — the same wall documented in
[[../sighash-anyprevout-bip118/_index|sighash-anyprevout-bip118]] and routed around
by [[../ark-boarding-sv2-mining/_index|ark-boarding-sv2-mining]].

## Layout

- `wiki/concepts/` — atomic concept articles
- `wiki/topics/` — synthesizing topic articles
- `wiki/reference/` — pointers to specs, repos, related proposals
- `theses/` — the thesis file + verdict (see [[theses/splice-lightning-channel-in-coinbase]])
- `raw/` — ingested source material with provenance
- `output/` — generated artifacts

## Theses

This topic now holds **three** theses:

1. **[[theses/splice-lightning-channel-in-coinbase|"I can splice a lightning channel in a coinbase transaction."]]** — the parent claim (verdict below).
2. **[[theses/splice-in-vs-bolt12-miner-liquidity|"Splicing matured coinbase rewards into miner channels beats OCEAN BOLT12 payouts for miners wanting inbound LN liquidity."]]** — follow-up #3a (Reading C). **Verdict: Contradicted (as stated) / Mixed (reframed) — High.** The "inbound liquidity" framing is a category error: splice-in of your own funds yields *outbound*, and receiving a BOLT12 payout *consumes* inbound — neither creates inbound (only a counterparty funding the far side does). Reframed to the outbound goal it's a conditions-dependent Mixed (splice wins for large/infrequent/self-custody; BOLT12 for small/frequent/immediate), and the two are complementary, not rivals. Full reasoning: [[wiki/topics/splice-vs-bolt12-verdict]].
3. **[[theses/pool-provisions-miner-inbound-via-splice|"A pool can provision miners' inbound LN liquidity by settling payouts as toward-miner splices/dual-funds, unifying delivery + provisioning in one on-chain footprint."]]** — follow-up #3b (the counterparty-splices-toward-miner option #3a surfaced). **Verdict: Partially Supported — High.** The mechanism is real, spec'd (bLIP-36 on-the-fly funding, bLIP-52 JIT, liquidity ads, interactive-tx batching) and *deployed as a wallet-LSP* (Phoenix / eclair #2861). But the literal "funds on the pool's side = payout" wording is a category error — `push_msat` is *omitted* from `open_channel2`, so no single tx both gives the miner inbound and delivers payout value; the genuine unification is JIT/on-the-fly (an incoming payment triggers the open, fee netted from it; the on-chain tx supplies *capacity*, the *value* crosses off-chain). And **no mining pool** actually does this — a novel, unbuilt synthesis. Full reasoning: [[wiki/topics/pool-splices-toward-miner-verdict]].

### Parent thesis verdict

See [[theses/splice-lightning-channel-in-coinbase]].

**Verdict (2026-07-23): Mixed — High confidence.** The claim is really three claims:
- **Reading A (splice tx *is* the coinbase): Contradicted.** A splice must spend the
  existing funding output; a coinbase's sole input has a null prevout and spends
  nothing (`IsCoinBase()`). Type-level consensus contradiction.
- **Reading B (funding output *created by* a coinbase, spliced later): spec-legal but
  not viable.** BOLT #2 `channel_ready` explicitly names the coinbase-funding case
  (verified verbatim) — but `COINBASE_MATURITY = 100` leaves the channel unenforceable
  for ~16.7 h and reorg voids it; the natural fix collapses into Reading C.
- **Reading C (splice-in a *matured* coinbase UTXO): Supported, today.** CLN
  `splicein` / Phoenix splice any confirmed UTXO — but that's splicing coinbase-
  *descended funds* into a channel, not a splice *in* a coinbase.

Full reasoning: [[wiki/topics/thesis-analysis-verdict]].

## Quick Navigation

- [Thesis 1 (parent)](theses/splice-lightning-channel-in-coinbase.md)
- [Thesis 2 (splice-in vs BOLT12)](theses/splice-in-vs-bolt12-miner-liquidity.md)
- [Thesis 3 (pool splices toward miner)](theses/pool-provisions-miner-inbound-via-splice.md)
- [All Sources](raw/_index.md)
- [Concepts](wiki/concepts/_index.md)
- [Topics](wiki/topics/_index.md)
- [Reference](wiki/reference/_index.md)
- [Outputs](output/_index.md)

## Stats

- Sources ingested: **23** (14 articles, 8 papers/BIPs/spec, 1 consensus-code repo)
- Articles compiled: **11** (7 concepts, 3 topic syntheses, 1 reference) + 3 thesis files
- Theses: **3** (all verdicts rendered — parent Mixed / High; follow-up #3a Contradicted-as-stated / Mixed-reframed / High; follow-up #3b Partially Supported / High)
- Research sessions: 2026-07-23 parent thesis (5 agents) + 2026-07-23 follow-up #3a (5 agents) + 2026-07-23 follow-up #3b (5 agents: supporting/opposing/mechanistic/meta/adjacent)
- Last updated: 2026-07-23

## Related wikis

- [[../sighash-anyprevout-bip118/_index|sighash-anyprevout-bip118]] — the unknown-coinbase-outpoint presigning wall.
- [[../ark-boarding-sv2-mining/_index|ark-boarding-sv2-mining]] — sibling thesis: defer signing to post-block-found to route around that wall.
- [[../ldk-server/_index|ldk-server]] — Lightning node context (splicing support).
- [[../bitcoin-mining-payout-schemas/_index|bitcoin-mining-payout-schemas]] — coinbase-payout context.
