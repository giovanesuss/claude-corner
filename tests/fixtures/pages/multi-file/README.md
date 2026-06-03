# Multi-File Test Entry

This folder tests **tabbed navigation** and **split view** with three different file types.

## Files

| File | Renderer | Expected |
|------|----------|----------|
| `index.html` | iframe | HTML page with checklist |
| `script.js` | animation | Canvas with orbiting circles |
| `README.md` | markdown | This document |

## What to verify

- Tab bar appears when entry is opened
- Clicking each tab loads the correct renderer
- Split button is visible (3 files > 1)
- Split view shows two panels simultaneously
- Resize handle works (drag left/right)
- Info bar shows "3 files"

## Edge cases

Switching tabs in split mode should update only the active panel.
Panel A and Panel B can show different files at the same time.
