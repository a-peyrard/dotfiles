End-of-session debrief — analyze this session honestly and specifically:

## Step 0: Knowledge Sync (do first)

### 0a: Second Brain Project Sync

Check if this session involved work related to a second brain project in `~/gdrive/01_projects/`. This includes: editing files there, using a project as reference, doing oncall/investigation work that produced knowledge for a project, or any session where learnings should flow back into a project's knowledge base. The question is "did this session produce knowledge that belongs in a project?" — not just "did we edit files there."

If yes:
1. Run `/para-workspace:update-from-session` to create the session file and update the project CLAUDE.md
2. Then continue with 0b

If no second brain project was involved, skip to 0b.

### 0b: CHAI Knowledge Harvest

Check if this session discovered any CHAI domain knowledge — system behaviors, tool commands/quirks, failure patterns, architecture facts, API/config details, platform specifics, or oncall learnings. This applies to ANY session, not just ones working on chai-knowledge directly.

If yes: run `/knowledge-harvest` to capture findings into `~/gdrive/01_projects/chai-knowledge/`.

If the session was purely about Claude tooling, dotfiles, or non-CHAI work, skip this step.

---

1. **Blockers & friction**: What slowed us down? Any tool failures, permission issues, missing context, or times you went in circles?
   - **Permission audit**: You cannot observe which tool calls required manual approval — they all look the same to you. To compensate, ALWAYS do the following: (1) read `~/.claude/settings.json` permissions.allow list, (2) list every distinct tool call you made this session with its arguments, (3) cross-reference each against the allow rules, (4) report which calls were likely NOT covered and would have required user approval, (5) suggest specific allow rules to add. Never skip this — never just ask the user if there was friction. IMPORTANT: Never suggest adding destructive commands (rm, git reset --hard, git clean, git checkout ., rmdir, etc.) to the allow list — these must always require manual approval.
2. **Memory promotion check**: Review memories written during this session in the project-level directory (`~/.claude/projects/.../memory/`). For each one created or modified in this session:
   - **Universal** (workflow patterns, tool behaviors, coding preferences) → move to global `~/.claude/memory/` and update both MEMORY.md files
   - **Project-specific** (code details, contacts, decisions) → keep in project directory
   Report which memories were promoted and why.
3. **Memory & knowledge updates**: Save learnings following this priority hierarchy:
   - **If working on a second brain project** (most knowledge was already synced in Step 0):
     1. Only save things here that Step 0 didn't cover — cross-project learnings, user preferences, tool behaviors
     2. Save to `~/.claude/.../memory/` as a thin reference if needed
     3. Only if the learning is useful across ALL projects, save to global `~/.claude/` memory or global CLAUDE.md
   - **If NOT on a second brain project**: save to `~/.claude/.../memory/` as before
   - Prefer the second brain (`~/gdrive/`) for knowledge — it's portable across devservers. Keep `~/.claude/` memory as a thin auto-loaded index.
4. **CLAUDE.md updates**: Should any instructions in my global CLAUDE.md or project CLAUDE.md be added, updated, or removed based on what happened?
5. **What worked well**: Any approaches or patterns that worked particularly well and should be reinforced?
6. **Improvement suggestions**: Concrete changes I could make to my setup, workflow, or how I give you tasks to make future sessions smoother.

Only flag things that actually came up or would have helped in this specific session. Don't give generic advice. If a section has nothing meaningful, say so and move on.

If you suggest memory or CLAUDE.md changes, go ahead and make them now.

After making changes, include a short **Changelog** section in your response with one-line bullet points summarizing each addition/update/removal — so the user can see what changed without expanding tool call logs. Group by location: second brain project, ~/.claude/ memory, CLAUDE.md.
