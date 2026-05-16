---
name: Session debrief should promote memories
description: At session debrief, review project-level memories written during the session and evaluate which should be promoted to global scope
type: feedback
---

At the end of each session debrief (`/session-debrief`), scan memories written during
the session in the project-level directory and evaluate which ones should be promoted
to the global memory directory (`~/.claude/memory/`).

**Why:** Feedback about workflow patterns, tool behaviors, and coding preferences applies
across all sessions, not just one project. But memories are often written to the
project-level directory by default. Without promotion, useful lessons stay invisible
to sessions in other working directories.

**How to apply:** During `/session-debrief`, add a step that:
1. Lists memories created/modified during the session (compare timestamps)
2. For each one, ask: "Is this project-specific or universal?"
3. Universal ones (workflow, preferences, tool usage) → move to `~/.claude/memory/`
4. Project-specific ones (code details, contacts, decisions) → keep in project directory

TODO: Add this as a step in the `/session-debrief` skill definition.
