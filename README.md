# .github

Standards and shared defaults for sakuragaoka-homelab repositories.

## Standards

- [standards/core.md](standards/core.md) — the shared core, identical in the five owner
  `.github` repositories.
- [standards/owner.md](standards/owner.md) — this owner's rules, plan limits, required checks and
  backlog.

## Shared Git hooks

- [hooks/core.yml](hooks/core.yml) — the Lefthook jobs every repository loads. It is a verbatim
  copy of the shared core config; never edit it here alone.
- [hooks/owner.yml](hooks/owner.yml) — this owner's extra jobs. The job names are `owner-*`.

Repositories load both files through `remotes` at the annotated tag `hooks-v2`, for example
`git_url: https://github.com/sakuragaoka-homelab/.github`, `ref: hooks-v2`,
`configs: [hooks/core.yml, hooks/owner.yml]`. The repository is public, so CI can fetch the tag
without a token. Move the tag only in a pull request that also updates every consumer.

`just check` verifies formatting. `just core-drift` compares the five copies of the core.
