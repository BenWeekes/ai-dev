---
description: Create a plan for a task before writing any code
---

Create a plan for the following task and save it to `docs/plans/`. Do not start implementation.

**Task:** $ARGUMENTS

## Plan template

Use this exact structure:

```markdown
# Plan: [Short Title]

## Problem

[What are we solving? 2-3 sentences.]

## Approach

[How will we solve it? Bullet points.]

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

## Files to Change

| File           | Action                   | Rationale                     |
| -------------- | ------------------------ | ----------------------------- |
| `path/to/file` | Create / Modify / Delete | Why this file needs to change |

## Open Questions

- [Anything unresolved that needs human input]
- Mark each with `[NEEDS CLARIFICATION]` if it blocks a requirement above
```

## Rules

1. **Number every requirement** — FR-001, FR-002, NFR-001, etc.
2. **Don't guess on ambiguity** — if a requirement is unclear, mark it `[NEEDS CLARIFICATION]` and add to Open Questions.
3. **Use real file paths** — check the repo to find actual paths, don't invent them.
4. **Don't start implementation** — the plan is the deliverable, not code.
5. **Given/When/Then for behavior** — use this format for anything testable. Fall back to checkboxes only for simple declarative criteria (e.g., "file exists", "config value is set").
6. **Rationale column is required** — every file in the table must explain why it changes.
