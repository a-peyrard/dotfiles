# Global Memory Index

This directory is in the public dotfiles repo. Employer-specific memories live in
`private/` with their own index (`private/MEMORY.md`), versioned in dotfiles-private.

## PARA Workspace
- [Store plans in PARA project directory](feedback_plans_in_project.md) — Plans go in ~/gdrive/01_projects/<project>/plan.md, not ~/.claude/plans/

## Tooling
- [Use ascii-art-fix for diagrams](feedback_ascii_art_verify.md) — run `ascii-art-fix verify/fix` after every diagram edit; handles emoji widths

## Testing
- [Given/when/then test structure](feedback_given_when_then_tests.md) — Tests must use `# given` / `# when` / `# then` comments with blank line separation

## Agent Discipline
- [Don't clock out](feedback_no_clocking.md) — never suggest stopping unless the user asks; complexity is not a reason to defer
- [Tests aren't gospel](feedback_tests_arent_gospel.md) — passing tests don't prove correct design; check if tests validate intent or side-effects
- [Verify before flagging risk](feedback_verify_before_flagging_risk.md) — read the code before asserting a risk or writing a plan item; wrong plans get executed later

## Session Workflow
- [Debrief should promote memories](feedback_debrief_promote_memories.md) — At debrief, review project memories and promote universal ones to global scope. TODO: add to /session-debrief skill.

## Terminal & UI
- [GUI apps won't launch from this shell](feedback_gui_app_launch_from_shell.md) — `open -a` fails with LaunchServices -54; never killall a GUI app from here

## CLI Tooling
- [Ship shell completions with the tool](feedback_ship_shell_completions.md) — any new/changed CLI must update its zsh completion in the same change; tab is the usage reference

## macOS Platform
- [macOS bash is 3.2](reference_macos_bash32.md) — `declare -A` fails silently and corrupts lookups; use `case` or awk instead
