---
title: "sv2-spec #95 — Handle unknown extensions / extension negotiation"
source: "https://github.com/stratum-mining/sv2-spec/issues/95"
type: notes
ingested: 2026-07-17
tags: [sv2, sv2-spec, extensions, extension-negotiation, version-negotiation, unknown-extension, nack, ack, extensions-sv2, github-issue, design-discussion]
summary: "GitHub issue in stratum-mining/sv2-spec: the spec requires extensions to do version negotiation before sending extension messages, but never says HOW. Fi3 proposes a universal per-extension NACK frame (msg_type 0xff); jakubtrnka argues for positive-ACK-only (assume unsupported until ACK). Discussion of NACK vs timeout, per-extension reserved message ids (0 = NegMsg, 255 = ACK), and how to stop/override extensions. Open, unresolved."
issue_number: 95
issue_state: "open (as of 2026-07-17 fetch; last activity 2024-09-06)"
issue_author: "Fi3"
created_at: "2024-08-28"
updated_at: "2024-09-06"
labels: [help wanted, question]
participants: [Fi3, jakubtrnka, rrybarczyk]
canonical_url: "https://github.com/stratum-mining/sv2-spec/issues/95"
spec_ref: "03-Protocol-Overview.md#34-protocol-extensions @ cc291562"
content_format: markdown
license: "unknown (upstream sv2-spec)"
fetched: 2026-07-17
---

# sv2-spec #95 — Handle unknown extensions / extension negotiation

GitHub issue **stratum-mining/sv2-spec#95**, opened by **Fi3** on 2024-08-28, labels `help wanted` + `question`, 23 comments, **still open** (last activity 2024-09-06). Participants: **Fi3**, **jakubtrnka**, **rrybarczyk**.

## The problem (issue body)

The spec ([`03-Protocol-Overview.md` §3.4 Protocol Extensions](https://github.com/stratum-mining/sv2-spec/blob/cc291562b729a6be28673940ffede3cd8c64f996/03-Protocol-Overview.md#34-protocol-extensions) @ cc291562) says:

> Extensions MUST require version negotiation with the recipient of the message to check that the extension is supported before sending non-version-negotiation messages for it. This prevents the needlessly wasted bandwidth and potentially serious performance degradation of extension messages when the recipient does not support them.

**But the spec never says HOW to achieve that.** Fi3 relays jakubtrnka's proposal: a valid SV2 implementation receiving a message for an unknown extension answers with a universal error/NACK frame:

```
Frame { extension_type, msg_type: 0xff, msg_length: 0, payload: [] }
```

Fi3 endorses this: "very very simple, and also powerful: 1. super easy to know if peer support ext; 2. if ext is supported you can use an extension-specific mechanism for version negotiation and extension setup."

## The core debate: universal NACK vs positive-ACK-only

**jakubtrnka's position (ACK-only / no NACK):**
- The spec already mandates version negotiation → "assume the peer **doesn't** support my extension X unless it receives a positive acknowledgement. So do we even need a negative acknowledgement?"
- Questions whether the clause should be a **requirement** at all vs a **recommendation**; extensions could be fully generic and left to implementers.
- It's inherently an **asynchronous** system on a single shared persistent connection — you cannot rely on the next incoming message being the response; you always defer handling. So distinguishing "pending" from "no" adds a state for little benefit.
- Design principle: "I always want to reduce the number of possible states to the minimum. Because the implementations do happen to be buggy." Warns of getting stuck in a "pending" state awaiting an ACK that never arrives.
- If the extension handler is simply missing, discarding its messages is *already* correct behavior. A peer that sends random messages after no ACK can be ignored or have its TCP session terminated.

**Fi3's position (universal NACK preferred):**
- A NACK is "arguably faster most of the time": if unsupported, 99% of the time you get the NACK immediately; without a NACK you must always wait a timeout `t` before concluding non-support.
- With NACK: `send activate_extension` → wait with timer → {timer finished → not active; activate_extension_ok → active; universal nack → not active}.
- Without NACK: same, minus the NACK branch → always wait the full timer on non-support.
- If a NACK arrives **after** an ACK for the same ext → invalid → close the connection.

## The per-extension NACK subtlety

Fi3 initially worried a *single shared* universal NACK would make it ambiguous which extension is being NACKed (forcing synchronous activation). jakubtrnka clarifies: the universal NACK is meant **per extension** ("Having one single shared universal NACK would be quite silly"), matched by `(ExtN, NACK)` arms in the receive loop. Open question he raises: how to handle NACK-after-ACK, and what exact handler logic is needed.

## jakubtrnka's example loop (ACK-only handler)

```rust
struct State { ext1: false, ext2: false, ... }
let ext1_handler = Ext1::handler();
let ext2_handler = Ext2::handler();
connection.send(activate_ext1_msg);
connection.send(activate_ext2_msg);
loop {
  incoming = connection.receive();
  match (incoming.extension, incoming.type) {
    (0, msg) => ordinary_mining.handle(msg),            // ordinary mining msg
    (Ext1, ACK) => { state.ext1 = true; ext1_handler.spawn_some_associated_task(); }
    (Ext2, ACK) => { state.ext2 = true; ext2_handler.spawn_some_associated_task(); }
    (Ext1, msg) if state.ext1 => ext1_handler.handle(msg),  // only if active
    (Ext2, msg) if state.ext2 => ext2_handler.handle(msg),
    unexpected  => { warn!("Unexpected message {unexpected}"); }
  }
}
```

## jakubtrnka's tentative recommendation (if forced to decide)

Write into the spec **as a recommendation** (not a requirement):
- Reserve **`message_id == 0`** in each extension for the negotiation message ("NegMsg").
- Reserve **`message_id == 255`** as an ACK.
- NegMsg payload must be sufficiently unique to the extension being used (avoid namespace collisions when two implementers accidentally pick the same extension number).
- **Any response to NegMsg other than ACK counts as NACK.**
- Sessions with no ACK / with a NACK should **ignore all messages** for that extension, not raise errors, and not affect mining.

Design goal illustrated: if two parties independently implement "extension 5" with incompatible meaning, the apps should gracefully stop exchanging messages they don't understand at the very beginning — one sends NegMsg, the other sees garbage payload, doesn't respond, sender proceeds no further, mining unaffected.

## rrybarczyk's contribution (explicit NACK + graceful fallback)

- Argues benefits of explicit NACK outweigh latency, since extension setup is infrequent. Removes the gray area "Am I waiting on an ACK, or will it never respond?"
- Notes a **timeout is needed either way** (messages may be delayed by connection prioritization) — the difference is a clear ACK/NACK vs waiting.
- Three scenarios with an `ActivateExtension` message: (1) **Supported** → ACK → proceed; (2) **Not supported** → NACK → gracefully fall back to default protocol behavior; (3) **No response** → timeout expires → graceful fallback.
- Proposes a **richer NACK** than the empty frame:
  ```
  Frame { extension_type, msg_type: 0xff, msg_length: X, payload: [error_code, reason_string] }
  ```
  carrying e.g. version-mismatch detail so the sender can retry with a different version. Trade-off: more complexity; each extension might need its own NACK structure.
- Raises **extension lifecycle** questions: overriding the current extension with a new one/version; adding another extension mid-session; stopping all extensions.

## Fi3 on extension lifecycle (stop/override)

- Any role (not only upstream) can initiate an extension; which one does is extension-specific. No universal mechanism needed.
  1. Override: upstream sends the extension-specific "stop" message, then initializes the new extension.
  2. Add another: just initialize it — using one extension doesn't prevent others.
  3. Stop all: send each extension's stop message.
- Prefers a **per-extension** stop mechanism because (a) different extensions may want to stop differently, and (b) a stateless extension (e.g. jakubtrnka's "echo" ext that just returns your message) needs no init or stop at all.
- "Whatever we decide we should include it in the spec, as a suggestion for whoever writes a new extension."

## Status / open questions

- **Unresolved / open.** No spec change merged in this thread. Tension: **requirement vs recommendation**, **universal NACK vs ACK-only**, **empty vs rich NACK payload**, and whether reserved message ids (0 = NegMsg, 255 = ACK/NACK) should be standardized.
- Relevant to the SRI **`extensions-sv2`** crate, which implements the extension mechanism this issue is trying to specify.
