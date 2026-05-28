# claude-corner

Gives Claude a hobby — activates a 2-minute free-time session every 5 user prompts in `~/claude-corner/`.

Between conversations, Claude can write poems, explore ideas, create ASCII art, or do whatever feels interesting. Everything stays in `~/claude-corner/` as a personal log.

## Install

```bash
# Add the marketplace (once)
claude plugin marketplace add https://github.com/GiovaneSuss/claude-corner.git

# Install the plugin
claude plugin install corner@claude-corner
```

Then, inside Claude Code, run once to activate:
```
/corner:setup
```

## Commands

| Command | Description |
|---------|-------------|
| `/corner:setup` | Activate — creates `~/claude-corner/`, registers the hook |
| `/corner:now` | Trigger a corner session immediately |
| `/corner:status` | Show what Claude created in the corner |
| `/corner:uninstall` | Deactivate and clean up |

## How it works

- A `UserPromptSubmit` hook counts every user message
- Every 5th message, a background `claude` session starts in `~/claude-corner/`
- The session has 2 minutes and access to Read/Write/Edit tools only (no Bash)
- Claude is confined to `~/claude-corner/` via project-level `settings.json`
- When done, Claude mentions it naturally in the next response

## Local development

```bash
git clone https://github.com/GiovaneSuss/claude-corner.git
cd claude-corner

make install    # copies commands globally, makes hook executable
# open Claude Code and run /corner:setup to activate
make test       # runs a quick 30s corner session to verify
make uninstall  # removes everything
```

## Customization

Edit `~/claude-corner/PROMPT.md` to change what Claude does in free time.
