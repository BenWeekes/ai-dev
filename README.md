# Claude Code Developer Guide

## Install Claude Code on Ubuntu 
```bash
sudo apt install -y nodejs npm
npm install -g @anthropic-ai/claude-code
```

## Install Claude Code on Mac 
```bash
npm install -g @anthropic-ai/claude-code
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
- ai/claude.md              # codebase documentation (update as work progresses)
- ai/feature_XXXX/feature.md  # feature requirements (XXXX is the feature id)
- ai/feature_XXXX/plan.md     # work plan for the feature
- ai/feature_XXXX/status.md   # current progress and updates

Before starting any feature:
1. Review the feature requirements in ai/feature_XXXX/feature.md
2. Create or update ai/feature_XXXX/plan.md with your approach
3. Wait for approval before implementing
4. Update ai/feature_XXXX/status.md regularly as you work

REMEMBER: No file edits without showing changes first. No commits without showing git diff. No exceptions.
```
