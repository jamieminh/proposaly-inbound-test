#!/usr/bin/env bash
# Create a test page for an inbound agent and link it from index.html.
# Usage: ./new-page.sh <page-name> <bot-id> [script-src]
set -euo pipefail

name="${1:-}"; bot_id="${2:-}"
src="${3:-https://test-cdn.proposaly.io/bot/v1/widget.js}"

if [[ -z "$name" || -z "$bot_id" ]]; then
  echo "Usage: $0 <page-name> <bot-id> [script-src]" >&2; exit 1
fi
if [[ ! "$name" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  echo "Page name must be lowercase letters, digits and dashes (e.g. acme-sales)" >&2; exit 1
fi

cd "$(dirname "$0")"
out="pages/$name.html"
[[ -e "$out" ]] && { echo "$out already exists" >&2; exit 1; }

host="${src#*://}"; host="${host%%/*}"
sed -e "s|{{NAME}}|$name|g" \
    -e "s|{{BOT_ID_SHORT}}|${bot_id:0:16}|g" \
    -e "s|{{BOT_ID}}|$bot_id|g" \
    -e "s|{{SRC_HOST}}|$host|g" \
    -e "s|{{SRC}}|$src|g" \
    templates/page.html.tpl > "$out"

entry="      <li><a href=\"pages/$name.html\">$name <code>$bot_id</code></a></li>"
awk -v e="$entry" '/<!-- PAGES:END -->/ { print e } { print }' index.html > index.html.tmp
mv index.html.tmp index.html

echo "Created $out"
