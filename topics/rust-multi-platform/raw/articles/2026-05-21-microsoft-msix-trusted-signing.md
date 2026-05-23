---
title: "Microsoft Code Signing — Azure Trusted Signing replaces EV cert pattern"
source: https://learn.microsoft.com/en-us/windows/msix/package/signing-package-overview
type: article
tags: [windows, code-signing, smartscreen, trusted-signing, distribution]
date: 2026-05-21
quality: 6
confidence: high
agent: 4
summary: "Microsoft now actively recommends Azure Artifact Signing (formerly Trusted Signing) over CA-purchased certs. Identity-based reputation (~$10/mo) replaces the historical $300-700/yr EV cert pattern. Reputation accumulates across builds, not per-cert."
---

# Microsoft Trusted Signing — major shift in Windows code signing

## Pricing tiers (April 2026)

| Scenario | Option | Cost |
|----------|--------|------|
| Dev / local testing | Self-signed cert | Free |
| Production (recommended) | **Azure Artifact Signing** (formerly Trusted Signing) | **~$10/month** |
| Production (alternative) | OV code signing cert from CA | $300–500/year |
| Microsoft Store | Signed by Store on submission | Free |

## Why Trusted Signing wins

> "Identity-based reputation: Reputation is tied to your verified publisher identity rather than a specific certificate, so it accumulates across builds."

The historical pattern: buy an EV cert from DigiCert/Sectigo for $300-700/yr to get **instant SmartScreen reputation**. This is **no longer required**. Trusted Signing's reputation follows your verified identity, not your certificate.

## Caveat — new apps still warn initially

> "new apps will still show SmartScreen warnings until sufficient download history builds — this typically takes several weeks"

Even with Trusted Signing, fresh apps need download volume before SmartScreen stops warning. EV certs got around this with bonded identity vetting; Trusted Signing rebuilds reputation per-publisher.

## Eligibility

Public Trust certificates require:
- Organizations: USA/Canada/EU/UK with **3+ years tax history**
- Individual developers: USA/Canada

## Technical setup

- Trusted Signing issues short-lived certs daily (each ~3 days valid) for time-precise revocation
- Supports GitHub Actions via `azure/trusted-signing-action`
- Requires Azure Artifact Signing Client Tools: `winget install -e --id Microsoft.Azure.ArtifactSigningClientTools`
- Integrates with SignTool

## Note

**AzureSignTool** (community) is for Azure Key Vault-stored certs and does NOT support Artifact Signing. Different tool, different workflow.

## Always timestamp

> "Without timestamping, signed packages stop installing once the cert expires; with it, packages install indefinitely."

## Cost economics for indie Rust developers

Old: ~$700/yr EV cert
New: ~$120/yr Trusted Signing
**Indie projects can now afford "real" code signing.** This is the most impactful change for solo Rust devs shipping Windows binaries in years.

## Cross-references

- [[cargo-dist]] — auto-generates SignTool invocation hooks
- [[volks73/cargo-wix]]
