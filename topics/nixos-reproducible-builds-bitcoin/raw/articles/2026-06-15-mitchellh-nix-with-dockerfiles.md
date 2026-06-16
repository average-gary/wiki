---
title: "Mitchell Hashimoto — Nix with Dockerfiles (mitchellh.com)"
type: article
source_url: https://mitchellh.com/writing/nix-with-dockerfiles
ingested: 2026-06-15
confidence: medium
relevance: direct
evidence_strength: expert-opinion
direction: nuances
tags: [hashimoto, nix, dockerfile, expert-opinion, nuance, anti-pattern]
research_session: 2026-06-15-sv2-apps-easy-oci-reproducibility-thesis
---

# Mitchell Hashimoto — Nix with Dockerfiles

Senior practitioner blog post (HashiCorp founder, now at Ghostty / Anthropic).
Provides a useful counterweight: documents a half-Nix path that
**defeats** the reproducible-OCI goal, and is honest about why.

## What Hashimoto recommends in this post

Use a Dockerfile with `nixos/nix` as the builder image, build the Nix
expression inside, then `COPY --from=builder` the closure into a
`FROM scratch` runtime stage:

```dockerfile
FROM nixos/nix:latest AS builder
COPY . /tmp/build
WORKDIR /tmp/build
RUN nix --extra-experimental-features "nix-command flakes" \
    build .#default

# resolve closure
RUN mkdir /tmp/nix-store-closure
RUN cp -R $(nix-store -qR result/) /tmp/nix-store-closure

FROM scratch
WORKDIR /app
COPY --from=builder /tmp/nix-store-closure /nix/store
COPY --from=builder /tmp/build/result /app
CMD ["/app/bin/myapp"]
```

## Why this is NOT what the thesis recommends

Hashimoto explicitly notes:

> "Nix is able to make more optimal Docker image layers by using the
> native Nix dockerTools to build an image instead of a Dockerfile, but
> the whole point of this blog post is to show you the Dockerfile
> approach."

The Dockerfile approach **does not produce bit-identical OCI images
across rebuilders**. Reasons:

- `COPY` operations bake build-time timestamps into Docker layer
  metadata.
- Layer hashing in Docker/BuildKit incorporates filesystem timestamps
  and ordering nondeterminism.
- The Nix closure underneath is reproducible, but the OCI image *over*
  the closure is not.

So this is a useful integration pattern when the goal is "use Nix for
build hermeticity, ship to a Docker-native CI" — but it does **not**
satisfy the thesis. The thesis requires the dockerTools / nix2container
path.

## What's still useful from this post

- **Practical reproducibility**: Hashimoto's "I haven't had a 'works on
  my machine but not on others' issue in years" testimonial is a real
  data point that Nix-driven builds eliminate the cross-developer
  bug class even when not all the way to bit-deterministic OCI.
- **Adoption-cost honesty**: Hashimoto frames Nix's upfront cost as
  worthwhile only if Nix is adopted more broadly than just OCI. For
  sv2-apps, this argues for pairing the OCI-reproducibility work with
  a `devShells.default` (cheap) and possibly a NixOS module
  (out of scope for this thesis but a natural follow-up).
- **The layer-caching nuance**: a monolithic `RUN nix build` produces
  one giant layer, eroding traditional Docker layer caching.
  `dockerTools.buildLayeredImage` (which auto-layers the Nix store
  closure) solves this — confirming the thesis's recommended path is
  the layer-cache-friendly one too.

## Read for the thesis

A small "consider, then reject" data point. Adopters who Google
"Nix Docker" land here and may follow this pattern by default, getting
hermetic-but-not-bit-reproducible builds. The sv2-apps documentation
needs to explicitly point to `dockerTools.buildLayeredImage` (the
Fedimint/loglog pattern) and call out *why* the Dockerfile-wrapping-Nix
pattern doesn't suffice.

## See also

- [[../repos/2026-06-15-rustshop-loglog-minimal-flake.md]] — the recommended pattern
- [[../repos/2026-06-15-fedimint-ci-nix-workflow.md]] — the recommended release pipeline
- [[2026-06-15-nix-oci-tooling-open-issues.md]] — gotchas in the recommended path
