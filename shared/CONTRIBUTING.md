# Contributing

Thanks for wanting to contribute! This org uses a release-centric workflow.
Start here for the basics; each repo may have additional project-specific
guides.

## Getting started

1. Find the right repo — most issues belong in `got-feedback/feedback`.
   Plugin-specific issues go in the plugin's repo.
2. Read the org's development docs at `got-feedback/.github`:
   - [Branching model](https://github.com/got-feedback/.github/blob/main/docs/branching.md)
   - [CI/CD pipeline](https://github.com/got-feedback/.github/blob/main/docs/pipeline.md)
   - [Daily workflow and commit rules](https://github.com/got-feedback/.github/blob/main/docs/guidelines.md)
3. Check the target repo's own `CONTRIBUTING.md` for license terms, DCO
   requirements, and project-specific setup.

## Developer Certificate of Origin

We use the [Developer Certificate of Origin](https://developercertificate.org/)
(DCO) to track contribution provenance. Every commit must be signed off:

```bash
git commit -s -m "your commit message"
```

This appends a line like:

```text
Signed-off-by: Jane Developer <jane@example.com>
```

If you forget to sign off, amend the most recent commit with
`git commit --amend -s` and force-push to your PR branch.

## PR workflow

- Never push directly to `main`.
- Create a feature branch on your fork.
- Open a PR against the target repo's `main` branch.
- Keep commits scoped and well-described; short imperative subject line,
  blank line, then body explaining *why*.

## Questions

Open an issue or start a Discussion in the relevant repo if you're unsure
whether a contribution fits.
