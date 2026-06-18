---
title: Nostr + Ecash Gaming — Wiki
type: wiki-root
created: 2026-06-17
updated: 2026-06-17
scope: hub
---

# Nostr + Ecash Gaming — Wiki

Knowledge base for game engines, protocols, and specs that fuse **Nostr** (decentralized
relay-based event protocol with cryptographic identity) and **ecash** (Cashu and Fedimint
blinded-token bearer instruments, often Bitcoin-backed) as the substrate for game state,
in-game economy, and item ownership.

The on-ramp for this topic is the trio of Ethan Tuttle ([@EthnTuttle](https://github.com/EthnTuttle))
projects:

- **[nutchain](https://github.com/EthnTuttle/nutchain)** — game-engine spec (no impl); 14
  event kinds in 30800-30814; **threshold-OPRF distributed randomness** over BDHKE +
  ChillDKG.
- **[kirk](https://github.com/EthnTuttle/kirk)** — Rust protocol library; 5 event kinds in
  9259-9263; **mint-as-referee** with NUT-11 P2PK reward-locking; **C-value game pieces**.
- **[manastr](https://github.com/EthnTuttle/manastr)** — playable strategy game; 7 event
  kinds in 31000-31006; CDK custom-units mint (`mana` / `loot`); stateless query-on-render
  React client; post-hoc Game Engine Bot validator. **Does NOT use kirk.**

The first non-obvious finding of this research session: the trio is **three independent
designs**, not three layers of one stack — see
[[wiki/topics/three-event-kind-ranges-one-author.md|Three event-kind ranges, one author]].

## Layout

- `wiki/concepts/` — atomic concept articles (10)
- `wiki/topics/` — synthesizing topic articles (3)
- `wiki/reference/` — specs, NIP-kind allocation, NUT cheat-sheet (2)
- `raw/` — ingested source material with provenance (16 sources)
- `output/` — generated artifacts (0)
- `theses/` — testable claims for follow-up research (0)

## Stats

- Sources ingested: 16 (2 papers, 5 articles, 9 repos)
- Articles compiled: 15 (3 topics + 10 concepts + 2 reference)
- Outputs: 0
- Theses: 0
- Last research session: 2026-06-17 (init + nutchain/kirk/manastr deep-ingest + 5-agent landscape)

## Start here

- [[wiki/topics/three-event-kind-ranges-one-author.md|Three event-kind ranges, one author]]
  ⭐ — the trio decomposed, the synthesis answer to "what is nutchain/kirk/manastr"
- [[wiki/topics/the-emerging-landscape.md|The emerging Nostr+ecash gaming landscape]] ⭐ —
  five factions, no shared protocol; what to use today
- [[wiki/topics/contrarian-case-and-hard-problems.md|The contrarian case]] — sober reading
  of the trust model, attack surface, and what these systems are actually good for
- [[wiki/concepts/c-value-game-piece.md|C-value game piece]] — kirk's clever Cashu-blind-
  signature-as-RNG trick
- [[wiki/concepts/threshold-oprf-dasor.md|Threshold-OPRF DASoR]] — nutchain's
  distributed-randomness alternative
- [[wiki/concepts/mint-as-referee.md|Mint-as-referee]] vs [[wiki/concepts/post-hoc-validator-pattern.md|Post-hoc validator]]
  — the two trust-model designs in active use
- [[wiki/reference/event-kind-allocation-table.md|Event-kind allocation table]] +
  [[wiki/reference/cashu-nut-primitives-for-gaming.md|Cashu NUT cheat-sheet]] — quick
  reference

## Open questions

1. **Will the EthnTuttle trio converge?** Three event-kind ranges, three different protocols,
   one author. As of 2026-06-17 the answer is fragmentation; whether kirk + DASoR get
   retrofit into manastr is an open question.
2. **Will any of these get a NIP?** Currently only NIP-64 (chess) and the draft NIP-101p
   (poker) live in the standardized NIP space. The kirk / nutchain / manastr ranges are
   all custom and unregistered.
3. **Will Cashu vs Fedimint converge for gaming?** No Fedimint gaming module ships
   (negative finding). manastr uses CDK custom units rather than a Fedimint module. Whether
   the multi-currency / module API of Fedimint becomes attractive for gaming is unanswered.
4. **Will a "Cashu game starter kit" emerge?** Calle / cashubtc has not endorsed any
   reference impl. Bitcoin++ Berlin Oct 2025 had a dedicated ecash hackday but no canonical
   reference for the game-asset-on-Cashu pattern emerged.
5. **Mint-as-referee vs post-hoc-validator** — which scales? Manastr's split design (CDK
   mint for custody only, Game Engine Bot for validation) is more decoupled but introduces
   a separate trust assumption.
6. **Ordering on Nostr** — should the application layer keep building hash-linked event
   chains, or should NIP-29 (relay-as-sequencer) become the standard? Both have failure
   modes.
7. **Funding** — OpenSats has not funded gaming through 17 grant waves. Routstr is the
   architectural template anyone could fork. Will a gaming proposal land?
8. **Trustless RNG without a mint?** nutchain's threshold-OPRF DASoR is currently the only
   serious answer; its ChillDKG-OPRF composability is unproven.
9. **Will Nutshell's `LNbitsWallet` fee-bypass attack actually trigger an insolvency event
   in a high-stakes Cashu game?** Vector is shipped code; question is observability.
10. **Is there a viable middle path between Lightning-settlement (NIP-101p) and Cashu-bearer
    (kirk / manastr)?** Nutzaps (NIP-61) on top of NIP-101p would be the cross-pollination
    no-one has shipped.
