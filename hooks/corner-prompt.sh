#!/bin/bash
# Outputs the full corner prompt (PROMPT.md + dynamic manifest context) to stdout.
# Usage: corner-prompt.sh <CORNER_DIR>

CORNER_DIR="${1:-$HOME/claude-corner}"
MANIFEST="$CORNER_DIR/pages/manifest.json"

PROMPT=$(cat "$CORNER_DIR/PROMPT.md")

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

printf '%s%s' "$PROMPT" "$DYNAMIC_CONTEXT"
