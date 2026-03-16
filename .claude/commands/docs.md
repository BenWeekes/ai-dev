---
description: Generate progressive disclosure documentation for the repo
---

Generate progressive disclosure documentation for this repository following the standard in `progressive-disclosure-standard.md`.

## Workflow

### 1. Read the standard

Read `progressive-disclosure-standard.md` to understand the L0/L1/L2 architecture, file naming rules, token budgets, and content density targets.

### 2. Analyze the repository

- List the directory structure (top 3 levels)
- Read config files (package.json, Cargo.toml, go.mod, pyproject.toml, Dockerfile, CI config)
- Identify repo type: api-service, frontend-app, sdk-library, infrastructure, distributed-system, data-pipeline, ml-model
- Read entry point files and primary source directories
- Identify the top 10-15 critical files/directories
- Map the primary data flow

### 3. Generate docs

Create files in this order:

1. `mkdir -p docs/ai/L1_operator_pack/deep_dives`
2. `docs/ai/L0_repo_card.md` — Identity Block + L1 Index
3. L1 files 01 through 08 in `docs/ai/L1_operator_pack/`
4. `docs/ai/L1_operator_pack/deep_dives/_index.md`
5. L2 deep dive files (2-4 minimum)

### 4. Verify

- All cross-references resolve (relative links between L0 → L1 → L2)
- L0 is under 50 lines
- Each L1 file is 80-200 lines
- Each L1 file starts with a one-line purpose statement
- Each L1 file ends with `## Related Deep Dives`
- Total L1 is under 1,600 lines
- L2 files start with `> **When to Read This:** ...`
