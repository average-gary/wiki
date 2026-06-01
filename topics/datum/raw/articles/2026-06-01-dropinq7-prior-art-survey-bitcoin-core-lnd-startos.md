---
title: "Prior-Art Survey for MIGRATING.md Shape — Bitcoin Core, LND, StartOS"
source_url: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-27.0.md
source_type: web-survey
date_fetched: 2026-06-01
ingested_by: dropinq7
research_path: dropinq7-switch-day-runbook
quality_score: 7
tags: [datum, datum-gateway, drop-in, migration, migrating-md, prior-art, bitcoin-core, lnd, startos]
related_concepts: [drop-in-replacement, switch-day-runbook, documentation-template]
---

# Prior-Art Survey for MIGRATING.md Shape

Surveyed three comparable bitcoin/mining-adjacent projects to identify
the right template for a `MIGRATING.md` shipping with the Rust DATUM
Gateway drop-in.

## Bitcoin Core release notes (the gold standard)

Bitcoin Core's `release-notes-X.Y.Z.md` template uses this fixed
section ordering:

1. `## How to Upgrade`
2. `## Compatibility`
3. `## Notable changes`
4. `## Low-level changes`
5. `## Credits`

The `How to Upgrade` section is famously terse and operationally direct:

> "If you are running an older version, shut it down. Wait until it has
> completely shut down (which might take a few minutes in some cases),
> then run the installer (on Windows) or just copy over
> `/Applications/Bitcoin-Qt` (on macOS) or `bitcoind`/`bitcoin-qt` (on
> Linux)."

Followed by a one-paragraph note about EOL upgrade paths and data-dir
migration timing.

`Compatibility` opens with a one-line statement of supported kernel/OS
versions and a follow-up qualifier paragraph.

**Takeaway:** the template prioritizes *what the operator does next*
over a narrative of changes. No checklists, no scary callouts, just
imperative steps.

## LND release notes

LND's `release-notes-0.18.0.md` uses a feature-driven structure with
no dedicated upgrade section:

1. Bug Fixes
2. New Features (Functional Enhancements / RPC Additions / lncli Additions)
3. Improvements (Functional Updates / Misc / RPC Updates / lncli Updates / Code Health / Breaking Changes / Performance)
4. Technical and Architectural Updates (BOLT Spec / Testing / Database / Code Health / Tooling)
5. Contributors

**Operator-relevant migration content lives only inside `Breaking
Changes` and scattered DB-migration callouts.** This is a weaker
template for a drop-in handoff because it forces operators to grep
for relevant notes. We should *not* adopt this pattern for the
Rust port.

## StartOS / s9pk (the appliance model)

StartOS — the Start9 Embassy successor — packages bitcoind, electrs,
LND, etc. as `.s9pk` archives. Service updates are one-click in the
GUI; the runtime handles backup, downtime windows, and dependency
checks. Service maintainers ship migrations as part of the s9pk
manifest (the SDK exposes hooks; canonical docs live behind
`docs.start9.com` per-version paths, several of which 404 on the
public site as of 2026-06-01).

**Takeaway for the Rust drop-in:** if/when the gateway is packaged as
an s9pk, the maintainer needs to ship a manifest with explicit
`fromVersion → migration` rules. Until then, `MIGRATING.md` is the
operator's primary source. The two surfaces (s9pk manifest, prose
doc) should agree.

## Recommended template for the Rust DATUM Gateway

Adopt Bitcoin Core's headline structure, augmented with three
mining-specific additions: a **rollback section** (because mining
revenue is on the line, unlike a bitcoind read replica), a
**verification commands** section (operators currently have no
prescribed health-check), and a **failure-mode catalog**
(version-mismatch and config-schema problems are this drop-in's
two known risk axes).

Section ordering:

1. `## At a glance` — one-paragraph summary, "drop-in compatible / not
   drop-in compatible" verdict, link to release tag.
2. `## Compatibility` — supported OS, supported C-gateway versions to
   migrate from, supported DATUM Prime protocol version, supported
   ASIC firmware (SV1 today; SV2 in the dual-protocol mode).
3. `## Pre-switch checklist` — backup config, note current state,
   identify monitoring touchpoints, run `--migrate-config --dry-run`.
4. `## How to upgrade` — the swap procedure for: bare metal
   (`systemctl`), Docker (`docker pull`), package manager (`apt`,
   `dnf`).
5. `## Verification` — `--version` output, HTTP API ping, hashboard
   share-rate sanity check, log-line greps for handshake success.
6. `## Rollback` — restore C binary, restart, reverify.
7. `## What changed` — config schema deltas, log-format deltas, new
   endpoints (Prometheus `/metrics` if shipped), removed flags.
8. `## Known issues` — limit-N list, with workarounds.
9. `## Telemetry differences during transition` — call out
   structured-log additions as **additions, not breaks**, so
   operators with grep alerts know what to expect.
10. `## Getting help` — issue tracker, OCEAN support contacts (Jason
    @wk057, Luke @LukeDashjr, Mechanic @GrassFedBitcoin per the
    setup guide).

Cross-check against Bitcoin Core sections 1–3 to make sure terse
imperative voice is preserved.

## Justification

`MIGRATING.md` is the artifact an OCEAN operator opens at 2 a.m. when
their hashrate just fell off a cliff. The template must front-load
*what to do next* and reserve narrative for the bottom of the doc.
Bitcoin Core's structure is the closest fit; LND's is too feature-
driven; StartOS's manifest model is the eventual destination but
not the starting artifact.

## Sources

- [Bitcoin Core 27.0 release notes](https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-27.0.md)
- [LND 0.18.0 release notes](https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.18.0.md)
- [StartOS / Start9 docs root](https://docs.start9.com)
