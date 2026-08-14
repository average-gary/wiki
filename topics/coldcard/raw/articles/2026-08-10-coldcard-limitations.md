---
title: "Coldcard Documented Limitations and Policy Choices"
source: "https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/limitations.md"
type: articles
ingested: 2026-08-10
tags: [coldcard, limitations, multisig, psbt, sighash, spending-policy, trick-pins, bbqr, address-explorer, fee-limits]
summary: "Coinkite's own catalogue of hard limits, deliberate policy choices and TODOs - the most useful single document for knowing what a Coldcard will refuse to do. Covers BIP-39 import constraints, XPRV/SLIP-132 handling, PIN length bounds (2-2 up to 6-6), the absence of a real-time clock (so backup metadata falls back to the firmware release date), a 32GB MicroSD ceiling, refusal to sign coinbase transactions, and maximum transaction sizes (Mk3: 384k PSBT, 20 inputs, 250 outputs; Mk4/Q: 2M PSBT, tested at 250 inputs and 2000 outputs, with the network's own 100k limit binding first). Details the multisig limits - at most 15 co-signers because of the 1650-byte scriptSig ceiling, 16-level derivation paths, mandatory unique XFPs, one multisig wallet per PSBT - plus BIP-67 sortedmulti rules and duplicate detection. Notes that all SIGHASH types are supported but NONE is rejected by default, the fee limits (reject above 10%, warn above 5%), macOS/Linux-only development, the change-output redeemScript/witnessScript matrix, MAX_PATH_DEPTH of 12, the 8000-byte NFC-V ISO-15693 payload cap, Fast Wipe's 256 MCU key slots, Trick PIN slot accounting (14 slots, with Mk4 avoiding slot 10 leaving 13 and Q offering 14, and duress wallets consuming 2-3 contiguous slots), the 2MiB BBQr limit, the Q's QR auto-detect list (SeedQR yes, Compact SeedQR no), Secure Notes and Passwords entropy (F1-F5 at 126+ bits except F3 at roughly 48), Address Ownership search over the first 1528 addresses (764 per keychain), and the Spending Policy constraints (Cosign key C limited to 12/24 words, velocity limits enforced via nLockTime, 25 whitelisted addresses, a Web2FA shared secret, and rejection of any PSBT carrying a warning)."
collection: "coldcard"
adapter: git
upstream_id: "docs/limitations.md"
upstream_type: git-file
revision: "43b2139227149c281141d08c612afd13c434d456"
sha: "46f6da92c962c0623e8a835bb03b49b9bd84d64f"
canonical_url: "https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/limitations.md"
content_format: markdown
license: "MIT (Coinkite Inc.)"
authors: [Coinkite Inc.]
fetched: 2026-08-10
---
# BIP-39 Import

- there must be 12, 18 or 24 words in your mnemonic
- we have only the English word list
- we support BIP-39 passwords during import

# XPRV Import

- we can import a BIP-32 HD-wallet root private key in XPRV format
- it's assumed to be top-level, and we don't store the parent fingerprint or depth value
- SLIP-132 format HD-wallet keys are also supported (xprv/yprv/zprv), but we strip
  the implied address format

# PIN Codes

- 2-2 through 6-6 in size, numeric digits only
- pin code 999999-999999 was reserved (meaning 'clear pin'), but now available again

# Backup Files

- we don't know what day it is, so meta data on files will not have correct date/time
- release date of the firmware version that made the file is used instead of true date
- encrypted files produced cannot be changed, and we don't support other tools making them

# Micro SD

- cards up to 32G are supported
- we do not guarantee to support all cards ever made, or yet to be made
- we recommend 8G cards or smaller, since our storage needs are very modest

# Signing / Wallet Types

- with Electrum, we support classic payment addresses (p2pkh), Bech32 Segwit and P2SH/Segwit
    - however, each wallet must be of a single address type; cannot be mixed (their limitation)
    - the same Coldcard could be used in each of the three modes (we don't care about address format)
- with Bitcoin Core (version 0.17+), we can do PSBT transactions, which support all address types
- we don't support signing coinbase transactions, so don't mine directly into a Coldcard wallet

# Max Transaction Size

- mk3:
    - we support transactions up to 384k-bytes in size when serialized into PSBT format
    - we can handle transactions with up to 20 inputs to be signed at one time.
    - a maximum of 250 outputs per transaction is supported (will attempt more if memory allows)
- mk4/Q:
    - we support PSBT files up to 2M bytes in size.
    - any number of inputs and outputs are supported, limited only by final transaction size (100k)
    - tested with: 250 inputs, 2000 outputs
- bitcoin limits transactions to 100k, but there could be large input transactions
  inside the PSBT. Reduce this by using segwit signatures and provide only the
  individual UTXO ("out points").
- every transaction needs to have at least one output, or we reject it


# P2SH / Multisig

- only one signature will be added per input. However, if needed the partly-signed 
  PSBT can be given again, and the "next" leg will be signed.
- finalizing of multisig transactions involving P2SH signatures:
    * SD/Vdisk signing exports both signed PSBT and finalized txn ready for broadcast (if txn is complete)
    * QR/NFC outputs finalized txn ready for broadcast if txn is complete otherwise signed PSBT only
    * USB signing requires `--finalize` parameter (as for standard single signature wallets)

- we can sign for P2SH and P2WSH addresses that represent multisig (M of N) but
  we cannot sign for non-standard scripts because we don't know how to present
  that to the user for approval.
- during USB "show address" for multisig, we limit subkey paths to
  16 levels deep (including master fingerprint)
- max of 15 co-signers due to 1650 byte `scriptSig` limitation in policy with classic P2SH (same limit applies to segwit even though consensus allows up to 20 co-signers).
  note: the consensus layer sets an upper bound of 520 bytes for the length of each stack element
- (mk3) we have space for up to 8 M-of-3 wallets, or a single M-of-15 wallet. YMMV
- only a single multisig wallet can be involved in a PSBT; can't sign inputs from two different
    multisig wallets at the same time.
- we always store xpubs in BIP-32 format, although we can read SLIP132 format (Ypub/Zpub/etc)
- change outputs (indicated with paths, scripts in output section) must correspond to
  the active multisig wallet, and cannot be used to describe an unrelated (multisig) wallet.
- derivation path for each cosigner must be known and consistent with PSBT
- XFP values (fingerprints) MUST be unique for each of the co-signers
- multisig wallet `name` can only contain printable ASCII characters `range(32, 127)`

### BIP-67

- importing multisig from PSBT can ONLY create `sortedmulti(...)` multisig according to BIP-67, DO NOT use with `multi(...)`
- creating airgapped multisig using COLDCARD as coordinator always produces `sortedmulti(...)` multisig according to BIP-67
- COLDCARD import/export [format](https://coldcard.com/docs/multisig/#configuration-text-file-for-multisig) only supports `sortedmulti(...)` multisig according to BIP-67. To import multisig wallet with `multi(...)` use descriptor import [format](https://github.com/bitcoin/bips/blob/master/bip-0383.mediawiki)
- encrypted COLDCARD backups that contains multisig wallets with `multi(...)` MUST only be restored on firmware versions with `multi(...)` support
- all imported `multi(...)` must differ in keys (same as `sortedmulti(...)`). If `wsh(multi(2,A,B))` is already registered, `wsh(multi(2,B,A))` will be rejected upon import as duplicate, even thought they are actually different script/wallet.
- just BIP67 difference is also treated as duplicate. If `wsh(multi(2,A,B)` is registered, `wsh(sortedmulti(2,A,B))` will be rejected as duplicate and vice-versa.

# SIGHASH types

- all sighash flags are supported:
    - `ALL`
    - `NONE`
    - `SINGLE`
    - `ALL|ANYONECANPAY`
    - `NONE|ANYONECANPAY`
    - `SINGLE|ANYONECANPAY`
- any value other than ALL will cause a warning to be shown to user
- by default, we reject `NONE` and `NONE|ANYONECANPAY` but there is a setting to allow

# U2F Protocol / Web Access to USB / WebUSB

- we do not support U2F protocol, WebUSB or any other means for random websites to talk to us
- only native desktop/mobile apps, or helpers for those, will be able to talk USB to Coldcard

# Fee Limits / Warnings

- Coldcard will, by default, reject any txn that pays a fee of more than 10% of its total
  value to miners. This limit is a setting: 10% (default), 25%, 50% or 'no limit'.
- Fees over 5% (was 1%) are shown as warnings.

# Developer / Source Code

- source code can probably only be compiled and developed on Mac OS and Linux
- we have very limited time to support other devs getting their setups working

# Change Outputs

We will summarize transaction outputs as "change" back into same wallet, however:

- PSBT must specify BIP-32 path in corresponding output section for us to treat as change
- for p2sh-wrapped segwit outputs, redeem script must be provided when needed
- any incorrect values here are assumed to be fraud attempts, and are highlighted to user
- the _redeemScript_ for `p2wsh-p2sh` is optional, but if provided must be
  correct, ie: 0x00 + 0x20 + sha256(_witnessScript_)
- the _witnessScript_ in a `p2wsh-p2sh` is not optional.
- depending on the address type of the output, different values are required in the
  corresponding output section, as follows
    - `p2pkh`: no _redeemScript_, no _witnessScript_
    - `p2wpkh-p2sh`: only _redeemScript_ (which will be: `0x00 + 0x14 + HASH160(key)`)
    - `p2wpkh`: no _redeemScript_, no _witnessScript_
    - `p2sh`: _redeemScript_ that contains the a multisig script, ending in 0xAE
    - `p2wsh-p2sh`: _redeemScript_ (which is: `0x00 + 0x20 + sha256(witnessScript)`), and
      _witnessScript_ (which contains the multisig script)
    - `p2wsh`: only _witnessScript_ (which contains the actual multisig script)


# Derivation Paths

- key derivatation paths must be 12 or less in depth (`MAX_PATH_DEPTH`)

# Pay-to-Pubkey

- although we have some code for "pay to pubkey" (P2PK not P2PKH), it is untested
  and unused since this style of payment address is obsolete and largely unused today

# NFC Feature

- can share up to 8000 bytes of PSBT or signed transaction data.
- NFC-V (ISO-15693) radio/modulation is common on mobile phones but very rare on desktops

# Fast Wipe

- each use of "fast wipe" feature consumes a MCU key slot, of which there are 256.
- use _Advanced > Danger Zone > MCU Key Slots_ to view usage

# Trick Pins

- "deltamode" PIN must be same length as true pin, and differ only in final 4 positions.
- there are 14 trick "slots", but on mk4, we avoid slot 10, so 13 available. (Q: 14)
- duress wallets consume 2 slots (or 3 slots for legacy duress wallet) which must be contiguous
- when restoring trick pins from backup files, "forgotten" pins are not restored,
  and any trick pin which matches the true PIN of the restored system will be dropped
- deltamode PIN requirements are checked during wallet restore, and if the new true PIN
  is not compatible, the deltamode trick PIN is dropped and not restored
- duress wallets are supported when derived from 24- or 12-word seed phrases

# Debug Serial Port

- virtual USB serial port disabled completely by default, and even if enabled
  in Danger Zone, only echos output, and does not accept any input
- use hardware serial port for interactive REPL access (3.3v TTL levels)

# BBQr Scanning (Q)

- files up to 2MiB in size can be accepted
- when 14 or less parts, we display status of each part, if more, just percent complete

# QR Scanning (Q)

- if not BBQr (or sent as unicode inside BBQr) we auto detect these data types:
    - PSBT in Base64 or hex
    - Wire Transaction in Base64 or hex
    - XPRV, XPUB, bare payment addresses, BIP-21 invoices
    - seed words (truncated, or full)
    - SeedQR (but not Compact SeedQR)
- for Base58, Bech32 encoded values, if checksum is wrong then it is shown as text
- binary QR codes are not supported
- when pasting into a secure note, if the QR's data is > 60 chars long, we assume done

# Secure Notes & Passwords (Q)

- when Q picks a password for you (using F1 thru F5), the entropy is 126 bits or more,
  except F3 which makes an easier to type password of around 48 bits entropy.
- Title, Sitename and Username fields are limited to 32 characters in length.
- Passwords are limited to 128 characters.
- Note text is unlimited, but storing very large notes may affect performance system-wide.
- Q Backup files restored onto Mk4 will lose their notes, since notes feature is not supported.

# Address Ownership

- only the first 1528 addresses (764 each from internal and external (change/not) paths)
  are considered
- if you have used an sub-account, without ever exploring it in the Address Explorer, nor
  signing a PSBT with those account numbers, we do not search it.
- does not search Seed Vault, you'll need to load each of those and re-search
- if you have an XFP collision between multiple wallets in SeedVault (ie. two wallets
  with same descriptors, but different seeds) you will get false negatives

# Spending Policy

- (Cosign mode) only 12 or 24 word seeds (not XPRV) are accepted for "key C"
- velocity limit:
    - based on a max magnitude per txn, and a required minimum block height
      gap, based on previous `nLockTime` value in last-signed PSBT.
    - if you sign a transaction, but never broadcast it, you will still have to wait out 
      the velocity policy.
    - PSBT creator must put in `nLockTime` block heights (most already do to avoid fee sniping)
- maximum of 25 whitelisted addresses can be stored
- Web2FA: any number of mobile devices can be enrolled, but all will have the same shared secret
- any warning from the PSBT, such as huge fees, will cause the transaction to be rejected

