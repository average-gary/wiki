---
title: "Yjs — no built-in E2EE; ecosystem add-ons only"
url: https://github.com/yjs/yjs
retrieved: 2026-06-02
type: repo
---

Confirmed from the official Yjs README: Yjs itself ships zero built-in end-to-end encryption, no group key agreement, no authentication primitive. It is deliberately "network agnostic" — providers (y-websocket, y-webrtc, Hocuspocus) handle transport, and any encryption is the application's problem. The README points at three external answers: Serenity Notes (E2EE notes app built atop Yjs), Skiff (private workspace using Yjs), and secsync (the relay-style E2EE-CRDT framework). Implication for christ-is-lord: the current Hocuspocus-based Yjs sync path provides confidentiality only via TLS to the relay; the relay sees plaintext doc state. Any small-group privacy story (e.g., a home Bible-study group's private notes) requires either secsync, a custom symmetric scheme, or a future Keyhive-style substrate.
