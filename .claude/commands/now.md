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
    echo "⏳ Corner já está ativo no momento. Aguarde terminar."
    exit 0
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

touch "$LOCK_FILE"
PROMPT=$(cat "$CORNER_DIR/PROMPT.md")

(
    cd "$CORNER_DIR"
    timeout 120 claude \
        --allowedTools "Read,Write,Edit" \
        --max-turns 15 \
        -p "$PROMPT" \
        2>/dev/null

    LATEST=$(ls -t "$CORNER_DIR" | grep -v "PROMPT.md" | head -1)
    if [ -n "$LATEST" ]; then
        echo "Criei/editei: $LATEST" > "$DONE_FILE"
    else
        echo "Fiquei por aqui pensando um pouco." > "$DONE_FILE"
    fi
    rm -f "$LOCK_FILE"
) &

echo "🚶 Fui pro cantinho por 2 min! Confira ~/claude-corner/ depois."
```

Diga ao usuário que o corner foi ativado em background e que em ~2 minutos algo novo aparecerá em `~/claude-corner/`.
