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

## Quick Installation to Agent Configs

```bash
# For Antigravity (global):
mkdir -p ~/.gemini/config/skills
cp -r skills/code-architecture-review ~/.gemini/config/skills/

# For Claude Code (global):
mkdir -p ~/.claude/skills
cp -r skills/code-architecture-review ~/.claude/skills/

# For Project-local (.agents):
mkdir -p .agents/skills
cp -r skills/code-architecture-review .agents/skills/
```
