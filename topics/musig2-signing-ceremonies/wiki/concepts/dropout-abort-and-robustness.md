---
title: "Dropout, Abort, and Robustness"
category: concept
sources: [raw/papers/2026-07-16-roast-robust-asynchronous-schnorr-threshold.md, raw/papers/2026-07-16-rfc-9591-frost.md, raw/articles/2026-07-16-bip-327-musig2-spec.md, raw/articles/2026-07-16-kohen-musig2-nonce-reuse-attack.md, raw/articles/2026-07-16-bolt-simple-taproot-channels-musig2.md]
created: 2026-07-16
updated: 2026-07-16
tags: [dropout, abort, robustness, identifiable-abort, denial-of-service, roast, retry, fresh-nonce, liveness]
aliases: [dropout handling, abort handling, robustness, identifiable abort, non-robust]
confidence: high
volatility: warm
verified: 2026-07-16
summary: "MuSig2 is non-robust: because it is n-of-n, any single signer who goes offline or sends a bad partial signature causes the entire ceremony to fail. Recovery means restarting with FRESH nonces — reusing the aborted round's nonces is the nonce-reuse catastrophe. PartialSigVerify gives identifiable abort (attribute the culprit). ROAST is the wrapper that adds true robustness, but only to threshold (FROST) schemes, not to n-of-n MuSig2."
---

# Dropout, Abort, and Robustness

> What happens when a signer disappears halfway through a MuSig2 ceremony, or sends a partial signature that does not verify? Because MuSig2 is **n-of-n**, the answer is blunt: the ceremony cannot complete. There is no "sign without the missing party." This makes dropout/abort handling — not the cryptography — the dominant *operational* concern, and it interacts dangerously with the [[nonce-reuse-catastrophe|nonce-reuse rule]] ([nonce-reuse rule](nonce-reuse-catastrophe.md)) on every retry.

## Non-robustness is inherent to n-of-n

A protocol is **robust** if the honest signers can still produce a valid signature even when other participants try to disrupt it. MuSig2 has no robustness: every one of the *n* participants is required, so a single offline, slow, or malicious signer halts the session. The ROAST paper frames this precisely — the absence of robustness means "a single disruptive/offline signer prevents completion," a liveness / **denial-of-service** concern that it calls a key adoption blocker for threshold signing in cryptocurrency. Plain FROST shares the flaw: RFC 9591 states "all participants are required to complete the protocol honestly in order to generate a valid signature."

## Failure modes

- **Silent dropout** — a signer never sends its Round-1 nonce or Round-2 partial sig. The session stalls; there is no aggregate to complete. Only a **timeout** rescues liveness.
- **Bad partial signature** — a signer sends a partial sig that fails `PartialSigVerify`. The aggregate would be invalid, so signing must abort.
- **Disruption / griefing** — a malicious participant deliberately withholds or corrupts to prevent completion, potentially indefinitely.

## Identifiable abort: attributing blame

BIP-327 provides **identifiable abort** via `PartialSigVerify`. If all inputs are untampered and each partial signature is individually verified, and exactly one fails, "the algorithm run by the honest party will output the index of exactly one malicious signer." This lets a coordinator eject or penalize the culprit rather than blindly restarting. (Caveat: individual partial sigs are forgeable in isolation; identifiability holds only when the honest party controls/verifies the other inputs.) A NIST 2026 presentation calls identifiable aborts "deployment-critical," noting that without them "a single misbehaving signer can stall protocol execution indefinitely."

## The dangerous part: retry requires FRESH nonces

Recovery from any abort means starting a **new signing attempt** — and that attempt must use **freshly generated nonces**. Reusing the Round-1 nonces from the aborted attempt is exactly the [[nonce-reuse-catastrophe|nonce-reuse catastrophe]] ([nonce-reuse catastrophe](nonce-reuse-catastrophe.md)): a signer that already produced a partial signature in the first attempt, then signs again over the same nonce in the retry, has signed twice under one nonce and leaks its key. This is the crucial coupling between abort handling and nonce safety: **an abort is not a "resume," it is a fresh session.** Implementations that persist and replay an in-flight session (to "continue after a crash") reintroduce the backup/restore footgun.

## ROAST: robustness — but only for threshold schemes

[[musig2-vs-frost-roast|ROAST]] ([ROAST](musig2-vs-frost-roast.md)) is a wrapper that makes a threshold scheme robust and asynchronous. Its coordinator maintains a pool of willing signers and cyclically assigns groups of *t* to concurrent signing attempts; as a signer returns a valid share it re-enters the pool, so a disruptive signer "can only hold up one signing attempt at a time" and honest signers eventually complete one. A 67-of-100 setup with 33 malicious signers still finishes within seconds. ROAST requires the underlying scheme to have (1) one preprocessing + one signing round, (2) identifiable aborts, and (3) concurrent-session security — all satisfied by FROST.

The catch for MuSig2: ROAST's robustness fundamentally relies on **thresholds** — being able to complete with a *subset* of signers. MuSig2 is n-of-n, so there is no subset to fall back to. ROAST does not make MuSig2 robust; it makes *FROST* robust. For an n-of-n MuSig2 deployment, the only recourses are timeouts, identifiable-abort-driven ejection, and fresh-nonce retries — or switching to a threshold scheme when robustness is a requirement.

## Practical handling checklist

1. Set a **round timeout**; treat a missing nonce/partial-sig as an abort, not an indefinite wait.
2. Use `PartialSigVerify` to **identify** a faulty signer before retrying.
3. On retry, **generate fresh nonces** for every participant; never resume a persisted in-flight session.
4. If robustness (completion despite dropouts) is a hard requirement, use a **threshold** scheme (FROST + ROAST), not n-of-n MuSig2.

## See Also

- [[nonce-reuse-catastrophe|Nonce-Reuse Catastrophe]] ([Nonce-Reuse Catastrophe](nonce-reuse-catastrophe.md)) — why every retry needs fresh nonces
- [[musig2-vs-frost-roast|MuSig2 vs FROST/ROAST]] ([MuSig2 vs FROST/ROAST](musig2-vs-frost-roast.md)) — ROAST's robustness mechanism and why it needs a threshold
- [[session-framing-and-state|Session Framing and State]] ([Session Framing and State](session-framing-and-state.md)) — timeouts, reconnection, and not persisting in-flight state
- [[musig2-protocol|The MuSig2 Protocol]] ([The MuSig2 Protocol](musig2-protocol.md)) — the n-of-n property that makes MuSig2 non-robust

## Sources

- [ROAST: Robust Asynchronous Schnorr Threshold Signatures](../../raw/papers/2026-07-16-roast-robust-asynchronous-schnorr-threshold.md) — robustness definition, coordinator pool, identifiable-abort requirement
- [RFC 9591: The FROST Protocol](../../raw/papers/2026-07-16-rfc-9591-frost.md) — FROST's acknowledged non-robustness
- [BIP-327: MuSig2 Specification](../../raw/articles/2026-07-16-bip-327-musig2-spec.md) — identifiable abort via PartialSigVerify
- [Kohen: Limited MuSig2 Nonce Reuse Attack](../../raw/articles/2026-07-16-kohen-musig2-nonce-reuse-attack.md) — why reusing an aborted round's nonce is fatal
- [BOLT: Simple Taproot Channels (MuSig2)](../../raw/articles/2026-07-16-bolt-simple-taproot-channels-musig2.md) — reconnection recovery via channel_reestablish
