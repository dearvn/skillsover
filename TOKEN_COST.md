# Token Cost in Claude Code — What's Actually Happening

> Why your bill is higher than expected, and how to fix it.

---

## First: how Claude Code charges you

Every interaction has two sides:

| | What it is | Price (Claude Sonnet 4.5) |
|---|---|---|
| **Input tokens** | Everything Claude reads: your message + conversation history + file contents | $3 / 1M tokens |
| **Output tokens** | Everything Claude writes back | $15 / 1M tokens |

The dangerous one is **input tokens** — because they compound invisibly.

---

## The compounding problem nobody warns you about

Claude Code keeps a **context window** — a running log of everything in the session:

```
[your messages]
[Claude's responses]
[every file Claude read]
[every tool call result]
```

Every new message you send includes ALL of this history as input tokens.

**Example:**

```
Message 1: "explain this function" → Claude reads auth.ts (500 lines = ~2,000 tokens)
Message 2: "now fix the bug"       → input includes auth.ts AGAIN + message history
Message 3: "write a test for it"   → input includes auth.ts AGAIN + all previous
```

By message 3, you've paid for auth.ts **3 times** even though you only needed it once.

A 500-line file = ~2,000 tokens × 3 messages = 6,000 tokens just for one file.
At $3/1M: negligible. But multiply by 10 files, 20 messages, 5 sessions per day — it adds up fast.

---

## The 5 anti-patterns that blow up your bill

### Anti-pattern 1: Vague prompts → back-and-forth

**What happens:**
```
You:    "fix the login bug"
Claude: "Which bug? Can you describe the error?"
You:    "the one with the token"
Claude: "Which token? JWT or refresh token?"
You:    "JWT"
Claude: "What's the exact error message?"
...
```

4 clarification rounds before Claude does anything. Each round = full context retransmitted.

**Real cost:** 4 × ~1,000 tokens = 4,000 tokens wasted just figuring out what you want.

**Fix:** Give Claude the error message, file, and line number upfront.

---

### Anti-pattern 2: Claude reads files "for context"

Without constraints, Claude reads everything it thinks might be relevant:

```
You:    "fix the bug in OrderService"
Claude: reads OrderService.js        ✓ needed
        reads UserService.js         ? maybe
        reads database/schema.sql    ? maybe
        reads config/app.js          ? probably not
        reads package.json           ✗ not needed
        reads README.md              ✗ not needed
```

6 files read when 1 was needed. If each file is 200 lines (~800 tokens):
- Needed: 800 tokens
- Actual: 4,800 tokens
- **Waste: 4,000 tokens (83%)**

**Fix:** Tell Claude exactly which file and line to look at.

---

### Anti-pattern 3: Long sessions without /clear

A 2-hour session with 30 messages accumulates context like this:

```
Message 1:  500 tokens
Message 10: 5,000 tokens (history growing)
Message 20: 12,000 tokens
Message 30: 22,000 tokens
```

By message 30, you're paying 44× more per message than at message 1 — even if you're asking simple questions.

**Fix:** Use `/clear` to reset context when switching tasks. Fresh context = fresh pricing.

---

### Anti-pattern 4: Verbose output you don't need

Claude by default:
- Explains what it's about to do
- Does the thing
- Summarizes what it just did
- Asks if you need anything else

That's 3× more output tokens than the actual answer.

**Example — asking for a commit message:**
```
Without constraints (Claude's default):
"Sure! I'll analyze your git diff and create a conventional commit message.
Let me read the staged changes first...
[reads diff]
Based on the changes I can see, this appears to be a feature addition to the
authentication module. Here's a commit message that follows the conventional
commits specification:

feat(auth): add refresh token rotation

This message uses the 'feat' type because... [3 more paragraphs of explanation]

Let me know if you'd like me to adjust the scope or message!"

Output tokens: ~350

With a skill that says "output the commit command only, no explanation":
git commit -m "feat(auth): add refresh token rotation"

Output tokens: ~15
```

**Difference: 23× fewer output tokens for the same result.**

---

### Anti-pattern 5: Re-explaining context every session

Without skills, every new session starts from zero:

```
Session 1: "We use conventional commits, scope should be the module name,
            max 72 chars, imperative mood, no period at end..."
Session 2: "Remember, we use conventional commits..." (paying again)
Session 3: "Like I said before, conventional commits..." (paying again)
```

You're paying to re-establish context every single session.

**Fix:** A skill file sets the context once. Claude reads it once per invocation — no re-explaining.

---

## How SkillsOver skills reduce token cost

Each skill is engineered to constrain three things:

### 1. Read scope — exactly which files, nothing else

```markdown
## Step 1 — Read the diff
git diff --staged
git status --short
```

Claude reads 2 commands. Not the whole codebase.
Compare: without a skill, Claude might read 5-10 files "for context."

### 2. Output format — fill a template, don't reason about presentation

```markdown
## Output
type(scope): summary under 72 chars
```

Claude fills the blank. It doesn't reason about format, doesn't explain its choice, doesn't ask follow-up questions.

### 3. Filler suppression — explicit instruction to skip the noise

Skills say things like:
- "Output findings only. No praise, no summary."
- "Report file:line references only."
- "Do not explain what you're about to do. Just do it."

This cuts output tokens 40-60% compared to unconstrained Claude.

---

## Real numbers: skill vs no skill

### Scenario: write a commit message

| Step | Without skill | With /commit skill |
|---|---|---|
| Clarification rounds | 1-2 rounds (~800 tokens) | 0 rounds |
| Files read | git diff + maybe package.json, README (~2,000 tokens) | git diff only (~500 tokens) |
| Output | Explanation + message + follow-up (~350 tokens) | Command only (~15 tokens) |
| **Total input** | ~2,800 tokens | ~500 tokens |
| **Total output** | ~350 tokens | ~15 tokens |
| **Total cost** | ~$0.0138 | ~$0.0018 |
| **Savings** | — | **87% cheaper** |

### Scenario: debug a bug (10 files codebase)

| Step | Without skill | With /debug skill |
|---|---|---|
| Files read | 4-6 files "for context" (~8,000 tokens) | 1 file at specific line (~800 tokens) |
| Clarification | 2 rounds (~1,200 tokens) | 0 rounds |
| Output | Analysis + explanation + suggestions (~800 tokens) | Root cause + fix only (~200 tokens) |
| **Total input** | ~9,200 tokens | ~800 tokens |
| **Total output** | ~800 tokens | ~200 tokens |
| **Total cost** | ~$0.0400 | ~$0.0051 |
| **Savings** | — | **87% cheaper** |

---

## The math at scale

If you use Claude Code 5 sessions/day, 20 days/month:

| Usage | Without skills | With skills |
|---|---|---|
| Token cost per session | ~$0.50 | ~$0.07 |
| Monthly cost | ~$50 | ~$7 |
| **Monthly savings** | — | **~$43** |

Heavy users (10+ sessions/day): savings scale to $80-150/month.

---

## Quick wins you can apply today

**1. Use /clear between unrelated tasks**
```
/clear
```
Resets context. Next message costs as if it's the first.

**2. Give Claude the minimum it needs**
```
# Instead of:
"fix the bug in my app"

# Write:
"fix OrderService.js line 112 — null check missing before .items.length"
```

**3. Point to the exact file and line**
```
# Instead of:
"there's a performance issue somewhere in the dashboard"

# Write:
"dashboard/StatsWidget.tsx:45 — fetchStats() called on every render"
```

**4. Say "no explanation needed" explicitly**
```
"fix the typo in README line 3. output the corrected line only."
```

**5. Install skills so you never repeat context**
```bash
curl -fsSL https://raw.githubusercontent.com/dearvn/skillsover/main/install.sh | bash
```

---

## Summary

| Problem | Cause | Fix |
|---|---|---|
| Bill growing unexpectedly | Context compounds across messages | /clear between tasks |
| Claude reads too many files | No scope constraint given | Skills prescribe exact files |
| Long back-and-forth | Vague prompts | Give file:line upfront |
| Verbose output | No format constraint | Skills define output template |
| Re-explaining every session | No persistent context | Skills carry the context |

Token cost is controllable. The bill is high because Claude is doing more work than needed — not because the task is expensive.
