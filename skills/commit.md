---
name: commit
description: Generate a semantic commit message from staged diff and create the commit. Works for any project, any language.
---

# Commit Skill

Run these steps in order:

## Step 1 — Read the diff
```bash
git diff --staged
git status --short
```

## Step 2 — Determine type
Choose ONE based on the primary change:
- `feat` — new capability or endpoint
- `fix` — bug fix (something was broken)
- `refactor` — same behavior, different code
- `perf` — measurable speed improvement
- `test` — adding or fixing tests
- `docs` — documentation only
- `chore` — config, deps, build tooling
- `style` — formatting, no logic change

## Step 3 — Write the message
Format: `type(scope): imperative summary under 72 chars`

Rules:
- Imperative mood: "add X", not "added X" or "adds X"
- Scope = the module/feature area changed (optional but preferred)
- No period at end of subject line
- If breaking change: add `!` after type, e.g. `feat!: ...`

## Step 4 — Create the commit
```bash
git commit -m "$(cat <<'EOF'
type(scope): summary

Optional body explaining WHY (not what — the diff shows that).

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

## Examples
```
feat(auth): add refresh token rotation
fix(api): return 404 instead of 500 for missing resource
refactor(db): replace raw SQL with ORM query in UserRepo
perf(cache): cache dashboard stats with 60s TTL
test(orders): add edge case for zero-quantity order
```

## Do NOT commit
- `.env` files or anything with secrets
- `node_modules/`, `__pycache__/`, build artifacts
- Files not related to the change
