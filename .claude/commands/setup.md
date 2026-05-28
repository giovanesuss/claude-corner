---
command: setup
description: Activate corner — creates ~/claude-corner/, registers the hook, and sets up path confinement
aliases:
  - install
allowed-tools: Bash, Read, Write
---

# Corner Setup

**Your first output line MUST be:** `🏠 Corner Setup`

Activate the corner plugin for this user. This registers the `UserPromptSubmit` hook so the corner fires automatically every 5 prompts.

## Step 1 — Check current state

```bash
CORNER_DIR="$HOME/claude-corner"
SETTINGS="$HOME/.claude/settings.json"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"

echo "corner_dir=$([ -d "$CORNER_DIR" ] && echo yes || echo no)"
echo "hook_registered=$(python3 -c "import json; s=json.load(open('$SETTINGS')); entries=s.get('hooks',{}).get('UserPromptSubmit',[]); print('yes' if any('corner-trigger' in str(e) for e in entries) else 'no')" 2>/dev/null || echo unknown)"
echo "plugin_root=$PLUGIN_ROOT"
echo "hook_script=$([ -x "$PLUGIN_ROOT/hooks/corner-trigger.sh" ] && echo ok || echo missing)"
```

## Step 2 — Create the corner folder

```bash
mkdir -p "$HOME/claude-corner"
if [ ! -f "$HOME/claude-corner/PROMPT.md" ]; then
    cp "$CLAUDE_PLUGIN_ROOT/templates/PROMPT.md" "$HOME/claude-corner/PROMPT.md"
    echo "✓ PROMPT.md copiado"
else
    echo "✓ PROMPT.md já existe (mantido)"
fi
```

## Step 3 — Create path-confinement settings.json

Creates `~/claude-corner/.claude/settings.json` that pre-approves Read/Write/Edit only inside the corner folder. This replaces `--dangerously-skip-permissions`.

```bash
mkdir -p "$HOME/claude-corner/.claude"
python3 -c "
import json, os
corner = os.path.expanduser('~/claude-corner')
data = {'permissions': {'allow': [
    'Read(' + corner + '/**)',
    'Write(' + corner + '/**)',
    'Edit(' + corner + '/**)',
]}}
open(corner + '/.claude/settings.json', 'w').write(json.dumps(data, indent=2))
print('✓ settings.json de confinamento criado')
"
```

## Step 4 — Register the UserPromptSubmit hook

Adds the corner hook to `~/.claude/settings.json` so it fires on every user prompt.

```bash
HOOK_CMD="${CLAUDE_PLUGIN_ROOT}/hooks/corner-trigger.sh"
SETTINGS="$HOME/.claude/settings.json"

python3 -c "
import json, sys
path = '$SETTINGS'
hook_cmd = '$HOOK_CMD'
s = json.load(open(path))
hook = {'matcher': {}, 'hooks': [{'type': 'command', 'command': hook_cmd, 'timeout': 5}]}
hooks = s.setdefault('hooks', {})
entries = hooks.setdefault('UserPromptSubmit', [])
# remove duplicates first
entries[:] = [e for e in entries if hook_cmd not in str(e)]
entries.append(hook)
open(path, 'w').write(json.dumps(s, indent=2))
print('✓ Hook UserPromptSubmit registrado')
"
```

## Step 5 — Show summary

```
🏠 Corner Setup — Concluído!

  Pasta:      ~/claude-corner/
  Confinado:  só lê/escreve dentro de ~/claude-corner/
  Hook:       ativo — dispara a cada 5 prompts
  Timeout:    2 minutos por sessão
  Prompt:     ~/claude-corner/PROMPT.md (editável)

Comandos disponíveis:
  /corner:now       → ativa o corner agora manualmente
  /corner:status    → vê o que foi criado no corner
  /corner:uninstall → desativa e remove tudo
```

Mencione que o usuário pode editar `~/claude-corner/PROMPT.md` para customizar o que o Claude faz no tempo livre.
