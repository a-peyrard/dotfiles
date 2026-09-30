---
name: verify-before-flagging-risk
description: Read the code before asserting a risk or writing a plan item — speculative warnings become wrong plans that get executed later
metadata:
  type: feedback
---

Before stating that something is risky, broken, or needs special handling — and especially before writing it into a plan document — verify it against the actual code or file contents. Plans get executed later, by someone with less context, who will not re-derive the reasoning.

**Why:** On 2026-09-30 three speculative claims made it into a plan or a recommendation and all three were wrong on inspection:

- "A partial pull will corrupt the manifest for unpulled files" — it doesn't; the manifest is rebuilt by hashing the local package, so filtered-out files keep their hash.
- "`deploy` must be kept for fresh-host provisioning" — it needn't; `classify_changes` marks everything `local_only` when there's no manifest, which is exactly what sync's push phase deploys.
- Worst: a plan item proposed un-ignoring `links/.claude/CLAUDE.md` in the **public** dotfiles repo. The file contains the author's work email and internal project names. Executing that plan item would have pushed employer data to public GitHub. It was caught only by grepping the file immediately before editing `.gitignore`.

**How to apply:**
- Grep or read the file before proposing to publish, un-ignore, commit or delete it — particularly anything moving into `dotfiles/`, which is public and forbids employer references.
- When a risk is hypothesised but unverified, either verify it before writing it down, or label it explicitly as unverified in the plan.
- When a claim turns out wrong, correct it in the plan document itself (strike it, say why) — not just in conversation. The document outlives the conversation.
- The same applies when *executing* a handoff or plan: re-verify its recommendations before acting. On 2026-09-30 a handoff called two skills "worth versioning" in the public repo; both were employer-specific, and a "just amend one commit" fix turned out to miss a leak that was already public.

Related: [[ship-shell-completions]], [[working-directory-boundary]].
