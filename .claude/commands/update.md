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

## Step 3 — Update hook path in settings.json

After the plugin update, the Stop hook path must point to the new version:

```bash
NEW_PLUGIN_ROOT=$(ls -d "$HOME/.claude/plugins/cache/claude-corner/corner/"*/ 2>/dev/null | sort -V | tail -1 | sed 's|/$||')
NEW_HOOK="$NEW_PLUGIN_ROOT/hooks/corner-trigger.sh"
SETTINGS="$HOME/.claude/settings.json"

TMPPY=$(mktemp /tmp/corner-update-XXXXX.py)
cat > "$TMPPY" << 'PYEOF'
import json, sys
settings, new_hook = sys.argv[1], sys.argv[2]
d = json.load(open(settings))
updated = False
for entry in d.get("hooks", {}).get("Stop", []):
    for h in entry.get("hooks", []):
        if "corner-trigger.sh" in h.get("command", "") and h["command"] != new_hook:
            h["command"] = new_hook
            updated = True
json.dump(d, open(settings, "w"), indent=2)
print("hook atualizado para: " + new_hook if updated else "hook já estava atualizado")
PYEOF
python3 "$TMPPY" "$SETTINGS" "$NEW_HOOK"
rm -f "$TMPPY"
```

## Step 4 — Refresh installed viewer assets

Use the NEW plugin root (not CLAUDE_PLUGIN_ROOT, which still points to the old version):

```bash
NEW_PLUGIN_ROOT=$(ls -d "$HOME/.claude/plugins/cache/claude-corner/corner/"*/ 2>/dev/null | sort -V | tail -1 | sed 's|/$||')
CORNER_DIR="$HOME/claude-corner"

if [ -f "$CORNER_DIR/index.html" ]; then
    cp "$CORNER_DIR/index.html" "$CORNER_DIR/index.html.bak"
    echo "index.html anterior salvo em index.html.bak"
fi
cp "$NEW_PLUGIN_ROOT/templates/index.html" "$CORNER_DIR/index.html" 2>/dev/null || true

mkdir -p "$CORNER_DIR/assets"
cp "$NEW_PLUGIN_ROOT/templates/assets/style.css" "$CORNER_DIR/assets/style.css" 2>/dev/null || true
cp "$NEW_PLUGIN_ROOT/templates/assets/app.js" "$CORNER_DIR/assets/app.js" 2>/dev/null || true
echo "index.html e assets/ atualizados"

echo "— PROMPT.md e pages/ não foram tocados"
```

## Step 5 — Refresh the version-check cache

```bash
NEW_PLUGIN_ROOT=$(ls -d "$HOME/.claude/plugins/cache/claude-corner/corner/"*/ 2>/dev/null | sort -V | tail -1 | sed 's|/$||')
NEW_VERSION=$(python3 -c "import json; print(json.load(open('$NEW_PLUGIN_ROOT/.claude-plugin/plugin.json'))['version'])" 2>/dev/null)
echo "$(date +%s) $NEW_VERSION" > "$HOME/.claude/.corner-version-check"
echo "versão nova: $NEW_VERSION"
```

## Step 6 — Show summary

```
🏠 Corner Update — Concluído!

  Versão anterior: $OLD_VERSION
  Versão nova:     $NEW_VERSION
  hook path:       atualizado
  index.html:      atualizado (backup em index.html.bak)
  assets/:         atualizados
  PROMPT.md:       mantido
  pages/:          mantido
```

Se `$OLD_VERSION` e `$NEW_VERSION` forem iguais, mencione que o plugin já estava na última versão.
