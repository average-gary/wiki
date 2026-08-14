---
title: "Temporary seeds and Seed Vault"
category: concept
sources:
  - raw/articles/2026-08-10-coldcard-temporary-seeds.md
  - raw/articles/2026-08-10-coldcard-security-model.md
  - raw/articles/2026-08-10-coldcard-release-history-mk4-mk5.md
  - raw/articles/2026-08-10-coldcard-release-history-q.md
  - raw/articles/2026-08-10-coldcard-menu-tree.md
created: 2026-08-10
updated: 2026-08-10
tags: [coldcard, temporary-seed, ephemeral-seed, seed-vault, bip-39-passphrase, bip-85, tapsigner, ram-only]
aliases: ["ephemeral seed", "Seed Vault", "Restore Master"]
confidence: medium
volatility: cold
verified: 2026-08-10
summary: "A temporary seed is a secret held in RAM, separate from the master seed in SE2 and normally not persisted across reboots. Coinkite states plainly that temporary seeds *completely* defeat the secure-element security model and are meant for one-off use. Seed Vault stores them longer-term, AES-256-CTR encrypted under the master seed's key. Requires Mk4/Mk5/Q; introduced 5.0.7, renamed 5.2.0."
---

# Temporary seeds and Seed Vault

> The doc does not hedge: temporary seeds *"completely defeat the design of Coldcard's security model,
> based on secure elements."* That sentence is Coinkite's, not a critic's. Everything else about this
> feature has to be read against it.

The feature exists because the alternative is worse — people need to recover a seed from another
system, or check a balance, and doing so on a general-purpose computer is more dangerous than doing
it in RAM on a Coldcard. But the warning is real: the secret lives outside the secure element while
in use.

Introduced as **Ephemeral Seed** in **5.0.7**, renamed **Temporary Seed** in **5.2.0**. Requires
**Mk4, Mk5 or Q** — not available on Mk1–Mk3.

## What "temporary" means

- The secret is held in **device RAM**, not written to the secure element.
- It is **not persisted between reboots** — unless you save it to the Seed Vault.
- While one is active, the **first home-menu item is `[<xfp>]`**, showing the temporary secret's
  fingerprint, and acts as a clone of `Ready To Sign`. That indicator is the only thing preventing you
  from mistaking which wallet you are signing with.

Availability does not depend on device state: you can use a temporary seed on a brand-new device with
no PIN and no secret, on one with a PIN but no secret, and on a fully configured device.

## Every route in

The doc enumerates them, and the breadth is the point — almost every seed-import path can land in a
temporary seed rather than the master slot:

| Route | Menu path |
|-------|-----------|
| TRNG generation | `Advanced/Tools > Temporary Seed > Generate Words` |
| Word import | `Advanced/Tools > Temporary Seed > Import Words` |
| XPRV import | `Advanced/Tools > Temporary Seed > Import XPRV` |
| Tapsigner backup | `Advanced/Tools > Temporary Seed > Tapsigner Backup` |
| BIP-85 derived | `Advanced/Tools > Derive Seed B85` → pick 12/18/24 words or XPRV → pick index → press `(0)` |
| Duress wallet | `Settings > Login Settings > Trick PINs` → select the trick PIN → `Activate Wallet` |
| Seed XOR restore | `Advanced/Tools > Danger Zone > Seed Functions > SeedXOR > Restore Seed XOR` → press `(2)` |
| Dice rolls | via the seed-generation path |

Only **word-based and XPRV-based** BIP-85 secrets can serve as temporary seeds — a BIP-85 password or
WIF cannot.

## The BIP-39 passphrase is a temporary seed

From **5.2.0** the BIP-39 passphrase is *internally implemented* as a temporary seed. This is the most
consequential detail in the article, because passphrase use is routine for many owners:

- It unifies the code path, so passphrase wallets get Seed Vault, per-wallet settings and the `[xfp]`
  indicator.
- It also means the warning above applies to passphrase wallets: while a passphrase wallet is active,
  its secret is derived and held like any other temporary seed.

The default backup behaviour reflects this split — with a passphrase active, a backup captures the
**main** wallet unless you opt in (5.2.0+); with an ephemeral seed active, the backup captures the
**ephemeral** wallet instead. See
[[encrypted-backup-and-transfer|Encrypted backup and transfer]]
([Encrypted backup and transfer](encrypted-backup-and-transfer.md)).

## Restore Master

Before **5.2.0** returning to the master seed meant a reboot. From 5.2.0 the last home-menu item is
`Restore Master`, with two outcomes:

- **OK** — wipe the temporary seed's settings and switch back to master.
- **`(1)`** — **preserve** the temporary seed's settings for later, and switch back.

If the active temporary seed is also in the Seed Vault, the wipe option is withheld; vault entries are
deleted only from the vault menu.

## Seed Vault

New in **5.2.0**, Mk4/Mk5/Q. It stores multiple temporary secrets in the device's encrypted settings —
**AES-256-CTR encrypted with your master seed's key** — for recall without re-entry. Any temporary
seed source can be captured: TRNG, dice rolls, Seed XOR, TAPSIGNER backups, BIP-85 values, BIP-39
passphrase wallets.

Enable at `Advanced/Tools > Danger Zone > Seed Vault > Enable`; a `Seed Vault` item then appears in
the home menu. To disable it you must first remove every entry.

Note the structural consequence of that encryption choice: **vault entries are bound to the master
seed**. Wipe or replace the master and the vault is unrecoverable. The vault is a convenience layer
over the master secret, not an independent store.

### Vault mechanics

- After creating a temporary seed you are prompted: press `(1)` to save, anything else to skip.
- Empty vault shows `(none saved yet)` plus a shortcut to the Temporary Seed menu.
- Saved seeds list as `[xfp]`; the active one carries a checkmark; `Restore Master` is the last item
  when a temporary seed is active.
- Per-entry submenu: the label (renameable, 40 characters max), `Use This Seed` (or `In Use`),
  `Rename`, and `Delete` (optionally wiping that seed's settings too).

## What this buys, and what it costs

**Buys:** many wallets on one device without many PINs; recovery of foreign seeds without a computer;
BIP-85 child wallets on demand; a place for the duress wallet to be inspected safely.

**Costs, stated plainly:**

- The secure-element protection does not apply to the active temporary secret.
- Vault contents depend on the master seed's continued existence.
- The `[xfp]` indicator is the only guard against signing with the wrong wallet.
- Coinkite's own recommendation is against routine use: *"We do not recommend handling unencrypted
  seed material on a regular basis!"*

Note also that the security model's "admitted limits" list names temporary seeds explicitly as a case
where the architecture's guarantees do not hold — see
[[security-architecture|Security architecture]]
([Security architecture](../topics/security-architecture.md)).

## Documentation defect

Three links in this source point at `docs/upgrade.md`, which **does not exist** in the repository at
revision `43b2139`. They are the "new in v5.0.7 / v5.2.0, requires Mk4, Mk5, or Q" annotations, so the
version and model gating is stated in the link text and survives; only the destinations are dead. This
was preserved rather than repaired during ingest.

## Evidence status

`confidence: medium`. The menu paths, version gates and vault mechanics are first-party and specific.
The security *characterisation* — that temporary seeds defeat the secure-element model — is also
first-party, and is the rare case where the vendor's claim is against its own interest, which makes it
more credible rather than less. Not documented here: exactly what remains in RAM after `Restore
Master`, or whether a power-cut mid-session can leave temporary secret material recoverable.

## See Also

- [[security-architecture|Security architecture]] ([Security architecture](../topics/security-architecture.md)) — the model this feature deliberately steps outside of
- [[seed-generation-and-derivation|Seed generation and derivation]] ([Seed generation and derivation](seed-generation-and-derivation.md)) — TRNG, dice, BIP-39 passphrase, BIP-85 indices
- [[trick-pins-and-duress-wallets|Trick PINs and duress wallets]] ([Trick PINs and duress wallets](trick-pins-and-duress-wallets.md)) — activating a duress wallet as a temporary seed
- [[seed-xor|Seed XOR]] ([Seed XOR](seed-xor.md)) — restoring a split as a temporary seed
- [[encrypted-backup-and-transfer|Encrypted backup and transfer]] ([Encrypted backup and transfer](encrypted-backup-and-transfer.md)) — how an active temporary seed changes what a backup contains; Key Teleport delivers into the vault
- [[entropy-advisory-2026|The 2026 entropy advisory]] ([The 2026 entropy advisory](entropy-advisory-2026.md)) — TRNG-generated temporary seeds are in scope
- [[coldcard-overview|COLDCARD — overview]] ([COLDCARD — overview](../topics/coldcard-overview.md)) — product context
- [[model-and-version-matrix|Model and version matrix]] ([Model and version matrix](../references/model-and-version-matrix.md)) — Mk4/Mk5/Q gating
- [[release-timeline|Release timeline]] ([Release timeline](../references/release-timeline.md)) — 5.0.7 introduction, 5.2.0 rename and vault
- [[spending-policy-and-two-factor|Spending Policy and two-factor]] ([Spending Policy and two-factor](spending-policy-and-two-factor.md)) — Related Keys, read-only vault, ephemeral-seed exclusion

## Sources

- [Temporary seeds](../../raw/articles/2026-08-10-coldcard-temporary-seeds.md) — the defeats-the-model statement, every activation route, Restore Master, full Seed Vault mechanics
- [Security model](../../raw/articles/2026-08-10-coldcard-security-model.md) — temporary seeds in the admitted-limits list
- [Mk4/Mk5 release history](../../raw/articles/2026-08-10-coldcard-release-history-mk4-mk5.md) — 5.0.7 ephemeral seeds, 5.2.0 rename, vault and passphrase-as-temporary-seed
- [Q release history](../../raw/articles/2026-08-10-coldcard-release-history-q.md) — Q-line parity
- [Menu tree](../../raw/articles/2026-08-10-coldcard-menu-tree.md) — `[IF SECRET AND NOT TMP SEED]` guards and vault menu placement
