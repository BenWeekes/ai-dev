# ai-dev-kit

Git conventions and documentation generation for AI-assisted development. Works with Claude Code, Cursor, Codex, and Gemini.

## Install

### Claude Code

```bash
claude install github.com/BenWeekes/ai-dev-kit
```

### Cursor

```bash
cursor install github.com/BenWeekes/ai-dev-kit
```

## How it works

ai-dev-kit uses a skill-based architecture:

1. **Session start** — a hook reads `skills/ai-dev-kit/SKILL.md` and injects git conventions into the session context. These are always active — you don't need to invoke anything.

2. **On demand** — detailed workflows (ship, pr, sync, docs) are loaded via the Skill tool when you need them.

### Ambient conventions (always active)

These rules are injected at session start and apply to every git operation:

- lowercase commit messages
- no AI tool names in commits
- present tense ("add feature", not "added feature")
- no Co-Authored-By trailers
- no --no-verify

### Skills (on demand)

| Skill    | What it does                                      |
| -------- | ------------------------------------------------- |
| `ship`   | commit staged changes and push to remote          |
| `pr`     | create a pull request from the current branch     |
| `sync`   | rebase current branch onto latest main            |
| `update` | generate progressive disclosure docs for the repo |
| `test`   | verify generated docs meet the standard           |

## Standards

ai-dev-kit includes two standards for AI-assisted development:

- **[Progressive Disclosure Documentation](progressive-disclosure-standard.md)** — a three-level (L0/L1/L2) architecture that makes repos self-describing for AI agents
- **[Multi-Repo Orchestration](multi-repo-orchestration.md)** — coordination patterns for features that span multiple repos

## Using with other skills

ai-dev-kit pairs well with [Superpowers](https://github.com/obra/superpowers) for a complete workflow:

1. spec — capture what you want to build
2. plan — plan how to build it
3. tdd — implement with tests
4. review — review the changes
5. ship — commit and push (ai-dev-kit conventions enforced)
6. pr — create a PR
7. update — update repo docs if needed

## Repo structure

| Path                 | Purpose                                        |
| -------------------- | ---------------------------------------------- |
| `skills/ai-dev-kit/` | skill definitions (SKILL.md + sub-skills)      |
| `hooks/`             | session-start hook and platform wrappers       |
| `*.md` (root)        | standards (progressive disclosure, multi-repo) |
| `.claude-plugin/`    | Claude Code plugin config                      |
| `.cursor-plugin/`    | Cursor plugin config                           |
| `.codex/`            | Codex install guide                            |

## License

MIT
