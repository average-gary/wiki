---
title: "BIP 310 — Stratum protocol extensions (version rolling, minimum difficulty)"
source: "https://github.com/bitcoin/bips/blob/master/bip-0310.mediawiki"
type: papers
ingested: 2026-09-21
tags: [bip310, stratum-v1, version-rolling, asicboost, minimum-difficulty, feature-negotiation, mining-configure, set-version-mask, backwards-compatibility, extension-negotiation]
summary: "The extension-negotiation mechanism retrofitted onto Stratum V1 by Pavel Moravec and Jan Capek (the same pair who then designed SV2). Establishes mining.configure as the FIRST message after connection, before mining.subscribe, so capabilities are negotiated up front and an incompatible client can be rejected early. Namespaced parameters (e.g. version-rolling.mask) with a server result map naming which extensions were accepted, giving graceful fallback. Two extensions matter architecturally: version-rolling, which lets a miner mutate negotiated bits of the block header version with the invariant version_bits & ~last_mask == 0, and which is what makes modern ASIC search spaces viable; and minimum-difficulty, which lets a miner request a difficulty its hardware can actually produce shares at — the mechanism that makes one pool serve both a Bitaxe needing difficulty 1 and a farm needing 100k+. Pools can push mining.set_version_mask at any time to change allowed bits without a job refresh. The spec records its own hazard: 'many server implementations close connections upon receiving unknown messages', which is why negotiation had to be added as a pre-subscribe handshake rather than as optional fields on existing messages."
authors: [Pavel Moravec, Jan Čapek]
venue: "Bitcoin Improvement Proposal 310"
credibility: high
credibility_score: 4
credibility_rationale: "Primary specification in the BIPs repository, authored by the implementers who went on to design Stratum V2."
confidence: high
research_round: 1
research_agent: applied
extraction_note: "Subagent extraction of the BIP text. The version-rolling invariant is reported as `version_bits & ~last_mask == 0`; field-level detail (full parameter list, error cases, exact JSON shapes) was not captured — read the BIP for implementation."
---

# BIP 310 — Stratum protocol extensions

**Pavel Moravec, Jan Čapek** — the authors who subsequently designed Stratum V2.

## Why it exists

Stratum V1 had no formal standard and no extension mechanism. BIP 310 adds one *after the fact*, and
the design is constrained by the installed base — which is the interesting part.

**The recorded hazard**: *"Many server implementations close connections upon receiving unknown
messages."* A protocol whose deployed servers drop the connection on anything unexpected cannot be
extended by adding optional fields or new messages opportunistically. So negotiation has to happen
in a single, agreed, up-front exchange.

## The mechanism

**`mining.configure` is the first message after connection establishment** — before
`mining.subscribe`. Consequences:

- Capabilities are known before any mining state exists.
- The pool can reject an incompatible client **early**, before allocating channel/job state.
- **Namespaced parameters** with extension prefixes, e.g. `version-rolling.mask`.
- The server replies with a **result map** naming which extensions it supports, so the client can
  fall back gracefully instead of guessing.

This ordering — negotiate, then subscribe — is the pattern SV2 later formalises as
`SetupConnection` with `supported_extensions` / `required_extensions`. BIP 310 is where it was first
established in the Bitcoin mining stack.

## `version-rolling`

Lets the miner mutate specific bits of the block header **version** field. The pool communicates which
bits are mutable via a mask; the miner must satisfy:

```
version_bits & ~last_mask == 0
```

i.e. never set a bit outside the negotiated mask. This permits ASIC-level optimisation (ASICBoost, and
more importantly plain search-space extension) **without the pool losing the ability to validate
submissions** — the pool knows exactly which bits could have changed, so it can reconstruct the header.

**Why it is load-bearing.** A 32-bit nonce at 100 TH/s is exhausted in roughly 43 µs. Version rolling
adds ~24 bits, extending the per-job search space by a factor of ~1.7×10⁷ — the difference between
needing a new job every few microseconds and needing one every several minutes. Without it, no modern
ASIC could be fed by any pool at any job rate. This is the single mechanism that keeps the job-push
rate bounded as hashrate per device grows.

**`mining.set_version_mask`** can be pushed by the pool **at any time**, immediately changing the
allowed bits **without requiring a job refresh**. A notification that changes a validation parameter
out-of-band from the job stream — worth flagging, because it means the pool's share-validation logic
must track mask changes against job timing, which is a version of the same "validate a late share
against its own context" problem that bit the SV2 translator proxy.

## `minimum-difficulty`

Lets the miner request a difficulty floor appropriate to its hardware. The gap it closes: pools could
not accommodate device limitations, and the range of device capabilities is enormous — a lottery miner
(Bitaxe class) needs difficulty near 1 to see any shares at all, while a farm needs 100,000+ to keep
submission rates sane.

Architecturally this is the admission that **difficulty is a negotiated per-connection parameter, not
a pool-wide policy**, and it is the ancestor of every `mindiff` / `startdiff` / high-difficulty-port
arrangement in production pools (compare ckpool's `mindiff`/`startdiff`/`maxdiff` and solo.ckpool's
separate 4334/4336 rental ports).

It also interacts with the vardiff finding in Optech #423: a *requested minimum* gives the controller
a floor, but says nothing about detecting a miner that slows below its own declared capability.

And it interacts with the Bedrock/StraTap privacy result: a *known, fixed* starting difficulty is what
made packet-count hashrate inference cheap. A miner-requested minimum is better for privacy than a
pool-wide constant, since the value is no longer publicly predictable.

## Architectural reading

1. **Extension negotiation must be a pre-mining handshake when the installed base is intolerant.**
   The "servers close on unknown messages" constraint fully determines the design. SV2 inherits the
   shape and pays for it with `SetupConnection` version enforcement (and the sv2-apps v0.8.0 fix
   rejecting non-setup responses during handshake).
2. **Search space, not bandwidth, is why version rolling exists.** It is usually discussed as an
   ASICBoost story; the durable reason is nonce exhaustion.
3. **Per-connection capability negotiation is the precondition for serving heterogeneous hardware on
   one endpoint.** Without `minimum-difficulty`, the Bitaxe and the 10 PH/s farm cannot share a pool
   without separate ports — which is exactly what pools that lack it do.
