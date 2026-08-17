---
title: Notes Index
type: raw-index
created: 2026-07-18
updated: 2026-08-16
---

# Notes

Session-derived lessons-learned and working notes (learned by doing/analyzing, not ingested from external sources).

| Note | Date | Lessons | Summary |
|---|---|---|---|
| [[2026-07-18-ll-proxy-held-vtxo-ark-sv2-extension|Proxy-held VTXO keys + SV2 Ark-claim extension]] | 2026-07-18 | 4 | Proxy holding VTXO keys neutralizes Ark's receiver-presence + expiry blockers (unlocks clArk sans CTV/CSFS) but reshuffles custody; a trust-reducing SV2 claim extension must carry VTXO leaf/path + exclusivity proof, not just the amount. |
| [[2026-07-30-ll-pplns-window-units-and-identity-boundaries\|PPLNS window units, share retention, identity boundaries]] | 2026-07-30 | 6 | `N = 8 × D` is accumulated share difficulty, not 8 blocks — a ~100× retention error for a 1% pool (~5.5 days, not ~80 min). Upward difficulty retargets grow the window *backwards*, so retention must cover `4 × N`. Distinct payout identity = distinct user, even on one connection. Translator `Aggregated` mode makes per-device identity structurally unrepresentable. |
| [[2026-08-14-ll-coinbase-silent-payments-ecdh-nonce\|Coinbase silent payments — the blocker is the sender pubkey, not the outpoint]] | 2026-08-14 | 8 | BIP 352's coinbase exclusion is an *absent sender pubkey `A`*, not an absent nonce — BIP 34 mandates the block height, a better nonce than `outpoint_L`. BIP 44's gap limit binds a BIP 32 child index, never an ECDH nonce, so height-as-index is fatal for descriptors and free for stealth derivation. Outputs can never supply a nonce (structurally circular; outpoints are the only consensus-unique identifier at derivation time). Extranonce ruled out — rolling it would rebuild the template. Reusing the pool's fee output as `A` costs 0 bytes but forecloses forward secrecy permanently. BIP 352 also fuses the sender's ECDH key with its signing key (`:244`) because `A` must be reconstructable from chain data; splitting them is sound math but cannot be derived (linear ⇒ `a` unlocks it, non-linear ⇒ nobody knows the dlog), so it costs transmitted bytes — and a pool's stratum session is the out-of-band channel that makes those bytes free on-chain. |
| [[2026-08-16-ll-sv2-pool-tag-asend-carrier\|Carrying a rotating A_send in the SV2 coinbase pool tag]] | 2026-08-16 | 6 | Two carrier designs died on the same requirement (`a_send` must authorize nothing and be destroyable) by unrelated mechanisms: a bare 1-of-2 multisig makes it *sufficient* to spend the pool's fee (`m = 2` inverts it, making it un-erasable — no `m` works), and BIP 32 unhardened derivation is algebraically the group-linear list already proven fatal, so the rotation branch's plumbing ports but `XpubDerivator` must not. Rotation cadence turns out to be a forward-secrecy knob, not a correctness requirement, since the height is already bound into the shared secret. The SV2 pool tag is a real field but a UTF-8 `String`: budget is `pool_len ≤ 64` (hex x-only = exactly 64, zero slack; compressed hex fails; bech32 52, base64url 43 — standard base64 disqualified, `/` is the delimiter), and extranonce-disjointness is enforced by the wire format rather than by discipline. Byte budgets need the spec for ceilings *and* pinned local source for allocations — `FULL_EXTRANONCE_SIZE = 20` exists only in code. |

## Cross-domain source notes (2026-07-29)

Primary-text reads on non-mining material, kept here because they have no natural `papers`/`repos`/`articles` home.

- [[2026-07-29-self-blinding-system-architectures|Self-blinding system architectures — OHTTP, split-trust relays, multi-vendor TEEs, Prio/DAP]] — 8-row transferability ranking with the trust each substitutes in; the Prio framing correction (population totals vs. exact per-recipient totals); SGAxe/ÆPIC/CVM-SoK on why attestation is weaker than advertised; PCC's log-gated key wrapping as the most transferable mechanism
- [[2026-07-29-fincen-td10000-regulatory-attribution-posture|Regulatory posture on pool attribution — FinCEN, TD 10000, OFAC, compulsion]] — §5.4 exempts pool distributions unless the operator hosts wallets; §4.5.1(a)/(b) make anonymizing transmitters ineligible and blinding a Travel Rule violation; TD 10000's validator carve-out never says "mining pool"; Lavabit and the untested warrant canary
