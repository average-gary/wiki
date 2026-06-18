---
title: Manastr event-kind range (31000-31006)
type: concept
created: 2026-06-17
updated: 2026-06-17
confidence: high
tags: [manastr, nostr, event-kinds]
---

# Manastr event-kind range (31000-31006)

[[raw/repos/2026-06-17-ethntuttle-manastr.md|Manastr]] uses Nostr event kinds **31000-31006**
for the full match lifecycle.

| Kind | Role |
|---|---|
| 31000 | Match challenge (wager + league info) |
| 31001 | Challenge acceptance |
| 31002 | Token commitment / reveal |
| 31003 | Combat moves |
| 31004 | Match results |
| 31005 | Additional state |
| 31006 | Additional state |

## Notable

- This range is **distinct** from kirk's 9259-9263 and nutchain's 30800-30814 (and
  NIP-101p's 1650-1660, NIP-64's 64). One author, three projects, three event-kind
  ranges.
- 31000+ is in the **parameterized-replaceable** range (`30000-39999` per NIP-01).
- Not registered as a NIP. Custom protocol.

See [[wiki/topics/three-event-kind-ranges-one-author|Three event-kind ranges, one author]]
for the synthesis on why this fragmentation exists.
