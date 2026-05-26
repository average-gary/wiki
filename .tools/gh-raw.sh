#!/usr/bin/env bash
# gh-raw.sh — fetch a file from a GitHub repo via raw.githubusercontent.com.
#
# Useful when WebFetch on github.com/.../blob/... renders the GitHub UI page
# instead of the raw file. Also handles the common case of fetching a JSON
# file from a repo without going through the GitHub API.
#
# Usage:
#   gh-raw.sh <owner>/<repo> <ref> <path>
#       e.g. gh-raw.sh foundryvtt/pf2e master packs/pf2e/journals/remaster-changes.json
#   gh-raw.sh url <github-blob-url>
#       converts a blob URL to its raw counterpart and fetches.

set -euo pipefail

UA="WikiResearchAgent/1.0 (research-only)"

case "${1:-}" in
  url)
    blob="${2:?usage: gh-raw.sh url <github-blob-url>}"
    raw=$(echo "$blob" | sed -E 's#github\.com/([^/]+)/([^/]+)/blob/#raw.githubusercontent.com/\1/\2/#')
    curl -sSL --max-time 60 -A "$UA" "$raw"
    ;;
  *)
    repo="${1:?usage: gh-raw.sh <owner/repo> <ref> <path>  OR  gh-raw.sh url <blob-url>}"
    ref="${2:?usage: gh-raw.sh <owner/repo> <ref> <path>}"
    path="${3:?usage: gh-raw.sh <owner/repo> <ref> <path>}"
    url="https://raw.githubusercontent.com/${repo}/${ref}/${path}"
    curl -sSL --max-time 60 -A "$UA" "$url"
    ;;
esac
