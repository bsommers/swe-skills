# Software Engineering Skills Collection (`swe-skills`)

A collection of specialized, cross-agent skills for software engineering, architecture analysis, refactoring, and code review.

---

## Master Router: `/swe`

The **`/swe`** skill serves as the central command router and dispatcher for the entire suite. You can use `/swe` with explicit subcommands or freeform intent:

```bash
/swe review [path]      # -> code-architecture-review (Graphify/AST review)
/swe pr [pr#|branch]    # -> pr-review (multi-lens PR and git diff review)
/swe refactor [task]    # -> refactor-execute (safe incremental refactoring)
/swe api [spec.yaml]    # -> api-contract-audit (OpenAPI/GraphQL schema drift)
/swe deps [opts]        # -> dependency-audit (CVE vulnerability and package audit)
/swe coverage [opts]    # -> test-coverage (multi-language coverage audit)
/swe release [bump]     # -> release (SemVer bump, CHANGELOG, tag, push)
/swe issues [plan.md]   # -> github-issues-script (batch GitHub issues)
/swe install [opts]     # -> runs universal installer (asks first)
/swe help               # -> displays the routing table
```

Aliases: `arch`, `architecture` (review); `diff`, `review-pr` (pr); `execute` (refactor); `schema`, `openapi`, `contract` (api); `dependencies`, `security`, `cve` (deps); `cov` (coverage); `tag`, `semver` (release); `tickets` (issues). Anything else is treated as freeform intent, and an ambiguous request shows the menu. `/swe release` and `/swe install` always ask before pushing or installing.

---

## Available Skills

### 1. `swe` (Master Router)
**Path:** [`skills/swe/SKILL.md`](skills/swe/SKILL.md)

Entry point for the SWE Skills suite. Dispatches subcommands, and freeform requests that fit exactly one skill, to that skill by name.

### 2. `code-architecture-review`
**Path:** [`skills/code-architecture-review/SKILL.md`](skills/code-architecture-review/SKILL.md)

Conducts a multi-tiered architecture and code review of any codebase using graph-based structural analysis (Graphify/AST), maps major components, performs intra- and inter-module reviews, and generates a structured, prioritized improvement plan saved directly into the repository.

### 3. `pr-review`
**Path:** [`skills/pr-review/SKILL.md`](skills/pr-review/SKILL.md)

Comprehensive automated pull request and git diff review skill:
- **Multi-Lens Code Audit**: Evaluates logic/correctness, architectural boundaries, breaking API changes, error handling/silent failures, test coverage, and security.
- **Structured Review Output**: Produces formatted PR reviews with blocking findings, non-blocking suggestions, and concrete code transformations.
- **GitHub CLI Integration**: Submits reviews directly via `gh pr review` (`--approve`, `--request-changes`, `--comment`).

### 4. `refactor-execute`
**Path:** [`skills/refactor-execute/SKILL.md`](skills/refactor-execute/SKILL.md)

Safely executes complex architectural refactoring plans (e.g. from `ARCHITECTURE_REVIEW.md` Phase P0/P1) step-by-step:
- **Invariant Safety Loop**: Enforces green baseline tests before touching code, breaks transformations into atomic micro-steps, and runs tests after each step.
- **Martin Fowler Recipes**: Applies Dependency Inversion, Strategy patterns, Method/Class Extraction, and Branch by Abstraction.
- **Atomic Commits & Logging**: Creates atomic conventional commits and tracks progress in `docs/REFACTOR_LOG.md`.

### 5. `api-contract-audit`
**Path:** [`skills/api-contract-audit/SKILL.md`](skills/api-contract-audit/SKILL.md)

Audits API contracts (OpenAPI/Swagger, GraphQL, Protobuf, DTOs) against backend route implementations:
- **Schema Drift Detection**: Flags fields declared in specifications that are missing, renamed, or mismatching in backend controllers.
- **Undocumented Properties & Endpoints**: Detects unmapped endpoints and data leaking past boundary DTOs.
- **Breaking Changes & Nullability**: Identifies breaking signature changes and nullability mismatches before shipping to clients.

### 6. `dependency-audit`
**Path:** [`skills/dependency-audit/SKILL.md`](skills/dependency-audit/SKILL.md)

Multi-ecosystem package security and dependency auditor across Node.js/TS, Python, Rust, Go, Java, and Ruby:
- **CVE Vulnerability Scanning**: Integrates native tools (`npm audit`, `pip-audit`, `cargo audit`, `govulncheck`, `osv-scanner`) to classify CVSS risk.
- **Outdated & Abandoned Packages**: Identifies major version lag, abandoned libraries, and excessive dependencies.
- **License Compliance Guardrails**: Audits permissive vs. high-risk copyleft licenses (GPL/AGPL).

### 7. `test-coverage`
**Path:** [`skills/test-coverage/SKILL.md`](skills/test-coverage/SKILL.md)

Audits a repository's test suite and produces real coverage analysis — not just "tests pass." Detects the language/framework, runs the appropriate coverage tool, and generates a prioritized (P0 critical-path / P1 core-logic / P2 edge-case) gap-closing plan saved into the repo.

### 8. `release`
**Path:** [`skills/release/SKILL.md`](skills/release/SKILL.md)

Automates the Semantic Versioning (SemVer 2.0.0) release workflow:
- **Intelligent SemVer Bump**: Inspects commit logs and diffs to automatically determine major, minor, or patch increments based on change significance.
- **Automated Changelog Generation**: Updates `CHANGELOG.md` following the Keep a Changelog format.
- **Annotated Git Tags**: Creates signed/annotated git tags (`git tag -a vX.Y.Z -m "..."`).
- **Safe Remote Push**: Automatically pushes commits and release tags to the remote repository (`git push && git push --tags`).
- **CLI Release Tool**: Includes [`skills/release/scripts/release.sh`](skills/release/scripts/release.sh) with `--dry-run`, `--minor`, `--patch`, and `--major` options.

### 9. `github-issues-script`
**Path:** [`skills/github-issues-script/SKILL.md`](skills/github-issues-script/SKILL.md)

Prepares and converts code review findings, architectural debt, or task backlogs into a structured, reviewable batch script (`scripts/create_issues.sh`) for GitHub:
- **Best Practice Issue Anatomy**: Formats every issue with Summary, Exact File Coordinates (`file#L12-L34`), Impact/Risk analysis, Recommended Remediation (with Before/After code snippets), and References.
- **Human Reviewable & Safe**: Outputs a standalone script supporting `--dry-run`, per-issue interactive confirmation, and custom `--repo` targeting.
- **Robust Shell Quoting**: Employs EOF heredocs to prevent escaping issues with markdown code blocks and backticks.

---

## Multi-Agent Compatibility Guide

This skill is designed to work across all AI coding assistants:

| Agent / Tool | Installation & Activation |
| :--- | :--- |
| **Antigravity (`agy`)** | Symlink or copy to `~/.gemini/config/skills/code-architecture-review` or `.agents/skills/code-architecture-review`. Uses native file tools, subagents, and artifact generation. |
| **Claude Code** | Symlink or copy to `~/.claude/skills/code-architecture-review` or project `.claude/skills/`. Invoke via `/code-architecture-review`. |
| **Cursor** | Copy or reference in `.cursor/rules/` or `.cursorrules`. Reference `@docs/ARCHITECTURE_REVIEW.md` in Cursor Composer. |
| **Windsurf / Trae / Hermes / CLI Agents** | Place in repository root `.agent/` or reference `SKILL.md` directly. |

---

## Quick Installation via Installer Script

Use the built-in universal installer [`install.sh`](install.sh):

```bash
# 1. Interactive wizard (prompts for skills, agents, scope, and mode):
./install.sh

# 2. Install all skills globally for all supported agents (agy, claude, cursor):
./install.sh --scope global --agents all

# 3. Install locally into a specific target project:
./install.sh --scope local --agents all --target /path/to/my-project

# 4. Install specific skill for Claude Code and Antigravity only:
./install.sh --skills code-architecture-review --agents agy,claude --scope global

# 5. List available skills:
./install.sh --list

# 6. Uninstall:
./install.sh --uninstall --agents all --scope global
```

### Supported Installer Flags:
| Flag | Description | Options |
| :--- | :--- | :--- |
| `-s, --scope` | Installation scope | `global`, `local`, `both` |
| `-a, --agents` | Target agents | `agy`, `claude`, `cursor`, `all` (comma-separated) |
| `-k, --skills` | Specific skills to install | `<skill-name>`, `all` |
| `-t, --target` | Local destination repository | Defaults to current working directory |
| `-m, --mode` | Link or copy mode | `symlink` (default, auto-syncs edits), `copy` |
| `-u, --uninstall`| Remove installed skills | Boolean flag |
| `-l, --list` | List all available skills | Displays name and descriptions |
