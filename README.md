# feedBack — org defaults & contributor docs

This repository holds feedBack's public contributor documentation, org-wide templates, reusable workflows, and ruleset scripts. Maintainer-only docs (release runbooks, pipeline internals, governance, roadmaps) live in the org-internal `.github-private` repository.

## Model summary

feedBack uses **trunk-based development**. `main` is always current and always the PR target. Short-lived `release/vX.Y.Z` branches exist only while a release stabilizes and receive cherry-picks from `main`; tags on them drive release builds.

`feedBack` (core) and `feedBack-desktop` follow the same version number and are tagged together on release day.

---

## Quick reference

| I want to… | Go to |
|---|---|
| Contribute (workflow, branch naming, commits, PR checklist) | [CONTRIBUTING.md](CONTRIBUTING.md) |
| Understand plugin tiers and governance | [docs/plugins.md](docs/plugins.md) |
| Apply rulesets / propagate templates (maintainers) | [scripts/README.md](scripts/README.md) |
| Release runbooks, pipeline internals (org members) | `.github-private` |

---

## Repos this applies to

| Repo | Role |
|---|---|
| `got-feedBack/feedBack` | Core — FastAPI server, plugin loader, Docker image |
| `got-feedBack/feedBack-desktop` | Desktop — Electron wrapper, native audio engine |
| `got-feedBack/feedBack-plugin-*` | Org plugins — bundled in desktop, lighter governance |
