---
title: "Spending Policy and two-factor"
category: concept
sources:
  - raw/articles/2026-08-10-coldcard-spending-policy.md
  - raw/articles/2026-08-10-coldcard-web2fa.md
  - raw/articles/2026-08-10-coldcard-microsd-2fa.md
  - raw/articles/2026-08-10-coldcard-release-history-mk4-mk5.md
  - raw/articles/2026-08-10-coldcard-release-history-q.md
  - raw/articles/2026-08-10-coldcard-menu-tree.md
created: 2026-08-10
updated: 2026-08-10
tags: [coldcard, spending-policy, ccc, web2fa, totp, microsd-2fa, bypass-pin, velocity, whitelist, money-manager]
aliases: ["CCC", "Co-Sign Multisig", "Bypass PIN", "Web2FA", "MicroSD 2FA"]
confidence: medium
volatility: cold
verified: 2026-08-10
summary: "Spending Policy makes the Coldcard refuse to sign outside limits set in advance — magnitude, velocity, a 25-address whitelist — and disables most of the device while active. Two second factors bolt on: Web2FA, which solves TOTP without a real-time clock by trusting a Coinkite server, and MicroSD 2FA, which wipes the seed if the enrolled card is absent. Covers the Bypass PIN, the multisig CCC variant, Money Manager Mode, and the trust costs."
---

# Spending Policy and two-factor

> Most of this wiki is about stopping someone else from spending your coins. Spending Policy is about
> stopping **the device itself** from signing outside limits you set while you still had full control —
> and then locking the device down so those limits cannot be edited. Coinkite's suggested use case is
> travelling with a Coldcard.

## Two modes

| Mode | What it is | Introduced |
|------|-----------|------------|
| **Single-Signer** | The device refuses to sign transactions violating the policy | 5.4.4 / 1.3.4Q |
| **Multisig** (formerly **CCC**, renamed **Co-Sign Multisig**) | The Coldcard is one co-signer that signs only when the policy is met; other signers decide independently | 5.4.2 / 1.3.2Q |

Both can be active at once. If a transaction would be signed under the multisig policy, Coinkite
assumes it is acceptable for the main key too. The multisig mode needs multisig addresses, new UTXOs
and cooperating on-chain wallets — a bigger commitment than the single-signer mode.

Naming history matters when reading the changelogs: **CCC** appears in 5.4.2/1.3.2Q, and 5.4.4
renamed it to **Co-Sign Multisig** while adding the single-signer variant.

## What a live policy costs you

Enabling a policy is not a soft setting. While it is in effect:

- **Firmware updates are blocked.**
- **There is no way to back up the Coldcard.**
- **Seed Vault and Secure Notes are read-only** (and can be hidden).
- **The Settings menu is inaccessible.**
- **BIP-39 passphrases may be blocked** (optional, via the Related Keys switch).

Hence the documented advice: fully configure the device *before* activating. This is the rare Coldcard
feature where the setup order is load-bearing.

## The Bypass PIN

Defined during setup, before the policy itself. It is **the only way to disable the policy once
enabled** — the docs say "don't loose it" [sic]. Disabling requires the Bypass PIN, then the normal
main PIN, then optionally the first and last seed words (the **Word Check** switch).

If you forget it, the only route out is `Advanced > Destroy Seed`, which erases the master seed, all
settings, Seed Vault entries, Secure Notes and Trick PINs — a factory reset that leaves the main PIN
unchanged. You then restore from backup. That is a genuine recovery path, but an expensive one.

## The policy itself

`Advanced/Tools > Spending Policy > Single-Signer > Edit Policy...`:

| Control | Meaning |
|---------|---------|
| **Max Magnitude** | maximum BTC per transaction |
| **Velocity** | minimum time gap between signed transactions |
| **Whitelist** | up to **25** destination addresses; empty means any address |
| **Web2FA** | enrol a phone; an authenticator code is required before signing |

Supporting switches: **Word Check** (first and last seed word after the Bypass PIN), **Allow Notes**
(Q; notes visible or hidden, read-only either way), **Related Keys** (BIP-39 passphrase entry and Seed
Vault use blocked unless enabled — and the vault is read-only regardless). See
[[temporary-seeds-and-seed-vault|Temporary seeds and Seed Vault]]
([Temporary seeds and Seed Vault](temporary-seeds-and-seed-vault.md)).

Other menu items: **Last Violation** (terse debugging record of the most recent rejection, clearable,
shown only if a violation occurred since the last valid signing), **Remove Policy**, **Test Drive**
(experiment with the locked-down mode without rebooting; `EXIT TEST DRIVE` or a reboot returns to
normal), and **ACTIVATE**.

## Web2FA

The interesting engineering problem: RFC 6238 TOTP needs the current time, and the Coldcard has **no
real-time clock**. The solution trades a clock for a trusted server.

1. Enrolment happens **on the device**, which picks the Base32 shared secret using **the same TRNG
   process as picking a seed** and shows a QR for the phone app.
2. At signing time the device builds a URL whose query string is **encrypted to the server's public
   key** (the server's pubkey ships in Coldcard firmware releases; the private key is company-secret).
   The payload carries `g` (the response nonce), `ss` (16 Base32 chars of shared secret), `nm` (a
   human-readable label) and `q` (Q-model flag).
3. Encryption is plain ECDH: the device picks a secp256k1 keypair, multiplies by the server pubkey,
   takes `sha256(coordinate)` as session key, applies **AES-256-CTR** over the ASCII URL contents,
   prepends the 33-byte compressed pubkey and base64url-encodes the lot →
   `https://coldcard.com/2fa?{base64}`.
4. The user reaches the URL by **NFC tap**, sees the label (which itself proves the server could
   decrypt), enters 6 digits from the authenticator app, and the server does the RFC 6238 check
   against real time.
5. On success the server reveals the nonce: an **8-digit code to type on Mk4**, or a **QR to scan on
   Q** (32 bytes / 64 hex chars).
6. The device accepts only that exact nonce.

Rate limiting is server-side: **one attempt per 30-second period**, with very recent responses stored
so an attacker cannot harvest two codes in one window, and the user is stuck on the page until a valid
code is supplied.

### The trust cost, stated by Coinkite

The doc's own "Trust Issues" section is refreshingly direct, and this article does not soften it:

- The server **learns the shared secret** during operation. "We won't store it [sorry, gotta trust us
  on that, but no help to us to store it]."
- **Only Coinkite can run the server**, because the private key is company-secret. There is no
  self-hosted option.
- **The server could skip the 2FA check entirely** and simply hand you the nonce. "Again, you have to
  trust us on that."

So Web2FA is a genuine second factor against a thief holding your device, and *not* a control that
holds if Coinkite's server is compromised or coerced. For a company whose product is otherwise built
to require trusting nobody, this is the sharpest exception in the collection, and it is documented
rather than hidden. Contrast the HSM feature's **HOTP** tokens, which need no backend but are, in
Coinkite's words, "not as robust as time-based tokens".

## MicroSD 2FA

A second factor with no server at all, introduced in **5.1.0**. Once enabled, an **enrolled MicroSD
card must be present at login** — and if the slot is empty or holds an unknown card **after the
correct PIN is entered, the seed is wiped**. That inversion is the point: the failure mode is
destruction, not refusal.

Mechanics:

- Enrolment writes a small encrypted file to the card.
- At login the master secret builds an **AES key** that decrypts it; if the plaintext is JSON
  containing a nonce on the acceptable list, login proceeds.
- The AES key incorporates **both the master secret and a hash of the card's unique serial number**,
  read via low-level protocols — so **copying the file to another card does not work**.
- The filename derives from a hash of the **Coldcard's** serial number, so one card can carry several
  `.2fa` files and unlock several devices. The name begins with a dot, so tools may hide it;
  reformatting removes it.
- On Q with both slots populated, the enrolled card must be in **slot A** (top).
- `Settings > Login Settings > MicroSD 2FA` → `Add Card`, then `Check Card` and `Remove Card #N`.
  Removing the last card disables the feature. You do **not** need the card in hand to remove it.
- **Cannot be used with ephemeral seeds**, because that secret is not in effect at boot time.

### Duress use

The recommended pattern is deliberately passive: **keep no card in the device**. Then an attacker — or
you under duress — logs in normally and triggers the wipe without any visible action. Supporting
details: nothing on screen during a *successful* login reveals the feature is active, so an observer
cannot tell whether the card was needed; if forced to prepare a PSBT you can choose an unenrolled
card, or clear the special file; and enrolled cards can be stored offsite (a safety deposit box is
fine — the card holds no sensitive data).

The docs also note the checks run in Delta Mode and for duress wallets, since settings are encrypted
by whichever secret the device believes is in play, while observing that if you are relying on the
wipe there is little reason for Delta Mode as well.

## Money Manager Mode

The most interesting application, and it is Coinkite's own suggestion: configure a Coldcard for a
family member with Web2FA enabled and no other limits (velocity unlimited). **You** enrol *your* phone
and keep both the 2FA secret and the Bypass PIN confidential. The holder must phone you for a 6-digit
code to spend — easy over voice. Because a policy is in effect they cannot view seed words or export
private key material, so phishing or spoofing cannot move funds without you.

The estate-planning note is worth repeating: record the Bypass PIN so it can be revealed on your
death, without sharing the risks of holding the seed words.

## Interaction with Trick PINs

The docs reason from a specific and pessimistic premise: **assume the attacker already has your main
PIN** — that is how they know they cannot spend everything, and they already have your UTXOs and total
balance because they can export XPUBs to any wallet. Consequences:

- **A duress wallet after giving up the bypass PIN will not fool them.** Better: give a false bypass
  PIN that is actually a **brick/wipe** PIN.
- **`Unlock Policy & Wipe`** is a purpose-built Trick PIN that mimics the policy-unlock sequence and
  wipes the seed. The attacker *will* notice — the main PIN then leads to a blank wallet.
- **Delta Mode composes**: if the attacker has your Delta Mode PIN and then bypasses the policy, they
  are still in Delta Mode. Unlimited spending attempts produce invalid signatures, and attempts to
  view seed words hit the wipe cases.
- **Locking out policy changes**: the Bypass PIN appears in the Trick PIN menu once the policy is
  enabled. *Deleting* it makes policy changes impossible (hiding it is pointless — you cannot reach
  that menu while the policy is live). Recovery from regret is `Destroy Seed`.

See [[trick-pins-and-duress-wallets|Trick PINs and duress wallets]]
([Trick PINs and duress wallets](trick-pins-and-duress-wallets.md)).

## Passphrase considerations

If you use one BIP-39 passphrase for everything, the docs recommend **`Lock Down Seed`** first
(`Advanced/Tools > Danger Zone > Seed Functions`): it cooks the master seed and the passphrase together
into an XPRV and stores *that* as the master secret, **irreversibly**. Other funds on the same words
are then protected, and the policy is confined to that wallet. In XPRV mode the `Passphrase` menu item
disappears, since BIP-39 passwords cannot apply to an XPRV secret.

## Evidence status

`confidence: medium`. Menu paths, limits and version gates are first-party and specific. The Web2FA
trust analysis above is Coinkite's own and is quoted rather than paraphrased, because the admission is
the substance. What is not verified anywhere in these sources: that the server behaves as described,
that the policy is enforced in the signing path rather than only in the UI, or that the velocity and
magnitude checks resist a crafted PSBT.

## See Also

- [[trick-pins-and-duress-wallets|Trick PINs and duress wallets]] ([Trick PINs and duress wallets](trick-pins-and-duress-wallets.md)) — Unlock Policy & Wipe, false bypass PINs, Delta Mode composition
- [[airgap-signing-workflows|Air-gapped signing workflows]] ([Air-gapped signing workflows](../topics/airgap-signing-workflows.md)) — what changes when the device signs under policy
- [[security-architecture|Security architecture]] ([Security architecture](../topics/security-architecture.md)) — Web2FA server trust in the admitted-limits list
- [[connectivity-and-nfc|Connectivity and NFC]] ([Connectivity and NFC](connectivity-and-nfc.md)) — the NFC tap that carries the 2FA URL
- [[temporary-seeds-and-seed-vault|Temporary seeds and Seed Vault]] ([Temporary seeds and Seed Vault](temporary-seeds-and-seed-vault.md)) — Related Keys, read-only vault, ephemeral-seed exclusion
- [[pin-entry-and-rate-limiting|PIN entry and rate limiting]] ([PIN entry and rate limiting](pin-entry-and-rate-limiting.md)) — the login sequence MicroSD 2FA hooks into
- [[seed-generation-and-derivation|Seed generation and derivation]] ([Seed generation and derivation](seed-generation-and-derivation.md)) — `Lock Down Seed` and XPRV mode
- [[coldcard-overview|COLDCARD — overview]] ([COLDCARD — overview](../topics/coldcard-overview.md)) — product context
- [[release-timeline|Release timeline]] ([Release timeline](../references/release-timeline.md)) — 5.1.0 MicroSD 2FA, 5.4.2 CCC, 5.4.4 single-signer policy
- [[device-limits|Device limits]] ([Device limits](../references/device-limits.md)) — the 25-address whitelist and other ceilings
- [[firmware-authenticity-and-upgrades|Firmware authenticity and upgrades]] ([Firmware authenticity and upgrades](firmware-authenticity-and-upgrades.md)) — an active policy blocks firmware upgrades
- [[model-and-version-matrix|Model and version matrix]] ([Model and version matrix](../references/model-and-version-matrix.md)) — CCC at 5.4.2, single-signer at 5.4.4, and the SSSP state

## Sources

- [Spending Policy](../../raw/articles/2026-08-10-coldcard-spending-policy.md) — both modes, what a live policy disables, Bypass PIN, policy controls, Money Manager Mode, Trick PIN game theory, Lock Down Seed advice
- [Web2FA](../../raw/articles/2026-08-10-coldcard-web2fa.md) — the no-RTC problem, ECDH URL construction, URL format, server-side rate limiting, the verbatim trust admissions
- [MicroSD 2FA](../../raw/articles/2026-08-10-coldcard-microsd-2fa.md) — enrolment, serial-number-bound AES key, wipe-on-absence behaviour, duress patterns
- [Mk4/Mk5 release history](../../raw/articles/2026-08-10-coldcard-release-history-mk4-mk5.md) — 5.1.0 MicroSD 2FA, 5.4.2 CCC, 5.4.4 rename and single-signer policy
- [Q release history](../../raw/articles/2026-08-10-coldcard-release-history-q.md) — 1.3.2Q and 1.3.4Q Q-line parity
- [Menu tree](../../raw/articles/2026-08-10-coldcard-menu-tree.md) — Spending Policy and Login Settings menu placement
