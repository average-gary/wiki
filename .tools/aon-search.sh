#!/usr/bin/env bash
# aon-search.sh — query the Archives of Nethys public Elasticsearch endpoint.
#
# Discovered via the pf2e-worldbuilding-tool gap-closing round:
# https://elasticsearch.aonprd.com/aon/_search returns full JSON records for any
# PF2e SRD entity (spell, monster, feat, deity, etc.).
#
# **License caveat**: AoN operates under a private commercial license with Paizo.
# That license is NOT transferable to scrapers. Use this for *research* only;
# do not redistribute scraped content without your own ORC + Community Use posture.
# See ~/wiki/topics/pf2e-worldbuilding-tool/wiki/concepts/pf2e-licensing-posture.md.
#
# Usage:
#   aon-search.sh by-name "Force Barrage"
#   aon-search.sh by-trait holy
#   aon-search.sh by-category spell
#   aon-search.sh raw '{"query":{"match":{"name":"Asmodeus"}},"size":3}'
#
# Output: JSON. Pipe through jq.
#
# Tip: extract the relevant fields:
#   aon-search.sh by-name "Force Barrage" | \
#     jq '.hits.hits[]._source | {name, type, level, traits, source, text}'

set -euo pipefail

UA="WikiResearchAgent/1.0 (research-only)"
ES="https://elasticsearch.aonprd.com/aon/_search"

case "${1:-}" in
  by-name)
    name="${2:?usage: aon-search.sh by-name <name>}"
    body=$(python3 -c '
import json, sys
print(json.dumps({
  "query": {"match_phrase": {"name": sys.argv[1]}},
  "size": 5,
}))
' "$name")
    ;;
  by-trait)
    trait="${2:?usage: aon-search.sh by-trait <trait>}"
    body=$(python3 -c '
import json, sys
print(json.dumps({
  "query": {"term": {"trait": sys.argv[1].lower()}},
  "size": 25,
}))
' "$trait")
    ;;
  by-category)
    cat="${2:?usage: aon-search.sh by-category <spell|monster|feat|deity|...>}"
    body=$(python3 -c '
import json, sys
print(json.dumps({
  "query": {"term": {"category": sys.argv[1].lower()}},
  "size": 50,
}))
' "$cat")
    ;;
  raw)
    body="${2:?usage: aon-search.sh raw <json>}"
    ;;
  *)
    cat >&2 <<'EOF'
aon-search.sh — query Archives of Nethys public Elasticsearch

  aon-search.sh by-name <name>
  aon-search.sh by-trait <trait>
  aon-search.sh by-category <spell|monster|feat|deity|...>
  aon-search.sh raw <json>

License: AoN's commercial license with Paizo is non-transferable.
Use for research only.
EOF
    exit 2
    ;;
esac

curl -sSL --max-time 30 -A "$UA" \
  -H 'Content-Type: application/json' \
  -d "$body" \
  "$ES" | python3 -m json.tool 2>/dev/null || {
    echo "ERROR: AoN ES query failed" >&2
    exit 1
  }
