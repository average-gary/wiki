---
title: "NIP-06: Basic Key Derivation from Mnemonic Seed Phrase (unrecommended)"
url: https://github.com/nostr-protocol/nips/blob/master/06.md
retrieved: 2026-06-02
type: spec
---

NIP-06 specifies BIP39 mnemonic seed words and BIP32 derivation at path `m/44'/1237'/<account>'/0/0` (1237 is the SLIP44 entry for Nostr) to produce a Nostr secp256k1 private key. Originally pitched as a way to share one seed phrase across many Nostr keys (one per `account` index), it is now flagged in the canonical NIPs repo with the warning: `"unrecommended": prefer a single nsec`.

The README repeats the same guidance under its "unrecommended NIPs" section. The implicit rationale is that a mnemonic-derived key buys nothing on Nostr that a single freshly generated nsec does not also provide: there is no notion of HD addresses on Nostr, no rotation primitive that uses the derivation, and no recovery semantics tied to the seed. Worse, it gives users a false sense that "their seed phrase will save them" the way it does in Bitcoin wallets, which is not true if the resulting nsec is leaked.
