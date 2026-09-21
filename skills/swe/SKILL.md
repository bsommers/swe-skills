---
name: swe
description: "Use when the user invokes /swe with a subcommand (review, coverage, release, issues, install, help) or asks what the swe-skills suite can do."
---

# `/swe` router

Dispatches `/swe <subcommand> [args]` to one skill in the suite. It holds no workflow of its own.

## Routes

| Subcommand | Skill | Purpose | Gate |
| :--- | :--- | :--- | :--- |
| `review`, `arch`, `architecture` | `code-architecture-review` | Graph-based code and architecture review with an improvement plan | none |
| `coverage`, `cov` | `test-coverage` | Measure real test coverage and plan gap closing | none |
| `release`, `tag`, `semver` | `release` | SemVer bump, CHANGELOG, tag, push | **confirm before any push** |
| `issues`, `tickets` | `github-issues-script` | Turn findings into a reviewable `gh issue create` script | none |
| `install` | installer | Run this suite's `install.sh` | **confirm before running** |
| `help`, `list`, no args | menu | Show this table and stop | none |

## Dispatch

1. Match the first word of the arguments against the Subcommand column. Matching is exact; anything else is freeform.
2. Invoke the target skill by name (the Skill tool in Claude Code) and forward the remaining arguments unchanged, e.g. `/swe release --dry-run` invokes `release` with `--dry-run`.
3. Freeform text: pick the one skill whose description fits the request. If two fit or none does, show the menu instead of guessing. A request that names two steps in order ("review, then file issues") runs them in that order.
4. `issues` with no plan path uses the newest review output (`docs/ARCHITECTURE_REVIEW.md` or `docs/IMPROVEMENT_PLAN.md`). If neither exists, say so and offer `/swe review`.

## Gates

- **`release`**: run the analysis and show the proposed version and notes. Ask before `git push`. If running `release.sh`, start with `--dry-run` and add `--yes` only after the user confirms the push. Never push on the strength of `/swe release` alone.
- **`install`**: the installer is in the suite's repo, not the current project. Resolve it from this skill's own directory: `realpath` of the skill directory, then `../../install.sh`. Confirm that file exists, show the resolved path and arguments, and ask before running. Never run a `./install.sh` from the working directory.

## Menu

Print the Subcommand and Purpose columns from Routes, with one example per line (`/swe review src/core`, `/swe release --minor`, `/swe issues docs/IMPROVEMENT_PLAN.md`).
