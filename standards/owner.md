# sakuragaoka-homelab repository standard

This organization holds the documentation and configuration for one household's homelab: the
always-on server, the desktop, the laptop, the Home Assistant appliance, a relative's PC, and the
service catalog and agent tooling that connect them. The repositories are the recreation
documentation of record for machines that are difficult or expensive to rebuild.

[core.md](core.md) applies in full unless a **(profile)** rule is adjusted below. The rules below
may tighten the core. They do not loosen it.

## Scope

| Repository               | Visibility        | Kind                 | Notes                                                                                                                   |
| ------------------------ | ----------------- | -------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `.github`                | private           | standards            | This repository. Standards and shared defaults, no runtime code.                                                        |
| `homelab-services`       | private           | service catalog      | Compose projects, edge routing, adoption and status records.                                                            |
| `agent-tooling`          | private           | tooling              | Model hub and driver configuration; home of the canonical hook and recipe implementations that every repository copies. |
| `shamiko-ubuntu-server`  | private           | machine (server)     | Ubuntu server, NVIDIA GPU, media stack, off-site backup.                                                                |
| `ryouko-cachyos-laptop`  | private           | machine (laptop)     | CachyOS with KDE Plasma, hybrid graphics.                                                                               |
| `ugallu-omarchy-desktop` | private           | machine (desktop)    | Windows 11 to Omarchy migration, still in planning.                                                                     |
| `lilith-haos-pi5`        | private           | machine (appliance)  | Home Assistant OS on a Raspberry Pi 5.                                                                                  |
| `parents-windows-pc`     | private           | machine (desktop)    | Remotely administered Windows 10 PC. Name is a recorded exception to H5.                                                |
| `.github-private`        | private           | organization profile | Members-only profile. GitHub reserved name; not an H5 violation.                                                        |
| `machine-inventory`      | public            | inventory tooling    | Moved from another owner. Public exception under H3.                                                                    |
| `hermes-agent`           | public            | service and tooling  | Moved from another owner, renamed from `openclaw-homelab`. Public exception under H3.                                   |
| `homelab-config`         | private, archived | retired              | Superseded by `homelab-services` on 2026-10-29. No local clone.                                                         |

Every repository not in this table is out of scope until it is added here.

## Plan and protection

The organization is on **GitHub Free** with a single member (`deathpie`). Every repository is
private except the two public exceptions in H3.

| Capability                             | Private on Free            | Public                     |
| -------------------------------------- | -------------------------- | -------------------------- |
| Repository ruleset on `main`           | rejected (403)             | available                  |
| Native auto-merge                      | rejected                   | available                  |
| CodeQL default setup                   | unavailable                | available                  |
| Secret scanning and push protection    | unavailable                | available                  |
| Required signed commits                | local Git config only      | ruleset rule               |
| Dependabot alerts and security updates | available, must be enabled | available, must be enabled |

### Private repositories

C2.1 is enforced by three layers. None of them is allowed to be the only one.

1. **Lefthook, loading `hooks/core.yml` and `hooks/owner.yml`** from this repository through
   `remotes` at the `hooks-v3` tag and installed by `just hooks`. The `core-policy` job refuses any
   push whose remote ref is `refs/heads/main`, then scans the exact commits being pushed for
   private material and secrets. It is the only layer that runs before data reaches GitHub.
2. **`.github/workflows/guard-direct-push.yml`** runs after a push to `main`, asks the API whether
   every pushed commit belongs to a merged pull request, and fails plus files or updates one
   issue labelled `direct-push` when one does not.
3. **`.github/workflows/pr-automerge.yml`** merges a labelled pull request only when every other
   check on the exact head commit has passed. It never merges a `major-update` pull request.

The local hook is advisory: `--no-verify` and a different Git client bypass it. That is why the
guard exists. The guard is post-hoc: it cannot prevent the push, only record it.

Repository settings, applied through the API to every private repository:

| Setting                              | Value                                                      |
| ------------------------------------ | ---------------------------------------------------------- |
| `allow_merge_commit`                 | `false`                                                    |
| `allow_rebase_merge`                 | `false`                                                    |
| `allow_squash_merge`                 | `true`                                                     |
| `squash_merge_commit_title`          | `PR_TITLE`                                                 |
| `squash_merge_commit_message`        | `PR_BODY`                                                  |
| `delete_branch_on_merge`             | `true`                                                     |
| `allow_update_branch`                | `true`                                                     |
| `allow_auto_merge`                   | `false` (Free rejects enabling it on private repositories) |
| default workflow token               | read-only, cannot approve pull requests                    |
| actions must be pinned to a full SHA | `true`                                                     |

The guard:

- checks every commit in `before..after`, using the API only and never checking out the pushed
  code;
- retries the commit-to-pull-request lookup at least three times with backoff (2 s, 4 s, 8 s)
  before calling a commit unassociated, because GitHub's association is not always visible when
  the push event fires;
- fails closed when the lookup itself errors, after the retries;
- opens one `direct-push` issue per repository, comments on the open issue instead of opening
  another, and records the commit SHAs and the pusher;
- closes its own open issue with a short note when a later push verifies every previously flagged
  commit as part of a merged pull request.

`ALLOW_MAIN_PUSH=1` is the only push escape hatch. It is for an owner-approved recovery, never
for routine work, and the guard still records the push.

### Public repositories

`machine-inventory` and `hermes-agent` use the platform features that Free grants public
repositories, as core C2.1, C3.3 and C6.1 require:

- one ruleset named `protect-main`, target `refs/heads/main`, enforcement `active`, no bypass
  actors, containing: block deletion, block non-fast-forward, require signed commits, require a
  pull request with **0** approving reviews and squash as the only allowed merge method, dismiss
  stale reviews on push, require review-thread resolution, and require the status checks listed
  under [Required checks](#required-checks);
- native auto-merge enabled, squash only, delete the head branch on merge, update branch enabled;
- CodeQL **default setup** on; the existing `codeql.yml` is removed unless default setup cannot
  express the languages in the repository, which is recorded in `docs/exceptions.md`;
- secret scanning, push protection and validity checks on; Dependabot alerts and security
  updates on;
- an MIT `LICENSE`, since the code is public (core C1.6).

Jobs gated by another owner's name are not allowed. The two moved repositories currently carry
`if: github.repository_owner == 'simpsonm09-org' || github.repository_owner == 'simpsonm09-projects'`
on every job, so their checks run as skipped here. Removing that condition is part of adopting this
standard, not an optional cleanup.

## Profile choices

| Rule | Choice                                                                                                                                                                                                                                                                                                                                                           |
| ---- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| C1.5 | Issues are on in every repository. Wiki, Projects and Discussions are off.                                                                                                                                                                                                                                                                                       |
| C2.7 | Commits are signed with SSH. Every checkout sets `commit.gpgsign=true` locally and keeps the key outside the repository. Public rulesets enforce `required_signatures`; private repositories rely on the local setting plus review because Free offers no central enforcement. The signature is never bypassed, and a checkout that cannot sign does not commit. |

## Required checks

Every repository with code has one workflow file, `.github/workflows/checks.yml`, with
`name: Checks`. The name is a contract: `pr-automerge.yml` matches it in `workflow_run.workflows`
and the public rulesets require its job contexts. Renaming the workflow is a three-file change
(`checks.yml`, `pr-automerge.yml`, the ruleset) in one pull request.

The workflow exposes one job per recipe, run in parallel, each with `timeout-minutes` and a
pull-request `concurrency` group with `cancel-in-progress: true`:

| Context     | Recipe                                                             | Required                                    |
| ----------- | ------------------------------------------------------------------ | ------------------------------------------- |
| `fmt`       | `just fmt-check`                                                   | yes                                         |
| `lint`      | `just lint`                                                        | yes                                         |
| `typecheck` | `just typecheck`                                                   | yes when the repository contains TypeScript |
| `test`      | `just test`                                                        | yes                                         |
| `privacy`   | `just privacy-identity privacy privacy-staged whitespace gitleaks` | yes                                         |

`just check` runs the non-test recipes locally, in that order, and `just test` runs beside it; both
are required. CI calls the recipes individually so the contexts stay separate and parallel; it
does not call `just check` in one job.

The canonical recipes behind those contexts:

| Recipe                             | Behaviour                                                                                                              |
| ---------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `fmt` / `fmt-check`                | `bun fmt` / `bun fmt --check` over the repository. Python-only repositories add `ruff format --check` for `.py` files. |
| `lint`                             | `bun lint --no-script` (oxlint until stable Bun ships `bun lint`). Python-only repositories add `ruff check`.          |
| `typecheck`                        | `bun check`. Omitted only in a repository with no TypeScript, recorded in `docs/exceptions.md`.                        |
| `test`                             | `bun test`; Python additionally `python3 -I -m unittest discover -s tests`, behind the same recipe.                    |
| `privacy-identity`                 | Effective author and committer emails, including environment overrides, are the owner's GitHub no-reply address.       |
| `privacy`                          | Non-ignored worktree files.                                                                                            |
| `privacy-staged`                   | The exact staged blobs.                                                                                                |
| `privacy-range <rev> <base>`       | Commits in `<base>..<rev>`, including messages and diffs.                                                              |
| `privacy-commits <rev>`            | Every commit reachable from `<rev>`.                                                                                   |
| `whitespace` / `whitespace-staged` | `git diff --check` / `git diff --cached --check`.                                                                      |
| `gitleaks`                         | `gitleaks git --redact` over the pushed range or pull-request diff; never prints a finding value.                      |
| `hooks`                            | Runs `lefthook install` and asserts the `core-*` and `owner-*` jobs are loaded (below).                                |
| `agent-files`                      | Verifies `.agents/skills` and `.claude/skills` agree (C8.3).                                                           |
| `history`                          | Scans every published ref. Run before publication; CI runs it on `main` and weekly.                                    |
| `inspect`                          | Read-only local orientation; never mutates.                                                                            |

### Canonical hook implementation

The pre-push policy implementation is **one TypeScript file**, `scripts/git-hook.ts`, kept
byte-identical in every repository. It must not embed a directory depth: it locates the repository
with `git rev-parse --show-toplevel`, so the same bytes work in every checkout. `agent-tooling` is
the reference copy; a change lands there first and is copied in the same pull request series to
every other repository that carries hooks.

The workflow files `checks.yml`, `guard-direct-push.yml` and `pr-automerge.yml` are byte-identical
across repositories. The checks-workflow name is fixed (`Checks`), so there is no per-repository
edit left in the automerge copy.

The launchers are Lefthook, not shell scripts. Each repository's `lefthook.yml` loads
`hooks/core.yml` and `hooks/owner.yml` from this repository through `remotes` at the annotated tag
`hooks-v3`, and `just hooks` installs them (C7.8). The `core-policy` job calls
`just hook-pre-push`, which runs `bun scripts/git-hook.ts pre-push` with the pushed ref lines on
standard input. The `hook-*` recipes stay `[private]`.

The C7.10 `core-*` jobs in `hooks/core.yml` cover formatting, lint, secrets, forbidden files,
workflow and shell checks; this owner's `owner-privacy-identity` and `owner-privacy-staged` jobs
run beside them. Agents never skip a hook (C7.11).

`pre-push` reads the ref lines from standard input and, for each line
`<local ref> <local oid> <remote ref> <remote oid>`:

1. Skip the line when `<local oid>` is all zeros (a deletion).
2. Exit non-zero when `<remote ref>` is `refs/heads/main`, unless `ALLOW_MAIN_PUSH=1`.
3. Run `just privacy-identity` once.
4. Choose the range. When `<remote oid>` is all zeros (a new branch), use
   `git merge-base <local oid> refs/remotes/origin/main` as the base, and fall back to the whole
   reachable set when there is no merge base. Otherwise the range is `<remote oid>..<local oid>`.
5. Run `just privacy-range <local oid> <base-or-remote oid>` and the `gitleaks` range scan over the
   same commits. Stop at the first non-zero exit.

`just hooks` removes a local `core.hooksPath` only when it equals `.githooks`, refuses any other
value or a global one, runs `lefthook install`, and asserts that `lefthook dump` contains the
`core-*` and `owner-*` jobs. `lefthook-local.yml` is git-ignored.

C5.1 measurement, median of available pull-request runs on 2026-11-23: `agent-tooling` 13 s,
`lilith-haos-pi5` 14 s, `parents-windows-pc` 14 s, `ugallu-omarchy-desktop` 13 s,
`ryouko-cachyos-laptop` 21 s, `homelab-services` 66 s, `shamiko-ubuntu-server` 95 s. The last two
exceed 60 s and record exceptions until the fix in the backlog lands.

## Git hooks

Hooks run through Lefthook, pinned in `mise.toml` as `"aqua:evilmartians/lefthook"` (C7.8). Each
repository's `lefthook.yml` loads `hooks/core.yml` and `hooks/owner.yml` from this repository
through `remotes` at the annotated tag `hooks-v3`, and adds its own jobs under names that never
start with `core-` or `owner-`. Repositories migrate from the old `.githooks` launchers to Lefthook
per core C7.8; `scripts/git-hook.ts` stays the `hook-pre-push` implementation.

This owner's `hooks/owner.yml` jobs run before every commit:

| Job                      | Recipe                  | Behaviour                                                                                                                            |
| ------------------------ | ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `owner-privacy-identity` | `just privacy-identity` | Fails unless the effective author and committer email, including environment overrides, is the owner's GitHub no-reply address (H1). |
| `owner-privacy-staged`   | `just privacy-staged`   | Fails when a staged blob contains private material (H1).                                                                             |

`just hooks` removes a local `core.hooksPath` only when it equals `.githooks`, refuses any other
value or a global one, runs `lefthook install`, and then asserts that `lefthook dump` contains the
`core-*` and `owner-*` jobs, because a failed remote fetch only warns. `lefthook-local.yml` is
git-ignored, and agents never skip hooks: no `LEFTHOOK=0`, no `--no-verify` (C7.11).

## Owner rules

### H1. Privacy first

Content is written as if the repository were public, even while the remote is private. Never
commit credentials, private keys, tokens, pairing codes, personal names or emails, real usernames
or hostnames, assigned IP addresses, tailnet names, MAC addresses, serial numbers, filesystem
identifiers, personal home paths, raw logs, transcripts, screenshots, browser captures, or Home
Assistant backup archives. The remote name is metadata, not permission to repeat identifying
details.

- Use role-based placeholders: `<PI_LAN_IP>`, `<TAILNET_NAME>`, `$HOME`, `<SERVER_LAN_IP>`.
- Real inventories, rendered configuration, recovery keys, downloaded images and evidence live
  outside Git, normally under `$HOME/.local/state/home-infra`. That directory is private in full.
- `.gitignore` does not remove tracked data or sanitize history. Ignore rules are fallback
  exclusions, not approved locations. `git add -f` is forbidden.
- The Git identity is the GitHub no-reply address
  `10750179+deathpie@users.noreply.github.com` for author and committer, set repository-locally.
  GitHub's own web-flow committer is allowed on web merges. Never change global Git identity as a
  side effect of a repository command.
- The account usernames `deathpie` and `simpsonm09` are public by owner decision and may appear as
  plain words. Their emails, tokens, keys, addresses, home paths and tailnet hostnames remain
  private.
- Scanners report categories, never matched values, and reject binary content. `just check` and the
  `pre-commit` hook include `privacy-identity`. Run `just history` after committing and before
  publication.
- Commit messages are content: no personal email, transcript or `Co-Authored-By` trailer.
- If a credential enters Git, stop publication, revoke or rotate it, then deliberately rewrite
  history. Deleting the latest copy is not remediation.

### H2. One enforcement implementation

The three private-repository layers and the recipe set above are copied, not reinvented.
Divergent hooks are a defect even when each variant works. A repository may add a check; it may
not weaken, rename or omit a canonical recipe without a row in `docs/exceptions.md`. The two known
divergences (`agent-tooling`'s worktree-only pre-push and `ryouko-cachyos-laptop`'s `check` without
`privacy-identity`) are fixed by adopting the canonical implementation, not by documenting a local
variant.

### H3. Public exceptions

`machine-inventory` and `hermes-agent` are public and use the public enforcement in
[Plan and protection](#public-repositories). They follow the same privacy rules as every other
repository, because a public repository has no second chance. They must not reference another
owner's reusable workflows, and no job may be gated on another organization's name. While
`hermes-agent` is being rewritten, only its owner-directed rewrite may change it; the standard is
applied when that rewrite lands.

### H4. Mutation safety

Every helper defaults to read-only or preflight. A recipe that can change a live machine prints a
plan, takes a `confirmation` argument, and proceeds only when the value matches an exact word from
the host runbook:

| Word                 | Used for                                         |
| -------------------- | ------------------------------------------------ |
| `APPLY`              | Applying a reviewed file or configuration change |
| `ADOPT`              | Bringing an existing service under the catalog   |
| `INSTALL:<target>`   | Installing a package or agent on a host          |
| `ROLLBACK:<asset>`   | Restoring a previous state                       |
| `PRUNE:<object>`     | Deleting recoverable data                        |
| `RUN-BACKUP:<tier>`  | Starting a backup run                            |
| `permanent-approved` | Irreversible erasure                             |

Rules: never infer a word; an empty or near-miss value prints the plan and exits non-zero; no
recipe runs a mutating step as a side effect of a read-only one; a recipe that cannot roll back
says so in its plan. A merged document is not permission to execute it.

### H5. Names

Machine repositories are `<character>-<os>-<formfactor>`, lowercase, for example
`shamiko-ubuntu-server`, `ryouko-cachyos-laptop`, `lilith-haos-pi5`. Service and tooling
repositories are plain kebab nouns: `homelab-services`, `agent-tooling`, `machine-inventory`.
`.github` and `.github-private` use GitHub's reserved names.

`parents-windows-pc` is a recorded exception: it has no character name. It is renamed to
`<character>-windows-pc` in the backlog; the character is the owner's choice, and links in
`.github-private` and the READMEs move in the same pull request.

### H6. Languages

New code is TypeScript run by Bun. Python is being retired: do not add `.py` helpers, Python tests
or inline Python heredocs. Shell is a thin launcher only; PowerShell only for code that runs on a
Windows target. Existing Python is allowed under an exception row with a reason and a revisit date
of **2027-06-30**, until the repository is ported or the owner records a new date:

| Repository               | Python surface                 | Exception                           |
| ------------------------ | ------------------------------ | ----------------------------------- |
| `lilith-haos-pi5`        | 22 scripts and tests           | port to Bun behind the same recipes |
| `shamiko-ubuntu-server`  | 78 scripts, package and tests  | port in place, module by module     |
| `ugallu-omarchy-desktop` | 3 planning scripts             | port before the migration executes  |
| `homelab-services`       | 22 acceptance and test scripts | port behind `just test`             |
| `hermes-agent`           | Python project                 | owner decides during the rewrite    |

### H7. Machine repository skeleton

A machine repository has exactly this layout, unless a row in `docs/exceptions.md` says otherwise:

```text
AGENTS.md
.agents/skills/<name>/SKILL.md
.claude/skills/<name> -> ../../.agents/skills/<name>
justfile
mise.toml
.editorconfig
.gitattributes
lefthook.yml
.github/dependabot.yml
.github/workflows/{checks.yml,guard-direct-push.yml,pr-automerge.yml}
docs/{architecture,status,privacy,handoff,validation}.md
docs/exceptions.md          # only when an exception exists
scripts/
templates/
tests/
favicon.svg
.gitignore
```

`docs/coverage.md`, `docs/recreation.md` and a feature register are allowed additions where the
repository needs them.

`SKILLS.md` is dropped. `AGENTS.md` is the only entry point (C8.1), each skill describes itself in
frontmatter, and a copied index drifts. Skill links are per-skill symlinks as shown above, not one
directory symlink. `just agent-files` fails on a missing link, an extra link, a broken target, or a
skill that names a recipe that does not exist. A Windows checkout documents
`git config core.symlinks true` (Developer Mode) in `AGENTS.md`; a checkout where the links became
text files fails `just agent-files` rather than silently losing skills.

### H8. Toolchain pins

Every repository has `mise.toml` pinning the tools its recipes call. Organization-wide versions
are `just = "1.59.0"` and `bun = "1.4.5"`. A repository that needs another pinned tool (gitleaks,
ruff) adds it at one version used everywhere it appears. `.bun-version`, when present, must equal
the `mise.toml` value. CI installs tools through mise; it does not hardcode a Bun version in a
workflow.

Documentation-only repositories (`sakuragaoka-homelab/.github`, `.github-private`) carry the
reduced recipe set `default`, `fmt`, `fmt-check`, `check`, plus `core-drift` in the standards
repository. They record the C7.5 omission in `docs/exceptions.md`; they do not copy runtime
recipes they cannot run.

### H9. Checks workflow contract

One workflow file `checks.yml`, `name: Checks`, the five contexts above, and one copy of
`pr-automerge.yml` whose `workflow_run.workflows` value is exactly `["Checks"]`. A repository must
not carry a second pull-request workflow with overlapping required checks. The automerge gate
reads every check on the head commit, so a new check joins the gate without editing automerge; a
renamed check silently changes it. Renames are forbidden outside the three-file change in
[Required checks](#required-checks).

### H10. When `automerge` may be applied

The label means "safe to merge unattended", never "skip the checks". Apply it only when all of the
following hold:

- the pull request is Dependabot minor or patch, or its diff touches only documentation,
  dependency lock manifests, generated catalog output, or test fixtures;
- no image digest, service catalog definition, adoption register, machine `docs/status.md`,
  privacy rule or workflow `permissions:` block changes;
- `just check` and `just test` pass locally and every check on the exact head commit is green;
- the pull request does not carry `major-update`.

Dependabot major updates always carry `major-update` and are never scheduled for auto-merge. Every
other pull request is merged by the owner after review, or by an agent only with the owner's
explicit authorization for that pull request. The owner is the only person who applies
`automerge`.

### H11. Branch hygiene

Only the C2.5 branch types (`deps/` and `save/` included) are allowed. Parked work that will not merge is
`save/<slug>`; it is the only place for a handoff that must survive. `archive/` and `wip/` are not
branch types: existing `archive/*` and `wip/*` branches are deleted after their content is either
merged or recorded in `save/*` with a dated note. Names carry dates as `YYYY-MM-DD`.

### H12. Commits and pull requests

Pull-request titles are Conventional Commits (C2.4). Commit subjects are concise and imperative;
both the conventional form and the bare imperative form are accepted in history, but new commits
use the conventional form when the change has a clear type. Merge is squash with the pull-request
title and body (C2.3), so the pull-request body is the permanent record: it states what changed,
the verification run, and any rollback. No AI attribution, no `Generated with`, no
`Co-Authored-By` trailer.

## Superseded

This standard replaces the following documents. This pull request does not edit them; each row
names the follow-up.

| Document                                                        | What changes                                                                                                                                                                                                                                                                                                                                                                                                              |
| --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `agent-tooling/docs/git-workflow.md`                            | Replaced by this file. Merge commit becomes squash. The settings table changes: merge commits and rebase merges off, squash title/body from the pull request. The hook section keeps the escape hatch but adopts the canonical TS implementation. The guard section gains the association retry and false-positive closure. The onboarding checklist drops the per-repository checks-name edit because the name is fixed. |
| the copied `## Git workflow` section in seven `AGENTS.md` files | Replaced by a short link to this standard. The copies now contradict the merge method, so they are removed rather than re-synced.                                                                                                                                                                                                                                                                                         |
| `.agents/skills/open-pr/SKILL.md` (five byte-identical copies)  | Step 6 becomes `gh pr merge --squash --delete-branch`. The generated-with line is removed. The skill points at this standard for the automerge criterion and for authorization: a merge by an agent needs explicit owner authorization, and the owner is the only person who labels `automerge`.                                                                                                                          |
| `lilith-haos-pi5/docs/privacy.md`                               | Its rules become H1. The repository copy may stay as implementation detail for the Pi tooling, but it links to H1 and must not contradict it.                                                                                                                                                                                                                                                                             |
| the `.github-private/profile/README.md` "Conventions" paragraph | Replaced by a link to this standard once that profile is next edited.                                                                                                                                                                                                                                                                                                                                                     |
| the "follows the same conventions" sentences in machine READMEs | Replaced by a link to this standard, so the claim has one definition.                                                                                                                                                                                                                                                                                                                                                     |

Follow-ups, in order, none in this pull request:

1. `agent-tooling`: replace `tools/src/git-hook.ts` with the canonical path-independent dispatcher,
   add the missing `privacy-identity` and range scans, add `mise.toml`, rename its checks workflow.
2. Each private repository: copy the canonical hooks, recipes, `checks.yml` and the two workflows;
   remove `SKILLS.md`; add `.claude/skills` links; update its `AGENTS.md` Git section.
3. `homelab-services`: add the guard retry, close issue #104 as a false positive, and split the
   over-60-second job set.
4. Apply the repository settings table through the API; turn on Dependabot alerts and security
   updates; enable SHA pinning.
5. `machine-inventory` and `hermes-agent`: remove owner-gated jobs, adopt the ruleset and native
   auto-merge, enable secret scanning and push protection, switch CodeQL to default setup, add
   `mise.toml`, `favicon.svg` and the recipe set.
6. `.github-private`: add the guard and automerge workflows, the four labels, and the missing
   settings; land its next commit through a pull request.
7. Rename `parents-windows-pc` and update links.
8. Delete `archive/*` and `wip/*` branches after recording them as `save/*`.

## Conformance backlog

| Repository               | Gaps against core and this standard                                                                                                                                                                                                                                                                                                                                                                                                                                                           | Proposed fix                                                                                                                                                   | PR check median                    |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| `.github`                | Holds `hooks/core.yml` and `hooks/owner.yml`; still missing a local `lefthook.yml`, the Lefthook pin and a direct-push guard, and it has no `.github/dependabot.yml` or workflows (deliberate for a docs-only standard).                                                                                                                                                                                                                                                                      | Record C2.1 as an exception in `docs/exceptions.md`, or add `lefthook.yml`, the pin and the two workflows in a later pull request.                             | no runs                            |
| `agent-tooling`          | Pre-push scans the worktree only (H2, C2.1); pre-commit has no privacy or identity check; `check` omits `privacy-identity`; checks workflow named "Catalog checks" (H9); no `mise.toml` (C7.2, H8); no `.agents/skills` or `.claude/skills` despite being the tooling repository (C8.2); `.gitignore` covers only `private/`, `rendered/`, `node_modules/` (H1); auto-merge settings still allow merge and rebase.                                                                            | Adopt the canonical dispatcher and recipes, add mise and skills, apply the settings table.                                                                     | 13 s                               |
| `homelab-services`       | Open `direct-push` issue #104 is a false positive; the guard has no association retry (H2); `check` has no `fmt-check` and no TypeScript type check in the same recipe (H9); checks workflow named "Declarations and safeguards" (H9); C5.1 exceeded at 66 s; no `pre-commit` hook (H7); 22 Python scripts without exception rows (H6).                                                                                                                                                       | Fix the guard, close #104, split the heavy job, rename the workflow, add the hook and language rows.                                                           | 66 s                               |
| `shamiko-ubuntu-server`  | C5.1 exceeded at 95 s; seven `archive/*`/`wip/*` branches (H11); checks workflow named "Documentation and safeguards" and runs `history-ci` as a separate path (H9); no `mise.toml` (H8); 78 Python files (H6); local clone stale against `origin/main`.                                                                                                                                                                                                                                      | Parallelise the CI jobs and drop non-diff work from the required path; prune branches; port Python.                                                            | 95 s                               |
| `lilith-haos-pi5`        | Python-only recipes with no `mise.toml` (H6, H8); no `.claude/skills` links (C8.3); `SKILLS.md` index (H7); checks workflow named "Documentation and safeguards" (H9); `archive/*`/`wip/*` branches (H11); the validation/coverage document set differs from its siblings (H7).                                                                                                                                                                                                               | Adopt the canonical skeleton and recipes, then port the scripts.                                                                                               | 14 s                               |
| `ryouko-cachyos-laptop`  | `check` omits `privacy-identity` (H2); stale repository description says "Bazzite laptop to Omarchy migration" (C1.2); no `docs/validation.md` or `docs/coverage.md` (H7); `.bun-version` 1.4.4 versus the 1.4.5 pin (H8); one `archive/` branch (H11); checks workflow name (H9).                                                                                                                                                                                                            | Adopt the canonical recipe and skeleton; update description and Bun pin.                                                                                       | 21 s                               |
| `parents-windows-pc`     | Name is an H5 exception; stale `package.json` pins `bun@1.4.3` and `engines.bun >=1.4.3` (H8); no `docs/coverage.md` (H7); checks workflow name (H9); local clone stale.                                                                                                                                                                                                                                                                                                                      | Rename, pin Bun 1.4.5, adopt the skeleton.                                                                                                                     | 14 s                               |
| `ugallu-omarchy-desktop` | Windows/WSL clone rule becomes wrong after the Omarchy install (H7 AGENTS.md requirement); 3 Python scripts (H6); no `mise.toml` (H8); `SKILLS.md` (H7); checks workflow name (H9); planning-only repo has no acceptance evidence for the target layout.                                                                                                                                                                                                                                      | Rewrite the host rule with the migration, port scripts, adopt the skeleton.                                                                                    | 13 s                               |
| `.github-private`        | Every push went straight to `main` with no pull request (C2.1); no guard, automerge, hooks or dependabot (C3, H9); `delete_branch_on_merge=false`, `allow_update_branch=false`; only default labels, missing `automerge`, `major-update`, `direct-push`, `dependencies`; single initial commit predates this policy.                                                                                                                                                                          | Apply the private-repository settings, labels and workflows; next change arrives through a pull request.                                                       | no runs                            |
| `machine-inventory`      | Public repository with every CI job gated on `simpsonm09-org`/`simpsonm09-projects`, so checks are skipped (H3); secret scanning, push protection and validity checks off; CodeQL is an advanced workflow, not default setup (C6.1); ruleset has no required status checks; auto-merge off and merge/rebase methods still enabled; no `favicon.svg` (C1.3); no `mise.toml`; recipes are `lint`/`verify`/`render-check`, not the C7.5 set; depends on another owner's reusable workflows (H3). | Adopt the public exception: remove owner gates and foreign reusable workflows, set the ruleset and scan settings, add favicon, mise and the canonical recipes. | 130 s (historic; jobs now skipped) |
| `hermes-agent`           | Same owner-gate and public-scan gaps as `machine-inventory` (H3, C6.1), including auto-merge off and merge/rebase methods enabled; no `favicon.svg`; Python project without an H6 exception row; CI and `codeql.yml` inherited from the old organization; mid-rewrite by another agent.                                                                                                                                                                                                       | Land the standard with the rewrite; do not edit independently until that rewrite finishes.                                                                     | 86 s (historic; jobs now skipped)  |
| `homelab-config`         | Archived; description is `Retired 2026-10-29; superseded by homelab-services`, not the C9.1 `Retired (archived):` form; README retirement note not verified (no local clone).                                                                                                                                                                                                                                                                                                                 | Update the description prefix and README note at the next archive maintenance pass, or record an exception and leave it frozen.                                | n/a (archived)                     |

Cross-repository gaps not tied to one row: before this standard, no repository ran `gitleaks`
(C6.2), no repository declared the SHA-pinning setting `true` (C4.1), Dependabot alerts and
security updates were off in every private repository (C3.1), and no private repository had
`.editorconfig`, `.gitattributes` or `mise.toml` (C7.2, C7.7); the two public repositories have
the first two. These are fixed by the follow-up sequence above, repository by repository.
