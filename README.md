# Software Engineering Skills Collection (`swe-skills`)

A collection of specialized, cross-agent skills for software engineering, architecture analysis, refactoring, and code review.

---

## Available Skills

### 1. `code-architecture-review`
**Path:** [`skills/code-architecture-review/SKILL.md`](file:///Users/bill/src/swe-skills/skills/code-architecture-review/SKILL.md)

Conducts a multi-tiered architecture and code review of any codebase using graph-based structural analysis (Graphify/AST), maps major components, performs intra- and inter-module reviews, and generates a structured, prioritized improvement plan saved directly into the repository.

#### Key Features:
- **Interactive Graphify Integration**: Prompts the user for permission/preference to install and execute `graphify` or fallback to deep static AST inspection.
- **Topological & Component Mapping**: Maps boundaries across presentation, domain core, data access, and infrastructure layers with Mermaid diagrams.
- **Within-Component (Intra-Module) Review**: Evaluates Single Responsibility Principle (SRP), cohesion, type safety, and error-handling resilience.
- **Across-Component (Inter-Module) Review**: Evaluates coupling metrics, circular dependency risks, and leaky abstractions.
- **Comprehensive Improvement Plan**: Saves a version-controlled plan with 5 mandatory sections:
  1. Code Architecture & System Topology
  2. Code Module / Component Review
  3. Code Inter-Module Review
  4. Recommended Improvements (Prioritized Roadmap: P0/P1/P2/P3 with code refactoring snippets)
  5. Security Review Recommendations (Cross-referencing OWASP/CVE and suggesting automated security scans)

### 2. `release`
**Path:** [`skills/release/SKILL.md`](file:///Users/bill/src/swe-skills/skills/release/SKILL.md)

Automates the Semantic Versioning (SemVer 2.0.0) release workflow:
- **Intelligent SemVer Bump**: Inspects commit logs and diffs to automatically determine major, minor, or patch increments based on change significance.
- **Automated Changelog Generation**: Updates `CHANGELOG.md` following the Keep a Changelog format.
- **Annotated Git Tags**: Creates signed/annotated git tags (`git tag -a vX.Y.Z -m "..."`).
- **Safe Remote Push**: Automatically pushes commits and release tags to the remote repository (`git push && git push --tags`).
- **CLI Release Tool**: Includes [`skills/release/scripts/release.sh`](file:///Users/bill/src/swe-skills/skills/release/scripts/release.sh) with `--dry-run`, `--minor`, `--patch`, and `--major` options.

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

Use the built-in universal installer [`install.sh`](file:///Users/bill/src/swe-skills/install.sh):

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
