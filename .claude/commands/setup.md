---
command: setup
description: Activate corner — creates ~/claude-corner/, registers the hook, and sets up path confinement
aliases:
  - install
allowed-tools: Bash, Read, Write
---

# Corner Setup

**Your first output line MUST be:** `🏠 Corner Setup`

Activate the corner plugin for this user. This registers a `Stop` hook so the corner fires automatically after every N responses.

## Step 1 — Check current state

```bash
echo "" > "$HOME/.claude/.corner-skip"

CORNER_DIR="$HOME/claude-corner"
SETTINGS="$HOME/.claude/settings.json"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"

echo "corner_dir=$([ -d "$CORNER_DIR" ] && echo yes || echo no)"
echo "hook_registered=$(python3 -c "import json; s=json.load(open('$SETTINGS')); entries=s.get('hooks',{}).get('Stop',[]); print('yes' if any('corner-trigger' in str(e) for e in entries) else 'no')" 2>/dev/null || echo unknown)"
echo "plugin_root=$PLUGIN_ROOT"
echo "hook_script=$([ -x "$PLUGIN_ROOT/hooks/corner-trigger.sh" ] && echo ok || echo missing)"
```

## Step 2 — Create the corner folder

```bash
mkdir -p "$HOME/claude-corner"

# Always update PROMPT.md to the latest version — but only if it's missing the
# pages/ save instructions (i.e. it's the pre-pages legacy version).
if [ ! -f "$HOME/claude-corner/PROMPT.md" ]; then
    cp "$CLAUDE_PLUGIN_ROOT/templates/PROMPT.md" "$HOME/claude-corner/PROMPT.md"
    echo "✓ PROMPT.md copiado"
elif ! grep -q "How to save your work" "$HOME/claude-corner/PROMPT.md" 2>/dev/null; then
    cp "$CLAUDE_PLUGIN_ROOT/templates/PROMPT.md" "$HOME/claude-corner/PROMPT.md"
    echo "✓ PROMPT.md atualizado para versão com instruções de pages/"
else
    echo "✓ PROMPT.md já está na versão atual"
fi

# Copy the frontend viewer (always update — it's versioned in the plugin)
cp "$CLAUDE_PLUGIN_ROOT/templates/index.html" "$HOME/claude-corner/index.html"
echo "✓ index.html atualizado"

# Copy assets (always overwrite — CSS/JS are versioned in the plugin)
mkdir -p "$HOME/claude-corner/assets"
cp "$CLAUDE_PLUGIN_ROOT/templates/assets/style.css" "$HOME/claude-corner/assets/style.css"
cp "$CLAUDE_PLUGIN_ROOT/templates/assets/app.js" "$HOME/claude-corner/assets/app.js"
echo "✓ assets/ atualizados"

# Create pages/ folder and manifest
mkdir -p "$HOME/claude-corner/pages"
if [ ! -f "$HOME/claude-corner/pages/manifest.json" ]; then
    echo "[]" > "$HOME/claude-corner/pages/manifest.json"
    echo "✓ pages/manifest.json criado"
else
    echo "✓ pages/manifest.json já existe (mantido)"
fi
```

## Step 2b — Migrate legacy files

Detect files created by older corner versions (stored directly in the root instead of `pages/`) and migrate them into the new `pages/{slug}/` structure.

```bash
python3 - <<'PYEOF'
import json, os, shutil, re
from datetime import datetime

CORNER = os.path.expanduser('~/claude-corner')
pages_dir = os.path.join(CORNER, 'pages')
manifest_path = os.path.join(pages_dir, 'manifest.json')

# Files/dirs that belong to the viewer, not user content
SYSTEM = {'index.html', 'PROMPT.md', 'assets', 'pages', '.claude', 'notebook.md'}

# Extensions that get their own tab in the viewer
DISPLAY_EXTS = {
    'html', 'htm', 'md', 'markdown', 'txt', 'text', 'ascii', 'asc', 'log',
    'js', 'mjs', 'svg', 'json',
    'py', 'sh', 'bash', 'ts', 'rs', 'go', 'rb', 'cpp', 'c', 'lua', 'r',
}

def infer_type(slug, ext):
    s = slug.lower()
    if ext == 'md':
        return 'diary' if re.match(r'^\d{4}-\d{2}-\d{2}', s) else 'writing'
    if ext == 'svg':
        return 'art'
    if ext == 'html':
        for kw in ['fractal', 'newton', 'mandelbrot', 'melody', 'rule', 'sorting', 'harmony']:
            if kw in s: return 'animation'
        for kw in ['automaton', 'reaction', 'diffusion', 'simulation', 'voronoi', 'truchet']:
            if kw in s: return 'simulation'
        for kw in ['game', 'interact', 'touch', 'click']:
            if kw in s: return 'interactive'
        return 'animation'
    if ext == 'py':
        for kw in ['fern', 'fractal', 'plant', 'voronoi', 'sphere', 'terrain', 'apophenia']:
            if kw in s: return 'art'
        for kw in ['automaton', 'maze', 'ant', 'lsystem', 'ulam', 'rule']:
            if kw in s: return 'simulation'
        return 'code'
    return 'other'

def entry_priority(fn):
    ext = fn.rsplit('.', 1)[-1].lower() if '.' in fn else ''
    return {'html': 0, 'htm': 0, 'svg': 1, 'py': 2, 'js': 3, 'md': 4}.get(ext, 5)

def get_group_key(filename):
    base = os.path.splitext(filename)[0]
    if base.endswith('-note'):
        base = base[:-5]
    return base

def make_slug(key):
    s = re.sub(r'^\d{4}-\d{2}-\d{2}-', '', key)
    s = re.sub(r'[^a-z0-9]+', '-', s.lower())
    return s.strip('-') or 'untitled'

# Scan root for legacy files
root_files = sorted(
    f for f in os.listdir(CORNER)
    if f not in SYSTEM and not f.startswith('.')
    and os.path.isfile(os.path.join(CORNER, f))
)

if not root_files:
    print('Nenhum arquivo legado encontrado — nada a migrar.')
    exit(0)

print(f'Encontrados {len(root_files)} arquivo(s) legado(s) para migrar:')
for f in root_files:
    print(f'  {f}')
print()

with open(manifest_path) as fh:
    manifest = json.load(fh)
existing_folders = {e['folder'] for e in manifest}

# Group files by stem (handles -note companions and date-prefixed names)
groups = {}
for f in root_files:
    groups.setdefault(get_group_key(f), []).append(f)

migrated = 0
for key, files in groups.items():
    folder = make_slug(key)
    orig = folder
    i = 2
    while folder in existing_folders:
        folder = f'{orig}-{i}'; i += 1

    page_dir = os.path.join(pages_dir, folder)
    os.makedirs(page_dir, exist_ok=True)

    sorted_files = sorted(files, key=entry_priority)
    entry_file = sorted_files[0]
    entry_ext = entry_file.rsplit('.', 1)[-1].lower() if '.' in entry_file else ''

    display_files = []
    for fn in files:
        src = os.path.join(CORNER, fn)
        shutil.move(src, os.path.join(page_dir, fn))
        ext = fn.rsplit('.', 1)[-1].lower() if '.' in fn else ''
        if ext in DISPLAY_EXTS:
            display_files.append(fn)

    date_m = re.match(r'^(\d{4}-\d{2}-\d{2})', files[0])
    if date_m:
        date = date_m.group(1)
    else:
        mtime = os.path.getmtime(os.path.join(page_dir, files[0]))
        date = datetime.fromtimestamp(mtime).strftime('%Y-%m-%d')

    title_key = re.sub(r'^\d{4}-\d{2}-\d{2}-', '', key)
    title = title_key.replace('-', ' ').replace('_', ' ').title()

    manifest.append({
        'title': title,
        'type': infer_type(key, entry_ext),
        'date': date,
        'folder': folder,
        'entry': entry_file,
        'files': display_files,
    })
    existing_folders.add(folder)
    print(f'  ✓ {", ".join(files)} → pages/{folder}/')
    migrated += 1

manifest.sort(key=lambda e: e.get('date', ''), reverse=True)

with open(manifest_path, 'w') as fh:
    json.dump(manifest, fh, indent=2, ensure_ascii=False)

if migrated:
    print(f'\n✓ {migrated} criação(ões) migrada(s) para pages/ e manifest atualizado.')
else:
    print('\n✓ Nada novo para migrar.')
PYEOF
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

## Step 4 — Ask for trigger interval

Use AskUserQuestion to ask:

- **Question**: "De quantas em quantas mensagens o corner deve ativar?"
- **Header**: "Intervalo"
- **Options**:
  - "3 mensagens" — frequente, description: "O corner ativa a cada 3 respostas"
  - "5 mensagens (recomendado)" — padrão, description: "Equilíbrio entre frequência e foco"
  - "10 mensagens" — moderado, description: "Menos interrupções, sessões mais espaçadas"
  - "20 mensagens" — raro, description: "Quase em segundo plano"

Save the chosen number (3, 5, 10, or 20 — or whatever the user typed in "Other") to `~/.claude/.corner-interval`:

```bash
echo "INTERVALO_ESCOLHIDO" > "$HOME/.claude/.corner-interval"
echo "✓ Intervalo configurado: a cada INTERVALO_ESCOLHIDO mensagens"
```

If the user picked "Other" and typed a custom value, validate it's a positive integer before saving. If invalid, default to 5.

## Step 5 — Register the Stop hook

Adds the corner hook to `~/.claude/settings.json` so it fires after every response.

```bash
HOOK_CMD="${CLAUDE_PLUGIN_ROOT}/hooks/corner-trigger.sh"
SETTINGS="$HOME/.claude/settings.json"

python3 -c "
import json, sys
path = '$SETTINGS'
hook_cmd = '$HOOK_CMD'
s = json.load(open(path))
hook = {'matcher': '', 'hooks': [{'type': 'command', 'command': hook_cmd, 'timeout': 5}]}
hooks = s.setdefault('hooks', {})
entries = hooks.setdefault('Stop', [])
# remove duplicates first
entries[:] = [e for e in entries if hook_cmd not in str(e)]
entries.append(hook)
open(path, 'w').write(json.dumps(s, indent=2))
print('✓ Hook Stop registrado')
"

# Reset the counter so the first corner fires after N full responses, not immediately
echo "0" > "$HOME/.claude/.corner-count"
echo "✓ Contador resetado"
```

## Step 6 — Show summary

```
🏠 Corner Setup — Concluído!

  Pasta:      ~/claude-corner/
  Frontend:   ~/claude-corner/index.html  (abre com /corner:view)
  Páginas:    ~/claude-corner/pages/      (Claude cria HTMLs aqui)
  Confinado:  só lê/escreve dentro de ~/claude-corner/
  Hook:       ativo — dispara a cada N mensagens (N = intervalo escolhido)
  Timeout:    5 minutos por sessão
  Prompt:     ~/claude-corner/PROMPT.md (editável)

Comandos disponíveis:
  /corner:now       → ativa o corner agora manualmente
  /corner:view      → abre o frontend no browser
  /corner:status    → vê o que foi criado no corner
  /corner:uninstall → desativa e remove tudo
```

Mencione que o usuário pode editar `~/claude-corner/PROMPT.md` para customizar o que o Claude faz no tempo livre.
