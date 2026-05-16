Orchestrate a multi-round adversarial debate across tmux panes. Reviewer sessions critique and refine a plan through structured rounds while the master session (you) defends and revises.

## Arguments

Parse from $ARGUMENTS. Supports two formats:

**Structured:** `--rounds 2 --with grumpy,chaic3`
**Natural language:** `"debate this plan with grumpy, justin, and augustin in 4 rounds"`

Examples:
- `/debate --rounds 2 --with grumpy,chaic3`
- `/debate --with chaic3`
- `/debate debate this with grumpy and ai-justin`
- `/debate 4 rounds with grumpy, ai-augustin, chaic3`

## Protocol

Follow these steps exactly. Use the Bash tool for all tmux operations.

### Step 1: Parse and Validate

1. Parse `$ARGUMENTS` to extract:
   - **Rounds**: look for `--rounds N`, or `N rounds`, or a number followed by "rounds". Default to 2.
   - **Personas**: look for `--with name1,name2`, or extract persona names mentioned in natural language. Match against available files in `~/.claude/personas/` (strip `ai-` prefix if needed, e.g., "justin" matches `ai-justin.md`).
2. For each persona name, read `~/.claude/personas/<name>.md` and parse the YAML frontmatter:
   - `type`: "persona" or "agent"
   - `agent`: (agents only) the `--agent` value
   - Body text below the frontmatter is the persona prompt (personas only)
3. If any persona file is missing, tell the user and list available personas from `ls ~/.claude/personas/`.

### Step 2: Setup

1. Generate a debate ID: `debate-$(date +%s)`
2. Create working directory: `mkdir -p /tmp/swarm/<debate-id>`
3. Record the master pane ID: `tmux display-message -p '#{pane_id}'`
4. Choose a short topic name based on what you've been discussing (e.g., "migration-plan", "fastcheck-redesign")

### Step 3: Write the Plan

Based on the conversation so far, write a clear, structured summary of the plan to `/tmp/swarm/<debate-id>/plan-v1.md`. This is what reviewers will critique. Include enough context for an independent reviewer to understand the plan without prior conversation.

### Step 4: Spawn Reviewer Panes with Initial Prompt

For Round 1, pass the initial prompt directly to `claude` as a CLI argument via `swarm-spawn --prompt-file` — no need to wait for session initialization or use tmux send-keys.

First, construct the Round 1 prompt for each reviewer and write it to `/tmp/swarm/<debate-id>/prompt-round-1-<persona>.txt`.

**Round 1 prompt (persona type):**
```
# Debate Review — Round 1

## Your Persona
[body from persona .md file]

## Protocol
You are participating in a structured debate review. Review the plan below through your persona's lens. Be specific: what would you change, what concerns do you have, what works well.

IMPORTANT: You have a TIME LIMIT of 3 minutes to complete your review and save the file. Be concise and focused — prioritize your top concerns. The orchestrator will time out after 3.5 minutes.

At the END of your review, include a verdict line in this exact format:
VERDICT: <COLOR>
Where <COLOR> is one of:
- GREEN — I approve this plan as-is, no changes needed
- YELLOW — minor concerns, close to approval
- ORANGE — significant concerns that need addressing
- RED — major issues, substantial rework needed

CRITICAL: When you finish your review, you MUST save your COMPLETE response (including the VERDICT line) to this exact path using the Write tool:
/tmp/swarm/<debate-id>/round-1-<persona-name>.md

Then run this command: swarm-respond /tmp/swarm/<debate-id>/round-1-<persona-name>.md

Do NOT skip the Write or swarm-respond steps. The orchestrator is waiting for this file.

## The Plan
[contents of /tmp/swarm/<debate-id>/plan-v1.md]
```

**Round 1 prompt (agent type):** Same but without "Your Persona" section.

Then spawn all reviewers using `swarm-spawn` (WITHOUT `--wait-boot` — spawn all in parallel first):

```bash
# Phase 1: Spawn all reviewers (fast, all boot in parallel)
for persona in <persona1> <persona2> ...; do
    args=(--id "<debate-id>" --name "$persona" --cwd "$HOME/gdrive" --prompt-file "/tmp/swarm/<debate-id>/prompt-round-1-${persona}.txt")
    [ "$type" = "agent" ] && args+=(--agent "$agent_name")
    pane_id=$(swarm-spawn "${args[@]}")
    echo "  $persona → $pane_id"
done

# Phase 2: Wait for all to finish booting (handshake)
for persona in <persona1> <persona2> ...; do
    swarm-wait-boot --id "<debate-id>" --name "$persona"
done
```

**IMPORTANT:** Do NOT use `--wait-boot` when spawning multiple sessions — it blocks, making spawns sequential. Spawn all first (parallel boot), then `swarm-wait-boot` for each.

### Step 5: Wait for Responses

Use `swarm-wait` for each reviewer:

```bash
for persona in <persona1> <persona2> ...; do
    swarm-wait --id "<debate-id>" --name "$persona" --timeout 300
done
```

If a reviewer times out, warn the user and offer to wait longer or skip. Note: Verifier consistently takes 3-5 minutes due to actual code verification — this is expected.

Alternatively, use `swarm-poll` for waiting on all at once:
```bash
swarm-poll --id "<debate-id>" round-1-grumpy.md round-1-ai-justin.md ...
```

### Step 6: Read Responses, Summarize, and Display Convergence Matrix

After each round:

1. Extract verdicts: `debate-verdicts <debate-id> round-1` — outputs `<persona> <COLOR>` per line.
2. Present a **concise one-line summary** per reviewer in your conversation response — NOT the full text:

```
**AI-Justin (YELLOW):** Drop read-as-arrive, fix Enter key, add rollout criteria.
**Grumpy (ORANGE):** Scuba schema missing, no line-splitting, cursor type inconsistent.
```

Rules for summaries:
- Extract only concerns that would change the plan. Drop stylistic/editorial feedback.
- One line per reviewer: persona name, verdict, key actionable points.
- Full text stays in the file — the user can read it in the reviewer pane or via `nvc`.

3. Display the convergence matrix as a **markdown emoji table in your conversation response**. Do NOT use Bash or ANSI escape codes — those get collapsed by Claude Code's TUI.

```
### Convergence Matrix

|              | R1  | R2  | R3  |
|--------------|-----|-----|-----|
| AI-Justin    | 🟡  | 🟢  | 🟢 (skip) |
| AI-Augustin  | 🟠  | 🟢  | 🟢 (skip) |
| Grumpy       | 🔴  | 🟡  | 🟢  |
```

Matrix rules:
- Columns added dynamically per round
- Emoji: 🟢 GREEN, 🟡 YELLOW, 🟠 ORANGE, 🔴 RED, ⏱️ TIMEOUT
- Skipped reviewers (GREEN in previous round): show `🟢 (skip)`

### Step 7: Early Stopping Check

After displaying the convergence matrix, check if ALL reviewers are GREEN for the current round. If so:

1. Announce: "All reviewers approve — stopping early after round N (of M requested)."
2. Skip remaining rounds and go directly to Step 10 (Final Summary).

If not all green but some are, continue to the next round.

### Step 8: Master Revises (You)

After presenting all critiques and the matrix:
- Address each reviewer's concerns
- Defend decisions you disagree with, explaining why
- Incorporate valid feedback into the plan
- Write the revised plan to `/tmp/swarm/<debate-id>/plan-v{N+1}.md`

### Step 9: Subsequent Rounds (2 to N)

For each remaining round:

#### 9a. Construct the Round N Prompt

```
# Debate Review — Round <N>

## What Changed
The plan author revised the plan based on all feedback from round <N-1>.

### Author's Revised Plan and Response
[master's response to THIS reviewer's specific critique + brief summary of changes]

### What Other Reviewers Said (Round <N-1>)
[2-3 bullet summary per other reviewer — key points only, not full text]

## Revised Plan
[contents of plan-v<N>.md]

## Your Task
Review the revised plan. Have your previous concerns been addressed? Any new issues?

IMPORTANT: You have a TIME LIMIT of 3 minutes. Be concise — focus on whether your concerns were addressed.

At the END of your review, include a verdict line:
VERDICT: <COLOR>  (GREEN / YELLOW / ORANGE / RED)

CRITICAL: Save your COMPLETE response to: /tmp/swarm/<debate-id>/round-<N>-<persona-name>.md
Then run: swarm-respond /tmp/swarm/<debate-id>/round-<N>-<persona-name>.md
```

#### 9b. Send the Prompt via swarm-send

For rounds 2+, the session is already running. **Only send to reviewers who gave YELLOW/ORANGE/RED in the previous round.** Skip GREEN reviewers — they've approved. Exception: if the revision is substantial (>50% of the plan changed), re-engage all reviewers.

Write each round prompt to a file, then send:
```bash
swarm-send /tmp/swarm/<debate-id>/prompt-round-<N>-<persona>.txt --id "<debate-id>" --name "<persona>"
```

#### 9c. Wait, Read, Display Matrix, Check Early Stop, Revise

Same as Steps 5-8. Write revised plan to `plan-v{N+1}.md`.

For waiting, use `swarm-wait` per reviewer or `swarm-poll` for multi-wait. Clean up `.signaled-<persona>` and response files between rounds:
```bash
rm -f /tmp/swarm/<debate-id>/round-<N>-<persona>.md /tmp/swarm/<debate-id>/.signaled-<persona>
```

### Step 10: Write Final Plan

Write the final revised plan to `/tmp/swarm/<debate-id>/plan-v<last>.md` (sequential numbering — e.g., `plan-v3.md` after 2 rounds of revision). This must be a complete, standalone document — not a delta.

**Always include a `## TL;DR — What the debate changed` section at the top** (right after the title). This is a bullet list of every change the debate introduced — concise, scannable, no context needed. The user already knows the plan; they want to see what's different. Example:

```
## TL;DR — What the debate changed
- Added short-term relief section for rate limiting
- IloFW simplified: skip dual-call, just migrate consumers
- CPER explicitly frozen until OOBit API validates
- Shadow at 1-5%, not 100%
- Ramp slowed to 3 days/phase with go/no-go criteria
```

### Step 11: Final Summary

After all rounds are complete (or early stop):

1. Write `debate-summary.md` to `/tmp/swarm/<debate-id>/` containing:
   - Final convergence matrix (text version)
   - Key changes from v1 (table format)
   - Resolved disagreements (checklist)
   - Accepted tradeoffs
2. Display the final convergence matrix as a markdown emoji table in your conversation response
3. **Close reviewer panes FIRST** (unless `--keep` flag was passed) — this must happen before opening nvim so the pane split is clean (equal halves):
   ```bash
   swarm-close --id "<debate-id>" --kill
   ```
4. **Then** open both files in the user's nvim via `nvc`:
   ```bash
   nvc /tmp/swarm/<debate-id>/debate-summary.md
   nvc /tmp/swarm/<debate-id>/plan-v<last>.md
   ```
5. Present a concise summary in conversation — include the numbered list of changes so the user can cherry-pick
6. **Do NOT update the original project document.** The debated plan stays in `/tmp/swarm/<debate-id>/`. Ask the user what to accept:
   - "Accept all" → copy the final plan to the project doc
   - "Accept 1, 3, 5 but not 2, 4" → apply only the selected changes
   - "Let me review first" → wait
   The debate produces recommendations. The user decides what ships. All-GREEN convergence is NOT automatic approval.

## Rules

- Always re-select the master pane after tmux operations: `tmux select-pane -t <master-pane-id>`
- The master pane must stay in position 0 (top-left) after tiling
- Timeout is 300 seconds per reviewer per round — if exceeded, warn the user and offer to wait or skip
- Check reviewer panes are alive before sending (`tmux list-panes -a`), skip any that crashed
- Keep the plan summary factual and structured — reviewers need concrete details to critique
- When revising, be specific about what changed and why
- Use atomic file writes where possible: write to `.tmp`, then `mv` to final path
- Between rounds, summarize prior critiques rather than including full text (context management)
- Each reviewer should see: revised plan + master's targeted response to THEIR critique + brief summary of other reviewers' key points
- Early stop: if all reviewers are GREEN after any round, stop the debate immediately
- All reviewer prompts MUST include `swarm-respond` instructions — this is how the master gets notified
