---
name: debug
description: Systematic 4-phase root cause analysis. Never guess — always trace evidence to source. For bugs, errors, crashes, or unexpected behavior.
allowed-tools: [Read, Grep, Bash]
---

# Debug Skill

Never guess. Follow these 4 phases in order. Stop when you find the root cause.

## Phase 1 — REPRODUCE
Read the exact error message or describe the symptom precisely.

Questions to answer:
- What is the exact error text? (copy verbatim, not paraphrase)
- What input/action triggers it?
- Is it 100% reproducible or intermittent?
- When did it start? What changed around that time?

```bash
# Get recent logs
tail -100 logs/app.log | grep -i error
# or
journalctl -u myservice --since "1 hour ago" | grep -i error
```

## Phase 2 — LOCATE
Find where in the code the error originates.

- Read the stack trace top-to-bottom — the FIRST line is usually the root, not the last
- `grep` for the error message string in source code
- Find the specific function + line number

DO NOT read files at random. Only read files named in the stack trace.

## Phase 3 — HYPOTHESIZE
Form ONE hypothesis about the cause. Test it before forming another.

Ask:
- What assumption is this code making that might be wrong?
- What state would have to be true for this to fail?
- Can I add a single log line to confirm?

Write down your hypothesis before testing: "I think X is happening because Y."

## Phase 4 — FIX
Fix only the root cause. Do not refactor surrounding code.

Verify:
- Does the fix address the hypothesis from Phase 3?
- Does it handle the edge case, not just the test case?
- Does it introduce any new failure modes?

## Output format
```
Root cause: [one sentence]
Evidence: [file:line + what you observed]
Fix: [description of change]
Risk: [any side effects to watch]
```

---

## Status

End every run with one of:

- **DONE** — root cause identified, fix described
- **DONE_WITH_CONCERNS** — fix applied but risk noted — monitor in production
- **BLOCKED** — cannot reproduce or locate without more information (state what is needed)
- **NEEDS_CONTEXT** — error message, stack trace, or steps to reproduce not provided
