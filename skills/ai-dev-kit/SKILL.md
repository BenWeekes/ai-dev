---
name: ai-dev-kit
description: Git conventions and documentation generation for AI-assisted development. Enforces lowercase commits, no AI tool names, present tense. Use when committing, pushing, creating PRs, rebasing, or generating repo documentation.
---

# ai-dev-kit

Git conventions and progressive disclosure documentation for AI-assisted development.

## Git Conventions (always active)

These rules apply to every commit in repos that install ai-dev-kit:

- **Lowercase start** — commit messages begin with a lowercase letter
- **No AI tool names** — never mention claude, cursor, copilot, cody, aider, gemini, codex, chatgpt, or gpt-3/4
- **Present tense** — "add feature", not "added feature"
- **No Co-Authored-By trailers** — omit AI attribution lines
- **No --no-verify** — let git hooks run normally
- **No git config changes** — do not modify user.name or user.email

## Available Skills

### git

Git workflow skills for committing, pushing, PRs, and rebasing.

| Skill  | Description                                   |
| ------ | --------------------------------------------- |
| `ship` | commit staged changes and push to remote      |
| `pr`   | create a pull request from the current branch |
| `sync` | rebase current branch onto latest main        |

### docs

Documentation generation following the progressive disclosure standard.

| Skill    | Description                                                 |
| -------- | ----------------------------------------------------------- |
| `update` | generate or update progressive disclosure docs for the repo |
| `test`   | verify generated docs meet the standard                     |
