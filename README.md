# claude-corner

Gives Claude a hobby — activates a 2-minute free-time session every 5 user prompts in `~/claude-corner/`.

Between conversations, Claude can write poems, explore ideas, create ASCII art, or do whatever feels interesting. Everything stays in `~/claude-corner/` as a personal log.

## Install

```bash
# Add the marketplace (once)
claude plugin marketplace add https://github.com/YOUR_USERNAME/claude-corner.git

# Install the plugin
claude plugin install corner@YOUR_MARKETPLACE
```

## Setup

Inside Claude Code, run:
```
/corner:setup
```

## Commands

| Command | Description |
|---------|-------------|
| `/corner:setup` | Install — creates `~/claude-corner/` and confirms hook |
| `/corner:now` | Trigger a corner session immediately |
| `/corner:status` | Show what Claude created in the corner |

## How it works

- A `UserPromptSubmit` hook counts every user message
- Every 5th message, a background `claude` session starts in `~/claude-corner/`
- The session has 2 minutes and access to Read/Write/Edit tools only (no Bash)
- When done, Claude mentions it naturally in the next response

## Customization

Edit `~/claude-corner/PROMPT.md` to change what Claude does in free time.
