---
name: test
description: Verify that generated progressive disclosure docs meet the standard. Use when the user wants to check doc quality or validate documentation.
---

# test

Verify that existing progressive disclosure documentation meets the standard.

## Workflow

### 1. Read the standard

Read `progressive-disclosure-standard.md` for the rules being checked.

### 2. Check structure

Verify these files exist:

- `docs/ai/L0_repo_card.md`
- `docs/ai/L1/01_*.md` through `docs/ai/L1/08_*.md`
- `docs/ai/L1/deep_dives/_index.md`
- At least 2 L2 deep dive files

### 3. Check L0

- Under 50 lines
- Contains Identity Block
- Contains L1 Index with links

### 4. Check L1 files

For each L1 file:

- 80-200 lines
- Starts with a one-line purpose statement
- Ends with `## Related Deep Dives`
- Cross-references resolve

Total L1: under 1,600 lines.

### 5. Check L2 files

For each L2 file:

- Starts with `> **When to Read This:** ...`
- Referenced from at least one L1 file

### 6. Check integration

- `AGENTS.md` exists with loading instructions
- `CLAUDE.md` references @AGENTS.md

### 7. Report

Output a pass/fail summary with specific violations listed.
