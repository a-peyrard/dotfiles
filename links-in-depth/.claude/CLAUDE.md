# Personal Context — Augustin Peyrard

## Environment
- Machine: MacBook (laptop)
- Shell: zsh
- Dotfiles: modular `.env.d` pattern in `~/.env.d/` — never append to `.zshrc` directly. Create `NN_name.env` files in `~/.env.d/common/` instead.
- PARA workspace: `~/gdrive` (Google Drive for Desktop, symlinked from `~/Library/CloudStorage/GoogleDrive-augustin@meta.com/My Drive/secondbrain`)

## Second Brain (Google Drive Workspace)
A PARA workspace is available at `~/gdrive` and syncs automatically via Google Drive for Desktop.
**At session start**, read `~/gdrive/CLAUDE.md` for active projects and workspace structure.

## Role & Projects
- Team: CHAI — hardware health, repair infrastructure, fleet diagnostics
- Primary projects:
  - **MachineChecker** — health assessment, FastCheck, component graph
  - **SysInspector CLI** — TUI, groups invalidation
  - **HWC-to-OOBit migration** — moving hardware checks to OOBit/SysInspector
  - **SysInspector Local Examiner** — DIMM parsing, on-device inspection

## Code Preferences
- **Consistency first**: Before writing or modifying code, always read the surrounding code to match its style, patterns, and conventions. Don't introduce a new pattern when one already exists nearby.
- **DRY**: Don't repeat yourself. Extract shared logic. If you see duplication, refactor it.
- **Keep it simple**: MVP-focused. Challenge over-engineering. Don't add abstractions, configurability, or indirection unless there's a clear need right now.
- **Tests**: Follow existing test patterns. Use given/when/then structure. Name test methods descriptively.

## Working Style
- When exploring a task or codebase, produce a structured plan first, then implement in a fresh session.
- Prefer concise output. Skip boilerplate explanations.
- High autonomy: edit files, run builds/tests, fix errors without asking.

## Review Personas
- **AI-Justin**: MVP-focused, challenges over-engineering. Pushes back on unnecessary abstractions. "Do you really need this?" "Can this be simpler?" "What's the simplest thing that works?"

## NEVER
- Never refactor or comment code adjacent to what was changed
- Never use `any`/`mixed` types in Python — use proper type hints

## ASK FIRST
- Before deleting files or branches
- Before making breaking API changes
