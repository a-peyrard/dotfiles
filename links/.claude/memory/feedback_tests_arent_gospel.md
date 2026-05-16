---
name: tests-arent-gospel
description: Don't treat passing tests as proof of correctness — challenge whether the tests themselves are testing the right thing
metadata:
  type: feedback
---

Tests passing doesn't mean the design is correct. Before preserving existing behavior just because "the tests pass," ask: are the tests testing intentional behavior, or a side-effect?

**Why:** During the ANR thrift-py migration, the agent wanted to keep string dispatch (duck typing) because mutable/immutable thrift tests passed with it. But those tests were testing a side-effect of string dispatch, not intentional multi-flavor support. The function was designed for py-deprecated only. Keeping the loose dispatch would have hidden a real type gap. See [[no-clocking]] for the session where this came up.

**How to apply:** When tests pass but the approach feels wrong, investigate the callers and the test intent. Ask "is this function really designed to handle this case, or do the tests just happen to pass?" Prefer exposing type gaps (the whole point of adding types) over preserving duck-typed shortcuts. The agent optimizes for "tests pass" — the human supplies "design is correct."
