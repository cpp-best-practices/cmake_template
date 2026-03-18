# CI Known Issues

Tracked issues with links to GitHub issues for follow-up.

## Resolved

- **clang-tidy + Conan**: Fixed by removing `-p` flag from
  `StaticAnalyzers.cmake`. clang-tidy works on all compilers.
- **macOS GCC ABI mismatch**: Fixed by pre-installing Conan deps
  with a GCC-specific `libstdc++11` profile.
- **CodeQL missing Conan**: Fixed by adding `pip install conan lizard`
  and disabling Bloaty/IWYU in the CodeQL workflow.
- **codecov**: Set to `fail_ci_if_error: true`. Derived repos must
  configure their own `CODECOV_TOKEN` repository secret from
  [codecov.io](https://codecov.io).
- **Intel ICX coverage** ([#6](https://github.com/VersatusHPC/cmake_template/issues/6)):
  Resolved by moving Linux CI to UBI 10 containers. The Intel
  container includes `llvm-cov` from oneAPI. Use `llvm-cov gcov`
  as the gcov executable for ICX builds.
- **IWYU / Bloaty in CI**: Previously disabled because `ubuntu-latest`
  runners lacked these tools. Now pre-installed in the UBI 10 CI
  container and enabled for all Linux jobs.

## Open

- **WASM + Emscripten threading** ([#4](https://github.com/VersatusHPC/cmake_template/issues/4)):
  spdlog built by Conan without atomics/bulk-memory, but the project
  uses Emscripten pthreads. Emscripten pinned to 3.1.74 (Conan
  doesn't support emcc 23+).
- **macOS GCC coverage** ([#5](https://github.com/VersatusHPC/cmake_template/issues/5)):
  Apple ARM linker can't find libgcov. Tests pass, coverage skipped.
