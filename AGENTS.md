# Agent Conventions

This repo is a template for AI-assisted development. Clone it, run `./init.sh <agent>`, and start working.

## Repo Structure

| Path                                 | Purpose                                                     |
| ------------------------------------ | ----------------------------------------------------------- |
| `README.md`                          | The guide — setup, workflow, advanced topics                |
| `AGENTS.md`                          | Agent conventions (this file)                               |
| `CLAUDE.md`                          | Claude Code wrapper — points here                           |
| `commands/`                          | Slash command source files (neutral, all agents)            |
| `hooks/`                             | Git hook scripts (installed by `init.sh`)                   |
| `docs/plans/`                        | Plans created with `/plan` — version-controlled, reviewable |
| `progressive-disclosure-standard.md` | Documentation standard for self-describing repos            |
| `multi-repo-orchestration.md`        | Multi-agent coordination across repos                       |

## Conventions

1. **Plan before code.** Use `/plan` to create a plan in `docs/plans/` before implementing. Plans are markdown, version-controlled, and reviewed in PRs.
2. **TDD.** Write the test first, verify it fails, implement, verify it passes. Use `/tdd` to enforce the cycle.
3. **Review before commit.** Use `/review` to check staged changes before committing.
4. **Commit messages:** lowercase start, no AI tool names, present tense. Hooks enforce this automatically.

## Slash Commands

| Command   | What It Does                                                                      |
| --------- | --------------------------------------------------------------------------------- |
| `/plan`   | Create a plan in `docs/plans/` with numbered requirements and acceptance criteria |
| `/review` | Review `git diff --cached` for correctness, security, conventions, and simplicity |
| `/tdd`    | Implement a task using strict test-driven development                             |
| `/docs`   | Generate progressive disclosure documentation following the PD standard           |

## Architectural Constraints

- **Plans live in `docs/plans/`.** Not in comments, not in issues, not ephemeral. They're markdown files in the repo.
- **Progressive disclosure for docs.** Follow `progressive-disclosure-standard.md` when generating repo documentation. Docs go in `docs/ai/`.
- **Slash commands are simple markdown.** No scripts, no execution, no handoffs. A command is a prompt with `$ARGUMENTS` placeholder.
- **Hooks are the safety net.** Git hooks enforce commit message format and run lint/format/security checks. Don't skip them.
