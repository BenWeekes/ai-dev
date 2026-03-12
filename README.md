# AI-Assisted Development Guide

Practices and standards for working effectively with AI coding agents across repositories. Tool-agnostic — the principles here apply regardless of which AI coding tool you use.

---

## What's in This Repo

| Document | What It Is | Start Here If... |
|----------|-----------|-----------------|
| [Progressive Disclosure Documentation Standard](progressive-disclosure-standard.md) | A three-level documentation architecture (L0/L1/L2) that makes any git repo self-describing for AI agents and humans. The foundation everything else builds on. | You want to make a single repo easier for AI agents to work with. |
| [AI Coding Orchestration](ai-coding-orchestration.md) | A conceptual guide for coordinating AI agents across multiple repositories — agent tiers, epic lifecycle, cross-repo code review, contract testing. Builds on the PD standard. | You're thinking about how AI agents coordinate when a feature spans multiple repos. |

**Reading order:** Start with the Progressive Disclosure standard. The orchestration guide assumes familiarity with its concepts (L0 Repo Cards, L1 Operator Packs, identity blocks).

---

## AI Coding Best Practices

These apply to any AI coding tool. They're the habits that prevent AI-assisted development from creating more problems than it solves.

### Review Changes

- **Review plans before code is written.** Have the agent explain its approach and get your approval before it starts editing.
- **Review diffs before committing.** Use `git diff` to inspect what actually changed. Expand truncated output if needed.
- **Never push code you haven't reviewed.**

There's a spectrum here. Reviewing every diff line by line is the safest approach, but it's also slow. Combining Test Driven Development (tests pass or it's not done) with code review agents can reduce the need to read every line — the tests provide a mechanical safety net, and review agents catch issues you might miss. Git hooks (see below) add another layer by enforcing coding conventions and formatting automatically. Find the balance that matches your confidence in the agent and the risk of the change.

### Protect Sensitive Files

AI coding agents can typically read all files in your project. Prevent access to secrets:

- Block agent access to `.env`, `.env.local`, `.env.production`, and similar files.
- Block `config/secrets.*`, `**/private_key.pem`, and any credentials files.
- Most AI coding tools have a permissions or deny-list mechanism — use it.

### Commit Hygiene

- Commit each feature or logical change separately for easy rollback.
- Handle git commits yourself — don't let the agent auto-commit without review.
- Keep commit messages descriptive and lowercase (see git hooks below).

### Make Repos Self-Describing

AI agents work better when they can quickly understand a codebase. The [Progressive Disclosure Documentation Standard](progressive-disclosure-standard.md) provides a structured way to do this — a single Repo Card (L0) for orientation, an Operator Pack (L1) for working knowledge, and deep dives (L2) for complex areas.

Even without adopting the full standard, a well-maintained README, clear directory structure, and documented conventions go a long way.

---

## Git Hooks

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
