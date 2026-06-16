---
title: "Thesis: Fedimint should establish a fedimint.sigs multi-builder attestation repo"
type: thesis
status: candidate
created: 2026-06-15
updated: 2026-06-15
verdict: pending
confidence: pending
core_claim: "Fedimint's reproducibility infrastructure is build-time-strong but verification-time-weak; establishing a `fedimint.sigs` repo modeled on `bitcoin-core/guix.sigs`, with ≥3 independent rebuilders per release, would close the gap at minimal cost given the existing `just sign-release` script."
key_variables: [fedimint-sigs-repo, signer-roster, just-sign-release, cachix-tofu, guardian-coordination, federation-trust-model]
falsification: "Fedimint maintainers explicitly reject the multi-builder model citing federation-already-trusts-the-threshold; OR the `just sign-release` script's per-system SHA256SUMS prove non-deterministic across rebuilders such that no cohort could ever agree on hashes."
---

# Thesis: Fedimint needs `fedimint.sigs`

## Core claim

Fedimint's `flake.nix` + `nix/flakebox.nix` + `scripts/release/sign.sh`
already produce per-system, GPG-signable `SHA256SUMS.asc` files. A
`fedimint-core/fedimint.sigs` repo where ≥3 independent rebuilders submit
their signatures per release would put Fedimint at LND parity (5-signer
manifests) for ~weeks of effort, not the ~3 years that 0xB10C spent
matching hashes for Bitcoin Core under Nix.

## Key variables

- **`just sign-release` mechanics** — already produces signed checksums; the
  question is whether they're cross-builder-deterministic.
- **Signer roster** — currently undocumented (PR #4339 deferred this).
- **Cachix TOFU** — eliminating it requires guardians to actually rebuild,
  which requires the cohort to demonstrate it's possible.
- **Guardian-coordination protocol** — current `--version` string check
  could be replaced by content-hash verification surfaced via federation
  API.
- **Federation trust model** — does the threshold consensus already make
  this redundant?

## Testable prediction

If the thesis holds, within 2-3 release cycles after a `fedimint.sigs` repo
is established, ≥3 distinct GPG keys (not just @elsirion + @dpc + GH-bot)
should attest matching hashes per release per system.

## Falsification criteria

- Maintainers explicitly reject the model on the
  federation-already-trusts-the-threshold argument.
- Cross-builder rebuilds prove non-deterministic (e.g. macOS code-signing
  ad-hoc differences, LLVM 20 nondeterminism, wasm-bindgen timestamp
  embedding) such that no cohort could agree.
- The Cachix-as-TOFU model is reaffirmed as project policy.

## Status

Candidate. Promote via `/wiki:research --mode thesis` if a follow-up wants
to render a verdict.

## See also

- [[../wiki/topics/fedimint-reproducible-builds.md]]
- [[../wiki/topics/lightning-node-reproducibility-under-nix.md]]
- [[nix-can-match-guix-attestation.md]]
- [[../wiki/concepts/multi-builder-attestation.md]]
