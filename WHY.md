# Why SkillsOver?

> Comparing with [everything-claude-code](https://github.com/affaan-m/everything-claude-code)

---

## TL;DR

**everything-claude-code** is a full harness system — powerful but complex.  
**SkillsOver** is a lean skill pack — minimal, fast, works for any stack.

If you just want Claude to commit, review, debug, and test well — SkillsOver is enough.

---

## Side-by-side comparison

| | SkillsOver | everything-claude-code |
|---|---|---|
| Skills | 9 universal | 156+ domain-specific |
| Agents | None | 36+ subagents |
| Commands | None | 79+ slash commands |
| Install | 1 curl command | Multi-step (script + manual rules copy) |
| Rules | Not required | Required, installed separately |
| Extra runtime | None | `ccg-workflow` needed for multi-agent |
| Language-specific setup | None | Required per language (Go, Java, etc.) |
| Token cost per invocation | Low (scoped reads) | Varies (larger context surface) |
| Learning curve | Read 9 skill files | Read extensive guides + config |

---

## The core difference in philosophy

**everything-claude-code** optimizes for *capability* — give Claude every possible context, agent, and command so it can handle complex multi-agent workflows.

**SkillsOver** optimizes for *efficiency* — give Claude the minimum it needs to do the task correctly, every time.

```
everything-claude-code: more tools → more power → more complexity
SkillsOver:             less scope → less token waste → faster results
```

---

## When to use SkillsOver

- You work solo or in a small team
- You switch between languages and frameworks
- You want Claude to just work without configuring a system
- You care about token costs
- You want to understand exactly what each skill does (9 files to read, not 156)

## When everything-claude-code makes sense

- You have a large team with dedicated language stacks
- You need multi-agent orchestration (`/multi-plan`, subagents)
- You want language-specific rules enforced automatically (TypeScript, Go, Java, etc.)
- You're willing to invest time in setup and maintenance

---

## Install complexity: real example

**SkillsOver:**
```bash
curl -fsSL https://raw.githubusercontent.com/dearvn/skillsover/main/install.sh | bash
```
Done. No config needed.

**everything-claude-code:**
```bash
# Step 1: install via plugin or clone + run install script
./install.sh --profile full

# Step 2: manually copy rules (plugins can't distribute these)
cp -r rules/typescript ~/.claude/rules/
cp -r rules/python ~/.claude/rules/

# Step 3: install ccg-workflow runtime if using multi-agent commands
# Step 4: configure language-specific tooling
```

---

## Token efficiency

SkillsOver skills are designed with explicit scope constraints:

- Each skill reads **only the files it needs**
- Output format is **predefined** — Claude fills a template, not a blank page
- No "read for context" — scope is prescribed per step

This matters at scale. If you run `/review` 10x per day, 500 saved tokens per invocation = 5000 tokens/day saved.

---

## Conclusion

Use **SkillsOver** if you want Claude to be a better developer tool, not a bigger system.  
Use **everything-claude-code** if you need a full AI development harness.

Both are good. They solve different problems.
