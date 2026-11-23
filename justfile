# Standards and shared defaults for sakuragaoka-homelab repositories.
# `just --list` shows every recipe. `just check` is this repository's gate.

default:
    @just --list

# Compare standards/core.md with the other four owner .github repositories.
core-drift:
    bun scripts/core-drift.ts

# Audit every repository of this owner against the core and owner standards.
# `just fleet-audit --timing` adds the C5.1 median pull request CI wall time.
fleet-audit *args:
    bun scripts/fleet-audit.ts {{args}}

# Format the repository. The two verbatim standard files are ignored.
fmt:
    bun fmt

# Fail when anything is unformatted.
fmt-check:
    bun fmt --check

# Repository gate.
check: fmt-check
