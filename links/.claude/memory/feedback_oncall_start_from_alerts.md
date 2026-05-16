---
name: oncall-start-from-alerts
description: "When triaging oncall alerts, always get the actual email/alert content first before investigating broadly"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 672e4c19-cd52-437d-b9a7-32586d719e8b
---

When the user asks to triage oncall issues, start by getting the ACTUAL alerts (email subjects, Pegasus notifications, etc.) before doing a broad sweep of all systems.

**Why:** Investigating blindly across all TC systems wasted ~10 minutes when the actual alerts pointed to specific SI conveyor pipelines and RE tasklet errors. The broad sweep produced correct findings but couldn't be mapped back to the original alerts.

**How to apply:** Use `/swarm` to ask another session to search Gmail, or ask the user to share the email content. Then work backwards from each specific alert to its root cause. Structure the triage output so each section maps to a specific email the user received.
