---
title: "Trick PINs and duress wallets"
category: concept
sources:
  - raw/articles/2026-08-10-coldcard-secure-elements.md
  - raw/articles/2026-08-10-coldcard-security-model.md
  - raw/articles/2026-08-10-coldcard-menu-tree.md
  - raw/articles/2026-08-10-coldcard-release-history-mk4-mk5.md
  - raw/articles/2026-08-10-coldcard-release-history-q.md
created: 2026-08-10
updated: 2026-08-10
tags: [coldcard, trick-pins, duress-wallet, delta-mode, coercion, bip-85, brick-me, plausible-deniability]
aliases: ["duress PIN", "Delta Mode", "brick me PIN", "Coldcard trick PIN"]
confidence: medium
volatility: cold
verified: 2026-08-10
summary: "Alternate PINs stored on SE2 that do something other than unlock the real wallet: open a BIP-85-derived duress wallet, wipe the seed, brick the device, count down, or enter Delta Mode where the attacker appears to be logged in while the seed stays sealed. Covers slot accounting, the BIP-85 duress indices, Delta Mode's mechanics, and the deniability limits."
---

# Trick PINs and duress wallets

> Every other layer of the Coldcard's defences assumes the attacker does not have you. Trick PINs
> assume they do. The design goal is not secrecy but **a plausible response under coercion** — a PIN
> you can hand over that produces something the attacker will accept.

## The menu of behaviours

Trick PINs are configured under `Settings > Login Settings > Trick PINs` and stored on SE2, not on
the MCU — so they survive a firmware reflash and cannot be read out of MCU flash. The documented
options:

| Behaviour | Effect |
|-----------|--------|
| **Duress Wallet** | Unlocks a real, spendable, BIP-85-derived wallet that is not your main seed |
| **Brick Self** | Destroys the SE1 pairing secret; device becomes e-waste in ~50ms |
| **Wipe Seed** | Erases the seed via Fast Wipe, then a chosen follow-up |
| **Wipe → Duress** | Wipes the real seed, then presents the duress wallet |
| **Wipe → Reboot** | Wipes and reboots, looking like a fresh device |
| **Look Blank** | Device claims to be un-initialised |
| **Login Countdown** | Starts a countdown; optionally wipes or bricks at the end |
| **Delta Mode** | Appears logged in to the real wallet, but is not |
| **Just Reboot** | Reboots without comment |

There is also an "after N wrong PINs" trigger: the menu-tree example `WRONG PIN → After 3 wrong:
Wipes seed / Reboots`. The `11-11 → Bricks CC` and `333-3334 → Duress Wallet` entries in the menu
tree are illustrative examples, not defaults.

## Duress wallets are BIP-85 children

A duress wallet is not a second random seed. It is derived from your **real** seed via BIP-85 at
reserved indices, which is what makes it reproducible and backup-recoverable:

| Words | Reserved BIP-85 indices |
|-------|------------------------|
| 24 | 1001, 1002, 1003 |
| 12 | 2001, 2002, 2003 |

Three of each, so up to three duress wallets per word length. The consequence worth internalising:
**a duress wallet is only as good as the master seed it derives from**, so a seed generated on
firmware affected by the entropy advisory yields duress wallets with the same problem. See
[[entropy-advisory-2026|The 2026 entropy advisory]]
([The 2026 entropy advisory](entropy-advisory-2026.md)).

A **legacy** duress path also exists for compatibility with pre-Mk4 devices: a 72-byte duress secret
addressed at `m/2147431408'/0'/0'`. That prefix is not arbitrary —
`2147431408 = 0x80000000 - 0xCC10`, i.e. `0xCC10` ("CC" for Coldcard) counted back from the top of
the hardened range. Legacy duress consumes **3** SE2 slots rather than 2.

## Delta Mode

The cleverest and most fragile option. You configure a PIN that differs from your real PIN in its
last few digits. Entering it appears to log you into the real wallet — the real balance, the real
addresses, the real menus. But:

- The **seed is never decrypted**; the device operates against a hobbled state.
- Signing produces **garbage signatures** that will not verify, so a coerced "sign this" produces a
  transaction that never confirms.
- Any attempt to **view the seed words**, or to open the **Trick PINs menu**, **immediately wipes
  the seed and bricks or reboots** — the two actions that would expose the deception are exactly the
  ones that trigger destruction.

Mechanically, SE2 stores which digits were substituted. Trick PIN slots keep the PIN hash on even
pages and its secret on odd pages, and the low bits of the stored value are masked off and reused as
`tc_arg` and `tc_flags`; Delta Mode records the **four substituted digits** in `tc_arg`. See
[[dual-secure-element-design|Dual secure-element design]]
([Dual secure-element design](dual-secure-element-design.md)).

Delta Mode's weakness is stated in the docs rather than hidden: a sophisticated attacker who knows
the feature exists can look for the tells, and the mode is only convincing for as long as the
attacker does not ask for something Delta Mode cannot fake.

## Slot accounting

This matters because it is a hard ceiling on how many tricks you can configure:

- SE2 has **14** Trick PIN slots.
- **Mk4 avoids slot 10**, leaving **13** usable. Q has all 14.
- A **duress wallet consumes 2 contiguous slots** (3 for the legacy layout).
- Alongside the trick slots SE2 holds 3 × 72-byte spare secrets and one 416-byte long secret.

A documented consequence: devices with **7 or more Trick PINs** configured hit a lockout condition,
with bootrom 3.1.5 (shipped alongside 5.0.7) noted as the fix and a workaround described in that
release's notes.

## Ordering during login

The evaluation order at login is load-bearing:

1. **brick-me PIN** — checked first, before any other trick and before the real PIN, with **no
   delay**, so a coerced user can destroy the device faster than an observer can stop them.
2. duress PINs.
3. increment the attempt counter.
4. the real PIN.

See [[pin-entry-and-rate-limiting|PIN entry and rate limiting]]
([PIN entry and rate limiting](pin-entry-and-rate-limiting.md)).

## Related destructive controls

- **Kill Key** — off by default; a single keypress during login wipes the seed. On Q any letter can
  be assigned and it stays live for the whole login.
- **Nuke Device** — added in 5.5.0/1.4.0Q under Danger Zone; a deliberate, menu-driven destruction
  rather than a coercion response.
- **`Destroy Seed`** — from 5.4.2/1.3.2Q this **also removes all Trick PINs from SE2**. Before that
  change, destroying the seed could leave trick configuration behind.

## Version-gated behaviour worth knowing

| Version | Change |
|---------|--------|
| 4.0.2 (Mk3) | Countdown and Brick; countdown survives power-off |
| 5.0.0 | Power-down during countdown resets the timer |
| 5.0.7 | 7+-trick-PIN lockout addressed with bootrom 3.1.5 |
| 5.4.2 / 1.3.2Q | `Destroy Seed` clears Trick PINs from SE2 |
| 1.3.4Q | "Forever calculator" mode after 13 failures, always enabled on Q |
| 5.5.1 / 1.4.1Q | Fixed: **a Delta Mode Trick PIN was never restored from backup** |

That last entry is a real caveat for anyone who set up Delta Mode before mid-2026 and relied on a
backup to carry it: it did not.

## Deniability limits

Stated plainly, because the docs are honest about it and a wiki should be too:

- Trick PINs live on SE2 and are **detectable in principle** by someone who knows the architecture;
  the security model's own "admitted limits" acknowledge deniability is limited.
- Delta Mode collapses the moment the attacker asks for the seed words or the Trick PIN menu — by
  design, but that means the exit is destruction, not escape.
- A duress wallet needs a **plausible balance**. An empty duress wallet is not a convincing answer.
- Bricking protects the coins, not the person. The threat model here ends where physical coercion
  continues.

## Evidence status

`confidence: medium`. All of this is Coinkite's description of its own coercion-response features.
The mechanics (BIP-85 indices, slot counts, `tc_arg` masking) are specific and internally consistent
across `docs/trick-pins.md`, `docs/secure-elements.md` and the changelogs; the *effectiveness*
claims — that Delta Mode is convincing, that deniability holds — are inherently untestable from
documentation and are not audited here.

## See Also

- [[pin-entry-and-rate-limiting|PIN entry and rate limiting]] ([PIN entry and rate limiting](pin-entry-and-rate-limiting.md)) — the login sequence these PINs are evaluated in
- [[dual-secure-element-design|Dual secure-element design]] ([Dual secure-element design](dual-secure-element-design.md)) — SE2 slot layout, `tc_arg`/`tc_flags`, Fast Wipe and Fast Brick
- [[security-architecture|Security architecture]] ([Security architecture](../topics/security-architecture.md)) — coercion as an axis separate from the four defence layers
- [[seed-generation-and-derivation|Seed generation and derivation]] ([Seed generation and derivation](seed-generation-and-derivation.md)) — BIP-85 and the reserved index ranges
- [[entropy-advisory-2026|The 2026 entropy advisory]] ([The 2026 entropy advisory](entropy-advisory-2026.md)) — duress wallets inherit a tainted master seed
- [[temporary-seeds-and-seed-vault|Temporary seeds and Seed Vault]] ([Temporary seeds and Seed Vault](temporary-seeds-and-seed-vault.md)) — the non-coercive way to run more than one wallet
- [[encrypted-backup-and-transfer|Encrypted backup and transfer]] ([Encrypted backup and transfer](encrypted-backup-and-transfer.md)) — what a backup does and does not carry
- [[coldcard-overview|COLDCARD — overview]] ([COLDCARD — overview](../topics/coldcard-overview.md)) — product context
- [[release-timeline|Release timeline]] ([Release timeline](../references/release-timeline.md)) — when each trick landed
- [[device-limits|Device limits]] ([Device limits](../references/device-limits.md)) — slot accounting and restore behaviour
- [[memory-map-and-key-slots|Memory map and key slots]] ([Memory map and key slots](../references/memory-map-and-key-slots.md)) — the SE2 pages the slots occupy
- [[model-and-version-matrix|Model and version matrix]] ([Model and version matrix](../references/model-and-version-matrix.md)) — 13 slots on Mk4 versus 14 on Q; Kill Key differences
- [[seed-xor|Seed XOR]] ([Seed XOR](seed-xor.md)) — a different, non-coercive deniability story
- [[spending-policy-and-two-factor|Spending Policy and two-factor]] ([Spending Policy and two-factor](spending-policy-and-two-factor.md)) — `Unlock Policy & Wipe` and false bypass PINs

## Sources

- [Secure elements](../../raw/articles/2026-08-10-coldcard-secure-elements.md) — SE2 slot layout, even/odd page scheme, `tc_arg`/`tc_flags` masking, Delta Mode digit substitution
- [Security model](../../raw/articles/2026-08-10-coldcard-security-model.md) — the behaviour menu, BIP-85 duress indices, legacy duress path, Delta Mode rationale, brick-me ordering, Kill Key, admitted deniability limits
- [Menu tree](../../raw/articles/2026-08-10-coldcard-menu-tree.md) — Trick PIN menu entries and example configurations
- [Mk4/Mk5 release history](../../raw/articles/2026-08-10-coldcard-release-history-mk4-mk5.md) — 5.0.7 lockout, 5.4.2 Destroy Seed, 5.5.1 Delta Mode backup fix, Nuke Device
- [Q release history](../../raw/articles/2026-08-10-coldcard-release-history-q.md) — forever calculator mode, Q slot count
