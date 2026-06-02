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

PROMPT=$(cat "$CORNER_DIR/PROMPT.md")

# Inject dynamic context: what's already in the corner
CORNER_FILES=$(ls "$CORNER_DIR" 2>/dev/null | grep -v "^PROMPT.md$" | grep -v "^\.claude$" | tr '\n' ' ' | sed 's/ $//')

DYNAMIC_CONTEXT=""
if [ -n "$CORNER_FILES" ]; then
    DYNAMIC_CONTEXT="
---
**What's already in your corner:** $CORNER_FILES"
fi

# If notebook.md exists and has many entries, nudge toward variety
if [ -f "$CORNER_DIR/notebook.md" ]; then
    ENTRY_COUNT=$(grep -c "^## " "$CORNER_DIR/notebook.md" 2>/dev/null || echo 0)
    if [ "$ENTRY_COUNT" -ge 3 ]; then
        DYNAMIC_CONTEXT="$DYNAMIC_CONTEXT
You've written $ENTRY_COUNT reflective entries in notebook.md. That space is always there — but you might also try creating something in a completely different format or medium today."
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
