# AI-Assisted Development Guide

Start here for AI-assisted coding. This guide covers the single-repo workflow — the practices that make AI coding effective and safe. Tool-agnostic, though we recommend Claude Code for the best experience.

For coordinating AI agents across multiple repositories, see [Multi-Repo Orchestration](multi-repo-orchestration.md).

---

## 1. AI Coding Tools

| Tool | What It Is |
|------|-----------|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | Anthropic's CLI agent. Terminal-native, agentic, strong at multi-file edits. Recommended. |
| [Cursor](https://cursor.sh) | VS Code fork with inline AI. Good for visual editing workflows. |
| [GitHub Copilot](https://github.com/features/copilot) | GitHub's AI pair programmer. Inline completions and chat in VS Code/JetBrains. |
| [Cody](https://sourcegraph.com/cody) | Sourcegraph's coding assistant. Strong codebase-aware context via code graph. |
| [Aider](https://aider.chat) | Open-source CLI agent. Git-native, works with multiple LLM providers. |

Everything in this guide works with any of these tools. The practices are about *how you work*, not which tool you use.

---

## 2. The Single-Repo Workflow

### 2.1 Plan Before You Code

Have the agent explain its approach before it starts editing files. A plan catches wrong assumptions before they become wrong code.

**What a plan includes:**

- **Problem:** What are we solving?
- **Approach:** How will we solve it?
- **Acceptance criteria:** How do we know it's done?
- **Files to change:** Which files will be created or modified?

Store plans in `docs/plans/` inside the repo. They're markdown files, version-controlled and reviewable in PRs. Old plans serve as context for future agents — they show how the codebase evolved and why.

#### Sharing Plans for Review

Plans are cheap to review. Include them in PRs:

- Create a plan file in `docs/plans/` before starting implementation
- Open a draft PR with just the plan for early feedback
- Tag both human reviewers and (optionally) AI review agents
- Merge the plan alongside the implementation it describes

#### Verifying Plans with Multiple Agents

Before implementing, have a second agent review the plan. Use a different tool or a separate session for an independent perspective.

This is cheap — plans are small documents. The second agent checks for:

- Missed edge cases
- Simpler alternatives
- Architectural issues the first agent didn't consider
- Files or dependencies the plan overlooks

Two agents disagreeing on approach is a signal to involve a human before any code is written.

### 2.2 Test Driven Development

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

### 2.3 Review Changes

- **Review plans before code is written.** Have the agent explain its approach and get your approval before it starts editing.
- **Review diffs before committing.** Use `git diff` to inspect what actually changed. Expand truncated output if needed.
- **Never push code you haven't reviewed.**

There's a spectrum here. Reviewing every diff line by line is the safest approach, but it's also slow. Combining Test Driven Development (tests pass or it's not done) with code review agents can reduce the need to read every line — the tests provide a mechanical safety net, and review agents catch issues you might miss. Git hooks (see below) add another layer by enforcing coding conventions and formatting automatically. Find the balance that matches your confidence in the agent and the risk of the change.

### 2.4 Commit Hygiene

- Commit each feature or logical change separately for easy rollback.
- Handle git commits yourself — don't let the agent auto-commit without review.
- Keep commit messages descriptive and lowercase (see git hooks below).

### 2.5 Protect Sensitive Files

AI coding agents can typically read all files in your project. Prevent access to secrets:

- Block agent access to `.env`, `.env.local`, `.env.production`, and similar files.
- Block `config/secrets.*`, `**/private_key.pem`, and any credentials files.
- Most AI coding tools have a permissions or deny-list mechanism — use it.

---

## 3. Where Plans Live

Store plans in `docs/plans/` inside the repo. They're version-controlled, reviewable, and serve as historical context.

### Plan Template

```markdown
# Plan: [Short Title]

## Problem

[What are we solving? 2-3 sentences.]

## Approach

[How will we solve it? Bullet points.]

## Acceptance Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

## Files to Change

| File | Action |
|------|--------|
| `path/to/file` | Create / Modify / Delete |

## Open Questions

- [Anything unresolved that needs human input]
```

### Why Plans Accumulate

Old plans are useful. When a new agent session starts, it can read `docs/plans/` to understand:

- What was already tried and why
- How the codebase got to its current state
- What design decisions were made and their rationale

Don't delete plans after implementation. They're lightweight documentation that costs nothing to keep.

---

## 4. Make Repos Self-Describing

AI agents work better when they can quickly understand a codebase. The [Progressive Disclosure Documentation Standard](progressive-disclosure-standard.md) provides a structured way to do this — a single Repo Card (L0) for orientation, an Operator Pack (L1) for working knowledge, and deep dives (L2) for complex areas.

Even without adopting the full standard, a well-maintained README, clear directory structure, and documented conventions go a long way.

---

## 5. Git Hooks

Git hooks enforce what agents (and humans) can't easily forget: coding conventions, code formatting, commit message standards, and author control. They run automatically on every commit, so quality checks don't depend on anyone remembering to run them.

The hooks below are language-aware and work across JavaScript/TypeScript, Python, JSON, Markdown, and CSS.

### commit-msg Hook

Enforces commit message standards: blocks AI tool name mentions, enforces lowercase start.

```bash
cat > .git/hooks/commit-msg << 'EOF'
#!/bin/bash
commit_msg=$(cat "$1")

if echo "$commit_msg" | grep -iq "claude"; then
    echo "Commit rejected: message contains 'claude'"
    exit 1
fi

first_char=$(echo "$commit_msg" | head -c 1)
if [[ "$first_char" =~ ^[A-Z]$ ]]; then
    echo "Commit rejected: message must start with lowercase letter"
    exit 1
fi

exit 0
EOF
chmod +x .git/hooks/commit-msg
```

### pre-commit Hook

Runs lint and format checks on staged files, plus security scans for secrets and `.env` files.

**What it checks:**
- **Security:** Blocks `.env` files and files containing potential secrets (API keys, tokens, passwords)
- **JavaScript/TypeScript:** ESLint + Prettier
- **Python:** ruff (linting) + black (formatting) — warns if not installed
- **JSON/Markdown/CSS:** Prettier

**Prerequisites:**
- JavaScript/TypeScript: `pnpm install` (installs ESLint, Prettier)
- Python: `pip install black ruff` (optional)

**Auto-fix commands:**

| Command | What It Fixes |
|---------|--------------|
| `pnpm lint:fix` | JS/TS lint errors |
| `pnpm format` | JS/TS/JSON/MD/CSS formatting |
| `pnpm lint:py:fix` | Python lint errors |
| `pnpm format:py` | Python formatting |
| `pnpm format:all` | All languages |
| `pnpm lint:all` | All languages |

<details>
<summary>Full pre-commit hook script</summary>

```bash
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "Running pre-commit checks..."

STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)
if [ -z "$STAGED_FILES" ]; then
    echo "No files staged for commit"
    exit 0
fi

CHECKS_FAILED=0

# --- Security checks ---

echo "→ Checking for .env files..."
if echo "$STAGED_FILES" | grep -E "\.env$|\.env\."; then
    FORBIDDEN_ENV_FILES=$(echo "$STAGED_FILES" | grep -E "\.env$|\.env\." | grep -v "\.env\.example$")
    if [ -n "$FORBIDDEN_ENV_FILES" ]; then
        echo "Commit rejected: .env file detected"
        echo "$FORBIDDEN_ENV_FILES"
        exit 1
    fi
fi

echo "→ Scanning for secrets..."
SECRET_PATTERNS=(
    "API_KEY" "APIKEY" "SECRET" "TOKEN" "PASSWORD"
    "PRIVATE_KEY" "AWS_ACCESS_KEY" "AWS_SECRET"
    "CLIENT_SECRET" "AGORA_APP_ID" "AGORA_APP_CERTIFICATE"
)
for file in $STAGED_FILES; do
    if [ -f "$file" ]; then
        for pattern in "${SECRET_PATTERNS[@]}"; do
            if grep -qE "${pattern}\s*=\s*['\"]?[a-zA-Z0-9+/]{16,}" "$file"; then
                echo "Commit rejected: potential secret in $file (matched: $pattern)"
                exit 1
            fi
        done
    fi
done

# --- JavaScript/TypeScript ---

TS_FILES=$(echo "$STAGED_FILES" | grep -E '\.(ts|tsx|js|jsx)$' || true)
if [ -n "$TS_FILES" ]; then
    echo "→ Running ESLint..."
    for file in $TS_FILES; do
        if ! npx eslint "$file" 2>/dev/null; then
            echo "ESLint failed: $file"
            CHECKS_FAILED=1
        fi
    done
    if [ $CHECKS_FAILED -eq 1 ]; then
        echo "Run 'pnpm lint:fix' to auto-fix"
        exit 1
    fi

    echo "→ Running Prettier..."
    for file in $TS_FILES; do
        if ! npx prettier --check "$file" 2>/dev/null; then
            echo "Prettier failed: $file"
            CHECKS_FAILED=1
        fi
    done
    if [ $CHECKS_FAILED -eq 1 ]; then
        echo "Run 'pnpm format' to auto-fix"
        exit 1
    fi
fi

# --- Python ---

PY_FILES=$(echo "$STAGED_FILES" | grep '\.py$' || true)
if [ -n "$PY_FILES" ]; then
    if command -v ruff &> /dev/null; then
        echo "→ Running ruff..."
        for file in $PY_FILES; do
            if ! ruff check "$file" 2>/dev/null; then
                CHECKS_FAILED=1
            fi
        done
        if [ $CHECKS_FAILED -eq 1 ]; then
            echo "Run 'pnpm lint:py:fix' to auto-fix"
            exit 1
        fi
    else
        echo "ruff not found - skipping Python lint (install: pip install ruff)"
    fi

    if command -v black &> /dev/null; then
        echo "→ Running black..."
        for file in $PY_FILES; do
            if ! black --check "$file" 2>/dev/null; then
                CHECKS_FAILED=1
            fi
        done
        if [ $CHECKS_FAILED -eq 1 ]; then
            echo "Run 'pnpm format:py' to auto-fix"
            exit 1
        fi
    else
        echo "black not found - skipping Python format (install: pip install black)"
    fi
fi

# --- JSON/Markdown/CSS ---

OTHER_FILES=$(echo "$STAGED_FILES" | grep -E '\.(json|md|css|scss)$' || true)
if [ -n "$OTHER_FILES" ]; then
    echo "→ Running Prettier..."
    for file in $OTHER_FILES; do
        if ! npx prettier --check "$file" 2>/dev/null; then
            CHECKS_FAILED=1
        fi
    done
    if [ $CHECKS_FAILED -eq 1 ]; then
        echo "Run 'pnpm format' to auto-fix"
        exit 1
    fi
fi

# --- Result ---

if [ $CHECKS_FAILED -eq 0 ]; then
    echo "All pre-commit checks passed"
    exit 0
else
    echo "Pre-commit checks failed"
    exit 1
fi
EOF
chmod +x .git/hooks/pre-commit
```

</details>

---

## 6. Computer Use Agents (CUA)

Computer Use Agents interact with running applications through a browser or UI — clicking buttons, filling forms, navigating pages. They test the integrated system the way a user would.

**Use cases:**

- **E2E validation:** Verify that a feature works end-to-end in the actual running application
- **UI regression:** Catch visual or interaction regressions that unit tests can't detect
- **Exploratory testing:** Have an agent explore the app looking for broken flows or unexpected behavior

CUA complements unit and integration tests — it doesn't replace them. Unit tests are fast and precise. CUA tests are slow but realistic. Use both.

For CUA in multi-repo scenarios (testing integrated systems across multiple codebases), see [Multi-Repo Orchestration](multi-repo-orchestration.md).

---

## 7. What's in This Repo

| Document | What It Is | Start Here If... |
|----------|-----------|-----------------|
| [README](README.md) (this file) | Single-repo AI coding workflow: planning, TDD, review, git hooks, CUA. | You want to start AI-assisted coding on a project. |
| [Progressive Disclosure Documentation Standard](progressive-disclosure-standard.md) | A three-level documentation architecture (L0/L1/L2) that makes any git repo self-describing for AI agents and humans. | You want to make a repo easier for AI agents to work with. |
| [Multi-Repo Orchestration](multi-repo-orchestration.md) | A conceptual guide for coordinating AI agents across multiple repositories — agent tiers, epic lifecycle, cross-repo code review, contract testing. | You're thinking about how AI agents coordinate when a feature spans multiple repos. |

**Reading order:** Start with this README. Then the Progressive Disclosure standard if you want self-describing repos. The multi-repo orchestration guide builds on both.
