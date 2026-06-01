---
title: "SV2 Job Declaration Subprotocol"
category: topic
sources:
  - raw/articles/2026-05-28-stratum-sri-sv2-subprotocols-job-declaration-readme.md
  - raw/repos/2026-05-28-stratum-sri.md
created: 2026-05-28
updated: 2026-05-28
tags: [sv2, job-declaration, jdp, jds, jdc, subprotocol, no-std]
aliases: ["job_declaration_sv2", "JDP", "Job Declaration Protocol"]
confidence: high
volatility: warm
verified: 2026-05-28
summary: "The Job Declaration Protocol (JDP) lets a Job Declarator Client (JDC) declare custom block-template work to a Job Declarator Server (JDS), which a pool can then trust as a third-party service. Implemented as the `job_declaration_sv2` `#![no_std]` message crate."
---

# SV2 Job Declaration Subprotocol

> JDP is the SV2 path that moves custom-work composition off the pool. The mining farm (or its agent) constructs templates and "declares" them to a Job Declarator Server, which can be the pool itself or a trusted third party. This is what makes "the miner picks the template, the pool just verifies and pays" possible inside the SV2 stack.

## Scope

Per the README, `job_declaration_sv2` is a `#![no-std]` crate that "contains the messages defined in the Job Declaration Protocol of Stratum V2. This protocol runs between the Job Declarator Server (JDS) and Job Declarator Client (JDC), and can be provided as a trusted 3rd party service for mining farms."

The normative spec lives at [stratumprotocol.org § 06 Job Declaration Protocol](https://stratumprotocol.org/specification/06-Job-Declaration-Protocol/).

## Roles

- **Job Declarator Client (JDC)** — runs alongside (or inside) the mining farm. It composes block templates the farm wants to mine — typically driven by the [[sv2-template-distribution-subprotocol|Template Distribution Protocol]] ([Template Distribution Protocol](sv2-template-distribution-subprotocol.md)) talking to a local Bitcoin node — and declares them to the JDS.
- **Job Declarator Server (JDS)** — accepts declared templates and authorizes work for the [[sv2-mining-subprotocol|Mining subprotocol]] ([Mining subprotocol](sv2-mining-subprotocol.md)) to ship to miners. JDS can be the pool, or it can be a separate third-party service that the pool delegates to.

## Framing note

Per the [[sv2-framing|SV2 framing]] ([SV2 framing](../concepts/sv2-framing.md)) rules, JDP frames always have `channel_msg = 0` — JDP doesn't run on a mining channel; it predates the work that ends up on a channel.

## Custom-work and `validate_share`

The JDP path is what `channels_sv2`'s **custom-work mode** refers to. PR #2156 / commit `cc3977e5` ("fix validate_share panic after on_set_new_prev_hash in custom-work mode") was specifically about correctness on the JDP-driven mining path: if a new prev-hash arrived between custom-work declaration and a share submission, the server side could panic during share validation. That's the kind of edge that only shows up when JDP is wired up.

## See Also

- [[sv2-mining-subprotocol|SV2 Mining Subprotocol]] ([SV2 Mining Subprotocol](sv2-mining-subprotocol.md)) — consumes the work declared via JDP
- [[sv2-template-distribution-subprotocol|SV2 Template Distribution Subprotocol]] ([SV2 Template Distribution Subprotocol](sv2-template-distribution-subprotocol.md)) — typical upstream of a JDC (Bitcoin Core → JDC → JDS)
- [[sv2-channels|SV2 Channels]] ([SV2 Channels](../concepts/sv2-channels.md)) — custom-work mode lives here
- [[sri-pull-request-themes|SRI Pull Request Themes]] ([SRI Pull Request Themes](../references/sri-pull-request-themes.md)) — PR #2156 panic fix
- [[stratum-core-umbrella|stratum-core Umbrella Crate]] ([stratum-core Umbrella Crate](stratum-core-umbrella.md)) — re-exports `job_declaration_sv2`

## Sources

- [job_declaration_sv2 README](../../raw/articles/2026-05-28-stratum-sri-sv2-subprotocols-job-declaration-readme.md) — JDS/JDC roles, third-party service framing, link to spec
- [SRI repo metadata snapshot](../../raw/repos/2026-05-28-stratum-sri.md) — PR #2156 / `cc3977e5` custom-work panic fix
