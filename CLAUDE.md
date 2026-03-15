# AI-Assisted Development Template

See AGENTS.md for full conventions.

## Quick Reference

- **Plan before code:** `/plan <task>` creates a plan in `docs/plans/`
- **TDD:** `/tdd <task>` enforces the red-green-commit cycle
- **Review:** `/review` checks staged changes before committing
- **Docs:** `/docs` generates progressive disclosure documentation

## Commit Conventions

- lowercase start, no AI tool names, present tense
- hooks enforce this — run `./init.sh` if hooks aren't installed

## Key Files

- `README.md` — the full guide
- `AGENTS.md` — agent conventions and constraints
- `progressive-disclosure-standard.md` — documentation standard
- `multi-repo-orchestration.md` — multi-repo coordination
