# Multi-Repo Orchestration

## A Guide to Multi-Agent Coordination Across Repositories

> **Prerequisite:** This guide depends on the [Progressive Disclosure Documentation Standard](progressive-disclosure-standard.md). Repos must have at least L0 (Repo Card) and L1 (Operator Pack) docs for the System Agent to read. Set those up first.

> **For single-repo AI coding practices, start with the [README](README.md).** This document covers coordination across multiple repositories.

> **This is a conceptual guide, not a specification.** Everything here is a recommendation, not a rule. Sections marked `[OPEN QUESTION]` are explicitly unsettled. The PoC (§8) has not yet been executed. Feedback welcome.

> **Start here:** Read §1 for the model, §5 for the lifecycle, §8 for the PoC. Everything else is reference.

---

## Table of Contents

- [1. Summary](#1-summary)
- [2. Why This Guide](#2-why-this-guide)
- [3. Architecture](#3-architecture)
- [4. The System Card](#4-the-system-card)
- [5. Epic Lifecycle](#5-epic-lifecycle)
- [6. Cross-Repo Code Review](#6-cross-repo-code-review)
- [7. Testing and Completion](#7-testing-and-completion)
- [8. Proof of Concept](#8-proof-of-concept)
- [9. Open Questions](#9-open-questions)

---

## 1. Summary

This guide describes a **multi-agent architecture** for coordinating AI coding work across multiple git repositories. It builds on the [Progressive Disclosure Documentation Standard](progressive-disclosure-standard.md), which makes individual repos self-describing. This document addresses the next layer: how agents collaborate when a feature spans multiple codebases.

The core idea: a coordinating agent specs and plans cross-repo work, repo-level agents implement within their own boundaries, and structured review gates keep humans in the loop. [Test Driven Development](README.md#4-test-driven-development) anchors quality at the single-repo level; this document adds the multi-repo coordination layer on top.

### Agent Tiers

| Tier   | Agent         | Scope                          | Writes Code?                    |
| ------ | ------------- | ------------------------------ | ------------------------------- |
| **T0** | System Agent  | Cross-repo orchestration       | No — plans and coordinates only |
| **T1** | Repo Agent    | Single repository              | Yes — sole writer for its repo  |
| **T2** | Sub-Agent     | Single task within a repo      | Yes — delegated by Repo Agent   |
| **T3** | E2E Validator | Integrated system (browser/UI) | No — tests and validates only   |

---

## 2. Why This Guide

### The Problem

The [Progressive Disclosure Documentation Standard](progressive-disclosure-standard.md) solves a single-repo problem: making one codebase self-describing for AI agents. But real features rarely live in one repo. A new API endpoint may require backend changes, SDK updates, frontend integration, and infrastructure provisioning.

AI coding agents working in isolation produce locally correct but globally inconsistent changes. An agent modifying the API may rename a field that the SDK agent doesn't know about. Without system-level coordination, multi-repo features require constant human shepherding.

### The Insight

Cross-repo features follow a predictable lifecycle: understand the system, plan across repos, agree on interfaces, implement in parallel, test integration, validate end-to-end. This lifecycle can be modeled with explicit review gates, enabling a coordinating agent to keep repo-level agents aligned without micromanaging their implementation choices.

### Design Principles

> **Repo sovereignty** — Each repository has exactly one Repo Agent. No external agent writes to a repo it doesn't own.

> **Spec before plan, plan before code** — All cross-repo work begins with a system-level spec, then an epic plan, both reviewed by a human before any code is written.

> **Interface-driven coordination** — Cross-repo dependencies are expressed as contracts agreed upon before implementation.

> **Progressive disclosure integration** — Agents bootstrap their understanding of each repo from L0/L1 docs, not raw file trees.

> **Human-in-the-loop** — Review gates at plan, interface agreement, and integration phases.

---

## 3. Architecture

### System Diagram

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
    └──────┬───────────┘ └──────┬───────┘ └──────┬───────────┘
           │                    │                 │
      ┌────▼────┐          ┌───▼───┐        ┌────▼────┐
      │Sub-Agent│          │Sub-Ag.│        │Sub-Agent│
      │  (T2)   │          │ (T2)  │        │  (T2)   │
      └─────────┘          └───────┘        └─────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                     E2E VALIDATOR (T3)                       │
    │        Validates integrated system via browser/UI           │
    │           Tests user flows end-to-end · Reports back        │
    └─────────────────────────────────────────────────────────────┘
```

### Agent Roles

| Tier | Agent         | What It Does                                                                              | What It Never Does              |
| ---- | ------------- | ----------------------------------------------------------------------------------------- | ------------------------------- |
| T0   | System Agent  | Plans, coordinates, assigns tasks across repos, manages review gates                      | Write code or modify repo files |
| T1   | Repo Agent    | Implements tasks, writes code and tests, reports status. Sole writer for its repo.        | Modify files in another repo    |
| T2   | Sub-Agent     | Executes scoped sub-tasks delegated by a Repo Agent (test writing, searches, scaffolding) | Act outside its delegated scope |
| T3   | E2E Validator | Tests the integrated system through browser/UI, reports pass/fail with screenshots        | Write production code           |

> **Why separate the System Agent from Repo Agents?** A single agent with write access to multiple repos would violate repo sovereignty. The System Agent's power is coordination, not implementation. This prevents a class of bugs where an orchestrator makes locally-reasonable but globally-inconsistent changes.

### Relationship to Progressive Disclosure

This architecture depends on the [Progressive Disclosure Documentation Standard](progressive-disclosure-standard.md) at every tier:

- **System Agent** scrapes L0 Identity Blocks from all repos to build the System Card's repo registry. It reads L1 `06_interfaces.md` files to understand cross-repo contracts.
- **Repo Agents** load their own repo's L0 + L1 per the PD loading protocol. They read other repos' L0s to understand dependencies.
- **Sub-Agents** load subsets of L1/L2 relevant to their specific sub-task.
- **E2E Validator** doesn't read docs — it tests the running system.

> **Why PD is prerequisite:** Without self-describing repos, the System Agent would need to scan every file in every repo. PD's L0 Identity Block provides structured metadata that can be scraped programmatically.

---

## 4. The System Card

The System Card is the system-level equivalent of a repo's L0 Repo Card. It describes the whole system: which repos exist, what they do, how they connect, and what the shared conventions are.

### How It's Built

The repo registry is populated by scraping L0 Identity Blocks from each repo's PD docs. System-level context (shared conventions, environments) is added on top — information that lives above any single repo.

### Template Sketch

```markdown
# [System Name] — System Card

> [One-line description of the system]

## Identity

| Field       | Value                               |
| ----------- | ----------------------------------- |
| System      | [system-name]                       |
| Description | [What the system does — 1 sentence] |
| Owner       | [Team or org]                       |
| Repos       | [Count]                             |

## Repo Registry

| Repo           | Type         | Language   | Description                 |
| -------------- | ------------ | ---------- | --------------------------- |
| `org/user-api` | api-service  | TypeScript | User management REST API    |
| `org/user-sdk` | sdk-library  | TypeScript | TypeScript SDK for User API |
| `org/web-app`  | frontend-app | TypeScript | Customer-facing web app     |

## Dependency Map

[ASCII diagram or table showing provider → consumer relationships]

## Shared Conventions

| Convention     | Value                                  |
| -------------- | -------------------------------------- |
| API versioning | [e.g., URL path prefix]                |
| Auth mechanism | [e.g., JWT]                            |
| Error format   | [e.g., `{ error: { code, message } }`] |
```

### PoC System Card

This is the filled-in System Card for the proof of concept in §8:

```markdown
# Demo User System — System Card

> A minimal user profile system for validating multi-repo orchestration.

## Identity

| Field       | Value                                |
| ----------- | ------------------------------------ |
| System      | demo-user-system                     |
| Description | User profile API with TypeScript SDK |
| Owner       | Platform team                        |
| Repos       | 2                                    |

## Repo Registry

| Repo       | Type        | Language   | Description                 |
| ---------- | ----------- | ---------- | --------------------------- |
| `demo-api` | api-service | TypeScript | User management REST API    |
| `demo-sdk` | sdk-library | TypeScript | TypeScript SDK for demo-api |

## Dependency Map

demo-api (provider) → demo-sdk (consumer)

## Shared Conventions

| Convention     | Value                          |
| -------------- | ------------------------------ |
| API versioning | URL path prefix (`/v1/`)       |
| Auth mechanism | None (PoC)                     |
| Error format   | `{ error: { code, message } }` |
```

`[OPEN QUESTION]` Where does the System Card live? Options include a dedicated orchestration repo, auto-generation from L0 scraping, or a hybrid where the registry is auto-generated but shared conventions are maintained manually.

---

## 5. Epic Lifecycle

An "epic" is a cross-repo feature that requires coordinated changes across two or more repositories. We recommend organizing this work in phases with human review gates.

### Phases

| Phase | Name                | Who                        | What Happens                                                                       |
| ----- | ------------------- | -------------------------- | ---------------------------------------------------------------------------------- |
| 1     | Discovery           | System Agent               | Loads System Card, identifies affected repos, reads their L0/L1 docs               |
| 2     | Planning            | System Agent               | Produces an Epic Plan: per-repo tasks, execution order, interface changes          |
| 3     | Interface Agreement | System Agent + Repo Agents | All affected agents review and agree on interface contracts before code is written |
| 4     | Implementation      | Repo Agents (parallel)     | Each agent implements its task using TDD, constrained by agreed contracts          |
| 5     | Integration         | System Agent + Repo Agents | Cross-repo contract tests, integration verification                                |
| 6     | E2E Validation      | E2E Validator              | Tests the integrated system through browser/UI                                     |
| 7     | Deploy              | Human                      | Production deployment per existing team process                                    |

### Interface Contract Example

During Phase 3, the System Agent proposes an interface contract. Both Repo Agents review and agree before implementation begins:

```markdown
## Contract: GET /v1/users/:id

**Provider:** demo-api
**Consumer:** demo-sdk

### Request

GET /v1/users/:id

### Response (200)

{ "id": "string", "name": "string", "email": "string" }

### Response (404)

{ "error": { "code": "USER_NOT_FOUND", "message": "string" } }
```

### Review Gates

We recommend human review gates between key phases. The System Agent pauses and presents its work for approval before proceeding.

| Gate               | When          | What the Human Reviews                                      |
| ------------------ | ------------- | ----------------------------------------------------------- |
| Plan Review        | After Phase 2 | Epic Plan — affected repos, task breakdown, execution order |
| Contract Review    | After Phase 3 | Interface contracts between repos                           |
| Code Review        | After Phase 4 | Pull requests in each repo                                  |
| Integration Review | After Phase 5 | Cross-repo test results, contract alignment                 |
| E2E Review         | After Phase 6 | E2E Validator test report and screenshots                   |

> **Why front-load reviews?** Cross-repo errors are expensive. A wrong interface contract discovered during implementation wastes work in multiple repos. Catching errors at the plan and contract phase is far cheaper. Teams can relax gates as they build trust in the system.

### Sovereignty in Practice

The System Agent specifies _what_ needs to happen. The Repo Agent decides _how_.

| System Agent Says                                         | Repo Agent Decides                                        |
| --------------------------------------------------------- | --------------------------------------------------------- |
| "Add a `/users` endpoint returning `{ id, name, email }`" | Route structure, controller design, model layer           |
| "Expose a `getUser(id)` method in the SDK"                | Method signature, error handling, internal implementation |

---

## 6. Cross-Repo Code Review

When one agent's changes affect another repo's interface, the affected Repo Agent should review the change. This is cross-repo code review — a coordination mechanism that catches integration issues before they reach the integration phase.

### When It Applies

Cross-repo review applies when a change in one repo alters a shared interface: an API response shape, an SDK method signature, a shared data format, or any contract surface that another repo depends on.

### How It Works

1. **Repo Agent A** implements a change that modifies an interface consumed by Repo B.
2. The **System Agent** identifies this as a cross-repo interface change (from the dependency map and contract registry).
3. The **System Agent** passes the relevant diff to Repo Agent B — either via a PR link, a file in a shared workspace, or by including the diff content in the task spec.
4. **Repo Agent B** reviews the change from the consumer's perspective:
   - Does the new interface match what I expect?
   - Will my existing code break?
   - Do I need to update my implementation?
5. Repo Agent B reports back: **compatible** (no changes needed), **update needed** (I can adapt), or **conflict** (this breaks my assumptions — needs discussion).

### What Gets Reviewed

| Change Type                  | Reviewer                         | What They Check                                |
| ---------------------------- | -------------------------------- | ---------------------------------------------- |
| API response shape changed   | Consumer Repo Agent(s)           | Does my parsing/deserialization still work?    |
| SDK method signature changed | Consumer Repo Agent(s)           | Do my call sites still compile/work?           |
| Shared data format changed   | All Repo Agents using the format | Can I produce/consume the new format?          |
| New dependency introduced    | Downstream Repo Agent(s)         | Does this affect my build, deploy, or runtime? |

> **This complements, not replaces, contract testing.** Contract tests verify interfaces mechanically. Cross-repo code review adds judgment: "Yes, this technically conforms to the contract, but the field name is confusing" or "This new optional field will cause issues with our caching layer."

`[OPEN QUESTION]` Should cross-repo review be a formal gate (blocking) or an advisory step? Blocking is safer but adds latency. Advisory is faster but relies on agents and humans noticing issues.

---

## 7. Testing and Completion

### Test Driven Development

Repo Agents follow [Test Driven Development](README.md#4-test-driven-development) as described in the README — write the test first, verify it fails, implement, verify it passes.

### Test Layers

| Layer           | Scope                             | Who                    | When                     |
| --------------- | --------------------------------- | ---------------------- | ------------------------ |
| Unit            | Single function/module            | Repo Agent             | Phase 4 — Implementation |
| Integration     | Single repo, external deps mocked | Repo Agent             | Phase 4 — Implementation |
| Contract        | Interface between two repos       | Both Repo Agents       | Phase 5 — Integration    |
| E2E (automated) | Running system, scripted flows    | Repo Agent (test code) | Phase 5 — Integration    |
| E2E (validated) | Running system, exploratory       | E2E Validator          | Phase 6 — Validation     |

### The Completion Rule

The [completion rule](README.md#4-test-driven-development) applies at every level: a Repo Agent should not report a task as complete if any test is failing or skipped. The System Agent should not advance the epic to the next phase while any repo has failing tests.

### Contract Testing

Contract testing ensures two repos agree on their shared interface. The provider repo and consumer repo each write tests against the same contract:

- **Provider test:** "My endpoint returns this shape"
- **Consumer test:** "When I call the endpoint, I expect this shape"

If both pass, the contract is upheld. If either fails, integration will break — fix before merging. This is the mechanical complement to cross-repo code review (Section 6).

`[OPEN QUESTION]` What contract testing framework to recommend? Options range from Pact (established, polyglot) to simpler schema-validation approaches. The choice may depend on team tooling.

---

## 8. Proof of Concept

> **Status:** This PoC is a design, not a report. It has not yet been executed. If you validate it, please report results.

### Scenario

A two-repo proof of concept validates the core orchestration loop: **add a "user profile" feature** requiring a new API endpoint and a corresponding SDK method.

| Repo       | Type                               | What Changes                            |
| ---------- | ---------------------------------- | --------------------------------------- |
| `demo-api` | API service (Express + TypeScript) | New `GET /v1/users/:id` endpoint        |
| `demo-sdk` | SDK library (TypeScript)           | New `getUser(id): Promise<User>` method |

Both repos have Progressive Disclosure docs pre-generated per the PD standard. See §4 for the filled-in System Card.

### What Happens

1. **Discovery** — System Agent loads the System Card, identifies both repos as affected, reads their L0 + relevant L1 files.
2. **Planning** — System Agent produces an Epic Plan: `demo-api` provides the endpoint (no dependencies), `demo-sdk` consumes it (depends on API contract).
3. **Interface agreement** — Both Repo Agents review and agree on the contract (response shape, error codes). Human reviews. See the contract example in §5.
4. **Implementation** — Both Repo Agents implement in parallel using [TDD](README.md#4-test-driven-development). The API agent writes endpoint tests first, then the endpoint. The SDK agent writes method tests first, then the method.
5. **Cross-repo review** — The SDK Repo Agent reviews the API's response shape from the consumer perspective.
6. **Integration** — Contract tests run in both repos. Integration test verifies the SDK can call the running API.
7. **Validation** — If a frontend repo existed, the E2E Validator would test the user flow through the browser.

### What This Proves

- System Agent can read the System Card and repo L0s to plan cross-repo work
- Interface contracts can be agreed before implementation begins
- Repo Agents can implement in parallel, constrained by contracts
- Cross-repo code review catches consumer-side issues early
- Contract tests catch interface mismatches before integration
- The completion rule prevents incomplete work from advancing

---

## 9. Open Questions

These are explicitly unsettled. We include them to frame discussion, not to prescribe answers. Questions marked **(blocks PoC)** should be resolved before running the proof of concept.

**Communication transport** `[OPEN QUESTION]` **(blocks PoC)** — How do agents exchange task specs, status updates, and results? File-based (auditable), sub-processes (simple), or message queues (scalable). We lean toward file-based for the PoC.

**Agent state and resumability** `[OPEN QUESTION]` **(blocks PoC)** — If a System Agent session times out mid-epic, how does it resume? File-based state (plans, status reports, contracts) enables any session to pick up where the previous one left off.

**Conflict resolution** `[OPEN QUESTION]` — When two Repo Agents produce conflicting implementations (e.g., API returns `userName` but SDK expects `name`), what resolves it? Contract tests catch most mismatches; cross-repo review catches subtler issues; human escalation handles the rest.

**Epic scope boundaries** `[OPEN QUESTION]` — How large should an epic be? We suspect 3-5 repos per epic keeps coordination manageable, but this needs validation.

**Scaling to many repos** `[OPEN QUESTION]` — At 50+ repos, a flat System Card may need to become hierarchical — a "System of Systems" with sub-system cards.

**Contract versioning** `[OPEN QUESTION]` — Can a contract change mid-epic? We lean toward amendments with re-approval for the PoC, moving toward semantic versioning for production use.
