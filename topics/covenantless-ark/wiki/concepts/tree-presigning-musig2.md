---
title: "Tree presigning — the MuSig2 pseudo-covenant"
type: concept
created: 2026-07-16
updated: 2026-07-16
confidence: high
tags: [ark, clark, presigning, musig2, ephemeral-keys, key-deletion, pseudo-covenant, n-of-n, schnorr]
---

# Tree presigning — the MuSig2 pseudo-covenant

This is the mechanism that makes Ark *covenantless*. Instead of an `OP_CTV` covenant constraining how the [[n-of-n-batch-output.md|batch output]] may be spent, clArk has all affected parties **pre-sign** the intended spend tree with an **n-of-n multisignature**, then **delete their signing keys** so no alternative spend can ever be created.

## The pseudo-covenant

> "If all parties that are affected by the covenant come together and create a multisig address and then pre-sign the desired transactions using an all-of-all signature scheme" — a covenant-like constraint emerges. ([[../../raw/articles/2026-07-16-foundations-ark-protocol-org-docs.md|ark-protocol.org]])

The trust condition: it holds "as long as at least one user in the entire group commits to deleting their key." One honest deletion makes the tree's alternative-spend branch permanently unforgeable — this is the **1-of-n honesty assumption** the litepaper names (§3.2). A covenant (CTV) would remove even that assumption.

## Ephemeral keys

Per round/refresh, "all of the refreshing users, together with the Ark server, each generate a **new private key**, use that key to sign the VTXO tree, then delete it" ([[../../raw/articles/2026-07-16-foundations-ark-protocol-org-docs.md|ark-protocol.org]]). These per-round **cosigner keys** are distinct from the users' wallet keys. (A later optimization removed ephemeral keys in favor of wallet keys for the reduced per-branch signing scheme — see below.)

## The MuSig2 session (arkd concrete flow)

From arkd's `pkg/ark-lib/tree/musig2.go` ([[../../raw/repos/2026-07-16-implementations-arkd-go-source.md|source]]):

1. `generateNonces()` → `musig2.GenNonces(WithPublicKey(signerPubKey))` per cosigner — one nonce **per branch transaction**.
2. `AggregateNonces()` → `musig2.AggregateNonces(allNonces)`.
3. `Sign()` → `musig2.Sign(secretNonce, signer, combinedNonce, cosigners, message, WithSortedKeys(), WithTaprootSignTweak(batchOutSweepClosure), WithFastSign())` — produces each cosigner's **partial signature**.
4. `CombineSigs()` → final single Schnorr signature per tree node.

Keys are sorted deterministically (`WithSortedKeys()`); cosigner membership is checked from the PSBT before signing (`ParseCosignerKeysFromArkPsbt`, `getCosignersPublicKeys`); and the **sweep-path taproot tweak** is applied so the aggregate key commits to the correct batch/leaf script. Ark Labs' account: clients "create random nonces for every branch transaction" ([[../../raw/articles/2026-07-16-implementations-arkade-os-docs.md|Arkade docs]]).

## Recursive n-of-n = the extra signing phase

Roose: "Each *node policy* contains a multisig with all the public keys of all the leaves below it." Because each presigned tree transaction must commit to *all descendant leaf keys*, clArk "requires an extra phase in which all clients sign (their branch of) the tree" — a phase absent from CTV variants ([[../../raw/articles/2026-07-16-foundations-roose-delving-clark-policies.md|Roose, Delving #1602]]). This recursion is why a receiver must be present to be issued a VTXO, driving the [[dropout-and-round-abort.md|interactivity limitation]].

## Signing-cost optimization

Ark Labs reduced the burden from each participant signing **(2n−1)** transactions to each user signing only **~log₂(n)** transactions — only those affecting their own VTXO descendants — and eliminated ephemeral keys in that scheme (users sign with wallet keys) ([[../../raw/articles/2026-07-16-evolution-unlock-liquidity-tree-signing.md|Ark Labs]]).

## See also

- [[clark-round-lifecycle.md|Round lifecycle]]
- [[n-of-n-batch-output.md|The n-of-n batch output]]
- [[dropout-and-round-abort.md|Dropout and round abort]]
- [[../topics/clark-vs-covenant-ark.md|clArk vs covenant-based Ark]]
