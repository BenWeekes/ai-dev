---
description: Plan the implementation approach for a spec
---

Create an implementation plan for the following task and save it to `docs/plans/`. Do not start implementation.

**Task:** $ARGUMENTS

## Before you start

1. **Find the spec.** Look in `docs/plans/` for a `-spec.md` file matching this task. If one exists, use its requirements as the source of truth. If no spec exists, note this in the plan and define requirements inline.
2. **Read the codebase.** Check actual file paths, existing patterns, and conventions before writing the plan.

## Plan template

Use this exact structure:

```markdown
# Plan: [Short Title]

## Spec

[Link to the spec file in `docs/plans/`, or "No spec — requirements defined inline."]

## Approach

[How will we solve it? Bullet points. This is the HOW — the spec covers the WHAT.]

## Task Breakdown

For plans with 3 or more steps, number tasks with dependencies and file paths.

- **T001:** [Task title]
  - Files: `path/to/file`
  - Depends on: —
- **T002:** [Task title]
  - Files: `path/to/file`
  - Depends on: T001
- **T003:** [Task title]
  - Files: `path/to/file`, `path/to/other`
  - Depends on: T001, T002

For simpler plans, a bullet list of steps is sufficient.

## Files to Change

| File           | Action                   | Rationale                     |
| -------------- | ------------------------ | ----------------------------- |
| `path/to/file` | Create / Modify / Delete | Why this file needs to change |

## Open Questions

- [Anything unresolved that needs human input]
```

## Rules

1. **Find the spec first** — the spec is the source of truth for requirements. Don't reinvent them.
2. **HOW, not WHAT** — the plan describes approach and tasks. Requirements belong in the spec.
3. **Use real file paths** — check the repo to find actual paths, don't invent them.
4. **Don't start implementation** — the plan is the deliverable, not code.
5. **Rationale column is required** — every file in the table must explain why it changes.
6. **Number tasks for complex plans** — if the plan has 3+ steps, use T001/T002/... with dependencies to show execution order.
