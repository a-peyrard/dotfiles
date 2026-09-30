---
name: gui-app-launch-from-shell
description: macOS GUI apps cannot be launched with `open` from the Claude Code shell (LaunchServices error -54) — never kill a GUI app from this shell
metadata:
  type: feedback
---

`open -a <App>` fails with `_LSOpenURLsWithCompletionHandler() failed ... error -54` from the Claude Code shell context — including when the user runs it via the `! command` prefix, since that executes in the same process. This happens even when the app bundle is completely valid (`codesign -v` passes, no quarantine xattr).

**Why:** On 2026-09-29 the agent told the user to run `killall AeroSpace && open -a AeroSpace` to reload a config change. The `killall` succeeded, the `open` failed with -54, and the user's window manager was left down with no way to restart it from the shell. Recovery required launching from Spotlight. The agent had suggested a kill without first verifying the relaunch path worked from this context.

**How to apply:** Never `killall` / `kill` a macOS GUI app from this shell unless relaunch has already been proven to work. To restart a GUI app, ask the user to launch it from Spotlight (`Cmd+Space`) or Finder — that is also the correct context for Accessibility/TCC permission grants. When a config change needs an app restart, say so and let the user drive the restart, rather than scripting kill-then-open.

Related: [[working-directory-boundary]] — the same shell context also can't write outside the session's allowlist.
