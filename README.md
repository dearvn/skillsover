# SkillsOver

[![GitHub stars](https://img.shields.io/github/stars/dearvn/skillsover?style=flat-square)](https://github.com/dearvn/skillsover/stargazers)
[![License](https://img.shields.io/github/license/dearvn/skillsover?style=flat-square)](LICENSE)

**AI coding skills that cut your token bill by 87%. Works with Claude Code, Cursor, Cline, Copilot.**

English | [Tiếng Việt](README.vi.md) | [中文](README.zh.md)

```bash
curl -fsSL https://raw.githubusercontent.com/dearvn/skillsover/main/install.sh | bash
```

```bash
npx skillsadd dearvn/skillsover   # alternative
```

Then just type `/commit`, `/debug`, `/review` — and stop paying for Claude's preamble.

![SkillsOver demo](demo.gif)

---

## The problem

```
WITHOUT skills:

  You: "fix the bug in OrderService"
         │
         ├─ Claude reads 6 files "for context"   +4,800 tokens
         ├─ Claude asks 2 clarifying questions   +  800 tokens
         ├─ Claude explains what it's doing      +  300 tokens
         └─ Claude summarizes what it did        +  200 tokens
                                                 ───────────
                                          Total:  ~6,100 tokens  ≈ $0.040


WITH /debug:

  You: /debug [paste error]
         │
         ├─ Claude reads 1 file at specific line  + 800 tokens
         └─ Claude outputs: root cause + fix      + 200 tokens
                                                  ──────────
                                           Total:  ~1,000 tokens  ≈ $0.005

                                                        84% less  ↓
```

---

## Supported tools

| Tool | Install location | Invocation |
|---|---|---|
| **Claude Code** | `~/.claude/skills/` | `/commit`, `/debug`... |
| **Cursor** | `.cursor/rules/` | `@commit`, `@debug`... |
| **Cline** | `.clinerules/` | mention in chat |
| **Copilot** | `.github/` | mention in chat |

```bash
# Claude Code (default)
curl -fsSL https://raw.githubusercontent.com/dearvn/skillsover/main/install.sh | bash

# Cursor
curl -fsSL https://raw.githubusercontent.com/dearvn/skillsover/main/install.sh | bash --tool cursor

# Cline
curl -fsSL https://raw.githubusercontent.com/dearvn/skillsover/main/install.sh | bash --tool cline
```

---

## Token savings

| Task | Without skill | With skill | Saved |
|---|---|---|---|
| Write commit message | ~$0.0138 | ~$0.0018 | **87%** |
| Debug a bug | ~$0.0400 | ~$0.0051 | **87%** |
| Monthly (5 sessions/day) | ~$50 | ~$7 | **~$43/mo** |

Check your own savings: `bash <(curl -fsSL https://raw.githubusercontent.com/dearvn/skillsover/main/scripts/gain.sh)`

---

## Comparison

### vs [everything-claude-code](https://github.com/affaan-m/everything-claude-code)

```
everything-claude-code:  156 skills + 36 agents + 79 commands
                         Full AI development harness
                         Multi-step install (script + manual rules copy)
                         Best for: large teams, complex multi-agent workflows

SkillsOver:              10 universal skills
                         Lean workflow control, any language/stack
                         One curl command
                         Best for: solo devs and small teams who want Claude
                                   to just work without configuring a system
```

If you need agent orchestration and language-specific rules → use ECC.  
If you want minimal, token-efficient skills that work everywhere → use SkillsOver.

→ [Full comparison](WHY.md)

---

## Works great with RTK

[RTK](https://github.com/rtk-ai/rtk) and SkillsOver solve different problems — use both for maximum savings.

```
RTK:        filters command OUTPUT before Claude reads it    → less input tokens
SkillsOver: controls Claude's WORKFLOW and reading scope    → less wasted tokens

Together:   ~90%+ token reduction on common dev tasks
```

| | RTK | SkillsOver |
|---|---|---|
| What it does | Intercepts `git log`, `cargo test` output and trims it | Defines how Claude approaches commit, debug, review tasks |
| Behavior change | Zero — works automatically | Type `/skill-name` to invoke |
| Install | `rtk init -g` | one curl command |

They complement each other. RTK handles output filtering. SkillsOver handles workflow control.

---

## Skills

```
/commit    Semantic commit from staged diff — no back-and-forth
/review    Pre-PR review: security P0, logic P1, perf P2
/debug     4-phase root cause — never guesses
/test      Tests for any framework (pytest, Jest, Go, RSpec...)
/explain   What it does → how → gotchas — skips the obvious
/security  OWASP Top 10 audit, read-only, findings only
/perf      Profile first, optimize the actual hotspot
/docs      JSDoc / docstrings / godoc — documents WHY not WHAT
/refactor  Safe refactor with characterization tests first
/safe-edit Edit without breaking behavior
```

---

## Docs

- [GETTING_STARTED.md](GETTING_STARTED.md) — zero to first skill in 5 minutes
- [TOKEN_COST.md](TOKEN_COST.md) — exact numbers on why bills spike and how skills fix it
- [WHY.md](WHY.md) — how this compares to alternatives

---

## Skills Reference

### `/commit` — Semantic Commit from Diff
**When to use**: After staging changes, instead of writing commit messages manually.

**What it does**:
1. Reads `git diff --staged` and `git status`
2. Determines the commit type (feat/fix/refactor/perf/test/docs/chore/style)
3. Writes an imperative summary under 72 chars
4. Creates the commit with proper format

**Example output**:
```
feat(auth): add refresh token rotation
fix(api): return 404 instead of 500 for missing resource
perf(cache): cache dashboard stats with 60s TTL
```

**Token cost**: ~300 tokens (reads only staged diff)
**Time saved**: 2-5 minutes per commit, eliminates bad commit messages

---

### `/review` — Pre-PR Code Review
**When to use**: Before opening a PR, or when reviewing someone else's PR.

**What it does**:
1. Reads the diff between current branch and main
2. Checks OWASP security issues (P0 — block PR)
3. Checks logic and correctness bugs (P1 — block PR)
4. Checks performance issues (P2 — suggest)
5. Reports findings with file:line references only — no praise, no filler

**Example output**:
```
[P0] api/users.ts:45 — User input passed directly to SQL query string
Suggestion: Use parameterized query or ORM

[P1] services/order.ts:112 — Missing null check before .items.length
Suggestion: Add guard: if (!order?.items) return []
```

**Token cost**: ~800-1500 tokens (reads diff + affected files)
**Time saved**: Catches bugs before code review cycle (saves 1-3 review rounds)

---

### `/debug` — Systematic Root Cause Analysis
**When to use**: Any time there's a bug, error, crash, or unexpected behavior.

**What it does**:
4-phase process — never guesses:
1. **REPRODUCE** — get exact error text, reproduction steps
2. **LOCATE** — trace stack to specific file:line
3. **HYPOTHESIZE** — form ONE hypothesis, test it
4. **FIX** — fix root cause only, no surrounding refactor

**Example output**:
```
Root cause: Redis connection not re-established after EAGAIN error
Evidence: market_pressure_service.py:847 — ctx->err not cleared after error
Fix: Add ctx->err = 0 and reconnect logic after EAGAIN returns
Risk: Must test reconnection under load — single-threaded Redis ctx
```

**Token cost**: ~500-1000 tokens (reads only stack trace files)
**Time saved**: Eliminates 30-60 min debug sessions by forcing systematic process

---

### `/test` — Write Tests for Existing Code
**When to use**: After writing a function, or to add missing test coverage.

**What it does**:
1. Reads target function/module
2. Identifies: happy path, edge cases, error paths
3. Mocks external dependencies (HTTP, DB, time, filesystem)
4. Writes tests with AAA structure (Arrange/Act/Assert)
5. One assertion per test

**Supports**: pytest, Jest, xUnit, Go testing, RSpec — any framework

**Token cost**: ~600-1200 tokens
**Time saved**: Writing tests from scratch for a 50-line function takes 20-40 min; with /test ~5 min

---

### `/explain` — Explain Code for Understanding
**When to use**: Onboarding to a new codebase, or understanding complex logic.

**What it does**:
1. Reads the specified code
2. Identifies your knowledge level from context
3. Explains: what it does → how it works → key concepts → gotchas
4. Skips obvious parts — only explains what a reader would actually miss

**Example use**:
```
/explain this function [select code]
/explain how authentication works in this codebase
/explain the DTE routing logic in market_pressure_service.py
```

**Token cost**: ~400-800 tokens
**Best for**: Onboarding, code review understanding, debugging unfamiliar code

---

### `/security` — Quick Security Audit
**When to use**: Before deploying a new feature, or auditing an existing endpoint.

**What it does**:
Checks OWASP Top 10 — read-only, never modifies code:
- SQL injection, XSS, path traversal
- Broken auth (missing middleware, JWT validation)
- Secrets in code
- Insecure deserialization
- Logging sensitive data

**Example output**:
```
[CRITICAL] routes/upload.ts:67 — File extension not validated before save
Fix: Validate MIME type + extension whitelist, never trust Content-Type header

[HIGH] middleware/auth.ts:23 — JWT expiry not checked
Fix: Verify exp claim: if (decoded.exp < Date.now() / 1000) throw Unauthorized()
```

**Token cost**: ~600-1000 tokens
**Why it saves money**: Catching a security bug before deploy vs after breach = orders of magnitude cost difference

---

### `/perf` — Performance Analysis
**When to use**: When something is slow and you don't know why.

**What it does**:
1. **Profiles first** — provides profiling commands for your stack before reading any code
2. **Locates the hotspot** — reads ONLY the slow function identified by profiler
3. **Identifies pattern** — N+1, missing index, no pagination, blocking I/O, re-renders
4. **Suggests fix** — specific change with expected impact

**Common findings**:
- N+1 queries (loop with DB call) → batch with `IN` clause
- `SELECT *` on 50-column table → select only needed columns
- Missing index on WHERE column → add index
- React component re-renders on every keypress → memo or debounce

**Token cost**: ~500-900 tokens
**Rule**: Never skip profiling. Optimizing the wrong thing wastes everyone's time.

---

### `/docs` — Generate Inline Documentation
**When to use**: After writing a function, or before a PR to add missing docs.

**What it does**:
1. Reads the target code
2. Identifies what actually needs explaining (skips obvious)
3. Generates JSDoc / Python docstrings / C# XML docs / Go godoc
4. Documents: params, return value, throws/errors, side effects, example

**Design principle**: Documents the WHY, not the WHAT. Code already shows what.

**Supports**: TypeScript (JSDoc), Python (Google style), C# (XML), Go (godoc), Java (Javadoc)

**Token cost**: ~300-600 tokens
**Time saved**: Writing good docs for a complex function takes 10-20 min; /docs does it in seconds

---

### `/refactor` — Safe Refactor
**When to use**: When code works but is hard to read, maintain, or test.

**What it does**:
1. Reads and understands current behavior (including edge cases)
2. Writes characterization tests if none exist
3. Applies ONE refactoring type: extract function / rename / remove duplication / simplify condition / break up function
4. Runs tests after every step

**Rule**: Never change logic and structure in the same commit.

**Token cost**: ~700-1500 tokens
**Risk reduction**: Characterization tests catch accidental behavior changes — saves regression debugging time

---

## Design Principles

### Why these skills save tokens

| Without skill | With skill |
|--------------|------------|
| Claude figures out approach from scratch each time | Approach is pre-defined — Claude executes directly |
| Multiple clarification rounds | Single invocation with clear output |
| Claude reads too many files "for context" | Skill constrains scope to minimum needed files |
| Long reasoning chains printed | Skill outputs only the result format |

### Token-efficient skill design
1. **Prescribe scope** — tell Claude exactly which files to read, and which NOT to read
2. **Prescribe output format** — Claude doesn't reason about how to present; it fills the template
3. **Prescribe process** — numbered steps eliminates exploration overhead
4. **Suppress filler** — "Output findings only, no praise" cuts output tokens 40-60%

---

## Contributing

A good universal skill:
- Works for any language/framework (or clearly states its requirements)
- Reads minimum files needed — never "reads for context"
- Has a defined output format
- Saves more time than it takes to invoke

Add your skill as `skills/{name}.md` with this frontmatter:
```yaml
---
name: skill-name
description: One line — what it does and when to use it.
---
```
