---
title: "IPFS in Practice — Wikipedia Summary, Adoption, and Real Limits"
source_url: "https://en.wikipedia.org/wiki/InterPlanetary_File_System"
type: article
path: infra-text
date_ingested: 2026-05-27
date_published: unknown
tags: [decentralized, ipfs, content-distribution, criticism]
quality: 4
confidence: high
summary: "Wikipedia's IPFS overview confirms real adoption (Anna's Archive, Library Genesis, censorship-circumvention mirrors) but also documents Brave removing IPFS support in 2024 and ongoing security/abuse incidents — a useful corrective to the marketing."
---

# IPFS in Practice — Wikipedia Summary, Adoption, and Real Limits

## Key findings

- **Real production use exists, mostly for shadow libraries and censorship circumvention**: Anna's Archive and Library Genesis distribute books over IPFS; Wikipedia mirrors via IPFS during Turkish and Catalan referendum blocks. This is the most directly analogous use case to "ship a digital library to clients".
- **Brave removed IPFS in 2024**, after adding it in 2021. This is the single most important data point on browser viability: the most aggressive mainstream IPFS-in-browser bet was rolled back. Browser-native IPFS is effectively dead; production consumer use is via HTTP gateways (cloudflare-ipfs, dweb.link, ipfs.io).
- **Filecoin is the financial backbone**, not the technical one. Most Bible/text-corpus publishers will not touch a crypto-token incentive layer.
- **Security incidents documented**: phishing through Cloudflare's IPFS gateway since 2018, IPStorm botnet using IPFS for C2 since 2019. These are not technical flaws of IPFS per se but show that public gateways are abused, which leads operators to filter aggressively, which then degrades reliability for legitimate publishers.
- **No performance benchmarks in the article** — the omission itself is telling. If IPFS performed well, the IPFS Foundation would publish numbers. The silence on latency is consistent with the well-known DHT-lookup-takes-seconds problem.

## Notable quotes / specifics

- "Brave added support in 2021 (later removed in 2024)" — direct evidence that the browser-native pitch failed.
- Anna's Archive and Library Genesis listed as successful examples — shadow libraries that *expect* their content to be unwelcome at any single host.

## Source notes

A balanced read of this article gives the honest picture: IPFS works when (a) content is mildly controversial enough that the "no central host" property is the actual product, and (b) consumers are willing to install software or accept gateway latency. A mainstream Bible-reader app fits neither condition well — content is uncontroversial, and consumers expect Logos/YouVersion-tier latency. Use IPFS as an optional mirror, not as the primary distribution path. The chunker-incompatibility issue documented in the IPFS-content-addressing source compounds this.
