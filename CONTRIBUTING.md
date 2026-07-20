# Contributing to feedBack

Thanks for contributing! This guide covers the workflow for `got-feedBack/feedBack` (core) and `got-feedBack/feedBack-desktop`. For plugin-specific rules see [docs/plugins.md](docs/plugins.md).

feedBack uses **trunk-based development**: `main` is always current and always the PR target. Short-lived `release/vX.Y.Z` branches exist only while a release stabilizes — never open PRs against them; needed fixes are cherry-picked from `main` by maintainers.

## Workflow

1. **Branch from `main`, PR to `main`** — always.
2. Keep branches focused; avoid bundling unrelated changes in one PR.
3. Merge incomplete features behind a flag rather than parking long-lived branches — `main` must stay releasable.

## Branch naming

Format: `<type>/<issue-number>-short-description`

- `fix/412-audio-dropout-on-seek`
- `feature/388-lyrics-sync`
- `chore/bump-tailwind` (no issue number for mechanical changes)

Tip: GitHub's "Create a branch" button on an issue (Development panel) auto-names the branch and links the PR back.

## Issue policy

| Branch type | Issue required |
|---|---|
| `fix/*` | Yes — always. Bugs are reported and triaged before code. |
| `feature/*` | Yes for external contributors; maintainer's discretion for small additions. |
| `chore/`, `docs/`, `refactor/` | No. |

## Bug reports

Include: **version** (exact tag or `nightly.YYYYMMDD`), **platform** (Docker / Desktop Windows / macOS / Linux), **steps to reproduce**, **expected vs. actual behaviour**.

## Commit messages

[Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `perf:`, `test:`. Subject ≤ 72 chars; body only when the *why* isn't obvious from the diff.

```
feat(player): add stem balance controls to mixer popover
fix(highway): correct fret position for 7-string arrangements
```

## PR checklist

- [ ] Branches from and targets `main`
- [ ] CI passes (all required checks green)
- [ ] Linked to an issue (`fix/*`, and `feature/*` for external contributions)
- [ ] `CHANGELOG.md` `[Unreleased]` updated if the change is user-visible
- [ ] Incomplete/risky functionality is behind a flag
- [ ] Core only: `tailwind.min.css` rebuilt if new Tailwind classes were added (`bash scripts/build-tailwind.sh` — the `tailwind-fresh` check enforces this)

## What CI runs on your PR

- **Core:** pytest, JS plugin-API tests, Tailwind freshness check, `print()`/traceback guard, plugin manifest validation, feedpak-spec conformance, ESLint. A red `feedpak-spec` check on a manifest-key change means the key must go through the spec process in [`feedpak-spec`](https://github.com/got-feedBack/feedpak-spec) first.
- **Desktop:** TypeScript typecheck, npm audit, a 3-OS native-addon build + load smoke-test, and sandbox IPC tests (ASan/TSan) when sandbox paths are touched.

---

Maintainer docs (release runbooks, pipeline internals, governance) live in the org-internal `.github-private` repository.
