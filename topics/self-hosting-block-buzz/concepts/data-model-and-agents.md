---
title: Data Model & Agents (Custom NIPs, Git, Runtime)
type: concept
tags: [buzz, nostr, nips, data-model, agents, git, event-kinds, mcp]
confidence: high
created: 2026-07-23
updated: 2026-07-23
---

# Data Model & Agents

Everything in buzz is a **signed Nostr event** of some kind, stored in Postgres. The event
kinds *are* the data model. buzz ships ~14 custom NIPs on top of the base Nostr protocol.

## Agent identity NIPs (the interesting part)

- **NIP-OA (Owner Attestation)** — an owner key authorizes an agent key to publish. The agent
  stays the author (`event.pubkey`); the owner attestation is **provenance evidence, not
  impersonation**. This is the "verifiable passport" that ties an agent to a human.
- **NIP-AA (Agent Authentication)** — the agent presents its NIP-OA credential during NIP-42
  AUTH (`kind 22242`); the relay verifies it and checks the owner is an active member. **Agents
  get relay access via their owner's membership.**
- **NIP-AM (Agent Turn Metrics, `kind 44200`)** — encrypted per-turn token usage + estimated
  cost, readable only by the owner.

## Channel / sync NIPs

- **NIP-CW (channel windowing)** — relay-signed overlays: `kind 39005` (thread summary),
  `kind 39006` (window bounds: `has_more` + next cursor) for paginated timelines.
- **NIP-WP (`kind 9033`)** — workspace profile icon (served in the NIP-11 relay info doc).
- **NIP-RS (`kind 30078`)** — cross-device read-state sync (encrypted, parameterized-replaceable).
- **NIP-DV (`kind 30622`)** — per-viewer DM-visibility snapshot (hide a DM without leaving).
- Full set (~14): NIP-AA/AE/AM/AO/AP/CW/DV/ER/GS/IA/OA/PL/RS/WP.

## Git on object storage

buzz hosts git repos as data, not as a separate forge:

- Repos live on **S3-compatible object storage**: content-addressed **immutable pack objects**
  plus a single mutable **manifest pointer** updated by atomic compare-and-swap.
- `git index-pack` / `upload-pack` / `receive-pack` are trusted upstream binaries; buzz proves
  it feeds them well-formed input.
- A push may publish `kind 30618` so subscribers learn refs moved (NIP-34 lineage).
- **NIP-GS** signs commits/tags with the same secp256k1 keypair used for Nostr, via
  `git-sign-nostr` / `git-credential-nostr`.

## Formal verification (a maturity bright spot)

The repo ships formal specs in `docs/spec`: `GitOnObjectStore.tla`, `MultiTenantRelay.tla`
(TLA+) and `MultiTenantAuth.spthy` (Tamarin) — unusually rigorous for an OSS project. Note the
multi-tenant spec is a **draft of a proposed design**, not shipping reality (see
[Operations, Security & Maturity](operations-security-maturity.md)).

## Agent runtime

Runtime stack: `Buzz Desktop → buzz-acp → buzz-agent → MeshLLM SDK → local/remote compute`.

- Built-in agent **Fizz** — bundled `buzz-agent`, no API key required, inherits the default
  provider/model.
- **Shared compute** — "Share this machine" exposes local GPU; inference travels over **MeshLLM**
  via direct QUIC or encrypted **iroh** relays; Buzz membership controls which node identities
  are admitted.
- **MCP-driven hooks** — lifecycle hooks are ordinary MCP tools (`tools/list` / `tools/call`);
  `_`-prefixed tools are hooks hidden from the LLM (`_Stop`, `_PostCompact`). Safety: 2.5s
  timeout, a 3-rejections-per-prompt budget, hook output injected as **lower-trust** tool-result
  messages.

> The MCP transport choice matters for VPN deployments — stdio MCP needs no network, HTTP/SSE MCP
> must be reachable over the tunnel. See [Connecting Clients & Agents Over a VPN](connecting-over-vpn.md).

## See Also

- [What buzz Is](what-is-buzz.md)
- [Connecting Clients & Agents Over a VPN](connecting-over-vpn.md)
- [Operations, Security & Maturity](operations-security-maturity.md)
