---
title: "Ark mainnet launches: Second's bark (Jun 2026) + Ark Labs' Arkade (Oct 2025)"
source_url: https://bitcoinmagazine.com/news/second-launches-bark-on-bitcoin-mainnet
type: article
authors: [Micah Zimmerman]
publisher: Bitcoin Magazine
date: 2026-06-09
ingested: 2026-07-16
research_path: news
credibility: medium
confidence: high
quality_score: 4
tags: [ark, bark, arkade, mainnet, second, ark-labs, funding, boltz, arkade-assets, deployment, timeline]
summary: Two distinct implementations/companies reached production — Second's bark went live on Bitcoin mainnet 2026-06-09 ($5.1M raise, ~11 people incl. ex-Blockstream); Ark Labs' Arkade launched public beta 2025-10-20/21 (Tether-backed, $2.5M pre-seed Aug 2024 + $5.2M Mar 2026). DO NOT conflate the two raises.
---

# Ark mainnet launches: Second's bark + Ark Labs' Arkade

Consolidated from two Bitcoin Magazine reports (Micah Zimmerman) plus the Ark Labs blog index. CRITICAL: two separate companies with separate ~$5M raises — do not merge.

## Second's bark — Bitcoin Magazine, 2026-06-09
- `bark` went live on **Bitcoin mainnet on 2026-06-09**; Ark server publicly accessible for payments.
- **Second raised $5.1M from a private investor**; team of **11**, including former Blockstream engineers.
- Developer toolkit: **Bark SDK** (Rust core with bindings for Kotlin, Swift, React Native, Flutter, Go, Python, WASM); **`barkd`** standalone wallet daemon (REST + OpenAPI); **BTCPay Server plugin** for merchant self-custodial Lightning.
- Launch apps: Noah, Arke (iOS), Satsigner, Bark Wallet (Umbrel — Ark + Lightning + on-chain).

## Ark Labs' Arkade — Bitcoin Magazine, 2025-10-21
- **Arkade launched to public beta on 2025-10-20/21** — billed as first mainnet implementation of the Ark protocol and "first major Bitcoin L2 since Lightning."
- Architecture: virtualizes UTXOs (no consensus change), VTXOs for instant off-chain execution, **batch settlement** compressing thousands of ops into a single Bitcoin tx, presigned txs for trustless on-chain recovery, **Lightning integration via Boltz**.
- **Arkade Assets** framework launched alongside — native multi-asset support (stablecoins/tokens) with planned **USDT/Tether** integration. CEO Marco Argentieri.
- Launch partners: Breez, BlueWallet, BTCPayServer, Bull Bitcoin, LayerZ.
- Funding trajectory (from blog index): **$2.5M pre-seed (2024-08-22)** → **$5.2M backed by Tether (2026-03-12)**; investors elsewhere reported as Draper Associates, Axiom, Fulgur Ventures.

## Ecosystem-standards signal (Optech #395, 2026-03-06)
- **V-PACK / Minimal Viable VTXO (MVV)**: proposed stateless VTXO verification standard to translate between Ark "dialects" (Arkade vs Bark) into a neutral format; open-source `libvpack-rs`, visualizer at vtxopack.org. Verifies unilateral-exit merkle paths; path-exclusivity (ASP backdoor detection) flagged as future work.

## Flags
- "Ark v2" as a formal named release did NOT surface; the v2-style evolution is captured by (a) Erk/hArk covenant proposals and (b) Arkade Delegation/Intents + arkd v0.7.0 + the log₂(n) tree-signing/OOR changes.
- Ark Labs funding figures corroborated across blog index + PRNewswire snippet, not a single deep-fetched primary post.
