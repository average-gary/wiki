---
title: "Coldcard BIP-21 URI Extensions (multisig ownership check)"
source: "https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/bip-21-extensions.md"
type: articles
ingested: 2026-08-10
tags: [coldcard, bip-21, uri, multisig, address-verification, qr, nfc, wallet-parameter]
summary: "Short specification of Coldcard's BIP-21 URI extension for accelerating multisig address ownership checks. Supplying wallet=name in an otherwise standard BIP-21 URL presented by QR code or NFC record names the multisig wallet an address belongs to, so the search can go straight to it; if the parameter is omitted, the device searches across every multisig wallet it knows. Includes two examples, one a bare testnet address with ?wallet=goldmine and one a full bitcoin: URI combining label, amount and a percent-encoded wallet name."
collection: "coldcard"
adapter: git
upstream_id: "docs/bip-21-extensions.md"
upstream_type: git-file
revision: "43b2139227149c281141d08c612afd13c434d456"
sha: "17a6b73bfe29c6a061cc595dbf962e168f7db074"
canonical_url: "https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/docs/bip-21-extensions.md"
content_format: markdown
license: "MIT (Coinkite Inc.)"
authors: [Coinkite Inc.]
fetched: 2026-08-10
---
## Multisig Ownership address check: "wallet"

If the name of the multisig wallet related to an address is provided, address search
can be greatly accelerated. Just provide `wallet=name` parameter in a standard
[BIP-21](https://github.com/bitcoin/bips/blob/master/bip-0021.mediawiki) URL
shown in QR code or NFC record. If omitted, search will continue across 
all multisig wallets known by COLDCARD.

### Examples

```
tb1q4d67p7stxml3kdudrgkg5mgaxsrgzcqzjrrj4gg62nxtvnsnvqjsxjkej0?wallet=goldmine

bitcoin:mtHSVByP9EYZmB26jASDdPVm19gvpecb5R?label=coldcard_purchase&amount=50&wallet=Haystack%20Four
```
