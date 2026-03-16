---
description: Create a pull request from the current branch
---

Create a pull request from the current branch to the base branch.

## Workflow

### 1. Determine branches

- Current branch: `git branch --show-current`
- Base branch: default to `main`. If `$ARGUMENTS` specifies a different base, use that.

If the current branch is the base branch, stop and tell the user to switch to a feature branch first.

### 2. Ensure branch is pushed

Check if the current branch has a remote tracking branch and is up to date. If not, push with `-u origin <current-branch>`.

### 3. Read changes

Run `git log <base>..HEAD --oneline` and `git diff <base>...HEAD --stat` to understand what changed.

### 4. Generate PR title and body

- **Title:** short (under 70 characters), lowercase start, describes the change
- **Body:** use this format:

```
## Summary
<1-3 bullet points summarizing the change>

## Test plan
<bulleted checklist of how to verify the change>
```

If `$ARGUMENTS` includes additional context, incorporate it into the summary.

### 5. Create the PR

Use `gh pr create --title "..." --body "..."` to create the pull request.

Print the PR URL when done.
