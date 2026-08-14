---
title: "Using Coldcard with Electrum"
source: "https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/electrum-usage.md"
type: articles
ingested: 2026-08-10
tags: [coldcard, electrum, airgap, psbt, offline-signing, seed-import, plugin, microsd]
summary: "Practical guide to pairing a Coldcard with Electrum, recommending the latest Coinkite plugin. The offline/air-gapped signing flow: create the Electrum wallet against the Coldcard's seed (over USB as a connected device, possibly fully offline), then to spend, set the amount and destination, press Preview or press Send with the Coldcard disconnected, and use the new 'Save PSBT' button in the transaction-details window to write the file - possibly straight to an SD card. The filename encodes date, time and wallet name. Move the card to the Coldcard, choose 'Ready to Sign' from the main menu, select the transaction, confirm the details on screen and approve; the device writes a -final.txn file containing the hex transaction, which Electrum can broadcast via Tools > Load Transaction > from File followed by Broadcast. Also gathers tips on importing seed words into Electrum for emergency access to funds."
collection: "coldcard"
adapter: git
upstream_id: "docs/electrum-usage.md"
upstream_type: git-file
revision: "43b2139227149c281141d08c612afd13c434d456"
sha: "ef44d0a35051a8c6230ea63473729f4fabadaa2d"
canonical_url: "https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/electrum-usage.md"
content_format: markdown
license: "MIT (Coinkite Inc.)"
authors: [Coinkite Inc.]
fetched: 2026-08-10
---
# Using Coldcard with Electrum

(please use the latest version of our plugin)

## Off-line signing (air gap)

Setup Time:
- setup your Electrum wallet associated with the seed of the Coldcard
- can be done over USB as a connected device... ie. like normal
- might be possible to do this completely offline

To spend:
- setup the details of the transaction (amount,destination)
- press preview, or press send when the Coldcard not connected
- you get a "transaction details" window, along bottom, new button is shown: "Save PSBT"
- click that, and it saves a new file ... perhaps direct to SD card if you have it 
- make note of the filename; it has date and time and wallet name in it.
- close things, move the MicroSD to Coldcard
- pick "Ready to Sign" from main menu on Coldcard
- select the correct transaction from list
- observe and confirm details, press OK and the Coldcard signs it.
- a new file will be created on SD card: `blah-final.txn` .. contains HEX of txn to send
- use any tool to transmit that on Bitcoin P2P network... for Electrum:
    - import the final transaction (`-final.txn`), using the "Tools > Load Transaction > from File" menu item
    - press Broadcast
    - should show up in wallet immediately


## Restoring Coldcard Seed into Electrum

Use this process to recover your funds if you loose your Coldcard and you still
have the seed words.


### Import from Seed Words

- choose New/Restore => (filename) => Standard Wallet => I already have a Seed
- type in 24 word phrase.
- then click "Options", and enable checkbox labeled "BIP39 seed"
- a warning is shown:

    BIP39 seeds can be imported in Electrum, so that users can access
    funds locked in other wallets.  However, we do not generate BIP39
    seeds, because they do not meet our safety standard.  BIP39 seeds
    do not include a version number, which compromises compatibility
    with future software.  We do not guarantee that BIP39 imports will
    always be supported in Electrum.

- press Next (seed phrase checksum is verified, so you must get all the words right)

### Import from Extended Public Key (XPUB)

- You may also save the XPUB from the Coldcard and import that.
- On the Coldcard, choose `Dump Summary` from the Advanced menu, and open the
        `public.txt` file that generated on your computer.
- In `public.txt`, look for the section labeled "BIP44 / Electrum" and
    Copy the top `xpub` value, beside: `m/44'/0'`
- In Electrum, choose New/Restore => (filename) => Standard Wallet => Use a master key
- Paste in the `xpub` value into the text box and press Next.
- Verify your work by selecting View -> Show Addresses and clicking on the Addresses tab.
- The first few receive addresses should match the values shown in `public.txt` beside
  the text: `m/44'/0'/0'/0/0`, `m/44'/0'/0'/0/1` and so on.

#### Note

You could also import the master xpub (`'m'`) from that file, and
use that key in Electrum, but that would not follow BIP44, which
is the default when importing seed words.

### Derivation Screen

- default value is `m/44'/0'/0'` (legacy BIP44), but options include:
    - p2sh-segwit BIP49: `m/49'/0'/0'` [NOT YET SUPPORTED]
    - native-segwit BIP84: `m/84'/0'/0'` [should work]
- for testnet, the first `0'` will be `1'`
- choose appropriately... but if you imported the top-level (master) xpub/xpriv, then
  use just `m/` which really is no derivation at all
- Electrum always uses `/{change}/{index}` for individual addresses, where:
    - `change` is one if it's change back to the wallet, and zero for normal receive
    - `index` starts at zero and counts up based on usage and gap size.


