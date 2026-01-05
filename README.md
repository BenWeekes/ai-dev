# Claude Code Developer Guide

## Install Claude Code on Ubuntu 
```bash
sudo apt update
sudo apt install -y nodejs npm
sudo npm install -g @anthropic-ai/claude-code
```

## Install Claude Code on Mac 
```bash
npm install -g @anthropic-ai/claude-code
```

## Git Hooks for Code Quality

### commit-msg Hook
Enforces commit message standards: blocks "Claude" mentions and enforces lowercase start.

```bash
cat > .git/hooks/commit-msg << 'EOF'
#!/bin/bash
# Git hook to validate commit messages

# Read the commit message
commit_msg=$(cat "$1")

# Check for "claude" (case-insensitive)
if echo "$commit_msg" | grep -iq "claude"; then
    echo "❌ Commit rejected: Commit message contains 'claude'"
    echo "Please remove references to Claude from your commit message."
    exit 1
fi

# Check that commit message starts with lowercase letter
first_char=$(echo "$commit_msg" | head -c 1)
if [[ "$first_char" =~ ^[A-Z]$ ]]; then
    echo "❌ Commit rejected: Commit message must start with lowercase letter"
    echo "Your message: $commit_msg"
    exit 1
fi

# Allow the commit
exit 0
EOF

chmod +x .git/hooks/commit-msg
```

### pre-commit Hook
Runs lint checks and scans for secrets before allowing commits.

```bash
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Git hook to run lint and check for secrets before commit

echo "Running pre-commit checks..."

# Get list of staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

# Check for .env files
if echo "$STAGED_FILES" | grep -q "\.env"; then
    echo "❌ Commit rejected: .env file detected in staged changes"
    echo "Files:"
    echo "$STAGED_FILES" | grep "\.env"
    exit 1
fi

# Check for common secret patterns in staged files
SECRET_PATTERNS=(
    "API_KEY"
    "APIKEY"
    "SECRET"
    "TOKEN"
    "PASSWORD"
    "PRIVATE_KEY"
    "AWS_ACCESS_KEY"
    "AWS_SECRET"
    "CLIENT_SECRET"
    "AGORA_APP_ID"
    "AGORA_APP_CERTIFICATE"
)

for file in $STAGED_FILES; do
    # Skip binary files and deleted files
    if [ -f "$file" ]; then
        for pattern in "${SECRET_PATTERNS[@]}"; do
            # Look for pattern followed by = and what looks like a real value (not empty, not placeholder)
            if grep -qE "${pattern}\s*=\s*['\"]?[a-zA-Z0-9+/]{16,}" "$file"; then
                echo "❌ Commit rejected: Potential secret detected in $file"
                echo "Pattern matched: $pattern"
                echo "Please review the file and remove any API keys or secrets"
                exit 1
            fi
        done
    fi
done

# Run ESLint on staged TypeScript/JavaScript files
TS_FILES=$(echo "$STAGED_FILES" | grep -E '\.(ts|tsx|js|jsx)$')

if [ -n "$TS_FILES" ]; then
    echo "Running ESLint on staged files..."

    # Check if we're in the workspace root or a package
    if [ -f "pnpm-workspace.yaml" ]; then
        # Run from workspace root
        pnpm run lint:check 2>/dev/null || {
            # Fallback: run eslint directly on each file
            for file in $TS_FILES; do
                npx eslint "$file" || exit 1
            done
        }
    else
        # Run eslint directly
        for file in $TS_FILES; do
            npx eslint "$file" || exit 1
        done
    fi

    if [ $? -ne 0 ]; then
        echo "❌ Commit rejected: ESLint errors found"
        echo "Fix the errors and try again"
        exit 1
    fi
fi

echo "✅ Pre-commit checks passed"
exit 0
EOF

chmod +x .git/hooks/pre-commit
```

## Developer Setup and Best Practices

### Working Directory
Run Claude in the project root or its src root folder. Keep any sensitive keys or secret sauce code separate from Claude.

### Protecting Sensitive Files
Claude Code can read all files in your project by default. To prevent access to sensitive files like .env:

1. Type `/permissions` in Claude Code
2. Select `Deny` then enter a new rule: `Read(./.env)`
3. Save in either project settings (current project only) or user settings (all projects)

Consider also blocking other sensitive files:
- `Read(./.env.local)`
- `Read(./.env.production)`
- `Read(./config/secrets.*)`
- `Read(./**/private_key.pem)`

### Initial Setup
Run `/init` to create ai/claude.md - Claude will use this to document the codebase

### Code Review Process
- **Before editing**: Claude must show every line of code that will change and get approval
- **After editing**: Review changes again with `git diff` before committing
  - Use `Ctrl-O` to expand truncated diffs if needed
- For new files, review the entire file content before creation
- Commit each feature separately for easy rollback
- Handle all git commits manually (don't let Claude auto-commit)
- Never push to git without every line being approved

## Instructions to Give Claude at Session Start
Copy and paste these guidelines to Claude at the beginning of each session:
```
Please follow these guidelines for our work session:

## CRITICAL: Code Change Protocol
**YOU MUST FOLLOW THIS TWO-STAGE APPROVAL PROCESS FOR EVERY FILE CHANGE:**

### Stage 1: BEFORE editing any file
- Show me the EXACT changes you plan to make
- Include line numbers and full context
- Wait for my explicit approval with "approved" or "yes"
- DO NOT proceed without approval

### Stage 2: AFTER editing, BEFORE committing
- Run `git diff` on all modified files
- Show me the complete diff output
- For new files, show the entire file content
- Wait for my explicit approval before committing
- I may need to use Ctrl-O to expand truncated diffs

## File Organization Rules
1. Keep all ai related .md files in an ai subfolder
2. Create a separate directory for each feature within ai/ to keep it organized
3. Do not mention Claude in code comments or git commits
4. Write updates on what has been done regularly in case the session exits

## Workflow
Use this file structure:
- `ai/claude.md`                        # codebase documentation (update as work progresses)
- `ai/feature_<identifier>/feature.md`  # feature requirements. Created by me.
- `ai/feature_<identifier>/plan.md`     # work plan for the feature. created and edited by AI.
- `ai/feature_<identifier>/status.md`   # current progress and updated regularly by AI

**Where `<identifier>` can be:**
- A descriptive label: `fix_high_cpu`, `user_auth`, `payment_integration`, etc.
- An ID: `0001`, `JIRA-456`, `GH-789`, etc.

**If the feature identifier is not provided, AI will ask:** 
*"What would you like to call this feature? (e.g., a descriptive name like 'fix_high_cpu' or an ID like '0001')"*

Before starting any feature:
1. Review the feature requirements in `ai/feature_<identifier>/feature.md`
2. Create or update `ai/feature_<identifier>/plan.md` with your approach
3. Wait for approval before implementing
4. Update `ai/feature_<identifier>/status.md` regularly as you work

**REMEMBER: No file edits without showing changes first. No commits without showing git diff. No exceptions.**
```
