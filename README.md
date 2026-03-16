# AI-Assisted Development Guide

A practical guide to developing software with AI coding tools. Works with any agent — the practices are about _how you work_, not which tool you use.

> **Quickstart:** `git clone` this repo, run `./init.sh <agent>` to install hooks and commands. Use [Superpowers](https://github.com/obra/superpowers) for the workflow layer (spec, plan, TDD, review).

## Table of Contents

**Setup**

- [1. Documentation Standard](#1-documentation-standard)
- [2. Git Hooks](#2-git-hooks)
- [3. Slash Commands](#3-slash-commands)

**Workflow**

- [4. Workflow](#4-workflow)

**Advanced**

- [5. Multi-Repo Orchestration](#5-multi-repo-orchestration)

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

This repo ships with one slash command in `commands/`. Run `./init.sh <agent>` to install it for your AI coding tool.

| Command | What It Does                                                            |
| ------- | ----------------------------------------------------------------------- |
| `/docs` | Generate progressive disclosure documentation following the PD standard |

For workflow commands (spec, plan, TDD, review), use [Superpowers](https://github.com/obra/superpowers) — it provides subagent-per-task dispatch, two-stage review, systematic debugging, and model selection by task complexity.

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

## 4. Workflow

This template provides infrastructure (hooks, docs standard, CI). For the development workflow itself — spec, plan, TDD, review — use [Superpowers](https://github.com/obra/superpowers).

The principles remain the same regardless of tooling:

**Spec before plan, plan before code.** Separate WHAT from HOW. A spec captures requirements; a plan captures the implementation approach. This split prevents agents from locking into the first solution they think of and skipping requirements along the way. Specs and plans live in `docs/plans/`, are version-controlled, and reviewed in PRs.

**Test driven development.** Write the test first, verify it fails, then write the implementation. This is especially important for AI agents, which are prone to writing tests that mirror their implementation rather than independently encoding the requirement. Fix the code, not the test. A task is not complete until all tests pass — no failures, no skipped tests.

**Review changes.** Humans gate decisions, AI gates execution. Human attention should focus on the plan, the spec, and the final PR. AI review checks spec compliance and code quality between tasks. Git hooks enforce formatting and conventions automatically.

**A practical workflow:** human approves spec → human approves plan → AI reviews each task (TDD + review) → human reviews final PR → merge.

Don't delete specs or plans after implementation. Old plans are useful context — they show what was tried, what decisions were made, and why.

| Project                                            | What It Adds                                                                                                       |
| -------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| [Superpowers](https://github.com/obra/superpowers) | Subagent-per-task dispatch, two-stage review, systematic debugging methodology, model selection by task complexity |
| [Spec Kit](https://github.com/github/spec-kit)     | Spec-driven development with executable specifications, multi-step refinement, cross-artifact validation           |

---

## 5. Multi-Repo Orchestration

When a feature spans multiple repositories, you need coordination across agents. The [Multi-Repo Orchestration](multi-repo-orchestration.md) guide covers agent tiers, epic lifecycle, cross-repo code review, and contract testing.
