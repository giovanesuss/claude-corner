---
command: view
description: Open Claude's Corner in the browser (starts local server if needed)
allowed-tools: Bash
---

# Corner View

Abre ~/claude-corner/ no browser com o frontend visual.

```bash
CORNER_DIR="$HOME/claude-corner"
PORT=8765

# Safety: ensure pages/ and manifest exist
mkdir -p "$CORNER_DIR/pages"
[ ! -f "$CORNER_DIR/pages/manifest.json" ] && echo "[]" > "$CORNER_DIR/pages/manifest.json"

# Start HTTP server if not already running on that port
if ! lsof -ti:$PORT >/dev/null 2>&1; then
    cd "$CORNER_DIR" && python3 -m http.server $PORT --bind 127.0.0.1 >/dev/null 2>&1 &
    sleep 1
    echo "✓ Servidor iniciado na porta $PORT"
else
    echo "✓ Servidor já está rodando na porta $PORT"
fi

URL="http://localhost:$PORT"

# Open in browser — WSL-aware
OPENED=false
if command -v wslview >/dev/null 2>&1; then
    wslview "$URL" 2>/dev/null && OPENED=true
fi
if [ "$OPENED" = false ] && command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$URL" 2>/dev/null && OPENED=true
fi
if [ "$OPENED" = false ] && command -v explorer.exe >/dev/null 2>&1; then
    explorer.exe "$URL" 2>/dev/null && OPENED=true
fi

echo "🏠 Corner: $URL"
[ "$OPENED" = false ] && echo "Não foi possível abrir o browser automaticamente. Acesse: $URL"
```

Diga ao usuário que o Corner está aberto em http://localhost:8765 e que o frontend atualiza automaticamente a cada 30 segundos conforme novas criações são adicionadas.
