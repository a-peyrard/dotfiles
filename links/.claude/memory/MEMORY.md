# Global Memory Index

## Google Docs Editing
- [Google Docs editing patterns](reference_gdocs_editing.md) — decision tree, gotchas (style inheritance, write-cell prepends, --html can't find table text), table ops, CLI reference

## Diff Quality
- [Diff tag convention](feedback_diff_tag_convention.md) — use short tags: [mc], [si], [anr]; / for subtags; multi-tag for independent dimensions
- [Code blocks in diffs](feedback_code_blocks_in_diffs.md) — formatting preference for code in diff descriptions
- [Diff tag ordering: general→specific](feedback_diff_tag_ordering.md) — System tag first, then feature subtag; `/` for parent-child, separate tags for independent dimensions

## PARA Workspace
- [Store plans in PARA project directory](feedback_plans_in_project.md) — Plans go in ~/gdrive/01_projects/<project>/plan.md, not ~/.claude/plans/

## DevServer & Tooling
- [Clean up erepo clones](feedback_erepo_cleanup.md) — always `erepo rm` after work is done; stale clones waste resources
- [Use ascii-art-fix for diagrams](feedback_ascii_art_verify.md) — run `ascii-art-fix verify/fix` after every diagram edit; handles emoji widths

## Source Control
- [Never amend landed diffs](feedback_never_amend_landed_diffs.md) — always create a fresh diff on a new bookmark; landed commits can't be amended

## Agent Discipline
- [Don't clock out](feedback_no_clocking.md) — never suggest stopping unless the user asks; complexity is not a reason to defer
- [Tests aren't gospel](feedback_tests_arent_gospel.md) — passing tests don't prove correct design; check if tests validate intent or side-effects

## Session Workflow
- [Debrief should promote memories](feedback_debrief_promote_memories.md) — At debrief, review project memories and promote universal ones to global scope. TODO: add to /session-debrief skill.

## Oncall
- [Start from actual alerts](feedback_oncall_start_from_alerts.md) — get the specific emails/alerts first, then investigate; don't do broad sweeps

## Terminal & UI
- [Bare URLs for Ghostty](feedback_bare_urls_for_ghostty.md) — render as bare https:// not markdown [text](url) for terminal clickability
