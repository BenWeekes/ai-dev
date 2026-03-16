# AI-Assisted Development Guide

This guide to developing software with AI coding tools is intended to be flexible enough to allow teams to experiment with new models, frameworks, and methodologies while being prescriptive enough to ensure we follow best practices where appropriate and learn from each other.

> **Quickstart:** `git clone` this repo, run `./init.sh claude` (or your agent), and start with `/spec <task>`.

## Table of Contents

**Setup**

- [1. AI Coding Tools](#1-ai-coding-tools)
- [2. Protect Sensitive Files](#2-protect-sensitive-files)
- [3. Progressive Disclosure Documentation Standard](#3-progressive-disclosure-documentation-standard)
- [4. Git Hooks](#4-git-hooks)
- [5. Slash Commands](#5-slash-commands)
- [6. Optional Extensions](#6-optional-extensions)

**Workflow**

- [7. Test Driven Development](#7-test-driven-development)
- [8. Spec and Plan Before You Code](#8-spec-and-plan-before-you-code)
  - [Spec Template](#spec-template)
  - [Plan Template](#plan-template)
- [9. Review Changes](#9-review-changes)
- [10. Prompt Engineering](#10-prompt-engineering)
- [11. Evals](#11-evals)

**Advanced**

- [12. Multi-Repo Orchestration](#12-multi-repo-orchestration)

---

## 1. AI Coding Tools

Everything in this guide works with any AI coding tool. The practices are about _how you work_, not which tool you use. Common options include [Claude Code](https://docs.anthropic.com/en/docs/claude-code), [Cursor](https://cursor.sh), [GitHub Copilot](https://github.com/features/copilot), [Cody](https://sourcegraph.com/cody), and [Aider](https://aider.chat).

---

## 2. Protect Sensitive Files

AI coding agents can typically read all files in your project. Prevent access to secrets:

- Block agent access to `.env`, `.env.local`, `.env.production`, and similar files.
- Block `config/secrets.*`, `**/private_key.pem`, and any credentials files.
- Most AI coding tools have a permissions or deny-list mechanism — use it.

---

## 3. Progressive Disclosure Documentation Standard

AI agents work better when they can quickly understand a codebase. The [Progressive Disclosure Documentation Standard](progressive-disclosure-standard.md) provides a structured way to do this — a single Repo Card (L0) for orientation, an Operator Pack (L1) for working knowledge, and deep dives (L2) for complex areas.

For internal projects, L0 (Repo Card) and L1 (Operator Pack) are the minimum expectation. Every repo should have at least a Repo Card for orientation and an Operator Pack covering setup, architecture, and conventions. L2 deep dives are added as needed for complex areas.

---

## 4. Git Hooks

Git hooks enforce what agents (and humans) can't easily forget: coding conventions, code formatting, commit message standards, and author control. They run automatically on every commit, so quality checks don't depend on anyone remembering to run them.

> **Quick install:** Run `./init.sh` to install hooks and set up slash commands for your AI agent.

The hooks live in `hooks/` and are installed to `.git/hooks/` by `init.sh`.

**commit-msg** — Blocks AI tool names (Claude, Cursor, Copilot, Cody, Aider, Gemini, Codex, ChatGPT, GPT-3/4) from commit messages. Enforces lowercase start.

**pre-commit** — Runs security checks (blocks `.env` files, scans for hardcoded secrets) and Prettier formatting on staged files. Language-agnostic by default — add project-specific linters (ESLint, ruff, clippy, etc.) by uncommenting or extending the hooks.

---

## 5. Slash Commands

This repo ships with five slash commands in `commands/`. Run `./init.sh <agent>` to install them for your AI coding tool.

| Command   | What It Does                                                                    |
| --------- | ------------------------------------------------------------------------------- |
| `/spec`   | Capture requirements (WHAT/WHY) in `docs/plans/` before planning implementation |
| `/plan`   | Plan implementation approach (HOW) referencing a spec                           |
| `/review` | Two-pass review: spec compliance first, then code quality                       |
| `/tdd`    | Implement a task using strict test-driven development                           |
| `/docs`   | Generate progressive disclosure documentation following the PD standard         |

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

## 6. Optional Extensions

The practices in this guide are self-contained, but these projects add capabilities on top:

| Project                                            | What It Adds                                                                                                       |
| -------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| [Superpowers](https://github.com/obra/superpowers) | Subagent-per-task dispatch, two-stage review, systematic debugging methodology, model selection by task complexity |
| [Spec Kit](https://github.com/github/spec-kit)     | Spec-driven development with executable specifications, multi-step refinement, cross-artifact validation           |

These are optional — install them alongside this repo's commands if you want deeper agent orchestration or more structured spec workflows.

---

## 7. Test Driven Development

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

## 8. Spec and Plan Before You Code

Separate WHAT from HOW. A spec captures requirements; a plan captures the implementation approach. This split prevents agents from locking into the first solution they think of and skipping requirements along the way.

**The workflow:** `/spec` → `/plan` → `/tdd`

1. **Spec** (`/spec`) — Write down what the system should do and why. No implementation details. Save to `docs/plans/` with a `-spec` suffix.
2. **Plan** (`/plan`) — Decide how to implement the spec. Reference the spec, break work into numbered tasks, list files to change. Save to `docs/plans/`.
3. **Implement** (`/tdd`) — Build it test-first, following the plan. See [TDD](#7-test-driven-development) for the full cycle.

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

## 9. Review Changes

Review diffs before committing. Use `git diff` to inspect what actually changed. Never push code you haven't reviewed.

**A practical workflow:** tests pass → AI review (`/review`) → human review → commit (hooks run automatically).

There's a spectrum of review depth. Find the balance that matches your confidence in the agent and the risk of the change:

- **Tests** provide a mechanical safety net — if they pass, core behavior is correct. [TDD](#7-test-driven-development) ensures tests exist before the code does.
- **AI-assisted review** catches issues you might miss. Use `/review` to have an agent check staged changes in two passes — first for spec compliance (did the code meet the requirements?), then for code quality (correctness, security, conventions, simplicity).
- **Human review** adds judgment that tests and agents can't — architectural fit, naming quality, whether the change is the right approach. Focus human attention on the parts that matter most.
- **Git hooks** enforce formatting and conventions automatically, so reviewers don't waste time on style.

---

## 10. Prompt Engineering

The quality of the agent's output depends on the quality of your prompt. Specific, context-rich prompts produce focused, correct code.

- **Be specific.** "Add a `getUser` method to `src/api/users.ts` that calls the `/users/:id` endpoint" beats "add a way to get users."
- **Provide context.** Reference the spec, reference the plan, paste the error message, link to the docs.
- **Constrain scope.** "Change only `src/auth.ts`", "follow the pattern in `src/api/posts.ts`" — constraints reduce scope and make output more predictable.
- **Use system prompts.** `CLAUDE.md`, `AGENTS.md`, and similar config files persist conventions across sessions. Write them once, every session inherits the context.

For a real example, see [Prompt: Generate Docs for an Existing Repo](progressive-disclosure-standard.md#6-prompt-generate-docs-for-an-existing-repo).

---

## 11. Evals

Evals are automated tests for AI behaviour. Where unit tests check whether code produces correct output, evals check whether a prompt, skill, or agent produces correct output.

**Why evals matter:** Prompts and skills change over time. A tweak to a system prompt can silently degrade output quality. Evals catch these regressions the same way unit tests catch code regressions — by running automatically and failing loudly.

**How they work:**

1. Spin up a fresh sub-agent with the resource under test (a skill, prompt, or `CLAUDE.md`)
2. Have it perform a defined task
3. Grade the output against expected criteria (correct files modified, expected patterns present, no regressions)

**Example:** Test whether a coding skill satisfies a prompt correctly by running it in a clean agent session and checking the result against acceptance criteria — did it produce the right files, follow the coding standard, pass the tests?

**Recommended platform:** [Anthropic's eval framework](https://docs.anthropic.com/en/docs/test-and-evaluate/strengthen-guardrails/reduce-hallucinations) provides tooling for building and running evals against Claude-based agents and prompts.

---

## 12. Multi-Repo Orchestration

When a feature spans multiple repositories, you need coordination across agents. The [Multi-Repo Orchestration](multi-repo-orchestration.md) guide covers agent tiers, epic lifecycle, cross-repo code review, and contract testing.
