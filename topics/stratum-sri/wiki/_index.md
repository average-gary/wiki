# Wiki Articles Index

Last updated: 2026-05-28

## Categories

- [Concepts](concepts/_index.md) — 8 articles
- [Topics](topics/_index.md) — 4 articles
- [References](references/_index.md) — 3 articles
- [Theses](theses/_index.md) — 0 articles

## Stack at a glance

```
   typed message ──► handlers_sv2 ──► role-specific code
        ▲
        │
   parsers_sv2 ──► framing_sv2 ──► codec_sv2 ──► (noise_sv2) ──► I/O
                                       ▲
                                       │
                                  buffer_sv2 (BufferPool)

   binary_sv2 (types) + derive_codec_sv2 (procmacros) ──► message structs

   channels_sv2 (mining-side state) ──► share accounting, custom-work mode

   subprotocols/ (mining, job-declaration, template-distribution, common-messages)
   extensions_sv2 (Extensions Negotiation 0x0001, Worker Hashrate 0x0002, TLV)
```

`stratum-core` is the umbrella crate that re-exports all of the above.

## Recent Changes

- 2026-05-28: Initial compile from the SRI git collection at HEAD `65c9688c` — 15 articles (8 concepts + 4 topics + 3 references) covering the SV2 wire stack, channel/share state, message handlers, subprotocols, the umbrella crate, the crate version map, the release process, and a pinned snapshot of recent PR themes.
