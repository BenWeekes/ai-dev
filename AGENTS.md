# Agent Conventions

ai-dev-kit provides git conventions and documentation generation as skills for AI coding agents.

## Repo Structure

| Path                         | Purpose                                        |
| ---------------------------- | ---------------------------------------------- |
| `skills/ai-dev-kit/SKILL.md` | entry point — conventions + skill directory    |
| `skills/ai-dev-kit/git/`     | git workflow skills (ship, pr, sync)           |
| `skills/ai-dev-kit/docs/`    | documentation skills (update, test)            |
| `hooks/`                     | session-start hook, platform wrappers          |
| `*.md` (root)                | standards (progressive disclosure, multi-repo) |
| `.claude-plugin/`            | Claude Code plugin config                      |
| `.cursor-plugin/`            | Cursor plugin config                           |
| `.codex/`                    | Codex install guide                            |
| `gemini-extension.json`      | Gemini extension config                        |

## Architecture

- **Ambient conventions** — `hooks/session-start` reads `skills/ai-dev-kit/SKILL.md` and injects git rules into the session context at startup. No user action needed.
- **On-demand skills** — detailed workflows (ship, pr, sync, docs) are loaded via the Skill tool when invoked.

## Conventions

1. **Commit messages:** lowercase start, no AI tool names, present tense.
2. **Spec before plan, plan before code.** Separate WHAT from HOW.
3. **Test driven development.** Write the test first, verify it fails, implement, verify it passes.
4. **Review before commit.** AI review checks spec compliance and code quality.

## Complementary Skills

- [Superpowers](https://github.com/obra/superpowers) — spec, plan, TDD, review workflow
