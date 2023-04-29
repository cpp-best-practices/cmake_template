#include <myproject/sample_library.hpp>

auto factorial(int input) noexcept -> int {
    int result = 1;
    while (input > 0) {
        result *= input;
        --input;
    }
    return result;
}
