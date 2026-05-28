#!/bin/bash
# corner-trigger.sh — fires on every UserPromptSubmit; activates corner every 5 prompts

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(realpath "$0")")/.."}"
CORNER_DIR="$HOME/claude-corner"
COUNTER_FILE="$HOME/.claude/.corner-count"
LOCK_FILE="$HOME/.claude/.corner-lock"
DONE_FILE="$HOME/.claude/.corner-done"

# If corner just finished, inject a comeback notice into Claude's context
if [ -f "$DONE_FILE" ]; then
    SUMMARY=$(cat "$DONE_FILE" 2>/dev/null)
    rm -f "$DONE_FILE"
    printf '{"additionalContext": "🏠 [corner] Você acabou de voltar do seu cantinho! %s Mencione brevemente ao usuário se fizer sentido no contexto."}' "$SUMMARY"
    exit 0
fi

# Increment counter
COUNT=0
[ -f "$COUNTER_FILE" ] && COUNT=$(cat "$COUNTER_FILE")
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

# Only every 5 prompts
[ $((COUNT % 5)) -ne 0 ] && exit 0

# Skip if already running
[ -f "$LOCK_FILE" ] && exit 0

mkdir -p "$CORNER_DIR"
touch "$LOCK_FILE"

# Copy default PROMPT.md if corner doesn't have one yet
if [ ! -f "$CORNER_DIR/PROMPT.md" ]; then
    cp "$PLUGIN_ROOT/templates/PROMPT.md" "$CORNER_DIR/PROMPT.md"
fi

PROMPT=$(cat "$CORNER_DIR/PROMPT.md")

# Start corner session in background (2-min timeout)
# No --dangerously-skip-permissions: project settings.json pre-approves only corner paths
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

# Inject a heads-up into Claude's context so it can tell the user
printf '{"additionalContext": "🚶 [corner] Você ativou seu tempo livre em ~/claude-corner/ (2 min). Mencione de forma natural ao usuário que foi dar uma escapadinha."}'
exit 0
