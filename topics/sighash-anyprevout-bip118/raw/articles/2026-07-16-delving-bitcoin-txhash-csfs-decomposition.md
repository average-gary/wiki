---
title: "Combined CTV/APO into minimal TXHASH+CSFS (Delving Bitcoin, reardencode)"
source: "https://delvingbitcoin.org/t/combined-ctv-apo-into-minimal-txhash-csfs/60"
type: articles
ingested: 2026-07-16
tags: [ctv, anyprevout, txhash, csfs, covenant-primitives, locking-vs-unlocking, recursion, reardencode, delving-bitcoin]
summary: "Primary developer discussion crystallizing the conceptual split between CTV and APO: CTV commits to the transaction template IN THE LOCKING SCRIPT (the output constrains what may spend it); APO commits via a SIGNATURE IN THE UNLOCK SCRIPT (the signature just doesn't bind to what it spends). Both decompose into TXHASH (configurable tx hash) + CSFS (verify a sig against an arbitrary hash). Notes the hash mode must itself be committed to prevent substitution attacks, and that APO's SIGHASH_SINGLE modes enable more recursive constructions."
---

# Combined CTV/APO into minimal TXHASH+CSFS

Delving Bitcoin, reardencode et al. Best articulation of the APO-vs-CTV conceptual
axis.

## The core conceptual split

- **CTV** commits to the transaction template *in the locking script* (the output
  constrains what may spend it).
- **APO** commits via a *signature in the unlock script* (the signature just doesn't
  bind to what it spends).
- "The requirements for a transaction hash are different when committed to in the
  locking script vs by a signature in the unlock script" — this is why the two exist
  as separate primitives.

## Unifying model

- Both can be decomposed into **TXHASH** (produce a configurable tx hash) + **CSFS**
  (verify a signature against an arbitrary hash), separating "hashing" from "signature
  validation."
- Warning: the hash *mode* must itself be committed (in the output) to prevent
  script-reordering / "anyonecanspend" substitution attacks.

## Recursion caveat

- Hash-based (CTV-style) covenants aren't recursive except via provably-deleted keys;
  APO's SIGHASH_SINGLE modes enable more "spooky" recursive constructions.
