# Agent Conventions

This repo is a template for AI-assisted development. Clone it, run `./init.sh <agent>`, and start working. Use [Superpowers](https://github.com/obra/superpowers) for the workflow layer (spec, plan, TDD, review).

## Repo Structure

| Path                                 | Purpose                                          |
| ------------------------------------ | ------------------------------------------------ |
| `README.md`                          | The guide — setup, workflow, advanced topics     |
| `AGENTS.md`                          | Agent conventions (this file)                    |
| `CLAUDE.md`                          | Claude Code wrapper — points here                |
| `commands/`                          | Slash command source files (neutral, all agents) |
| `hooks/`                             | Git hook scripts (installed by `init.sh`)        |
| `docs/plans/`                        | Specs and plans — version-controlled, reviewable |
| `progressive-disclosure-standard.md` | Documentation standard for self-describing repos |
| `multi-repo-orchestration.md`        | Multi-agent coordination across repos            |

## Conventions

1. **TDD.** Write the test first, verify it fails, implement, verify it passes. Fix the code, not the test.
2. **Spec before plan, plan before code.** Capture requirements (WHAT/WHY) before designing the approach (HOW). Both live in `docs/plans/`, are version-controlled, and reviewed in PRs.
3. **Review before commit.** AI review checks spec compliance and code quality between tasks. Human review gates the plan, spec, and final PR.
4. **Commit messages:** lowercase start, no AI tool names, present tense. Hooks enforce this automatically.

## Slash Commands

| Command     | What It Does                                                             |
| ----------- | ------------------------------------------------------------------------ |
| `/docs`     | Generate progressive disclosure documentation following the PD standard  |
| `/git:ship` | Commit staged changes and push (preserves git author, no Co-Authored-By) |
| `/git:pr`   | Create a PR from current branch to main with generated title and summary |
| `/git:sync` | Pull latest from main, rebase current branch on top                      |

For workflow commands (spec, plan, TDD, review), use [Superpowers](https://github.com/obra/superpowers).

## Architectural Constraints

- **Specs and plans live in `docs/plans/`.** Not in comments, not in issues, not ephemeral. They're markdown files in the repo.
- **Progressive disclosure for docs.** Follow `progressive-disclosure-standard.md` when generating repo documentation. Docs go in `docs/ai/`.
- **Slash commands are simple markdown.** No scripts, no execution, no handoffs. A command is a prompt with `$ARGUMENTS` placeholder.
- **Hooks are the safety net.** Git hooks enforce commit message format and run lint/format/security checks. Don't skip them.
