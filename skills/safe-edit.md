---
name: safe-edit
description: Safely add a feature or fix a bug in existing working code. Writes characterization tests first, makes the minimal change, verifies nothing broke. Use any time you touch code that is currently working in production.
---

# Safe Edit Skill

**Rule #1: Never touch code you were not asked to touch.**
If you notice something ugly nearby — ignore it. That is a separate task.

**Rule #2: Tests before code. Always.**
If tests don't exist, write characterization tests capturing current behavior before making any change.

**Rule #3: Minimal diff.**
The change should be as small as possible to achieve the goal. Every extra line is a risk.

---

## Step 1 — Understand the request

Identify exactly:
- **What** needs to change (feature to add, or bug to fix)
- **Which file and function** is the entry point
- **What the expected new behavior is**

If unclear, ask ONE question to clarify before proceeding. Do not guess.

---

## Step 2 — Read the target code only

Read the specific file and function mentioned. Do NOT read surrounding files unless they are directly imported by the function you are changing.

Questions to answer:
- What does this function currently do?
- What are its inputs and outputs?
- What are the edge cases it already handles?
- What will break if I change this?

---

## Step 3 — Write characterization tests

Before changing anything, write tests that capture the **current behavior** of the function.

These tests must:
- Cover the happy path
- Cover existing edge cases you found in Step 2
- Pass with the current code (unchanged)

```python
# Example — Python/pytest
def test_current_behavior_happy_path():
    result = calculate_order_total(items=[{"price": 10, "qty": 2}])
    assert result == 20.0

def test_current_behavior_empty_items():
    result = calculate_order_total(items=[])
    assert result == 0.0

def test_current_behavior_with_discount():
    result = calculate_order_total(items=[{"price": 10, "qty": 1}], discount=0.1)
    assert result == 9.0
```

Run them now. **All must pass before you write a single line of new code.**

If any test fails — stop. Report which test failed and why. Do not proceed until this is resolved.

---

## Step 4 — Write the new test first

Write a test for the new behavior you are about to implement (or the bug you are fixing).

```python
# New feature: apply free shipping when total > 100
def test_new_free_shipping_above_100():
    result = calculate_order_total(
        items=[{"price": 60, "qty": 2}],
        apply_shipping=True
    )
    assert result == 120.0  # no shipping fee added

# Bug fix: discount should not go below 0
def test_fix_negative_total_prevented():
    result = calculate_order_total(items=[{"price": 5, "qty": 1}], discount=2.0)
    assert result == 0.0  # not -5.0
```

Run it. It must **fail** (red). If it passes, the feature already exists or the bug is already fixed — stop and report.

---

## Step 5 — Make the minimal change

Write only the code needed to make the new test pass.

Rules:
- Do NOT refactor other parts of the function
- Do NOT rename variables you did not add
- Do NOT reformat code you did not change
- Do NOT add error handling for cases unrelated to this task
- Do NOT change function signatures unless explicitly required

---

## Step 6 — Run all tests

Run the full test suite for this file:
```bash
# pytest
pytest tests/test_order.py -v

# jest
npx jest OrderService.test.js

# go
go test ./... -run TestOrder

# others: run whatever test command applies
```

Expected result:
- All characterization tests from Step 3 → **still pass**
- New test from Step 4 → **now passes**

If any characterization test fails → your change broke existing behavior. Undo, diagnose, fix.

---

## Step 7 — Output

```
Change type: [feature | bugfix]
File changed: [file:line-range]
Lines added: [N]
Lines removed: [N]

Characterization tests: [N passed / N total]
New test: [passed | failed]

Behavior before: [one sentence]
Behavior after:  [one sentence]

Untouched (confirmed stable):
- [list other functions/paths you did NOT touch]
```

---

## When to stop and report instead of proceeding

- Step 3 characterization tests fail → existing tests are already broken, fix that first
- Step 2 reveals the change requires touching 3+ files → scope is larger than expected, report and get approval
- You cannot make Step 4 test pass without refactoring something else → report the dependency, do not refactor silently
