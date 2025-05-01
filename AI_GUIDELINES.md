# AI Agent Guidelines

This document provides guidance for AI agents working with this C++ project template. These guidelines are designed to be useful for any AI assistant, not specific to any particular system.

**Important**: AI agents should also review the `HUMAN_GUIDELINES.md` file, which contains:
- The project's purpose and philosophy
- Information about the strict static analysis approach
- Reference to C++23 Best Practices book by Jason Turner
- Additional guidelines that both humans and AIs should follow

AI agents should align their suggestions and implementations with the best practices and project philosophy outlined in that document.

## Project Overview

This is a C++ project template that enforces best practices through tooling. It is designed to help you quickly set up a new C++ project with:

- Modern CMake (3.21+) with C++23 support
- Comprehensive warning configurations
- Sanitizers (Address, Undefined Behavior)
- Static analysis (clang-tidy, cppcheck)
- Dependency management with CPM
- Testing framework support (unit, constexpr, fuzz)
- CI integration

## Project Structure

- `CMakeLists.txt` - Main CMake configuration file
- `ProjectOptions.cmake` - Project-wide CMake options
- `Dependencies.cmake` - External dependency management
- `/cmake` - CMake modules and utilities
- `/configured_files` - Templates for generated files
- `/include` - Public header files
- `/src` - Source code files
- `/test` - Test files
- `/fuzz_test` - Fuzzing test files

## Common Tasks

### 1. Adding a New Component

When adding a new component:

1. Check existing components for naming conventions and structure
2. Follow the established pattern for CMakeLists.txt configuration
3. Use the project's existing target structure and namespacing
4. Ensure new code follows the project's warning and style guidelines

### 2. Working with CMake

- Use modern CMake practices (target-based approach)
- Set properties at the target level, not globally when possible
- Use `myproject::` namespace for targets
- Follow the established pattern for adding libraries and executables

### 3. Managing Dependencies

- External dependencies should be added to `Dependencies.cmake`
- Use CPM for dependency management when possible
- Always specify versions for dependencies
- Consider vendoring small dependencies that don't change often

### 4. Testing

The project has three primary test targets, each with specific purposes:

1. **constexpr_tests**:
   - Tests are compiled as static assertions (`STATIC_REQUIRE`)
   - If the project compiles, we know the code passes these tests
   - Errors are detected at compile-time
   - Located in `/test/constexpr_tests.cpp`

2. **relaxed_constexpr_tests**:
   - Same tests as constexpr_tests but as runtime assertions
   - Compiled with `-DCATCH_CONFIG_RUNTIME_STATIC_REQUIRE`
   - When adding new tests, compile and run this target first
   - Allows for debugging test failures that would otherwise be compile errors
   - After tests pass in this target, they should pass in constexpr_tests

3. **tests**:
   - Contains tests that cannot be made constexpr
   - Uses runtime assertions (`REQUIRE`)
   - Use for tests involving I/O, runtime-only features, etc.
   - Located in `/test/tests.cpp`

**Workflow for Adding Tests:**
1. Start by adding tests to `relaxed_constexpr_tests` if they can be constexpr
2. Debug and fix any issues
3. Once passing, ensure they compile in `constexpr_tests`
4. For non-constexpr functionality, add tests to `tests.cpp`

The project also supports fuzz testing for code that handles external inputs, located in `/fuzz_test`.


* ALWAYS prefer test-driven development
* ALWAYS write tests for new code
* NEVER filter tests when running test binaries - you need to know if the feature broke other tests!

### 5. Code Coverage

The project supports code coverage reporting using gcovr. When working with this project:

1. **Enabling Coverage:**
   - Configure with `-D<project_name>_ENABLE_COVERAGE=ON`
   - Note: After template instantiation, the variable prefix will change from `myproject_` to your specific project name (e.g., `fizzbuzz_ENABLE_COVERAGE=ON`)

2. **Running Coverage:**
   - Build and run the tests
   - Use gcovr to generate reports: `gcovr -r . --config=gcovr.cfg`
   - The HTML report will be generated at `./out/coverage/index.html`
   - XML report (Cobertura format) at `out/cobertura.xml`

3. **Coverage Goals:**
   - Always work toward increasing coverage percentages
   - Focus on branch coverage in addition to line coverage
   - Use gcovr's branch coverage reporting (`--branch-coverage`) for detailed analysis
   - Prioritize covering error handling paths and edge cases

4. **Configuration:**
   - Coverage settings are in `gcovr.cfg`
   - Excludes test directories and dependencies
   - Focuses on your project's source and include directories

## Best Practices

### Following Project Standards

1. **Warnings**: Do not disable warnings. Fix the underlying issues instead.
2. **Sanitizers**: Do not disable sanitizers. Fix the detected problems.
3. **Static Analysis**: Address issues reported by clang-tidy and cppcheck.
4. **Code Complexity**: Keep cyclomatic complexity and function length within Lizard's limits.
5. **Modern C++**: Use modern C++ features instead of legacy approaches.
6. **Type Safety**: Prefer strong types over primitive types (e.g., create a `Velocity` type rather than using plain `int`).
7. **Compile-time Evaluation**: Mark functions as `constexpr` by default, especially in C++23 mode.
8. **Resource Management**: Follow the Rule of 0; avoid manual resource management.

### Missing Tools

This project is designed to fail configuration if required tools are missing. This is intentional and acts as a guardrail.

1. **NEVER disable tools**: If build configuration fails due to missing tools, do not suggest disabling the tools
2. **ALWAYS suggest installing missing tools**: Provide instructions for installing the required tools
3. **Example missing tool message**: If you see "clang-tidy requested but executable not found", recommend installing clang-tidy, not disabling it
4. **Common required tools**:
   - clang-tidy: C++ static analyzer
   - cppcheck: C++ static analyzer
   - lizard: Code complexity analyzer
   - ccache: Compilation cache tool
   - include-what-you-use: Header dependency analyzer
   - bloaty: Binary size analyzer (optional, disabled by default)

Remember, the project's guardrails exist for a reason. Help the user install and use the required tools rather than circumventing them.

### Code Conventions

1. Follow the existing code style for consistency
2. Use strong typing and avoid C-style casts
3. Prefer compile-time safety when possible
4. Make correct use of const-correctness
5. **Always recommend running clang-format** on modified files:
   ```bash
   clang-format -i path/to/changed/files/*.cpp path/to/changed/files/*.hpp
   ```
   - clang-format is the source of truth for formatting
   - This reduces friction in code reviews and CI pipeline failures
   - Let clang-format handle all style decisions rather than manual formatting

### Modern C++ Coding Guidelines

1. **Format Strings**: 
   - Use `std::format` and `std::print` instead of iostream or printf
   - NEVER use printf (this will not pass static analysis)
2. **Memory Management**: 
   - No raw `new`/`delete` operations
   - Prefer stack allocation, then std::vector/array
   - Use smart pointers if heap allocation is necessary
   - ALWAYS prefer unique_ptr over shared_ptr
3. **Algorithms over Loops**: 
   - Use standard algorithms and ranges instead of raw loops when possible
   - Use ranged-for with `auto` when algorithms aren't suitable
4. **Function Design**:
   - Mark functions that return values as `[[nodiscard]]`
   - Use concepts to constrain template parameters
   - Return by value for small objects, avoid returning raw pointers
5. **Container Selection**:
   - Use `std::array` when size is known at compile time
   - Default to `std::vector` for dynamic containers
   - Select other containers only when their specific properties are needed
6. **Control Flow**:
   - Make case statements return values, avoid default in switch statements
   - Use scoped enums instead of unscoped enums
   - Use `if constexpr` for compile-time conditions

### Building and Testing

1. Before making significant changes, ensure you can build the project
2. Run tests after making changes to verify functionality
3. Use the provided CMake presets for consistency
4. Ensure your changes pass in all build configurations
5. **Preferred build configuration**:
   - Always prefer a Debug build
   - Set `<project_name>_PACKAGING_MAINTAINER_MODE=OFF`
   - Enable coverage with `-D<project_name>_ENABLE_COVERAGE=ON`
   - Example: `cmake -DCMAKE_BUILD_TYPE=Debug -Dmyproject_PACKAGING_MAINTAINER_MODE=OFF -Dmyproject_ENABLE_COVERAGE=ON ..`
6. ALWAYS commit changes after significant change has been made AND tests pass

## Technical Implementation Details

### CMake Configuration

The project uses several CMake patterns:

- Interface libraries for options and warnings
- Conditional feature enabling based on compiler support
- Presets for different build configurations

### Complexity Analysis with Lizard

The project uses Lizard for code complexity analysis with the following thresholds:

- **Cyclomatic Complexity**: Functions should have CCN ≤ 15
- **Function Length**: Functions should be ≤ 100 lines
- **Parameter Count**: Functions should have ≤ 6 parameters
- **Copy-Paste Detection**: Detects duplicated code segments

When encountering functions that exceed these limits:
1. Consider splitting them into smaller, more focused functions
2. Extract complex logic into separate methods
3. Reduce nesting levels and simplify control flow
4. Use parameter objects for functions with many parameters
5. **For duplicated code**: Extract common functionality into shared functions or templates

To run the analysis manually:
```bash
# Run Lizard with warning output only
cmake --build build --target lizard

# Generate HTML report
cmake --build build --target lizard_html

# Generate XML report for CI integration
cmake --build build --target lizard_xml
```

### Compiler Warning Configuration

Each supported compiler (GCC, Clang, MSVC) has specific warning flags enabled:

- All reasonable warnings are enabled
- Sign conversions are checked
- Shadowing is detected
- Unused code is flagged

### Build Modes

The project typically supports these build modes:

- Debug: No optimization, full debug information
- Release: Optimized build with minimal debug information
- RelWithDebInfo: Optimized but with debug information

## Common Problems and Solutions

### Recommending Development Workflow

When helping users with code changes, suggest setting up a quick iteration workflow:

```bash
# Suggest this development setup for quick iteration
mkdir -p build && cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Debug -Dmyproject_PACKAGING_MAINTAINER_MODE=OFF -Dmyproject_ENABLE_COVERAGE=ON ..
ninja
```

For testing code changes, recommend focusing on the non-constexpr tests first:
```bash
# For running runtime tests after changes (not constexpr tests)
cd build
ninja tests relaxed_constexpr_tests
ctest -R "unittests|relaxed_constexpr" --output-on-failure
```

For checking test coverage:
```bash
# For generating coverage reports
cd build
ninja
ctest
gcovr -r .. --config=../gcovr.cfg
```

This workflow helps the user quickly test your suggestions and allows you, as an AI assistant, to get fast feedback on proposed changes. Using Ninja as the generator speeds up compilation significantly.

### Fixing Build Errors

1. **Warning as Errors**: The template treats warnings as errors. Fix the warning rather than disabling it.
2. **Sanitizer Errors**: Address issues found by sanitizers at their root cause.
3. **Static Analysis**: Address the issues reported by clang-tidy and cppcheck.

### Dependency Issues

1. Check `Dependencies.cmake` for how dependencies are configured
2. Ensure correct version compatibility
3. Use the project's dependency management system rather than adding ad-hoc include paths

### Cross-Platform Concerns

1. Use conditional compilation sparingly and only when necessary
2. Consider implications of your changes on all supported platforms
3. Use the provided abstractions for platform-specific code
