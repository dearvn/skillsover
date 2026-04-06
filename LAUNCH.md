# Launch Playbook

Copy-paste ready posts for Reddit, Hacker News, and X/Twitter.

---

## Reddit — r/ClaudeAI

**Title:**
> I analyzed why my Claude Code bill was high and built a fix — 10 skills that cut token cost 87%

**Body:**
```
I started tracking token usage per task after noticing my Claude Code bill was climbing.

Found the problem: Claude was reading 5-10 files "for context" when it only needed 1.
Back-and-forth clarifications. Verbose output explaining things I didn't ask for.

So I built SkillsOver — 10 skills that prescribe exactly what Claude should read,
how to respond, and nothing else.

Results per task:
- /commit: 2,800 → 500 input tokens (82% less)
- /debug:  9,200 → 800 input tokens (91% less)
- /review: saves 1-3 PR review rounds

Install (one command):
curl -fsSL https://raw.githubusercontent.com/dearvn/skillsover/main/install.sh | bash

Or: npx skillsadd dearvn/skillsover

Then just type /commit, /debug, /review, /safe-edit inside Claude Code.

Works for any language — Python, TypeScript, Go, PHP, whatever.

GitHub: https://github.com/dearvn/skillsover

Happy to answer questions about how skills work or how to write your own.
```

---

## Reddit — r/programming

**Title:**
> Claude Code was reading 10 files when it only needed 1 — here's why and how to fix it

**Body:**
```
Every time I asked Claude Code to "fix a bug" without context, it would read:
- The file I mentioned ✓
- Related service files ? 
- Schema files ?
- Config files ✗
- README ✗

Each file = ~800 tokens. Each session = paying for files 3x as context compounds.

The fix is constraining scope explicitly — tell Claude exactly which file:line to read,
define the output format, suppress the explanation it defaults to.

I packaged this as 10 reusable skills for Claude Code:
https://github.com/dearvn/skillsover

The token cost breakdown with real numbers is here:
https://github.com/dearvn/skillsover/blob/main/TOKEN_COST.md

Install: curl -fsSL https://raw.githubusercontent.com/dearvn/skillsover/main/install.sh | bash
```

---

## Hacker News

**Title:**
> Show HN: SkillsOver — 10 minimal Claude Code skills that cut token cost 87%

**Body:**
```
I built SkillsOver after noticing my Claude Code sessions were using 5-10x more tokens
than the actual task required.

Root cause: without explicit constraints, Claude reads files "for context," generates
verbose output, and requires clarification rounds — all of which compound across a session.

Skills are .md files in ~/.claude/skills/ that prescribe exactly:
- Which files to read (and which NOT to)
- Output format (fill a template, not a blank page)
- Process steps (no exploration overhead)

The result: /commit goes from ~2,800 to ~500 tokens. /debug from ~9,200 to ~800.

10 skills, works for any language/stack, one install command.

GitHub: https://github.com/dearvn/skillsover
Token cost breakdown: https://github.com/dearvn/skillsover/blob/main/TOKEN_COST.md
```

---

## X / Twitter (Thread)

**Tweet 1:**
```
I was spending $50/month on Claude Code.

After tracking token usage: Claude was reading 10 files when it needed 1.

Here's why — and the fix I built (thread 🧵)
```

**Tweet 2:**
```
The problem: context compounds.

Every message in a session re-sends ALL previous context:
- Your messages
- Claude's responses  
- Every file it read

By message 20 in a session, you're paying 44x more per message than message 1.
```

**Tweet 3:**
```
Worse: without constraints, Claude reads "for context."

Ask it to fix OrderService.js and it reads:
✓ OrderService.js (needed)
? UserService.js
? schema.sql  
✗ package.json
✗ README.md

5 files when you needed 1. 83% waste.
```

**Tweet 4:**
```
The fix: skills.

A skill is a .md file that tells Claude:
- Exactly which file to read
- Exactly what format to output
- No clarification, no filler, no summary

/commit: 2,800 → 500 tokens (82% less)
/debug: 9,200 → 800 tokens (91% less)
```

**Tweet 5:**
```
I packaged 10 of these as SkillsOver.

Install:
curl -fsSL https://raw.githubusercontent.com/dearvn/skillsover/main/install.sh | bash

Then type /commit, /debug, /review, /safe-edit in Claude Code.

Any language. One install. Free.

→ github.com/dearvn/skillsover
```

---

## dev.to Article Title Options

1. "Why Your Claude Code Bill Is Higher Than It Should Be (and How to Fix It)"
2. "I Cut My Claude Code Token Cost by 87% With 10 Skill Files"
3. "Claude Code Is Reading Too Many Files — Here's How to Stop It"

Use TOKEN_COST.md as the article body — it's already written.

---

## Timing

Post in this order:
1. **r/ClaudeAI** — Monday or Tuesday, 9am EST
2. Wait 24h — if upvotes > 50, then:
3. **Hacker News Show HN** — same time window
4. **X thread** — same day as HN
5. **dev.to** — any day (SEO, long tail)
6. **r/programming** — if r/ClaudeAI went well
