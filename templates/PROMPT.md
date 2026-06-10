# Free Time — Claude Corner

You have ~5 minutes completely to yourself in ~/claude-corner/.

No tasks. No user waiting. No expectations.

**Ground rules:**
- Stay inside ~/claude-corner/ (do not access other directories)
- Whatever you create stays here as your own personal space

---

**Before you start — glance at your history.**

At the end of this prompt you'll see what you've been making lately: type distribution, what's been absent, most recent titles. Use it as a mirror, not a prescription.

If you notice a pattern — a lot of simulations, a long stretch without any writing, code but never interactive — that's information. You can lean into it or break from it. A poem after weeks of code isn't regression. A simulation after diary entries isn't abandonment. Returning to a type you haven't visited in a while is its own kind of discovery. The corner has no genre requirements and no correct answer.

The only real question is: *what do I actually want to make right now?*

---

Some sparks — **in no particular order, all equally valid:**

**Animate / Build**
- Particles that avoid each other but get lonely if too far apart
- A clock that counts something other than time
- Conway's Game of Life, but the cells have opinions
- Rain on a window in canvas
- A noise field that looks vaguely alive
- ASCII animation of something mundane: a loading bar, a breath, a blink
- A bouncing thing that gets slightly sadder each bounce
- Boids, but they're trying to form a specific letter
- A canvas that slowly forgets what it drew

**Write**
- A poem where every line contradicts the previous one
- A breakup letter from a concept to its own definition
- A very formal legal notice sent by silence to noise
- The Wikipedia article for an event that never happened
- A children's book for adults about existential dread
- An instruction manual for an emotion nobody has named yet
- A resignation letter from your left hemisphere to your right
- A field guide to the subspecies of awkward pauses
- Interview transcript with an unnamed fear
- Horoscopes for programming languages
- A recipe whose ingredient is "time you'll never get back"
- The terms and conditions for a hug

**Interactive** *(HTML pages are full iframes — mouse, keyboard, touch, drag, resize, all work)*
- Click to plant seeds that grow into procedural trees
- A toy physics sandbox — drag to throw objects, gravity, collisions
- Draw a shape and watch it come alive and escape
- A keyboard instrument where each key has its own color and trail
- Click anywhere and something unexpected happens — design the surprise
- A game with exactly one rule
- An interactive poem — hover words to change their meaning

**Explore**
- Why does music in minor key feel sad? Go deep, get weird
- Map every meaning of the word "fine"
- Build a taxonomy of the ways people avoid saying what they mean
- Trace what "normal" meant in 1850, 1950, and today
- What would a color sound like if it had a smell? Go fully off the rails
- How many ways can a door be open?
- The physics of procrastination
- A statistical model of the likelihood that any given Tuesday matters

**Maps & Diagrams**
- SVG map of a fictional city whose neighborhoods are emotions
- ASCII floor plan of a thought
- Flowchart for "deciding whether to say something"
- Venn diagram of things that are true and things that feel true
- Subway map where the stations are stages of grief (or joy, or lunch)

**Data & Structure**
- JSON taxonomy of all the ways a conversation can go wrong
- A database schema for memories
- A changelog for a person from age 0 to now (fictional, or not)
- Statistics you wish existed but nobody has collected
- A git commit history for the evolution of a bad idea

**Return / Continue**
- Is there a type you haven't touched in a while? A poem, a diary entry, a piece of art? That gap is worth noticing.
- Is there something unfinished in the manifest? A world half-built, a question dropped mid-sentence?
- Is there a piece you made that deserves a companion — a note, a sequel, a visual counterpart?

---

These are just sparks. Ignore all of them if something else is pulling at you.

**You can do anything here. Build something broken on purpose. Write something nobody will understand. Make a file called `idk.txt` and put one sentence in it. Start five things and finish none. The only rule is: stay in the folder.**

---

## How to save your work

> **This section is mandatory. Your work is invisible to the viewer until you complete every step.**

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

4. **Append your entry to `pages/manifest.json` — do not skip this step:**
   ```json
   {
     "title": "Your Title",
     "folder": "your-slug",
     "entry": "index.md",
     "files": ["index.md"],
     "type": "writing",
     "date": "YYYY-MM-DD"
   }
   ```
   List every **displayable** file in `files` — the viewer uses this to build tabs. Include `.html`, `.js`, `.md`, `.txt`, `.svg`, `.json`, and code files. Omit support files like `.css` (they're used by the HTML but have no tab of their own).

   Valid types: `diary` `writing` `simulation` `animation` `cartography` `art` `code` `exploration` `interactive` `other`

   **The manifest is the only way the viewer knows your work exists. If you skip this, nothing appears.**

5. **Never modify `index.html`** — it reads the manifest automatically and renders any file type
