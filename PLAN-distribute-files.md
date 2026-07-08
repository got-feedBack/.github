# Plan: Distribute a Directory of Files Across Org Repos

## Goal

A `workflow_dispatch`-only workflow in `got-feedback/.github` that copies files from `shared/` into every org repo including `.github` itself — pushes direct to `main`, no PRs.

## What exists today (recent changes to reconcile)

Since the first draft of this plan, two things landed in `.github`:

- **`.github/workflows/reusable-ci.yml`** — a reusable CI workflow that other repos call via `workflow_call`. It lives at `.github/workflows/` only to be referenceable by path from other repos. It should **not** be in `shared/` — it's not a file to copy, it's a service to call.
- **`.github/ISSUE_TEMPLATE/config.yml`** — redirects issue submitters to the central `feedback` repo. This **is** a candidate for `shared/` so every repo gets the same redirect.

## Proposed `shared/` contents

```text
shared/
├── .github/
│   └── ISSUE_TEMPLATE/
│       └── config.yml        ← redirect all issues to central feedback repo
├── CODE_OF_CONDUCT.md        ← org-wide code of conduct
├── CONTRIBUTING.md            ← org-wide contributing guide
└── LICENSE.md                 ← MIT license (if all repos share it)
```

Files that are **not** candidates for `shared/`:

| File/dir | Reason |
|----------|--------|
| `profile/` | Org profile page — only `.github` can serve it |
| `scripts/`, `runbooks/`, `docs/` | Org admin tooling — doesn't belong in every repo |
| `.github/workflows/reusable-ci.yml` | Called by reference, never copied |
| `.github/workflows/propagate-rulesets.yml` | Admin workflow, not useful in other repos |

### Reconciliation question — `docs/` files

The `.github` repo has `docs/branching.md`, `docs/pipeline.md`, `docs/guidelines.md`, `docs/plugins.md`, and `docs/github-setup.md`. These describe the org's development process. Every repo's contributors need this context. You have two options:

| Option | Pro | Con |
|--------|-----|-----|
| **A: Keep docs only in `.github`** | Single source of truth; everyone knows to go there | Contributors may not find them |
| **B: Put docs in `shared/` → auto-distribute** | Every repo has a local copy | Stale copies if a repo gets out of sync (auto-propagation fixes this, but only on manual dispatch); contributors might edit the local copy instead of the source |

I'd suggest Option A for now — `.github` is GitHub's well-known convention for this purpose. If contributors aren't finding the docs, you can always add them to `shared/` later.

## Pre-requisite: fix `propagate-files.sh` for `--destination .`

The script has a bug when `--destination .` is used (which is what we want: copy `shared/` into the repo root):

```bash
# Current (buggy) — rm -rf would delete the entire cloned checkout:
rm -rf "${TARGET:?}/$DEST"

# Fix — handle "." as a special case, copy items individually:
if [ "$DEST" = "." ]; then
  for item in "$ROOT/$SOURCE"/* "$ROOT/$SOURCE"/.[!.]*; do
    [ -e "$item" ] || continue
    cp -r "$item" "$TARGET/"
  done
elif [ -d "$ROOT/$SOURCE" ]; then
  rm -rf "${TARGET:?}/$DEST"
  cp -r "$ROOT/$SOURCE" "$TARGET/$DEST"
else
  cp "$ROOT/$SOURCE" "$TARGET/$DEST"
fi
```

This fix needs to land before the workflow runs.

## Workflow

`.github/workflows/distribute-shared.yml`:

```yaml
name: Distribute shared files

on:
  workflow_dispatch:
    inputs:
      repo_name:
        description: "Single repo to target (empty = all)"
        required: false

jobs:
  distribute:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - name: Checkout .github
        uses: actions/checkout@v4

      - name: Propagate shared/ to all org repos
        env:
          GH_TOKEN: ${{ secrets.PROPAGATION_TOKEN }}
          ORG: ${{ github.repository_owner }}
          REPO_NAME: ${{ github.event.inputs.repo_name }}
        run: |
          if [ -n "$REPO_NAME" ]; then
            bash scripts/propagate-files.sh \
              --source shared/ \
              --destination . \
              --repo "$REPO_NAME" \
              --message "Sync shared files from .github"
          else
            bash scripts/propagate-files.sh \
              --source shared/ \
              --destination . \
              --all \
              --message "Sync shared files from .github"
          fi
```

Key differences from the previous draft:

| Before | Now | Why |
|--------|-----|-----|
| `push` + `workflow_dispatch` | `workflow_dispatch` only | You want a manual gate |
| `--exclude .github` | no exclude | You want `.github` to receive its own shared files |
| `--exclude community-code-review` | not shown (add if desired) | Can be added per your preference |

## Execution order

1. Fix the `--destination .` bug in `scripts/propagate-files.sh`
2. Create `shared/` with the initial files (see proposed contents above)
3. Create `.github/workflows/distribute-shared.yml` with the workflow YAML
4. Test: run the workflow with `repo_name: community-code-review` (smallest target first)
5. Run with `repo_name: feedBack` (one real repo)
6. Run targeting all repos
7. Verify each target repo received the expected files

## Open question — Node 20 deprecation

The workflow YAML above uses `actions/checkout@v4` (current), which triggers a Node 20 deprecation warning. You can bump it to `v7` the same way we did in the other repos, or leave it as-is since it still works — just noisy.
