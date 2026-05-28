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
echo "running: $([ -f "$LOCK_FILE" ] && echo sim || echo não)"
echo "total_prompts: $(cat "$COUNT_FILE" 2>/dev/null || echo 0)"
echo ""
echo "=== Arquivos criados ==="
if [ -d "$CORNER_DIR" ]; then
    ls -lt "$CORNER_DIR" | grep -v "^total" | grep -v "PROMPT.md"
else
    echo "(pasta não existe ainda — rode /corner:setup)"
fi
```

Liste os arquivos encontrados e leia o conteúdo do mais recente para mostrar ao usuário o que o Claude criou no último tempo livre.

Se o corner estiver rodando agora, mencione isso também.
