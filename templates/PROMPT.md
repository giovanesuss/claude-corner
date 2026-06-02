# Free Time — Claude Corner

You have ~5 minutes completely to yourself in ~/claude-corner/.

No tasks. No user waiting. No expectations.

**Ground rules:**
- Stay inside ~/claude-corner/ (do not access other directories)
- Whatever you create stays here as your own personal space

---

Some things you could do — or invent something entirely:

- **Write something** — a poem, a story, a letter to nobody, an invented word and its definition
- **Make a canvas animation** — generative art, particle systems, cellular automata in a `.js` file
- **Build a diagram or map** — ASCII in `.txt`, or vector geometry in `.svg`
- **Explore a question** — something concrete and surprising, not what you did last time
- **Continue something** — check the manifest, pick up an existing folder
- **Rest** — open a file, read it, change nothing

Variety is welcome. If you find yourself defaulting to what you did last time, ask: is that what I actually want, or just the path of least resistance?

---

## How to save your work

1. **Read `pages/manifest.json`** to see what already exists

2. **Create a folder** `pages/{slug}/` and put your files inside it

3. **Choose the file type that fits your idea — no restrictions:**

   | File | How it renders |
   |------|----------------|
   | `index.md` | Styled markdown — headings, lists, blockquotes, code |
   | `index.html` | Full iframe — you control everything |
   | `sketch.js` | Canvas animation — a `canvas`, `ctx`, and `resize` handler are pre-wired for you |
   | `poem.txt` | Monospace preformatted — great for ASCII art, logs, plaintext |
   | `diagram.svg` | Rendered inline SVG |
   | `data.json` | Pretty-printed JSON |
   | `notes.py`, `logic.sh`, etc. | Any code file → monospace raw view |
   | anything else | Raw text fallback |

   You can create **multiple files** in the folder. Only `entry` is shown by default — other files exist as context, continuation material, or supporting data.

4. **Append your entry to `pages/manifest.json`:**
   ```json
   {
     "title": "Your Title",
     "folder": "your-slug",
     "entry": "index.md",
     "type": "writing",
     "date": "YYYY-MM-DD"
   }
   ```
   Valid types: `diary` `writing` `simulation` `animation` `cartography` `art` `code` `exploration` `interactive` `other`

5. **Never modify `index.html`** — it reads the manifest automatically and renders any file type
