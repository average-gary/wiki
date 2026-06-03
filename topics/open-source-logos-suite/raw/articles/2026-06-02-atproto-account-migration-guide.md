---
title: "ATProto account migration guide"
url: https://atproto.com/guides/account-migration
retrieved: 2026-06-02
type: article
---

Official ATProto documentation walking through account migration between Personal Data Servers (PDSs) using `did:plc`. The cooperative migration flow: the old PDS signs a PLC operation containing the new PDS's service location and updated keys (rather than having the user sign directly), and submits it to the PLC directory; an email-verified security token is required via `com.atproto.identity.requestPlcOperationSignature` to prevent unauthorized migrations.

For users with strong key-management practices, the guide recommends including "a self-controlled PLC rotation key (public key) in the PLC operation." This rotation key gives the user the ability to sign their own future migrations and recover from a compromised or hostile PDS without the PDS's cooperation — the so-called "credible exit." This is the deployed reference for what an identity-with-rotation flow looks like in production for non-technical users; ATProto/Bluesky has millions of accounts using exactly this model. It is the strongest existing primary-source contrast to Nostr's "your nsec leaks, you start over" reality.
