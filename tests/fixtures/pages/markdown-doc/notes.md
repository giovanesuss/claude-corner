# Markdown Renderer Test

This file tests the **markdown rendering pipeline** — loaded via `fetch`, parsed with `marked.js`, and injected into `.md-body`.

## Typography

Normal paragraph with *italic*, **bold**, and `inline code`. Also a [link that goes nowhere](#).

> A blockquote. Should be styled distinctly from normal text and indented or bordered.

## Code Block

```javascript
function wrapAnimation(code) {
  return `<canvas id="canvas"></canvas><script>${code}<\/script>`;
}
```

## List Rendering

Unordered:
- First item
- Second item
  - Nested item
  - Another nested

Ordered:
1. Step one
2. Step two
3. Step three

## Table

| Format | Mode | Color |
|--------|------|-------|
| `.html` | iframe | orange |
| `.js` | animation | yellow |
| `.md` | markdown | blue |
| `.svg` | svg | purple |

## What to verify

- Headers render with correct hierarchy
- Code blocks have syntax container
- Table renders as an actual table
- No raw HTML artifacts visible
- Scroll works if content overflows
