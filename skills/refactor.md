---
name: refactor
description: Safe refactor — improve code structure without changing behavior. Write characterization tests first, then refactor. Never change logic and structure at the same time.
allowed-tools: [Read, Edit, Bash]
---

# Refactor Skill

**Rule #1: Never change logic and structure at the same time.**
Each commit should do one: either refactor (same behavior) OR change logic (new behavior). Never both.

**Rule #2: Tests first. Always.**
If tests don't exist, write characterization tests before touching the code.

## Step 1 — Understand what the code does now
Read the target code. Do NOT assume it's wrong — it might be correct despite looking ugly.
Questions:
- What inputs does it accept?
- What outputs does it produce?
- What side effects does it have?
- Are there edge cases that seem intentional (even if undocumented)?

## Step 2 — Write characterization tests (if not present)
Characterization tests capture the current behavior, not the desired behavior.

```python
# Capture actual output, even if it seems wrong
result = my_function(edge_input)
assert result == "weird_output"  # this IS the current behavior
```

Run them. They must all pass BEFORE you start refactoring.

## Step 3 — Choose ONE refactoring type per commit

### Extract function
Move a logical block into its own named function.
When: function is >40 lines, or a block has a clear single purpose.

### Rename for clarity
Rename variables/functions to better represent what they actually do.
When: name misleads or is too generic (data, temp, result, x).

### Remove duplication
Extract repeated logic into a shared function.
When: same code appears 3+ times (rule of three).

### Simplify condition
Replace complex boolean logic with named predicates.
```python
# Before
if user.role == "admin" and user.active and not user.suspended:
# After
def is_admin_active(user): return user.role == "admin" and user.active and not user.suspended
if is_admin_active(user):
```

### Break up long function
Split into smaller functions with single responsibilities.
When: function does more than one thing (AND in its name is a code smell).

## Step 4 — Run tests after every change
After each small change, run the characterization tests. They must still pass.

If a test breaks → undo the last change, don't push through.

## Step 5 — Output
```
Refactoring type: [which type from Step 3]
Files changed: [list]
Behavior change: None (or describe any intentional cleanup)
Tests: [pass/fail count before and after]
```

---

## Limitations

- **Requires:** existing tests or time to write characterization tests first — skipping this violates Rule #2
- **One type per run:** multi-step refactors require multiple invocations
- **Not for:** architectural rewrites, external interface/API changes, or cross-language refactoring — those change observable behavior

---

## Status

End every run with one of:

- **DONE** — refactor complete, all characterization tests still pass, behavior unchanged
- **DONE_WITH_CONCERNS** — refactor complete but a potential behavior change was noted — review required
- **BLOCKED** — characterization tests fail before refactor even starts (existing code is broken)
- **NEEDS_CONTEXT** — target code or refactoring goal not specified
