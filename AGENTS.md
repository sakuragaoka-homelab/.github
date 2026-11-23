# Agent entry point

This repository holds the repository standard for the `sakuragaoka-homelab` organization: the
rules every homelab, machine and tooling repository follows. It contains documentation only.

- [standards/core.md](standards/core.md) is byte-identical in the five owner `.github`
  repositories. Never edit it here alone.
- [standards/owner.md](standards/owner.md) adds this owner's rules and profile choices.
- [scripts/core-drift.ts](scripts/core-drift.ts) is also a verbatim copy.

## Commands

- `just --list` shows the recipes.
- `just check` runs the repository gate (format check).
- `just core-drift` compares `standards/core.md` with the other four owner repositories. It needs
  `gh` logged in as both `deathpie` and `simpsonm09`; run it before a standards change, not from
  CI.

## Rules

- A change to `standards/core.md` or `scripts/core-drift.ts` is copied byte-for-byte from the
  shared source. Do not reformat either file; `.prettierignore` excludes them.
- A change to `standards/core.md` is one pull request per owner, with the same content, or no
  change at all.
- Work on a branch and open a pull request. This organization squashes merges, so the pull
  request body is the permanent record. Never push to `main`.
- Do not add workflows or change GitHub settings from this repository.
