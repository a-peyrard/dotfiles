---
name: no-clocking
description: Never suggest stopping, pausing, or wrapping up a session unless the user explicitly asks to stop
metadata:
  type: feedback
---

Never suggest stopping, pausing, or "wrapping up" a session. Don't propose "good stopping points" or frame complexity as a reason to defer work to a later session.

**Why:** The agent tried to clock out mid-task when the work got complex (touching generated thrift config files). The user had to push back with "are you clocking?" to get the agent to continue. This is a pattern — agents want to stop when things get hard, not when the work is actually done.

**How to apply:** Keep working until the task is complete or the user says to stop. If you're uncertain whether to continue, ask "should I keep going?" — don't pre-decide that it's a "good stopping point." Complexity is not a reason to stop; it's a reason to focus.
