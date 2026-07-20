---
title: "TRMNL Private Plugins / Recipes — building a Bitcoin screen"
source: https://docs.trmnl.com/go/private-plugins/templates
type: article
tags: [trmnl, private-plugin, recipe, liquid, webhook, polling-url, bitcoin, mempool, template]
date: 2026-07-20
quality: 4
confidence: medium
summary: "TRMNL's screen framework: 800x480 1-bit markup with layout regions (full/half/quadrant), Shopify Liquid templating ({{ var }} + filters like money_with_currency), fed by Polling URL (TRMNL fetches your JSON) or Webhook (you POST merge_variables). How to render a mempool.space Bitcoin screen — on cloud (Private Plugin) or self-hosted (server-side recipe)."
---

# TRMNL Private Plugins / Recipes — Bitcoin screen

## Screen framework
- Panel markup spec: **800×480, 1-bit B/W** (2-bit grayscale capable). Layout regions via `.view` class: `full`, `half_horizontal`, `half_vertical`, `quadrant`.
- DOM: `.screen` > `.view` > `.layout` with `.columns`/`.column`; components `.title_bar`, `.content`, `.label`, `.markdown` (framework CSS/JS from TRMNL CDN).
- Templating = **Shopify Liquid**: `{{ variable }}` + filters (e.g. `money_with_currency` turns `10` → `$10.00` — handy for BTC price/fees).

## Data flow (two strategies)
- **Polling URL**: TRMNL fetches your JSON on the device schedule (e.g. mempool.space endpoints). (Docs thin on polling form fields — confirm in plugin UI.)
- **Webhook**: you `POST` to the plugin webhook with data under a `merge_variables` node; fields then appear as top-level `{{ fee }}`, `{{ block_height }}`, `{{ price }}`. Strategies: `deep_merge`, `stream`. Multi-plugin vars namespaced `<plugin_keyname>_<setting_id>`.

## Building the Bitcoin screen — two routes
- **Self-hosted BYOS (all-free, recommended)**: write it as a server-side screen. In byos_next add a recipe folder that fetches `mempool.space/api/v1/fees/recommended`, `/api/blocks/tip/height`, price → renders a React screen → renderer produces the 800×480 bitmap. In byos_django, fetch in a view and push HTML via `generate_screen`.
- **TRMNL cloud Private Plugin (free account, no device needed to author)**: Polling URL or Webhook → Liquid markup with the layout framework.

The ImageMagick DIY guide (docs.trmnl.com/go/diy/imagemagick-guide) shows how to hand-produce a compliant 1-bit bitmap if not using a browser renderer.
