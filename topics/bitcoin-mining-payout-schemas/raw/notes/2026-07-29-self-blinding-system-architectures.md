---
title: "Self-blinding system architectures — OHTTP, split-trust relays, multi-vendor TEEs, Prio/DAP"
source: https://www.rfc-editor.org/rfc/rfc9458.html
supporting_sources:
  - https://www.usenix.org/system/files/osdi24-connell.pdf
  - https://crypto.stanford.edu/prio/paper.pdf
  - https://arxiv.org/abs/2503.08256
  - https://security.apple.com/blog/private-cloud-compute/
  - https://www.apple.com/privacy/docs/iCloud_Private_Relay_Overview_Dec2021.PDF
  - https://cacheoutattack.com/files/SGAxe.pdf
  - https://www.usenix.org/system/files/sec22-borrello.pdf
type: notes
ingested: 2026-07-29
quality: 5
credibility: high
confidence: high
tags: [ohttp, rfc9458, split-trust, tee, sgx, sev-snp, nitro-enclaves, attestation, prio, dap, divvi-up, private-cloud-compute, icloud-private-relay, sgaxe, aepic, transparency-log, blind-signature, primary]
summary: "Cross-domain survey of deployed patterns, evaluated for transferability to a mining pool."
---

# Architectures for making yourself structurally unable to retain attribution

Cross-domain survey of deployed patterns, evaluated for transferability to a mining pool.
**The framing correction that reorders everything**: private aggregation (Prio) hides
*individual inputs* while revealing a *population total*. A pool needs the opposite axis — an
**exact per-recipient total**, with only the *link* between recipient and submitting identity
hidden. So the primary tool is unlinkable submission (OHTTP + blind-signature credentials),
not Prio.

## Ranked by transferability, with the trust each substitutes in

| # | Architecture | Transferability | Trust substituted (nothing is free) |
|---|---|---|---|
| 1 | **Split-trust relay for share submission** (RFC 9458 OHTTP; iCloud Private Relay; PCC relay) | **High** — pool sees shares + payout address, never the submitting IP; relay sees the connection, not the share | Relay and pool **must not collude or be co-owned** (RFC 9458 §6.8). Inherits: no forward secrecy within a key epoch (§6.6); **any persistent state re-links the client** (§2.1.2). ≥2 round trips per submission. |
| 2 | **Blind-signature / anonymous-credential admission** (Private Relay's BAA-issued one-time RSA blind sigs; PCC single-use credentials) | **High** — proves "enrolled, paid-up, non-abusive miner" without learning which one | Issuer must not collude with redeemer; you must rebuild the anti-abuse layer the token replaced (double-spend detection, per-day issuance limits, daily rotation). Rate limiting itself shrinks the anonymity set (§6.2.1.3). |
| 3 | **Multi-vendor TEE trust splitting** (SVR3: SGX/Azure + SEV-SNP/GCP + Nitro/AWS, t=2 of n=3) | **Medium-high** for holding an attribution table; **low** for metadata | "No attacker compromises >2 of 3 vendor+cloud stacks **simultaneously**." Costs 3× cloud spend; per-enclave-type threat re-derivation. **SVR3 states it "does not hide the identity of clients or the timing of… requests"** — must layer *under* #1/#2, never instead. |
| 4 | **Single TEE + reproducible build + client-enforced transparency log** (PCC pattern; Nitro PCRs) | **Medium** — cheapest credible "we structurally can't read it" | Trust in the CPU/hypervisor vendor who *signs the attestation* — **AWS attests AWS** — plus your build pipeline, plus somebody actually auditing the log. |
| 5 | **Private aggregation** (Prio / DAP / Divvi Up) | **Medium, but not for the ledger** — fits published statistics and cross-pool reconciliation | Prio: privacy with 1-of-s honest, **robustness only if ALL servers honest**. Imports selective-DoS and intersection attacks, which bite hardest on a system publishing exact numbers every block. |
| 6 | **Oblivious data structures** (Path ORAM, PIR) | **Medium-narrow** — for the *read* path (miner asks "what am I owed?"), not the accounting path | Large constant factors. Signal's Path ORAM: ~1,800 accesses vs 1 B linear. SimplePIR 10 GB/s/core but **121 MB client hint per 1 GB DB**; DoublePIR 16 MB hint, 345 KB/query. The hint, not throughput, breaks deployments. |
| 7 | **Client-held keys / write-only append-only accounting** (retain only running totals) | **High per unit of effort, and the most honest** — no non-collusion assumption, no enclave, no vendor | Substitutes nothing cryptographic; substitutes **capability for functionality** — no dispute forensics, no retroactive withholding investigation. Strong against retrospective compulsion, weak against prospective. |
| 8 | **Differential privacy on aggregates** | **Near-zero for the ledger** — money must be exact | Substitutes exactness for privacy, the one trade a payout system cannot make. Prio itself "does not natively provide differential privacy." Fine for dashboards; keep away from balances. |

## RFC 9458 (Oblivious HTTP) — the standardized split-trust pattern

Four roles: Client, Oblivious **Relay**, Oblivious **Gateway**, Target. Relay sees client IP +
ciphertext + timing/size, never plaintext; Gateway sees plaintext but only the relay's address
and "cannot link requests from the same Client in the absence of unique per-Client keys"
(§6.10.2.1).

The load-bearing assumption is a hard requirement: the relay "cannot be operated by the same
entity as the Oblivious Gateway Resource" (§6.8).

**The caveat that matters most for a pool** — §2.1.2: OHTTP "removes linkage at the transport
layer, which is only useful for an application that does not carry state between requests."
**A payout address is persistent state.** Any credential or address re-links the user.

Explicit non-protections: no forward secrecy during a key configuration's lifetime (§6.6); no
post-compromise security for responses (§6.7.1) — a leaked gateway key retroactively exposes
historical pairs; traffic analysis out of scope (§6.11). Anti-replay is delegated, not
provided. Differential treatment (rate limiting, blocking) "reduce[s] the size of the anonymity
set" (§6.2.1.3). Requires fixed one-to-one relay↔gateway allowlisting (§8.2.1).

## SVR3 (Signal, OSDI '24) — production multi-vendor TEE

Three **heterogeneous** enclave clusters on three clouds: Intel SGX/Azure, AMD SEV-SNP/GCP,
AWS Nitro/AWS. "the first deployed cross-enclave, cross-cloud secret key recovery system."
n=3, **t=2**: "if an attacker simultaneously compromises ≤ t trust domains… the attacker only
has ⌊nu/(t+1)⌋ PIN attempts." Rationale: "the odds of an attacker identifying and exploiting
vulnerabilities *simultaneously* across > t trust domains is low."

Crypto: Password-Protected Secret Sharing (Jarecki et al.), chosen "primarily because it
requires no cross-trust domain communication." Enclave threat model enumerated honestly:
(A1) memory-access-pattern side channels, (A2) software rollback, (A3) **hardware** rollback
via DIMM interposer, (A4) power/transient-execution. Uses a modified Raft (Raft^↻) with a
**TLA+ safety proof** against physical rollback — vanilla Raft is not rollback-safe.

Scale/cost: **$0.0025/user/year, 365 ms recovery, millions of users, capacity 500 M+.**

**The critical admission**: "SVR3 does not hide the identity of clients or the timing of backup
and recovery requests." Multi-cloud "incurs higher monetary costs."

## Why attestation is weaker than advertised

**SGAxe (2020)**: extracts the sealing key of Intel's own signed production Quoting Enclave via
CacheOut, then unseals the persistent attestation key — "with any of Intel's countermeasures…
including the recent hardening for the LVI attack," and **while the victim enclave is
completely idle**. Consequence in the authors' words: "we can build a malicious SGX simulator
that passes Intel's entire remote attestation process," and "any outputs allegedly produced by
enclaves running on the client cannot be trusted for correctness." They analyze impact on
**Signal** and Town Crier. EPID compounding: "obtaining even a single EPID private key allows
us to forge signatures for the entire EPID group, which contains millions of SGX-capable Intel
CPUs."

**ÆPIC Leak (USENIX Sec '22)**: "the first architectural CPU bug that leaks stale data from the
microarchitecture **without using a side channel**." All Sunny-Cove-based Intel CPUs. "Our
end-to-end attack extracts AES-NI, RSA, and even the **Intel SGX attestation keys** from
enclaves within a few seconds." Conclusion: "the only short-term mitigations… are to disable
APIC MMIO **or not rely on SGX**."

**"SoK: A cloudy view on trust relationships of CVMs" (arXiv 2503.08256, Mar 2025)** —
per-provider, and bleaker than any vendor doc: "**all major cloud providers retain control over
critical parts of the trusted software stack and, in some cases, intervene in the standard
remote attestation process. This directly contradicts their claims of delivering confidential
computing.**" Azure SEV-SNP: HCL and guest firmware closed source, measurements not
reproducible. AWS SEV-SNP: guest OS image "cannot be retrieved by the customer after being
modified by AWS tooling," so "**AWS becomes a trusted stakeholder on attestation.**" GCP TDX:
"the virtual firmware is closed-source software owned by Google, therefore not attestable."
AWS **Nitro Enclaves** is excluded from analysis entirely because Amazon is "both acting as
hardware vendor and cloud provider." Every offering fails unique target identification.
Their threat model puts side channels *out of scope* — so this is a **lower bound**.

Nitro specifics: PCR0 = EIF contents, PCR1 = kernel+bootstrap, PCR2 = application, PCR3 =
SHA384 of parent IAM role ARN, PCR4 = SHA384 of parent instance ID, PCR8 = EIF signing cert.
The attestation document is generated **by the Nitro Hypervisor** — by AWS. Operational trap:
`--debug-mode` / `--attach-console` produce **all-zero PCRs**. AWS ships no turnkey
reproducible-build tooling.

**RFC 9334 (RATS)**: Evidence describes "operational status, health, configuration, or
construction" — *what* code is running, never whether it behaves correctly.

## The two most transferable mechanisms

**Apple PCC's non-targetability**: single-use credentials via **RSA Blind Signatures** authorize
a request without tying it to a user; a third-party-operated **OHTTP relay** hides the device
IP; the load balancer holds no identifying info so it cannot bias node selection. An attacker
"needs both." Verifiable transparency: production images published, measurements in an
**append-only tamper-proof log**, and the device "wraps request payload key **only to PCC nodes
whose attested measurements match logged releases**." Stated publication window is **within 90
days** — detection is *delayed*, not immediate. Hard operational guarantees: no remote shell,
no interactive debugging, Developer Mode cannot be enabled, no JIT, only pre-specified
structured logs may leave a node, Secure Enclave randomizes the data-volume key every reboot
and never persists it.

**iCloud Private Relay's decoupled authorization**: two hops with deliberately different
operators (Apple ingress sees original IP with website names encrypted; third-party CDN egress
sees the website name, "has no knowledge of the user's original IP address"). Location degraded
on purpose — IP converted to a **geohash truncated to four characters, ~800 km²**, handed back
*to the device*. Relay IPs rotate across sessions. Authorization via **one-time-use RSA
blind-signature tokens** minted after device+account attestation, validated with a public key
"without actually identifying the user," rotated daily, with **asynchronous double-spend
prevention** and per-day rate limits. Proxy auth via **raw public keys** in the TLS 1.3
handshake compared against a separately distributed authenticated configuration — not the web
PKI.

**That client-side enforcement step — encrypt only to measurements in the log, pin raw public
keys against a separately distributed config — is the single most transferable mechanism in
this entire set, and worth more to a blind pool than the enclave it protects.**

## Prio / DAP specifics

Prio (NSDI '17): client additively secret-shares `x_i` over 𝔽_p; each server accumulates;
`Σ_j A_j` yields `Σ_i x_i`. Privacy holds "as long as at least one server is honest," against
an adversary who "can observe the entire network, control all but one of the servers, and
control a large number of clients." **SNIPs** give robustness against malicious clients
without public-key crypto — information-theoretic, "a few hundred bytes" server-to-server per
submission, **50–100× faster than NIZKs**. Total overhead 5.7× over a no-privacy baseline;
1,312–2,608 submissions/sec on a five-server global cluster.

Two named attacks that apply to **any exact-output aggregation**, and bite hardest on
per-block payouts: **selective DoS** (block all honest clients but one, read the survivor's
value off the total) and **intersection attack** (force a client offline between two runs and
diff the outputs). Standard defense is withholding results until a threshold of honest clients
has contributed — i.e. **batching delays before payout**.

Prio's best deployment argument here is **"jurisdictional diversity"**: "If law enforcement
agents seize the Prio servers in one country, they cannot deanonymize the organization's Prio
users."

DAP (draft-ietf-ppm-dap): Leader/Helper/Collector over VDAFs; per-aggregator HPKE so the
Leader cannot read the Helper's share; 16-byte report IDs with per-aggregator replay stores;
`min_batch_size`; batches collectable once. **Still not an RFC** — draft-19 (Jul 2026),
"Waiting for Write-Up"; `draft-irtf-cfrg-vdaf` also still a draft (v20). Production split:
**Fastly runs the OHTTP relay, ISRG's Divvi Up runs the DAP aggregator** for Firefox
page-load telemetry.

## The failure mode nothing on this list fixes

Attestation binds the *identity* of running code, not its trustworthiness (RFC 9334); it cannot
rule out backdoors or compelled changes (arXiv 2409.03720: "attestation alone cannot guarantee
the absence of vulnerabilities or backdoors"). A transparency log converts a code substitution
from invisible to *eventually detectable by whoever checks* — PCC's 90-day window shows the lag
is real. Because the operator controls the build, the signing key, and the release cadence,
"we made ourselves unable to comply" is durable in only one form: **data that was never
collected, in a design where collecting it would require a client-visible, log-visible change
that clients refuse to encrypt to.**

## Negative results

- **No substantive independent critique of Apple PCC's trust model found.** Searches returned
  only Apple's own docs and restatements. The best adversarial framing available is the CVM SoK
  applied by analogy.
- **No good primary source on verifiable key deletion / cryptographic proof-of-erasure at
  scale.** PCC's Sealed Key Protection and SVR3's "unconditionally delete key material" are
  closest; neither gives the *user* a proof deletion occurred. **Treat verifiable deletion as
  an open problem, not an available primitive.**
- **No source found treating legal compulsion of enclave operators rigorously.**
- Signal's "Building Faster ORAM" blog contains **no discussion of SGX side channels or
  attestation weaknesses** — the honest accounting is in the SVR3 paper, not the blog.
