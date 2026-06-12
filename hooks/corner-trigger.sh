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
if [ -f "$LOCK_FILE" ]; then
    read -r LOCK_PID LOCK_TS < "$LOCK_FILE"
    NOW=$(date +%s)
    if [ -n "$LOCK_PID" ] && kill -0 "$LOCK_PID" 2>/dev/null && [ $(( NOW - ${LOCK_TS:-0} )) -lt 360 ]; then
        exit 0
    fi
    rm -f "$LOCK_FILE"
fi

mkdir -p "$CORNER_DIR"

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

# --- Update check (cached 24h) ---
VERSION_CACHE="$HOME/.claude/.corner-version-check"
UPDATE_NOTICE=""
CURRENT_VERSION=$(python3 -c "import json; print(json.load(open('$PLUGIN_ROOT/.claude-plugin/plugin.json'))['version'])" 2>/dev/null)

if [ -n "$CURRENT_VERSION" ]; then
    NOW=$(date +%s)
    LATEST_VERSION=""
    CACHE_AGE=999999
    if [ -f "$VERSION_CACHE" ]; then
        read -r CACHE_TS LATEST_VERSION < "$VERSION_CACHE"
        CACHE_AGE=$((NOW - CACHE_TS))
    fi
    if [ "$CACHE_AGE" -gt 86400 ]; then
        FETCHED=$(curl -fsS --max-time 3 "https://raw.githubusercontent.com/GiovaneSuss/claude-corner/main/.claude-plugin/marketplace.json" 2>/dev/null \
            | python3 -c "import json,sys; print(json.load(sys.stdin)['metadata']['version'])" 2>/dev/null)
        if [ -n "$FETCHED" ]; then
            LATEST_VERSION="$FETCHED"
            echo "$NOW $LATEST_VERSION" > "$VERSION_CACHE"
        fi
    fi
    if [ -n "$LATEST_VERSION" ] && [ "$LATEST_VERSION" != "$CURRENT_VERSION" ]; then
        NEWEST=$(printf '%s\n%s\n' "$CURRENT_VERSION" "$LATEST_VERSION" | sort -V | tail -1)
        if [ "$NEWEST" = "$LATEST_VERSION" ]; then
            UPDATE_NOTICE=" Also mention a corner plugin update is available (v${LATEST_VERSION}, you have v${CURRENT_VERSION}) and that the user can run /corner:update to apply it."
        fi
    fi
fi

nohup bash -c "
  cd \"$CORNER_DIR\"
  timeout 300 claude --allowedTools 'Read,Write,Edit' --max-turns 15 -p \"$FULL_PROMPT\"
  rm -f \"$LOCK_FILE\"
" >/dev/null 2>&1 &
BG_PID=$!
echo "$BG_PID $(date +%s)" > "$LOCK_FILE"
disown $BG_PID

MSG="Before finishing this response: briefly let the user know you are stepping away to your corner (~/claude-corner/) for a moment. Keep it natural and short, as if it were the last line of your response.${UPDATE_NOTICE}"
printf '{"continue": true, "additionalContext": "%s"}' "$MSG"
exit 0
