---
name: scaffold
description: Opinionated project scaffold for new projects. Asks 3 questions, picks ONE structure, outputs folder tree + CLAUDE.md + first files. No alternatives. No recommendation spiral. Stops when done.
---

# Scaffold Skill

**Rule #1: One decision per question. Never offer alternatives.**
If there is a better option — pick it. Do not mention what you didn't pick.

**Rule #2: Stop when the structure is defined.**
Do not suggest "you could also add...", "in the future you might want...", or "consider...". Output the structure. Stop.

**Rule #3: Opinionated defaults are correct.**
The goal is a working starting point, not a perfect architecture. Good enough now beats perfect never.

---

## Step 1 — Ask exactly 3 questions

Ask all 3 in a single message. Do not ask one at a time.

```
1. Stack: what language + framework? (e.g. Python/FastAPI, Node/Express, React, Go, etc.)
2. Type: what does this project do? (e.g. REST API, fullstack web app, CLI tool, data pipeline, background worker)
3. Scale: solo side project / small team startup / production team?
```

Wait for the answer. Do not proceed without it.

---

## Step 2 — Pick the structure

Based on the answers, select ONE folder structure. Apply these rules:

| Scale | Principle |
|-------|-----------|
| Solo side project | Flat. Minimum folders. Ship fast. |
| Small team startup | Feature-based grouping. CLAUDE.md required. |
| Production team | Domain isolation. Strict boundaries. Full CLAUDE.md with feature map. |

**Python/FastAPI — REST API:**
```
project/
  app/
    api/v1/endpoints/   ← route handlers only
    services/           ← business logic
    models/             ← SQLAlchemy models
    schemas/            ← Pydantic schemas
    repositories/       ← DB queries
    core/               ← config, deps, security
  tests/
  alembic/              ← migrations
  main.py
  pyproject.toml
  CLAUDE.md
```

**Node/Express — REST API:**
```
project/
  src/
    routes/             ← route handlers only
    services/           ← business logic
    models/             ← DB models
    middleware/         ← auth, validation, errors
    config/             ← env, db connection
  tests/
  package.json
  CLAUDE.md
```

**React — Frontend app:**
```
project/
  src/
    pages/              ← top-level routes
    components/         ← shared UI only
    hooks/              ← data hooks (one per domain)
    services/           ← API calls
    types/              ← TypeScript types
  public/
  package.json
  CLAUDE.md
```

**Fullstack (FastAPI + React):**
```
project/
  backend/
    app/
      api/v1/endpoints/
      services/
      models/
      schemas/
  frontend/
    src/
      pages/
      components/
      hooks/
  CLAUDE.md
```

**Go — REST API:**
```
project/
  cmd/server/           ← main entrypoint
  internal/
    handler/            ← HTTP handlers
    service/            ← business logic
    repository/         ← DB layer
    model/              ← domain types
  pkg/                  ← shared utilities
  CLAUDE.md
```

**CLI tool (any language):**
```
project/
  src/ (or cmd/)        ← commands
  lib/ (or internal/)   ← core logic
  tests/
  README.md
  CLAUDE.md
```

**Data pipeline:**
```
project/
  pipeline/
    extract/
    transform/
    load/
  tests/
  config/
  CLAUDE.md
```

If the stack is not listed above — apply the same principle: handlers/routes → services → data layer → tests. Always flat until complexity demands otherwise.

---

## Step 3 — Output the scaffold

Output in this exact format. Nothing else.

```
## Project: [name inferred from description]
## Stack: [stack]
## Scale: [scale]

### Folder structure
[paste the tree]

### Files to create first (in order)
1. CLAUDE.md — project guide (template below)
2. [config file] — e.g. pyproject.toml, package.json
3. [entry point] — e.g. main.py, index.ts, cmd/server/main.go
4. [first service] — the core domain service, empty skeleton
5. [first test] — one test that proves the skeleton runs

### CLAUDE.md template
---
# [Project Name]

## Project Layout
[paste folder tree]

## Feature Map
| Feature | Files | Do NOT touch |
|---------|-------|--------------|
| [first feature] | [files] | — |

## Critical Rules
- [1 rule specific to this stack, e.g. "never use date math for business logic"]
- [1 rule about scope, e.g. "read only files in the feature's row above"]

## Regression Checklist
- [ ] [most important thing that must not break]
- [ ] [second most important]
---

### Start here
1. Create the folder structure above
2. Copy the CLAUDE.md template and fill in [brackets]
3. Run: [exact command to verify the skeleton works, e.g. `uvicorn main:app`, `npm start`, `go run cmd/server/main.go`]
4. When it starts without errors — you're ready to build.

**Stop. Start building.**
```

---

## What to never output

- "Alternatively, you could..."
- "Another approach would be..."
- "In the future, consider..."
- "You might also want..."
- "It depends on..."
- Multiple options for the same decision
- Explanations of why you chose this over other structures

The developer asked for a structure. Give them the structure. Done.
