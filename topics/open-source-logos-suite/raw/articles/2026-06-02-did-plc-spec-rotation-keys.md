---
title: "did:plc method specification — rotation keys & 72h recovery"
url: https://github.com/did-method-plc/did-method-plc
retrieved: 2026-06-02
type: spec
---

Canonical specification for the `did:plc` method used by ATProto / Bluesky. DIDs are derived from hashing their genesis operation (self-certifying), and identity state is maintained as a hash-chained log of DAG-CBOR operations submitted to a directory server.

Crucially for the rotation comparison: the spec states that "control of a `did:plc` identity rests in a set of reconfigurable rotation key pairs." Each DID has 1–5 rotation keys, priority-ordered from highest to lowest authority. Rotation keys are NOT included in the public DID document — they are the secret backstop. Any rotation key can sign updates, but higher-authority keys can override lower-authority ones during a 72-hour recovery window: if a lower-authority key is compromised and used to publish bogus updates, a higher-authority key can rewrite history within 72 hours and invalidate the attacker's operations.

This is exactly the primitive Nostr lacks. It is a real specified, deployed, recovery mechanism, not a stylistic difference. The contrast in the assess report holds.
