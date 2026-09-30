---
name: ship-shell-completions
description: Any CLI tool we build or change must ship an updated zsh completion in the same change — tab-completion is the usage reference
metadata:
  type: feedback
---

When building a new CLI tool, or adding/removing/renaming any subcommand or flag on an existing one, write or update its zsh completion **in the same change**. Treat the completion as part of the deliverable, not a follow-up.

**Why:** The user's stated reason — "if I don't remember the usage, I can just hit tab." Tab-completion is their primary usage reference, so a tool without one is effectively undocumented at the point of use. On 2026-09-30 a `dotfiles-bundle` completion was drafted, deferred, then invalidated when the CLI changed underneath it; the user had to ask whether it had been done.

**How to apply:**
- Public tools → `links/.zsh_completions/_<tool>`; work-specific → `links/.zsh_completions.private/_<tool>`. Both are already on `fpath` via `.env.d/common/00_completions_fpath.env`.
- Derive the surface from `--help` output, not memory, so it matches the real parser.
- Mark repeatable flags with a leading `*`, and encode mutual exclusion with `(--a --b)` prefixes so the completion teaches the constraints.
- Resolve paths dynamically rather than hardcoding: `repo="${${:-$(command -v <tool>)}:A:h:h:h}"`.
- After installing, the cache must be cleared or it won't load: `rm -f ~/.zcompdump ~/.zcompdump.zwc && compinit`.

Related: [[macos-bash32]] for shell-portability constraints on the same machines.
