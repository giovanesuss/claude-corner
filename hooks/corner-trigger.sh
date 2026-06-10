#!/bin/bash
# corner-trigger.sh - fires on Stop; activates corner every N responses

_SELF=$(realpath "$0")
_DIR=$(dirname "$_SELF")
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-${_DIR}/..}"
CORNER_DIR="$HOME/claude-corner"
COUNTER_FILE="$HOME/.claude/.corner-count"
LOCK_FILE="$HOME/.claude/.corner-lock"
INTERVAL_FILE="$HOME/.claude/.corner-interval"

INTERVAL=5
if [ -f "$INTERVAL_FILE" ]; then
    _val=$(cat "$INTERVAL_FILE" | tr -d '[:space:]')
    [[ "$_val" =~ ^[1-9][0-9]*$ ]] && INTERVAL=$_val
fi

COUNT=0
[ -f "$COUNTER_FILE" ] && COUNT=$(cat "$COUNTER_FILE")
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

[ $((COUNT % INTERVAL)) -ne 0 ] && exit 0
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
    DYNAMIC_CONTEXT=$(python3 -c "
import json
from collections import Counter

try:
    data = json.load(open('$MANIFEST'))
except:
    exit(0)

if not data:
    exit(0)

KNOWN_TYPES = ['diary', 'writing', 'simulation', 'animation', 'interactive', 'art', 'code', 'exploration']
window = data[-10:]
counts = Counter(e.get('type', 'other') for e in window)
distribution = ', '.join(
    f'{t} ×{n}' for t, n in sorted(counts.items(), key=lambda x: -x[1]) if t in KNOWN_TYPES
)
absent = [t for t in KNOWN_TYPES if counts.get(t, 0) == 0]
recent_titles = ', '.join(e['title'] for e in reversed(data[-3:]))

lines = ['', '---', f'**Your corner so far:** {len(data)} creation(s).']
lines.append(f'Last {len(window)}: {distribution or \"mixed\"}.')
if absent:
    lines.append(f'Not seen recently: {\", \".join(absent)}.')
lines.append(f'Most recent: {recent_titles}.')
print('\n'.join(lines))
" 2>/dev/null || echo "")
fi

FULL_PROMPT="${PROMPT}${DYNAMIC_CONTEXT}"

nohup bash -c "
  cd \"$CORNER_DIR\"
  timeout 300 claude --allowedTools 'Read,Write,Edit' --max-turns 15 -p \"$FULL_PROMPT\"
  rm -f \"$LOCK_FILE\"
" >/dev/null 2>&1 &
disown $!

MSG='Before finishing this response: briefly let the user know you are stepping away to your corner (~/claude-corner/) for a moment. Keep it natural and short, as if it were the last line of your response.'
printf '{"continue": true, "additionalContext": "%s"}' "$MSG"
exit 0
