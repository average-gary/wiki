---
title: "MuSig2: Simple Two-Round Schnorr Multisignatures (Jonas Nick / Blockstream)"
source: "https://jonasnick.github.io/blog/2020/11/29/musig2-simple-two-round-schnorr-multisignatures/"
type: articles
ingested: 2026-07-16
tags: [musig2, two-nonce, concurrent-security, drijvers-attack, state-machine, backup-restore, nonce-reuse, explainer]
summary: "Co-author Jonas Nick's plain-language MuSig2 explainer (also on the Blockstream blog, Nov 2020). Names the Drijvers concurrent-session forgery that made naive two-round Schnorr multisig an unsolved problem, explains the two-nonce fix R_i = R_i,1 + b·R_i,2 with b hashing all nonces + aggkey + message, and gives the canonical state-machine footgun: back up an open session, finish it, restore the backup and finish again → two sigs under one nonce → key theft."
---

# MuSig2: Simple Two-Round Schnorr Multisignatures (author explainer)

**Author**: Jonas Nick (MuSig2 co-author). Blockstream blog / jonasnick.github.io, Nov 2020. Companion to the academic paper.

## The problem: concurrent-session forgery

Names the **Drijvers et al.** attack: *"an attacker opens many sessions with a victim signer and is able to obtain a signature on a message that the victim did not intend to sign."* Making a secure two-round interactive Schnorr multisig was an "unsolved research problem" until MuSig2.

## The two-nonce fix

Each signer makes two nonces `R_i,1, R_i,2` and uses the effective nonce `R_i = R_i,1 + b·R_i,2`, where `b` is a hash of all signers' nonces + the aggregate key + the message. If any signer tweaks their nonces, everyone's linear combination changes unpredictably — denying the attacker the controlled algebraic structure the ROS/Wagner attack needs. This replaces MuSig1's separate nonce-commitment round.

## The canonical state-machine footgun (backup/restore)

The most vivid real-world reuse scenario: start a session, save its state, back up the drive, finish the session — then **restore the backup and finish again**. This produces two signatures under the same nonce, which *"can be used to steal our secret key."* This is the VM-snapshot / rollback / restore-from-backup hazard made concrete. Contrasts with MuSig-DN's stateless deterministic-nonce design, which avoids the persistence hazard at the cost of a zero-knowledge proof.

## What this source contributes

The best plain-language explanation of the two-nonce rationale, plus the single most vivid concrete nonce-reuse scenario (backup/restore) — ideal source material for the state-machine-pitfalls section of the wiki.
