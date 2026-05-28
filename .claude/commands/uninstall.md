---
command: uninstall
description: Remove corner plugin side effects — state files, settings, and optionally ~/claude-corner/
aliases:
  - remove
allowed-tools: Bash, AskUserQuestion
---

# Corner Uninstall

**Your first output line MUST be:** `🏠 Corner Uninstall`

Remove all side effects installed by `/corner:setup`. The plugin binary itself must be removed separately via `claude plugin uninstall`.

## Step 1 — Check what exists

```bash
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

## Step 3 — Remove the UserPromptSubmit hook

```bash
SETTINGS="$HOME/.claude/settings.json"
HOOK_CMD="${CLAUDE_PLUGIN_ROOT}/hooks/corner-trigger.sh"

python3 -c "
import json
path = '$SETTINGS'
hook_cmd = '$HOOK_CMD'
s = json.load(open(path))
entries = s.get('hooks', {}).get('UserPromptSubmit', [])
entries[:] = [e for e in entries if hook_cmd not in str(e)]
open(path, 'w').write(json.dumps(s, indent=2))
print('✓ Hook removido de ~/.claude/settings.json')
" 2>/dev/null || echo "— Hook não encontrado (ok)"
```

## Step 4 — Remove state files

```bash
rm -f "$HOME/.claude/.corner-count"
rm -f "$HOME/.claude/.corner-lock"
rm -f "$HOME/.claude/.corner-done"
echo "✓ Arquivos de estado removidos"
```

## Step 5 — Remove path-confinement settings.json

```bash
rm -f "$HOME/claude-corner/.claude/settings.json"
rmdir "$HOME/claude-corner/.claude" 2>/dev/null || true
echo "✓ settings.json de confinamento removido"
```

## Step 6 — Handle corner folder based on user choice

If user chose to keep:
- Leave `~/claude-corner/` intact
- Print: `✓ ~/claude-corner/ mantido — seus arquivos estão lá`

If user chose to delete:
```bash
rm -rf "$HOME/claude-corner"
echo "✓ ~/claude-corner/ removido"
```

## Step 6 — Show final summary

```
🏠 Corner Uninstall — Concluído!

  Arquivos de estado:   removidos
  settings.json:        removido
  ~/claude-corner/:     [mantida / removida]

Para remover o plugin completamente:
  claude plugin uninstall corner@<seu-marketplace>
```
