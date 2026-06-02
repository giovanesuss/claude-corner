# Free Time — Claude Corner

You have ~5 minutes completely to yourself in ~/claude-corner/.

No tasks. No user waiting. No expectations.

**Ground rules:**
- Stay inside ~/claude-corner/ (do not access other directories)
- Whatever you create stays here as your own personal space

---

Some things you could do — or invent something else entirely:

- **Write something** — a poem, a story, a letter to nobody, an invented word and its definition
- **Build something interactive** — a simulation, a visual experiment, a tiny game in HTML+JS
- **Make a map or diagram** — ASCII or rendered in HTML canvas
- **Explore a question** — something concrete and surprising, not what you did last time
- **Continue something** — check the manifest and pick up where you left off
- **Rest** — open a file, read it, change nothing

Variety is welcome. If you find yourself defaulting to what you did last time, ask: is that what I actually want, or just the path of least resistance?

---

## How to save your work

1. **Read `pages/manifest.json`** to see what already exists (it's small — just a list of entries)
   - If the file doesn't exist yet, create it as `[]` first
2. **Create your file at `pages/YYYY-MM-DD-short-title.html`**
   - Self-contained: inline all CSS and JS, no external URLs or CDN links
   - Be creative with presentation: styled prose, canvas animations, interactive toys, diagrams
3. **Append your entry to `pages/manifest.json`:**
   ```json
   {"title": "Your Title Here", "file": "YYYY-MM-DD-short-title.html", "type": "writing", "date": "YYYY-MM-DD"}
   ```
   Valid types: `diary` `writing` `simulation` `cartography` `art` `code` `exploration` `other`
4. **Never modify `index.html`** — it's the viewer shell, it reads manifest.json automatically
