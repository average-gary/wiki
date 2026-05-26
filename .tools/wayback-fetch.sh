#!/usr/bin/env bash
# wayback-fetch.sh — pull a page from the Internet Archive Wayback Machine.
#
# Useful when the live URL is 403/404/CDN-blocked. The Wayback API picks the
# closest snapshot to a given timestamp.
#
# Usage:
#   wayback-fetch.sh <url> [timestamp]
#       timestamp format: YYYYMMDD or YYYYMMDDhhmmss (default: latest)
#   wayback-fetch.sh --list <url>
#       list all available snapshots for a URL via CDX API

set -euo pipefail

UA="WikiResearchAgent/1.0 (research-only)"

if [[ "${1:-}" == "--list" ]]; then
  url="${2:?usage: wayback-fetch.sh --list <url>}"
  encoded=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=':/?=&'))" "$url")
  curl -sSL --max-time 30 -A "$UA" \
    "https://web.archive.org/cdx/search/cdx?url=${encoded}&output=json&limit=20"
  exit 0
fi

url="${1:?usage: wayback-fetch.sh <url> [timestamp]}"
ts="${2:-}"

# Resolve closest snapshot
encoded=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=':/?=&'))" "$url")
api_url="https://archive.org/wayback/available?url=${encoded}"
[[ -n "$ts" ]] && api_url="${api_url}&timestamp=${ts}"

snapshot=$(curl -sSL --max-time 20 -A "$UA" "$api_url" | python3 -c '
import json, sys
data = json.load(sys.stdin)
snap = data.get("archived_snapshots", {}).get("closest", {})
if snap.get("available"):
    print(snap["url"])
else:
    sys.exit("no snapshot available")
')

echo "# wayback snapshot: $snapshot" >&2
curl -sSL --max-time 60 -A "$UA" "$snapshot"
