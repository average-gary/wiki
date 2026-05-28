---
title: File Over App
type: concept
created: 2026-05-27
updated: 2026-05-27
verified: 2026-05-27
volatility: cold
status: active
confidence: high
tags: [local-first, files, obsidian, design-principle]
sources:
  - "[[raw/articles/2026-05-27-case-file-over-app]]"
  - "[[raw/articles/2026-05-27-case-inkandswitch-local-first]]"
---

# File Over App

The design principle that consistently produces winning knowledge apps: **plain files on disk in open formats are the ground truth; the app is a view on top.** Coined explicitly by Obsidian.

## The principle

> Your data should outlive the app you use to read it.

Obsidian writes plain Markdown files to a local folder. The app is a viewer/editor. The user can:
- Open a file in any text editor
- `grep` across the vault
- Sync with git, rsync, Dropbox, Syncthing — any tool they already trust
- Walk away from Obsidian entirely without losing data

This is the opposite of Roam Research, Notion, early Anytype: those store data in proprietary formats inside a cloud database, and even when "exportable," the export loses fidelity.

## The empirical record

| App | Model | Outcome |
|-----|-------|---------|
| **Obsidian** | Files-on-disk (markdown), proprietary client | Most successful note app; no investors; commercially profitable |
| **Logseq** | Files-on-disk (md/org), open-source | Open formats won users; sync monetization struggling |
| **Roam Research** | Cloud blob, no files | Lost market to Obsidian/Logseq specifically over data lock-in |
| **Notion** | Cloud blob | Successful but enterprise-bound; consumer churn high |
| **Anytype** | CRDT blob store, encrypted | Adoption modest despite open-source + decentralized framing |
| **Standard Notes** | Cloud blob (E2E encrypted) | Acquired by Proton 2024; couldn't sustain independent commercial path |

The pattern: **plain files + optional sync** wins; **CRDT/blob-store + sync as the only path** struggles.

## Why this works

### Trust

Users have been burned. Cloud-only apps disappear; data goes with them. A folder of plain files is a hedge against the app dying.

### Power-user gravity

Power users (the segment most likely to evangelize) want:
- `grep` access
- Git history
- Their own backup tools
- Their own sync (Dropbox, Syncthing, NAS)

They will not adopt apps that take this away. They will leave the app eventually if they can.

### Plugin economy

When data is in plain files, *any* tool can manipulate it. A community plugin can ingest, transform, export without negotiating an API. This compounds — Obsidian's plugin economy is a moat *because* of its open data.

## Application to a Logos OSS suite

Default install lays down a folder structure like:

```
~/.bible-suite/
├── library/                  # content-addressed, fetched on demand
│   ├── translations/
│   │   ├── web/              # USFM
│   │   ├── kjv/
│   │   └── wlc/              # OSIS XML
│   ├── lexicons/             # JSON
│   │   ├── strongs.json
│   │   ├── bdb.json
│   │   └── tflsj.json
│   ├── morphology/
│   │   ├── tahot.tsv
│   │   └── tagnt.tsv
│   ├── syntax/
│   │   └── macula-greek/     # XML syntax trees
│   └── commentaries/         # markdown
│       ├── matthew-henry/
│       └── jfb/
├── notes/                    # user content — markdown
│   ├── 2026-01-15-romans-8.md
│   └── sermons/
│       └── 2026-easter.md
├── highlights.jsonl          # append-log of highlights
├── reading-plans.json
└── index.sqlite              # rebuildable from sources
```

**Critical rule**: every byte of user data is in `notes/`, `highlights.jsonl`, `reading-plans.json` as plain text. The `index.sqlite` and CRDT state are caches — derivable, deletable, rebuildable.

If the user uninstalls the app:
- `library/` is content-addressed packages they can read with any USFM viewer
- `notes/` is markdown they can open in any editor
- `highlights.jsonl` is jsonl they can grep
- They lose the integrated UX, not their work

## The CRDT / sync layer is secondary

CRDT state (Yjs document, Automerge log) is a **secondary store** — used to replicate edits across devices and resolve conflicts. It is not the source of truth. The source of truth is the markdown file written to disk after CRDT merge.

This means:
- A user can sync without CRDT (git, Dropbox) — works fine
- A user can use CRDT without files — would break the principle; don't allow it
- Conflicts resolve into the file; users can see the resolved file in any editor

## Why decentralization frames the wrong question

The local-first essay (Ink & Switch) and the case-study evidence converge: users don't want decentralization, they want **their data not held hostage**. File-over-app delivers that with zero P2P infrastructure.

If you have files-on-disk + optional sync, you don't need IPFS, libp2p, ATProto, or Hypercore for the user-data layer. Add those for *library distribution* (where decentralization actually solves a problem) — not for personal notes.

See [[credible-exit|Credible exit principle]].

## See Also

- [[credible-exit|Credible exit principle]]
- [[client-architecture|Client architecture]]
- [[decentralized-sync|Decentralized sync]]
- [[../topics/engineering-playbook|Engineering playbook]]
