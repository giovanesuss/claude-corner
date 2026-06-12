---
command: status
description: Show what Claude created in ~/claude-corner/
allowed-tools: Bash, Read
---

# Corner Status

Mostra o histórico do tempo livre do Claude.

```bash
CORNER_DIR="$HOME/claude-corner"
LOCK_FILE="$HOME/.claude/.corner-lock"
COUNT_FILE="$HOME/.claude/.corner-count"

echo "=== Corner Status ==="
echo "pasta: $CORNER_DIR"

# Check lock with PID validation
RUNNING="não"
if [ -f "$LOCK_FILE" ]; then
    read -r LOCK_PID LOCK_TS < "$LOCK_FILE"
    NOW=$(date +%s)
    if [ -n "$LOCK_PID" ] && kill -0 "$LOCK_PID" 2>/dev/null && [ $(( NOW - ${LOCK_TS:-0} )) -lt 360 ]; then
        RUNNING="sim (PID $LOCK_PID)"
    fi
fi
echo "running: $RUNNING"
echo "total_prompts: $(cat "$COUNT_FILE" 2>/dev/null || echo 0)"
echo ""
echo "=== Criações ==="
if [ -f "$CORNER_DIR/pages/manifest.json" ]; then
    python3 -c "
import json
data = json.load(open('$CORNER_DIR/pages/manifest.json'))
if not data:
    print('(nenhuma criação ainda)')
else:
    for e in reversed(data):
        print(f\"  {e.get('date','')}  [{e.get('type','?')}]  {e['title']}\")
" 2>/dev/null
else
    echo "(pasta não existe ainda — rode /corner:setup)"
fi
```

Liste os arquivos encontrados e leia o conteúdo do mais recente para mostrar ao usuário o que o Claude criou no último tempo livre.

Se o corner estiver rodando agora, mencione isso também.
