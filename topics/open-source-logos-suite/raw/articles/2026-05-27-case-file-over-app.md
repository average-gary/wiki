---
title: "File Over App"
source_url: "https://stephango.com/file-over-app"
type: article
path: case
date_ingested: 2026-05-27
date_published: 2023-04-21
tags: [case-study, local-first, obsidian, files-on-disk, philosophy]
quality: 4
confidence: high
summary: "Obsidian CEO Steph Ango's manifesto for plain-file-on-disk architecture. Articulates the design philosophy behind the most commercially successful local-first knowledge app."
---

# File Over App

## Key findings

The thesis: digital longevity depends on the user controlling files in open formats, not on the app surviving. Apps become obsolete; files endure if they are in standard formats the user owns directly on disk.

Design implications for any knowledge app:
- The app is replaceable; the file format is sacred.
- "To read something written on paper all you need is eyeballs" — the modern equivalent should be plain text + standard image formats on a regular filesystem.
- Open formats are a feature, not a constraint. Users will pay for an app that promises NOT to lock them in.

## Notable quotes / specifics

- "If you want to create digital artifacts that last, they must be files you can control, in formats that are easy to retrieve and read."
- "If you want your writing to still be readable on a computer from the 2060s or 2160s, it's important that your notes can be read on a computer from the 1960s."
- Obsidian's commercial success (proprietary client, optional paid sync, but plain markdown files on disk) is the proof point — users pay for tooling around files they fully own.

## Source notes

This is the single most important business-model insight in the local-first space. Obsidian beat Roam, Logseq, Notion-on-features-but-not-on-trust because it never held data hostage. The file-on-disk architecture is what made Obsidian's "we have no investors and don't need to" statement credible to power users. Anyone shipping a knowledge app should treat plain files on disk as the ground truth and any database/CRDT/blob-store as a secondary index.
