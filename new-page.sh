#!/usr/bin/env bash
# Create a test page for an inbound agent and link it from index.html.
# Usage: ./new-page.sh <page-name> <bot-id> "<agent-name>" [script-src]
set -euo pipefail

name="${1:-}"; bot_id="${2:-}"; agent="${3:-}"
src="${4:-https://test-cdn.proposaly.io/bot/v1/widget.js}"

if [[ -z "$name" || -z "$bot_id" || -z "$agent" ]]; then
  echo "Usage: $0 <page-name> <bot-id> \"<agent-name>\" [script-src]" >&2; exit 1
fi
if [[ ! "$name" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  echo "Page name must be lowercase letters, digits and dashes (e.g. acme-sales)" >&2; exit 1
fi

cd "$(dirname "$0")"
out="pages/$name.html"
[[ -e "$out" ]] && { echo "$out already exists" >&2; exit 1; }

# HTML-escape the agent name, then escape it for the sed replacement.
agent_html=$(printf '%s' "$agent" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g')
agent_sed=$(printf '%s' "$agent_html" | sed -e 's/[\\|&]/\\&/g')

host="${src#*://}"; host="${host%%/*}"
sed -e "s|{{AGENT}}|$agent_sed|g" \
    -e "s|{{BOT_ID_SHORT}}|${bot_id:0:16}|g" \
    -e "s|{{BOT_ID}}|$bot_id|g" \
    -e "s|{{SRC_HOST}}|$host|g" \
    -e "s|{{SRC}}|$src|g" \
    templates/page.html.tpl > "$out"

entry="      <li><a href=\"pages/$name.html\"><span>$agent_html<small>pages/$name.html</small></span><code>$bot_id</code></a></li>"
awk -v e="$entry" '/<!-- PAGES:END -->/ { print e } { print }' index.html > index.html.tmp
mv index.html.tmp index.html

echo "Created $out"
