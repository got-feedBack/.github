# Branching Model

Slopsmith uses a release-centric model. `main` is always the last shipped stable release. All development for a given version happens on a dedicated `release/vX.Y.Z` branch.

---

## Structure

```
main                         ← last shipped stable release only
  └── release/v0.3.0         ← integration branch for the whole version
        └── feature/xyz      ← branches off release/v0.3.0, PR back to release/v0.3.0
        └── fix/abc          ← branches off release/v0.3.0, PR back to release/v0.3.0
        └── hotfix/crash     ← branches off release/v0.3.0, PR back to release/v0.3.0
```

## Branch purposes

| Branch | Purpose | Created from | Merges into |
|---|---|---|---|
| `main` | Last shipped stable release | — | — |
| `release/vX.Y.Z` | Integration branch for a version | `main` | `main` via PR when version ships |
| `feature/*` | New features | `release/vX.Y.Z` | `release/vX.Y.Z` via PR |
| `fix/*` | Bug fixes | `release/vX.Y.Z` | `release/vX.Y.Z` via PR |
| `hotfix/*` | Urgent fixes during alpha/beta/post-release | `release/vX.Y.Z` | `release/vX.Y.Z` via PR |

---

## Release lifecycle

1. Cut `release/v0.3.0` from `main` at the start of the v0.3.0 development cycle
2. All features and fixes for v0.3.0 are PRed against `release/v0.3.0`
3. Tag `v0.3.0-alpha.1` on `release/v0.3.0` to publish the first alpha
4. Continue fixes via PRs to `release/v0.3.0`; tag further alphas and betas as needed
5. Tag `v0.3.0` on `release/v0.3.0` for the final release
6. Merge `release/v0.3.0` into `main` via PR — the only merge `main` receives this cycle

---

## Versioning

Both `slopsmith` (core) and `slopsmith-desktop` follow the same version number. A `v0.3.0` release means both repos are tagged `v0.3.0` on the same day. Bug reports from Docker and Desktop users are directly comparable by version.

```
v0.3.0-nightly.20260608   ← scheduled nightly build from the active release branch
v0.3.0-alpha.1            ← early testing
v0.3.0-beta.1             ← feature-complete, stabilizing
v0.3.0                    ← final release
```

---

## Hotfixes for a shipped version

Branch `hotfix/my-fix` from the relevant `release/v0.3.0` branch, PR back to it, tag `v0.3.1`. If a `release/v0.4.0` branch already exists and the fix applies there too, open a second PR to that branch.

See [runbooks/hotfix.md](../runbooks/hotfix.md) for the step-by-step checklist.

---

## Concurrent version development

If work on v0.4.0 needs to start before v0.3.0 ships, cut `release/v0.4.0` from `main` (which is still at the last stable release). Clearly communicate which release branch is the target for each piece of work — this is the main coordination overhead of this model.

---

## Why this model

- `main` is always the last stable release — a clean, predictable reference for users and contributors
- No ambiguity about where to target PRs: if you're working on v0.3.0, you branch from `release/v0.3.0`
- No cherry-picks during stabilization — all fixes for a version are already on its release branch
- The final `release/*` → `main` merge is the complete, tested changeset for the version

**Trade-off:** `main` is stale during development. Contributors who clone `main` get the previous release, not current work. Direct them to the active `release/*` branch.
