---
title: "Cloudflared and AWS SSM — SSH ProxyCommand patterns"
source: https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/use-cases/ssh/ssh-cloudflared-authentication/, https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started-enable-ssh-connections.html
type: article
tags: [ssh, proxycommand, cloudflared, aws-ssm, pattern, allowlist]
date: 2026-06-01
quality: 4
confidence: high
agent: 7
summary: "Cloudflare Zero Trust uses ProxyCommand `cloudflared access ssh --hostname %h`; AWS SSM uses ProxyCommand `aws ssm start-session --target %h --document-name AWS-StartSSHSession`. Common shape across both vendors: (1) magic Host pattern in ssh_config, (2) external command speaks the auth+transport, (3) ssh sees a stdio pipe. ssh client unmodified; identity, NAT traversal, and authn live in the ProxyCommand binary."
---

# ProxyCommand: the universal SSH integration point

Two independent vendors converge on the same shape. The Iroh ssh app should target this exact contract.

## Cloudflare Zero Trust shape

```
# ~/.ssh/config
Host ssh.example.com
    ProxyCommand /usr/local/bin/cloudflared access ssh --hostname %h
```

User runs plain `ssh user@ssh.example.com` — `cloudflared` opens a browser for IdP auth, then pipes stdio between ssh and the tunnel.

Transport invisible to ssh; ssh only knows it has a stdio pipe.

## AWS SSM shape

```
# ~/.ssh/config
Host i-* mi-*
    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
```

Magic Host glob `i-* mi-*` matches EC2 instance IDs. Same shape; different transport.

## The shared pattern

1. **Magic Host pattern** in ssh_config — selects a class of targets
2. **External command** speaks auth + transport — IdP login, token mint, tunnel setup
3. **ssh sees a stdio pipe** — ssh protocol completely unaware

## Caveat both vendors share

SSH session logging cannot see inside the SSH stream (TLS-in-TLS). Same caveat applies to any Iroh ProxyCommand:

```
# ~/.ssh/config
Host *.iroh
    ProxyCommand iroh-ssh access %h
```

Iroh-ssh would have visibility on:
- Connection establishment (peer EndpointID)
- Bytes-on-wire counts
- Connection lifetime

NOT visibility on:
- SSH command issued
- Files transferred
- Inner SSH multiplexed sessions

## Implication for the GTX 1060 server's iroh-ssh design

Match this exact UX:
1. SSH config: `Host *.iroh` → `ProxyCommand iroh-ssh access %h`
2. `iroh-ssh access` resolves `%h` to an EndpointID (lookup in `~/.iroh-ssh/known_endpoints` keyed by hostname)
3. Establish iroh QUIC stream, pipe stdio
4. Server-side: enforce `~/.iroh-ssh/allowed_node_ids` via `AccessLimit<P>`

## See also

- [[2026-06-01-dumbpipe-binary]] — the primitive
- [[2026-06-01-iroh-ssh-rustonbsd]] — community impl missing the allowlist piece
