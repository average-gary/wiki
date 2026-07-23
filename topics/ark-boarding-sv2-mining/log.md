# ark-boarding-sv2-mining — log

## [2026-07-17] init | new hub topic created for thesis research

## [2026-07-17] research (thesis mode) | 5 agents → 21 sources, 7 articles + thesis verdict
- Thesis: "Online-while-mining covenantless Ark boarding SV2 extension (n-of-n batch output, cosigning ceremony post-block-found) viable today without CTV/CSFS."
- Verdict: **Partially Supported / Medium**. Covenant-free core sound (post-block-found dissolves unknown-txid; MuSig2 Deployed; clArk mainnet; SV2 NewBlockFound trigger). "Viable" overreaches at pool scale (Braidpool ~50-signer cap; pure-receiver DoS; coinbase maturity/reorg → matured proxy UTXO).
- Compiled: thesis-analysis-viability (topic); post-block-found-signing, covenantless-batch-output-mechanics, pure-receiver-and-liveness, coinbase-maturity-and-reorg, sv2-extension-surface (concepts); alternatives-and-prior-art (reference).

## [2026-07-20] plan | "Minimal covenantless Ark-boarding SV2 extension — testnet4 real-hashrate trial" → output/plan-ark-boarding-sv2-testnet4-trial-2026-07-20.md (11 articles consulted across 3 wikis + direct source read, 5 decisions, 6 phases)
- Scope locked to the viable regime: n=2–5, Pool+JDC/proxy keys (not ASIC), post-block-found NewBlockFound trigger, matured-proxy-UTXO primary + fresh-coinbase failure demo, abort+ban+retry dropout.
- New extension messages 0x11–0x18 (BoardingRequest/Commit, TreeNonces/Aggregated, TreePartialSigs/TreeSignatures, BoardingComplete, CeremonyAbort) alongside existing 0x00–0x10.
- Gap-fills: BIP-94 testnet4 keeps 20-min min-difficulty rule (real-hashrate block-finding feasible); MuSig2 API correction → mainline `secp256k1` 0.32.0-beta.2 `musig` module (per local bark), not `secp256k1-zkp`.

## [2026-07-20] plan | "JDC-as-Ark-payer — verifiable SV2 sub-pool over an external Ark ASP" → output/plan-jdc-ark-payer-external-asp-2026-07-20.md (external-ASP variant, 5 decisions, 6 phases)
- Pivot from pool-as-ASP after user asked to plug into EXISTING ASPs as a mining pool. Realizes thesis follow-up #3 (matured funding collapses post-block-found novelty).
- Topology: Pool pays JDC as one miner → JDC holds funded/matured Ark balance, runs verifiable sub-tier accounting (demand-share-accounting-ext downstream) → sends miners weighted OOR/arkoor VTXOs via ark-settler → barkd → captaind (self-hosted testnet4, AspClient boundary).
- Removes the MuSig2 ceremony (ASP owns signing); new extension shrinks to addressing/receipt messages 0x11–0x14. Trade: 2 custodial surfaces (JDC+ASP), OOR exit collusion-conditional; mitigated by verifiable accounting + unilateral-exit floor. Two plans now coexist (pool-as-ASP vs external-ASP).

## [2026-07-20] plan-amend | external-ASP plan: Pool→JDC funding is now over LIGHTNING
- Added Decision 6: Pool pays JDC over LN; ASP is itself a Lightning gateway so inbound LN value arrives directly as a VTXO (no JDC LN node/channels/on-chain boarding wait). Grounded in covenantless-ark lightning-integration + boarding.
- Handling baked in: refresh-to-harden LN receives (ephemeral-key caveat + ~3-day lifetime); AspClient trait gains invoice()/await_receive()/refresh(); balance watchdog emits top-up invoices. New failure mode 5f (LN funding fail / unrefreshed receive), 3 new risk rows, Phase 6 inbound-LN cost metric.
