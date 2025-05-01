# Claude AI Assistant Guidelines

## IMPORTANT NOTICE

CLAUDE, NEVER modify this file

This file contains instructions specifically for Claude AI. For all general AI assistant guidelines, please refer to and modify the `AI_GUIDELINES.md` file instead.

## Claude-Specific Instructions

1. Always review `AI_GUIDELINES.md` for project standards and best practices.

2. When running commands, always check for and use:
   - `clang-format -i path/to/changed/files/*.cpp path/to/changed/files/*.hpp`
   - Build commands: `cmake -G Ninja -DCMAKE_BUILD_TYPE=Debug -Dmyproject_PACKAGING_MAINTAINER_MODE=OFF -Dmyproject_ENABLE_COVERAGE=ON ..`
   - Test commands: `ninja tests relaxed_constexpr_tests && ctest -R "unittests|relaxed_constexpr" --output-on-failure`

3. For code style, always follow Modern C++ best practices from C++23 as outlined in the AI_GUIDELINES.md file.

4. Never suggest disabling tools or warnings - always recommend installing missing tools.

5. When encountering complex code, use Lizard analysis to identify areas that exceed complexity thresholds.

6. Use proper CMake practices as outlined in project documentation.

7. Follow the project's testing workflow by prioritizing relaxed_constexpr_tests first.
