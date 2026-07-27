---
title: Raw Sources
type: index
updated: 2026-06-17
---

# Raw Sources (16 total)

## papers/ (2)

- [[papers/2026-06-17-chaum-blind-signatures-1982-foundational.md|2026-06-17-chaum-blind-signatures-1982-foundational.md]] — Chaum CRYPTO '82, the originating blind-signature primitive every Cashu/Fedimint claim reduces to
- [[papers/2026-06-17-nostr-empirical-decentralization-resilience-conext.md|2026-06-17-nostr-empirical-decentralization-resilience-conext.md]] — Wei & Tyson, ACM CoNEXT '25 — peer-reviewed measurement of Nostr; 20% relays down >40%, 95% can't cover cost, no native event ordering

## articles/ (5)

- [[articles/2026-06-17-cashu-nuts-10-11-12-14-programmable-primitives.md|2026-06-17-cashu-nuts-10-11-12-14-programmable-primitives.md]] — NUT-10/11/12/14 reference: P2PK + multisig + locktime + DLEQ + HTLC, the building blocks for game-asset semantics
- [[articles/2026-06-17-nip-101p-and-game-relevant-nips-survey.md|2026-06-17-nip-101p-and-game-relevant-nips-survey.md]] — Survey of all gaming-relevant NIPs (01/29/44/47/57/60/61/64/87/90/101p) and the kind ranges in active use
- [[articles/2026-06-17-cashu-vulnerabilities-keyset-collision-and-poisonous-airdrop.md|2026-06-17-cashu-vulnerabilities-keyset-collision-and-poisonous-airdrop.md]] — conduition.io disclosure: NUT-13 31-bit keyset-id space + NUT-09 restore = silent coin-fork
- [[articles/2026-06-17-rug-the-mints-fee-bypass-nutshell-lnbits.md|2026-06-17-rug-the-mints-fee-bypass-nutshell-lnbits.md]] — Nutshell `LNbitsWallet` ignores `fee_limit_msat`, drains hot wallet, returns success-on-overage
- [[articles/2026-06-17-ethntuttle-chaumian-ecash-design-notes-gist.md|2026-06-17-ethntuttle-chaumian-ecash-design-notes-gist.md]] — Tuttle's own gist: "much worse trust model than a blockchain"; Cashu has reverted to online (not offline) transfers

## repos/ (9)

- [[repos/2026-06-17-ethntuttle-kirk.md|2026-06-17-ethntuttle-kirk.md]] ⭐ — kirk: Rust protocol library; event kinds 9259-9263; mint-as-referee; NUT-11 reward-locking; C-value game pieces
- [[repos/2026-06-17-ethntuttle-manastr.md|2026-06-17-ethntuttle-manastr.md]] ⭐ — manastr: full game; event kinds 31000-31006; CDK custom-units mint; stateless clients; commit-reveal; **does NOT use kirk**
- [[repos/2026-06-17-ethntuttle-nutchain.md|2026-06-17-ethntuttle-nutchain.md]] ⭐ — nutchain: spec only; event kinds 30800-30814; threshold-OPRF DASoR randomness via ChillDKG over BDHKE
- [[repos/2026-06-17-nostrgameengine.md|2026-06-17-nostrgameengine.md]] — NostrGameEngine (jMonkeyEngine fork, Java); production engine; NostrRTC P2P-over-Nostr-signaling; v0.5.x will add Lightning/Cashu
- [[repos/2026-06-17-docnr-nostr-poker-nip101p.md|2026-06-17-docnr-nostr-poker-nip101p.md]] — DocNR/nostr-poker: rigorous NIP-101p draft; kinds 1650-1660 + 33650; commit-reveal trust model; replaceable-dealer marketplace; Lightning settlement (candidate for Cashu)
- [[repos/2026-06-17-jester-nip64-chess-on-nostr.md|2026-06-17-jester-nip64-chess-on-nostr.md]] — Jester + NIP-64: chess via PGN-in-event-content; only merged game-specific NIP; counter-pattern to mint-as-referee
- [[repos/2026-06-17-spacenut-and-gandlafbtc-cashu-toolkit.md|2026-06-17-spacenut-and-gandlafbtc-cashu-toolkit.md]] — spacenut + gandlafbtc Cashu builder kit (nutstash, proxnut, cashu-faucet, headless-cashu) — only confirmed shipped Cashu game
- [[repos/2026-06-17-fedimint-modules-roastr-and-prediction-market.md|2026-06-17-fedimint-modules-roastr-and-prediction-market.md]] — Fedimint module survey: ROASTr (threshold Nostr signing), fedimint-prediction-market (EthnTuttle); no actual gaming modules exist
- [[repos/2026-06-17-cashu-casino-and-other-cashu-games-survey.md|2026-06-17-cashu-casino-and-other-cashu-games-survey.md]] — Cashu Casino, Monopoly, chessu, OnChainDiscGolf — every shipped Cashu game uses ecash as payment rail only, NOT NUT-11/14 game-asset semantics

## data/ (0)

(none)
