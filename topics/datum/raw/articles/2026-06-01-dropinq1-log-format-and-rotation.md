---
title: "datum_gateway log line format and rotation — the grep contract"
source: https://raw.githubusercontent.com/OCEAN-xyz/datum_gateway/master/src/datum_logger.c
type: articles
tags: [datum-gateway, drop-in-replacement, logs, observability, log-format, operator-surface]
summary: "Exact log line anatomy from datum_logger.c: 'YYYY-MM-DD HH:MM:SS.mmm [func_name_padded_44] LEVEL: message'. Local time, no timezone. Levels are right-padded 5-char strings (' INFO', ' WARN', 'ERROR', 'FATAL', 'DEBUG', '  ALL'). Daily rotation appends YYYY-MM-DD via rename(). Operators grep these; bit-exact format match is part of the drop-in contract for any production deployment with existing log alerting."
confidence: high
ingested: 2026-06-01
ingested_by: dropinq1
---

# datum_gateway log line format — the grep contract

## Anatomy of one log line

Without `log_calling_function`:
```
%s.%03d %s: %s\n
   timestamp.ms LEVEL: message
```

With `log_calling_function=true` (the default):
```
%s.%03d [%44s] %s: %s\n
   timestamp.ms [function_name_padded_44] LEVEL: message
```

The exact strftime: `"%Y-%m-%d %H:%M:%S"`, then `.%03d` for milliseconds. **`localtime_r()`** — local time, no timezone offset emitted. Operators in non-UTC TZs see local TZ in logs.

## Level prefixes — right-padded to 5 chars

```
0 → "  ALL"
1 → "DEBUG"
2 → " INFO"
3 → " WARN"
4 → "ERROR"
5 → "FATAL"
```

Note the **leading whitespace** on `ALL`, `INFO`, `WARN`. A grep for `"INFO"` works; a grep for `^INFO` would silently miss everything. This is the kind of detail a drop-in could break by default if it picks `tracing`'s default formatter (which emits `INFO` left-aligned, no leading space).

## Output destinations

- **Console**: stdout by default; stderr if `logger.log_to_stderr=true`.
- **File**: append mode (`fopen(..., "a")`).
- Independent level thresholds: `log_level_console` (default 2=Info), `log_level_file` (default 1=Debug).

File flushes ~every 1s; stdout/stderr flushed after buffer swap.

## Rotation

- Daily, at midnight local time.
- Rotated file renamed via `rename()` to `<log_file>.YYYY-MM-DD`.
- Original path reopened.
- Driven by a `next_log_rotate` timestamp checked in the logging hot path.

There is no size-based rotation, no compression, no retention policy. Logrotate-style external tooling has no native hook.

## Special markers operators may grep

- `LOGGER OVERRUN:` — buffer exhaustion (lossy log, indicates pressure)
- The padded `[function_name_44chars]` is grep-friendly for filtering by module
- `FATAL` only on init paths in practice (the gateway doesn't FATAL during steady-state per the surveyed code)

## Drop-in implications

**Hard to match bit-exact in Rust** without a custom `tracing_subscriber` formatter. Default `tracing-subscriber` output is:

```
2026-06-01T15:23:45.123456Z  INFO datum_gateway::stratum: message
```

— ISO-8601 with timezone, no millisecond truncation, module path instead of `[function_name_padded_44]`.

To match the C gateway:
1. Custom formatter that emits `%Y-%m-%d %H:%M:%S.%03d` in local time.
2. Custom level rendering: right-pad to 5 chars (`" INFO"`, `" WARN"`, `"ERROR"`, `"FATAL"`, `"DEBUG"`, `"  ALL"`).
3. Custom field rendering: `[function_name_padded_44]` — but this is harder; `tracing` spans don't map cleanly to function names (they're explicit `instrument` decorations or `info_span!` calls).
4. Daily rotation via `tracing-appender` `Rotation::DAILY`, but the suffix format is `YYYY-MM-DD` and `tracing-appender` defaults to that — match achievable.

**Negotiable**: the function-name padding is the costliest part. Reasonable fallback: emit module path padded to 44 chars, document in CHANGELOG. Operator alert rules for level/timestamp would still work; only filters keyed on specific `[function_name]` strings break.

**Improvements the drop-in should add** (additive, doesn't break grep):
- Optional JSON output mode (gated by `logger.format=json`) for ELK/Loki ingestion.
- Optional `OTEL` export.
- UTC timestamp option (`logger.utc=true`).

## Justification

Operators run their alerting against these log lines; many have copy-pasted regexes from forum threads. The format is part of the de-facto contract. Documenting it precisely lets us make explicit decisions about which dimensions to preserve bit-exact and which to label as breaking-with-CHANGELOG.
