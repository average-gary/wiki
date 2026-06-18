---
title: "Spacenut + gandlafbtc Cashu toolkit — only confirmed-shipped Cashu-paying game"
source: https://github.com/gandlafbtc/spacenut
demo: https://spacenut.nutstash.app
type: repo
tags: [cashu, gaming, spacenut, nutstash, faucet, headless-cashu, gandlafbtc, sveltekit]
fetched: 2026-06-17
confidence: high
credibility: medium
quality_score: 3
relevance: direct
direction: nuances
summary: |
  Spacenut is a classic arcade space-shooter that pays sats via Cashu — the only confirmed
  shipped game with a Cashu-native payout primitive as of mid-2026. SvelteKit / Vite / Bun
  / TypeScript. Author gandlafbtc maintains the surrounding Cashu plumbing (nutstash-wallet,
  proxnut paywall, cashu-faucet, headless-cashu, cashu-bdhke-kmp), which together form the
  most complete builder kit for bolt-on Cashu game economy today. Existence proof + toolkit
  even if the game itself is small.
---

# Spacenut + gandlafbtc toolkit

## Source

- Repo: https://github.com/gandlafbtc/spacenut
- Live demo: https://spacenut.nutstash.app
- Author: gandlafbtc (maintainer of Nutstash wallet)
- Quality: 3 (small game, but author surface is high-signal)

## What it is

Classic arcade space-shooter. Posted on Stacker News May 2023 as "a game that pays you sats
via Cashu." Stack:

- SvelteKit + Vite + Bun + TypeScript / Svelte

## gandlafbtc surrounding kit

| Repo | Role |
|---|---|
| `nutstash-wallet` (62 stars) | Multimint Cashu wallet, send-to-Nostr-key |
| `proxnut` | Cashu paywall proxy |
| `cashu-faucet` | Slow token faucet (directly useful for play-to-earn drip) |
| `cashu-tools` | Misc Cashu tools |
| `headless-cashu` | Browser library |
| `cashu-bdhke-kmp` | Kotlin-multiplatform BDHKE |
| `cashu-brrr` | Token mass-minting tool |

## Why it matters

This is currently the **only confirmed shipped game with a Cashu-native payout primitive**.
The supporting toolkit is the most complete builder kit for ecash-on-game today —
particularly `cashu-faucet` (drip), `proxnut` (paywall), `headless-cashu` (browser-side
wallet without UI). For anyone bolting Cashu onto an existing game without designing a
trust model from scratch, this stack is the prior art.

## Negative finding (corroborating signal)

Stacker News thread Feb 2026 ("Do you know any game online where I can play2earn Ecash
Cashu?") — community consensus: essentially "no full games yet." Spacenut is the floor.

## Notable

- No Nostr integration — Cashu-only. Distinguishes from manastr / kirk where Nostr is the
  bus.
- No NUT-11 P2PK or NUT-14 HTLC use — Cashu is the payment rail, not the asset/state layer.
