---
name: feedback-ascii-art-verify
description: Always use ascii-art-fix CLI tool after every diagram edit — never hand-count characters or do naive substitution
metadata:
  type: feedback
---
When creating or editing ASCII art diagrams, always invoke `/ascii-art` first to load the full rules, then use `ascii-art-fix` to verify and fix.

**Why:** In April 2026, agents did naive `+`->`┌` character substitution across ~40 diagram blocks without running verification. This produced: content wider than borders (off-by-1), vertical pipe drift between lines, arrows inside borders (`┌──▼──┐`), and misaligned right borders. Required 3+ rounds of fixes to clean up.

**How to apply:** Before any diagram work, run `/ascii-art`. After every edit, run:
```bash
ascii-art-fix verify <file>   # check only
ascii-art-fix fix <file>      # auto-fix + re-verify
```
The tool lives at `~/.local/bin/ascii-art-fix` (v1.0.0). It handles emoji display widths, nested boxes, side-by-side boxes, and cascading fixes. A diagram is NOT done until `ascii-art-fix verify` reports zero errors.
