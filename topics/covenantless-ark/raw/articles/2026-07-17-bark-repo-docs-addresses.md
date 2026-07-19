---
title: "Ark Addresses (bark docs/addresses.md)"
source: "https://gitlab.com/ark-bitcoin/bark/-/blob/4f1b646ae3c4387bd374d835f76719637a48b846/docs/addresses.md"
type: articles
ingested: 2026-07-17
tags: [collection, bark-repo, ark, arkoor, address, bech32m, boat-001, vtxo-policy, mailbox, delivery]
summary: "bark's Ark address format: bech32m ark1/tark1, cross-Ark spec BOAT-001. Encodes a 4-byte server-pubkey hash + VTXO policy (currently Pubkey; future multisig/miniscript) + VTXO delivery methods (server message-passer or Unified Mailbox)."
collection: "bark-repo"
adapter: git
upstream_id: "docs/addresses.md"
upstream_type: git-file
revision: "4f1b646ae3c4387bd374d835f76719637a48b846"
sha: "f41cb99bbeff2aa18524c0aeb8288977b8cd29ee"
canonical_url: "https://gitlab.com/ark-bitcoin/bark/-/blob/4f1b646ae3c4387bd374d835f76719637a48b846/docs/addresses.md"
content_format: markdown
license: "MIT"
fetched: 2026-07-17
outlinks: ["https://github.com/ark-protocol/boats/blob/master/boat-0001.md"]
---

# Ark Addresses (bark docs/addresses.md)

Part of the [[../repos/2026-07-17-collection-bark-repo-manifest.md|bark-repo collection]].

- Transactions within an Ark are **Arkoor transactions**; addressing uses **Ark addresses**.
- Format: **bech32m** (like bitcoin), prefix **`ark1`** (mainnet) / **`tark1`** (test networks).
- Cross-Ark spec: **BOAT-001** (github.com/ark-protocol/boats/blob/master/boat-0001.md) — a universal repo for cross-Ark specifications. (New primitive: "BOATs" = cross-Ark specs, analogous to BIPs/BOLTs.)
- The address encodes **three things**:
  1. **Ark server identifier** — a **4-byte hash of the server pubkey** (the server's fixed main public key), so a recipient can tell if the sender is on the same Ark.
  2. **VTXO policy** — where to receive; currently the **`Pubkey`** policy (user's public key). Future: multisig or generalized **miniscript**-based policies.
  3. **VTXO delivery methods** — how the cosigned arkoor VTXO reaches the recipient.
- **Delivery**: no mempool exists off-chain. By default the server acts as a message-passer notifying users of new money; but users may not want to rely on the server, so the address can list **multiple** receive methods.
- **Unified Mailbox**: optional; all a user's VTXOs found together so they needn't poll per-pubkey; server can notify on mailbox entry. See [[2026-07-17-bark-repo-docs-mailbox.md|mailbox]].
