#include <catch2/catch_test_macros.hpp>

#include <myproject/sample_library.hpp>

TEST_CASE("Factorials are computed with constexpr", "[factorial]")
{
  // TODO: Replace single line comments with cppcheck-suppress-begin/-end available in Cppcheck 2.13.0+
  STATIC_REQUIRE(factorial_constexpr(0) == 1);// cppcheck-suppress knownConditionTrueFalse
  STATIC_REQUIRE(factorial_constexpr(1) == 1);// cppcheck-suppress knownConditionTrueFalse
  STATIC_REQUIRE(factorial_constexpr(2) == 2);// cppcheck-suppress knownConditionTrueFalse
  STATIC_REQUIRE(factorial_constexpr(3) == 6);// cppcheck-suppress knownConditionTrueFalse
  STATIC_REQUIRE(factorial_constexpr(10) == 3628800);
}
