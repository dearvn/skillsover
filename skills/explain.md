---
name: explain
description: Explain selected code clearly and concisely. Adapts depth to what's actually complex — skips obvious parts. Great for onboarding or understanding unfamiliar code.
---

# Explain Skill

## Step 1 — Read the code
Read only the selected code or the file/function specified.

## Step 2 — Identify the audience
Based on context clues in the conversation:
- **Beginner** → explain concepts, avoid jargon, use analogies
- **Experienced in other language** → focus on language-specific patterns
- **Expert in this codebase** → focus on business logic, not language syntax

Default to intermediate level if unknown.

## Step 3 — Explain in this order

### What it does (1-2 sentences)
The job of this code in plain language. What problem does it solve?

### How it works (structured breakdown)
Walk through the logic. For each non-obvious part:
- WHY is it done this way? (not just what it does)
- What would break if this was removed?

Skip lines that are self-explanatory from their name.

### Key concepts (if any)
Only include if the code uses patterns/algorithms that aren't obvious:
- Design patterns used (and why)
- Non-obvious data structures
- External system interactions

### Gotchas / non-obvious behavior
What would surprise a developer reading this for the first time?
- Side effects
- Hidden dependencies
- Performance implications
- Known limitations

## Rules
- Never say "this code does X" and then repeat the code — add meaning
- Prefer analogies over jargon for complex concepts
- If something IS obvious, skip it — don't waste tokens explaining `i++`
- If you don't understand a section, say so clearly rather than guessing
