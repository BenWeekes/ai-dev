---
description: Review staged changes before committing
---

Review the staged changes (`git diff --cached`) and evaluate them for commit readiness.

## What to evaluate

For each changed file, check:

1. **Correctness** — Does the code do what it's supposed to? Logic errors, off-by-ones, wrong conditions.
2. **Missing tests** — Are there behavioral changes without corresponding test updates?
3. **Convention violations** — Does the code follow the repo's established patterns? Check AGENTS.md and existing code for conventions.
4. **Security issues** — Secrets in code, injection vulnerabilities, unsafe inputs, OWASP top 10.
5. **Simplicity** — Is this more complex than it needs to be? Unnecessary abstractions, dead code, over-engineering.

## Output format

For each file with issues:

```
### `path/to/file`

- **error:** [Description of the issue]
- **warning:** [Description of the issue]
- **suggestion:** [Description of the issue]
```

Severity levels:

- **error** — Must fix before committing. Bugs, security issues, broken tests.
- **warning** — Should fix. Convention violations, missing tests, poor naming.
- **suggestion** — Consider fixing. Simplification opportunities, minor style issues.

## Summary

End with a commit-readiness verdict:

- **Ready to commit** — No errors or warnings.
- **Fix before committing** — List the errors/warnings that need attention.
