---
title: Concepts
type: index
updated: 2026-07-21
---

# Concepts — sv2-coinbase-verify-daemon

- [[wiki/concepts/sv2-mining-client-message-flow]] — the ordered connect→handshake→open-channel→job→submit sequence.
- [[wiki/concepts/standard-vs-extended-channels-coinbase-visibility]] — **the pivotal fact**: only extended channels expose the coinbase.
- [[wiki/concepts/coinbase-transaction-anatomy]] — coinbase fields (scriptSig/BIP34/tags, outputs, OP_RETURN commitment) and what each check targets.
- [[wiki/concepts/coinbase-reconstruction-and-merkle-fold]] — the byte-level reconstruct→txid→merkle-fold algorithm.
- [[wiki/concepts/expected-value-checks-taxonomy]] — the check×field×feasibility table.
- [[wiki/concepts/sourcing-the-expected-value]] — where the expected value comes from (subsidy from height; fees from a template; payout target by scheme).
- [[wiki/concepts/sri-client-crate-stack]] — minimal Rust crate set (verified versions); channels_sv2 reuse win; naming traps; sniffer-vs-own-client.
- [[wiki/concepts/deviation-detection]] — job-diff heuristic + on-chain correlation loop + what's undetectable.
- [[wiki/concepts/coinbase-verification-trust-model-limits]] — why passive verification is trust-but-verify, not trustless.
- [[wiki/concepts/prior-art-coinbase-verification]] — miningpool.observer, stratum.work, DATUM, JD, and the gap.
