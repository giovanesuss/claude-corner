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

Nota: se este comando estiver rodando a partir do próprio plugin corner, o runtime pode recriar este diretório (marcado como `.orphaned_at`/`.in_use`) enquanto a sessão está ativa. Isso é esperado e se autolimpa no próximo restart do Claude Code.

## Step 7 — Remove plugin registry entries

Remove `corner@claude-corner` de `enabledPlugins` e `claude-corner` de `extraKnownMarketplaces` em `~/.claude/settings.json`:

```bash
python3 -c "
import json
path = '$HOME/.claude/settings.json'
s = json.load(open(path))
changed = False
if s.get('enabledPlugins', {}).pop('corner@claude-corner', None) is not None:
    changed = True
if s.get('extraKnownMarketplaces', {}).pop('claude-corner', None) is not None:
    changed = True
if changed:
    open(path, 'w').write(json.dumps(s, indent=2))
    print('✓ Registros de plugin/marketplace removidos de settings.json')
else:
    print('— Nenhum registro em settings.json (ok)')
"
```

Remove a entrada `corner@claude-corner` de `~/.claude/plugins/installed_plugins.json`:

```bash
python3 -c "
import json
path = '$HOME/.claude/plugins/installed_plugins.json'
s = json.load(open(path))
if s.get('plugins', {}).pop('corner@claude-corner', None) is not None:
    open(path, 'w').write(json.dumps(s, indent=2))
    print('✓ Entrada removida de installed_plugins.json')
else:
    print('— Nenhuma entrada em installed_plugins.json (ok)')
"
```

Remove a entrada `claude-corner` de `~/.claude/plugins/known_marketplaces.json`:

```bash
python3 -c "
import json
path = '$HOME/.claude/plugins/known_marketplaces.json'
s = json.load(open(path))
if s.pop('claude-corner', None) is not None:
    open(path, 'w').write(json.dumps(s, indent=2))
    print('✓ Marketplace removido de known_marketplaces.json')
else:
    print('— Nenhum marketplace registrado (ok)')
"
```

## Step 8 — Remove marketplace source clone and leftover hook directory

```bash
rm -rf "$HOME/.claude/plugins/marketplaces/claude-corner"
echo "✓ Clone do marketplace removido"

rm -rf "$HOME/.claude/corner-hooks"
echo "✓ Diretório de hooks legado removido"
```

## Step 9 — Handle corner folder based on user choice

If user chose to keep:
- Leave `~/claude-corner/` intact
- Print: `✓ ~/claude-corner/ mantido — seus arquivos estão lá`

If user chose to delete:
```bash
rm -rf "$HOME/claude-corner"
echo "✓ ~/claude-corner/ removido"
```

## Step 10 — Show final summary

```
🏠 Corner Uninstall — Concluído!

  Arquivos de estado:        removidos
  Plugin cache:              removido de ~/.claude/plugins/cache/
  Registros de plugin:        removidos (settings.json, installed_plugins.json, known_marketplaces.json)
  Marketplace + hooks legado: removidos
  settings.json:              removido
  ~/claude-corner/:           [mantida / removida]
```
