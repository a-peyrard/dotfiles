---
name: backups-outside-tmp
description: Backups taken before irreversible operations must not live in /tmp — macOS clears it at boot
metadata:
  type: feedback
---

Before an irreversible operation (history rewrite, bulk move, force-push prep), put the backup and any
artifacts needed to undo or audit it (commit maps, filter files, pre-edit copies) somewhere persistent —
never only in `/tmp`.

**Why:** On 2026-09-30 the only pre-rewrite mirror of a repo and the filter-repo commit maps were in `/tmp`.
The user then announced a reboot; macOS clears `/tmp` at boot, which would have deleted the only way back.
Caught only because the reboot was mentioned before it happened.

**How to apply:**
- Write backups under a writable persistent path from the start. The Claude Code sandbox may block `~/`
  outside the working directories — use a `backups/` directory inside an allowed working directory
  that is not itself a git repo.
- Record the backup path in the session notes / handoff, next to the command that would use it.
- Delete the backup only after the irreversible step is verified (e.g. the force-push checked on the remote).

Related: [[verify-before-flagging-risk]].
