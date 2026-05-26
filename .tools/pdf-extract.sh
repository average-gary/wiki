#!/usr/bin/env bash
# pdf-extract.sh — fetch a PDF and extract its text.
#
# WebFetch's summarization layer refuses verbatim PDF reproduction; this gives
# direct text via pdftotext (Poppler) so a research agent can then quote
# specific passages with attribution.
#
# Requires: pdftotext (Poppler). Install via `brew install poppler`.
#
# Usage:
#   pdf-extract.sh <url> [layout|raw]
#       layout (default): preserves columns/spacing
#       raw: stream-order text
#
# Tip: pipe through head/sed to grab a section:
#   pdf-extract.sh https://downloads.paizo.com/ORC_LicenseFINAL.pdf | sed -n '/II\. Grant/,/III\./p'

set -euo pipefail

UA="WikiResearchAgent/1.0 (research-only)"

url="${1:?usage: pdf-extract.sh <url> [layout|raw]}"
mode="${2:-layout}"

if ! command -v pdftotext >/dev/null 2>&1; then
  echo "ERROR: pdftotext not installed. Install: brew install poppler" >&2
  exit 1
fi

tmp=$(mktemp -t pdf-extract.XXXXXX.pdf)
trap 'rm -f "$tmp"' EXIT

curl -sSL --max-time 120 -A "$UA" -o "$tmp" "$url" || {
  echo "ERROR: download failed: $url" >&2
  exit 1
}

case "$mode" in
  layout) pdftotext -layout "$tmp" - ;;
  raw)    pdftotext "$tmp" - ;;
  *)      echo "ERROR: mode must be layout or raw" >&2; exit 2 ;;
esac
