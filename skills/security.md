---
name: security
description: Security audit covering OWASP Top 10 + AI agent attack vectors (prompt injection, data poisoning, indirect injection). Read-only — never modifies code. Outputs findings by severity.
allowed-tools: [Read, Grep, Bash]
---

# Security Skill

Read-only audit. Never modify production code. Report findings only.

## Step 1 — Identify target type

Read the specified file(s). Determine: is this **web/API code**, an **AI agent/LLM pipeline**, or both?

- Web/API → run Steps 2 + 3
- AI agent → run Steps 2 + 3 + 4
- Both → run all steps

If checking an API endpoint, also read its auth middleware and validation layer.

---

## Step 2 — Check OWASP Top 10

### A01 — Broken Access Control
- Is every route protected by auth middleware?
- Can users access other users' data by changing an ID in the URL?
- Are admin routes restricted to admin role?

### A02 — Cryptographic Failures
- Is sensitive data (passwords, tokens) stored in plaintext?
- Are secrets/API keys hardcoded or in version control?
- Is HTTP used where HTTPS should be?

### A03 — Injection
- Is user input passed directly to SQL queries? (look for string concatenation)
- Is user input used in shell commands? (os.system, subprocess, exec)
- Is user input rendered as HTML? (innerHTML, dangerouslySetInnerHTML)

### A04 — Insecure Design
- Is there rate limiting on auth endpoints?
- Are failed login attempts counted and blocked?

### A05 — Security Misconfiguration
- Are error messages leaking stack traces to users?
- Are debug endpoints exposed in production?
- Are default credentials still in use?

### A07 — Authentication Failures
- Are JWTs validated (signature + expiry)?
- Are sessions invalidated on logout?
- Is password reset secure (time-limited, single-use tokens)?

### A08 — Software and Data Integrity
- Is user-controlled data used in deserialization?
- Are file uploads validated for type AND content?

### A09 — Logging Failures
- Are auth failures logged?
- Are sensitive values (passwords, tokens) being logged?

---

## Step 3 — Check for common high-risk patterns

- **Secrets in code**: grep for `api_key`, `secret`, `password`, `token` assigned as string literals
- **Open redirects**: URL redirects using user-supplied input without whitelist
- **CORS misconfiguration**: `Access-Control-Allow-Origin: *` on authenticated endpoints
- **Path traversal**: user input used in file paths without sanitization
- **Mass assignment**: ORM model created directly from request body without field allowlist

---

## Step 4 — AI Agent Attack Surface (run if code uses LLMs or AI agents)

This section covers attack vectors from indirect prompt injection and data poisoning —
the attack class where malicious content in external data hijacks AI agent behavior.

### PI-01 — External Data Ingestion
Does the agent read from any of these sources?
- Websites / web scraping
- PDFs, spreadsheets, documents
- Emails, calendar invites
- Search results, APIs from third parties
- Images processed by vision models

**Risk**: Any external source can embed hidden instructions. Websites can detect AI agents
and serve different content to them vs humans (timing, user-agent, behavioral fingerprint).

Flag as [CRITICAL] if: agent reads external content AND executes actions based on it with no human checkpoint.

### PI-02 — Prompt Injection via Hidden Content
Check if the code processes raw HTML, PDF text, or image metadata:
- HTML comments stripped before feeding to LLM? (`<!-- ignore previous instructions -->`)
- CSS hidden text handled? (`color: white; background: white` — invisible to humans, visible to AI)
- Image alt-text / metadata sanitized before LLM sees it?
- PDF text extraction: is raw extracted text fed directly to LLM without sanitization?

Flag as [CRITICAL] if: raw external content reaches the LLM prompt without sanitization.

### PI-03 — Trust Boundaries in Multi-Agent Pipelines
In pipelines where Agent A feeds Agent B:
- Does Agent B validate the source of instructions?
- Can an attacker inject via Agent A's data source to compromise Agent B?
- Does the pipeline have a human checkpoint before irreversible actions (send email, make payment, delete data)?

Flag as [CRITICAL] if: downstream agents execute irreversible actions without human approval gate.

### PI-04 — Exfiltration via Legitimate Actions
Can injected instructions cause the agent to:
- Send data to attacker-controlled URLs via API calls that look legitimate?
- Include user data in outbound requests (search queries, webhooks, analytics)?
- Write sensitive data to shared storage accessible by third parties?

Flag as [HIGH] if: agent has write access to external endpoints AND reads untrusted external content.

### PI-05 — Memory Poisoning
If the agent has persistent memory (vector DB, session history):
- Can an attacker inject false information into memory via a crafted input?
- Does poisoned memory persist across sessions?
- Is memory content ever reviewed before being used to inform high-stakes decisions?

Flag as [HIGH] if: memory is populated from external sources without sanitization.

### PI-06 — Goal Hijacking
Does the agent have long-running tasks that can be gradually redirected?
- Are intermediate steps logged and reviewable?
- Does the agent re-confirm its original goal at each major step?

Flag as [MEDIUM] if: long-running agents have no goal-drift detection.

---

## Step 5 — Output format

```
[CRITICAL] Description — why this is dangerous
File: path/to/file.ts:42
Fix: what to do

[HIGH] Description
File: ...
Fix: ...

[MEDIUM] Description
...

[INFO] Description (not a vuln, just worth noting)
...
```

Group AI agent findings under a separate header:
```
--- AI AGENT ATTACK SURFACE ---
[CRITICAL] ...
```

If nothing found: `No security issues found in the reviewed scope.`

Do not include low-confidence guesses. Only report what you can confirm from the code.

---

## Status

End every run with one of:

- **DONE** — audit complete, no issues found
- **DONE_WITH_CONCERNS** — audit complete, findings reported — human review required before shipping
- **BLOCKED** — cannot proceed (state exactly why and what is needed)
- **NEEDS_CONTEXT** — insufficient scope provided (state what files/context is missing)
