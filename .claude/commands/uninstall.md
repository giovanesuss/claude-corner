---
command: uninstall
description: Remove the corner plugin completely — hook, state files, plugin cache, and optionally ~/claude-corner/
aliases:
  - remove
allowed-tools: Bash, AskUserQuestion
---

# Corner Uninstall

**Your first output line MUST be:** `🏠 Corner Uninstall`

Remove everything installed by `/corner:setup` — hook, state files, plugin cache, and optionally `~/claude-corner/`.

## Step 1 — Check what exists

```bash
echo "" > "$HOME/.claude/.corner-skip"

echo "corner_dir=$([ -d "$HOME/claude-corner" ] && echo yes || echo no)"
echo "settings=$([ -f "$HOME/claude-corner/.claude/settings.json" ] && echo yes || echo no)"
echo "state_files=$(ls "$HOME/.claude/.corner-"* 2>/dev/null | wc -l | tr -d ' ') files"
echo "corner_contents=$(ls "$HOME/claude-corner" 2>/dev/null | grep -v "PROMPT.md" | wc -l | tr -d ' ') user files"
```

## Step 2 — Ask about the corner folder

Use AskUserQuestion to ask:

- **Question**: "O que fazer com ~/claude-corner/ e os arquivos criados pelo Claude lá?"
- **Options**:
  - "Manter a pasta e os arquivos" — only removes settings.json and state, keeps creations
  - "Apagar tudo (pasta + arquivos)" — full wipe

## Step 3 — Remove the Stop hook

Match any corner-trigger.sh entry regardless of version path:

```bash
SETTINGS="$HOME/.claude/settings.json"

python3 -c "
import json
path = '$SETTINGS'
s = json.load(open(path))
entries = s.get('hooks', {}).get('Stop', [])
before = len(entries)
entries[:] = [e for e in entries if 'corner-trigger.sh' not in str(e)]
open(path, 'w').write(json.dumps(s, indent=2))
removed = before - len(entries)
print('Hook removido de ~/.claude/settings.json' if removed else '— Hook não encontrado (ok)')
" 2>/dev/null || echo "— Erro ao ler settings.json"
```

## Step 4 — Remove state files

```bash
rm -f "$HOME/.claude/.corner-count"
rm -f "$HOME/.claude/.corner-lock"
rm -f "$HOME/.claude/.corner-done"
rm -f "$HOME/.claude/.corner-interval"
rm -f "$HOME/.claude/.corner-version-check"
rm -f "$HOME/.claude/.corner-skip"
echo "Arquivos de estado removidos"
```

## Step 5 — Remove path-confinement settings.json

```bash
rm -f "$HOME/claude-corner/.claude/settings.json"
rmdir "$HOME/claude-corner/.claude" 2>/dev/null || true
echo "✓ settings.json de confinamento removido"
```

## Step 6 — Remove plugin cache from ~/.claude/

```bash
rm -rf "$HOME/.claude/plugins/cache/claude-corner"
echo "✓ Cache do plugin removido de ~/.claude/plugins/cache/"
```

## Step 7 — Handle corner folder based on user choice

If user chose to keep:
- Leave `~/claude-corner/` intact
- Print: `✓ ~/claude-corner/ mantido — seus arquivos estão lá`

If user chose to delete:
```bash
rm -rf "$HOME/claude-corner"
echo "✓ ~/claude-corner/ removido"
```

## Step 8 — Show final summary

```
🏠 Corner Uninstall — Concluído!

  Arquivos de estado:   removidos
  Plugin cache:         removido de ~/.claude/plugins/cache/
  settings.json:        removido
  ~/claude-corner/:     [mantida / removida]
```
