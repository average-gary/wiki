# Log — cdk-ldk-lnurl

## [2026-05-28] init | new topic wiki created — CDK + LDK + LNURL deployment

## [2026-05-28] research | "deploying LNURL using Cashu Dev Kit's LDK node" (deep mode, 8 agents) → 23 sources ingested, 10 articles compiled

## [2026-05-28] thesis | "LDK Node bolt11_payment().receive accepts caller-supplied description_hash" (5 agents) → 5 sources ingested. Verdict: SUPPORTED, high confidence. Mechanism is `Bolt11InvoiceDescription::Hash(Sha256)` enum variant (since ldk-node v0.5.0, PR #438, May 2025). Remaining gap is purely CDK-side.
