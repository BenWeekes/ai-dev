---
description: Review staged changes before committing
---

Review the staged changes (`git diff --cached`) and evaluate them for commit readiness.

## Pass 1: Spec compliance

Check whether the staged changes satisfy the requirements from the spec.

1. **Find the spec.** Look in `docs/plans/` for a `-spec.md` file matching the current work. If multiple candidates exist, check git log for context.
2. **Check each requirement.** For every FR and NFR in the spec, verify the staged changes satisfy it. Flag any requirement that is not addressed or only partially addressed.
3. **No spec?** If no spec exists, note "No spec found — skipping spec compliance check" and proceed to Pass 2.

For each unmet requirement:

```
### Pass 1: Spec compliance

- **FR-001: [title]** — not addressed. [Explanation.]
- **NFR-002: [title]** — partially addressed. [What's missing.]
```

If all requirements are met: "All spec requirements satisfied."

## Pass 2: Code quality

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
