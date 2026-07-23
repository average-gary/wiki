---
title: "Plan: JDC-as-Ark-payer — a verifiable SV2 sub-pool paying miners over an external Ark ASP (testnet4)"
type: plan
format: roadmap
supersedes_context: plan-ark-boarding-sv2-testnet4-trial-2026-07-20.md (pool-as-ASP variant)
sources:
  - topics/ark-boarding-sv2-mining/theses/ark-boarding-sv2-mining.md
  - topics/ark-boarding-sv2-mining/wiki/topics/thesis-analysis-viability.md
  - topics/ark-boarding-sv2-mining/wiki/concepts/sv2-extension-surface.md
  - topics/ark-boarding-sv2-mining/wiki/concepts/pure-receiver-and-liveness.md
  - topics/ark-boarding-sv2-mining/wiki/concepts/coinbase-maturity-and-reorg.md
  - topics/ark-boarding-sv2-mining/wiki/reference/alternatives-and-prior-art.md
  - topics/covenantless-ark/wiki/concepts/unilateral-exit-and-timeouts.md
  - topics/covenantless-ark/wiki/concepts/out-of-round-payments.md
  - topics/covenantless-ark/wiki/concepts/vtxo-lifetime-and-expiry.md
generated: 2026-07-20
architecture: external-ASP (JDC-as-Ark-payer sub-pool); Pool unchanged
target_asp: Second bark / barkd / captaind (self-hosted on testnet4 for the trial)
payout_model: OOR/arkoor sends from JDC-held Ark balance
funding_model: Pool → JDC over Lightning; JDC receives as a VTXO through the ASP gateway
---

# Plan: JDC-as-Ark-payer — a verifiable SV2 sub-pool paying miners over an external Ark ASP

> Generated from the [ark-boarding-sv2-mining](../_index.md) wiki (grounded in
> [covenantless-ark](../../covenantless-ark/_index.md) OOR/exit/lifetime concepts),
> plus a direct read of `demand-share-accounting-ext`, the local `stratum` fork,
> `~/repos/ark-settler`, and `~/repos/bark`.
>
> **Relationship to the earlier plan.** This *replaces* the pool-as-ASP design in
> `plan-ark-boarding-sv2-testnet4-trial-2026-07-20.md`. That plan had the Pool run a
> covenantless MuSig2 cosigning ceremony over the SV2 wire post-block-found. This
> plan **plugs into an existing Ark ASP instead**, which deliberately removes that
> ceremony — the ASP owns tree-signing and custody. What remains, and what this plan
> builds, is a **JDC that acts as a verifiable sub-pool paying its miners over Ark.**

## Executive Summary

Make the **JDC (Job Declarator Client) a self-contained Ark-paying sub-pool.** The
upstream **Pool is unchanged** — it pays the JDC **over Lightning** (the JDC presents
a BOLT-11/12 invoice; the Pool pays it like any other LN payout). Because the Ark
server is itself a **Lightning gateway**, that incoming LN payment **arrives directly
as a VTXO** in the JDC's Ark balance — no JDC LN node, no channels, no on-chain
boarding wait. The JDC then:

1. Runs **sub-tier share accounting** over its own downstream miners, reusing
   `demand-share-accounting-ext` in the **downstream direction** (JDC = accounting
   server; sub-miners = *verifying* clients). This is the extension used for its
   actual designed purpose — payout **verification** — at the tier where custody now
   lives.
2. Holds a **funded, matured Ark balance** in a `barkd` wallet — topped up by the
   Pool's Lightning payments, then **refreshed-to-harden** into round VTXOs (LN-receive
   VTXOs carry an ephemeral-key caveat + ~3-day lifetime that a refresh clears).
3. On each disburse trigger, translates sub-tier shares into `(ark_address, weight)[]`
   and **sends each miner an out-of-round (OOR/arkoor) VTXO** via **`ark-settler` →
   `barkd` → `captaind` (the ASP)** — reusing `~/repos/ark-settler` as-is.
4. Returns each miner a **VTXO receipt + client-side exit data** over a **slim new
   SV2 addressing/receipt extension** (`0x11–0x14`).

**What this buys vs the pool-as-ASP plan:** no MuSig2/tree/key-deletion code to
write; mainnet-mature Ark infra; miners land in a large, liquid Ark (real anonymity
set, Lightning-via-Boltz); and — critically — a **rolling matured Ark balance
decouples payouts from block-finding**, which *collapses the coinbase
maturity/reorg problem entirely* ([coinbase-maturity-and-reorg](../wiki/concepts/coinbase-maturity-and-reorg.md)).
This is essentially thesis follow-up #3 realized.

**What it costs (stated plainly):** the covenantless post-block-found *novelty* is
gone; there are now **two custodial surfaces** — the JDC (holds pending balance,
performs the send) and the ASP (covenantless 1-of-n custody). The mitigations are
that the **JDC's accounting is cryptographically verifiable** by its miners and the
**ASP custody has a unilateral-exit floor**. OOR VTXOs have **collusion-conditional
exit** (blockable only if JDC *and* ASP collude; safe if either is honest).

Deliverable is this plan; execution is separate. Effort assumes one engineer fluent
in the SRI stack; the Ark side is integration, not cryptography.

## Topology

```
         pays JDC's invoice over Lightning
   Pool ──────(BOLT-11/12)──────▶ captaind LN gateway ──arrives as VTXO──▶  JDC  ── barkd wallet
 (unchanged)                                                                 │      (refresh-to-harden → matured Ark balance)
                                                                             │
                                                                             │  sub-tier share accounting (demand-share-accounting-ext, downstream)
                                                                             │  shares → (ark_address, weight)[]
   downstream miners ──mine to JDC──▶ JDC translator                         │
        ▲                                                                    ▼
        │   VTXO receipt + exit data (0x11–0x14)                      ark-settler ──REST──▶ barkd ──gRPC──▶ captaind (ASP)
        └────────────────────────────────────────────────────────────────┘                          (covenantless, self-hosted testnet4)
```

The ASP is a **Lightning gateway** ([lightning-integration](../../covenantless-ark/wiki/concepts/lightning-integration.md)),
so the Pool's LN payment and the JDC's Ark funding are the *same event* — inbound
LN value is issued to the JDC as a VTXO with no JDC-side LN node or channels.

The **trust tiers**: Pool → (pays) → JDC → (sends OOR VTXOs via) → ASP → (holds) →
miner's VTXO, with the miner's **unilateral exit** as the ultimate floor.

## Architecture Decisions

### Decision 1: The JDC is the Ark payer; the Pool is untouched

**Context**: You want to plug into *existing* ASPs as a mining pool without becoming
one. An Ark round needs an always-online server/coordinator; rather than build that
(pool-as-ASP), delegate it to a real ASP and make the **JDC** the Ark *client* that
funds a balance and pays out.

**Decision**: Pool pays the JDC as a single miner (its business as usual). **All Ark
logic lives in the JDC.** The JDC is a sub-pool: it has its own downstream miners,
its own accounting, its own Ark wallet.

**Consequences**: Zero Pool-side changes — huge for adoptability. The JDC becomes a
**sub-custodian** of its miners' pending balances (a new trust surface, mitigated by
Decision 3's verifiable accounting). The "who are the n parties / where does the
cosigning key live" questions from the old plan **vanish** — the ASP owns signing.

### Decision 2: Send miners OOR/arkoor VTXOs from a matured JDC balance

**Context**: [out-of-round-payments](../../covenantless-ark/wiki/concepts/out-of-round-payments.md)
— Ark supports sending to others *out of round* (arkoor), asynchronously, without the
receiver being online at pay time. `~/repos/ark-settler` already implements weighted
proportional OOR distribution over `barkd` with crash recovery and dust filtering.

**Options considered**:
- **Miners join the ASP's rounds** → truly-unilateral board VTXOs (stronger exit),
  but reintroduces the full pure-receiver liveness/DoS problem and puts miners on the
  ASP's round cadence. Rejected for the trial.
- **OOR sends from JDC balance** → async, miner offline-friendly, reuses ark-settler.

**Decision** (your call): **OOR/arkoor sends** from the JDC's funded, matured Ark
balance.

**Consequences**: Payout is **decoupled from block-finding and from coinbase
maturity/reorg entirely** — the JDC pays from funds already boarded and matured. The
cost: OOR VTXOs are **collusion-conditional on exit** — blockable only if the JDC
(sender) *and* the ASP collude; safe if **either** is honest
([unilateral-exit-and-timeouts](../../covenantless-ark/wiki/concepts/unilateral-exit-and-timeouts.md)).
State this to miners explicitly.

### Decision 3: Reuse `demand-share-accounting-ext` DOWNSTREAM for verifiable sub-tier accounting

**Context**: The extension's designed purpose is payout **verification**, not custody
([sv2-extension-surface](../wiki/concepts/sv2-extension-surface.md)). In this
topology the JDC *is* a pool to its sub-miners, and it *is* a custodian — exactly the
situation the verification extension exists for.

**Decision**: Run the existing `0x00–0x10` share-accounting protocol with the **JDC
as server** and **sub-miners as clients**, so a sub-miner can audit that the JDC's
share→weight→payout mapping is fair before trusting it with pending balance. The JDC's
`NewBlockFound (0x03)` fires when the *upstream Pool* credits the JDC (a disburse
trigger), and sub-miners verify the window that determined their weights.

**Consequences**: The one genuinely trust-minimizing piece of this design. It turns
"trust the JDC sub-custodian" into "verify the JDC sub-custodian." No new custody
semantics in the extension — verification stays verification (no category error).

### Decision 4: Self-host captaind on testnet4 behind an ASP-client boundary

**Context**: The mining side is **testnet4**; bark/captaind have run on
signet/mutinynet/mainnet, and testnet4 support is unconfirmed. The *architecture* is
"external ASP" regardless of who hosts it.

**Decision**: For the trial, **self-host a `captaind` ASP + `barkd` on testnet4**,
reached through an **`AspClient` trait** so a hosted third-party ASP could be
swapped in later without touching the JDC logic. Target the **Second
bark/barkd/captaind** stack (`~/repos/bark`; ark-settler already speaks its REST API).

**Consequences**: Keeps the network matched (testnet4 end-to-end) while preserving
the "plug into existing ASP" story via the trait boundary. If testnet4 is
unsupported by captaind, fall back to **signet for the Ark leg** and document the
network split (mining=testnet4, Ark=signet) as a trial limitation.

### Decision 5: Miner liveness handled by delegated VTXO renewal

**Context**: VTXOs expire; refresh happens in ASP rounds
([vtxo-lifetime-and-expiry](../../covenantless-ark/wiki/concepts/vtxo-lifetime-and-expiry.md)).
A miner that never comes online loses funds to the operator sweep at `T_exp`.

**Decision**: Recommend miners authorize **delegated VTXO renewal** (Ark Labs "Adios
Expiry") to the JDC or a third party, keeping unilateral-exit rights. The JDC
surfaces expiry timing in the receipt (`0x11`/`0x14`).

**Consequences**: Softens (doesn't remove) the passive-payee liveness burden. A miner
who wants zero trust can decline delegation and refresh/exit itself.

### Decision 6: Pool funds the JDC over Lightning; the ASP gateway issues it as a VTXO

**Context**: The Ark server **is a Lightning gateway** — incoming Lightning value
"arrives as VTXOs, with no channels and no inbound liquidity required of the user"
([lightning-integration](../../covenantless-ark/wiki/concepts/lightning-integration.md)).
So the Pool→JDC payment rail and the JDC's Ark-funding step **collapse into one
event**: the JDC presents a BOLT-11/12 invoice, the Pool pays it, and captaind issues
the value to the JDC as a fresh VTXO.

**Options considered**:
- **On-chain payout + boarding** — Pool pays the JDC on-chain, JDC boards into Ark
  (six-confirmation wait, boarding tx, `~90-day` boarding exit path). Slower, needs a
  JDC on-chain wallet + boarding flow. Rejected as the primary rail.
- **LN payout via the ASP gateway** (chosen) — no JDC LN node, no channels, no
  on-chain boarding wait; funding is instant and already in-Ark.

**Decision** (your call): **Pool pays the JDC over Lightning**, received through the
ASP gateway as a VTXO. The JDC runs **no LN node of its own**.

**Consequences & required handling**:
- **Ephemeral-key caveat on LN receives**: an LN-receive VTXO is trusted-until-refreshed
  ("you are trusting that the server actually deleted the ephemeral key; if retained,
  the server could double-spend the HTLC input"). **Refresh-to-harden**: the JDC MUST
  refresh inbound LN funding into a round VTXO before treating it as settled treasury.
- **Short ~3-day LN-receive lifetime** (vs ~28-day round VTXOs) → the refresh is also a
  liveness requirement, not just a hardening step. Automate it on receive.
- **Failure mode**: LN payment failure revokes the HTLC cooperatively and returns funds
  to the Pool (the sender-safeguard path) — no stuck state.
- Fees: LN routing + Ark server fees on the inbound leg (Pool-side cost); receiving is
  currently free on Second's server.
- The **`AspClient` trait gains `invoice()` + `await_receive()`** (BOLT-11/12 generation
  and receive-detection); everything downstream (OOR payouts, accounting, exit) is
  unchanged.

## Repositories in play

| Repo | Local path | Role |
|---|---|---|
| `demand-share-accounting-ext` | `~/repos/share-accounting-ext` (this repo) | Slim addressing/receipt messages `0x11–0x14`; sub-tier accounting reused downstream |
| `stratum` fork | `~/repos/stratum` (`average-gary`/`ethan`) | JDC-side handlers: sub-tier accounting server + Ark-payer orchestration |
| `sv2-apps` | `~/repos/sv2-apps` | The JDC role that hosts sub-miners and drives payouts; Pool role unchanged |
| `ark-settler` | `~/repos/ark-settler` | **Reused as-is** — weighted OOR distribution over barkd, crash recovery, dust filtering |
| `bark` / `barkd` / `captaind` | `~/repos/bark` | The ASP + wallet stack; self-hosted on testnet4 behind the `AspClient` boundary |
| Template Provider + bitcoind | `~/repos/sv2-tp`, `~/repos/bitcoind-testnet4-startos` | testnet4 mining substrate (unchanged from mining setup) |

## Implementation Phases

### Phase 1: testnet4 mining + self-hosted Ark ASP (estimated effort: 4–6 days)

**Goal**: SRI Pool→JDC→sub-miners mining testnet4, alongside a self-hosted
`captaind`+`barkd` reachable by the JDC, with a funded JDC Ark balance.

**Tasks**:
- [ ] Bring up testnet4 `bitcoind` + Template Provider + SRI **Pool + JDS + JDC**
      (per the mining setup); attach real hashrate or `cpuminer` downstream of the JDC.
- [ ] Confirm the Pool pays the JDC as a single miner (JD coinbase output is the
      cleanest: the JDC's declared job carries a payout output the JDC controls).
- [ ] Stand up **`captaind` (ASP) + `barkd` (wallet)** from `~/repos/bark`, **with the
      Lightning gateway enabled** (the ASP's LN node(s)). Attempt **testnet4**; if
      unsupported, run the Ark leg on **signet** and record the network split as a
      documented limitation (Decision 4). *Note: the LN gateway raises the bar on the
      self-hosted ASP — confirm captaind's gateway works on the chosen network early.*
- [ ] Fund the **JDC's barkd wallet over Lightning** (Decision 6): the JDC generates a
      BOLT-11/12 invoice; pay it from the Pool's LN wallet (or any LN wallet for the
      trial). Confirm the value arrives as a VTXO. **Refresh-to-harden** it into a round
      VTXO (clears the ephemeral-key caveat + resets the ~3-day lifetime).
- [ ] Smoke-test `ark-settler` against the ASP: a manual `(addr, weight)[]` disburse
      lands OOR VTXOs at two test miner addresses.

**Design decisions flagged**: funding is a **treasury** problem now (keep the JDC's
Ark balance topped up via LN invoices — Decision 6), not a per-block problem —
maturity/reorg no longer gate payouts (Decision 2). LN-receive VTXOs must be
refreshed-to-harden before counting as settled treasury.

**Dependencies**: None.

**Validation**: the Pool's LN payment to the JDC's invoice arrives as a VTXO and
refreshes into a hardened balance; `barkd` shows a matured JDC balance; a manual
ark-settler run distributes to 2 addresses with correct proportional amounts and dust
filtering; sub-miner shares reach the JDC and `ShareOk` returns.

**Wiki grounding**: [alternatives-and-prior-art](../wiki/reference/alternatives-and-prior-art.md)
(OCEAN/DATUM ~100-payout ceiling this beats; ark-settler lineage); [vtxo-lifetime-and-expiry](../../covenantless-ark/wiki/concepts/vtxo-lifetime-and-expiry.md).

**Definition of done**: End-to-end substrate up — testnet4 mining into the JDC, a
self-hosted ASP **with LN gateway**, a JDC Ark balance **funded over Lightning and
refreshed-to-harden**, and a working manual OOR disburse.

---

### Phase 2: Slim SV2 addressing/receipt extension `0x11–0x14` (estimated effort: 3–5 days)

**Goal**: Let a sub-miner register an Ark address with the JDC and receive a VTXO
receipt + exit data — the only new wire surface this architecture needs. **No
nonce/partial-sig ceremony messages** (the ASP owns signing).

**Message allocation** (extends `extension.md` §3; `EXTENSION_TYPE=32`; channel_bit
`false`):

| Type | Name | Dir | Payload |
|---|---|---|---|
| `0x11` | `RegisterArkAddress` | C→S | `request_id:U32`, `ark_address:STR0255`, `renewal_delegation:U8` (0=none,1=delegate-to-JDC) |
| `0x12` | `RegisterArkAddress.Success` | S→C | `request_id:U32`, `min_payout:U64` (dust floor), `vtxo_expiry_hint:U32` |
| `0x13` | `VtxoPaid` | S→C | `request_id:U32`, `block_hash:U256` (the window that set weights), `vtxo_id:U256`, `amount:U64`, `exit_data:B0_16M` (client-side exit encoding — persist!) |
| `0x14` | `VtxoPaid.Ack` | C→S | `request_id:U32`, `vtxo_id:U256` (miner confirms receipt + storage) |

**Files — `demand-share-accounting-ext`**:
- `src/const.rs`: `MESSAGE_TYPE_REGISTER_ARK_ADDRESS=0x11` … `0x14` + `CHANNEL_BIT_*`.
- `src/register_ark_address.rs`, `src/vtxo_paid.rs`: new structs (pattern from
  `new_block_found.rs`; `exit_data:B0_16M` big-blob like `NewTxs`).
- `src/lib.rs`: `mod` + `pub use`.
- `src/parser.rs`: add 4 variants across all 6 match arms + the type enum + both
  `TryFrom`s + `into_static()` (the same 6-place wiring the crate already shows).
- `extension.md`: append `0x11–0x14` to §2 and the §3 table; note these are for the
  **downstream JDC↔sub-miner** connection.

**Files — `stratum` fork / `sv2-apps`**: JDC-side handlers for `0x11/0x14` (store
address, mark receipt); `0x12/0x13` emitters.

**Design decisions flagged**: *verification ≠ custody* — these messages carry
addressing + receipts, not signing. Exit data is emitted for the miner to persist
(the covenantless storage burden survives even with an external ASP).

**Dependencies**: Phase 1.

**Validation**: round-trip encode/decode tests for all four; a sub-miner registers an
address and receives a `VtxoPaid` with non-empty `exit_data`.

**Wiki grounding**: [sv2-extension-surface](../wiki/concepts/sv2-extension-surface.md)
(extension mechanism, verification≠custody); [unilateral-exit-and-timeouts](../../covenantless-ark/wiki/concepts/unilateral-exit-and-timeouts.md)
(why exit data must reach the client).

**Definition of done**: `0x11–0x14` round-trip; `parser.rs` compiles; `extension.md`
updated; a registered miner gets a receipt carrying exit data.

---

### Phase 3: JDC Ark-payer orchestration + verifiable sub-tier accounting (estimated effort: 5–7 days)

**Goal**: On a disburse trigger, the JDC turns its sub-tier share window into weighted
OOR payouts and issues receipts — with the accounting auditable by sub-miners.

**Tasks**:
- [ ] JDC runs `demand-share-accounting-ext` **as server** downstream: maintains
      slices/windows over sub-miner shares; answers `GetWindow`/`GetShares` so a
      sub-miner can verify weight fairness (reuse the existing `0x00–0x10` logic).
- [ ] On disburse trigger (upstream Pool credits the JDC, surfaced as the JDC's own
      `NewBlockFound 0x03`), compute `(ark_address, weight)[]` from the verified
      window.
- [ ] Define `trait AspClient { invoice/await_receive/refresh/send_oor/status }`;
      implement it over **ark-settler → barkd** (Decisions 4, 6). `invoice`/`await_receive`
      handle LN top-ups (Pool pays a JDC invoice → VTXO); `refresh` hardens LN receives;
      `send_oor` distributes the credited amount proportionally with dust filtering +
      crash recovery.
- [ ] For each successful OOR send, emit `VtxoPaid (0x13)` with the ASP-returned
      `vtxo_id`, amount, and exit data; collect `0x14` acks.
- [ ] Handle **partial disburse** (some sends fail): ark-settler's crash-recovery
      resumes; unpaid weight rolls to the next window (no double-pay).

**Files — `stratum` fork / `sv2-apps`**: JDC `ArkPayer` module (trigger → window →
weights → AspClient → receipts); `AspClient` trait + ark-settler-backed impl; balance
watchdog that keeps the JDC Ark balance funded (generates LN invoices for the Pool to
pay when the balance runs low — Decision 6) and auto-refreshes LN-receive VTXOs.

**Files — `ark-settler`**: reused as a dependency; contribute only bug fixes if found.

**Design decisions flagged**: *matured balance* means the JDC must maintain a treasury
buffer ≥ expected payout; if underfunded, disburse defers (log it, don't silently
truncate).

**Open risks**: reconciling **sub-tier accounting units** (shares/difficulty) with
**Ark sat amounts** — rounding must be exact (ark-settler guarantees no sats lost to
rounding; verify weights sum correctly). Idempotency: a retriggered disburse must not
double-pay (key by window/block_hash).

**Dependencies**: Phases 1–2.

**Validation**: a real disburse over ≥3 sub-miners lands correct proportional OOR
VTXOs; a sub-miner independently verifies its weight via `GetWindow`/`GetShares`;
a forced mid-disburse crash resumes without double-paying.

**Wiki grounding**: [pure-receiver-and-liveness](../wiki/concepts/pure-receiver-and-liveness.md)
(OOR async receipt softens the pure-receiver problem); [out-of-round-payments](../../covenantless-ark/wiki/concepts/out-of-round-payments.md).

**Definition of done**: One trigger → verified window → weighted OOR payouts →
receipts with exit data, idempotent and crash-safe, with sub-miner-side verification
demonstrated.

---

### Phase 4: Demonstrated unilateral exit of a miner's VTXO (estimated effort: 2–4 days)

**Goal**: A miner exits its OOR VTXO to sole on-chain control **without JDC
cooperation**, proving the trust floor — and demonstrate the collusion-conditional
caveat honestly.

**Tasks**:
- [ ] Using only the persisted `exit_data` from `0x13`, a miner's `barkd` wallet
      performs the **unilateral exit** (two-stage for OOR/preconfirmed VTXOs:
      checkpoint tx gated by `checkpointExitDelay`, then the ark tx gated by
      `unilateralExitDelay`), CPFP-funded via P2A anchors.
- [ ] Advance the exit CSV (`~144` blocks) — on testnet4 via the 20-min
      min-difficulty rule or `generatetoaddress`; land a sole-control UTXO.
- [ ] **Demonstrate the caveat**: show that with an *honest* ASP the exit succeeds
      even with the JDC offline; document that only JDC+ASP *collusion* could block it
      (the statechain-like OOR property).
- [ ] Show **cancellability**: start an exit, then let the miner refresh cooperatively
      instead, abandoning the costly unroll.

**Files**: miner-side is `barkd` (no new code — exercise its exit path); scripting +
docs only.

**Design decisions flagged**: exit is **collusion-conditional** for OOR VTXOs
(Decision 2) — the trial must not overclaim "fully unilateral."

**Dependencies**: Phase 3.

**Validation**: miner lands a sole-control UTXO with the JDC offline; the
two-stage exit sequence and vBytes/fees are recorded; cancellability shown.

**Wiki grounding**: [unilateral-exit-and-timeouts](../../covenantless-ark/wiki/concepts/unilateral-exit-and-timeouts.md)
(two-stage OOR exit, `checkpointExitDelay`/`unilateralExitDelay`, board-vs-spend
unilaterality, cancellability).

**Definition of done**: Unilateral exit demonstrated with the JDC offline;
collusion-conditional caveat documented with evidence; cancellability shown.

---

### Phase 5: Failure handling (estimated effort: 3–5 days)

**Goal**: Exercise the failure modes that *actually* apply to this architecture
(different from the pool-as-ASP plan — no cosigning ceremony to abort).

**5a — ASP unavailable / refuses a send.** Disburse fails mid-run → ark-settler crash
recovery resumes when the ASP returns; unpaid weight rolls forward; no double-pay.
Demonstrate JDC retry + eventual completion.

**5b — JDC underfunded / treasury shortfall.** Disburse amount > JDC Ark balance →
defer with a logged shortfall (never silently truncate); JDC emits a top-up LN invoice
for the Pool; on payment + refresh-to-harden, complete.

**5c — Miner offline past VTXO expiry.** Without delegated renewal, the ASP sweeps at
`T_exp` and the miner loses the VTXO — show this, then show **delegated renewal**
(Decision 5) preventing it.

**5d — JDC↔ASP collusion (trust-boundary demo).** Explicitly walk through why an OOR
VTXO exit *could* be blocked if both collude, and why an honest ASP (or honest JDC)
prevents it. This is analysis + a documented scenario, not an attack to run.

**5e — Upstream Pool reorg.** Because the JDC pays from a **matured** balance, an
upstream reorg affects the JDC's *income accounting*, not already-sent miner VTXOs —
contrast this cleanly with the pool-as-ASP plan where a reorg voided the batch. (LN
funding further insulates this: an LN payment settles independently of the block that
paid the Pool.)

**5f — LN funding failure / unrefreshed receive.** Pool's LN payment to the JDC
invoice fails or times out → HTLC revokes cooperatively, funds return to the Pool
(sender safeguard), no stuck state; JDC re-issues an invoice. Also demonstrate the
**ephemeral-key caveat window**: an LN receive left *unrefreshed* is trusted-to-the-ASP
and expires in ~3 days; show refresh-to-harden closing it (Decision 6).

**Files — `stratum`/`sv2-apps`**: JDC retry/defer logic, shortfall logging + LN
top-up invoice generation, LN-receive refresh automation, expiry watcher + delegation
hookup.

**Dependencies**: Phase 3 (+ Phase 4 for 5c/5d).

**Validation**: each mode reproduced with logs; no double-pay; no miner-funds-loss
except the *expected* expiry-sweep-without-delegation case (which delegation fixes).

**Wiki grounding**: [pure-receiver-and-liveness](../wiki/concepts/pure-receiver-and-liveness.md),
[vtxo-lifetime-and-expiry](../../covenantless-ark/wiki/concepts/vtxo-lifetime-and-expiry.md),
[coinbase-maturity-and-reorg](../wiki/concepts/coinbase-maturity-and-reorg.md) (why
maturity/reorg no longer gate payouts here).

**Definition of done**: 5a–5f reproduced/documented; the maturity/reorg contrast with
the pool-as-ASP plan is written up; the LN-receive refresh-to-harden window is
demonstrated closing.

---

### Phase 6: Measurements (estimated effort: 2–3 days)

**Goal**: Quantify what this architecture's viability actually depends on (payout
throughput and cost — not ceremony latency, which is now the ASP's concern).

**Measurements**:
- [ ] **Payout fan-out throughput**: OOR sends/second and wall-clock to disburse to
      N miners (N=10, 50, 100, 250) — the number that beats OCEAN/DATUM's ~100/coinbase
      ceiling. This is the real value-prop metric.
- [ ] **Per-VTXO OOR cost** (ASP fees + any on-chain component) vs a direct on-chain
      payout of the same size — the batching win.
- [ ] **Exit cost**: two-stage OOR exit vBytes + fees (from Phase 4).
- [ ] **Verification cost**: bytes/time for a sub-miner to audit its window via
      `GetWindow`/`GetShares`.
- [ ] **Recovery**: wall-clock for ark-settler to resume after an ASP outage (5a).
- [ ] **Inbound LN funding cost + latency**: routing + Ark server fees and time from
      Pool payment → hardened JDC balance (Decision 6), and how batching top-ups
      amortizes it.

**Files**: instrument the `ArkPayer` + `AspClient` with counters; a small analysis
script.

**Dependencies**: Phases 3–5.

**Validation**: a results table (throughput×N, per-VTXO cost, exit vBytes,
verification cost, recovery time) with ≥5 samples each and a one-paragraph read.

**Wiki grounding**: [alternatives-and-prior-art](../wiki/reference/alternatives-and-prior-art.md)
(the OCEAN/DATUM ~100-payout ceiling is the benchmark to beat).

**Definition of done**: all metrics captured for N up to ≥250; fan-out demonstrably
exceeds the ~100-payout coinbase ceiling; written back to the thesis wiki.

## Risks & Mitigations

| Risk | Source | Mitigation |
|------|--------|------------|
| Two custodial surfaces (JDC + ASP) instead of one | this design | JDC accounting is **verifiable** (Decision 3); ASP custody has **unilateral-exit floor** (Phase 4); state both to miners. |
| OOR VTXO exit is collusion-conditional (JDC+ASP) | [unilateral-exit-and-timeouts](../../covenantless-ark/wiki/concepts/unilateral-exit-and-timeouts.md) | Don't overclaim "fully unilateral"; demo honest-party exit (Phase 4/5d); offer miners board VTXOs (round participation) if they want truly-unilateral. |
| captaind may not support testnet4 | Decision 4 | Self-host; if needed run Ark leg on signet and document the network split. |
| Self-hosted ASP must run a working **LN gateway** (higher bar) | [lightning-integration](../../covenantless-ark/wiki/concepts/lightning-integration.md) | Verify captaind's LN gateway on the chosen network in Phase 1 before building on it; signet fallback. |
| LN-receive VTXO ephemeral-key caveat + ~3-day lifetime | [lightning-integration](../../covenantless-ark/wiki/concepts/lightning-integration.md) | **Refresh-to-harden on receive** (Decision 6); automate; never treat unrefreshed LN receives as settled treasury. |
| LN routing/gateway fees on the inbound leg | [lightning-integration](../../covenantless-ark/wiki/concepts/lightning-integration.md) | Pool-side cost; batch top-ups to amortize; measure in Phase 6. |
| JDC treasury shortfall stalls payouts | Phase 5b | Balance watchdog; defer+log, never truncate; top-up procedure. |
| Miner loses funds to expiry sweep if offline | [vtxo-lifetime-and-expiry](../../covenantless-ark/wiki/concepts/vtxo-lifetime-and-expiry.md) | Delegated VTXO renewal (Decision 5); expiry hint in receipt. |
| Lost client-side exit data → no exit | [unilateral-exit-and-timeouts](../../covenantless-ark/wiki/concepts/unilateral-exit-and-timeouts.md) | Persist `0x13` `exit_data` durably; `0x14` ack gates it; document as covenantless cost. |
| Double-pay on retriggered disburse | Phase 3 | Idempotency keyed by window/block_hash; ark-settler crash recovery. |
| Share→sat rounding drift | Phase 3 | ark-settler's exact-sum allocation; assert weights reconcile. |
| Privacy: ASP sees payout addresses/amounts | this design | Note as a limitation; a per-payout fresh address helps but ASP still correlates. |
| Novelty collapse — "just a pool paying over Ark" | thesis follow-up #3 | Accept it; the *verifiable sub-tier accounting* + beating the DATUM ceiling is the real contribution here, not the covenant story. |

## Open Questions

- **Does captaind run on testnet4?** Must verify in Phase 1; drives the network-split
  fallback.
- **Pool→JDC over Lightning (Decision 6): does the Pool already have an LN payout
  rail?** Most pools pay LN or on-chain; if LN, this is drop-in. Open sub-question:
  invoice cadence (per-block vs batched top-ups) and who initiates — JDC pushes an
  invoice on low balance, or Pool streams keysend? Batched top-ups amortize fees
  (Phase 6).
- **Does the self-hosted captaind expose an LN gateway on testnet4/signet?** Higher
  bar than a plain ASP; verify in Phase 1.
- **Should sub-miners be able to demand board (round) VTXOs** for truly-unilateral
  exit, at the cost of ASP-round liveness? A per-miner policy knob — out of scope for
  the trial, worth a follow-up.
- **Is the JDC-as-sub-custodian regulatory posture** meaningfully different from a
  normal pool holding pending balances? Legal, not technical — flag, don't answer.
- **Multi-ASP redundancy**: the `AspClient` trait allows it; does splitting payouts
  across ASPs improve censorship-resistance enough to matter? Follow-up.

## Sources Consulted

**Primary wiki — [ark-boarding-sv2-mining](../_index.md):**
- [thesis + verdict](../theses/ark-boarding-sv2-mining.md) — follow-up #3 (matured funding collapses post-block-found novelty) is essentially this plan.
- [sv2-extension-surface](../wiki/concepts/sv2-extension-surface.md) — extension mechanism; verification≠custody (Decision 3, Phase 2).
- [pure-receiver-and-liveness](../wiki/concepts/pure-receiver-and-liveness.md) — OOR async receipt softens pure-receiver; delegated renewal (Decisions 2, 5).
- [coinbase-maturity-and-reorg](../wiki/concepts/coinbase-maturity-and-reorg.md) — why a matured JDC balance removes the maturity/reorg gate (Decision 2, Phase 5e).
- [alternatives-and-prior-art](../wiki/reference/alternatives-and-prior-art.md) — OCEAN/DATUM ~100-payout ceiling (the Phase 6 benchmark); ark-settler lineage.

**Grounding — [covenantless-ark](../../covenantless-ark/_index.md):**
- [out-of-round-payments](../../covenantless-ark/wiki/concepts/out-of-round-payments.md) — the OOR/arkoor send path (Decision 2, Phase 3).
- [unilateral-exit-and-timeouts](../../covenantless-ark/wiki/concepts/unilateral-exit-and-timeouts.md) — two-stage OOR exit, collusion-conditional caveat, cancellability, storage burden (Phase 4).
- [vtxo-lifetime-and-expiry](../../covenantless-ark/wiki/concepts/vtxo-lifetime-and-expiry.md) — expiry sweep, delegated renewal (Decision 5, Phase 5c).
- [lightning-integration](../../covenantless-ark/wiki/concepts/lightning-integration.md) — ASP-as-LN-gateway, incoming LN value arrives as VTXOs, ephemeral-key caveat + ~3-day receive lifetime, HTLC failure/revocation (Decision 6, Phase 1/5f).
- [boarding](../../covenantless-ark/wiki/concepts/boarding.md) — the on-chain-boarding alternative rejected in Decision 6 (six-conf wait, ~90-day boarding exit).

**Direct source & environment reads (2026-07-20):**
- `demand-share-accounting-ext` `src/const.rs`/`parser.rs`/`new_block_found.rs`/`extension.md` — the wiring `0x11–0x14` extends.
- `~/repos/ark-settler` — weighted OOR distribution over barkd (reused as-is; note its Pool→settler→barkd→captaind topology *is* this architecture's payout leg).
- `~/repos/bark` — barkd/captaind ASP stack; `secp256k1::musig` (ASP-internal now, not our code).
- `~/repos/stratum` (demand fork), `~/repos/sv2-apps`, `~/repos/sv2-tp`, `~/repos/bitcoind-testnet4-startos` — mining substrate.

## Definition of Done (whole trial)

A testnet4 SRI stack in which the **Pool pays a JDC over Lightning** (received through
the ASP gateway as a VTXO, refreshed-to-harden); the **JDC runs verifiable sub-tier
share accounting** over its downstream miners and pays them **weighted OOR VTXOs from
that matured Ark balance** via a **self-hosted external ASP** (bark/barkd/captaind)
behind a swappable `AspClient` boundary; miners register addresses and receive VTXO
receipts + exit data over new extension messages `0x11–0x14`; a miner **unilaterally
exits** with the JDC offline (collusion-conditional caveat documented); failure modes
(ASP-down, shortfall, expiry, collusion, upstream reorg, **LN funding failure /
unrefreshed receive**) are handled/documented; and **fan-out throughput beats the
~100-payout coinbase ceiling** — with **no covenant, and the covenantless custody +
exit inherited from the ASP, not built by us.**


