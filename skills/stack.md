---
name: stack
description: Pick the right language and framework for a new project. Asks what you're building and outputs ONE stack decision — no comparisons, no "it depends". Use before /scaffold.
allowed-tools: [Read]
---

# Stack Skill

**Rule #1: One stack. Never list alternatives.**
Pick the best fit. Do not say "you could also use X". Do not compare.

**Rule #2: Decision is based on constraints, not trends.**
The right stack is the one that ships fastest given the team's existing knowledge and the project's core requirement.

**Rule #3: Stop after the decision.**
Do not explain the ecosystem. Do not list libraries. Output the stack + reason in 2 sentences. Done.

---

## Step 1 — Ask exactly 4 questions

Ask all 4 in one message:

```
1. What does this project do? (describe in 1-2 sentences)
2. Who uses it? (end users / internal tool / other developers / automated system)
3. Team's existing languages? (e.g. "we know Python", "everyone knows JS", "starting fresh")
4. What is the #1 priority? (ship fast / scale to millions / easy maintenance / strict correctness)
```

---

## Step 2 — Apply decision rules

Use this matrix. Pick the first match:

### If team already knows a language → use it
No stack switch is worth the learning cost for a side project or startup.
Override: only switch if the language is fundamentally wrong for the problem (e.g. PHP for real-time ML inference).

### By project type:

**REST API / Backend service:**
| Priority | Stack |
|----------|-------|
| Ship fast | Python + FastAPI |
| Scale / performance | Go + stdlib or Gin |
| Team knows JS | Node + Express or Fastify |
| Strict correctness / finance | Rust or Go |
| Enterprise / existing Java team | Spring Boot |

**Fullstack web app:**
| Priority | Stack |
|----------|-------|
| Ship fast, solo | Next.js (React + API routes) |
| Separate frontend/backend teams | FastAPI + React |
| SEO critical | Next.js |
| Internal dashboard | React + Vite + FastAPI |

**Mobile app:**
| Priority | Stack |
|----------|-------|
| Both iOS + Android | React Native |
| Performance critical | Flutter |
| iOS only | Swift |
| Android only | Kotlin |

**CLI tool:**
| Priority | Stack |
|----------|-------|
| Any | Go (single binary, fast) |
| Team knows Python | Python + Click or Typer |
| Needs JS ecosystem | Node |

**Data pipeline / ML:**
| Priority | Stack |
|----------|-------|
| Any | Python (non-negotiable — ecosystem wins) |

**Real-time / WebSocket heavy:**
| Priority | Stack |
|----------|-------|
| Any | Go or Node (FastAPI works for moderate load) |

**Browser extension:**
| Priority | Stack |
|----------|-------|
| Any | TypeScript + Vite |

**Background worker / queue consumer:**
| Priority | Stack |
|----------|-------|
| Python team | Python + Celery or ARQ |
| Go team | Go |
| Node team | Node + BullMQ |

---

## Step 3 — Output

Exactly this format. Nothing else.

```
## Stack decision

**Language:** [language]
**Framework:** [framework]
**Why:** [1 sentence — the constraint that decided it]

## Next step
Run: /scaffold
Tell it: "[stack from above] — [project type from question 1]"
```

---

## What to never output

- "Alternatively, you could use..."
- "X is also a great choice if..."
- "It depends on..."
- Pros/cons lists
- Ecosystem comparisons
- Performance benchmarks
- Trend analysis ("X is popular right now")
- More than 1 stack option

---

## Status

End every run with one of:

- **DONE** — one stack decided, `/scaffold` next step printed
- **BLOCKED** — team's existing language unknown and project type is ambiguous
- **NEEDS_CONTEXT** — waiting for answers to the 4 questions from Step 1
