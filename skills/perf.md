---
name: perf
description: Performance analysis — profile first, then optimize. Never guess the bottleneck. Identifies N+1 queries, slow loops, memory leaks, and render thrashing.
allowed-tools: [Read, Grep, Bash]
---

# Perf Skill

**Rule #1: Never optimize without measuring first.**
Guessing bottlenecks wastes time and often makes things worse.

## Step 1 — Define the problem
Answer before reading any code:
- What is slow? (page load, API response, background job, render)
- How slow? (1s vs 30s — context matters)
- When does it happen? (always, under load, with large data)
- What changed recently? (new feature, more data, more users)

## Step 2 — Profile, don't guess

### Backend
```bash
# Python — cProfile
python -m cProfile -o output.prof myscript.py
python -m pstats output.prof

# Node — built-in profiler
node --prof app.js
node --prof-process isolate-*.log

# PostgreSQL slow queries
SELECT query, mean_exec_time, calls FROM pg_stat_statements
ORDER BY mean_exec_time DESC LIMIT 20;
```

### Frontend
- Open Chrome DevTools → Performance tab → Record while reproducing
- Look for: long tasks (>50ms), layout thrashing, excessive re-renders
- React DevTools Profiler → find components that render too often

## Step 3 — Read the code only after profiling shows a hotspot

Read ONLY the specific function/query identified as slow. Do not read surrounding code.

## Step 4 — Common patterns to look for

### Database
- **N+1**: loop that runs a query per item → replace with JOIN or batch fetch
- **Missing index**: WHERE/ORDER BY on unindexed column → add index
- **SELECT ***: fetching all columns when only 2 needed → select only what's needed
- **No pagination**: fetching 100k rows → add LIMIT/OFFSET or cursor

### Backend
- **Repeated computation**: same value computed in loop → hoist outside loop
- **Blocking I/O in async**: sync file/DB call inside async handler → await properly
- **No caching**: identical query per request → cache with TTL

### Frontend
- **Re-render on every keystroke**: expensive component in input onChange → debounce
- **Huge bundle**: `import * from 'lodash'` → import only what's used
- **No virtualization**: rendering 1000 list items → use virtual scroll

## Step 5 — Output format
```
Bottleneck: [specific function/query/component]
Evidence: [profiler data or code analysis]
Root cause: [why it's slow]
Fix: [specific change]
Expected gain: [rough estimate — only if measurable]
```

---

## Limitations

- **Most useful after profiling:** without profiler output, bottleneck identification is speculative — findings are directional, not evidence-based
- **Does not run profilers:** user must run the profiler and share results; this skill reads and interprets them
- **Not covered:** infrastructure bottlenecks (DNS, CDN, network latency, load balancer); GPU-bound workloads; real-time or embedded systems

---

## Status

End every run with one of:

- **DONE** — bottleneck identified, fix described with evidence
- **DONE_WITH_CONCERNS** — fix suggested but expected gain is uncertain — measure after deploying
- **BLOCKED** — no profiling data available and hotspot cannot be determined from code alone
- **NEEDS_CONTEXT** — "it's slow" is not enough — Step 1 questions must be answered first
