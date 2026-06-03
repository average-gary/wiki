---
title: "nostr.how — official Nostr getting-started guide on key safety"
url: https://nostr.how/en/get-started
retrieved: 2026-06-02
type: article
---

The official end-user guide at nostr.how is the closest thing Nostr has to user-facing documentation. On key safety it states bluntly: "If you lose your private key your Nostr account is lost. If someone else gains access to your private key, they can take control of your account." It recommends storing the key in a password manager (1Password) or a browser extension like Alby.

The guide notably does NOT discuss key rotation, recovery, or what to do if an nsec is leaked. The only recovery-adjacent language is the warning that, unlike passwords, private keys "cannot be reset if lost." That sentence is, in 2026-06-02, the canonical user-facing acknowledgment that Nostr has no rotation primitive. Damus's homepage and Amethyst's user-facing docs follow the same pattern: emphasize "you truly own your account" without addressing the failure mode where ownership turns into permanent compromise. This is the strongest primary evidence that the gap is unsolved at the deployed-client layer, not just at the spec layer.
