# CI Known Issues

This document tracks CI limitations and their resolutions. Most issues
stemmed from the migration from CPM/FetchContent to Conan 2.0.

## clang-tidy and Conan include paths (RESOLVED)

**Status:** Fixed by removing the `-p` flag from `StaticAnalyzers.cmake`.

**Root cause:** The `-p` flag in `CMAKE_CXX_CLANG_TIDY` options told CMake
to have clang-tidy use `compile_commands.json` instead of passing the full
compile command directly. This broke include resolution for Conan packages
whose headers live in external `-isystem` paths (`~/.conan2/p/...`). Without
`-p`, CMake appends `-- <full compile command>` to clang-tidy, which includes
all `-isystem` paths and works reliably with Conan.

## macOS + GCC Conan ABI (RESOLVED)

**Status:** Fixed by overriding the Conan profile for macOS GCC in CI.

**Root cause:** Conan's default macOS profile detects Apple Clang and sets
`compiler.libcxx=libc++`. When building with GCC 14 (which uses `libstdc++`),
this causes ABI mismatches at link time. Fixed by creating a GCC-specific
Conan profile with `compiler=gcc` and `compiler.libcxx=libstdc++11`.

## codecov fail_ci_if_error (RESOLVED)

**Status:** Set to `true`. Requires `CODECOV_TOKEN` repository secret.

**Setup:** Add `CODECOV_TOKEN` to the repository secrets at
`Settings > Secrets and variables > Actions`. The token is obtained from
[codecov.io](https://codecov.io) after linking the repository. Derived repos
must configure their own token.

## GCC coverage on macOS ARM

**Status:** Skipped in `cmake/Tests.cmake` when `APPLE AND GNU`.

**Root cause:** GCC's `--coverage` flag links against `libgcov`, which
Apple's ARM linker can't find. Tests still run and pass; only coverage
instrumentation is skipped. GCC coverage works on Linux.

## Intel ICX coverage

**Status:** gcovr skipped when `matrix.compiler == intel` in `ci.yml`.

**Root cause:** Intel ICX produces coverage data in a format incompatible
with `gcov`. Tests still run and pass; only the coverage report is skipped.

**Possible fix:** Use `llvm-cov` from the oneAPI toolkit to process ICX
coverage data. Nice-to-have, not a blocker.
