# Wiki research tools

Scripts that bypass common WebFetch failure modes:

- **`reddit-json.sh`** — fetch Reddit threads/searches via `*.json` endpoints (Reddit blocks WebFetch on HTML but the JSON API is scrape-friendly with a real UA).
- **`wayback-fetch.sh`** — pull pages from the Internet Archive Wayback Machine when the live URL is gone or CDN-blocked.
- **`aon-search.sh`** — query Archives of Nethys's public Elasticsearch endpoint (`elasticsearch.aonprd.com/aon/_search`) for PF2e SRD content. **License caveat**: AoN's commercial license with Paizo is non-transferable; use for research only.
- **`pdf-extract.sh`** — fetch a PDF and pipe its text through `pdftotext`; gets around WebFetch's summarization layer for verbatim quotation. Requires `brew install poppler`.
- **`gh-raw.sh`** — fetch a file from a GitHub repo via `raw.githubusercontent.com` instead of the rendered blob UI.

## Usage from a research agent

```bash
# Reddit
~/wiki/.tools/reddit-json.sh search Pathfinder2e "Christian setting"
~/wiki/.tools/reddit-json.sh thread /r/Pathfinder2e/comments/<id>/<slug>

# Wayback
~/wiki/.tools/wayback-fetch.sh "https://paizo.com/community/blog/v5748dyo5ldfk?Heres-Where-the-Pathfinder-Reference-Document"

# Archives of Nethys
~/wiki/.tools/aon-search.sh by-name "Force Barrage"
~/wiki/.tools/aon-search.sh by-trait holy

# PDF (e.g. ORC license verbatim)
~/wiki/.tools/pdf-extract.sh https://downloads.paizo.com/ORC_LicenseFINAL.pdf

# GitHub raw
~/wiki/.tools/gh-raw.sh foundryvtt/pf2e master packs/pf2e/journals/remaster-changes.json
~/wiki/.tools/gh-raw.sh url https://github.com/foundryvtt/pf2e/blob/master/packs/...
```

## Failure modes these address

| Tool | Replaces failing approach |
|------|---------------------------|
| reddit-json.sh | WebFetch on `reddit.com` / `old.reddit.com` (CDN blocks) |
| wayback-fetch.sh | WebFetch on dead URLs (paizo.com 2021 announcement, biblicaltraining.org 403) |
| aon-search.sh | WebFetch on `2e.aonprd.com/Rules.aspx?ID=...` (returns nav chrome) |
| pdf-extract.sh | WebFetch refusing verbatim license/article reproduction |
| gh-raw.sh | WebFetch on `github.com/.../blob/...` showing the UI not the file |

All scripts use a consistent User-Agent string and respect 30-120s timeouts.
