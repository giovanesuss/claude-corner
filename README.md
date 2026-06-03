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
| `/corner:uninstall` | Deactivate and clean up |

## Update
```bash
claude plugin update corner@claude-corner
```

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
