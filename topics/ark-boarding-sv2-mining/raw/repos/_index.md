---
title: ark-boarding-sv2-mining — raw/repos index
type: raw-subindex
---

# raw/repos

| File | Credibility | Direction | Source |
|---|---|---|---|
| sv2-spec-extensions | high | supports | stratum-mining/sv2-spec 09-Extensions |
| demand-share-accounting-ext | high | nuances | this repo (NewBlockFound trigger) |
| arkd-batch-event-handler | medium | supports | arkade-os/arkd tree-signing events |
| flock-research-ark | medium | supports | barrydeen/flock research-ark |

- [[2026-07-17-arkd-batch-event-handler.md|arkade-os/arkd — batch event handler (tree signing wire schema)]] — Real MuSig2 tree ceremony carried as coordinator-pushed events: TreeNoncesEvent -> TreeNoncesAggregatedEvent…
- [[2026-07-17-braidpool-spec.md|Braidpool spec — payout & signer scaling]] — Signing very large threshold Schnorr outputs is impractical'; signer set capped at ~50 (winners of last S…
- [[2026-07-17-demand-share-accounting-ext.md|demand-open-source/demand-share-accounting-ext (this repo)]] — SV2 share-accounting extension, EXTENSION_TYPE=32. Has a NewBlockFound (0x03) message sent by the pool…
- [[2026-07-17-flock-research-ark.md|barrydeen/flock — research-ark.md]] — clArk = n-of-n pre-signed pseudo-covenant: server+all participants cosign every tree tx (MuSig2) then delete…
- [[2026-07-17-sv2-spec-extensions.md|Stratum V2 spec — 09-Extensions + 0x0001 negotiation]] — Formal extension_type registry; core=0x0000; RequestExtensions negotiation after SetupConnection,…
