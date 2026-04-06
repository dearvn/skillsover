---
name: security
description: Quick security audit of current file or feature. Checks OWASP Top 10 + secrets + auth. Read-only — never modifies code. Outputs findings by severity.
---

# Security Skill

Read-only audit. Never modify production code. Report findings only.

## Step 1 — Read the target
Read the specified file(s). If checking an API endpoint, also read its auth middleware and validation layer.

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

## Step 3 — Output format

```
[CRITICAL] Description — why this is dangerous
File: path/to/file.ts:42
Fix: what to do

[HIGH] Description
...

[MEDIUM] Description
...

[INFO] Description (not a vuln, just worth noting)
...
```

If nothing found: "No security issues found in the reviewed scope."
Do not include low-confidence guesses. Only report what you can confirm from the code.
