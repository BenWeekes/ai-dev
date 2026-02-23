# Progressive Disclosure Documentation Standard

## Enterprise Standard for Self-Describing Git Repositories

**Version:** 1.2
**Status:** Active
**Last Updated:** 2026-02-23

> **Upgrading from a previous version?** Re-run the generation prompt (Section 6) against your repo. The prompt embeds the current standard — generated output will conform to the latest structure. No manual migration steps are needed unless the L1 file set changes (it hasn't since v1.0).

---

## Table of Contents

- [1. Quick-Start Summary](#1-quick-start-summary)
- [2. Introduction and Motivation](#2-introduction-and-motivation)
- [3. The Standard: L0 / L1 / L2 Architecture](#3-the-standard-l0--l1--l2-architecture)
  - [3.1 Architecture Overview](#31-architecture-overview)
  - [3.2 L0 — The Repo Card](#32-l0--the-repo-card)
  - [3.3 L1 — The Operator Pack](#33-l1--the-operator-pack)
  - [3.4 L2 — Deep Dives](#34-l2--deep-dives)
- [4. Base Conventions](#4-base-conventions)
  - [4.1 Directory Structure](#41-directory-structure)
  - [4.2 File Naming Rules](#42-file-naming-rules)
  - [4.3 Linking Patterns](#43-linking-patterns)
  - [4.4 Content Density Targets](#44-content-density-targets)
  - [4.5 Anti-Patterns](#45-anti-patterns)
  - [4.6 Freshness and Maintenance](#46-freshness-and-maintenance)
  - [4.7 AGENTS.md and CLAUDE.md Integration](#47-agentsmd-and-claudemd-integration)
- [5. Specializing for Repo Types](#5-specializing-for-repo-types)
  - [5.1 API Service / Backend](#51-api-service--backend)
  - [5.2 Frontend Application](#52-frontend-application)
  - [5.3 SDK / Library](#53-sdk--library)
  - [5.4 Infrastructure / IaC](#54-infrastructure--iac)
  - [5.5 Adaptation Notes](#55-adaptation-notes-for-other-repo-types)
- [6. Prompt: Generate Docs for an Existing Repo](#6-prompt-generate-docs-for-an-existing-repo)
- [7. Prompt: Bootstrap Docs for a New Repo](#7-prompt-bootstrap-docs-for-a-new-repo)
- [8. Appendices](#8-appendices)

---

## 1. Quick-Start Summary

This standard defines a **three-level documentation architecture (L0 / L1 / L2)** that makes any git repository self-describing for both AI coding agents and human engineers.

| Level | Name | What It Is | Token Budget |
|-------|------|-----------|-------------|
| **L0** | Repo Card | Identity + L1 index. Always read first. Single file. | 300–500 |
| **L1** | Operator Pack | Structured summaries for standard work. 7 fixed files. | 300–600 each |
| **L2** | Deep Dives | Full specs and subsystem docs. Loaded only when needed. | No ceiling |

**Where docs live:** `docs/ai/` directory in every repository.

**Entry point:** `AGENTS.md` at repo root explains the system and points to `docs/ai/L0_repo_card.md`.

**Loading rule:** Start at L0. Load all 7 L1 files (they're small). Go to L2 only when L1 isn't detailed enough.

---

## 2. Introduction and Motivation

### 2.1 The Problem

AI coding agents loading an entire codebase into context is expensive, slow, and error-prone. Agents hallucinate when given too much irrelevant information. Most repositories have either no documentation, or a single sprawling README/wiki that forces full-context loading regardless of the task.

### 2.2 The Insight

80% of agent tasks — config changes, bug fixes, small features — need only the L1 summaries, not the full L2 deep dives. Progressive disclosure exploits this by separating essential working knowledge (L1, loaded upfront) from deep reference material (L2, loaded on demand).

### 2.3 Design Goals

- **Token efficiency** — Minimize context window usage for AI agents (reduces cost, latency, and hallucination)
- **Multi-agent readiness** — Self-describing repos that can be loaded on demand by any orchestration layer
- **Human onboarding** — The same docs serve new engineers joining a team
- **Consistency** — Predictable structure across all enterprise repos enables shared tooling and enterprise-wide repo discovery
- **Framework agnosticism** — Works with any language, framework, or AI tool

---

## 3. The Standard: L0 / L1 / L2 Architecture

### 3.1 Architecture Overview

```
                    ┌─────────┐
                    │   L0    │  ← Always loaded (1 file, 300-500 tokens)
                    │Repo Card│     Identity + L1 index
                    └────┬────┘
                         │
              ┌──────────┼──────────┐
              ▼          ▼          ▼
         ┌────────┐ ┌────────┐ ┌────────┐
         │L1 File │ │L1 File │ │L1 File │  ← Load ALL at session start (~3,500 tokens total)
         │ Setup  │ │Workflow│ │  Map   │     Structured summaries (× 7 files)
         └────┬───┘ └────────┘ └────────┘
              │
              ▼
         ┌─────────┐
         │L2 Deep  │  ← Load only for complex changes (no ceiling)
         │  Dive   │     Full specs, diagrams, decision records
         └─────────┘

  Frequency of access:  HIGH ◄──────────────────────► LOW
  Token cost per task:  LOW  ◄──────────────────────► HIGH
```

#### Agent Loading Protocol

1. **Load L0.** Read `docs/ai/L0_repo_card.md` to identify the repo and see the L1 index.
2. **Load all L1.** Read all 7 files in `docs/ai/L1_operator_pack/`. Total is ~3,000–4,500 tokens — small enough to load upfront. This gives you the critical knowledge for every branch of the repo.
3. **Follow L2 links only if needed.** If an L1 file references a deep dive and the task requires more detail than L1 provides, load the specific L2 document. Never load all L2 docs.

#### Loading Examples

**Config change** ("Update the Redis connection timeout"):
```
Load L0 → load all L1 → 01_setup.md has the answer → done. No L2 needed.
Total: ~3,500–5,000 tokens
```

**Standard feature** ("Add a new /users endpoint"):
```
Load L0 → load all L1 → 05_workflows.md + 04_conventions.md have what you need → done.
Total: ~3,500–5,000 tokens
```

**Complex change** ("Refactor the WebSocket event system"):
```
Load L0 → load all L1 → 02_architecture.md + 06_interfaces.md give overview →
need more detail → deep_dives/websocket_system.md → done.
Total: ~5,000–7,000 tokens
```

> **Why load all L1?** Total L1 is ~3,000–4,500 tokens — roughly the size of a single page of prose. Loading everything upfront means the agent has every critical gotcha, every workflow, every convention from the start. This eliminates wrong guesses about which files are relevant and costs less than a single wasted tool call.

#### Token Budget Targets

| Component | Target | Hard Ceiling |
|-----------|--------|-------------|
| L0 (Repo Card) | 300–500 tokens | 600 tokens |
| Each L1 file | 300–600 tokens | 800 tokens |
| All 7 L1 files combined | 2,100–4,200 tokens | 5,600 tokens |
| L0 + all L1 (session baseline) | 2,400–4,700 tokens | 6,200 tokens |
| L2 files | No target | No ceiling (self-contained) |

---

### 3.2 L0 — The Repo Card

**Purpose:** Single point of entry. Identifies the repo and indexes L1 files. An AI agent reads L0 to orient itself, then loads all 7 L1 files. L0 is the table of contents; L1 is the substance.

**File:** `docs/ai/L0_repo_card.md`

#### Required Sections (in order)

1. **Identity Block** — Repo name, one-line description, primary language/framework, deployment target, owning team, repo type, last reviewed date
2. **L1 Index** — The 7 L1 files listed with their one-line purpose statements

That's it. L0 is lean by design. Everything else lives in L1.

#### Why L0 Is Minimal

L0 contains only identity and an index because agents load all L1 upfront. There's no need for routing tables, gotcha summaries, or quick commands in L0 when the total L1 cost is only ~3,000–4,500 tokens. Detailed content lives where it naturally belongs:

| Content | Lives In |
|---------|---------|
| Core file listings | `03_code_map.md` |
| Quick commands | `01_setup.md` |
| Gotchas | `07_gotchas.md` |
| Task-based navigation | Not needed — agent already has all L1 |

#### Identity Block — Enterprise Discovery

The Identity Block serves double duty: it orients agents working in this repo, AND it enables **enterprise-wide repo discovery**. A central registry can scrape all L0 files across the organization to build a map of every repo, its type, owner, language, and deployment target.

| Field | Value | Discovery Use |
|-------|-------|--------------|
| `repo` | `org/repo-name` | Unique identifier |
| `type` | `api-service` | Filter repos by kind |
| `language` | `TypeScript + Express` | Find repos by tech stack |
| `deploy_target` | `AWS ECS (Fargate)` | Map deployment topology |
| `owner` | `Telephony Squad` | Route questions to the right team |
| `description` | One-line summary | Search and browse |
| `last_reviewed` | `2026-02-15` | Track freshness across org |

#### L0 Template

```markdown
# [Repo Name] — Repo Card

> [One-line description of what this repo does]

## Identity

| Field | Value |
|-------|-------|
| Repo | `[org/repo-name]` |
| Type | `[api-service / frontend-app / sdk-library / infrastructure]` |
| Language | [Primary language and framework] |
| Deploy Target | [Where this runs — e.g., AWS ECS, Vercel, Kubernetes] |
| Owner | [Team or squad name] |
| Last Reviewed | [YYYY-MM-DD] |

## L1 Operator Pack

| File | Purpose |
|------|---------|
| [01_setup](L1_operator_pack/01_setup.md) | Environment setup, quick commands, env vars |
| [02_architecture](L1_operator_pack/02_architecture.md) | System design, component diagram, data flow |
| [03_code_map](L1_operator_pack/03_code_map.md) | Directory tree, module map, "where does X live?" |
| [04_conventions](L1_operator_pack/04_conventions.md) | Naming, patterns, error handling, testing |
| [05_workflows](L1_operator_pack/05_workflows.md) | Step-by-step: add endpoint, deploy, migrate |
| [06_interfaces](L1_operator_pack/06_interfaces.md) | API contracts, event schemas, DB schemas |
| [07_gotchas](L1_operator_pack/07_gotchas.md) | Critical gotchas, tribal knowledge, incident lessons |
```

---

### 3.3 L1 — The Operator Pack

**Purpose:** Structured summaries covering all critical knowledge. Agents load all 7 files at session start (~3,000–4,500 tokens total). This is the primary working knowledge layer — most tasks complete here without needing L2.

**Directory:** `docs/ai/L1_operator_pack/`

#### Standard File Set (7 files — fixed, never omit any)

| # | File | Purpose | Typical Content |
|---|------|---------|----------------|
| 01 | `01_setup.md` | Environment and local dev | Prerequisites, install steps, env vars, local run, quick commands, common setup failures |
| 02 | `02_architecture.md` | System design at a glance | Component diagram (ASCII), data flow, key abstractions, tech stack rationale |
| 03 | `03_code_map.md` | Navigate the codebase | Directory tree with annotations, module responsibilities, core files table |
| 04 | `04_conventions.md` | How we write code here | Naming, file structure, error handling, logging, testing patterns |
| 05 | `05_workflows.md` | How to do common tasks | Step-by-step: add endpoint, add migration, deploy, handle incident |
| 06 | `06_interfaces.md` | Boundary contracts | API schemas, event formats, DB schemas, external service contracts |
| 07 | `07_gotchas.md` | Gotchas and tribal knowledge | Dangerous pitfalls, incident lessons, environment-specific behaviors |

> **Why 7 files is fixed:** If a repo has no external interfaces, `06_interfaces.md` says "This repo has no external interfaces." It is **not** omitted. Predictability enables tooling and agent expectations.

#### L1 File Rules

- **Starts** with a one-line purpose statement after the title.
- **Ends** with a `## Related Deep Dives` section (links to relevant L2 docs, or "None").
- **Content format:** H2 headers, bullet lists, tables, short code blocks. No narrative prose longer than 3 sentences.
- **Independence:** Each file is independently useful. No required reading order between L1 files.
- **Line budget:** 80–200 lines per file.

#### L1 File Template

```markdown
# [NN] [Title]

> [One-line purpose statement]

## [Section H2]

- Bullet point content
- Structured for scanning, not reading

## [Section H2]

| Column | Column |
|--------|--------|
| Data   | Data   |

## Related Deep Dives

- [Topic Name](deep_dives/topic_name.md) — One-line description
- None
```

---

### 3.4 L2 — Deep Dives

**Purpose:** Full architecture docs, specifications, and subsystem deep-dives. Loaded only for complex, cross-cutting changes.

**Directory:** `docs/ai/L1_operator_pack/deep_dives/`

> **Why under L1?** L2 is an *extension* of L1, not a sibling. An agent navigating from an L1 file to an L2 deep dive follows a simple relative path: `deep_dives/topic_name.md`.

#### Index File (Required)

Every repo with L2 docs MUST have `docs/ai/L1_operator_pack/deep_dives/_index.md`:

```markdown
# Deep Dives Index

| Document | Summary | Load When |
|----------|---------|-----------|
| [call_routing.md](call_routing.md) | SIP call routing logic and decision tree | Modifying call flow or adding routing rules |
| [websocket_system.md](websocket_system.md) | Real-time event system architecture | Changing WebSocket handlers or event schema |
```

#### Rules

- **Naming:** Lowercase, snake_case, descriptive. No number prefix. No subdirectories.
- **Self-contained:** Each deep dive includes enough context to be read without other L2 docs.
- **"When to Read This" callout:** Every L2 file starts with this callout.
- **No length ceiling,** but chunked into scannable sections with clear H2/H3 structure.
- **When to create:** If an L1 file needs >10 lines to explain a subsystem, that becomes an L2 deep dive.

#### L2 Example: `websocket_system.md`

```markdown
# WebSocket System

> **When to Read This:** Load this document when you are modifying WebSocket event
> handlers, changing the event schema, or debugging real-time notification issues.

## Overview

The WebSocket system provides real-time event notifications to connected clients.
Built on the `ws` library with a pub/sub pattern internally.

## Architecture

    Call Handler ──publish──▶ EventBus ──route──▶ WebSocket Connections
                                │                        │
                                ▼                        ▼
                          Redis Pub/Sub           Client receives
                         (multi-instance)          JSON message

## Event Types

| Event Type | Payload | Published When |
|-----------|---------|---------------|
| `call.initiated` | `{ callId, from, to }` | New inbound/outbound call |
| `call.state_changed` | `{ callId, oldState, newState }` | Call state machine transition |
| `call.ended` | `{ callId, reason, duration }` | Call terminated |

## Gotchas

- **Redis pub/sub does not persist messages.** Missed events during disconnect
  require REST API polling to catch up.
- **EventBus topic filters use glob syntax, not regex.** `call.*` matches
  `call.initiated` but not `call.state.changed` (use `call.**` for nested topics).

## See Also

- [Back to Architecture](../02_architecture.md)
- [Back to Interfaces](../06_interfaces.md)
```

---

## 4. Base Conventions

These rules apply to **every repository** regardless of type, language, or framework.

### 4.1 Directory Structure

```
repo-root/
├── AGENTS.md                              # Universal AI entry point
├── CLAUDE.md                              # Thin redirect to AGENTS.md
└── docs/
    └── ai/
        ├── L0_repo_card.md                # L0 — always exactly this name
        └── L1_operator_pack/              # L1 — always exactly this directory name
            ├── 01_setup.md                # L1 — fixed file set
            ├── 02_architecture.md
            ├── 03_code_map.md
            ├── 04_conventions.md
            ├── 05_workflows.md
            ├── 06_interfaces.md
            ├── 07_gotchas.md
            └── deep_dives/                # L2 — extension of L1
                ├── _index.md              # Required if any L2 files exist
                ├── call_routing.md        # Example L2 files
                └── websocket_system.md
```

**Rules:**

- The `docs/ai/` path is **mandatory** and must not be changed or aliased.
- No files outside `docs/ai/` are part of the progressive disclosure system (except `AGENTS.md` at repo root).
- No other files may be added to `L1_operator_pack/` besides the 7 standard files and the `deep_dives/` directory.

### 4.2 File Naming Rules

| Level | Naming Rule | Examples |
|-------|------------|---------|
| L0 | Exact name: `L0_repo_card.md` | `L0_repo_card.md` |
| L1 | `NN_name.md` — zero-padded number + snake_case | `01_setup.md`, `05_workflows.md` |
| L2 | snake_case, no number prefix | `call_routing.md`, `auth_flow.md` |
| L2 Index | Exact name: `_index.md` | `_index.md` |

- L1 files use the exact names listed in Section 3.3. No variations.
- L2 file names: descriptive nouns, not verbs (`auth_flow.md` not `authenticate.md`).
- No subdirectories within `deep_dives/` — flat structure only.

### 4.3 Linking Patterns

All links between progressive disclosure files use **relative paths**:

| From | To | Pattern |
|------|----|---------|
| L0 → L1 | `[Setup](L1_operator_pack/01_setup.md)` | Relative from `docs/ai/` |
| L1 → L2 | `[Call Routing](deep_dives/call_routing.md)` | Relative from `L1_operator_pack/` |
| L2 → L2 | `[Auth Flow](auth_flow.md)` | Same directory |
| L2 → L1 | `[Back to Interfaces](../06_interfaces.md)` | Parent directory |
| Any → External | `[API Docs](https://docs.example.com) [EXTERNAL]` | Full URL with marker |

**Rules:**

- Never use absolute paths. Never link outside `docs/ai/`.
- If a doc references source code files, use inline code (`` `src/routes/index.ts` ``) not a link.
- Mark external URLs with `[EXTERNAL]`.

### 4.4 Content Density Targets

| Level | Lines per File | Prose | Tables | Code Blocks |
|-------|---------------|-------|--------|-------------|
| L0 | 30–50 | None (tables only) | Required | None |
| L1 | 80–200 per file | Minimal (≤3 sentences per section) | Encouraged | Short examples |
| L2 | No ceiling | Allowed (but structured) | Yes | Full examples |

**Aggregate budgets:**

| Metric | Target | Maximum |
|--------|--------|---------|
| L0 lines | 30–50 | 60 |
| Total L1 lines (all 7 files) | 700–1,200 | 1,400 |
| Total L0 + L1 lines | 730–1,250 | 1,460 |

### 4.5 Anti-Patterns

Do NOT put any of the following in `docs/ai/`:

| Anti-Pattern | Why | Where It Belongs |
|-------------|-----|-----------------|
| Duplicating the README | Creates two sources of truth that drift apart | README stays at repo root; L1 is structured differently |
| Auto-generated API docs (Swagger/TypeDoc output) | Goes stale, inflates token count, already available from source | Link from `06_interfaces.md` with `[EXTERNAL]` marker |
| Operational runbooks (incident response, on-call playbooks) | Too long, changes frequently, audience is ops not developers | Wiki or runbook system; link from `07_gotchas.md` if critical |
| Full database migration history | Unbounded growth, low signal | `06_interfaces.md` covers current schema; link to migration dir |
| Commented-out "previous versions" of docs | Noise; git has history | Delete and rely on version control |

**Rule of thumb:** If content is auto-generated, unbounded in growth, or has a better canonical home elsewhere — link to it, don't copy it.

### 4.6 Freshness and Maintenance

#### When to Update

| Trigger | What to Update |
|---------|---------------|
| New critical file or module added | L1 `03_code_map.md` |
| Workflow changes | L1 `05_workflows.md` |
| Gotcha discovered in incident | L1 `07_gotchas.md` |
| API contract changes | L1 `06_interfaces.md` |
| Subsystem undergoes significant change | Relevant L2 deep dive |
| New external dependency added | L1 `01_setup.md`, L1 `02_architecture.md` |

#### Freshness Tracking

- The `last_reviewed` date in L0's Identity Block should be updated whenever any `docs/ai/` file is modified.

#### CI Check (Recommended)

Check freshness per-file so a single update doesn't reset the clock for everything:

```yaml
# GitHub Actions
- name: Check docs freshness
  run: |
    threshold=$(( $(date +%s) - 90 * 86400 ))
    stale=""
    for f in docs/ai/L0_repo_card.md docs/ai/L1_operator_pack/*.md; do
      [ -f "$f" ] || continue
      last=$(git log -1 --format="%ct" -- "$f" 2>/dev/null || echo 0)
      if [ "$last" -lt "$threshold" ]; then
        stale="$stale $f"
      fi
    done
    if [ -n "$stale" ]; then
      echo "::warning::Stale docs (>90 days):$stale"
    fi
```

> **Note:** Uses POSIX-compatible `date +%s` arithmetic instead of GNU-only `date -d`. Works on both Linux and macOS CI runners.

### 4.7 AGENTS.md and CLAUDE.md Integration

Every repo should have an `AGENTS.md` at the root that serves as the **universal entry point for all AI tools**. `CLAUDE.md` is a thin redirect.

#### AGENTS.md Template

```markdown
# AI Agent Instructions

This repository uses progressive disclosure documentation to help AI coding
agents work efficiently. Documentation is structured in three levels under
`docs/ai/`.

## How to Load

1. Read [docs/ai/L0_repo_card.md](docs/ai/L0_repo_card.md) to identify the repo.
2. Load ALL 7 files in `docs/ai/L1_operator_pack/` (~3,000–4,500 tokens total).
   This gives you setup, architecture, code map, conventions, workflows,
   interfaces, and gotchas.
3. If a task needs more detail than L1 provides, follow links to L2 deep dives
   in `docs/ai/L1_operator_pack/deep_dives/`. Load only the specific L2 file
   you need.

## Levels

- **L0 (Repo Card):** Identity and L1 index. Table of contents.
- **L1 (Operator Pack):** Seven structured summaries. Load all at session start.
- **L2 (Deep Dives):** Full specifications. Load only when L1 isn't detailed enough.
```

#### CLAUDE.md Template

Claude Code reads `CLAUDE.md` into the system prompt automatically. A one-line redirect would force an extra tool call to read `AGENTS.md`. Instead, duplicate the core loading instructions so Claude Code has them immediately:

```markdown
# Repository Documentation

This repo uses progressive disclosure docs under `docs/ai/`.

1. Read [docs/ai/L0_repo_card.md](docs/ai/L0_repo_card.md) to identify the repo.
2. Load ALL 7 files in `docs/ai/L1_operator_pack/` (~3,000–4,500 tokens total).
3. Follow L2 deep dive links only when L1 isn't detailed enough for your task.

See AGENTS.md for the full explanation.
```

#### Why This Pattern

- **`AGENTS.md`** is the universal standard (Linux Foundation). All AI tools will look for it.
- **`CLAUDE.md`** duplicates the 3-step loading instructions so Claude Code doesn't waste a tool call reading `AGENTS.md`. The duplication is 5 lines — worth the saved round-trip.
- **Other tools** (Cursor, Copilot, Cody, etc.) can all read `AGENTS.md`.
- **Future enterprise map:** A central system can scrape all `AGENTS.md` files to discover repos, then follow the link to each L0 for Identity Block metadata.

---

## 5. Specializing for Repo Types

### Key Principle

> **The 7-file L1 structure is universal. Specialization is in content, not structure.**

The L0 Identity Block includes a `repo_type` field. Valid values: `api-service`, `frontend-app`, `sdk-library`, `infrastructure`, `monorepo`, `data-pipeline`, `ml-model`, `mobile-app`.

Specialization manifests in:
1. **L1 file content emphasis** — which topics each file focuses on
2. **L2 deep dive topics** — which subsystems need full docs
3. Agents and tooling never need repo-type-specific branching for structure.

---

### 5.1 API Service / Backend

**Reference:** sip-call-manager (Node.js SIP service)

#### L1 Content Emphasis

| File | API Service Focus |
|------|------------------|
| `01_setup.md` | Database setup, Docker Compose, service dependencies, env var catalog, seed data, quick commands |
| `02_architecture.md` | Request lifecycle diagram, middleware chain, service layer pattern, database access pattern |
| `03_code_map.md` | Routes → Controllers → Services → Models → Migrations, middleware, config directories |
| `04_conventions.md` | Route naming, error response format, logging standards, database query patterns |
| `05_workflows.md` | "Add a new endpoint," "Add a migration," "Add a background worker," "Deploy to staging" |
| `06_interfaces.md` | REST API contract (or OpenAPI ref), event bus schemas, database entity schemas |
| `07_gotchas.md` | Connection pool limits, migration ordering, race conditions, SIP protocol edge cases |

#### Typical L2 Deep Dives

- `call_routing.md` — SIP call routing logic and decision tree
- `websocket_system.md` — Real-time event system architecture
- `database_schema.md` — Full entity relationship map
- `auth_flow.md` — Authentication and authorization flow

#### Example: sip-call-manager 02_architecture.md Excerpt

```markdown
# 02 Architecture

> System design overview for sip-call-manager.

## Request Lifecycle

Inbound SIP INVITE → SIP Parser → Route Matcher → Call Handler → State Machine → Response

## Component Diagram

    ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
    │  SIP Gateway  │────▶│  Call Router  │────▶│ Call Handler  │
    └──────────────┘     └──────────────┘     └──────┬───────┘
                                                      │
                              ┌────────────────────────┤
                              ▼                        ▼
                         ┌─────────┐           ┌──────────────┐
                         │  State  │           │  WebSocket   │
                         │ Machine │           │   Notifier   │
                         └────┬────┘           └──────────────┘
                              ▼
                         ┌─────────┐
                         │ Database │
                         └─────────┘

## Key Abstractions

- **CallSession** — State machine representing a single call lifecycle
- **RouteRule** — Configuration-driven routing decision
- **SIPDialog** — Low-level SIP protocol state

## Related Deep Dives

- [Call Routing](deep_dives/call_routing.md) — Full routing decision tree
- [WebSocket System](deep_dives/websocket_system.md) — Event notification architecture
```

---

### 5.2 Frontend Application

#### L1 Content Emphasis

| File | Frontend Focus |
|------|---------------|
| `01_setup.md` | Node version, package manager, dev server, Storybook, browser requirements, quick commands |
| `02_architecture.md` | Component hierarchy, state management approach, data fetching layer, routing, rendering strategy |
| `03_code_map.md` | Pages, components (shared vs feature), hooks/composables, stores, styles, assets |
| `04_conventions.md` | Component naming, file co-location, CSS approach, prop drilling vs context rules |
| `05_workflows.md` | "Add a new page," "Create a shared component," "Connect to a new API," "Add a feature flag" |
| `06_interfaces.md` | Shared component prop contracts, store shapes, API client interface, route definitions |
| `07_gotchas.md` | Hydration mismatches, state persistence quirks, CSS specificity traps, bundle size issues |

#### Typical L2 Deep Dives

- `state_management.md` — Store architecture, action patterns, selectors
- `design_system.md` — Token system, component library conventions, theming
- `data_fetching.md` — Caching strategy, optimistic updates, error boundaries

#### Example: Frontend 05_workflows.md Excerpt

```markdown
# 05 Workflows

> Step-by-step guides for common frontend development tasks.

## Add a New Page

1. Create route file: `src/pages/[PageName]/index.tsx`
2. Create page component: `src/pages/[PageName]/[PageName].tsx`
3. Add route to `src/router/routes.ts`
4. Add sidebar entry to `src/components/Layout/Sidebar/nav-items.ts`
5. Add page-level query hooks if needed: `src/hooks/queries/use[PageName].ts`
6. Add page-level tests: `src/pages/[PageName]/__tests__/`

## Related Deep Dives

- [Design System](deep_dives/design_system.md) — Component library patterns
```

---

### 5.3 SDK / Library

#### L1 Content Emphasis

| File | SDK/Library Focus |
|------|------------------|
| `01_setup.md` | Build toolchain, test harness, local linking, docs generation, quick commands |
| `02_architecture.md` | Module dependency graph, public vs internal API boundary, extension points, versioning |
| `03_code_map.md` | Public API surface (exports), internal modules, types directory, examples, test fixtures |
| `04_conventions.md` | Semver rules, breaking change policy, deprecation pattern, public API naming |
| `05_workflows.md` | "Add a public method," "Deprecate an API," "Write a usage example," "Release a new version" |
| `06_interfaces.md` | Full public API surface (type signatures), configuration schema, plugin interface, error types |
| `07_gotchas.md` | Backwards compatibility traps, bundle size impacts, peer dependency conflicts |

#### Typical L2 Deep Dives

- `api_design_decisions.md` — Rationale for public API shape
- `backwards_compatibility.md` — Supported versions matrix, migration guides
- `build_pipeline.md` — Multi-target builds, tree-shaking, bundling

---

### 5.4 Infrastructure / IaC

#### L1 Content Emphasis

| File | IaC Focus |
|------|-----------|
| `01_setup.md` | Cloud CLI tools, credentials setup, state backend access, plan/apply workflow, quick commands |
| `02_architecture.md` | Environment topology (dev/staging/prod), resource dependency graph, network layout, blast radius zones |
| `03_code_map.md` | Module directories, environment overlays, variable files, state files, CI/CD pipeline files |
| `04_conventions.md` | Resource naming, tagging policy, module composition rules, secret management |
| `05_workflows.md` | "Add a new resource," "Modify existing infrastructure," "Promote across environments," "Emergency rollback" |
| `06_interfaces.md` | Module input/output variables, cross-stack references, external service endpoints |
| `07_gotchas.md` | **Critical for IaC:** State corruption risks, destroy-before-create, cascading failures, cost surprises |

#### Typical L2 Deep Dives

- `network_topology.md` — VPC layout, subnet strategy, peering, firewall rules
- `iam_model.md` — Role hierarchy, least-privilege policies, cross-account access
- `disaster_recovery.md` — Backup strategy, RTO/RPO targets, failover procedures

#### Example: IaC 07_gotchas.md Excerpt

```markdown
# 07 Gotchas

> Critical gotchas and tribal knowledge for the infrastructure repo.

## State Management

- **Never run `terraform apply` locally against production.** All production applies
  go through CI/CD. Local applies are only for dev environments.
- **State file locking uses DynamoDB.** If a lock is stuck, check `terraform-locks`
  table before force-unlocking.
- **Moving resources between modules requires `terraform state mv`.** Simply cutting
  and pasting HCL will destroy and recreate the resource.

## Cost Surprises

- **NAT Gateways cost ~$32/month each, plus data transfer.** We have one per AZ (3 total).
- **RDS Multi-AZ doubles the instance cost.** Enabled in prod only.

## Environment Differences

| Resource | Dev | Staging | Prod |
|----------|-----|---------|------|
| RDS instance class | `db.t3.micro` | `db.t3.medium` | `db.r6g.xlarge` |
| RDS Multi-AZ | No | No | Yes |
| ECS task count | 1 | 2 | 4 (min), 12 (max) |

## Related Deep Dives

- [Network Topology](deep_dives/network_topology.md)
- [IAM Model](deep_dives/iam_model.md)
- [Disaster Recovery](deep_dives/disaster_recovery.md)
```

---

### 5.5 Adaptation Notes for Other Repo Types

#### Monorepo

The root gets a **meta L0 + full L1** that covers workspace-level concerns. Each package gets its own `docs/ai/` tree. Only the root has `AGENTS.md`.

```
repo-root/
├── AGENTS.md                              # Single entry point for the whole monorepo
├── docs/ai/
│   ├── L0_repo_card.md                    # Meta repo card (type: monorepo)
│   └── L1_operator_pack/
│       ├── 01_setup.md                    # Root workspace tooling, install, build-all
│       ├── 02_architecture.md             # Package dependency graph, shared patterns
│       ├── 03_code_map.md                 # Package map with paths + one-liners
│       ├── 04_conventions.md              # Shared conventions across packages
│       ├── 05_workflows.md               # "Add a package," "Run affected tests"
│       ├── 06_interfaces.md               # Cross-package contracts, shared types
│       ├── 07_gotchas.md                  # Workspace-level gotchas (hoisting, linking)
│       └── deep_dives/
├── packages/
│   ├── api/docs/ai/                       # Package-level L0 + L1 + L2
│   │   ├── L0_repo_card.md
│   │   └── L1_operator_pack/
│   └── web/docs/ai/
```

**Monorepo Loading Protocol:**

1. **Always start at root.** Load root L0 → load root L1 (workspace setup, package map, shared conventions).
2. **Identify the target package** from root `03_code_map.md` which lists all packages with paths.
3. **Load the package's L0 + L1.** Each package has its own full progressive disclosure tree.
4. **Package-level docs do NOT get their own `AGENTS.md`.** The root `AGENTS.md` explains the two-tier loading model.

**Root `03_code_map.md` must include a package index:**

```markdown
## Packages

| Package | Path | Type | Description |
|---------|------|------|-------------|
| api | `packages/api/` | api-service | REST API backend |
| web | `packages/web/` | frontend-app | React SPA |
| shared | `packages/shared/` | sdk-library | Shared types and utilities |

Each package has its own `docs/ai/` tree. Load `packages/[name]/docs/ai/L0_repo_card.md` to start.
```

#### Data Pipeline

Follows **API service** pattern. Key content shifts:
- `02_architecture.md` — DAG/pipeline graph, sources → transforms → sinks
- `06_interfaces.md` — Schema definitions (input/output), SLA contracts, data quality rules
- `05_workflows.md` — "Add a pipeline stage," "Backfill historical data," "Handle schema evolution"
- **L2 topics:** `data_lineage.md`, `schema_registry.md`, `backfill_procedures.md`

#### ML Model Repo

Follows **SDK/library** pattern. Key content shifts:
- `02_architecture.md` — Training vs serving architecture, feature pipeline diagram
- `05_workflows.md` — "Retrain model," "Deploy model version," "A/B test a variant"
- `06_interfaces.md` — Model I/O schemas, feature definitions, hyperparameter config
- `07_gotchas.md` — Training/serving skew, feature leakage, GPU memory limits
- **L2 topics:** `training_pipeline.md`, `feature_engineering.md`, `model_evaluation.md`

---

## 6. Prompt: Generate Docs for an Existing Repo

Copy the entire fenced block below into an AI coding agent with repo file access. The prompt is self-contained.

> **Usage notes:**
> - Works with any AI tool that can read files (Claude Code, Cursor, Cody, Aider, etc.)
> - The agent creates files one at a time — expect 10–20 tool calls
> - Review generated docs for accuracy — agents may miss domain-specific gotchas

````markdown
# Task: Generate Progressive Disclosure Documentation

You are a documentation agent. Analyze this codebase and generate progressive
disclosure documentation under `docs/ai/`.

## The Standard (Condensed)

**Loading model:** L0 (table of contents) → load ALL L1 at session start → L2 only when L1 isn't detailed enough.

**L0 — Repo Card** (`docs/ai/L0_repo_card.md`):
- Single file, always read first, 30-50 lines max
- Two sections: Identity Block (name, type, language, deploy target, owner,
  last_reviewed) and L1 Index (table of 7 files with one-line purposes)
- NO prose. Tables only.

**L1 — Operator Pack** (`docs/ai/L1_operator_pack/`):
- Exactly 7 files, never omit any:
  01_setup.md, 02_architecture.md, 03_code_map.md, 04_conventions.md,
  05_workflows.md, 06_interfaces.md, 07_gotchas.md
- Agents load ALL 7 at session start (~3,000-4,500 tokens total)
- Each: 80-200 lines, starts with one-line purpose, ends with
  "## Related Deep Dives" (links or "None")
- No prose >3 sentences. Use headers, bullets, tables, short code blocks.
- 01_setup.md includes quick commands (build, test, run, deploy)
- 07_gotchas.md includes all critical gotchas (no separate gotchas in L0)

**L2 — Deep Dives** (`docs/ai/L1_operator_pack/deep_dives/`):
- `_index.md` required — table: Document, Summary, Load When
- Files: snake_case, no number prefix, flat directory
- Each starts with "> **When to Read This:** ..." callout
- Self-contained. No length ceiling. Create when L1 needs >10 lines on a topic.

**Linking:** Relative paths only. Never link outside docs/ai/.
External URLs marked with [EXTERNAL].

## Analysis Steps

### Step 1: Understand the Repository

1. List directory structure (top 3 levels).
2. Read config files: package.json, Cargo.toml, go.mod, pyproject.toml,
   Dockerfile, docker-compose.yml, CI config — whatever exists.
3. Identify repo type: api-service, frontend-app, sdk-library, infrastructure,
   monorepo, data-pipeline, ml-model, or mobile-app.

### Step 2: Map the Architecture

4. Read entry point files and primary source directories.
5. Identify top 10-15 critical files/directories.
6. Map primary data flow (request lifecycle, component hierarchy, module graph,
   or resource dependency graph — whichever applies).

### Step 3: Extract Patterns and Knowledge

7. Identify coding conventions from 3-5 representative source files.
8. Identify all external interfaces (APIs, databases, queues, caches).
9. Find gotchas: TODO/FIXME/HACK comments, complex conditionals, environment
   differences, retry logic, commented-out code.

### Step 4: Plan

10. List key topics for each L1 file (3-5 per file).
11. Identify 2-4 L2 deep dive topics.

## Output

Create files one at a time in this order:

1. `mkdir -p docs/ai/L1_operator_pack/deep_dives`
2. `docs/ai/L0_repo_card.md` — Identity Block + L1 Index table
3. L1 files 01 through 07
4. `docs/ai/L1_operator_pack/deep_dives/_index.md`
5. L2 deep dive files
6. Verify all cross-references resolve

## Also create: AGENTS.md

Create `AGENTS.md` at the repo root:

```
# AI Agent Instructions

This repository uses progressive disclosure documentation.

1. Read [docs/ai/L0_repo_card.md](docs/ai/L0_repo_card.md) to identify the repo.
2. Load ALL 7 files in docs/ai/L1_operator_pack/ (~3,000-4,500 tokens total).
3. Follow L2 deep dive links only when L1 isn't detailed enough for your task.
```

## Quality Checklist

**L0:** Identity Block with repo_type + last_reviewed. L1 Index table with all 7 files. ≤50 lines. No prose.

**L1:** All 7 files exist. Each starts with purpose statement, ends with Related Deep Dives. 80-200 lines each. Total ≤1,400.

**L2:** _index.md exists. ≥2 deep dives. Each starts with "When to Read This." All self-contained.

**Links:** All relative. All resolve. None point outside docs/ai/.
````

---

## 7. Prompt: Bootstrap Docs for a New Repo

Copy the entire fenced block below into an AI coding agent. For repos with **little or no code yet**.

> **Usage notes:**
> - The agent asks a questionnaire then generates starter docs with specific TODO markers
> - L2 content files are NOT generated — just the index
> - Re-run the existing-repo prompt (Section 6) once the codebase has taken shape

````markdown
# Task: Bootstrap Progressive Disclosure Documentation for a New Repo

You are a documentation agent. Help an engineer set up progressive disclosure
documentation for a new repository with little or no code yet.

## Gather Information

Ask the engineer (or extract from context):

1. **Repo name** and **one-line description**
2. **Repo type:** api-service, frontend-app, sdk-library, infrastructure,
   monorepo, data-pipeline, ml-model
3. **Primary language and framework**
4. **Key external dependencies** (databases, queues, third-party APIs)
5. **Deployment target** (AWS ECS, Vercel, Kubernetes, Lambda, etc.)
6. **Anticipated directory structure** (src/, lib/, modules/, packages/)

## The Standard (Condensed)

**Loading model:** L0 (table of contents) → load ALL L1 at session start → L2 only when L1 isn't detailed enough.

**L0 — Repo Card** (`docs/ai/L0_repo_card.md`):
- Identity Block + L1 Index table. 30-50 lines. No prose.

**L1 — Operator Pack** (`docs/ai/L1_operator_pack/`):
- 7 files: 01_setup, 02_architecture, 03_code_map, 04_conventions,
  05_workflows, 06_interfaces, 07_gotchas
- Agents load all 7 at session start (~3,000-4,500 tokens total)
- Each: starts with purpose, ends with Related Deep Dives

**L2:** Generate only `_index.md` with anticipated topics. No content files yet.

## TODO Marker Convention

Use SPECIFIC TODO markers — never generic ones:

GOOD:
```
<!-- TODO: Document actual database schema once models are created -->
<!-- TODO: List actual environment variables from .env.example once created -->
```

BAD:
```
<!-- TODO: Fill in later -->
<!-- TODO: TBD -->
```

Every TODO must say WHAT to document and WHEN to do it.

## Output

Create files one at a time:

1. `mkdir -p docs/ai/L1_operator_pack/deep_dives`
2. `docs/ai/L0_repo_card.md` — Fill Identity from questionnaire. L1 Index.
3. L1 files 01-07 — Fill what you can from tech stack knowledge, TODO the rest.
   All 7 must exist even if mostly TODOs.
4. `docs/ai/L1_operator_pack/deep_dives/_index.md` — 3-5 anticipated topics,
   all marked "To be created." No content files.
5. `AGENTS.md` at repo root — Instructs agents to load L0 then all L1.

## Quality Checklist

**L0:** Identity filled from questionnaire. L1 Index complete. ≤50 lines.

**L1:** All 7 exist. Purpose statements present. All TODOs are specific.

**L2:** _index.md only. No content files created.

**AGENTS.md:** Exists at repo root. Instructs: load L0, then all L1, then L2 only if needed.
````

---

## 8. Appendices

### 8.1 File Inventory

| File | Level | Required? | Purpose |
|------|-------|----------|---------|
| `AGENTS.md` (repo root) | — | **Required** | Universal AI entry point |
| `CLAUDE.md` (repo root) | — | Optional | Loading instructions + AGENTS.md reference |
| `docs/ai/L0_repo_card.md` | L0 | **Required** | Identity + L1 index |
| `docs/ai/L1_operator_pack/01_setup.md` | L1 | **Required** | Environment setup, quick commands |
| `docs/ai/L1_operator_pack/02_architecture.md` | L1 | **Required** | System design overview |
| `docs/ai/L1_operator_pack/03_code_map.md` | L1 | **Required** | Codebase navigation, core files |
| `docs/ai/L1_operator_pack/04_conventions.md` | L1 | **Required** | Coding patterns |
| `docs/ai/L1_operator_pack/05_workflows.md` | L1 | **Required** | Step-by-step task guides |
| `docs/ai/L1_operator_pack/06_interfaces.md` | L1 | **Required** | Boundary contracts |
| `docs/ai/L1_operator_pack/07_gotchas.md` | L1 | **Required** | Gotchas and tribal knowledge |
| `docs/ai/L1_operator_pack/deep_dives/_index.md` | L2 | Required if L2 exists | Deep dive index |
| `docs/ai/L1_operator_pack/deep_dives/*.md` | L2 | Optional | Topic deep dives |

### 8.2 Token Budget Summary

| Scenario | Files Loaded | Estimated Tokens |
|----------|-------------|-----------------|
| Any task (baseline) | L0 + all 7 L1 | 2,400–4,700 |
| Task needing L2 detail | L0 + all L1 + 1–2 L2 | 4,000–7,000+ |
| Full context (avoid) | All files including all L2 | 8,000–15,000+ |

**vs alternatives:**

| Approach | Any Task (Baseline) | With L2 Depth |
|----------|---------------------|--------------|
| Full codebase in context | 50,000–200,000+ | 50,000–200,000+ |
| Single large README | 3,000–10,000 | 3,000–10,000 |
| **Progressive disclosure** | **2,400–4,700** | **4,000–7,000+** |

### 8.3 Adoption Checklist

1. **Classify** — Determine `repo_type`, language, deploy target, owner
2. **Generate** — Copy prompt from Section 6 into an AI agent with repo access
3. **Review** — Verify architecture, interfaces, workflows, gotchas for accuracy
4. **Fill gaps** — Add incident-learned gotchas, deployment runbooks, tribal knowledge
5. **Integrate** — Create `AGENTS.md` + `CLAUDE.md` at repo root, add note to `README.md`
6. **Maintain** — Update `docs/ai/` when code changes, update `last_reviewed` in L0
7. **Monitor** (optional) — CI freshness check, track L2 load frequency

### 8.4 FAQ

**Q: Can I add L1 files beyond the 7?**
A: No. Additional content goes in L2 deep dives. If an L1 file doesn't apply, it says "Not applicable" — it is not omitted.

**Q: Can I use this with non-Claude agents?**
A: Yes. Everything is tool-agnostic markdown. `AGENTS.md` is the universal entry point.

**Q: How does this work with monorepos?**
A: Root gets a meta L0 + L1. Each package can have its own `docs/ai/` tree. See Section 5.5.

**Q: Why load all L1 instead of picking files per task?**
A: Total L1 is ~3,000–4,500 tokens — less than a single page of prose. Loading everything upfront eliminates wrong guesses about which files matter and costs less than a single wasted tool call. The real cost savings come from not loading L2 unless you need it.

**Q: What if L0 exceeds 50 lines?**
A: L0 should only contain Identity Block + L1 Index. If it's growing beyond that, content belongs in L1.

**Q: How do we build an enterprise repo map?**
A: Scrape all `L0_repo_card.md` files across repos. The Identity Block (name, type, language, owner, deploy target) provides structured metadata for a central registry.

**Q: What if the agent generates incorrect docs?**
A: Expected for domain-specific content. Agents excel at structural generation but miss tribal knowledge. Always review with a senior engineer.

---

### End of Standard
