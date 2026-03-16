# AI-Assisted Development Template

See AGENTS.md for full conventions.

## Quick Reference

- **Workflow:** use [Superpowers](https://github.com/obra/superpowers) for spec, plan, TDD, and review
- **Docs:** `/docs` generates progressive disclosure documentation
- **Git:** `/git:ship` commit + push, `/git:pr` create PR, `/git:sync` rebase on main

## Commit Conventions

- lowercase start, no AI tool names, present tense
- hooks enforce this — run `./init.sh` if hooks aren't installed

## Key Files

- `README.md` — the full guide
- `AGENTS.md` — agent conventions and constraints
- `progressive-disclosure-standard.md` — documentation standard
- `multi-repo-orchestration.md` — multi-repo coordination
