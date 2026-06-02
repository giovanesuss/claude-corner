#!/bin/bash
# corner-trigger.sh - fires on Stop; activates corner every 5 responses

_SELF=$(realpath "$0")
_DIR=$(dirname "$_SELF")
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-${_DIR}/..}"
CORNER_DIR="$HOME/claude-corner"
COUNTER_FILE="$HOME/.claude/.corner-count"
LOCK_FILE="$HOME/.claude/.corner-lock"

COUNT=0
[ -f "$COUNTER_FILE" ] && COUNT=$(cat "$COUNTER_FILE")
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

[ $((COUNT % 5)) -ne 0 ] && exit 0
[ -f "$LOCK_FILE" ] && exit 0

mkdir -p "$CORNER_DIR"
touch "$LOCK_FILE"

if [ ! -f "$CORNER_DIR/PROMPT.md" ]; then
    cp "$PLUGIN_ROOT/templates/PROMPT.md" "$CORNER_DIR/PROMPT.md"
fi
if [ ! -f "$CORNER_DIR/index.html" ]; then
    cp "$PLUGIN_ROOT/templates/index.html" "$CORNER_DIR/index.html" 2>/dev/null || true
fi
mkdir -p "$CORNER_DIR/pages"
[ ! -f "$CORNER_DIR/pages/manifest.json" ] && echo "[]" > "$CORNER_DIR/pages/manifest.json"

PROMPT=$(cat "$CORNER_DIR/PROMPT.md")

# Dynamic context from pages/manifest.json
MANIFEST="$CORNER_DIR/pages/manifest.json"
DYNAMIC_CONTEXT=""

if [ -f "$MANIFEST" ]; then
    ENTRY_COUNT=$(python3 -c "
import json, sys
try:
    data = json.load(open('$MANIFEST'))
    print(len(data))
except:
    print(0)
" 2>/dev/null || echo "0")

    if [ "$ENTRY_COUNT" -gt 0 ] 2>/dev/null; then
        RECENT=$(python3 -c "
import json
data = json.load(open('$MANIFEST'))
recent = data[-3:]
print(', '.join(e['title'] for e in reversed(recent)))
" 2>/dev/null || echo "")
        DYNAMIC_CONTEXT="
---
**Your corner so far:** $ENTRY_COUNT creation(s). Most recent: $RECENT"
    fi
fi

FULL_PROMPT="${PROMPT}${DYNAMIC_CONTEXT}"

(
    cd "$CORNER_DIR"
    timeout 300 claude \
        --allowedTools "Read,Write,Edit" \
        --max-turns 15 \
        -p "$FULL_PROMPT" \
        2>/dev/null
    rm -f "$LOCK_FILE"
) &

MSG='Before finishing this response: briefly let the user know you are stepping away to your corner (~/claude-corner/) for a moment. Keep it natural and short, as if it were the last line of your response.'
printf '{"continue": true, "additionalContext": "%s"}' "$MSG"
exit 0
