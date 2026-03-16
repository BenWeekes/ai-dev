---
description: Capture requirements for a task before planning implementation
---

Write a spec for the following task and save it to `docs/plans/` with a `-spec` suffix (e.g., `docs/plans/auth-login-spec.md`). Do not plan implementation. Do not write code.

**Task:** $ARGUMENTS

## Spec template

Use this exact structure:

```markdown
# Spec: [Short Title]

## Problem

[What are we solving and why? 2-3 sentences.]

## Requirements

Number every requirement. Use Given/When/Then for behavioral requirements. Use checkboxes for simple declarative criteria. Mark anything ambiguous with `[NEEDS CLARIFICATION]`.

### Functional Requirements

- **FR-001:** [Requirement title]
  - Given [precondition]
  - When [action]
  - Then [expected outcome]

- **FR-002:** [Requirement title]
  - [ ] [Simple declarative criterion]

### Non-Functional Requirements

- **NFR-001:** [Requirement — e.g., performance, security, accessibility]

## Open Questions

- [Anything unresolved that needs human input]
- Mark each with `[NEEDS CLARIFICATION]` if it blocks a requirement above
```

## Rules

1. **WHAT and WHY only** — a spec describes what the system should do and why. No implementation details, no approach, no file paths.
2. **Number every requirement** — FR-001, FR-002, NFR-001, etc.
3. **Don't guess on ambiguity** — if a requirement is unclear, mark it `[NEEDS CLARIFICATION]` and add to Open Questions.
4. **Given/When/Then for behavior** — use this format for anything testable. Fall back to checkboxes only for simple declarative criteria (e.g., "file exists", "config value is set").
5. **No implementation leaking in** — if you catch yourself writing file paths, function names, or technology choices, move it to an Open Question or remove it. The spec is for the `/plan` command to consume.
