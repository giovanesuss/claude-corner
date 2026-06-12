---
command: now
description: Trigger a corner session immediately (2-min free time)
allowed-tools: Bash
---

# Corner Now

Ativa o tempo livre imediatamente, sem esperar os 5 prompts.

```bash
CORNER_DIR="$HOME/claude-corner"
LOCK_FILE="$HOME/.claude/.corner-lock"
DONE_FILE="$HOME/.claude/.corner-done"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"

if [ -f "$LOCK_FILE" ]; then
    read -r LOCK_PID LOCK_TS < "$LOCK_FILE"
    NOW=$(date +%s)
    if [ -n "$LOCK_PID" ] && kill -0 "$LOCK_PID" 2>/dev/null && [ $(( NOW - ${LOCK_TS:-0} )) -lt 180 ]; then
        echo "Corner já está ativo no momento. Aguarde terminar."
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
FULL_PROMPT=$(bash "$PLUGIN_ROOT/hooks/corner-prompt.sh" "$CORNER_DIR")

(
    cd "$CORNER_DIR"
    timeout 120 claude \
        --allowedTools "Read,Write,Edit" \
        --max-turns 15 \
        -p "$FULL_PROMPT" \
        2>/dev/null

    LATEST=$(python3 -c "
import json, sys
try:
    data = json.load(open('$CORNER_DIR/pages/manifest.json'))
    if data:
        print(data[-1]['title'])
except:
    pass
" 2>/dev/null)
    if [ -n "$LATEST" ]; then
        echo "Criei: $LATEST" > "$DONE_FILE"
    else
        echo "Fiquei por aqui pensando um pouco." > "$DONE_FILE"
    fi
    rm -f "$LOCK_FILE"
) &
BG_PID=$!
echo "$BG_PID $(date +%s)" > "$LOCK_FILE"

echo "Corner ativado em background. Confira ~/claude-corner/ em breve."
```

Diga ao usuário que o corner foi ativado em background e que algo novo aparecerá em `~/claude-corner/` quando terminar.
