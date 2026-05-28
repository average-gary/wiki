# theses — cdk-ldk-lnurl

Testable claims.

- [ldk-node-receive-description-hash.md](ldk-node-receive-description-hash.md) — **SUPPORTED (high confidence)** — LDK Node `Bolt11Payment::receive` accepts caller-supplied 32-byte description_hash via `Bolt11InvoiceDescription::Hash(Sha256)` since v0.5.0
- [single-ln-node-deployment-feasibility.md](single-ln-node-deployment-feasibility.md) — Whether spec-compliant LUD-06 LNURL can be served from a CDK + LDK deployment with a single LN node *(now mostly resolved by thesis above — gap is CDK-side only)*
- [ldk-node-vs-cln-for-mints-under-1btc.md](ldk-node-vs-cln-for-mints-under-1btc.md) — Whether LDK Node is operationally safer than CLN/LND for mints below ~1 BTC reserve *(investigating)*
