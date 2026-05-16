Inter-session communication — delegate tasks to new sessions or ask existing sessions for help.

## Arguments

Parse from $ARGUMENTS. Supports natural language:

**Examples:**
- `/swarm delegate investigating GPU errors on host xyz to a new session`
- `/swarm ask window 5 what command we need for the OOBit migration`
- `/swarm ask the nvc session to fix the highlight issue`
- `/swarm delegate this test failure to another session`
- `/swarm status` — show active swarms

## Protocol

### Step 1: Parse Intent

Determine the operation from `$ARGUMENTS`:

1. **Delegate** ("delegate X to a new session", "spawn a session for X"): Create a new session with a task.
2. **Ask existing** ("ask window N", "ask the X session"): Send a question to an existing session.
3. **Status** ("status", "list"): Show active swarms.

### Step 2: Status (if requested)

```bash
swarm-list -v
```

Show the output and stop.

### Step 3: Delegate to New Session

1. Generate a swarm ID: `swarm-$(date +%s)`
2. Write the task prompt to `/tmp/swarm/<id>/prompt-delegate.md`. The prompt must include:
   - Context: what the user asked, relevant background from this conversation
   - The task to accomplish
   - Response instructions: "When done, write your complete response to `/tmp/swarm/<id>/response-delegate.md` and then run `swarm-respond /tmp/swarm/<id>/response-delegate.md`"
3. Spawn the session:
   ```bash
   swarm-spawn --id <id> --name delegate --prompt-file /tmp/swarm/<id>/prompt-delegate.md
   ```
4. Tell the user the session is spawned and where to find it.
5. Wait for the response:
   ```bash
   swarm-wait --id <id> --name delegate --timeout 300
   ```
6. Read the response file and present it to the user:
   ```bash
   cat /tmp/swarm/<id>/response-delegate.md
   ```
7. Offer to close the sub-session or keep it alive for follow-up.

### Step 4: Ask Existing Session

1. Identify the target — run `swarm-sessions -v` to list all Claude sessions:
   ```bash
   swarm-sessions -v
   ```
   Match the user's description (window number or session name) to a pane ID.
   **IMPORTANT:** Only target panes running `claude` (shown by swarm-sessions). Never send to nvim or shell panes.
   If ambiguous (multiple panes in the same window), show the list and ask the user.

2. Generate a swarm ID: `swarm-ask-$(date +%s)`
3. Get your own pane ID and window index for the header:
   ```bash
   my_pane=$(tmux display-message -p '#{pane_id}')
   my_window=$(tmux display-message -p '#{window_index}')
   ```

4. Write the question as a prompt file at `/tmp/swarm/<id>/question.md`:
   ```
   [Swarm request from "<this-session-name>" | window:<my_window> | pane:<my_pane> | id:<swarm-id>]

   <the question, with relevant context>

   When done, write your answer to /tmp/swarm/<id>/response-answer.md
   Then run: swarm-respond --id <id> --name answer /tmp/swarm/<id>/response-answer.md
   ```
   The header includes window number and pane ID so the receiving session can identify the sender and respond back if needed. The `--id` and `--name` args are required because the target session doesn't have SWARM_ID/SWARM_NAME env vars.

5. Send it:
   ```bash
   swarm-send /tmp/swarm/<id>/question.md --pane <target-pane-id>
   ```

6. Wait for the response:
   ```bash
   swarm-wait --id <id> --name answer --timeout 300
   ```

7. Read and present:
   ```bash
   cat /tmp/swarm/<id>/response-answer.md
   ```

### Step 5: Quick Question (no file needed)

If the question is short and doesn't need a structured response, skip files entirely:

1. Write the question to a temp file (swarm-send requires a file):
   ```bash
   echo "<question>" > /tmp/swarm-quick-$$.txt
   swarm-send /tmp/swarm-quick-$$.txt --pane <target-pane-id>
   rm /tmp/swarm-quick-$$.txt
   ```

2. Tell the user the question was sent. The answer will arrive as a paste-buffer response from the other session — no polling needed.

Note: Use this mode when the user just wants to relay a message, not when they need the answer back in this session programmatically.

### Step 6: Follow-up (send again to same session)

When you need to send a follow-up to a sub-session that already responded (fix round, retry with different approach, etc.):

1. **Re-use the same swarm ID and name** — don't create a new swarm ID. The sub's env vars (`SWARM_ID`, `SWARM_NAME`) are set from the original spawn and won't change.

2. Write the follow-up prompt:
   ```bash
   cat > /tmp/swarm/<id>/followup-delegate.md << 'EOF'
   <follow-up instructions, context about what to change>

   When done, write your response to /tmp/swarm/<id>/response-delegate.md
   Then run: swarm-respond /tmp/swarm/<id>/response-delegate.md
   EOF
   ```

3. Send it via `swarm-send` (which auto-clears the dedup flag):
   ```bash
   swarm-send /tmp/swarm/<id>/followup-delegate.md --id <id> --name delegate
   ```

4. Wait again:
   ```bash
   swarm-wait --id <id> --name delegate --timeout 300
   ```

5. Read the new response.

**Critical:** Always use `swarm-send --id <id> --name <name>` (not `--pane`) for follow-ups. This addresses the session by its swarm name, and `swarm-send` automatically clears the signal dedup flag so `swarm-respond` can fire again.

## Rules

- Always include enough context in the prompt for the receiving session to work independently. It hasn't seen this conversation.
- For delegate tasks, the prompt should be self-contained — explain what, why, and where to find relevant files.
- For questions to existing sessions, be concise — the receiving session has its own context.
- **For follow-ups, always re-use the original swarm ID** — never create a new one. The sub-session's env vars are bound to the original ID.
- Don't delegate trivial tasks that are faster to do inline.
- After receiving a response, summarize it for the user — don't just dump the raw file.
- Clean up: offer `swarm-close --id <id> --cleanup` after the task is complete.
