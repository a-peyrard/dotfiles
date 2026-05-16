Load ASCII art diagram rules for creating or fixing Unicode box-drawing diagrams in documentation. USE when creating, editing, or fixing ASCII art diagrams in markdown files.

## Rules

- Box borders: `─` not `-`, `│` not `|`, `┌┐└┘` not `+`
- Connections: `───>` not `--->`, `<───` not `<---`
- Trees: `├──` and `└──` are fine
- Arrows: `▼` on its own line above `┌─────┐`, NEVER inside the border (`┌──▼──┐` is forbidden)

## Workflow

### Step 1: Design the column grid

Before writing any line, define the column positions for all boxes and vertical pipes:

```python
COLS = {
    'outer_l': 1,     # ║
    'box1': (4, 23),   # left column boxes (20 wide)
    'box2': (28, 47),  # center column boxes (20 wide)
    'box3': (52, 72),  # right column boxes (21 wide)
    'vpipe': 59,       # vertical connector column
    'outer_r': 78,     # ║
}
```

### Step 2: Measure content BEFORE placing it

```python
text = " FastCheck Service "  # 19 chars
box_inner = 18                # ┌ + 18×─ + ┐ = 20 wide box
assert len(text) == box_inner, f"Content {len(text)} != border {box_inner}"
```

### Step 3: Build lines with `pad_line()`

Never hand-count spaces. Use this for lines with an outer border:

```python
def pad_line(content, width=79):
    return ' ║' + content.ljust(width - 3) + '║'
```

### Step 4: Run `ascii-art-fix` (MANDATORY)

Run this after EVERY diagram edit. A diagram is NOT done until this passes with zero errors.

```bash
ascii-art-fix verify <file>   # check only, exit 1 on errors
ascii-art-fix fix <file>      # auto-fix and re-verify
```

`ascii-art-fix` (at `~/.local/bin/ascii-art-fix`) is display-width-aware:
handles emojis (2 display columns), nested boxes, side-by-side boxes (KPI cards),
and cascading inner/outer border fixes. Run `ascii-art-fix --help` for details.

## Key Lessons

1. **Never do naive character substitution.** `+` → `┌` is wrong without checking context. Determine from neighbors: `─` right AND `│` below → `┌`, `─` left AND `│` below → `┐`, etc.
2. **Vertical pipes must stay on the same column** across all lines. Define the column in the grid and verify.
3. **Content width must equal border width.** Measure BEFORE placing.
4. **Use `pad_line()`** for consistent right borders — trailing spaces are invisible killers.
5. **Work bottom-to-top** when inserting lines (e.g., adding `▼` above `┌`) to avoid line-number drift.
