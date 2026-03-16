# AI-Assisted Development Guide

A practical guide to developing software with AI coding tools. Works with any agent — the practices are about _how you work_, not which tool you use.

> **Quickstart:** `git clone` this repo, run `./init.sh claude` (or your agent), and start with `/spec <task>`.

## Table of Contents

**Setup**

- [1. Documentation Standard](#1-documentation-standard)
- [2. Git Hooks](#2-git-hooks)
- [3. Slash Commands](#3-slash-commands)

**Workflow**

- [4. Test Driven Development](#4-test-driven-development)
- [5. Spec and Plan Before You Code](#5-spec-and-plan-before-you-code)
  - [Spec Template](#spec-template)
  - [Plan Template](#plan-template)
- [6. Review Changes](#6-review-changes)

**Advanced**

- [7. Multi-Repo Orchestration](#7-multi-repo-orchestration)
- [8. Optional Extensions](#8-optional-extensions)

---

## 1. Documentation Standard

Every repo should have at least a Repo Card (L0) for orientation and an Operator Pack (L1) covering setup, architecture, and conventions. L2 deep dives are added as needed for complex areas. See the [Progressive Disclosure Documentation Standard](progressive-disclosure-standard.md) for the full spec, and the [prompt for generating docs for an existing repo](progressive-disclosure-standard.md#6-prompt-generate-docs-for-an-existing-repo).

---

## 2. Git Hooks

Git hooks enforce what agents (and humans) can't easily forget: coding conventions, code formatting, commit message standards, and author control. They run automatically on every commit, so quality checks don't depend on anyone remembering to run them.

> **Quick install:** Run `./init.sh` to install hooks and set up slash commands for your AI agent.

The hooks live in `hooks/` and are installed to `.git/hooks/` by `init.sh`.

**commit-msg** — Blocks AI tool names from commit messages so authorship accurately reflects human developers. Enforces lowercase start.

**pre-commit** — Blocks `.env` files, scans for hardcoded secrets, and runs Prettier formatting on staged files. Language-agnostic by default — add project-specific linters (ESLint, ruff, clippy, etc.) by uncommenting or extending the hooks.

**CI** — A [sample GitHub Actions workflow](.github/workflows/ci.example.yml) is included for projects cloned from this template. It mirrors the hook checks (Prettier, secret scanning) and has commented-out sections for Node.js, Python, Go, and Rust. Copy it to `ci.yml` and uncomment what you need.

---

## 3. Slash Commands

Slash commands live in `commands/`. Run `./init.sh <agent>` to install them for your AI coding tool. Subdirectories create namespaced commands — `commands/git/ship.md` becomes `/git:ship`.

| Command     | What It Does                                                                    |
| ----------- | ------------------------------------------------------------------------------- |
| `/spec`     | Capture requirements (WHAT/WHY) in `docs/plans/` before planning implementation |
| `/plan`     | Plan implementation approach (HOW) referencing a spec                           |
| `/review`   | Two-pass review: spec compliance first, then code quality                       |
| `/tdd`      | Implement a task using strict test-driven development                           |
| `/docs`     | Generate progressive disclosure documentation following the PD standard         |
| `/git:ship` | Commit staged changes and push (preserves git author, no Co-Authored-By)        |
| `/git:pr`   | Create a PR from current branch to main with generated title and summary        |
| `/git:sync` | Pull latest from main, rebase current branch on top                             |

### Supported Agents

| Agent            | Command             | Install Directory   |
| ---------------- | ------------------- | ------------------- |
| Claude Code      | `./init.sh claude`  | `.claude/commands/` |
| OpenAI Codex CLI | `./init.sh codex`   | `.codex/prompts/`   |
| Gemini CLI       | `./init.sh gemini`  | `.gemini/commands/` |
| Cursor           | `./init.sh cursor`  | `.cursor/commands/` |
| GitHub Copilot   | `./init.sh copilot` | `.github/agents/`   |

Commands are plain markdown files with a `$ARGUMENTS` placeholder for user input. The init script copies them to the agent-specific directory and transforms the placeholder for agents that use a different syntax (e.g., `{{args}}` for Gemini).

---

## 4. Test Driven Development

Write the test first, verify it fails, then write the implementation. This is especially important for AI agents, which are prone to writing tests that mirror their implementation rather than independently encoding the requirement.

**The sequence:**

1. **Read** acceptance criteria from the task or plan
2. **Write** test(s) that encode the criteria
3. **Run** tests — verify they fail (a test that passes before implementation tests nothing)
4. **Write** implementation code
5. **Run** tests — verify they pass
6. **Commit** on green

> **Fix the code, not the test.** When a test fails after implementation, fix the implementation — not the test. Weakening a test to match broken code defeats the purpose.

> **A task is not complete until all tests pass.** No failures, no skipped tests. If the agent cannot get tests passing after a reasonable effort, it should report the task as blocked with diagnostics and escalate to a human.

---

## 5. Spec and Plan Before You Code

Separate WHAT from HOW. A spec captures requirements; a plan captures the implementation approach. This split prevents agents from locking into the first solution they think of and skipping requirements along the way.

**The workflow:** `/spec` → `/plan` → `/tdd`

1. **Spec** (`/spec`) — Write down what the system should do and why. No implementation details. Save to `docs/plans/` with a `-spec` suffix.
2. **Plan** (`/plan`) — Decide how to implement the spec. Reference the spec, break work into numbered tasks, list files to change. Save to `docs/plans/`.
3. **Implement** (`/tdd`) — Build it test-first, following the plan. See [TDD](#4-test-driven-development) for the full cycle.

### Spec Template

```markdown
# Spec: [Short Title]

## Problem

[What are we solving and why? 2-3 sentences.]

## Requirements

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
```

The spec is WHAT and WHY only. No file paths, no function names, no technology choices.

### Plan Template

```markdown
# Plan: [Short Title]

## Spec

[Link to the spec file in `docs/plans/`.]

## Approach

[How will we solve it? Bullet points.]

## Task Breakdown

- **T001:** [Task title]
  - Files: `path/to/file`
  - Depends on: —
- **T002:** [Task title]
  - Files: `path/to/file`
  - Depends on: T001

## Files to Change

| File           | Action                   | Rationale                     |
| -------------- | ------------------------ | ----------------------------- |
| `path/to/file` | Create / Modify / Delete | Why this file needs to change |
```

The plan is HOW only. Requirements belong in the spec.

Don't delete specs or plans after implementation. Old plans are useful context — they show what was tried, what decisions were made, and why.

---

## 6. Review Changes

Humans gate decisions, AI gates execution. Not every commit needs human eyeballs on the diff — if tests pass and AI review passes, the code can proceed. Human attention should focus on the plan, the spec, and the final PR.

**Human gates** — design approval (before implementation), spec review, final merge decision. These are the points where judgment matters: is this the right approach? Does the spec capture the real requirement? Is this ready to ship?

**AI gates** — spec compliance and code quality checks between tasks. Use `/review` to have an agent check staged changes in two passes — first for spec compliance (did the code meet the requirements?), then for code quality (correctness, security, conventions, simplicity). [TDD](#4-test-driven-development) provides the mechanical safety net underneath.

**Git hooks** enforce formatting and conventions automatically on every commit.

**A practical workflow:** human approves spec → human approves plan → AI reviews each task (TDD + `/review`) → human reviews final PR → merge.

---

## 7. Multi-Repo Orchestration

When a feature spans multiple repositories, you need coordination across agents. The [Multi-Repo Orchestration](multi-repo-orchestration.md) guide covers agent tiers, epic lifecycle, cross-repo code review, and contract testing.

---

## 8. Optional Extensions

The practices in this guide are self-contained, but these projects add capabilities on top:

| Project                                            | What It Adds                                                                                                       |
| -------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| [Superpowers](https://github.com/obra/superpowers) | Subagent-per-task dispatch, two-stage review, systematic debugging methodology, model selection by task complexity |
| [Spec Kit](https://github.com/github/spec-kit)     | Spec-driven development with executable specifications, multi-step refinement, cross-artifact validation           |

These are optional — install them alongside this repo's commands if you want deeper agent orchestration or more structured spec workflows.
