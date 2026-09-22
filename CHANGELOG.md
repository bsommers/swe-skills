# Changelog

All notable changes to this project will be documented in this file.
## [v0.3.0] - 2026-09-22

### Added
- add pr-review, refactor-execute, api-contract-audit, and dependency-audit skills



## [v0.2.0] - 2026-09-18

### Added
- add test-coverage skill: language/framework detection, coverage tool matrix, prioritized (P0/P1/P2) gap analysis beyond raw percentage, and a Shell Test-Quality Checklist for Bash/bats projects
- add `shell_function_reachability.sh`: deterministic, zero-dependency static coverage fallback for Bash projects, since kcov+bats-core instrumented coverage is empirically unreliable (documented in `references/BASH_COVERAGE_NOTES.md`)

## [v0.1.0] - 2026-09-18

### Added
- add release skill with automated semver bump and tagging
- add universal installer script for agy, claude code, and cursor
- add cross-agent code-architecture-review skill


## [v0.2.0] - 2026-09-21

### Added
- add /swe master skill router and dispatcher
- add github-issues-script skill for generating reviewable batch issue scripts
- add test-coverage skill with shell reachability fallback

### Fixed
- confirm before pushing a release

### Changed / Maintenance
- rewrite router as a single route table with gates


