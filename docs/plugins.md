# Plugin Tiers and Governance

feedBack distinguishes three plugin tiers with different integration levels and governance requirements.

---

## Tier overview

| Tier | Location | Ships via | Versioned with core |
|---|---|---|---|
| **Core plugins** (`bundled: true`) | `got-feedBack/feedBack/plugins/` | Docker image + desktop | Yes — tied to core release |
| **Org plugins** | `got-feedBack/feedBack-plugin-*` repos | Desktop only | No — independent cadence |
| **Community plugins** | Personal accounts | Desktop only | No — migration target |

---

## Core plugins

Core plugins have `"bundled": true` in their `plugin.json`. They live directly in the `got-feedBack/feedBack` repository under `plugins/` and are the source of truth for what ships in the Docker image.

**Governance:** full core contribution workflow applies.
- PR required, CI must pass, 1 approval required
- Issue-first for bugs and features (see [CONTRIBUTING.md](../CONTRIBUTING.md))
- Changes follow the core release cycle — a fix to a core plugin ships in the next tagged release

**CI checks that cover core plugins:**
- `tailwind-fresh` — Tailwind build covers `plugins/*/` in addition to `static/`
- `print() / traceback guard` — extended to `plugins/*/routes.py`
- `plugin manifest validation` — all `plugins/*/plugin.json` files validated for required fields

**When to make a plugin a core plugin:** when it provides functionality that every feedBack user should have (visualization, note detection, core editor tooling) and the plugin's development is tightly coupled to the core API. Moving a plugin into core is a deliberate decision — it increases the surface covered by core CI and ships the plugin to Docker users who may not want it.

---

## Org plugins

Org plugins live in their own repos under the `got-feedBack` GitHub org (`got-feedBack/feedBack-plugin-*`). The desktop build clones them at build time via `build-common.sh`.

**Governance:** lighter model. Plugin authors own their workflow.

**Required:**
- Branch protection on `main`: no force pushes, no direct pushes from outside the maintainer set
- Minimal CI must pass on every push to `main`:
  - `plugin.json` validation — required fields present, valid JSON, `id` matches directory name
  - `print()` guard on `routes.py` if the plugin has a backend
  - JS syntax check: `node --check screen.js`
- AGPL-compatible license (MIT, BSD, Apache-2.0)

**Not required:**
- A specific branching model
- PR-based workflow (single-maintainer repos may push directly to `main`)
- Conventional Commits or any particular commit style
- Issue-first policy

The full core contribution guidelines apply only when a plugin is integrated into the core repo.

**Reusable CI workflow:** 🚧 TODO — a shared `plugin-lint` reusable workflow does not currently exist in this repo. Until it does, plugin repos maintain their own lint CI; this section will document the shared snippet once the workflow lands.

---

## Community plugins (personal accounts)

Plugins on personal accounts are a transitional state. They are bundled in the desktop build while awaiting migration to the org.

**Reliability backstop:** for any bundled plugin on a personal account, a maintainer forks it into the org as `feedBack-plugin-<name>-bak`. This fork exists solely as a fallback if the original repo disappears or breaks. It is not actively maintained and is retired when the plugin transfers to the org.

**Current personal-account plugins bundled in desktop:**

> 🚧 TODO: the old status table was stale — most listed plugins (`find-more`, `invert-highway`, `themes`, `update-manager`, `song-preview`, `guitar-theory`, `transpose-chords`, `stem-mixer`, …) now exist as `feedBack-plugin-*` repos in the org. Rebuild this table from `build-common.sh`'s current clone list.

The migration process is documented in the org-internal `.github-private` repository (runbooks/plugin-migration.md).

---

## Plugin pinning in desktop releases

All desktop builds (nightly, RC, and release) currently clone plugins at **tip of their default branch** — there is no pinning mechanism.

> 🚧 TODO: decide whether release builds need reproducible plugin pins and document the mechanism here if one is introduced.
