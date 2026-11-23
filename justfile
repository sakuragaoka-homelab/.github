# Standards and shared defaults for sakuragaoka-homelab repositories.
# `just --list` shows every recipe. `just check` is this repository's gate.

default:
    @just --list

# Compare standards/core.md with the other four owner .github repositories.
core-drift:
    bun scripts/core-drift.ts

# Format the repository. The two verbatim standard files are ignored.
fmt:
    bun fmt

# Fail when anything is unformatted.
fmt-check:
    bun fmt --check

# Repository gate.
check: fmt-check
