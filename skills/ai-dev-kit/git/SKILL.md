---
name: git
description: Git workflow skills — commit, push, PR, rebase. Use when the user wants to ship code, create a pull request, or sync with main.
---

# git

Git workflow skills that enforce ai-dev-kit commit conventions.

## Conventions

All git skills enforce these rules:

- lowercase start, present tense, no AI tool names
- no Co-Authored-By trailers
- no --no-verify (let hooks run)
- no git config changes

## Skills

| Skill  | Description                                   |
| ------ | --------------------------------------------- |
| `ship` | commit staged changes and push to remote      |
| `pr`   | create a pull request from the current branch |
| `sync` | rebase current branch onto latest main        |
