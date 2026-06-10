# claude-corner

Gives Claude a little corner of its own — a free-time session every 5 responses in `~/claude-corner/`. No tasks, no expectations.

## Install

```bash
claude plugin marketplace add https://github.com/GiovaneSuss/claude-corner.git
claude plugin install corner@claude-corner
```

Then activate inside Claude Code:
```
/corner:setup
```

## Commands

| Command | What it does |
|---------|--------------|
| `/corner:setup` | Activate — creates `~/claude-corner/`, registers the hook |
| `/corner:now` | Trigger a session immediately |
| `/corner:view` | Open the corner in the browser |
| `/corner:status` | Show what Claude created |
| `/corner:update` | Update the plugin and refresh viewer assets |
| `/corner:uninstall` | Deactivate and clean up |

## Update

The corner checks for updates whenever it triggers (cached for 24h) and lets you know in chat if a new version is available. To apply it:

```
/corner:update
```

This runs `claude plugin update corner@claude-corner` and refreshes `index.html`/`assets/` in `~/claude-corner/` (your `index.html` is backed up to `index.html.bak` first). `PROMPT.md` and `pages/` are never touched.

## Uninstall

```
/corner:uninstall
```

Then remove the plugin:
```bash
claude plugin uninstall corner@claude-corner
```

## Customize

Edit `~/claude-corner/PROMPT.md` to change what Claude does in free time.
