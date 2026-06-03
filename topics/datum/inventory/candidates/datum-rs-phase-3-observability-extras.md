---
title: "datum-rs Phase 3: observability extras — Prometheus, structured logs, --migrate-config, PID file, systemd notify"
kind: task
status: blocked
priority: p3
created: 2026-06-01
updated: 2026-06-01
last_checked: 2026-06-01
next_action: "After Phase 1 v0.1.0 ships and Phase 2 distribution polish lands: add Prometheus /metrics endpoint to datum-api; add structured JSON log option to datum-logger (gated, default off); add --migrate-config --dry-run subcommand to datum-config; add --pid-file PATH; integrate Type=notify systemd."
sources:
  - output/plan-bootstrap-datum-rs-2026-06-01.md
  - wiki/concepts/drop-in-surface-inventory.md
  - wiki/concepts/switch-day-runbook.md
tags: [datum-rs, phase-3, observability, deferred, additive-features]
confidence: high
summary: "Observability extras explicitly deferred from datum-rs Phase 1 per user brief. Bundles 5 additive (non-parity) features. All are listed as additive in the drop-in surface inventory's negotiable-surfaces section. Blocked on Phase 2."
---

# datum-rs Phase 3: observability extras

## Why Track This

Phase 1 plan ([plan-bootstrap-datum-rs-2026-06-01.md](../../output/plan-bootstrap-datum-rs-2026-06-01.md)) explicitly defers these per the user brief. None are required for drop-in parity — they're listed as **additive** in [drop-in-surface-inventory § negotiable surfaces](../../wiki/concepts/drop-in-surface-inventory.md#negotiable-surfaces-additive-only). Lower priority (p3) because the drop-in is fully functional without them; they ship after Phase 2 distribution polish to maximize operator-facing improvements per release.

Bundled (not split into 5 records) because these are small additive features that share the "improve operator surface beyond C parity" theme.

## Current State

Blocked on Phase 2 (distribution polish). Phase 1 deliberately leaves the observability surface at C-parity to minimize log-format / API drift risk during the high-risk protocol port.

## Sub-tasks (when unblocked)

1. **Prometheus `/metrics` endpoint**: add to `datum-api`. C gateway has none. Operator-side dashboards become possible (Grafana etc.).
2. **Structured JSON log option**: add to `datum-logger`, gated behind config flag (default keeps C-format for grep-pipeline compat). Operators opt in.
3. **`--migrate-config --dry-run` subcommand**: add to `datum-config`. Helpful when config schema additions ship in later versions.
4. **`--pid-file PATH` flag**: optional addition. C gateway has no PID file.
5. **`Type=notify` systemd integration**: deeper than `Type=simple`. Unit file shipped in `.deb` package.

## Notes

- Risk: log-format drift breaks operator alerts ([switch-day-runbook F7](../../wiki/concepts/switch-day-runbook.md#failure-mode-catalog)). Default-off for structured-JSON-log option mitigates.
- Coordinates with [drop-in-surface-inventory § four hard surfaces](../../wiki/concepts/drop-in-surface-inventory.md#the-four-hard-surfaces) — none of these violate the four hard surfaces.
- Phase 1 already keeps SIGTERM/SIGINT clean shutdown and `--version` flag (additive items judged cheap enough to include in v0.1.0).
