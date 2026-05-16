Scan git repos for uncommitted changes after a dotfiles sync and propose feature-grouped commits. USE when the user says "commit sync", "sync commits", "commit the synced files", "commit after sync", "what needs committing", or asks to commit changes across local git repos after syncing.

## Steps

### 1. Detect environment

Run `uname -s`:
- **Linux** (devserver): scan `~/.config/nvim`, `~/.local`
- **Darwin** (laptop): scan `~/config/dotfiles`, `~/config/dotfiles-private`

Only include repos where `.git` exists. On devserver, never check `~/config/dotfiles/` — it's a leftover snapshot, not a real repo.

### 2. Scan repos for changes

For each repo, run in parallel:
```bash
git -C <repo> status --short
```

If a repo has no output, skip it entirely. If ALL repos are clean, report "All repos are clean — nothing to commit." and stop.

### 3. Load project context

Resolve second brain root: `$PARA_ROOT` if set, else `~/gdrive`. If neither exists, skip this step.

Load CLAUDE.md files based on which repos have changes (deduplicate):

| Repo with changes | Load project CLAUDE.md |
|--------------------|------------------------|
| `~/.config/nvim` | `01_projects/neovim-ide/CLAUDE.md` |
| `~/.local` | `01_projects/neovim-ide/CLAUDE.md`, `01_projects/claude-sessions-tooling/CLAUDE.md` |
| `~/config/dotfiles` | `01_projects/dotfiles/CLAUDE.md` |
| `~/config/dotfiles-private` | `01_projects/dotfiles/CLAUDE.md` |

Only read CLAUDE.md files that exist. If second brain is unavailable, proceed without — group changes based on diff analysis alone.

### 4. Collect diffs and commit style

For each repo with changes, run in parallel:
- `git -C <repo> diff` (unstaged changes)
- `git -C <repo> diff --cached` (staged changes, if any)
- `git -C <repo> log --oneline -5` (commit message style reference)

For untracked files: read their contents (skip binary files). Filter out artifacts from the skip list.

### 5. Group changes into commits

Analyze all diffs and new files using the project context. Group into logical commits:

- **One repo per commit** — never cross-repo commits
- **Functional cohesion** — files implementing the same feature go together
- **Separate concerns** — docs separate from code, config from features, unless tightly coupled
- **Match commit style** — use each repo's existing message format from `git log`

### 6. Pre-commit checks (Darwin only)

Skip this entire step on Linux (devserver). These checks only apply on the laptop where both repos and tooling exist.

**A. Sensitive content scan (public repo)**

For all changed/new files in `~/config/dotfiles`, grep for employer-specific terms: `Meta`, `Facebook`, `facebook`, `fbcdn`, `internalfb`, `meta.com`, `fburl`, `fbid`, `intern.facebook`, `workplace.com`. Ignore matches inside `CLAUDE.md` files (which reference project context).

If any match is found, flag the file with the matched term and suggest:
- Moving it to `dotfiles-private` (as a `.private` or `.add.private` file), OR
- Removing the sensitive reference if the file is otherwise generic

**B. Destination analysis (new/untracked files only)**

- **In public repo** (`~/config/dotfiles`): does the file have a `.private` suffix or contain employer-specific terms? → flag as "likely belongs in `dotfiles-private`"
- **In private repo** (`~/config/dotfiles-private`): is the file generic (no `.private` suffix, no employer-specific content)? → flag as "could be public in `dotfiles`"

**C. Symlink reminders**

- If any new `.add.private` files were added in `dotfiles-private` → remind: "Run `dotfiles-private-link` to create symlinks"
- If any new files were added under `links/` or `links-in-depth/` in `dotfiles` → remind: "Run `./install.sh --dry-run` to preview new symlinks, then `./install.sh` to apply"

Include all flags and reminders in the commit plan output (step 7) so the user sees them before approving.

### 7. Present commit plan

Format the plan as:

```
## Commit Plan

### ~/.config/nvim (N commits)

1. **commit message here** — `file1`, `file2`
2. **commit message here** — `file3`

### ~/.local (N commits)

3. **commit message here** — `file4`, `file5`

### Skipped
- `default.profraw` (build artifact)

Proceed?
```

**STOP HERE and wait for user approval.** The user may:
- Say "yes" / "y" → execute all commits
- Say "edit 2: new message" → modify a commit's message
- Say "skip 3" → drop a commit
- Say "merge 1 and 2" → combine commits
- Say "abort" → cancel everything

### 8. Execute commits

After approval, for each commit sequentially:

```bash
git -C <repo> add <file1> <file2> ...
git -C <repo> commit -m "$(cat <<'EOF'
<commit message>
EOF
)"
```

Report each commit as it completes. After the last commit, run `git -C <repo> status --short` for each repo to confirm everything is clean.

## Artifact skip list

Never include these in any commit. If untracked, mention them as "Skipped" in the plan:
- `*.profraw`, `default.profraw` (LLVM coverage)
- `*.pyc`, `__pycache__/` (Python)
- `.DS_Store` (macOS)
- `*.swp`, `*.swo` (vim swap)
- `node_modules/`

## Rules

1. NEVER use `git add -A`, `git add .`, or `git add --all` — always add specific files by name.
2. NEVER commit files that appear to contain credentials, tokens, or secrets. If unsure, ask.
3. Match each repo's existing commit message style from `git log --oneline -5`.
4. Present the plan and WAIT for user approval before executing any commits.
5. If a commit fails (pre-commit hook, etc.), report the error and move to the next commit.
6. If the user has already staged files, show them separately and ask whether to include or leave as-is.
