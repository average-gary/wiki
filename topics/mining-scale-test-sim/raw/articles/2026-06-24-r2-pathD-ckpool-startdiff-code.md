---
title: "ckpool stratifier.c — quoted code for startdiff, ssdc, vardiff_thread (the ramp-up gates)"
source_url: https://github.com/ckolivas/ckpool/blob/master/src/stratifier.c
type: article
ingested: 2026-06-24
quality: 5
confidence: high
tags: [ckpool, stratifier, startdiff, ssdc, vardiff, cold-start, code-quote, source-of-truth]
---

# ckpool stratifier.c — the ramp-up code paths, quoted

The Round-1 thesis flagged vardiff ramp-up as a caveat. The exact
semantics of when a fresh ckpool connection retargets, and what
controls the initial diff, live in three files: `ckpool.c` for
defaults, `stratifier.c` for the runtime, and `libckpool.c` for the
EWMA primitives.

## Defaults — ckpool.c

```c
/* ckpool.c:1479-1482 — config parse */
json_get_int64(&ckp->mindiff, json_conf, "mindiff");
json_get_int64(&ckp->startdiff, json_conf, "startdiff");
json_get_int64(&ckp->maxdiff, json_conf, "maxdiff");

/* ckpool.c:1784-1787 — fallback to defaults */
if (!ckp.mindiff)
    ckp.mindiff = 1;
if (!ckp.startdiff)
    ckp.startdiff = 42;
```

`startdiff = 42` is the default. Operator override via JSON config
key `"startdiff"`. `mindiff = 1` is the absolute floor —
miners cannot be assigned a diff below 1 once the pool is configured.

## Initial assignment — stratifier.c

```c
/* stratifier.c:3456 — new client */
client->diff = client->old_diff = ckp->startdiff;
if (ckp->server_highdiff && ckp->server_highdiff[server]) {
    client->suggest_diff = ckp->highdiff;
    if (client->suggest_diff > client->diff)
        client->diff = client->old_diff = client->suggest_diff;
}
```

Every new client starts at `ckp->startdiff` unless the *listening
server* (one of the `serverurl[]` entries) has its `highdiff` flag set,
in which case `client->diff = ckp->highdiff`. This is the
**port-class** mechanism big pools use to escape the `startdiff=42`
storm: one port at startdiff=42 for low-hashrate, another at
highdiff=65536 for ASICs. Neither is honest to the miner's nominal
hashrate; the operator picks by port assignment.

## The retarget gate — stratifier.c add_submit()

```c
/* stratifier.c:5721-5851 — the whole vardiff function */
static void add_submit(ckpool_t *ckp, stratum_instance_t *client,
                       const double diff, const bool valid, const bool submit)
{
    ...
    /* stratifier.c:5778-5784 — the gate */
    client->ssdc++;
    bdiff = sane_tdiff(&now_t, &client->first_share);
    tdiff = sane_tdiff(&now_t, &client->ldc);

    /* Check the difficulty every 240 seconds or as many shares as we
     * should have had in that time, whichever comes first. */
    if (client->ssdc < 72 && tdiff < 240)
        return;
```

`ssdc` = "shares since diff change". `bdiff` is seconds since the
first share (lifetime). `tdiff` is seconds since the last diff change
(`ldc` = last diff change).

The function returns early — **no retarget** — until either:

- 72 shares have been submitted since the last diff change, OR
- 240 wall-seconds have passed since the last diff change.

72 shares is `240s / 3.33s` — the share count corresponding to one full
"target window" at ckpool's `drr=0.3` design point. The gate ensures
the EMA has accumulated enough evidence to be statistically meaningful.

## The adaptive window switch — stratifier.c

```c
/* stratifier.c:5796-5801 */
/* Diff rate ratio.
 * If shares are coming in fast, calculate based on
 * the one minute rolling average for quick diff adjustment, otherwise
 * use the 5 minute rolling average */
if (client->ssdc >= 72) {
    bias = time_bias(bdiff, 60);
    dsps = client->dsps1 / bias;
} else {
    bias = time_bias(bdiff, 300);
    dsps = client->dsps5 / bias;
}
drr = dsps / (double)client->diff;
```

`dsps1` and `dsps5` are 1-minute and 5-minute EMAs of
`(share_diff / elapsed)`, updated on every share in `decay_client`
(stratifier.c:5202-5206). `time_bias(t, period) = 1 - 1/exp(t/period)`
(stratifier.c:5711-5719) is the warmup correction.

The fast-window switch (`ssdc >= 72`) lets the controller respond
quickly during ramp-up when shares are coming in fast; otherwise it
uses the slow 5-min window for stability.

## The hysteresis band — stratifier.c

```c
/* stratifier.c:5803-5806 */
drr = dsps / (double)client->diff;

/* Optimal rate product is 0.3, allow some hysteresis. */
if (drr > 0.15 && drr < 0.4)
    return;
```

No retarget unless `drr` exits `[0.15, 0.4]` (asymmetric around 0.3).
This is the gimballock `CKPOOL_INVESTIGATION.md` "Hysteresis band"
point. Combined with the share-count gate above, the controller is
**doubly gated**: it requires both evidence (72 shares or 240 s) AND
deviation (drr outside hysteresis band) before firing.

## The retarget rule — stratifier.c

```c
/* stratifier.c:5808-5822 */
/* Client suggest diff overrides worker mindiff */
if (client->suggest_diff)
    mindiff = client->suggest_diff;
else
    mindiff = worker->mindiff;
/* Allow slightly lower diffs when users choose their own mindiff */
if (mindiff) {
    if (drr < 0.5)
        return;
    optimal = lround(dsps * 2.4);
} else
    optimal = lround(dsps * 3.33);
```

Two sub-cases:

- **No miner-chosen mindiff**: `optimal = round(dsps × 3.33)` →
  targets one share per 3.33 s ≈ **18 SPM**.
- **Miner-chosen mindiff**: `optimal = round(dsps × 2.4)` → targets
  one share per 2.4 s ≈ **25 SPM**, denser. (And retarget only fires
  if `drr ≥ 0.5`, a tighter trigger.)

## EMA primitive — libckpool.c

```c
/* libckpool.c:2051-2069 — the decay_time EWMA primitive */
void decay_time(double *f, double fadd, double fsecs, double interval)
{
    double ftotal, fprop, dexp;

    if (fsecs <= 0)
        return;
    dexp = fsecs / interval;
    /* Put Sanity bound on how large the denominator can get */
    if (unlikely(dexp > 36))
        dexp = 36;
    fprop = 1.0 - 1 / exp(dexp);
    ftotal = 1.0 + fprop;
    *f += (fadd / fsecs * fprop);
    *f /= ftotal;
    /* Sanity check to prevent meaningless super small numbers that
     * eventually underflow libjansson's real number interpretation. */
    if (unlikely(*f < 2E-16))
        *f = 0;
}
```

Called on every share submit (5202-5206 in stratifier.c) for the
1m/5m/1h/1d/1w windows. The `fadd / fsecs * fprop` increment is the
"per-share decay" pattern gimballock's CKPOOL_INVESTIGATION.md tried
(and failed) to port directly to a 60-s tick framework.

## Summary table — what ckpool actually gates

| Gate | Condition | Effect |
|---|---|---|
| Share-count | `ssdc < 72` | Skip retarget; let evidence accumulate |
| Time | `tdiff < 240 s` | Skip retarget; force minimum re-evaluation interval |
| Hysteresis | `drr ∈ (0.15, 0.4)` | Skip retarget; tolerate normal noise |
| Down-step protection | `optimal < diff && ssdc == 1` | Reset `ldc`, return (don't fall back on first share of new session) |
| Floor | `optimal = MAX(optimal, ckp->mindiff)` | Never below mindiff (default 1) |
| Ceiling | `optimal = MIN(optimal, ckp->maxdiff, network_diff)` | Never above maxdiff or network_diff |

The "burst-connect storm" risk lives entirely in the **interval before
the first gate clears** — specifically, the time it takes for the
fast-rate miner to submit 72 shares at `startdiff=42`:

```
72 shares / (H / (42 × 2^32))  seconds
= 72 × 42 × 2^32 / H
= 1.297e13 / H  seconds

H = 1e12 (Bitaxe, 1 TH/s):       12.97 s
H = 1e14 (S19, 100 TH/s):        0.130 s
H = 2e14 (S21, 200 TH/s):        0.065 s
```

For 100 TH/s+ ASIC class, **the first retarget fires in under 130 ms**.
This is the empirical answer to "how long does the storm last per
connection." Total storm duration for N simultaneously-connecting
S19s is `~130 ms + propagation` since each connection retargets
independently in its own thread (ckpool's stratifier is one global
thread but per-client state is independent).

## What changed when

The `startdiff=42` and `72/240` gates are present in ckpool from at
least 2014. Search across forks confirms no fork has changed these
defaults (see `gh api search/code?q=startdiff+stratum+filename:stratifier.c`
— asicseer-pool, rsksmart/ckpool, ctubio/ckpool, jlest01/ckpool all
keep the same `startdiff=42` and `if (client->ssdc < 72 && tdiff < 240)`).

Public-pool (a separate Node.js codebase, not a ckpool fork) handles
ramp differently and was where issue `#120` revealed the inverse
problem (diff falling below 1 due to a missing floor).
