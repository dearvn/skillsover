---
name: review
description: Pre-PR code review checklist. Read the diff, find real bugs, security issues, and logic errors. Output actionable findings only — no praise, no nitpicks.
allowed-tools: [Bash, Read]
---

# Review Skill

## Step 1 — Read the diff
```bash
git diff main...HEAD
git log main...HEAD --oneline
```

## Step 2 — Read affected files
Read only files that were changed. Do NOT read unrelated files.

## Step 3 — Check each category

### Security (P0 — block PR)
- [ ] SQL injection: raw string interpolation in queries?
- [ ] XSS: user input rendered as HTML without escaping?
- [ ] Auth bypass: any route missing auth check?
- [ ] Secrets in code: API keys, passwords hardcoded?
- [ ] Path traversal: user-controlled file paths?

### Correctness (P1 — block PR)
- [ ] Off-by-one errors in loops/slices
- [ ] Null/undefined dereference without check
- [ ] Race condition in async code (shared state modified without lock)
- [ ] Error paths: are all exceptions caught or propagated correctly?
- [ ] Edge cases: empty list, zero, negative numbers, very large inputs

### Logic (P1 — block PR)
- [ ] Does the code do what the PR description claims?
- [ ] Are conditionals correct? (== vs ===, && vs ||)
- [ ] Are all return paths handled?

### Performance (P2 — suggest)
- [ ] N+1 query in a loop?
- [ ] Unbounded list fetched without pagination?
- [ ] Expensive operation called on every request?

### Maintainability (P3 — optional)
- [ ] Functions doing more than one thing?
- [ ] Magic numbers without named constants?

## Step 4 — Output format

For each finding:
```
[P0|P1|P2|P3] File:line — Issue description
Suggestion: what to do instead
```

Only output findings. If nothing found, say "No issues found." — never fill space with praise.

---

## Status

End every run with one of:

- **DONE** — review complete, no blocking issues found
- **DONE_WITH_CONCERNS** — P0 or P1 issues found — PR should not merge until resolved
- **BLOCKED** — no diff available or target branch not specified
- **NEEDS_CONTEXT** — PR description missing, cannot verify intent vs. implementation
