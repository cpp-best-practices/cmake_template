# Design Choices

This template starts a C++ project with safe, modern defaults. Each choice
below explains *why*, so you can keep it, swap it, or turn it off.

## Goals

1. Catch bugs at compile time, not in production.
2. Stay portable across GCC, Clang, MSVC, and Emscripten.
3. Work the same way as a top-level project or as a subdirectory dependency.

## Layout

| File | Role |
| --- | --- |
| `CMakeLists.txt` | Top-level wiring. |
| `ProjectOptions.cmake` | All `myproject_*` options and setup macros. |
| `Dependencies.cmake` | CPM package fetch, gated by `if(NOT TARGET ...)`. |
| `cmake/*.cmake` | One concern per file (warnings, sanitizers, hardening, ...). |

`PROJECT_IS_TOP_LEVEL` flips defaults: strict when you own the build, quiet
when you are a dependency.

## C++ standard

C++23, set only if a parent project has not chosen one. `CMAKE_CXX_EXTENSIONS`
is off so the standard flag is `-std=c++23`, not `-std=gnu++23`. This avoids
`-Wpedantic` conflicts with precompiled headers.

## Warnings

`cmake/CompilerWarnings.cmake` enables a curated set per compiler — `/W4`
plus extras on MSVC, and `-Wall -Wextra -Wshadow -Wconversion -Wpedantic ...`
on GCC/Clang. Top-level builds add `-Werror` / `/WX`. Source:
[cppbestpractices](https://github.com/lefticus/cppbestpractices/blob/master/02-Use_the_Tools_Available.md).

## Sanitizers

ASan and UBSan are on by default for top-level GCC/Clang builds when a link
probe shows them working. TSan, LSan, and MSan are off — they conflict with
each other and MSan needs an instrumented standard library. Emscripten and
MSVC skip the sanitizer pass.

## Hardening

`cmake/Hardening.cmake` adds `_FORTIFY_SOURCE=3` (release builds),
`_GLIBCXX_ASSERTIONS`, `-fstack-protector-strong`, `-fcf-protection`, and
`-fstack-clash-protection` when supported. MSVC gets `/sdl /DYNAMICBASE
/guard:cf /NXCOMPAT /CETCOMPAT`. When no full sanitizer is active, the UBSan
minimal runtime is layered on top.

## Static analysis

clang-tidy and cppcheck run as part of the build, on by default at top level.
They are separate options because one tool may not be installed in every
environment.

## Link-time optimization

IPO/LTO is on by default at top level. It is gated through
`check_ipo_supported` so unsupported toolchains skip it.

## Dependencies

[CPM](https://github.com/cpm-cmake/CPM.cmake) fetches sources at configure
time. Each package is gated by `if(NOT TARGET ...)`, so a parent project can
supply its own version. `SYSTEM YES` silences warnings from third-party
headers. Default set: fmt, spdlog, Catch2, CLI11, FTXUI, lefticus/tools.

## Testing

* `test/tests.cpp` — Catch2 unit tests.
* `test/constexpr_tests.cpp` — the same checks at compile time, so bugs
  become build errors.
* `fuzz_test/` — libFuzzer harness, auto-enabled when ASan/TSan/UBSan and
  libFuzzer are all available.

## Targets and packaging

`myproject_options` and `myproject_warnings` are `INTERFACE` libraries that
hold flags. Real targets link `myproject_options` and call
`myproject_enable_warnings(target)` to link the warning flags and set the
target's `COMPILE_WARNING_AS_ERROR` property from `myproject_WARNINGS_AS_ERRORS`,
without changing global state. `CPack` package names embed compiler, version,
and short Git SHA, so a binary maps to one build.

## Defaults for daily use

The default build type is `RelWithDebInfo` — debuggable and fast.
`compile_commands.json` is always exported, for editors and clang tooling.

## Changing the defaults

Every knob is a CMake option named `myproject_ENABLE_<feature>`. Flip it on
the configure line, for example:

    cmake -B build -S . -Dmyproject_ENABLE_CLANG_TIDY=OFF

The `myproject_` prefix is the placeholder the rename workflow replaces, so
renaming the project is one search-and-replace.
