# OCEAN Miner-Base Composition: SV1 vs SV2 Firmware Estimate

**Date:** 2026-06-01
**Sub-question:** Q4 / dual-protocol drop-in
**Confidence:** Low–Medium. Direct OCEAN miner data is not public. This is inferred from
firmware-vendor coverage, public mining-Twitter discussion patterns, and OCEAN's own
positioning as a sovereignty-focused pool (which biases toward home-miner / Solo-Bitaxe
demographics).

## Headline estimate (uncertain)

As of mid-2026, the OCEAN miner population is approximately:

- **75–90% SV1-only** (stock vendor firmware on Antminer / Whatsminer / Avalon, plus
  Bitaxe and other non-vendor open hardware that ships SV1 by default).
- **10–25% SV2-capable** (BraiinsOS+ on supported Antminer models, plus a small fraction
  of Bitaxe variants that have flashed SV2-capable open firmware).
- **0% SV2-only**: Every SV2-capable firmware also speaks SV1 as a fallback, so an SV2
  drop-in that drops SV1 support would brick an unbounded fraction of the fleet but a
  pure-SV1 drop-in would brick zero miners.

**Implication for the dual-protocol decision: SV1 support is NOT dead weight, it is the
load-bearing path.** Removing it would be a fleet-bricking event for OCEAN. SV2 support is
forward-looking optionality for the sliver of operators who run BraiinsOS+ and want the
benefits (per-miner template selection, better encryption, lower latency).

## Evidence sources (all weak, sum to "directional")

### 1. BraiinsOS+ supported hardware (only firmware vendor with first-class SV2 client)

From the Braiins academy compatibility page (`academy.braiins.com/os/plus-en/Compatibility.html`,
fetched 2026-06-01 — note: returns a generic 404-substitute on direct fetch; data here is
from earlier knowledge and the redirect chain `docs.braiins.com → academy.braiins.com`):

BraiinsOS+ supports a known list of Antminer models including S9, S17, S19, S19j, S19j Pro,
S19 XP, S21 (added per a 2024 announcement), and limited Whatsminer / Canaan support. Each
supported model gets full SV2 client functionality. **However, BraiinsOS+ is a paid /
opt-in install** and does not ship from Bitmain. Owners must actively flash it. The
fraction of S19-class Antminers running BraiinsOS+ globally is generally quoted in the
single-digit-percent range.

### 2. Bitmain stock firmware: SV1 only

Stock Antminer firmware (LuxOS being a separate alternative also primarily SV1) does not
ship an SV2 stratum client as of 2026. Bitmain has not publicly committed to SV2. This is
the dominant firmware in the network globally and is reasonably assumed dominant on OCEAN
absent contrary data.

### 3. OCEAN's demographic skew

OCEAN markets to sovereignty-focused / decentralization-focused / home miners. This
demographic correlates with:

- Higher than average rate of BraiinsOS+ adoption (sovereignty-aligned).
- Higher than average rate of Bitaxe / open-hardware solo-style miners (mostly SV1).
- Lower than average rate of large-scale farm operators (who tend toward Foundry / FPPS).

Net: OCEAN's SV2 fraction is plausibly higher than network-average (single-digit) but
still a minority. A 10–25% range is a reasonable working assumption pending direct data.

### 4. Bitaxe-class hardware

Bitaxe and open-source ASIC hardware overwhelmingly ship SV1. SV2 support exists in
firmware forks but is not the default. Bitaxe operators on OCEAN are SV1.

### 5. Datum_gateway README itself

From `OCEAN-xyz/datum_gateway/README.md`:

> "Currently the DATUM Gateway supports communication with mining hardware using the
> Stratum v1 protocol with version rolling extensions (aka 'ASICBoost')."

OCEAN itself ships an SV1-only gateway in 2026. If their miner base were predominantly
SV2-capable, prioritizing SV2 in the C gateway would be obvious. They have not. This is a
revealed-preference signal that the SV1 path matters.

### 6. The "Sv2 wouldn't be a viable solution" quote

From `ocean.xyz/docs/datum`:

> "after a long development period, it became clear that Sv2 wouldn't be a viable solution
> in the near term. Further technical challenges convinced us that a new framework was
> necessary."

OCEAN explicitly chose to build DATUM rather than depend on SV2. This means OCEAN's
strategic outlook is "SV2 is not the path" — so they have not been pressuring their miner
base to upgrade firmware.

## What this implies for switch-day risk

If the Rust drop-in dropped SV1: ~80% of OCEAN's miner-fleet hashrate goes dark
instantly. The pool's TIDES window resets to zero contribution from the affected operators
until they reconfigure their miners to a different pool. This is an unrecoverable
reputational event for both the drop-in and OCEAN.

If the Rust drop-in keeps SV1 and adds SV2: zero miner-side change required for the SV1
fleet. SV2-capable miners gain optional access to the new path. Strict superset.

**Decision: SV1 support is mandatory in v1.0 of the drop-in.** SV2 is the differentiator.

## Honest uncertainty section

This article's percentages are NOT derived from OCEAN telemetry. They are directional
estimates. Things that would sharpen them:

- A Twitter / Stacker News post by an OCEAN operator citing their miner mix.
- BraiinsOS+ install-base data from Braiins (not public AFAIK).
- An OCEAN forum / discord poll (haven't found one).
- DATUM gateway connection-string user-agents — the C gateway logs miner UA strings,
  but log dumps are not public.

For now, the **safe-design conclusion holds even under strong uncertainty**: the dual-
protocol commitment is correct because it is strictly safer than SV2-only across all
plausible miner-base distributions, at marginal additional implementation cost (the
SRI `stratum-translation` crate already exists and is maintained).

## What to do if SV1-only fraction turns out to be lower (e.g., 30%)

Even in that case, dual-protocol is still correct in v1.0 because:

- Bricking 30% of operators on switch day is still catastrophic.
- The cost of SV1 support is a one-time integration with `stratum-translation` (maintained
  upstream by SRI).
- SV1 sunset can be a v2.0 decision once telemetry shows usage.

## Open data request for Q1/Q2/Q3 agents (if not covered)

Has any of the parallel research found:

- A Bitmain announcement of SV2 stock-firmware support?
- A Whatsminer / MicroBT announcement?
- An OCEAN-published miner mix breakdown?
- Pool-side SV2 deployment numbers (Braiins Pool / DEMAND / Public Pool)?

If yes, these should be cross-referenced into the synthesis to refine the percentage
estimates here.
