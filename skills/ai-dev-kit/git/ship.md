---
name: ship
description: Commit staged changes and push to remote. Use when the user says "ship it", "commit and push", or wants to send changes to the remote.
---

# ship

Commit the currently staged changes and push them to the remote.

## Rules

- Do NOT add a Co-Authored-By trailer
- Do NOT modify git config (user.name, user.email)
- Do NOT skip hooks (no --no-verify)

## Workflow

### 1. Check for staged changes

Run `git diff --cached --stat`. If there are no staged changes, stop and tell the user to stage files first.

### 2. Generate a commit message

If `$ARGUMENTS` is provided, use it as the commit message.

Otherwise, read the staged diff and generate a commit message:

- lowercase start, present tense, no AI tool names
- one concise line summarizing the change

### 3. Commit

Commit with the message. Let git hooks run normally.

### 4. Push

Push to the current branch's remote tracking branch.

If there is no upstream tracking branch, push with `-u origin <current-branch>`.
