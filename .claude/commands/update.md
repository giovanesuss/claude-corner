---
command: update
description: Update the corner plugin and refresh installed assets in ~/claude-corner/
allowed-tools: Bash
---

# Corner Update

**Your first output line MUST be:** `🏠 Corner Update`

Updates the plugin code and refreshes the viewer assets installed in `~/claude-corner/`, without touching the user's creations or `PROMPT.md`.

## Step 1 — Record current version

```bash
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"
CORNER_DIR="$HOME/claude-corner"

OLD_VERSION=$(python3 -c "import json; print(json.load(open('$PLUGIN_ROOT/.claude-plugin/plugin.json'))['version'])" 2>/dev/null)
echo "versão atual: $OLD_VERSION"
```

## Step 2 — Update the plugin

```bash
claude plugin update corner@claude-corner
```

## Step 3 — Refresh installed viewer assets

```bash
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"
CORNER_DIR="$HOME/claude-corner"

# Back up the user's index.html before overwriting (in case it was hand-edited)
if [ -f "$CORNER_DIR/index.html" ]; then
    cp "$CORNER_DIR/index.html" "$CORNER_DIR/index.html.bak"
    echo "✓ index.html anterior salvo em index.html.bak"
fi
cp "$PLUGIN_ROOT/templates/index.html" "$CORNER_DIR/index.html" 2>/dev/null || true

# Assets always get the latest version
mkdir -p "$CORNER_DIR/assets"
cp "$PLUGIN_ROOT/templates/assets/style.css" "$CORNER_DIR/assets/style.css"
cp "$PLUGIN_ROOT/templates/assets/app.js" "$CORNER_DIR/assets/app.js"
echo "✓ index.html e assets/ atualizados"

echo "— PROMPT.md e pages/ não foram tocados (suas criações e customizações ficam intactas)"
```

## Step 4 — Refresh the version-check cache

So the next corner trigger doesn't immediately complain about being outdated again:

```bash
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"
NEW_VERSION=$(python3 -c "import json; print(json.load(open('$PLUGIN_ROOT/.claude-plugin/plugin.json'))['version'])" 2>/dev/null)
echo "$(date +%s) $NEW_VERSION" > "$HOME/.claude/.corner-version-check"
echo "versão nova: $NEW_VERSION"
```

## Step 5 — Show summary

```
🏠 Corner Update — Concluído!

  Versão anterior: $OLD_VERSION
  Versão nova:     $NEW_VERSION
  index.html:      atualizado (backup em index.html.bak)
  assets/:         atualizados
  PROMPT.md:       mantido
  pages/:          mantido
```

Se `$OLD_VERSION` e `$NEW_VERSION` forem iguais, mencione que o plugin já estava na última versão.
