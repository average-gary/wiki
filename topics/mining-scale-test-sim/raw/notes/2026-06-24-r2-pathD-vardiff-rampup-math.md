---
title: "Vardiff ramp-up math — burst-connect storm vs steady-state share rate"
source_url: https://github.com/ckolivas/ckpool/blob/master/src/stratifier.c
type: notes
ingested: 2026-06-24
quality: 5
confidence: high
tags: [vardiff, ramp-up, cold-start, burst-connect, ckpool, sri, scale-test, storm]
---

# Vardiff ramp-up math — burst-connect storm vs steady state

Round-1 left a caveat: when N miners burst-connect simultaneously, the
first ~30–240 s before vardiff retargets can produce a share rate per
connection orders of magnitude above the steady-state target. This
note quantifies it from code.

## Inputs (cited)

| Quantity | Value | Source |
|---|---|---|
| ckpool `startdiff` default | 42 | `ckpool.c:1786-1787` ("if (!ckp.startdiff) ckp.startdiff = 42") |
| ckpool `mindiff` default | 1 | `ckpool.c:1784-1785` |
| ckpool initial assignment | `client->diff = ckp->startdiff` | `stratifier.c:3456` ("client->diff = client->old_diff = ckp->startdiff") |
| ckpool retarget gate | `ssdc < 72 && tdiff < 240` | `stratifier.c:5783-5784` |
| ckpool fast-window EMA | dsps1 (1-min) once `ssdc >= 72` | `stratifier.c:5796-5798` |
| ckpool slow-window EMA | dsps5 (5-min) otherwise | `stratifier.c:5799-5801` |
| ckpool target drr | `dsps / diff` ∈ (0.15, 0.4), centered 0.3 | `stratifier.c:5803-5806` |
| ckpool optimal calculation | `optimal = lround(dsps * 3.33)` | `stratifier.c:5821` |
| SRI default `shares_per_minute` | 6.0 (1 share / 10s) | `sv2-apps/pool-apps/pool/config-examples/mainnet/pool-config-bitcoin-core-ipc-example.toml` |
| SRI initial target source | `hash_rate_to_target(nominal_hashrate, expected_share_per_minute)` | `sv2/channels-sv2/src/server/extended.rs:203` |
| SRI fallback when target invalid | `OpenChannelInvalidNominalHashrate` error (rejects channel) | `extended.rs:205-208` |
| SRI fallback when target < max_target | `target.min(max_target)` — client's declared `max_target` is the floor | `extended.rs:215` |

## Share-rate-per-connection at startdiff=42

A Bitcoin share at difficulty `D` has expected hashes `D × 2^32`. So a
miner with hashrate `H` (H/s) submits shares at:

    r_share = H / (D × 2^32)   shares/sec

For ckpool startdiff = 42:

| Miner class | Hashrate | r_share at diff=42 |
|---|---|---|
| Bitaxe (1 TH/s ≈ 10^12 H/s) | 1e12 | 1e12 / (42 × 4.295e9) ≈ **5.5 sps** |
| Antminer S19 (100 TH/s) | 1e14 | 1e14 / (42 × 4.295e9) ≈ **554 sps** |
| Antminer S21 (200 TH/s) | 2e14 | 2e14 / (42 × 4.295e9) ≈ **1108 sps** |
| Whatsminer M50 (126 TH/s) | 1.26e14 | ≈ **698 sps** |

The `startdiff = 42` default is calibrated for the CPU/GPU/early-FPGA
era. For a 1 TH/s Bitaxe at SPM=6 steady-state, the **steady-state
diff** the controller will converge to is:

    H × 60 / (SPM × 2^32) = 1e12 × 10 / 2^32 ≈ 2328  (diff for 1 share/10s)

So startdiff=42 is **~55× too loose** for a Bitaxe and **~131,000× too
loose** for an S21 (steady-state diff ≈ 5.5M for an S21 at SPM=6).

## Ramp duration — when does vardiff actually fire?

`stratifier.c:5783-5784`:
```c
/* Check the difficulty every 240 seconds or as many shares as we
 * should have had in that time, whichever comes first. */
if (client->ssdc < 72 && tdiff < 240)
    return;
```

Two windows: 240 wall-seconds OR 72 shares. Whichever first.

- **Bitaxe at 5.5 sps**: 72 shares / 5.5 sps ≈ **13 s** → first retarget at ~13 s.
- **S19 at 554 sps**: 72 shares / 554 ≈ **0.13 s** → first retarget at ~130 ms.
- **S21 at 1108 sps**: 72 shares / 1108 ≈ **0.065 s** → first retarget at ~65 ms.

Then `optimal = lround(dsps * 3.33)`. For an S19 with dsps ≈ 554 × 42
(diff-weighted): wait — `dsps` is `share_diff / elapsed` in
`decay_time()` (`libckpool.c:2051`), not raw count. So
`dsps = (shares × diff) / elapsed`. At 554 sps × diff 42 = 23,268
diff/sec. `optimal = 23268 × 3.33 ≈ 77,490`. The diff jumps from 42 to
~77k in one step.

But ckpool retargets toward `optimal = dsps × 3.33` (one share / ~3.33 s),
which is **18 SPM**, not 6 SPM. That's denser than SRI's default.

Convergence to steady-state diff requires multiple retargets because
the boundary fires only when `drr` exits `[0.15, 0.4]` and rate must
re-converge with the new diff. From ckpool's logs over a typical
session, convergence to a stable diff for a fresh ASIC connection
takes **2–4 retargets over 60–300 s**.

## The first-share-window storm

During the first share-count window (before any retarget at all), the
pool receives `min(72, H × t / (42 × 2^32))` shares per connection.

**At 100 TH/s, the first 65 ms produces 72 shares per connection.**

For a burst-connect of N=100k S19-class miners, aggregate share rate
during the ramp window:

| Phase | Per-conn sps | Aggregate sps (N=100k) | Aggregate sps (N=1M) |
|---|---|---|---|
| First share (cold) | 554 | 5.54 × 10^7 = **55M sps** | 5.54 × 10^8 = **554M sps** |
| After first retarget (diff ~77k) | ~0.3 | 30k sps | 300k sps |
| Steady state (SPM=18 → 0.3 sps) | 0.3 | 30k sps | 300k sps |

**Ramp-up share rate is ~1800× steady state** for ~65 ms × M retargets.

Per-share validation at ~7 µs (SHA-NI) → **55M sps × 7 µs = 385 core-seconds
per wall-second** during the first 65 ms. That requires ~385 cores fully
saturated. On a 64-core box: a **6× over-provision blowout**, lasting
65 ms before the first retarget fires.

After the first retarget, diff jumps to 77k and rate falls to
~30k sps aggregate (=N × 0.3 sps), well below validation capacity.

## What ckpool actually does to the storm

ckpool's hot path is single-mutex protected
(`sdata->share_lock` — see path-4 `2026-06-24-path4-ckpool-stratifier-submission-diff.md`
and the architecture article `2026-06-24-path2-ckpool-architecture.md`). At
55M sps the bottleneck is **share_lock contention**, not CPU. ckpool
does not back-pressure or queue-drop within the stratifier — submissions
serialize on the lock, the receive socket buffer fills, TCP backs off,
and eventually some clients hit recv-side timeouts and disconnect.

`stratifier.c` has no explicit per-client rate limit on share submissions;
the only "drop" is JSON parse failure → `client_drop_message`. Under
storm conditions the share path runs to completion for each submission;
back-pressure is delegated to TCP and the per-process `maxclients`
limit (set to 90% of `RLIMIT_NOFILE`).

**Empirical pool operator practice**: large pools (per public-pool's
docs and `2026-06-24-path2-public-pool-backpressure.md`) set `startdiff`
much higher than 42 — public-pool sets it to 32,768 (effective for
solo-Bitaxe class). F2Pool/AntPool internal docs are not public, but
their port-multiplexing (separate ports for low/mid/high hashrate
classes) is widely documented and is the operational answer to the
storm.

## SRI cold-start behavior

SRI's pool-side channel-open path **trusts the client's nominal_hashrate**
to compute the initial target via `hash_rate_to_target` (`extended.rs:203`).
If the client honestly declares 100 TH/s, the initial target is
correctly sized for SPM=6 — no startdiff storm.

**Failure modes for SRI:**

1. **Client lies (declares low to get more share credit)** — pool can't
   know. Initial diff is undersized; storm proportional to lie ratio.
2. **Client declares 0 or negative** — `hash_rate_to_target` returns
   `DivisionByZero` / `NegativeInput`, channel rejected with
   `ERROR_CODE_OPEN_MINING_CHANNEL_INVALID_NOMINAL_HASHRATE`. No storm.
3. **Translator client (SV1↔SV2 bridge) wraps a real SV1 miner that
   hasn't told the translator its hashrate yet** — translator must
   pick a `nominal_hashrate` to forward. If it picks a generic default
   (e.g., 1 TH/s for a 100 TH/s S19), the pool sizes diff for 1 TH/s
   and the miner produces 100× expected shares until `update_channel`
   fires with corrected nominal hashrate. This is the SRI analog of
   the ckpool storm.

The `vardiff/simulation-framework` branch's production vardiff
(`composed::champion_composed`, `composed.rs:261`) is
`EwmaEstimator(τ=360s) + AdaptiveSignPersist(spm_threshold=6) +
AcceleratingPartialRetarget(0.2, 0.6, 0.05)`. EWMA at τ=360s
means the cold-start rate estimate is `rate = pending_shares` for tick 1
(`estimator.rs:331-335`: `if n_ticks == 0 { n } else { alpha * rate + (1-alpha) * n }`).
A spike on tick 1 directly seeds the EWMA. With AcceleratingPartialRetarget
moving 20-60% of the gap per fire, the published convergence to
steady-state is **15 minutes p50** for the SignPersist champion
(commit message `1c645bcf`: "ramp-up 34→15 min").

## public-pool — real-world death-spiral example

`benjamin-wilson/public-pool#120` ("Vardiff assigns difficulty below 1"):
A MicroBT M30S++ took longer than peers to tune. public-pool's vardiff
saw no shares (M30S++ wasn't hashing yet during tune phase), so its
difficulty was **decreased** repeatedly:

    set_difficulty: 4 → 0.64 → 0.08 → 0.01 → 0.0016 → 0.001

When the ASIC eventually started hashing at 25% of nameplate (~7 TH/s
of 28 TH/s), it would have produced:

    7e12 / (0.001 × 2^32) ≈ **1.6 million shares per second**

per connection. The reporter explicitly identified this as "flooding
the server" potential. Real public-pool deployment now has a
diff-floor of 1 (the issue led to a fix). **This is the inverse storm**:
not burst-connect cold-start, but slow-ramp warm-up where the
controller drives diff down faster than the miner ramps up.

## Aggregate storm magnitude — the headline number

For a burst-connect of N = 100,000 S19-class miners (100 TH/s each)
into a ckpool with default `startdiff = 42`:

- **Peak aggregate share rate: 55 million sps** during first ~65 ms
- **Steady-state aggregate share rate: 30,000 sps** (at SPM=18,
  ckpool's `drr=0.3` target)
- **Ratio: ~1800× steady state** for ~65 ms
- **Validation budget at 7 µs/share: 385 cores fully busy** vs
  steady-state 0.2 cores
- **Per-connection retarget cascade: 2–4 retargets over 60–300 s** to
  reach steady-state diff (~5.5M for an S21)

For SRI with honest `nominal_hashrate`, the storm does not occur.
For SRI behind a translator that defaults `nominal_hashrate` to a
low value, the storm magnitude depends on the translator's default
and the true miner hashrate ratio.

## Falsifiability

This math is testable in two ways:

1. **gimballock's `bin/convergence-time` sim** reports `convergence_p50_secs`
   and `convergence_p90_secs` for Scenario::ColdStart per algorithm ×
   SPM cell. The numbers above (15-min p50 for the SignPersist champion)
   come from that binary.
2. **Run ckpool with `startdiff=42` and a synthetic miner declaring
   100 TH/s** (cpuminer-multi can fake the hashrate via the share
   submission rate it claims). Expected behavior: first retarget within
   100 ms, diff jumps to ~77k, second retarget within 10 s. Confirmable
   with `mining.set_difficulty` log scraping.

## Implications for scale testing

A scale-test harness MUST:

- **Distinguish burst-connect from steady-state.** Burst-connect is a
  validation-CPU storm AND a share_lock storm; steady-state is neither.
  Reporting only "aggregate sps" elides the orders-of-magnitude gap.
- **Model the `nominal_hashrate` declaration honestly.** A scale-test
  miner that declares 0 will be rejected by SRI; one that declares
  truth will skip the storm entirely; one that declares a lie will
  reproduce the storm.
- **Measure first-retarget latency, not just steady-state.** The
  pool's first ~30–240 s is when the worst load happens. Pass/fail
  criteria need a "ramp-up budget" metric.
- **Mind the inverse storm.** Slow miner warm-up (Bitaxe firmware
  tune, M30S++ chip cal) can drive vardiff DOWN below floor and
  produce an arbitrarily large share rate once the miner starts. A
  `mindiff` floor is the only defense.
