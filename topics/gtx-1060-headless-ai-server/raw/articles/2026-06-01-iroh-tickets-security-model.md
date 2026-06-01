---
title: "iroh tickets — security caveats (iroh docs + Discussion #3168)"
source: https://docs.iroh.computer/concepts/tickets, https://github.com/n0-computer/iroh/discussions/3168
type: article
tags: [iroh, tickets, qr-pairing, security, no-revocation, contrarian]
date: 2026-06-01
quality: 5
confidence: high
agent: 5
summary: "Iroh's own docs: tickets embed current IP addresses (sharing = doxxing your network location), tickets are NOT single-use ('can be used multiple times by anyone who has it'), there is no built-in expiration, and there is no revocation — once leaked, the ticket is live forever. Discussion #3168 adds: tickets 'don't inherently provide client authentication,' NodeIds leak via mDNS/DNS discovery, relays know who talks to whom, even on first connect a stranger learns your supported ALPNs/public IP/timing. Maintainer quote: 'I would still recommend not relying on this for actual authentication.' PR #3157 is the open work-in-progress to wrap protocols with a generic auth layer."
---

# Iroh ticket security model — first-party caveats

Devastating first-party evidence for the QR-pairing-pitfalls and multi-ALPN-routing critiques.

## What an iroh ticket actually contains

```
EndpointTicket = base32(EndpointAddr {
    endpoint_id: PublicKey (Ed25519, 32 bytes),
    relay_url: Option<RelayUrl>,
    direct_addresses: Vec<SocketAddr>,
})
```

Direct addresses are the holder's **current IP addresses**. Sharing the ticket = doxxing the holder's network location.

## Five caveats from official docs

1. **Embeds current IP addresses** — sharing leaks network location
2. **NOT single-use** — anyone with the ticket can use it multiple times
3. **No built-in expiration**
4. **No revocation** — once leaked, the ticket is live for the lifetime of the EndpointID secret key
5. **App-encoded write capabilities mean a captured QR is a permanent write grant** if the app uses tickets for capability conveyance

## Discussion #3168 — maintainer guidance

> "I would still recommend not relying on this for actual authentication."
> — n0 maintainer

Specific issues:

- Tickets "don't inherently provide client authentication"
- NodeIds leak via mDNS / DNS discovery — anyone on the LAN learns them
- Relays know who talks to whom
- On first connect, a stranger learns your supported ALPNs, public IP, and timing

## Open WIP

PR #3157 — generic auth layer that wraps protocols. Status: in progress.

## What this means for QR pairing UX in the GTX 1060 AI server

**Don't rely on tickets as auth credentials.** Layer your own:

1. **Capability tokens** — embed an HMAC of (EndpointID, ALPN, expiry) signed by the server's HMAC key in the ticket payload
2. **Time-bound sessions** — even if the ticket is captured, the embedded capability has an expiry
3. **`AccessLimit<P>` allowlist** at the Router layer — only honor connections from explicitly-allowed peers
4. **Rotate the seed (à la Wesh)** — instead of revoking individual tickets, rotate a per-app seed periodically; old tickets stop validating

See [[2026-06-01-briar-bhp-protocol]] and [[2026-06-01-tailscale-auth-keys]] for ticket flag schemas to mirror.

## See also

- [[2026-06-01-noise-protocol-framework-rev34]] — IK pattern caveats
- [[2026-06-01-tailscale-auth-keys]] — bearer-token flag schema reference
- [[2026-06-01-briar-bhp-protocol]] — "QR is the trust anchor" philosophy
