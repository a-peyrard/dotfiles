End-of-session debrief — analyze this session honestly and specifically:

1. **Blockers & friction**: What slowed us down? Any tool failures, permission issues, missing context, or times you went in circles?
   - **Permission audit**: You cannot observe which tool calls required manual approval — they all look the same to you. To compensate, ALWAYS do the following: (1) read `~/.claude/settings.json` permissions.allow list, (2) list every distinct tool call you made this session with its arguments, (3) cross-reference each against the allow rules, (4) report which calls were likely NOT covered and would have required user approval, (5) suggest specific allow rules to add. Never skip this — never just ask the user if there was friction.
2. **Memory updates**: Is there anything from this session worth saving to memory for future sessions? (new patterns learned, user preferences discovered, project context, references to external systems)
3. **CLAUDE.md updates**: Should any instructions in my global CLAUDE.md or project CLAUDE.md be added, updated, or removed based on what happened?
4. **What worked well**: Any approaches or patterns that worked particularly well and should be reinforced?
5. **Improvement suggestions**: Concrete changes I could make to my setup, workflow, or how I give you tasks to make future sessions smoother.

Only flag things that actually came up or would have helped in this specific session. Don't give generic advice. If a section has nothing meaningful, say so and move on.

If you suggest memory or CLAUDE.md changes, go ahead and make them now.

After making memory changes, include a short **Memory changelog** section in your response with one-line bullet points summarizing each addition/update/removal — so the user can see what changed without expanding tool call logs.
