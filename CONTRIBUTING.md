# Contributing

## Commit message policy

This project uses [Conventional Commits](https://www.conventionalcommits.org/) enforced by [gitlint](https://jorisroovers.com/gitlint/).

- Format: `type(scope?): subject` with allowed types `build`, `chore`, `ci`, `docs`, `feat`, `fix`, `perf`, `refactor`, `revert`, `style`, `test`.
- Subject: imperative mood, no trailing punctuation, max 72 characters.
- Body: required; add context for the change.
- Sign-offs: every commit must include `Signed-off-by: Full Name <email>` in the body (`git commit -s`); sign commits cryptographically when possible (`git commit -S -s`).

Example:

```
feat(network): Add TLS client certificate rotation

Implement automatic rotation of TLS client certificates before expiry.

Signed-off-by: Jane Doe <jane@example.com>
```

## Setting up pre-commit hooks

This repository uses [pre-commit](https://pre-commit.com/) to run formatting and linting checks automatically on each commit. Install and activate it:

```sh
pipx install pre-commit
pre-commit install
```

If you previously used the `.githooks/` directory, unset the custom hooks path:

```sh
git config --unset core.hooksPath
```
