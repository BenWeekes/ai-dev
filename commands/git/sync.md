---
description: Rebase current branch onto the latest main
---

Pull the latest changes from the main branch and rebase the current branch on top.

## Workflow

### 1. Fetch latest

Run `git fetch origin`.

### 2. Rebase

Run `git rebase origin/main`.

### 3. Handle conflicts

If the rebase encounters conflicts:

- Report which files have conflicts
- Stop and tell the user to resolve them manually
- Do NOT force resolve or use `--skip`/`--abort` without the user asking
