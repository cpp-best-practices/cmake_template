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

Here are some relevant chapter titles from that book:

    5:Use AI Coding Assistants Judiciously
    7:Remember: C++ Is Not Object-Oriented (it's multi-paradigm)
    9:Know Your Standard Library
    10:Use The Tools
    11:Don’t Invoke Undefined Behavior
    14:Use the Tools: Automated Tests
    15:Use the Tools: Continuous Builds
    16:Use the Tools: Compiler Warnings
    17:Use the Tools: Static Analysis
    18:Use The Tools: Consider Custom Static Analysis
    19:Use the Tools: Sanitizers
    20:Use The Tools: Hardening
    21:Use the Tools: Multiple Compilers
    22:Use The Tools: Fuzzing and Mutating
    23:Use the Tools: Build Generators
    24:Use the Tools: Package Managers
    25:Make your interfaces hard to use wrong.
    27:Be Afraid of Global State
    28:Use Stronger Types (define new types, example: `velocity { int }` instead of `int`)
    29:Use [[nodiscard]] Liberally
    32:Prefer Stack Over Heap
    33:Don’t return raw pointers
    34:Be Aware of Custom Allocation And PMR
    35:Constrain Your Template Parameters With Concepts
    36:Understand consteval and constinit (and use when appropriate)
    37:Prefer Spaceships (operators)
    38:Decouple Your APIs With Views and Spans
    39:Follow the Rule of 0
    40:If You Must Do Manual Resource Management, Follow the Rule of 5
    41:Don’t Copy and Paste Code
    42:Prefer std::format, std::print Over iostream Or c-formatting Functions
    43:constexpr All The Things! (constexpr should be the prefered default as of C++23)
    44:Make globals in headers inline constexpr
    45:Safely Initialize Non-const Static Variables
    46:const Everything That’s Not constexpr
    47:Know Your Containers (prefer array over vector, vector over anything else)
    48:Always Initialize Your non-const, non-auto Values
    49:Prefer auto in Many Cases.
    50:Use Ranges and Views For Correctness and Readability
    51:Don’t Reuse Views
    52:Prefer Algorithms Over Loops
    53:Use Ranged-For Loops When Views and Algorithms Cannot Help
    54:Use auto in ranged for loops
    55:Make case statements return and Avoid default In switch Statements
    56:Prefer Scoped enum
    57:Use if constexpr When It Results In Better Code
    60:No More new! (always prefer stack or std containers, but use smart pointers if you must)
    61:Avoid std::bind and std::function (use lambdas and captures instead)
    62:Don’t Use initializer_list For Non-Trivial Types
    63:Consider Designated Initializers

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
