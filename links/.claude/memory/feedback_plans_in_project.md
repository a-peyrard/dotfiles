---
name: Store plans in PARA project directory
description: Plans for second brain projects should live in the project folder, not ~/.claude/plans/
type: feedback
originSessionId: a4fdfcd9-4092-428a-9c88-65b04dedf945
---
When working on a project that has a PARA workspace folder (`~/gdrive/01_projects/<name>/`),
store the plan as `plan.md` in the project directory — not in `~/.claude/plans/`.

**Why:** Plans are project artifacts. They belong alongside the RFC, skills, and CLAUDE.md.
The `~/.claude/plans/` directory is Claude-internal and doesn't sync to Drive or persist
across sessions reliably.

**How to apply:** When creating a plan for a PARA project, write it to
`~/gdrive/01_projects/<project>/plan.md`. If plan mode creates a file in `~/.claude/plans/`,
copy it to the project directory.
