# AI Coding Orchestration Architecture

## Multi-Agent Coordination Across Repositories

**Version:** 0.1 DRAFT
**Status:** Draft — Not for implementation
**Last Updated:** 2026-03-11
**Depends On:** [Progressive Disclosure Documentation Standard](progressive-disclosure-standard.md)

> **This is a draft architecture proposal.** Nothing in this document is finalized. Sections marked `[OPEN QUESTION]` are explicitly unsettled. The goal is to establish a starting point for discussion, not to prescribe a standard. Feedback welcome on all sections.

---

## Table of Contents

- [1. Quick-Start Summary](#1-quick-start-summary)
- [2. Introduction and Motivation](#2-introduction-and-motivation)
  - [2.1 The Problem](#21-the-problem)
  - [2.2 The Insight](#22-the-insight)
  - [2.3 Design Goals](#23-design-goals)
- [3. Architecture Overview](#3-architecture-overview)
  - [3.1 System Diagram](#31-system-diagram)
  - [3.2 Agent Tiers](#32-agent-tiers)
  - [3.3 Relationship to Progressive Disclosure](#33-relationship-to-progressive-disclosure)
- [4. Agent Roles and Responsibilities](#4-agent-roles-and-responsibilities)
  - [4.1 System Agent](#41-system-agent)
  - [4.2 Repo Agent](#42-repo-agent)
  - [4.3 Sub-Agents](#43-sub-agents)
  - [4.4 CUA (Computer-Using Agent)](#44-cua-computer-using-agent)
- [5. Communication Protocol](#5-communication-protocol)
  - [5.1 Candidate Approaches](#51-candidate-approaches)
  - [5.2 Message Schema](#52-message-schema)
- [6. System Context: The System Card](#6-system-context-the-system-card)
  - [6.1 System Card Template](#61-system-card-template)
  - [6.2 Repo Registry](#62-repo-registry)
  - [6.3 Dependency Map](#63-dependency-map)
- [7. Workflow: Epic Lifecycle](#7-workflow-epic-lifecycle)
  - [7.1 Phase Diagram](#71-phase-diagram)
  - [7.2 Phase Details](#72-phase-details)
  - [7.3 Review Gates](#73-review-gates)
- [8. Testing Strategy](#8-testing-strategy)
  - [8.1 Testing Layers](#81-testing-layers)
  - [8.2 Test Driven Development (TDD) Enforcement](#82-test-driven-development-tdd-enforcement)
  - [8.3 The Completion Rule](#83-the-completion-rule)
  - [8.4 Contract Testing](#84-contract-testing)
  - [8.5 CUA End-to-End Testing](#85-cua-end-to-end-testing)
- [9. Proof of Concept](#9-proof-of-concept)
  - [9.1 Scenario](#91-scenario)
  - [9.2 Step-by-Step Walkthrough](#92-step-by-step-walkthrough)
  - [9.3 Success Criteria](#93-success-criteria)
- [10. Open Questions](#10-open-questions)

---

## 1. Quick-Start Summary

This proposal defines a **multi-agent architecture** for coordinating AI coding work across multiple git repositories. It builds on the [Progressive Disclosure Documentation Standard](progressive-disclosure-standard.md), which makes individual repos self-describing. This document addresses the next layer: how agents collaborate when a feature spans multiple codebases.

**Core guarantee:** All agent work is governed by **Test Driven Development** — tests are written and verified failing before implementation, and **all tests must pass or the task is not complete** (Section 8.2, 8.3).

### Agent Tiers

| Tier | Agent | Scope | Writes Code? |
|------|-------|-------|-------------|
| **T0** | System Agent | Cross-repo orchestration | No — plans and coordinates only |
| **T1** | Repo Agent | Single repository | Yes — sole writer for its repo |
| **T2** | Sub-Agent | Single task within a repo | Yes — delegated by Repo Agent |
| **T3** | CUA | Integrated system (browser/UI) | No — tests and validates only |

### Key Artifacts

| Artifact | Purpose | Lives At |
|----------|---------|----------|
| System Card | System-level identity, repo registry, dependency map | Orchestration repo or central config |
| Epic Plan | Cross-repo implementation plan with phases | System Agent workspace |
| Task Spec | Single-repo task derived from Epic Plan | Repo Agent workspace |
| Contract | Interface agreement between repos | Both repos' `06_interfaces.md` |
| L0 Repo Card | Per-repo identity (from PD standard) | Each repo's `docs/ai/L0_repo_card.md` |

---

## 2. Introduction and Motivation

### 2.1 The Problem

The [Progressive Disclosure Documentation Standard](progressive-disclosure-standard.md) solves a single-repo problem: making one codebase self-describing for AI agents. But real features rarely live in one repo. A new API endpoint requires backend changes, SDK updates, frontend integration, and infrastructure provisioning. Today, this coordination happens in a human's head — or doesn't happen at all.

AI coding agents working in isolation produce locally correct but globally inconsistent changes. An agent modifying the API may rename a field that the SDK agent doesn't know about. Without system-level coordination, multi-repo features require constant human shepherding to keep agents aligned.

### 2.2 The Insight

Cross-repo features follow a predictable lifecycle: understand the system → plan across repos → agree on interfaces → implement in parallel → test integration → validate end-to-end. This lifecycle can be modeled as a state machine with explicit review gates, enabling an orchestrating agent to coordinate repo-level agents without micromanaging their implementation choices.

### 2.3 Design Goals

- **Repo sovereignty** — Each repository has exactly one Repo Agent. No external agent writes to a repo it doesn't own.
- **Plan-first execution** — All cross-repo work begins with a plan reviewed by a human before any code is written.
- **Interface-driven** — Cross-repo dependencies are expressed as contracts agreed upon before implementation.
- **Progressive disclosure integration** — Agents bootstrap their understanding of each repo from L0/L1 docs, not raw file trees.
- **Human-in-the-loop** — Review gates at plan, interface agreement, and integration phases.
- **Test Driven Development (TDD)** — Tests are written and verified failing before implementation code. All tests must pass or the task is not complete. No exceptions.
- **Tool agnosticism** — The architecture works with any AI coding tool, not just Claude Code.

---

## 3. Architecture Overview

### 3.1 System Diagram

```
    ┌─────────────────────────────────────────────────────────────┐
    │                      SYSTEM AGENT (T0)                      │
    │         Reads System Card · Plans epics · Coordinates       │
    │              Never writes code · Human review gates          │
    └──────────┬──────────────┬──────────────┬────────────────────┘
               │              │              │
          Task Spec      Task Spec      Task Spec
               │              │              │
    ┌──────────▼──────┐ ┌─────▼────────┐ ┌──▼───────────────┐
    │  REPO AGENT (T1) │ │ REPO AGENT   │ │  REPO AGENT      │
    │  api-service     │ │ sdk-library  │ │  frontend-app    │
    │  ─────────────── │ │ ──────────── │ │  ──────────────  │
    │  Reads L0+L1     │ │ Reads L0+L1  │ │  Reads L0+L1     │
    │  Sole writer     │ │ Sole writer  │ │  Sole writer     │
    │  Owns contracts  │ │ Owns tests   │ │  Owns UI tests   │
    └──────┬───────────┘ └──────┬───────┘ └──────┬───────────┘
           │                    │                 │
      ┌────▼────┐          ┌───▼───┐        ┌────▼────┐
      │Sub-Agent│          │Sub-Ag.│        │Sub-Agent│
      │  (T2)   │          │ (T2)  │        │  (T2)   │
      │Test     │          │Build  │        │Component│
      │Writer   │          │Config │        │Scaffold │
      └─────────┘          └───────┘        └─────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                         CUA (T3)                            │
    │        Validates integrated system via browser/UI           │
    │           Tests user flows end-to-end · Reports back        │
    └─────────────────────────────────────────────────────────────┘
```

### 3.2 Agent Tiers

| Tier | Name | Instance Count | Context Loaded | What It Does | What It Never Does |
|------|------|---------------|----------------|-------------|-------------------|
| T0 | System Agent | 1 per epic | System Card, all repo L0s | Plans, coordinates, assigns tasks, reviews integration | Write code, modify repo files |
| T1 | Repo Agent | 1 per repo | L0 + all L1 for its repo | Implements task specs, writes code, runs tests | Modify files in another repo |
| T2 | Sub-Agent | N per Repo Agent | Subset of repo context | Executes specific sub-tasks (test writing, refactoring) | Act outside its delegated scope |
| T3 | CUA | 1 per epic | System Card + test plan | Tests integrated system through UI/browser | Write production code |

> **Why three tiers plus CUA?** The System Agent needs cross-repo awareness but should never touch code — this prevents a single agent from making uncoordinated changes across repos. Repo Agents need deep single-repo knowledge. Sub-Agents are standard AI coding tool behavior (e.g., Claude Code spawning sub-agents for file searches). CUA is a distinct capability — browser interaction — that doesn't fit the code-writing tiers.

### 3.3 Relationship to Progressive Disclosure

This architecture depends on the [Progressive Disclosure Documentation Standard](progressive-disclosure-standard.md) at every tier:

| Agent | PD Artifact Used | How |
|-------|-----------------|-----|
| System Agent | All L0 Repo Cards | Scrapes Identity Blocks to build the repo registry in the System Card |
| System Agent | L1 `06_interfaces.md` (all repos) | Reads interface docs to understand cross-repo contracts |
| Repo Agent | L0 + all L1 (own repo) | Standard PD loading protocol — bootstraps full working knowledge |
| Repo Agent | L0 (other repos) | Reads other repos' identity to understand dependencies |
| Sub-Agent | Subset of L1/L2 (own repo) | Loads specific files relevant to its sub-task |
| CUA | None directly | Tests the running system, not the code |

> **Why PD is prerequisite:** Without self-describing repos, the System Agent would need to scan every file in every repo to build a system map. PD's L0 Identity Block provides structured metadata that can be scraped programmatically. L1 `06_interfaces.md` provides the contract surface. This is the foundation the orchestration layer builds on.

---

## 4. Agent Roles and Responsibilities

### 4.1 System Agent

The System Agent is the orchestrator. It reads the System Card to understand the system, creates an Epic Plan, assigns Task Specs to Repo Agents, and coordinates integration. It never writes code.

#### Responsibilities

| Responsibility | Description |
|---------------|-------------|
| System understanding | Load System Card, read all repo L0s, build mental model of the system |
| Epic planning | Decompose a cross-repo feature into per-repo Task Specs with ordering |
| Interface negotiation | Identify cross-repo contracts and propose interface agreements |
| Task assignment | Send Task Specs to the appropriate Repo Agent |
| Integration coordination | Track progress, resolve cross-repo blockers, sequence integration |
| Review gate management | Pause at defined gates for human approval |
| CUA orchestration | Define E2E test scenarios and dispatch to CUA |

#### Context Window

```
System Card (~500-800 tokens)
+ All repo L0s (~300-500 tokens each × N repos)
+ Relevant L1 06_interfaces.md files (~300-600 tokens each)
+ Epic Plan (variable)
─────────────────────────────────
Total: ~2,000-5,000 tokens for a 3-5 repo system
```

> **Why the System Agent doesn't write code:** A single agent with write access to multiple repos would violate repo sovereignty. The System Agent's power is coordination, not implementation. This separation prevents a class of bugs where an orchestrator makes locally-reasonable but globally-inconsistent changes because it lacks deep repo context.

### 4.2 Repo Agent

The Repo Agent is the sole writer for its repository. It receives Task Specs from the System Agent, loads context via the [Progressive Disclosure Documentation Standard](progressive-disclosure-standard.md), implements changes, and reports results back.

#### Responsibilities

| Responsibility | Description |
|---------------|-------------|
| Context loading | Load L0 + all L1 per PD standard. Load L2 as needed. |
| Task execution | Implement the Task Spec — write code, tests, config changes |
| Contract compliance | Ensure implementation matches agreed interface contracts |
| Test execution | Run unit tests, integration tests within the repo |
| Sub-agent delegation | Spawn Sub-Agents for parallelizable sub-tasks |
| Status reporting | Report completion, blockers, or contract violations back to System Agent |
| Doc maintenance | Update `docs/ai/` files if the changes affect architecture or interfaces |

#### Context Window

```
L0 + all L1 (~2,400-4,700 tokens per PD standard)
+ Task Spec from System Agent (~200-500 tokens)
+ L2 deep dives as needed (variable)
+ Working code context (variable)
─────────────────────────────────
Total: ~3,000-6,000 tokens baseline before code
```

#### Sovereignty Rule

A Repo Agent MUST be the only agent that creates, modifies, or deletes files in its repository. The System Agent coordinates what needs to happen. The Repo Agent decides how.

| Action | System Agent | Repo Agent |
|--------|-------------|------------|
| "Add a `/users` endpoint that returns `{ id, name, email }`" | Specifies WHAT | Decides WHERE (routes, controllers, models) and HOW |
| "Expose a `getUser(id)` method in the SDK" | Specifies WHAT | Decides the method signature, error handling, and implementation |
| "Update the frontend to call the new endpoint" | Specifies WHAT | Decides component structure, state management approach |

### 4.3 Sub-Agents

Sub-Agents are standard AI coding tool sub-processes spawned by Repo Agents for parallelizable work. This is not a new concept — Claude Code already spawns sub-agents for file searches and targeted edits. The orchestration architecture simply acknowledges them as a tier.

#### Responsibilities

| Responsibility | Description |
|---------------|-------------|
| Scoped execution | Execute a narrow, well-defined task delegated by the Repo Agent |
| Context efficiency | Load only the context needed for the specific sub-task |
| Result reporting | Return results to the parent Repo Agent |

#### Common Sub-Agent Tasks

| Task | Context Loaded | Output |
|------|---------------|--------|
| Write unit tests for module X | Module source + `04_conventions.md` | Test files |
| Scaffold a new component | `03_code_map.md` + `04_conventions.md` | Component files |
| Search for usages of function Y | Codebase index | File list + line numbers |
| Update config for new dependency | `01_setup.md` + config files | Config changes |

### 4.4 CUA (Computer-Using Agent)

The Computer-Using Agent validates the integrated system by interacting with it through a browser or UI, the same way a human tester would. It tests user flows end-to-end after all Repo Agents have completed their implementation.

#### Responsibilities

| Responsibility | Description |
|---------------|-------------|
| E2E test execution | Run through user flows defined in the test plan |
| Visual validation | Verify UI renders correctly, data displays properly |
| Integration verification | Confirm cross-repo changes work together in the running system |
| Bug reporting | Report failures with screenshots, steps to reproduce, and error logs |

#### CUA Test Scenario Format

```markdown
## Test: [Scenario Name]

**Preconditions:**
- [System state required before test]

**Steps:**
1. Navigate to [URL]
2. [Action — click, type, select]
3. [Assertion — verify text, element, state]
4. [Action]
5. [Assertion]

**Expected Result:**
- [What the user should see]

**Pass Criteria:**
- [Specific, verifiable conditions]
```

> **Why CUA instead of automated E2E tests?** CUA complements, not replaces, automated tests. CUA excels at exploratory testing, visual validation, and testing flows that cross system boundaries in ways that are hard to automate. Automated E2E tests (Playwright, Cypress) are better for regression suites. Use both.

---

## 5. Communication Protocol

`[OPEN QUESTION]` — The mechanism by which agents exchange Task Specs, status updates, and results is not settled. This section presents three candidate approaches with trade-offs.

### 5.1 Candidate Approaches

#### Option A: File-Based (Shared Workspace)

Agents communicate by reading and writing structured files in a shared workspace directory.

```
orchestration-workspace/
├── system-card.md
├── epics/
│   └── epic-001-user-profiles/
│       ├── plan.md
│       ├── tasks/
│       │   ├── api-service.task.md
│       │   ├── sdk-library.task.md
│       │   └── frontend-app.task.md
│       └── status/
│           ├── api-service.status.md
│           ├── sdk-library.status.md
│           └── frontend-app.status.md
└── contracts/
    └── user-profile-api.contract.md
```

#### Option B: Message Queue

Agents communicate via a lightweight message queue (Redis Streams, SQS, or similar). The System Agent publishes task messages. Repo Agents subscribe and publish status updates.

#### Option C: Direct Tool Calls

The System Agent invokes Repo Agents as sub-processes, passing Task Specs as prompts and receiving results as return values. This is closest to how Claude Code already works with sub-agents.

#### Trade-off Comparison

| Factor | A: File-Based | B: Message Queue | C: Direct Calls |
|--------|--------------|-----------------|----------------|
| Simplicity | High — just files | Medium — needs queue infra | High — built into AI tools |
| Auditability | High — full history on disk | Medium — needs log consumer | Low — ephemeral context |
| Human visibility | High — humans read files | Low — need tooling | Low — buried in agent logs |
| Async support | Native — poll for file changes | Native — pub/sub | Poor — synchronous calls |
| Scalability | Medium — file I/O limits | High — designed for scale | Low — single process tree |
| Resumability | High — pick up from files | Medium — replay from queue | Low — restart from scratch |
| Tool agnosticism | High — any tool reads files | Medium — need client library | Low — tool-specific APIs |

> **Recommendation (tentative):** File-based (Option A) for the initial proof of concept. Auditability and human readability matter most in early iterations. Migrate to a hybrid (files for plans, direct calls for execution) if needed.

### 5.2 Message Schema

Regardless of transport mechanism, all inter-agent messages follow this schema:

```yaml
message:
  id: "msg-001"
  type: "task_spec | status_update | contract_proposal | review_request"
  from: "system-agent | repo-agent:api-service | cua"
  to: "repo-agent:api-service | system-agent | human"
  epic_id: "epic-001"
  timestamp: "2026-03-11T10:30:00Z"
  payload:
    # Type-specific content
```

#### Task Spec Payload

```yaml
payload:
  title: "Add GET /users/:id endpoint"
  description: "..."
  contracts:
    - ref: "contracts/user-profile-api.contract.md"
      role: "provider"
  depends_on: []
  acceptance_criteria:
    - "Endpoint returns 200 with { id, name, email } for valid user ID"
    - "Endpoint returns 404 for unknown user ID"
    - "Unit tests cover both cases"
```

#### Status Update Payload

```yaml
payload:
  status: "in_progress | blocked | complete | failed"
  summary: "Implemented GET /users/:id with validation and tests"
  blockers: []
  artifacts:
    - type: "commit"
      ref: "abc123f"
    - type: "test_result"
      passed: 12
      failed: 0
```

---

## 6. System Context: The System Card

The System Card is the system-level equivalent of a repo's L0 Repo Card. It describes the entire system: which repos exist, what they do, how they connect, and what the shared conventions are.

### 6.1 System Card Template

The System Card is populated by scraping L0 Identity Blocks from each repo's [Progressive Disclosure Documentation Standard](progressive-disclosure-standard.md) docs, then adding system-level context that no single repo contains.

```markdown
# [System Name] — System Card

> [One-line description of the system]

## Identity

| Field | Value |
|-------|-------|
| System | [system-name] |
| Description | [What the system does — 1 sentence] |
| Owner | [Team or org] |
| Repos | [Count] |
| Last Updated | [YYYY-MM-DD] |

## Repo Registry

[See Section 6.2 — scraped from repo L0 Identity Blocks]

## Dependency Map

[See Section 6.3 — cross-repo dependency graph]

## Shared Conventions

| Convention | Value |
|-----------|-------|
| API versioning | URL path prefix (`/v1/`, `/v2/`) |
| Auth mechanism | JWT with RS256 |
| Error format | `{ error: { code, message, details } }` |
| Date format | ISO 8601 UTC |
| ID format | UUIDv4 |

## Environments

| Environment | URL Pattern | Purpose |
|-------------|-------------|---------|
| Local | `localhost:[port]` | Developer workstation |
| Staging | `staging.[service].example.com` | Integration testing |
| Production | `[service].example.com` | Live traffic |
```

### 6.2 Repo Registry

The Repo Registry is built by scraping the L0 Identity Block from each repository's [Progressive Disclosure Documentation Standard](progressive-disclosure-standard.md) docs. This is the same metadata described in L0's "Enterprise Discovery" section.

| Repo | Type | Language | Deploy Target | Owner | Description |
|------|------|----------|--------------|-------|-------------|
| `org/user-api` | api-service | TypeScript + Express | AWS ECS | Platform Squad | User management REST API |
| `org/user-sdk` | sdk-library | TypeScript | npm | Platform Squad | TypeScript SDK for User API |
| `org/web-app` | frontend-app | TypeScript + React | Vercel | Product Squad | Customer-facing web application |
| `org/infra` | infrastructure | Terraform | AWS | Platform Squad | Shared infrastructure as code |

> **How to populate:** Run a script that reads `docs/ai/L0_repo_card.md` from each repo and extracts the Identity Block fields. The PD standard ensures these fields exist in a predictable format.

### 6.3 Dependency Map

```
    ┌──────────────────────────────────────────────┐
    │                  SYSTEM                       │
    │                                               │
    │   ┌───────────┐     ┌───────────┐            │
    │   │  user-api  │────▶│  user-sdk  │           │
    │   │ (provider) │     │(consumer) │            │
    │   └─────┬─────┘     └─────┬─────┘            │
    │         │                 │                    │
    │         │ REST API        │ npm package        │
    │         │                 │                    │
    │         │           ┌─────▼─────┐             │
    │         │           │  web-app   │             │
    │         │           │(consumer) │             │
    │         └──────────▶│           │             │
    │           (direct)  └───────────┘             │
    │                                               │
    │   ┌───────────┐                               │
    │   │   infra    │──── provisions ────▶ all      │
    │   └───────────┘                               │
    └──────────────────────────────────────────────┘

    Arrow = dependency direction (A ──▶ B means B depends on A)
```

#### Dependency Table

| Provider | Consumer | Interface Type | Contract Location |
|----------|----------|---------------|-------------------|
| user-api | user-sdk | REST API (OpenAPI) | Both repos' `06_interfaces.md` |
| user-sdk | web-app | npm package (TypeScript types) | SDK's `06_interfaces.md` |
| user-api | web-app | REST API (direct calls) | API's `06_interfaces.md` |
| infra | user-api | AWS resources (ECS, RDS) | infra's `06_interfaces.md` |

---

## 7. Workflow: Epic Lifecycle

An "epic" is a cross-repo feature that requires coordinated changes across two or more repositories. The epic lifecycle defines the phases, gates, and handoffs.

### 7.1 Phase Diagram

```
    ┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
    │  PHASE 1 │────▶│  PHASE 2 │────▶│  PHASE 3 │────▶│  PHASE 4 │
    │Discovery │     │ Planning │     │Interface │     │Implement │
    └──────────┘     └─────┬────┘     └─────┬────┘     └─────┬────┘
                           │                │                 │
                      ┌────▼────┐      ┌────▼────┐      ┌────▼────┐
                      │  GATE:  │      │  GATE:  │      │  GATE:  │
                      │  Human  │      │  Human  │      │  Human  │
                      │ Review  │      │ Review  │      │ Review  │
                      └─────────┘      └─────────┘      └─────────┘

    ┌──────────┐     ┌──────────┐     ┌──────────┐
    │  PHASE 5 │────▶│  PHASE 6 │────▶│  PHASE 7 │
    │Integrate │     │ E2E Test │     │  Deploy  │
    └─────┬────┘     └─────┬────┘     └──────────┘
          │                │
     ┌────▼────┐      ┌────▼────┐
     │  GATE:  │      │  GATE:  │
     │  Human  │      │  Human  │
     │ Review  │      │ Review  │
     └─────────┘      └─────────┘
```

### 7.2 Phase Details

| Phase | Name | Actor | Input | Output | Duration Target |
|-------|------|-------|-------|--------|----------------|
| 1 | Discovery | System Agent | Feature request + System Card | System understanding, affected repos list | Minutes |
| 2 | Planning | System Agent | Discovery output | Epic Plan with per-repo Task Specs | Minutes |
| 3 | Interface Agreement | System Agent + Repo Agents | Epic Plan | Signed-off interface contracts | Minutes |
| 4 | Implementation | Repo Agents (parallel) | Task Specs + contracts | Code + tests per repo | Variable |
| 5 | Integration | System Agent + Repo Agents | Completed implementations | Integration test results, conflict resolution | Minutes–Hours |
| 6 | E2E Validation | CUA | Running system + test plan | E2E test report | Minutes |
| 7 | Deploy | Human (+ automation) | Passing E2E tests | Production deployment | Per team process |

#### Phase 1: Discovery

The System Agent loads the System Card, identifies which repos are affected by the feature request, and reads their L0 + relevant L1 files (`06_interfaces.md`, `02_architecture.md`) to understand the current state.

#### Phase 2: Planning

The System Agent produces an Epic Plan:

```markdown
# Epic Plan: [Feature Name]

## Affected Repos
- [repo-1] — [what changes]
- [repo-2] — [what changes]

## Execution Order
1. [repo-1] — [task] (no dependencies)
2. [repo-2] — [task] (depends on repo-1 contract)
3. [repo-3] — [task] (depends on repo-2 package)

## Interface Changes
- [contract-1]: [description of new/changed interface]

## Risk Assessment
- [risk-1]: [description and mitigation]
```

#### Phase 3: Interface Agreement

Before any code is written, all affected Repo Agents review and agree on interface contracts. This is the TDD equivalent at the system level — define the contract (test) before writing the implementation.

#### Phase 4: Implementation

Repo Agents work in parallel within their repos. Each agent follows the standard PD loading protocol, implements its Task Spec, writes tests, and reports status. Implementation order respects dependency chains defined in Phase 2.

#### Phase 5: Integration

The System Agent coordinates integration testing. If repo-A's output is repo-B's input, the System Agent verifies that the implementations align with agreed contracts.

#### Phase 6: E2E Validation

CUA executes the E2E test scenarios defined in the Epic Plan. This validates that the integrated system works from the user's perspective.

#### Phase 7: Deploy

Human-driven. The orchestration architecture produces tested, reviewed code. Deployment follows each team's existing process.

### 7.3 Review Gates

Every gate requires human approval before proceeding. The System Agent pauses and presents:

| Gate | After Phase | Human Reviews | Approval Means |
|------|-------------|--------------|----------------|
| Plan Review | 2 — Planning | Epic Plan, affected repos, execution order | "Yes, this plan correctly decomposes the feature" |
| Contract Review | 3 — Interface Agreement | Interface contracts between repos | "Yes, these interfaces are correct and complete" |
| Code Review | 4 — Implementation | PRs in each repo | "Yes, the implementation is correct" (standard PR review) |
| Integration Review | 5 — Integration | Integration test results, cross-repo alignment | "Yes, the repos work together correctly" |
| E2E Review | 6 — E2E Validation | CUA test report, screenshots | "Yes, the feature works end-to-end" |

> **Why so many gates?** Cross-repo errors are expensive. A wrong interface contract discovered during implementation wastes work in multiple repos. Front-loading reviews at plan and contract phases catches errors when they're cheapest to fix. Teams can relax gates as they build trust in the system.

---

## 8. Testing Strategy

### 8.1 Testing Layers

Testing follows a pyramid structure, with each layer owned by a different agent tier:

| Layer | Scope | Owner | When | Tool |
|-------|-------|-------|------|------|
| Unit Tests | Single function/module | Repo Agent (T1) | Phase 4 — Implementation | Standard test runner (Jest, pytest, etc.) |
| Integration Tests | Single repo, external deps mocked | Repo Agent (T1) | Phase 4 — Implementation | Standard test runner + mocks |
| Contract Tests | Interface between two repos | System Agent (T0) coordinates, Repo Agents (T1) implement | Phase 5 — Integration | Contract testing framework |
| E2E Tests (automated) | Running system, scripted flows | Repo Agent (T1) for test code | Phase 5 — Integration | Playwright, Cypress |
| E2E Tests (CUA) | Running system, exploratory | CUA (T3) | Phase 6 — E2E Validation | Browser interaction |

### 8.2 Test Driven Development (TDD) Enforcement

Stating "write tests first" is not a mechanism. This section defines the concrete sequence a Repo Agent MUST follow and the checkpoints that enforce it.

#### The TDD Loop

Every Repo Agent follows this exact sequence for each unit of work. The sequence is not advisory — it is the implementation protocol.

```
    ┌───────────────────────────────────────────────────┐
    │              REPO AGENT TDD LOOP                  │
    │                                                   │
    │   Step 1: READ acceptance criteria from Task Spec │
    │                     │                             │
    │                     ▼                             │
    │   Step 2: WRITE test(s) that encode the criteria  │
    │                     │                             │
    │                     ▼                             │
    │   Step 3: RUN tests ── verify they FAIL           │
    │           (if tests pass, they test nothing)      │
    │                     │                             │
    │                     ▼                             │
    │   Step 4: WRITE implementation code               │
    │                     │                             │
    │                     ▼                             │
    │   Step 5: RUN tests ── do they pass?              │
    │              │                │                   │
    │             YES              NO                   │
    │              │                │                   │
    │              ▼                ▼                   │
    │   Step 6: COMMIT      Step 5a: FIX code           │
    │           (green)       (NOT the test)            │
    │              │                │                   │
    │              │                └──── back to ──┐   │
    │              │                     Step 5     │   │
    │              ▼                                │   │
    │   Step 7: NEXT unit of work                   │   │
    │           or REPORT complete                  │   │
    └───────────────────────────────────────────────┘
```

#### Enforcement Rules

| Rule | What It Means | Why It Matters |
|------|--------------|---------------|
| Tests before code | No implementation file is created or modified until at least one failing test exists for the change | Prevents "code first, test after" where tests become rubber stamps |
| Red before green | After writing a test, the agent MUST run it and confirm failure before writing implementation | A test that passes before implementation is written is testing nothing |
| Fix code, not tests | When a test fails after implementation, the agent fixes the implementation — never the test (unless the test itself has a bug) | Prevents agents from weakening tests to match broken code |
| No skipping tests | An agent cannot mark a test as `.skip`, `.todo`, or `pending` to make the suite pass | Skipped tests are invisible failures |
| Commit on green only | The agent commits only when all tests pass. No commits with known failures. | Every commit in the history is a working state |

#### TDD at Every Layer

| Layer | Write First | Then Implement | Red-Green Verified By |
|-------|------------|---------------|----------------------|
| Unit | Test cases from acceptance criteria | Function/module code | Repo Agent runs test runner |
| Integration | Test with mocked dependencies | Wiring and integration code | Repo Agent runs test runner |
| Contract | Contract spec (provider and consumer) | API endpoint / SDK method | Both Repo Agents run contract tests |
| E2E | Test scenario document | Feature code across repos | CUA or automated E2E runner |

> **Why enforce red-before-green?** AI agents are prone to writing tests that mirror their implementation rather than independently encoding the requirement. Running the test before writing code proves the test is actually checking something. A test that passes against an empty function is worthless.

### 8.3 The Completion Rule

This is the fail-safe. It defines when work is "done" and what happens when it isn't.

#### The Rule

> **A task is not complete until all tests pass. There are no exceptions.**

This applies at every level:

| Level | Rule | Enforced By |
|-------|------|------------|
| Repo Agent task | ALL unit + integration tests pass (0 failures, 0 skipped) | Repo Agent cannot report `status: complete` otherwise |
| Contract testing | BOTH provider and consumer contract tests pass | System Agent rejects integration if either fails |
| Integration | Cross-repo integration tests pass | System Agent blocks Phase 6 |
| E2E | All CUA test scenarios pass | System Agent blocks Phase 7 (deploy) |
| Epic | ALL of the above, across ALL repos | System Agent cannot close the epic |

#### Status Reporting Enforcement

The status update payload (Section 5.2) includes test counts. The completion rule adds hard constraints:

```yaml
payload:
  status: "complete"          # ONLY valid when failed == 0 AND skipped == 0
  test_result:
    passed: 12
    failed: 0                 # Must be 0 for status: complete
    skipped: 0                # Must be 0 for status: complete
    total: 12                 # Must equal passed + failed + skipped
```

**Illegal states — the System Agent MUST reject these:**

```yaml
# REJECTED: failed > 0 with status complete
payload:
  status: "complete"
  test_result: { passed: 10, failed: 2, skipped: 0 }

# REJECTED: skipped > 0 with status complete
payload:
  status: "complete"
  test_result: { passed: 11, failed: 0, skipped: 1 }

# REJECTED: total doesn't match
payload:
  status: "complete"
  test_result: { passed: 12, failed: 0, skipped: 0, total: 15 }
```

#### The Fix Loop

When tests fail, the Repo Agent enters a fix loop. This is not a retry — it is a structured debugging cycle with a bound.

```
    Tests fail
        │
        ▼
    Attempt 1: Read failure output → diagnose → fix code → re-run
        │
      Pass? ──YES──▶ Report complete
        │
        NO
        │
    Attempt 2: Read failure output → diagnose → fix code → re-run
        │
      Pass? ──YES──▶ Report complete
        │
        NO
        │
    Attempt 3: Read failure output → diagnose → fix code → re-run
        │
      Pass? ──YES──▶ Report complete
        │
        NO
        │
    Report: status: "blocked"
    Include: failure output, diagnosis, what was tried
    Escalate to: System Agent → human
```

#### Fix Loop Rules

| Rule | Description |
|------|-------------|
| Maximum 3 fix attempts | After 3 failed fix cycles, the agent MUST stop and report `status: blocked` |
| Fix code, not tests | The agent modifies implementation code. Tests are only changed if the agent can articulate a specific bug in the test itself (not "the test doesn't match my code"). |
| Include diagnostics | The `blocked` status MUST include: test failure output, the agent's diagnosis of root cause, and what was attempted |
| No workarounds | The agent cannot comment out code, add `try/catch` blocks that swallow errors, or weaken assertions to make tests pass |
| Human escalation | A `blocked` status always reaches a human. The System Agent cannot auto-resolve it. |

> **Why 3 attempts?** Empirically, if an AI agent can't fix a test failure in 3 targeted attempts with failure output, it's either misunderstanding the requirement or hitting a genuine design issue. Both need human input. More retries waste tokens and risk the agent drifting further from the correct solution.

#### Phase Gate Enforcement

The Completion Rule integrates with Section 7.3 Review Gates:

| Gate | Completion Rule Check |
|------|----------------------|
| Code Review (after Phase 4) | System Agent verifies: every Repo Agent reported `status: complete` with `failed: 0, skipped: 0`. If any repo is `blocked`, the gate does not open. |
| Integration Review (after Phase 5) | System Agent verifies: all contract tests pass across all repo pairs. All integration tests pass. |
| E2E Review (after Phase 6) | System Agent verifies: all CUA scenarios report pass. |

**The epic cannot advance to the next phase while any test is failing.** There is no override. If a test is genuinely wrong, a human must approve removing or rewriting it — the agent cannot do so unilaterally.

### 8.4 Contract Testing

Contract testing ensures that two repos agree on their shared interface. The provider repo and consumer repo each write tests against the same contract spec.

```
    ┌─────────────────┐                    ┌─────────────────┐
    │   PROVIDER REPO  │                    │  CONSUMER REPO   │
    │   (user-api)     │                    │  (user-sdk)      │
    │                  │                    │                  │
    │  ┌────────────┐  │    ┌──────────┐    │  ┌────────────┐  │
    │  │ Provider   │  │    │ CONTRACT │    │  │ Consumer   │  │
    │  │ Contract   │◀─┼────│   SPEC   │────┼─▶│ Contract   │  │
    │  │ Test       │  │    │          │    │  │ Test       │  │
    │  └─────┬──────┘  │    │ GET /user │    │  └─────┬──────┘  │
    │        │         │    │ Response: │    │        │         │
    │        ▼         │    │ {id,name} │    │        ▼         │
    │  "My endpoint    │    └──────────┘    │  "When I call    │
    │   returns this   │                    │   the endpoint,  │
    │   shape"         │                    │   I expect this  │
    │                  │                    │   shape"         │
    └─────────────────┘                    └─────────────────┘

    Both tests pass ──▶ Contract is upheld
    Either fails    ──▶ Integration will break — fix before merging
```

#### Contract Spec Format

```yaml
contract:
  name: "user-profile-api"
  version: "1.0.0"
  provider: "org/user-api"
  consumer: "org/user-sdk"
  endpoints:
    - method: GET
      path: "/v1/users/:id"
      request:
        params:
          id: { type: "string", format: "uuid" }
      response:
        status: 200
        body:
          id: { type: "string", format: "uuid" }
          name: { type: "string" }
          email: { type: "string", format: "email" }
      error_responses:
        - status: 404
          body:
            error: { code: "USER_NOT_FOUND", message: "string" }
```

### 8.5 CUA End-to-End Testing

CUA testing validates the integrated system from a user's perspective. After all repos have been implemented and contract tests pass, CUA interacts with the running system through a browser.

#### CUA Test Workflow

```
    System Agent                    CUA
         │                           │
         │  ── Test Plan ──────────▶ │
         │     (scenarios,           │
         │      expected results)    │
         │                           │
         │                      Launch browser
         │                      Navigate to app
         │                      Execute steps
         │                      Capture screenshots
         │                      Assert results
         │                           │
         │  ◀── Test Report ──────── │
         │     (pass/fail,           │
         │      screenshots,         │
         │      error details)       │
         │                           │
```

#### What CUA Tests That Automation Doesn't

| Aspect | Automated E2E | CUA |
|--------|--------------|-----|
| Predefined flows | Yes | Yes |
| Visual correctness | Limited (screenshot diff) | Full visual assessment |
| Exploratory testing | No | Yes — can notice unexpected issues |
| Cross-system flows | Hard to maintain | Natural — just uses the browser |
| Accessibility | Only with explicit assertions | Can assess as a user would |

> **CUA is not a replacement for Playwright/Cypress.** Automated E2E tests are faster, deterministic, and run in CI. CUA adds a layer of exploratory, visual, and cross-boundary testing that complements automation. Run CUA after automated tests pass.

---

## 9. Proof of Concept

### 9.1 Scenario

A two-repo proof of concept that validates the core orchestration loop. The scenario: **add a "user profile" feature** that requires a new API endpoint and a new SDK method.

#### Repos

| Repo | Type | What Changes |
|------|------|-------------|
| `demo-api` | api-service (Express + TypeScript) | New `GET /v1/users/:id` endpoint |
| `demo-sdk` | sdk-library (TypeScript) | New `getUser(id): Promise<User>` method |

Both repos have Progressive Disclosure docs (`docs/ai/`) pre-generated per the PD standard.

#### What This Proves

- System Agent can read System Card and repo L0s to understand the system
- System Agent can produce an Epic Plan with correct dependency ordering
- Interface contracts can be agreed before implementation
- Repo Agents can implement in parallel, constrained by contracts
- Contract tests catch mismatches before integration
- The file-based communication approach works end-to-end

### 9.2 Step-by-Step Walkthrough

#### Step 1: System Agent — Discovery

```
Input:  "Add user profile retrieval to the system"
Action: Load System Card → identify affected repos

System Agent reads:
  - system-card.md → repo registry, dependency map
  - demo-api/docs/ai/L0_repo_card.md → API identity
  - demo-sdk/docs/ai/L0_repo_card.md → SDK identity
  - demo-api/docs/ai/L1_operator_pack/06_interfaces.md → current API surface
  - demo-sdk/docs/ai/L1_operator_pack/06_interfaces.md → current SDK surface

Output: "Two repos affected. demo-api provides the endpoint. demo-sdk consumes it."
```

#### Step 2: System Agent — Planning

```
Output: Epic Plan

  Epic: User Profile Retrieval
  ────────────────────────────
  1. demo-api: Add GET /v1/users/:id
     - Returns { id, name, email }
     - Returns 404 for unknown ID
     - No dependencies

  2. demo-sdk: Add getUser(id) method
     - Calls GET /v1/users/:id
     - Returns typed User object
     - Depends on: demo-api contract
```

**→ GATE: Human reviews Epic Plan**

#### Step 3: System Agent — Interface Agreement

```
Output: Contract spec (user-profile-api.contract.yaml)

  System Agent proposes contract.
  demo-api Repo Agent confirms: "I can provide this shape."
  demo-sdk Repo Agent confirms: "I can consume this shape."
```

**→ GATE: Human reviews contract**

#### Step 4: Repo Agents — Implementation (Parallel, TDD Enforced)

```
demo-api Repo Agent:
  1. Loads L0 + all L1 (PD standard)
  2. Reads Task Spec + contract
  ── TDD Loop: Unit tests ──
  3. Writes test: GET /v1/users/:id returns { id, name, email }
  4. Writes test: GET /v1/users/:id returns 404 for unknown ID
  5. Runs tests → both FAIL (red) ✓ confirms tests check something
  6. Implements endpoint
  7. Runs tests → both PASS (green) ✓
  ── TDD Loop: Contract tests ──
  8. Writes provider contract test against contract spec
  9. Runs contract test → FAIL (red) ✓
  10. (Already implemented — expects pass)
  11. Runs contract test → PASS (green) ✓
  ── Completion check ──
  12. Runs full test suite: 4 passed, 0 failed, 0 skipped
  13. Reports: status: complete, test_result: { passed: 4, failed: 0, skipped: 0 }

demo-sdk Repo Agent:
  1. Loads L0 + all L1 (PD standard)
  2. Reads Task Spec + contract
  ── TDD Loop: Unit tests ──
  3. Writes test: getUser(validId) returns typed User
  4. Writes test: getUser(unknownId) throws UserNotFoundError
  5. Runs tests → both FAIL (red) ✓
  6. Implements getUser method
  7. Runs tests → 1 PASS, 1 FAIL
  ── Fix Loop (attempt 1) ──
  8. Reads failure: error mapping doesn't handle 404
  9. Fixes error handling in getUser
  10. Runs tests → both PASS (green) ✓
  ── TDD Loop: Contract tests ──
  11. Writes consumer contract test against contract spec
  12. Runs contract test → FAIL (red) ✓
  13. (Already implemented — expects pass)
  14. Runs contract test → PASS (green, mock server) ✓
  ── Completion check ──
  15. Runs full test suite: 5 passed, 0 failed, 0 skipped
  16. Reports: status: complete, test_result: { passed: 5, failed: 0, skipped: 0 }
```

**System Agent validates both status reports:** `failed == 0 AND skipped == 0` for both repos. Gate opens.

**→ GATE: Human reviews PRs in both repos**

#### Step 5: Integration (Completion Rule Enforced)

```
System Agent:
  1. Checks status reports:
     - demo-api: complete, { passed: 4, failed: 0, skipped: 0 } ✓
     - demo-sdk: complete, { passed: 5, failed: 0, skipped: 0 } ✓
  2. Runs cross-repo contract tests:
     - Provider (demo-api) contract test: PASS ✓
     - Consumer (demo-sdk) contract test: PASS ✓
  3. Coordinates integration test: SDK calls running API
     - getUser("valid-id") → { id, name, email } ✓
     - getUser("unknown-id") → UserNotFoundError ✓
  4. All tests green across all repos. Integration verified.
```

**If any contract test failed:** System Agent reports `status: blocked`, identifies the mismatch (e.g., "provider returns `userName` but consumer expects `name`"), and assigns a fix task to the responsible Repo Agent. The gate does not open until re-run passes.

**→ GATE: Human reviews integration results**

#### Step 6: E2E Validation (Optional for API+SDK)

For an API + SDK proof of concept, CUA testing may not apply (no browser UI). In a full system with a frontend repo, CUA would test the user flow through the web app.

### 9.3 Success Criteria

| Criterion | Measurement |
|-----------|------------|
| System Agent correctly identifies affected repos | Reads System Card, outputs correct repo list |
| Epic Plan has correct dependency ordering | SDK depends on API, not the reverse |
| Interface contract is agreed before implementation | Contract file exists before code is written |
| Repo Agents implement independently | No cross-repo file modifications |
| Contract tests pass | Provider and consumer tests both green |
| Integration test passes | SDK successfully calls running API |
| TDD loop followed | Tests written and run (red) before implementation in both repos |
| Completion rule enforced | No repo reports `complete` with `failed > 0` or `skipped > 0` |
| Fix loop works | SDK agent hits a test failure, fixes it within 3 attempts, reports complete |
| Human review gates function | System pauses at each gate, resumes on approval |
| Total orchestration overhead | < 20% of total implementation time |

---

## 10. Open Questions

These questions are explicitly unresolved. Each includes context and candidate answers to frame discussion.

---

**OQ-1: Communication Transport** `[OPEN QUESTION]`

How do agents exchange messages (Task Specs, status updates, results)?

| Candidate | Argument For | Argument Against |
|-----------|-------------|-----------------|
| File-based | Human-readable, auditable, resumable | Polling overhead, no real-time notifications |
| Message queue | Async-native, scalable | Infrastructure dependency, less human-visible |
| Direct calls | Simplest, built into AI tools | Ephemeral, no audit trail, hard to resume |

**Leaning:** File-based for PoC, hybrid for production.

---

**OQ-2: System Card Ownership** `[OPEN QUESTION]`

Where does the System Card live and who maintains it?

| Candidate | Description |
|-----------|-------------|
| Dedicated orchestration repo | Central repo with System Card + epic history |
| Auto-generated from L0 scraping | Script crawls all repos, builds System Card dynamically |
| Hybrid | Auto-generated registry + manually maintained shared conventions |

**Consideration:** Auto-generation ensures the registry stays fresh but can't capture cross-cutting conventions (auth mechanism, error format) that live above any single repo.

---

**OQ-3: Agent Identity and State** `[OPEN QUESTION]`

How do agents maintain identity across sessions? If a System Agent session times out during Phase 4, how does it resume?

| Candidate | Description |
|-----------|-------------|
| Stateless (file-driven) | All state is in workspace files. Any agent can read files and resume. |
| Session-based | Agent sessions persist with conversation history. Resumption requires the same session. |
| Checkpoint-based | Agents write explicit checkpoint files at each phase transition. |

**Leaning:** Stateless with checkpoint files. The file-based workspace already contains enough state to resume without session affinity.

---

**OQ-4: Conflict Resolution** `[OPEN QUESTION]`

What happens when two Repo Agents report conflicting implementations? Example: API returns `userName` but SDK expects `name`.

| Candidate | Description |
|-----------|-------------|
| Contract tests catch it | If contract tests are comprehensive, mismatches fail before integration |
| System Agent mediates | System Agent detects conflict, proposes resolution, assigns fix |
| Human escalation | Flag to human reviewer at integration gate |

**Leaning:** Contract tests as first line; System Agent mediation as second; human escalation as last resort.

---

**OQ-5: Scope Boundaries** `[OPEN QUESTION]`

How large can an epic be before it should be split? Is there a maximum number of repos or tasks?

| Candidate | Description |
|-----------|-------------|
| No limit | Trust the System Agent to decompose appropriately |
| Soft limit (5 repos) | Recommend splitting epics that touch more than 5 repos |
| Hard limit (3 repos) | Enforce maximum to keep coordination manageable |

**Consideration:** Coordination complexity grows roughly quadratically with repo count (each pair can have interface interactions). Smaller epics reduce blast radius.

---

**OQ-6: Contract Versioning** `[OPEN QUESTION]`

How do interface contracts evolve? Can a contract be updated mid-epic?

| Candidate | Description |
|-----------|-------------|
| Immutable per epic | Contract is locked after Phase 3. Changes require a new epic. |
| Amendment process | Contract can be amended with re-approval at a new gate. |
| Semantic versioning | Contracts are versioned. Breaking changes bump major version. |

**Leaning:** Amendment process for the PoC (pragmatic). Semantic versioning for production (principled).

---

**OQ-7: Failure and Rollback** `[OPEN QUESTION]`

If Phase 5 integration fails, what happens to the code already written in Phase 4?

| Candidate | Description |
|-----------|-------------|
| Revert all | Roll back all repos to pre-epic state |
| Fix forward | Identify the mismatch, update the failing repo, re-test |
| Partial deploy | Deploy repos that are independently safe, hold the rest |

**Consideration:** Reverting all is safe but wasteful. Fixing forward is faster but risks cascading fixes. Partial deploy is risky if repos are tightly coupled.

---

**OQ-8: CUA Scope** `[OPEN QUESTION]`

Should CUA only validate, or should it also perform setup actions (create test users, seed data)?

| Candidate | Description |
|-----------|-------------|
| Validate only | CUA tests the system as-is. Setup is done by scripts or Repo Agents. |
| Setup + validate | CUA can perform setup actions as part of test execution. |

**Leaning:** Validate only. Setup through CUA is fragile and hard to reproduce. Use scripts for deterministic setup.

---

**OQ-9: Security Boundaries** `[OPEN QUESTION]`

How do we ensure the System Agent can't be manipulated into making unauthorized cross-repo changes?

| Candidate | Description |
|-----------|-------------|
| File permissions | Repo Agent runs with write access only to its repo |
| Capability tokens | System Agent issues scoped tokens that limit what each agent can do |
| Audit log + review | All actions are logged. Human reviews catch unauthorized changes. |

**Consideration:** The repo sovereignty rule is a policy, not a mechanism. Enforcement depends on the execution environment.

---

**OQ-10: Scaling to Many Repos** `[OPEN QUESTION]`

The PoC uses 2 repos. How does this architecture scale to 10, 50, or 200 repos?

| Factor | 2 Repos | 10 Repos | 50+ Repos |
|--------|---------|----------|-----------|
| System Card size | Trivial | Manageable (~5,000 tokens) | Needs hierarchical System Cards |
| System Agent context | All L0s fit easily | All L0s still fit (~5,000 tokens) | May need selective loading |
| Coordination overhead | Minimal | Moderate | Needs sub-system agents |
| Contract count | 1 | O(N) to O(N²) | Requires contract registry |

**Consideration:** At scale, the flat System Card may need to become hierarchical — a "System of Systems" with sub-system cards that group related repos. This mirrors the PD standard's own progressive disclosure: load the system overview, then drill into sub-systems.

---

### End of Draft
