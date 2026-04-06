---
name: test
description: Write tests for the currently selected or described code. Covers happy path, edge cases, and error paths. Works for any language/framework.
---

# Test Skill

## Step 1 — Read the target code
Read the function/module to be tested. Understand:
- What are the inputs and outputs?
- What are the side effects? (DB writes, HTTP calls, file I/O)
- What can go wrong?

Do NOT read unrelated files.

## Step 2 — Identify test cases
For every function, write tests for:

1. **Happy path** — normal input, expected output
2. **Edge cases** — empty input, zero, null, very large, boundary values
3. **Error path** — invalid input, missing dependency, external failure

Rule: if a bug would break prod, write a test for it.

## Step 3 — Mock external dependencies
- HTTP calls → mock at the HTTP layer (not the service layer)
- Database → use in-memory DB or transactions that roll back
- Time → inject a clock/timestamp, never use `Date.now()` directly
- File I/O → use temp dir, clean up after each test

## Step 4 — Write the tests

### Naming pattern
`test_[functionName]_[scenario]_[expectedOutcome]`
or for BDD: `it("should [outcome] when [scenario]")`

### Structure (AAA)
```
// Arrange — set up inputs and mocks
// Act — call the function
// Assert — verify the output
```

### One assertion per test (preferred)
Tests that check one thing fail clearly. Tests that check many things fail confusingly.

## Step 5 — Verify completeness
- [ ] All happy paths covered
- [ ] All documented edge cases covered
- [ ] All error/exception paths covered
- [ ] No test relies on state from another test
- [ ] Tests are deterministic (no sleep, no random, no real network)
