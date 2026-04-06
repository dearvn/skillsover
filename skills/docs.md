---
name: docs
description: Generate inline documentation (JSDoc, docstrings, OpenAPI comments) for selected code. Adds only what a reader can't infer from the code itself.
---

# Docs Skill

## Rule: Document the WHY, not the WHAT
Code shows what. Docs explain why it's designed this way, what the non-obvious behavior is, and what callers need to know.

Bad doc: `// Increments the counter` (obvious from code)
Good doc: `// Counter is shared across workers — use AtomicInt, not plain int`

## Step 1 — Read the target code
Read the function/class/module to be documented.

## Step 2 — Identify what actually needs explaining
Only add documentation for:
- Non-obvious parameters (what values are valid? what happens at the boundary?)
- Return value semantics (what does null mean? what's the shape?)
- Side effects (modifies shared state, sends HTTP call, writes to DB)
- Throws/errors (which exceptions can be raised and when?)
- Performance implications (O(n²), makes a network call, caches)
- Usage examples for complex APIs

## Step 3 — Write the documentation

### TypeScript / JavaScript (JSDoc)
```typescript
/**
 * [One-line summary — what it does]
 *
 * [Optional: WHY this exists or design decision worth noting]
 *
 * @param name - [what it represents, valid values, constraints]
 * @returns [what the value means, including null/undefined cases]
 * @throws {ErrorType} [when this is thrown]
 * @example
 * const result = myFunction("input");
 * // result: { id: 1, name: "example" }
 */
```

### Python (Google-style docstring)
```python
def my_function(param: str) -> dict:
    """One-line summary.

    Extended description if needed — focus on WHY and non-obvious behavior.

    Args:
        param: What it represents. Valid values: ...

    Returns:
        Dict with keys: id (int), name (str). Returns None if not found.

    Raises:
        ValueError: When param is empty.
        HTTPError: When the upstream service is unavailable.

    Example:
        result = my_function("input")
        # {'id': 1, 'name': 'example'}
    """
```

### C# (XML doc)
```csharp
/// <summary>
/// One-line summary.
/// </summary>
/// <param name="id">Description. Must be > 0.</param>
/// <returns>Null if not found. Never throws for missing items.</returns>
/// <exception cref="ArgumentException">When id is negative.</exception>
```

## Step 4 — Review checklist
- [ ] No doc restates what the code already shows clearly
- [ ] All `throws` documented
- [ ] Null/undefined return cases documented
- [ ] Side effects documented
- [ ] Example included for complex or non-obvious API
