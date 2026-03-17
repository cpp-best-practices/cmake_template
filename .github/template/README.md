# %%myproject%%

[![ci](https://github.com/%%myorg%%/%%myproject%%/actions/workflows/ci.yml/badge.svg)](https://github.com/%%myorg%%/%%myproject%%/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/%%myorg%%/%%myproject%%/graph/badge.svg)](https://codecov.io/gh/%%myorg%%/%%myproject%%)
[![CodeQL](https://github.com/%%myorg%%/%%myproject%%/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/%%myorg%%/%%myproject%%/actions/workflows/codeql-analysis.yml)

## About %%myproject%%
%%description%%

### Developer mode

By default the project enables developer mode with:

 * Address Sanitizer and Undefined Behavior Sanitizer
 * Warnings as errors
 * clang-tidy and cppcheck static analysis
 * Conan 2.0 for dependency management
 * pre-commit hooks (clang-format, gitlint, trailing whitespace)

## WebAssembly Demo

Try the live WebAssembly demo:
- Main: [https://%%myorg%%.github.io/%%myproject%%/](https://%%myorg%%.github.io/%%myproject%%/)
- Develop: [https://%%myorg%%.github.io/%%myproject%%/develop/](https://%%myorg%%.github.io/%%myproject%%/develop/)

The default branch (`main` or `master`) deploys to the root, `develop` to `/develop/`, and tags to `/tagname/`.

## Getting Started

```sh
pipx install pre-commit
pre-commit install
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for commit message policy and developer workflow.

## More Details

 * [Dependency Setup](README_dependencies.md)
 * [Building Details](README_building.md)
 * [Containers](README_container.md)
