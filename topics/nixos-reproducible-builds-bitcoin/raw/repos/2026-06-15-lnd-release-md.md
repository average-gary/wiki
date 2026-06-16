---
title: "LND Release Process — docs/release.md + scripts/release.sh"
sources:
  - https://github.com/lightningnetwork/lnd/blob/master/docs/release.md
  - https://raw.githubusercontent.com/lightningnetwork/lnd/master/scripts/release.sh
  - https://raw.githubusercontent.com/lightningnetwork/lnd/master/scripts/keys/roasbeef.asc
type: repo
maintainer: Lightning Labs (Olaoluwa Osuntokun / roasbeef + co-maintainers)
year: ongoing (Go 1.13+ era; current as of 2026-06)
ingested: 2026-06-15
tags: [lnd, lightning, go, release-process, multi-signer, deterministic]
confidence: high
quality: 5
---

# LND release process

LND has its own deterministic-build pipeline — independent of Nix and Guix —
and a multi-signer manifest pattern functionally similar to (but weaker than)
`bitcoin-core/guix.sigs`.

## Reproducibility recipe (`scripts/release.sh`)

```sh
env CGO_ENABLED=0 GOOS=$os GOARCH=$arch GOARM=$arm \
  go build -v -trimpath -ldflags="${ldflags}" -tags="${buildtags}" ${PKG}/cmd/lnd
```

Plus environment normalization:
- `BUILD_DATE="2020-01-01 00:00:00"`
- `TZ=UTC`
- `tar --mtime --owner=0 --group=0 --numeric-owner`
- `LC_ALL=C sort`
- `chmod -R 0755`
- GNU tar/gzip required

Notably **does NOT** use `-buildvcs=false` — Go 1.18+ VCS-stamping
non-determinism is a known sharp edge for users on unusual git states.

## Multi-signer manifest pattern

Each maintainer signs the manifest separately:

```sh
gpg --detach-sig --output manifest-USERNAME-TAG.sig manifest-TAG.txt
```

Per release v0.21.0-beta, attached assets include:
`manifest-roasbeef-*.sig`, `manifest-suheb-*.sig`, `manifest-yyforyongyu-*.sig`,
`manifest-ziggie1984-*.sig`, `manifest-hieblmi-*.sig` — **5 signers**.

Plus OpenTimestamps proofs: `manifest-roasbeef-v0.18.5-beta.txt.asc.ots`.

## Distributed verification claim

> *"third parties can now independently run the release process, and verify
> that all the hashes of the release binaries match exactly."*

This is functionally equivalent to `bitcoin-core/guix.sigs` but:

- **No separate sigs repo** — sigs are attached to each GitHub Release.
- **No documented attester threshold** — Bitcoin Core requires "6 or more"
  matching guix.sigs. LND has no published rule.
- **No formal cohort tracking** — Bitcoin Core 26.0 had 23 attesters; LND's
  count plateaus at 5 maintainers.

## Roasbeef key

- Fingerprint (signing): `60A1FA7DA5BFF08BDCBBE7903BBD59E99B280306`
- UID: `Olaoluwa Osuntokun <laolu32@gmail.com>` (Ed25519)
- Subordinate tag-signing key id: `8E4256593F177720`
- Distributed via `scripts/keys/roasbeef.asc` in-repo (TOFU off GitHub).

## Why this matters for the wiki

LND's reproducibility story is **strong on the deterministic-build axis** but
**weak on the multi-builder cohort axis** vs Bitcoin Core. A NixOS user who
wants to verify their `lnd` binary matches Lightning Labs' upstream output
*can* do so manually — but the Nixpkgs derivation does not perform this
verification (see `nixpkgs-lnd-trimpath-gap` ingest).
