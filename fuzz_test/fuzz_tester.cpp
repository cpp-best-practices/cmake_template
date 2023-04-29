#include <fmt/format.h>
#include <iterator>
#include <utility>

[[nodiscard]] auto sum_values(const uint8_t *data, std::size_t size) -> int {
    constexpr auto scale = 1000;
    int            value = 0;
    for (std::size_t offset = 0; offset < size; ++offset) {
        value += static_cast<int>(*std::next(data, static_cast<long>(offset))) * scale;
    }
    return value;
}

extern "C" {
    // Fuzzer that attempts to invoke undefined behavior for signed integer overflow
    auto LLVMFuzzerTestOneInput(const uint8_t *data, std::size_t size) -> int {
        fmt::print("Value sum: {}, len{}\n", sum_values(data, size), size);
        return 0;
    }
}
