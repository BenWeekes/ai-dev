---
description: Generate progressive disclosure documentation for the repo
---

Generate progressive disclosure documentation for this repository following the standard in `progressive-disclosure-standard.md`.

## Workflow

### 1. Read the standard

Read `progressive-disclosure-standard.md` to understand the L0/L1/L2 architecture, file naming rules, token budgets, and content density targets.

### 2. Read existing project context

Read all markdown files and config/setup files in the repo root first — these contain project decisions, conventions, and context that should inform the generated docs:

- All `*.md` files (README, CLAUDE.md, AGENTS.md, CONTRIBUTING, CHANGELOG, etc.)
- Config files: package.json, Cargo.toml, go.mod, pyproject.toml, Dockerfile, docker-compose.yml, Makefile, CI config
- Setup scripts: init.sh, bootstrap.sh, setup.py, etc.

### 3. Map and deep-read the codebase

1. List the directory structure (top 3 levels)
2. Identify repo type: api-service, frontend-app, sdk-library, infrastructure, distributed-system, data-pipeline, ml-model
3. Identify the major modules, packages, or service boundaries

For each major module:

- Read all source files (or a representative set if the module is very large)
- Summarize: purpose, key abstractions, public interfaces, internal patterns, external dependencies, gotchas (TODO/FIXME/HACK, complex conditionals, retry logic, environment-specific behavior)

For large repos, analyze each module as a separate sub-agent task and collect the summaries before proceeding.

### 4. Synthesize and plan

Using the module summaries:

- Map the primary data flow across the whole system
- Identify coding conventions consistent across modules
- Identify all external interfaces (APIs, databases, queues, caches)
- Compile gotchas from all modules
- List key topics for each L1 file (3-5 per file)
- Identify 2-4 L2 deep dive topics

### 5. Generate docs

Create files in this order:

1. `mkdir -p docs/ai/L1/deep_dives`
2. `docs/ai/L0_repo_card.md` — Identity Block + L1 Index
3. L1 files 01 through 08 in `docs/ai/L1/`
4. `docs/ai/L1/deep_dives/_index.md`
5. L2 deep dive files (2-4 minimum)

Also create or update:

- `AGENTS.md` at repo root with loading instructions
- `CLAUDE.md` at repo root referencing @AGENTS.md (add reference if file exists, create if not)

### 6. Verify

- All cross-references resolve (relative links between L0 → L1 → L2)
- L0 is under 50 lines
- Each L1 file is 80-200 lines
- Each L1 file starts with a one-line purpose statement
- Each L1 file ends with `## Related Deep Dives`
- Total L1 is under 1,600 lines
- L2 files start with `> **When to Read This:** ...`
- CLAUDE.md references @AGENTS.md
