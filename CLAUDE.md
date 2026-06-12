# CLAUDE.md — Development Rules for claude-corner

This file is for development only. It documents the invariants and patterns that must be followed when modifying this plugin.

---

## Core invariant: never modify ~/.claude/ directly

All changes go into this repo. The installed plugin in `~/.claude/plugins/cache/claude-corner/` is updated via `/corner:update`, which replaces the old version directory with the new one. Never hand-edit files in `~/.claude/`.

---

## Sentinel file — preventing counter pollution from corner commands

**File:** `~/.claude/.corner-skip`

Every corner command (`now`, `view`, `setup`, `status`, `update`, `uninstall`) writes the sentinel at the very start of its bash block:

```bash
echo "" > "$HOME/.claude/.corner-skip"
```

The Stop hook (`corner-trigger.sh`) checks for it BEFORE incrementing the counter:

```bash
SKIP_FILE="$HOME/.claude/.corner-skip"
if [ -f "$SKIP_FILE" ]; then
    rm -f "$SKIP_FILE"
    exit 0
fi
```

**Why:** The Stop hook fires after every Claude response, including responses to corner commands. Without the sentinel, running `/corner:now` when the counter is at N-1 would both launch a corner session (from now.md) AND trigger the auto-activation (from the Stop hook), resulting in two concurrent sessions. The sentinel ensures corner command responses never count toward the interval.

**Rule:** The counter is incremented ONLY by `corner-trigger.sh`. No command ever increments it directly.

---

## Prompt: always via corner-prompt.sh, always identical

`hooks/corner-prompt.sh` is the single source of truth for the corner prompt. Both `corner-trigger.sh` and `now.md` must call it the same way:

```bash
FULL_PROMPT=$(bash "$PLUGIN_ROOT/hooks/corner-prompt.sh" "$CORNER_DIR")
```

The prompt always includes the history section — even on the first session when the manifest is empty. `corner-prompt.sh` must never silently exit without outputting the dynamic context block.

---

## Shell quoting: nohup bash -c with FULL_PROMPT

Never interpolate `$FULL_PROMPT` directly into a `bash -c "..."` string — PROMPT.md contains double quotes that will break the string. Use the export pattern:

```bash
export _CORNER_PROMPT="$FULL_PROMPT"
nohup bash -c "
  cd \"$CORNER_DIR\"
  timeout 300 claude --allowedTools 'Read,Write,Edit' --max-turns 15 -p \"\$_CORNER_PROMPT\"
  rm -f \"$LOCK_FILE\"
" >/dev/null 2>&1 &
BG_PID=$!
echo "$BG_PID $(date +%s)" > "$LOCK_FILE"
disown $BG_PID
unset _CORNER_PROMPT
```

`\$_CORNER_PROMPT` prevents expansion during string construction; the subshell reads the exported env var at runtime. Both `corner-trigger.sh` and `now.md` must use this exact pattern (same timeout: 300s, same flags).

---

## Lock file format

`~/.claude/.corner-lock` contains: `PID TIMESTAMP` (space-separated).

Validation checks:
1. Process is alive: `kill -0 $LOCK_PID 2>/dev/null`
2. Age is under 360 seconds: `(NOW - LOCK_TS) < 360`

If either fails, the lock is stale — delete it and proceed.

---

## corner:update — complete plugin replacement

After `claude plugin update`, the old version directory may still exist in `~/.claude/plugins/cache/claude-corner/corner/`. `update.md` must:
1. Record `OLD_PLUGIN_ROOT` before the update
2. Run `claude plugin update`
3. Find `NEW_PLUGIN_ROOT`
4. If they differ: `rm -rf "$OLD_PLUGIN_ROOT"` — ensures no stale files remain

---

## corner:uninstall — total removal

Uninstall removes everything:
- Stop hook entry from `~/.claude/settings.json`
- All state files: `.corner-count`, `.corner-lock`, `.corner-done`, `.corner-interval`, `.corner-version-check`, `.corner-skip`
- Confinement settings: `~/claude-corner/.claude/settings.json`
- Plugin cache: `~/.claude/plugins/cache/claude-corner/` (entire directory)
- Optionally: `~/claude-corner/` and all user creations (ask first)

After uninstall, no corner-related files should remain in `~/.claude/`.

---

## Version bump workflow

1. Edit `.claude-plugin/plugin.json` — bump `version`
2. Edit `.claude-plugin/marketplace.json` — bump `metadata.version`
3. Commit and push to main
4. Run `/corner:update` in Claude Code to deploy the new version locally
