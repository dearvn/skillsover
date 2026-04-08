---
name: security
description: Security audit covering OWASP Top 10 + full AI agent attack surface (6-category DeepMind framework: Content Injection, Semantic Manipulation, Cognitive State, Behavioural Control, Systemic, Human-in-the-Loop traps). Read-only — never modifies code. Outputs findings by severity.
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

This section implements the full 6-category framework from Google DeepMind research (Franklin et al., 2026) on AI Agent Traps — the first systematic taxonomy of how adversarial content in the environment manipulates AI agents.

---

### Category 1 — Content Injection Traps (Target: Perception)

Exploiting the gap between human-visible rendering and machine-parsed content.

#### CI-01 — Web-Standard Obfuscation
Does the agent read raw HTML, or does it receive pre-processed text?
- HTML comments stripped before feeding to LLM? (`<!-- Ignore previous instructions -->`)
- CSS hidden text handled? (`color: white; background: white`, `display: none`, `position: absolute; left: -9999px`)
- Aria-label and metadata attributes sanitized? (used for accessibility, invisible to users, parsed by agents)

Flag as [CRITICAL] if: raw HTML or DOM content reaches the LLM prompt without sanitization.

*Evidence: Injecting adversarial instructions into HTML elements alters generated summaries in 15–29% of cases depending on the model (Verma and Yadav, 2025).*

#### CI-02 — Dynamic Cloaking
Does the agent identify itself or behave differently than a human browser?
- Does the agent send a custom User-Agent or automation-framework headers?
- Could the server detect agent presence (IP/ASN, behavioral fingerprinting, browser attributes) and serve different content?
- Is the agent required to fetch content from untrusted third-party domains?

Flag as [CRITICAL] if: agent fetches content from external URLs where server-side fingerprinting could deliver agent-specific malicious payloads invisible to humans.

*Evidence: Web servers can run fingerprinting scripts to detect LLM-powered agents and serve visually identical but semantically different pages with embedded prompt-injection payloads (Zychlinski, 2025).*

#### CI-03 — Steganographic Payloads
Does the agent process images, audio, or other media files from external sources?
- Are images passed to vision-language models without content validation?
- Is audio processed by multimodal models?
- Are binary files (PDFs, DOCX) processed where pixel/binary-level manipulation is possible?

Flag as [CRITICAL] if: external media reaches a multimodal LLM without any integrity verification. A single adversarial image can universally jailbreak vision-language models (Qi et al., 2024).

*Evidence: Adversarial perturbations added to images can encode natural-language instructions that the model follows when users ask apparently benign questions about the media (Bagdasaryan et al., 2023).*

#### CI-04 — Syntactic Masking
Does the agent process Markdown, LaTeX, or other formatting languages from external sources?
- Are Markdown hyperlinks with adversarial anchor text rendered or parsed?
- Is LaTeX content from user-submitted documents processed?
- Are formatting constructs stripped before content reaches the LLM?

Flag as [HIGH] if: raw Markdown or LaTeX from external sources is passed to the LLM. Commands can be hidden in anchor text, white-on-white text, or tiny-font characters that survive PDF→Markdown conversion.

---

### Category 2 — Semantic Manipulation Traps (Target: Reasoning)

Corrupting the agent's reasoning by manipulating information distributions — without overt commands.

#### SM-01 — External Data Ingestion Without Human Checkpoint
Does the agent read from any of these sources?
- Websites / web scraping
- PDFs, spreadsheets, documents
- Emails, calendar invites
- Search results, third-party APIs
- Images processed by vision models

Flag as [CRITICAL] if: agent reads external content AND executes actions based on it with no human approval checkpoint before irreversible actions.

#### SM-02 — Biased Phrasing and Contextual Priming
Does the agent summarize, synthesize, or make decisions based on external text?
- Could an attacker saturate source content with sentiment-laden or authoritative-sounding language to bias the agent's output?
- Is the agent exposed to text from sources that could frame information to exploit LLM anchoring effects?
- Does the agent's reasoning rely on "Lost in the Middle" vulnerable positions (relevant info buried mid-context)?

Flag as [HIGH] if: agent performs synthesis or recommendations from untrusted external text without explicit framing controls or cross-checking.

*Evidence: LLMs exhibit systematic anchoring effects — even arbitrary initial values skew subsequent judgments. Performance degrades significantly when relevant information is buried mid-context (Liu et al., 2024).*

#### SM-03 — Oversight and Critic Evasion
Does the agent use a critic model, self-correction loop, or constitutional verifier?
- Could malicious instructions be wrapped in "educational", "hypothetical", "red-teaming", or "security audit simulation" framing to pass the critic?
- Are the critic's safety heuristics known or guessable?
- Does the critic have access to the full context, or only a summary?

Flag as [HIGH] if: critic/verifier model can be bypassed by framing harmful instructions as benign training, awareness, or academic analysis.

*Evidence: Successful jailbreaks systematically use "instruction misdirection" — harmful requests wrapped in hypothetical or educational framing — to bypass internal safety logic (Weinberg, 2025).*

---

### Category 3 — Cognitive State Traps (Target: Memory & Learning)

Corrupting long-term memory, knowledge bases, and learned behavioral policies.

#### CS-01 — RAG Knowledge Poisoning
Does the agent use a retrieval-augmented generation (RAG) system?
- Can attackers publish content to sources that get scraped into the retrieval corpus?
- Are retrieved documents from public/shared sources treated as verified facts?
- Is there any verification of retrieved content provenance before passing to the LLM?

Flag as [CRITICAL] if: agent treats retrieved documents as authoritative without provenance checking. Injecting only a handful of optimized documents into a large knowledge base can reliably manipulate outputs for targeted queries (Zou et al., 2025).

#### CS-02 — Latent Memory Poisoning
Does the agent maintain persistent memory across sessions?
- Can external inputs write to the agent's memory store?
- Is memory content validated before retrieval?
- Could crafted interactions inject records that activate maliciously in a specific future context?

Flag as [CRITICAL] if: memory is writable from external inputs without sanitization. Attack success rate exceeds 80% with less than 0.1% data poisoning (Chen et al., 2024).

---

### Category 4 — Behavioural Control Traps (Target: Action)

Explicit commands that subvert the agent's instruction-following to serve attacker goals.

#### BC-01 — Embedded Jailbreak Sequences
Are there dormant adversarial prompts in external resources the agent consumes?
- Does the agent ingest content from websites, repos, emails, or documents that could contain embedded jailbreaks?
- In multimodal settings: could a crafted image act as a universal jailbreak trigger when included alongside benign prompts?
- Does the agent have mechanisms to detect context-window override attempts?

Flag as [CRITICAL] if: agent ingests external resources without checking for embedded prompt-override patterns. Prompt injections embedded in web content partially hijack agents in up to 86% of scenarios (Evtimov et al., 2025).

#### BC-02 — Data Exfiltration via Legitimate Actions
Can injected instructions cause the agent to:
- Send data to attacker-controlled URLs via API calls that appear legitimate?
- Include user data in outbound requests (search queries, webhooks, analytics)?
- Write sensitive data to shared storage accessible by third parties?
- Email or transmit financial, medical, or behavioral data to attacker addresses?

Flag as [HIGH] if: agent has write access to external endpoints AND reads untrusted external content. Attack success rates exceed 80% across tested agents (Shapira et al., 2025).

#### BC-03 — Sub-agent Spawning Traps
Does the agent have the ability to instantiate sub-agents or delegate tasks?
- Can external content coerce the agent to spawn a sub-agent with an attacker-controlled system prompt?
- Do spawned sub-agents inherit the parent's privileges?
- Is there validation of sub-agent system prompts before instantiation?

Flag as [CRITICAL] if: agent can spawn sub-agents AND sub-agent system prompts can be influenced by external content. Attack success rates of 58–90% depending on orchestrator (Triedman et al., 2025).

---

### Category 5 — Systemic Traps (Target: Multi-Agent Dynamics)

Attacks that target aggregate behavior across multiple agents sharing an environment.

#### SY-01 — Trust Boundaries in Multi-Agent Pipelines
In pipelines where Agent A feeds Agent B:
- Does Agent B validate the source of instructions?
- Can an attacker inject via Agent A's data source to compromise Agent B?
- Does the pipeline have a human checkpoint before irreversible actions (send email, make payment, delete data)?
- Are agents in the pipeline using different base models, or are they homogeneous (correlated failure risk)?

Flag as [CRITICAL] if: downstream agents execute irreversible actions without human approval gate.

#### SY-02 — Goal Hijacking and Long-Session Drift
Does the agent have long-running tasks?
- Are intermediate steps logged and reviewable?
- Does the agent re-confirm its original goal at each major step?
- Could gradual environmental manipulation steer the agent away from its intended goal?

Flag as [MEDIUM] if: long-running agents have no goal-drift detection or intermediate checkpoints.

#### SY-03 — Compositional Fragment Traps
Does the agent aggregate content from multiple independent sources?
- Could an attacker distribute fragments of a malicious payload across multiple documents/sources that are individually benign?
- Does the agent combine content from multiple sources in a single context window?

Flag as [HIGH] if: multi-source aggregation occurs without cross-source integrity checking. Distributed backdoors trigger only when all key fragments appear together (Huang et al., 2024).

---

### Category 6 — Human-in-the-Loop Traps (Target: Human Overseer)

Attacks that commandeer the agent to manipulate its human supervisor.

#### HL-01 — Automation Bias and Approval Fatigue
Is there a human-in-the-loop reviewing agent outputs?
- Could the agent be coerced to generate highly technical but benign-looking summaries of malicious work?
- Could high-volume approval requests induce cognitive fatigue in the human reviewer?
- Could the agent embed phishing links or harmful instructions in outputs designed to look trustworthy?

Flag as [HIGH] if: human overseer approves agent outputs without independent verification, especially in high-volume or high-stakes workflows.

*Evidence: Invisible prompt injections via CSS obfuscation can make AI summarization tools faithfully repeat step-by-step ransomware commands as "fix" instructions that users are likely to follow (OECD.AI Policy Observatory, 2025).*

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

[INFO] Description (not a vulnerability, just worth noting)
...
```

Group AI agent findings under category headers:
```
--- AI AGENT ATTACK SURFACE ---

[Content Injection]
[CRITICAL] CI-01 — ...

[Semantic Manipulation]
[HIGH] SM-02 — ...

[Cognitive State]
[CRITICAL] CS-01 — ...

[Behavioural Control]
[CRITICAL] BC-01 — ...

[Systemic]
[CRITICAL] SY-01 — ...

[Human-in-the-Loop]
[HIGH] HL-01 — ...
```

If nothing found: `No security issues found in the reviewed scope.`

Do not include low-confidence guesses. Only report what you can confirm from the code.

---

## Limitations

- **Requires:** readable source code — does not analyze compiled binaries, minified bundles, or opaque third-party SDKs
- **A06 Vulnerable Components:** not in scope here — use `/supply-chain` for dependency-level threats
- **AI agent checks:** only effective when agent code is in the reviewed scope; cannot detect issues inside closed-source LLM SDKs
- **Does not replace:** dedicated SAST tools (Semgrep, CodeQL) for large-scale static analysis or custom rule enforcement at CI scale

---

## Status

End every run with one of:

- **DONE** — audit complete, no issues found
- **DONE_WITH_CONCERNS** — audit complete, findings reported — human review required before shipping
- **BLOCKED** — cannot proceed (state exactly why and what is needed)
- **NEEDS_CONTEXT** — insufficient scope provided (state what files/context is missing)
