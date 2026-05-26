#!/usr/bin/env bash
# reddit-json.sh — fetch a Reddit thread or search as JSON without browser CDN gates.
#
# Reddit blocks WebFetch for HTML pages but their public read-only JSON endpoints
# (https://www.reddit.com/<path>.json) are scrape-friendly with a real UA.
#
# Usage:
#   reddit-json.sh thread <permalink>
#       e.g. reddit-json.sh thread /r/Pathfinder2e/comments/abc123/some_slug
#   reddit-json.sh search <subreddit> <query>
#       e.g. reddit-json.sh search Pathfinder2e "worldbuilding tool"
#   reddit-json.sh subreddit-top <subreddit> [t=year|month|week] [limit=25]
#
# Output: pretty-printed JSON to stdout. Pipe through jq to extract.
#
# Tip for ingestion:
#   reddit-json.sh thread /r/Pathfinder2e/comments/<id>/<slug> | \
#     jq -r '.[0].data.children[0].data | "# \(.title)\n\n\(.selftext)\n\n---\n"' \
#     and then for comments:
#   reddit-json.sh thread /r/Pathfinder2e/comments/<id>/<slug> | \
#     jq -r '.[1].data.children[].data | "[\(.score)] u/\(.author): \(.body)\n"' | head -50

set -euo pipefail

UA="WikiResearchAgent/1.0 (by /u/anonymous; research-only; contact via wiki maintainer)"
BASE="https://www.reddit.com"

case "${1:-}" in
  thread)
    permalink="${2:?usage: reddit-json.sh thread <permalink>}"
    permalink="${permalink#/}"
    permalink="${permalink%/}"
    url="${BASE}/${permalink}.json?raw_json=1&limit=100"
    ;;
  search)
    sub="${2:?usage: reddit-json.sh search <subreddit> <query>}"
    query="${3:?usage: reddit-json.sh search <subreddit> <query>}"
    encoded=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$query")
    url="${BASE}/r/${sub}/search.json?q=${encoded}&restrict_sr=on&sort=relevance&t=all&raw_json=1"
    ;;
  subreddit-top)
    sub="${2:?usage: reddit-json.sh subreddit-top <subreddit> [t] [limit]}"
    t="${3:-year}"
    limit="${4:-25}"
    url="${BASE}/r/${sub}/top.json?t=${t}&limit=${limit}&raw_json=1"
    ;;
  *)
    cat >&2 <<'EOF'
reddit-json.sh — fetch Reddit content as JSON

  reddit-json.sh thread <permalink>
  reddit-json.sh search <subreddit> <query>
  reddit-json.sh subreddit-top <subreddit> [t] [limit]
EOF
    exit 2
    ;;
esac

curl -sSL --max-time 30 -A "$UA" "$url" | python3 -m json.tool 2>/dev/null || {
  echo "ERROR: fetch failed for $url" >&2
  exit 1
}
