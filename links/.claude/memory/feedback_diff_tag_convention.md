---
name: Diff tag convention
description: Use short canonical tags in diff titles — [mc], [si], [anr], etc. with / for subtags and multi-tags for independent dimensions
type: feedback
originSessionId: d3407d3e-e41c-44b8-a715-89b9774167fe
---
Use short tags in diff titles, not full names. Key mappings:
- `[mc]` not `[machinechecker]`
- `[si]` not `[sysinspector]`
- `[si/db]` not `[sidb]` or `[sysinspectordb]`
- `[hwc-to-oobit]` not `[hwc-to-oobit/si]`
- `[fleet-health]` not `[fleet_health]` or `[fh]`
- `[claude-code]` not `[Claude Code]`

**Why:** Team has 7+ variants for MachineChecker alone; user wants personal consistency based on analysis of 712 TC diffs.

**How to apply:** When creating commit messages or diff titles for the user, always use the canonical short tag from `~/gdrive/01_projects/chai-knowledge/diff-tag-convention.md`. Use `/` for subtags (child of parent), multiple `[]` tags for independent dimensions (system + platform).
