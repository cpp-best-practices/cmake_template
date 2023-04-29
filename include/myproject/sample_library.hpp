#ifndef SAMPLE_LIBRARY_HPP
#define SAMPLE_LIBRARY_HPP

#include <myproject/sample_library_export.hpp>

[[nodiscard]] SAMPLE_LIBRARY_EXPORT auto factorial(int) noexcept -> int;

[[nodiscard]] constexpr auto factorial_constexpr(int input) noexcept -> int
{
  if (input == 0) { return 1; }

  return input * factorial_constexpr(input - 1);
}

#endif
