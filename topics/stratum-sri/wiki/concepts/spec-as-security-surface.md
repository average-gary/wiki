---
title: "Specification as Security Surface"
category: concept
sources:
  - raw/articles/2026-09-02-vinteum-deep-dive-bitcoin-mining-protocol-silicon.md
  - raw/notes/2026-07-17-sv2-spec-issue-95-unknown-extensions.md
  - raw/articles/2026-07-17-sv2-spec-extensions-negotiation.md
  - raw/articles/2026-05-28-stratum-sri-security.md
created: 2026-09-02
updated: 2026-09-02
tags: [sv2, sv2-spec, spec-quality, security-surface, protocol-invariants, interoperability, ambiguity, vinteum, disclosure-policy]
aliases: ["Specs Are Part of the Security Surface", "spec ambiguity", "spec quality", "unstated invariants"]
confidence: medium
volatility: warm
verified: 2026-09-02
summary: "The claim — from Vinteum's 2026 mining Deep Dive — that for security-sensitive infrastructure the specification itself is part of the attack surface, because ambiguous terminology, unstated invariants, and tacit knowledge let two reasonable implementers build incompatible systems from the same document. sv2-spec issue #95 is the worked example: the spec mandated extension version negotiation as a MUST but never said how, and two competent implementers derived opposite protocols from it."
---

# Specification as Security Surface

> Reference implementations are usually treated as the thing that can have bugs and specs as the thing that defines correctness. The inverse claim — argued at Vinteum's August 2026 mining Deep Dive — is that for security-sensitive infrastructure **the specification is itself part of the security surface**. A clause that is ambiguous, an invariant that is assumed but never written down, or knowledge that lives only in a contributor's head all produce the same outcome: two implementations that each believe they are correct and that disagree in production. This wiki has a documented instance of exactly that, so the claim is not abstract here.

## The claim

Vinteum's report on its week-long mining Deep Dive (August 24–28, 2026) states the position directly: "specifications are part of the security surface." The named mechanism is that ambiguous terminology, unstated invariants, and tacit knowledge create the opportunity for "two reasonable implementers to understand the same system differently."

Note the word *reasonable*. This is not a claim about careless implementers. Both parties read the document, both comply with it, and the disagreement is still latent in the text — which is why it survives code review, tests, and fuzzing on either side. Each implementation is internally consistent; the defect only appears when they are connected.

## Worked example: a MUST with no mechanism (sv2-spec #95)

The clearest instance in this wiki is [sv2-spec issue #95](<../../raw/notes/2026-07-17-sv2-spec-issue-95-unknown-extensions.md>), which is the pre-history of [[sv2-extensions-negotiation|SV2 Extensions Negotiation (0x0001)]] ([SV2 Extensions Negotiation (0x0001)](sv2-extensions-negotiation.md)).

`03-Protocol-Overview.md` §3.4 carried a normative requirement:

> Extensions MUST require version negotiation with the recipient of the message to check that the extension is supported before sending non-version-negotiation messages for it.

The requirement is unambiguous about the *obligation* and silent about the *mechanism*. What followed is the failure mode in miniature. Fi3 read it as implying a universal per-extension NACK frame (`msg_type: 0xff`) so a peer could learn non-support immediately. jakubtrnka read the same clause as making a NACK unnecessary — if negotiation is already mandatory, you assume non-support until you receive a positive ACK, and adding a "pending" state only adds a state that buggy implementations can get stuck in. rrybarczyk read it as wanting an explicit NACK carrying `error_code` and `reason_string`.

Three competent readings, one sentence, and the wire behaviors are not interoperable: an ACK-only implementation talking to a NACK-expecting one leaves the latter waiting out a timeout on every unsupported extension, and a NACK sender talking to an ACK-only peer emits a frame the peer treats as unexpected. The issue sat open from August 2024 with no merged spec change, which means the ambiguity was live in the normative document for as long as it took extension `0x0001` to be specified.

Two secondary observations from that thread reinforce why this is a *security* surface and not only an interoperability one:

- **Unstated invariants around namespace collisions.** jakubtrnka's recommendation that a negotiation payload be "sufficiently unique to the extension being used" exists because nothing stopped two implementers from independently claiming the same extension number with incompatible meaning. Absent that convention, the graceful outcome (both sides stop talking) and the ugly one (both sides proceed on mismatched semantics) are equally spec-compliant.
- **Timeouts are load-bearing either way.** rrybarczyk's point that a timeout is needed regardless — because messages can be delayed by connection prioritization — means the spec was silently delegating a denial-of-service-relevant parameter to implementers. `0x0001` eventually wrote concrete guidance into the spec (wait 2× initial connection time, retry, proceed without extensions after 5×, consider a fallback pool past ~1 second), which is the fix: move the number out of tacit knowledge and into the document.

## Worked example: field-name drift inside one document

Ambiguity does not require a multi-year debate. The normative `0x0001` spec itself names the same field two ways: the §2 message table calls it `required_extensions`, while the §4 error-handling prose calls it "the `requested_extensions` field" — a field name that already means something else in the same message family. An implementer working from the prose rather than the table can wire the wrong field, and the resulting behavior (failing to disconnect a client that declined a server-required extension) is enforcement, not cosmetics.

## Why this bites a reference implementation specifically

*(Observation from this wiki, not a claim in the sources.)* SRI occupies an awkward position on this surface. Because it is the reference implementation, implementers resolve spec ambiguity by reading SRI's code — so whichever reading SRI picks becomes de facto normative regardless of whether the spec was ever clarified. That converts an ordinary implementation choice into a protocol decision, and it means the cost of an ambiguous clause is paid once, silently, in whichever SRI crate got there first.

The repo's own [Security Policy](../../raw/articles/2026-05-28-stratum-sri-security.md) shows the resulting gap. It is a well-formed vulnerability process: private reporting via GitHub Security Advisory or `stratumv2@gmail.com`, PGP fingerprints for encrypted reports, no public issues or PRs referencing the flaw, coordinated disclosure, and version support limited to `> 1.6.0`. Every part of it presumes the defect is *in code that ships*. An ambiguous normative clause is not a vulnerability in any single implementation — there is nothing to patch and no affected version to name — so it has no route through that process, even when its consequence is two deployed roles that disagree about protocol state. Spec defects go through the spec repo's ordinary issue tracker, on ordinary timelines, in public, which is how #95 stayed open for two years.

## Shared vocabulary as the mitigation

The Deep Dive's stated remedy is unglamorous: make the objects and roles explicit. Roughly two of the event's five days went to the SV2 specs and reference implementations, and the outcome Vinteum reports first is not a finding but a vocabulary — **mining devices, proxies, pool services, template providers, Job Declaration Clients, and Job Declaration Servers** as named things with named boundaries.

That matters because boundary confusion is itself a source of ambiguity. The report notes that `getblocktemplate` and Stratum "are sometimes described as successive approaches to giving miners work, but they operate at different boundaries" — GBT sits at the node↔mining-software boundary, Stratum at the pool↔miner boundary. Treating them as generations rather than as different interfaces is a vocabulary error that propagates into design arguments.

The framing Vinteum offers for why the precision is worth the effort is the PC industry: "Part of what enabled the personal computer industry to become so diverse was the standardization of interfaces between components." SV2 as "glue between specialized components of the mining stack" lets a developer specialize in one component — firmware, proxy, pool — and still interoperate. That payoff is exactly what an ambiguous interface forfeits, which is why spec precision and ecosystem diversity are the same problem.

## Not covered here

The [Vinteum source](../../raw/articles/2026-09-02-vinteum-deep-dive-bitcoin-mining-protocol-silicon.md) also reports a P2Pool v2 finding ("a potentially security-relevant edge case involving malicious miner behavior, denial of service, and possible loss of funds," undetailed) and a hardware day on the BM13xx ASIC family, Mujina firmware, and Bitaxe. Both are outside this wiki's scope — SRI's low-level SV2 crates — and belong in the p2pool and mining-firmware topics respectively.

## See Also

- [[sv2-extensions-negotiation|SV2 Extensions Negotiation (0x0001)]] ([SV2 Extensions Negotiation (0x0001)](sv2-extensions-negotiation.md)) — the spec that closed the #95 ambiguity, and the source of the field-name drift example
- [[sv2-extensions|SV2 Extensions]] ([SV2 Extensions](sv2-extensions.md)) — the `extensions_sv2` crate that has to implement whatever the spec turns out to mean
- [[sv2-framing|SV2 Framing]] ([SV2 Framing](sv2-framing.md)) — the `extension_type` field whose namespace the collision concern applies to
- [[sri-release-process|SRI Release Process]] ([SRI Release Process](../references/sri-release-process.md)) — the versioning and changelog machinery the security policy's "supported versions" table depends on

## Sources

- [Inside a Vinteum Deep Dive: Bitcoin Mining from Protocol to Silicon](../../raw/articles/2026-09-02-vinteum-deep-dive-bitcoin-mining-protocol-silicon.md) — the "specifications are part of the security surface" claim, the two-reasonable-implementers mechanism, the role vocabulary, the GBT-vs-Stratum boundary distinction, and the PC-interface analogy
- [sv2-spec #95 — Handle unknown extensions](../../raw/notes/2026-07-17-sv2-spec-issue-95-unknown-extensions.md) — the worked example: three incompatible readings of one MUST clause, plus the namespace-collision and timeout observations
- [SV2 Extension 0x0001: Extensions Negotiation (sv2-spec)](../../raw/articles/2026-07-17-sv2-spec-extensions-negotiation.md) — the §2-vs-§4 field-name inconsistency, and the concrete timeout guidance that replaced tacit knowledge
- [Security Policy (SECURITY.md)](../../raw/articles/2026-05-28-stratum-sri-security.md) — SRI's vulnerability reporting, PGP keys, supported-version table, and coordinated-disclosure process, all scoped to shipped code
