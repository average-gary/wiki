---
title: "Cyberhaven Chrome extension supply-chain attack (December 2024)"
url: "https://www.bleepingcomputer.com/news/security/hacker-injects-malicious-code-into-cyberhaven-chrome-extension/"
retrieved: 2026-06-02
type: article
sources_seen:
  - https://www.cyberhaven.com/blog/cyberhaven-incident-update
  - https://www.bleepingcomputer.com/news/security/hacker-injects-malicious-code-into-cyberhaven-chrome-extension/
  - https://krebsonsecurity.com/2024/12/...
  - https://duo.com/decipher/cyberhaven-extension-attack
ingested: 2026-06-02
confidence: high
---

# Cyberhaven Chrome extension supply-chain attack (December 2024)

On 2024-12-24/25, an attacker phished a Cyberhaven extension publisher's Chrome Web Store account via a fake "Chrome Web Store Developer Support" OAuth consent flow. With developer-account access, the attacker pushed a malicious update (v24.10.4) of the legitimate Cyberhaven extension to all installed users. The malicious payload exfiltrated browser cookies and authentication tokens for high-value SaaS targets (notably Facebook ads accounts, ChatGPT auth, Gemini auth) to attacker infrastructure.

Cyberhaven detected the malicious update within ~24 hours, removed it from the Chrome Web Store, pushed a clean v24.10.5, and published an incident postmortem. The malicious extension affected an estimated ~400,000 users during the active window.

## Why it matters as a plugin-trust pattern

The attack vector was **NOT a code-review failure or a sandbox escape**. The malicious update went through Chrome's extension publishing pipeline and Chrome Web Store review and **passed cleanly because the publisher's own credentials signed it**. The system is not equipped to distinguish "publisher pushing a legitimate update" from "attacker who phished publisher pushing a malicious update."

Concurrent with Cyberhaven, the same attacker campaign hit at least 35 other Chrome extensions through similar OAuth-phishing of publishers. The pattern was systematic: target publisher accounts, not target extension code.

## Lessons for capability-manifest plugin systems

1. **"Declared but not enforced" is the failure window.** Capability manifests at install time prevent overprivileged plugins from launching, but they do not prevent a previously-trusted plugin from being maliciously updated by a compromised publisher key. The window is between install (declared, recorded) and update (signed by same key, enforced or not).

2. **Update-signature enforcement matters more than install-signature enforcement.** If a plugin's install was signed by Ed25519 key K, every subsequent update should require a signature from K (not just any key the marketplace accepts). If the user's app sees a key change, that's a re-grant flow, not a silent update.

3. **Per-plugin proxy/keychain narrows blast radius.** Even if an attacker compromises a plugin's publisher key and pushes a malicious update, capability scoping limits damage: a `network.host:api.openai.com` plugin can't suddenly exfiltrate to `attacker.example.com` because the host capability is single-FQDN.

4. **Publisher-key cold storage is the primary defense.** The attacker had to phish the publisher because the keys were live in the publishing pipeline. Keys held offline (hardware token, air-gapped machine) for signing releases — with hot keys only allowed for development — make the OAuth-phishing vector ineffective.

## Reference for christ-is-lord

ADR-0005 designs the capability manifest schema; this incident is the reference threat scenario for the plugin-runtime sandboxing v2 work tracked as INV-017 in `.wiki/inventory/_index.md`. The post-v1 gap-closing plan (`/Users/garykrause/repos/christ-is-lord/.wiki/output/plan-gap-closing-post-v1-2026-06-02.md` Phase 2.4) pulls publisher-key-pinning + update-signature enforcement earlier than v1.x explicitly because of this pattern.
