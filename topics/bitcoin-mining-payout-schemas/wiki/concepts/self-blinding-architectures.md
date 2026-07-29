---
title: Self-Blinding Architectures (cross-domain)
category: concept
created: 2026-07-29
confidence: high
tags: [ohttp, rfc9458, split-trust, tee, sgx, sev-snp, nitro, attestation, prio, dap, private-cloud-compute, icloud-private-relay, transparency-log, sgaxe, compulsion]
volatility: warm
updated: 2026-07-29
summary: "Deployed patterns for making an operator structurally unable to retain data, ranked by transferability to a mining pool — and the trust each one substitutes in, because nothing is free."
verified: 2026-07-29
sources:
  - "raw/notes/2026-07-29-self-blinding-system-architectures.md"
  - "raw/notes/2026-07-29-fincen-td10000-regulatory-attribution-posture.md"
---

# Self-Blinding Architectures

Cross-domain survey of what "we made ourselves unable to know" looks like in production systems,
evaluated for transfer into a mining pool. Every entry substitutes one trust assumption for
another; the article is organized around naming the substitution honestly.

**The framing correction that reorders everything**: private aggregation (Prio/DAP) hides
*individual inputs* and reveals a *population total*. A pool needs the **opposite axis** — an
exact per-recipient total, with only the *link* to the submitting identity hidden. So the primary
tool is **unlinkable submission** (OHTTP + blind-signature credentials), not private aggregation.

## Ranked by transferability

| # | Architecture | Transferability | Trust substituted in |
|---|---|---|---|
| 1 | **Split-trust relay for share submission** (RFC 9458 OHTTP; iCloud Private Relay) | **High** — pool sees shares + payout script, never the submitting IP | Relay and pool **must not collude or be co-owned** (§6.8). No forward secrecy within a key epoch (§6.6). **Any persistent state re-links the client** (§2.1.2). ≥2 round trips per submission. |
| 2 | **Blind-signature / anonymous-credential admission** (Private Relay's one-time RSA blind sigs; PCC single-use credentials) | **High** — proves "enrolled, paid-up, non-abusive miner" without learning which one | Issuer must not collude with redeemer; you must rebuild the anti-abuse layer the token replaced. Rate limiting itself shrinks the anonymity set (§6.2.1.3). |
| 3 | **Multi-vendor TEE trust splitting** (Signal SVR3: SGX/Azure + SEV-SNP/GCP + Nitro/AWS, t=2 of n=3) | **Medium-high** for holding an attribution table; **low** for metadata | "No attacker compromises >2 of 3 vendor+cloud stacks *simultaneously*." 3× cloud spend. **SVR3 itself states it "does not hide the identity of clients or the timing of… requests"** — layer it *under* #1/#2, never instead. |
| 4 | **Single TEE + reproducible build + client-enforced transparency log** (PCC; Nitro PCRs) | **Medium** — cheapest credible "we structurally can't read it" | The vendor who *signs the attestation* — **AWS attests AWS** — plus your build pipeline, plus somebody actually auditing the log. |
| 5 | **Private aggregation** (Prio / DAP / Divvi Up) | **Medium, but not for the ledger** — fits published statistics and cross-pool reconciliation | Privacy with 1-of-s honest, but **robustness only if ALL servers honest**. Imports selective-DoS and intersection attacks, which bite hardest on a system publishing exact numbers every block. |
| 6 | **Oblivious data structures** (Path ORAM, PIR) | **Medium-narrow** — for the *read* path ("what am I owed?"), not the accounting path | Large constants. Signal's Path ORAM ~1,800 accesses vs 1 B linear. SimplePIR: **121 MB client hint per 1 GB DB**. The hint, not throughput, breaks deployments. |
| 7 | **Client-held keys / write-only running totals** | **High per unit of effort, and the most honest** — no non-collusion assumption, no enclave, no vendor | Substitutes **capability for functionality**: no dispute forensics, no retroactive withholding investigation. Strong against *retrospective* compulsion, weak against prospective. |
| 8 | **Differential privacy on aggregates** | **Near-zero for the ledger** — money must be exact | Substitutes exactness for privacy, the one trade a payout system cannot make. Fine for dashboards; keep away from balances. |

## The two most transferable mechanisms

Both are client-side enforcement, and both are cheaper than the cryptography they guard:

**PCC's key-wrapping rule** — the device "wraps request payload key **only to PCC nodes whose
attested measurements match logged releases**." The server cannot decrypt unless its measurement
already appears in an append-only public log. This converts "trust our promise" into "clients
refuse to encrypt to unlogged code."

**Private Relay's raw-public-key pinning** — proxy authentication uses raw public keys in the
TLS 1.3 handshake compared against a separately distributed authenticated configuration, *not*
the web PKI.

> **That client-side enforcement step is the single most transferable mechanism in this entire
> set, and worth more to a blind pool than the enclave it protects.**

Also worth copying from Private Relay: authorization by **one-time-use RSA blind-signature
tokens** minted after device+account attestation, validated with a public key "without actually
identifying the user," **rotated daily**, with **asynchronous double-spend prevention** and
per-day rate limits — and deliberate location degradation (IP → geohash truncated to four
characters, ~800 km², handed back *to the device*).

## Why attestation is weaker than the marketing

- **SGAxe (2020)** extracted the sealing key of Intel's own signed production Quoting Enclave via
  CacheOut, then unsealed the persistent attestation key — with all countermeasures applied and
  **while the victim enclave was completely idle**. Authors: "we can build a malicious SGX
  simulator that passes Intel's entire remote attestation process." EPID compounding: one private
  key forges signatures for a group of **millions** of CPUs. They analyze impact on Signal.
- **ÆPIC Leak (USENIX Sec '22)** — "the first architectural CPU bug that leaks stale data from the
  microarchitecture **without using a side channel**." Extracts "even the Intel SGX attestation
  keys from enclaves within a few seconds." Recommendation: disable APIC MMIO **or not rely on
  SGX**.
- **"SoK: A cloudy view on trust relationships of CVMs"** (arXiv 2503.08256, Mar 2025) is bleaker
  than any vendor doc: "**all major cloud providers retain control over critical parts of the
  trusted software stack and, in some cases, intervene in the standard remote attestation
  process. This directly contradicts their claims of delivering confidential computing.**" AWS
  SEV-SNP: the guest image "cannot be retrieved by the customer after being modified by AWS
  tooling," so "**AWS becomes a trusted stakeholder on attestation.**" GCP TDX firmware is
  closed-source and "therefore not attestable." **AWS Nitro Enclaves is excluded from analysis
  entirely** because Amazon is both hardware vendor and cloud provider. Side channels are *out of
  scope* — so this is a lower bound.
- **RFC 9334 (RATS)**: Evidence describes "operational status, health, configuration, or
  construction" — *what* code is running, never whether it behaves correctly.

Nitro operational trap worth knowing: `--debug-mode` / `--attach-console` produce **all-zero
PCRs**, and AWS ships no turnkey reproducible-build tooling.

## The failure mode nothing on this list fixes

Attestation binds the *identity* of code, not its trustworthiness. A transparency log converts a
code substitution from invisible to *eventually detectable by whoever checks* — and PCC's stated
publication window is **within 90 days**, so the lag is real. Because the operator controls the
build, the signing key, and the release cadence:

> "We made ourselves unable to comply" is durable in only one form: **data that was never
> collected, in a design where collecting it would require a client-visible, log-visible change
> that clients refuse to encrypt to.**

This lines up exactly with the compulsion record. **Lavabit** is dispositive as to promises: the
government obtained a warrant for the TLS private keys covering all 400,000 customers, Levison
offered targeted code instead, and **the court rejected it** — $5,000/day, shutdown, contempt.
The EFF's warrant-canary FAQ answers "have canaries been tested?" with "**Not yet**… EFF
*believes* warrant canaries are legal" — belief, not holding. Therefore **any blindness claim must
be scoped to the past tense.** See [[../decisions/attribution-retention-tradeoffs|attribution retention tradeoffs]].

One deployment argument worth borrowing from Prio: **jurisdictional diversity** — "If law
enforcement agents seize the Prio servers in one country, they cannot deanonymize the
organization's Prio users."

## Negative results

- **No substantive independent critique of Apple PCC's trust model found.** Searches returned only
  Apple's own docs and restatements; the best available adversarial framing is the CVM SoK applied
  by analogy.
- **No good primary source on verifiable key deletion / proof-of-erasure at scale.** PCC's Sealed
  Key Protection and SVR3's "unconditionally delete key material" are closest; neither gives the
  *user* a proof deletion occurred. **Treat verifiable deletion as an open problem, not an
  available primitive.**
- **No source found treating legal compulsion of enclave operators rigorously.**

## Sources

- [[../../raw/notes/2026-07-29-self-blinding-system-architectures|Self-blinding system architectures — OHTTP, TEEs, Prio]]
- [[../../raw/notes/2026-07-29-fincen-td10000-regulatory-attribution-posture|Regulatory posture — FinCEN, TD 10000, Lavabit]]

## See also

- [[blind-share-accounting]] — the primitive layer, and why non-collusion is unavoidable
- [[payout-attribution-privacy]] — what needs hiding in the first place
- [[../decisions/attribution-retention-tradeoffs|Attribution Retention Tradeoffs]]
- [[../topics/self-blinding-pool-design-space|Self-Blinding Pool Design Space]]
