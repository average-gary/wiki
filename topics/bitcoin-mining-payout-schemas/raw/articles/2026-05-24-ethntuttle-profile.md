---
title: "EthnTuttle (Ethan Tuttle) — eHash originator and Cashu/SV2 contributor"
publication: github.com/EthnTuttle + virginiafreedom.tech + Nostr
url: https://github.com/EthnTuttle
url2: https://virginiafreedom.tech
type: article
ingested: 2026-05-24
quality: 5
credibility: high
confidence: high
tags: [EthnTuttle, ehash-originator, Cashu, SV2, Iroh, Virginia-Freedom-Tech]
---

# EthnTuttle (Ethan Tuttle)

Originator of the **eHash** concept (mining-share-as-Cashu-bearer-token). Co-architect of hashpool via issue-driven protocol design. SRI Iroh/Noise transport RFC author. Founder of Virginia Freedom Tech LLC.

## Identity

- **Name**: Ethan Tuttle
- **GitHub**: https://github.com/EthnTuttle (143 public repos, 34 followers)
- **Email**: tuttle.ethan@protonmail.com
- **Nostr**: `npub1tmycvul7aj4fxhypg5qkjgsjtx30zvnrfeufrgx9xlwtv0hne7cs67el78`
- **Company**: Virginia Freedom Tech LLC (https://virginiafreedom.tech) — sells BitAxe lottery miners, ColdCard hardware wallets, Meshtastic devices; offers mining-pool consultation + protocol design services. Tagline: *"Sic Semper Tyrannis per Technologiam."*
- Affiliated with Shenandoah Bitcoin Club (regional meetup).

## Originator of eHash (May 2024)

The seminal proposal: **delvingbitcoin.org/t/870** — *"Ecash TIDES using Cashu and Stratum v2"*, May 2024. EthnTuttle authored. Thread continued into Jan 2025; Calle (Cashu creator), vnprc, MattCorallo, davidcaseria participated.

Key proposal: **Cashu NUT-02 keysets repurposed so each public key in the keyset corresponds to a difficulty target rather than a power-of-two sat denomination**. A blinded signature is "valued" by its committed difficulty target. **Calle's direct endorsement (paraphrased)**: *"your approach is more simple and doesn't require the mint operator to store outstanding blind messages."*

This is the conceptual antecedent of vnprc's hashpool. Relationship: **EthnTuttle = idea originator; vnprc = independent implementer.** No public evidence Tuttle contributes code to vnprc/hashpool; their relationship is idea-author → implementer.

## hashpool contributor profile (issue-driven)

Filed at least 9 foundational tracking issues on `vnprc/hashpool` from Feb-Sep 2025. **Zero PRs in the repo** — collaborator/co-conceiver via protocol-design issues, not direct commits.

| Issue | Title | Date |
|---|---|---|
| #2 | NIP-60 – Cashu Wallet (closed, "not planned") | Apr 2025 |
| #3 | HTTP Mint Service (closed) | Apr 2025 |
| #4 | Test ehash melting (closed) | Jun 2025 |
| #5 | CDK – Tracking Issue | Feb 2025 |
| #6 | Verification Proofs | (open) |
| #19 | async_channel migration | Sep 2025 |
| #23 | bitcoin commit pin | — |
| #24 | Do not return proofs when minting ehash (closed) | May 2025 |
| **#33** | **[PROTOCOL] add share hash commitment to blinded message** (open) | Mar 2025 |

#33 is the most consequential — direct protocol-design proposal on the share→token cryptographic binding.

## SV2 / Iroh transport RFC

**SRI Discussion #1935** (`stratum-mining/stratum`) — *"RFC: Iroh [Noise] Connection"*, posted **2025-10-03**. **EthnTuttle authored.** (The wiki previously recorded him as "commenter" — corrected.)

Core thesis: *"Iroh removes DNS as a dependency for Stratum v2 mining pools."*

Concrete API design — four parallel constructors (`Connection::new` TCP+Noise, `PlainConnection::new` TCP-only, `IrohConnection::new` Iroh+Noise, `PlainIrohConnection::new` Iroh-only) all returning identical `(Receiver, Sender)<StandardEitherFrame<Message>>` so `channels-sv2` and higher layers need zero changes.

Components specified: `NoiseIrohStream` (replaces `NoiseTcpStream` using `iroh::endpoint::{RecvStream, SendStream}`), `IrohNodeManager` (relay/STUN config). Four-phase rollout (transport → node mgmt → role integration → fallback).

Same-day reply mentioned plans for hands-on Iroh training at TABConf and linked Fedimint's Iroh integration via Fountain.fm.

## SRI reviewer activity

Recognized SRI reviewer on payout-relevant code. Named reviewer on **PR #1902** (`average-gary`'s "Persistence trait" — share-event persistence decoupling), with `plebhash`, `GitGab19`, `Shourya742`. Eventually closed/superseded by #1966 ("improve share validation"). Confirms reviewer-tier engagement on SRI core, not peripheral commenting.

## Cashu specification contributor

**cashubtc/nuts PR #85**: *"Update 01.md"* — merged March 19, 2024. Single small merged PR to the Cashu NUTs spec. Establishes him as a Cashu protocol contributor (NUT-01).

Other cashubtc work:
- **cashubtc/cdk #96** (May 2024, abandoned) — authored "feat: use bip32 DerivationPath for mint keyset"
- **cashubtc/nuts #107** (Dec 2024, abandoned) — involved in *"NUT-XX/XX+1: Mint/Melt Bitcoin On-Chain"* — direct attempt to bridge Cashu to on-chain Bitcoin. Conceptually close to mining-share→ecash workflows.

## Fedimint contributor

12 issues/PRs across Jan 2024–Jan 2026. Merged contributions: #4055 (module DKG message), #4178 (DKG peer-id ordering), #4347 (Nix flake overlays), #4391 (devimint stderr), #4415 (downloading guardian config), #5519 (docs typo).

## Mining-stack ecosystem repos (originals)

- **`pplns-jd`** (Feb 2026) — "SLICE (PPLNS+JD) accounting library for Stratum V2 mining pools." Empty placeholder — intent signal that he tracks DMND's SLICE work.
- **`ha-sv2-addons`** — Home Assistant add-on packaging the full Stratum V2 stack (sv2-apps v0.2.0 + Bitcoin Core 30.2 + sv2-tp v1.0.6). Distinctive **operator/homelab angle** on SV2.
- **`whatsminer-HA`** — Whatsminer ASIC integration (pyasic + Prometheus + Grafana + MQTT). Hands-on ASIC operator.
- **`ocean-srrrvey`** — Ocean.xyz pool monitor publishing stats to Nostr (#telehash-pirate hashtag). Confirms ongoing engagement with Ocean.
- **`blinded-sig`** (Rust) — BDHKE/Cashu-adjacent crypto experiment.
- **`kirk`** — Cashu+Nostr trustless gaming protocol.
- **`nutchain`** — Nostr game engine with FROST threshold randomness.
- **`sneakernet`** — NFC key exchange via Nostr+Iroh. Production-ish Iroh user (informs his SRI Iroh RFC).
- **`mole`**, **`herd-scout`**, **`MeshCore-BitChat` fork** — more Iroh/mesh experiments.
- **`awesome-ecash`** — curated list covering Cashu, Fedimint, webimint-rs, Nostr.
- **`purser`** — Nostr-native Zaprite replacement (very active May 2026).

## Trajectory (corrected/extended 2026-05-24)

1. **Fedimint contributor** — heavy 2023-2024 (~30 PRs/issues across `fedimint/fedimint`)
2. **Sept 2023**: [delvingbitcoin/t/110](https://delvingbitcoin.org/t/110) — *"Fedimint Overview and Fedipool Theorizing"*. Proposes a **"Poolimint"** Fedimint module validating shares & ecash payouts. **Earliest known precursor to eHash, 8 months before t/870.**
3. **Cashu/CDK contributor + NUT-01 spec author** — March 2024 PR #85 (merged); May 2024 cdk PR #96 (closed)
4. **May 2024**: [delvingbitcoin/t/870](https://delvingbitcoin.org/t/870) — *"Ecash TIDES using Cashu and Stratum v2"*. **eHash origin.** Calle endorsed.
5. **Nov 2024**: PR #2 on `dmnd-pool/share-accounting-ext` — first public engagement with DMND/SLICE
6. **Feb-Sep 2025**: hashpool architect via 9+ design issues (#2-#6, #19, #23, #24, #33). Zero PRs — issue-driven design only.
7. **Oct 2025**: SRI Discussion #1935 — *"RFC: Iroh [Noise] Connection"* (authored)
8. **Oct 23, 2025**: **PioneerHash GitHub org created**. 12 repos with `ehash-dev`/`ehash-persistence` branches across `cdk`, `stratum`, `sv2-apps`, plus originals `ehash`, `sv2-startos`, `webuyhash`, `e-sharp`. **EthnTuttle's parallel integration vehicle.** *See [[2026-05-24-pioneerhash-org|PioneerHash org]].*
9. **Feb 2026**: `EthnTuttle/pplns-jd` placeholder repo + Issue #7 (design notes citing Fi3 + sjors).

**The mining-payout work sits at the convergence of his ecash and Iroh transport interests** — and is increasingly **a parallel implementation track** (PioneerHash) rather than upstream contribution into vnprc/hashpool.

## Operating mode

EthnTuttle's preferred channel is **Nostr** (hardcoded npub on GitHub) and **GitHub discussions/issues**. No detectable podcast, conference, or article presence under either name (no btc++ Poolin' Stage talks identified). Search engines return no useful long-form material.

He is a **systems integrator + protocol commentator** — not the cryptographer (Cashu/CDK community), not the lead implementer (vnprc), but the person packaging, monitoring, and pushing protocol-level proposals at the edges.

## See also

- [[2026-05-24-vnprc-profile|vnprc profile]] — implementer of EthnTuttle's eHash idea
- [[../../wiki/concepts/ehash|eHash concept article]]
- [[2026-05-24-cashu-mining-application|Cashu mining application — delvingbitcoin/t/870]]
- [[2026-05-24-pioneerhash-org|PioneerHash GitHub org]] — his integration vehicle
- [[2026-05-24-ethntuttle-pioneerhash-collab|Collaboration verdict + full timeline]]
- [[../../../iroh-transport-stratum-v2/_index|sister wiki: iroh-transport-stratum-v2]] — for the SRI Iroh RFC
