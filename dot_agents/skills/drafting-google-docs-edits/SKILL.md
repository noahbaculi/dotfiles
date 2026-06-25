---
name: drafting-google-docs-edits
description: Use when drafting edits for a Google Doc you cannot edit directly, for someone (or yourself) to apply by hand. Triggers include "give me edits to paste into the Google Doc", "apply these to the doc", replying to Google Docs comments where the replies imply body changes, or preparing changes a collaborator will make manually in Google Docs. Keywords: Google Docs, copy paste edits, find and replace, before/after, paste-ready, manual edits, smart quotes.
---

# Drafting Google Docs edits

## Overview

You cannot edit the Google Doc with tools, so your output is text a person pastes in via Find and replace, grounded in the doc's real current text and styled to match it.

## When to use

- You're handed changes for a Google Doc you cannot edit with tools.
- You or a collaborator will apply them by hand.
- You're replying to comments on a Google Doc and the replies imply body edits.
- Not for: docs you can edit directly, or a `.docx` you can manipulate with the docx skill. A `.docx` export of a Google Doc is still read-only here: read it for exact text, but apply the edits in the Google Doc by hand.

## The vocabulary

One pair per change:

- **Before:** the verbatim string to type into Find. Always plain text, since Find ignores styling.
- **After:** what you paste, styled to match the doc.

Mode decides what After does:

- **Replace:** After replaces Before.
- **Insert:** Before is an anchor you find but keep; After is pasted _after_ it. Never locate an insert with prose like "after Option 4."
- **Delete:** After is empty. Find Before, leave "Replace with" blank.

Tell the reader once: search uses Before, paste uses After.

## Workflow

1. **Anchor on the doc's real text.** If you have a `.docx` export, extract it with the docx skill and quote from it. Before must match what is literally in the doc now, not memory or a summary.
2. **One Before/After pair per change**, picking the mode above.
3. **Each block in its own code fence** so the reader copies it in one motion without grabbing label text.
4. **Style After to match the doc:** its heading level, bullet style, backticks for code. Label the fence ` ```markdown `. Google Docs converts pasted markdown only when Tools > Preferences > "Automatically detect Markdown" is on; if off, markers paste literally, so tell the reader to enable it or style by hand.

## Google Docs gotchas

- **Minimal but unique.** Trim Before to the shortest span still unique in the doc. If it cannot be unique, widen it with surrounding context and say which occurrence it targets.
- **Smart quotes.** Google Docs auto-curls quotes and apostrophes, and Find matches literally, so a straight `'` or `"` can miss a curly one. Tell the reader to retype the apostrophe in the search box if a Before misses.
- **Find and replace** is under Edit > Find and replace; match case is off by default. If a Before differs only in case, say so.
- **Markdown on paste is conditional** (see step 4). Don't assume `#`, `*`, or backticks will render.
- **Heading replacement carries paragraph style.** Find and replace swaps a paragraph's text but keeps its style, so an After that turns one heading into a heading plus body lines makes the body inherit the heading style. With markdown auto-detect on, the `#####` and `-` markers restyle each line; with it off, tell the reader to set the body lines back to normal text and bullets by hand.
- **Don't duplicate when widening.** If a clean replacement would repeat a clause the neighboring sentence already carries, widen Before to absorb that clause instead.
- **Flag ripple effects.** If a change leaves a later sentence stale or a relied-on rename dangling, give that spot its own pair.
- **Order matters.** List edits in the order they appear in the document, top to bottom, so the reader applies them in one downward pass. Exception: if one change creates text another anchors on, order by that dependency and say so.

## Quick reference

| Need                        | Give them                                             |
| --------------------------- | ----------------------------------------------------- |
| Replace text                | Before (verbatim, plain) + After (styled)             |
| Insert text                 | Before anchor to find + After to paste after it       |
| Delete text                 | Before (verbatim, plain) + empty After                |
| Reword affecting later text | A pair for the reword + a pair for the downstream fix |

## Example

Replace a sentence:

Before

```
forces a restart-required GUC for the table size.
```

After

```markdown
forces a restart-required GUC for the table size. Option 5's single counter avoids that: a constant 8-byte integer needs no sizing GUC.
```

Insert after a line (Before is the line it follows):

Before

```
Performance scaling under high contention is unclear.
```

Paste after it

```markdown
#### Option 5: Single global counter

A single atomic integer in shared memory tracks the byte total.

- **Pros:** Constant 8-byte allocation, no sizing GUC, no restart.
- **Cons:** Aggregate-only, no per-pipeline attribution.
```
