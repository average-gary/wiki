---
title: "Adios, Expiry: Rethinking Liveness and Liquidity in Arkade (Ark Labs)"
source_url: https://blog.arklabs.xyz/adios-expiry-rethinking-liveness-and-liquidity-in-arkade/
type: article
authors: [Marco Argentieri]
publisher: Ark Labs
date: 2025-07-16
ingested: 2026-07-16
research_path: evolution
credibility: high
confidence: high
quality_score: 5
tags: [ark, arkade, delegation, intents, bip322, liveness, expiry, vtxo-renewal, arkd-0.7.0, sighash-anyonecanpay]
summary: Ark Labs' Delegation + Arkade Intents design to remove the active-liveness burden — a third-party delegate auto-renews VTXOs within BIP322-signed authorized windows. Also a candid designer admission that VTXO expiry + mandatory renewal "feels like a step backwards" from set-and-forget self-custody. Ships with arkd v0.7.0.
---

# Adios, Expiry: Rethinking Liveness and Liquidity in Arkade (Ark Labs)

Marco Argentieri (Ark Labs), 2025-07-16. Concrete shift away from mandatory synchronous VTXO renewal.

## Delegation + Intents
- Removes the active-liveness burden: previously users had to "periodically renew their VTXOs to maintain unilateral exit rights"; now a third-party delegate can auto-renew on their behalf within authorized time windows.
- Intents are **BIP322 message-signed** ownership proofs that cryptographically commit to exactly which outputs will be created; delegates "cannot modify either, only submit them at the authorized time."
- Three spending paths for delegated VTXOs: **A+S** (user+server normal spend), **A+CSV(exit)** (unilateral exit after timelock), **A+B+S** (user+delegate+server delegation path).
- Uses **SIGHASH_ALL|ANYONECANPAY** to let delegates add inputs without altering outputs.
- Ships with **arkd v0.7.0**.
- Notably does NOT mention CTV/CSFS/CCV/MuSig2/ANYPREVOUT — a covenantless-today design change to round/expiry mechanics.

## Designer admissions (criticism steelman)
- "expiry requires users to periodically renew their VTXOs to maintain unilateral exit rights, introducing liveness requirements for users."
- "Missing a renewal cycle means expired VTXOs are swept by the operator." (the "use it or lose it" mechanism)
- "For Bitcoin users used to 'set it and forget it' self-custody, this feels like a step backwards."
- No robust cross-device renewal story: "Current solutions require platform-specific strategies, some more reliable than others."
- Missing renewal means users "lose the ability to enforce ownership claims onchain" — fall back to trusting operator goodwill.
