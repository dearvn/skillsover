# Getting Started with SkillsOver

> For developers who are new to Claude Code and have never used skills before.

---

## Step 1 — What is Claude Code?

Claude Code is a CLI tool made by Anthropic that lets you run Claude AI directly in your terminal, inside your project.

Install it:
```bash
npm install -g @anthropic-ai/claude-code
```

Then run it inside any project folder:
```bash
cd your-project
claude
```

---

## Step 2 — What is a "skill"?

A skill is a `.md` file that tells Claude **exactly how to do a specific task**.

Without a skill, you'd type something like:
> "hey can you help me write a commit message for my changes?"

Claude then has to figure out: what format? what convention? which files to read? This wastes time and tokens.

With a skill, you just type:
```
/commit
```

Claude already knows:
- Read `git diff --staged`
- Use conventional commit format (`feat`, `fix`, `refactor`...)
- Write under 72 chars
- Create the commit

**A skill = a pre-written instruction set for Claude.**

---

## Step 3 — Where do skills live?

Skills are `.md` files stored in:
```
~/.claude/skills/
```

That's a folder in your home directory. Claude Code automatically loads every `.md` file in that folder as a `/command`.

So if you have `~/.claude/skills/commit.md` → you can type `/commit` in Claude Code.

---

## Step 4 — Install SkillsOver

Run this one command in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/dearvn/skillsover/main/install.sh | bash
```

This will:
1. Create `~/.claude/skills/` if it doesn't exist
2. Download all 9 skills into that folder
3. Print a confirmation

---

## Step 5 — Use a skill

Open any project in your terminal and start Claude Code:

```bash
cd your-project
claude
```

Now try your first skill. Stage some changes first:

```bash
git add .
```

Then inside Claude Code, type:
```
/commit
```

Claude will read your diff and create a proper commit message automatically.

---

## What skills are included?

| Command | What it does |
|---|---|
| `/commit` | Reads staged diff → writes semantic commit message → commits |
| `/review` | Reviews your branch diff vs main → finds bugs and security issues |
| `/debug` | Systematic 4-step root cause analysis for any bug or error |
| `/test` | Reads a function → writes unit tests with edge cases |
| `/explain` | Explains any code in plain language |
| `/security` | Audits code for OWASP Top 10 vulnerabilities |
| `/perf` | Profiles and identifies performance bottlenecks |
| `/docs` | Generates JSDoc / docstrings / godoc for your code |
| `/refactor` | Safely refactors code without changing behavior |

---

## Real example: fixing a bug with /debug

You have an error in your app:
```
TypeError: Cannot read properties of undefined (reading 'items')
    at OrderService.js:112
```

Instead of digging through the code yourself, open Claude Code and type:
```
/debug TypeError: Cannot read properties of undefined (reading 'items') at OrderService.js:112
```

Claude will:
1. Ask for reproduction steps if needed
2. Read `OrderService.js` at line 112
3. Trace the root cause
4. Suggest a specific fix

---

## FAQ

**Do I need to set up skills per project?**  
No. Skills live in `~/.claude/skills/` which is global. Once installed, they work in every project.

**Does this work with any programming language?**  
Yes. All 9 skills are language-agnostic. `/test` works whether you use pytest, Jest, or Go testing.

**What if I want to see what a skill does before using it?**  
Read the file directly:
```bash
cat ~/.claude/skills/commit.md
```

**Can I edit a skill to match my team's conventions?**  
Yes. Edit the `.md` file however you want. It's just text.

**Is this free?**  
Claude Code requires an Anthropic API key or Claude Pro/Max subscription. The skills themselves are free and open source.

---

## Next step

Once you're comfortable with the basics, read [WHY.md](WHY.md) to understand how SkillsOver compares to larger alternatives and when each approach makes sense.
