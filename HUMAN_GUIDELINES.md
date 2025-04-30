# Human Developer Guidelines

## Project Purpose

This project exists to provide a strong foundation for creating new C++ projects that follow industry best practices from the start. It incorporates:

1. **Modern C++ Standards**: Built for C++23 with backward compatibility considerations
2. **Rigorous Safety Checks**: Strict warnings, sanitizers, and static analysis tools
3. **Testing Infrastructure**: Unit, constexpr, and fuzz testing frameworks
4. **Build System**: Modern CMake approach with sensible defaults
5. **CI/CD Setup**: GitHub Actions workflows for testing and validation

## Philosophy Behind Strict Analysis Rules

The strict static analysis rules and warnings-as-errors approach are deliberate:

1. **Early Problem Detection**: Catching potential issues at compile time rather than runtime
2. **Consistent Code Quality**: Enforcing consistent practices across the codebase
3. **Reduced Technical Debt**: Preventing the accumulation of code smells and problematic patterns
4. **Learning Opportunity**: Helping developers learn better C++ practices through immediate feedback

## C++ Best Practices

This project is based on the guidelines from [C++23 Best Practices](https://leanpub.com/cpp23_best_practices/) by Jason Turner. When modifying the codebase, follow these guidelines. The book covers:

- Using modern C++ features effectively
- Writing safer, more maintainable code
- Leveraging tools for code quality
- Performance considerations
- Testing strategies

When making changes, refer to this resource to ensure your modifications align with the project's philosophy.

## Code Formatting

This project uses clang-format as the source of truth for code formatting:

1. **Always Run clang-format**: After making code changes, run the latest version of clang-format on all modified files
   ```bash
   clang-format -i path/to/changed/files/*.cpp path/to/changed/files/*.hpp
   ```

2. **Benefits of Consistent Formatting**:
   - Reduces friction in code reviews
   - Eliminates formatting debates
   - Ensures CI pipeline success
   - Maintains consistent codebase appearance
   - Helps focus reviews on substantive issues rather than style

3. **Integration Options**:
   - Configure your editor to run clang-format on save
   - Set up a pre-commit hook
   - Use a formatting check in CI (already configured in this project)

By letting clang-format be the final arbiter of code style, we reduce human and AI decision-making overhead on non-functional aspects of the code.