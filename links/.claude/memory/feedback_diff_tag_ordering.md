---
name: diff-tag-ordering
description: "Diff title tags go general→specific; use subtag (/) for parent-child, multi-tag for independent dimensions"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: ed5bd230-5d7b-4514-bcef-033d1b9a8f9a
---

Tags in diff titles must go from general to specific. Use subtag (`/`) when the second tag is a child of the first (e.g., `[hwc/console-log]`), use separate tags when they're independent dimensions (e.g., `[npi] [anacapa]`).

**Why:** `[console-log] [hwc]` reads backwards — the system (`hwc`) should come first so diffs sort and filter predictably by system. Consistency matters more than which style is used.

**How to apply:** Before writing a diff title, identify the system tag first (e.g., `[hwc]`, `[mc]`, `[si]`), then append the feature as a subtag if it's a child (`[hwc/console-log]`) or as a separate tag if it's an independent axis (`[hwc] [gcp]`).
