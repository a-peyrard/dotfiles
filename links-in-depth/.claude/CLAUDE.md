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
- **Keep it simple**: MVP-focused. Challenge over-engineering. Don't add abstractions, configurability, or indirection unless there's a clear need right now. Ask "do we really need this?" before adding complexity.
- **Tests**: Follow the existing test patterns in the codebase. Look at neighboring test files for structure, naming, fixtures, and assertion style before writing new tests. Use given/when/then structure in test bodies. Name test methods descriptively: `test_it_should_return_error_when_device_not_found`.
- **Tests before refactoring**: When refactoring, write or update tests FIRST against the current behavior, verify they pass, THEN refactor. The tests serve as a safety net to validate correctness of the refactor. Never refactor and write new tests in the same step.
- **One concern per step**: Don't combine behavior changes with structural changes. Separate refactoring (no behavior change) from feature work (behavior change). This makes each step independently verifiable.

## Working Style
- When exploring a task or codebase, produce a structured plan first, then implement in a fresh session.
- Prefer concise output. Skip boilerplate explanations.
- High autonomy: edit files, run builds/tests, fix errors without asking.

## Review Personas
- **AI-Justin**: MVP-focused, challenges over-engineering. Pushes back on unnecessary abstractions. "Do you really need this?" "Can this be simpler?" "What's the simplest thing that works?"
- **AI-Augustin**: Consistency, DRY, KISS. Checks that new code matches the style, patterns, and conventions of the surrounding codebase. Flags duplication — if logic exists elsewhere, reuse it. Challenges unnecessary complexity: "Is there a simpler way?" "Does this abstraction earn its keep?"

## Neovim Integration (nvc)

`nvc` is a CLI companion for controlling Neovim from Claude Code via tmux. It auto-spawns nvim in a split pane if none is running, scoped per tmux window.

### Commands
- `nvc <file>:<line>` — open file at line
- `nvc --highlight-function <file>:<line>` — highlight the enclosing function (treesitter)
- `nvc --highlight <file>:<line>` — highlight any enclosing block (if, for, class, etc.)
- `nvc --highlight-lines <file>:<start>-<end>[,...]` — highlight line ranges
- `nvc --diff <file>` — pipe proposed content on stdin, open side-by-side diff
- `nvc --clear` — clear all highlights
- `nvc --close-diff` — close diff view
- `nvc review [D12345|hash|.]` — review a diff/commit in diffview
- `nvc notes [D12345]` — read review or code notes (auto-detects context)
- `nvc errors` — get recent nvim errors (noice-aware)
- `nvc messages` — get raw `:messages` output
- `nvc cmd '<keys>'` — send raw key sequence to nvim
- `nvc expr '<expr>'` — evaluate vimscript expression
- `nvc quit` — close the nvim instance in this window
- `nvc debug set-breakpoints <file:line> ...` — set DAP breakpoints
- `nvc debug attach` — start DAP from `/tmp/fdb-dap.json`
- `nvc debug clear-breakpoints` — clear all breakpoints

Multiple highlight flags can be chained:
```
nvc --highlight-function f.py:43 --highlight-lines f.py:99-114,160-171
```

### Rules
- **Use `nvc` to show code to the user** — when discussing files, highlight the relevant section rather than dumping code in the terminal.
- **Always use absolute paths** — nvc resolves relative paths from `pwd`, but absolute is safer.
- **Clear highlights when done** — run `nvc --clear` after the user has seen the highlighted code.
- **Check `nvc errors` when something looks wrong** — useful for diagnosing LSP or plugin issues.
- **Read notes with `nvc notes`** — the user may have left review notes for you to act on.

## NEVER
- Never refactor or comment code adjacent to what was changed
- Never use `any`/`mixed` types in Python — use proper type hints

## ASK FIRST
- Before deleting files or branches
- Before making breaking API changes
